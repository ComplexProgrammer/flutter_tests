import 'package:flutter/material.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/services.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/data/api.dart';
import 'package:flutter_tests/data/models.dart';
import 'package:flutter_tests/features/quiz_screen.dart';
import 'package:flutter_tests/features/review_screen.dart';
import 'package:flutter_tests/widgets/common.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  final ResultRecord record;
  final List<Question> questions;
  final Map<int, List<Answer>> options;
  final Map<int, int> picks;

  const ResultScreen({
    super.key,
    required this.record,
    required this.questions,
    required this.options,
    required this.picks,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  TopicRef? _next;

  ResultRecord get r => widget.record;

  @override
  void initState() {
    super.initState();
    _findNextTopic();
    if (r.percent >= 70) Sfx.right();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1200), AdManager.onQuizFinished);
    });
  }

  Future<void> _findNextTopic() async {
    try {
      final topics = (await Api.topics(r.ref.book.id)).data;
      final i = topics.indexWhere((t) => t.id == r.ref.topic.id);
      if (i >= 0 && i + 1 < topics.length && mounted) {
        setState(() => _next = TopicRef(
            group: r.ref.group, book: r.ref.book, topic: topics[i + 1]));
      }
    } catch (_) {}
  }

  void _restart() {
    if (r.mode == QuizMode.practice) AppState.instance.resetTopic(r.ref.topic.id);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => QuizScreen(ref: r.ref, mode: r.mode)));
  }

  void _openNext() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => QuizScreen(ref: _next!, mode: r.mode)));
  }

  void _review(ReviewFilter filter) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewScreen(
            questions: widget.questions,
            options: widget.options,
            picks: widget.picks,
            initialFilter: filter,
          ),
        ),
      );

  void _share() {
    final lang = AppState.instance.lang;
    Share.share(context.tr('share_result', {
      'percent': '${r.percent}',
      'topic': r.ref.topic.name.of(lang),
      'subject': r.ref.book.name.of(lang),
      'correct': '${r.correct}',
      'total': '${r.total}',
      'url': kStoreUrl,
    }));
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppState.instance.lang;
    final (gradeKey, emoji) = gradeFor(r.percent);
    final color = r.percent >= 70
        ? kSuccessColor
        : (r.percent >= 50 ? kWarningColor : kErrorColor);
    final mistakes = r.wrong + r.skipped;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('result')),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: context.tr('close'),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: context.tr('share'),
            onPressed: _share,
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: r.percent / 100),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: v,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        color: color,
                        backgroundColor: context.colors.surfaceContainerHighest,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 30)),
                        Text('${(v * 100).round()}%',
                            style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: color)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(context.tr(gradeKey),
              textAlign: TextAlign.center,
              style: context.text.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '${r.ref.topic.name.of(lang)}\n'
            '${context.tr(r.mode == QuizMode.exam ? 'mode_exam' : 'mode_practice')}',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.mutedText, height: 1.4),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _tile(context, Icons.check_circle_rounded, kSuccessColor,
                  '${r.correct}', context.tr('legend_right')),
              const SizedBox(width: 10),
              _tile(context, Icons.cancel_rounded, kErrorColor, '${r.wrong}',
                  context.tr('legend_wrong')),
              const SizedBox(width: 10),
              _tile(context, Icons.radio_button_unchecked_rounded,
                  context.mutedText, '${r.skipped}', context.tr('legend_empty')),
              const SizedBox(width: 10),
              _tile(context, Icons.schedule_rounded, context.colors.primary,
                  formatDuration(r.seconds), context.tr('time')),
            ],
          ),
          const SizedBox(height: 24),
          if (mistakes > 0) ...[
            FilledButton.icon(
              onPressed: () => _review(
                  r.wrong > 0 ? ReviewFilter.wrong : ReviewFilter.skipped),
              icon: const Icon(Icons.fact_check_rounded),
              label: Text(context.tr('review_mistakes', {'n': '$mistakes'})),
              style: FilledButton.styleFrom(backgroundColor: kErrorColor),
            ),
            const SizedBox(height: 10),
          ],
          if (_next != null) ...[
            FilledButton.icon(
              onPressed: _openNext,
              icon: const Icon(Icons.skip_next_rounded),
              label: Text(context.tr('next_topic')),
            ),
            const SizedBox(height: 10),
          ],
          OutlinedButton.icon(
            onPressed: _restart,
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(context.tr('restart')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _review(ReviewFilter.all),
            icon: const Icon(Icons.list_alt_rounded),
            label: Text(context.tr('review_all')),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.topic_rounded),
            label: Text(context.tr('back_to_topics')),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, Color color, String value,
          String label) =>
      Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                FittedBox(
                  child: Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 18)),
                ),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: context.mutedText)),
              ],
            ),
          ),
        ),
      );
}
