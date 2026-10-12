import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/services.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/data/api.dart';
import 'package:flutter_tests/data/models.dart';
import 'package:flutter_tests/features/result_screen.dart';
import 'package:flutter_tests/features/settings_screen.dart';
import 'package:flutter_tests/widgets/common.dart';
import 'package:flutter_tests/widgets/question_view.dart';

/// Seconds per question in exam mode.
const kExamSecondsPerQuestion = 90;

/// Lets the user choose practice / exam (and continue or restart).
Future<void> showModeSheet(BuildContext context, TopicRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _ModeSheet(ref: ref, parent: context),
  );
}

class _ModeSheet extends StatelessWidget {
  final TopicRef ref;
  final BuildContext parent;
  const _ModeSheet({required this.ref, required this.parent});

  void _open(BuildContext context, QuizMode mode, {bool restart = false}) {
    Navigator.pop(context);
    if (restart) AppState.instance.resetTopic(ref.topic.id);
    Navigator.push(parent,
        MaterialPageRoute(builder: (_) => QuizScreen(ref: ref, mode: mode)));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final p = s.progressOf(ref.topic.id);
    final examMinutes = p.total > 0
        ? (p.total * kExamSecondsPerQuestion / 60).ceil().toString()
        : null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(ref.topic.name.of(s.lang),
                textAlign: TextAlign.center,
                style: context.text.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${ref.group.name.of(s.lang)} · ${ref.book.name.of(s.lang)}',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.mutedText)),
            const SizedBox(height: 20),
            if (p.started && !p.completed)
              _option(
                context,
                icon: Icons.play_arrow_rounded,
                color: context.colors.primary,
                title: context.tr('continue_test'),
                subtitle: p.total > 0
                    ? context.tr('status_progress',
                        {'answered': '${p.answered}', 'total': '${p.total}'})
                    : null,
                onTap: () => _open(context, QuizMode.practice),
                filled: true,
              ),
            if (p.completed)
              _option(
                context,
                icon: Icons.fact_check_rounded,
                color: kSuccessColor,
                title: context.tr('review_answers'),
                subtitle: context.tr('status_done', {'percent': '${p.percent}'}),
                onTap: () => _open(context, QuizMode.practice),
                filled: true,
              ),
            _option(
              context,
              icon: p.started ? Icons.restart_alt_rounded : Icons.school_rounded,
              color: kSuccessColor,
              title: context.tr(p.started ? 'restart_practice' : 'mode_practice'),
              subtitle: context.tr('mode_practice_desc'),
              onTap: () => _open(context, QuizMode.practice, restart: p.started),
            ),
            _option(
              context,
              icon: Icons.timer_rounded,
              color: kWarningColor,
              title: context.tr('mode_exam'),
              subtitle: examMinutes == null
                  ? context.tr('mode_exam_desc')
                  : context.tr('mode_exam_desc_min', {'min': examMinutes}),
              onTap: () => _open(context, QuizMode.exam),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      String? subtitle,
      required VoidCallback onTap,
      bool filled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: filled
            ? color.withValues(alpha: 0.12)
            : context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      if (subtitle != null)
                        Text(subtitle,
                            style: TextStyle(
                                color: context.mutedText, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final TopicRef ref;
  final QuizMode mode;
  const QuizScreen({super.key, required this.ref, required this.mode});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _state = AppState.instance;
  final _page = PageController();
  final _watch = Stopwatch();
  final Map<int, int> _examPicks = {};

  List<Question> _questions = [];
  Map<int, List<Answer>> _options = {};
  bool _loading = true;
  bool _fromCache = false;
  Object? _error;
  int _index = 0;
  Timer? _timer;
  int _remaining = 0;
  bool _finished = false;
  Timer? _autoNext;

  bool get _exam => widget.mode == QuizMode.exam;
  int get _topicId => widget.ref.topic.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoNext?.cancel();
    _page.dispose();
    super.dispose();
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Api.quiz(_topicId, forceRefresh: force);
      if (!mounted) return;
      final data = res.data;
      final questions = List.of(data.questions);
      final options = <int, List<Answer>>{};
      final rnd = Random(DateTime.now().millisecondsSinceEpoch);
      if (_exam) questions.shuffle(rnd);
      for (final q in questions) {
        final list = List.of(data.answers[q.id] ?? const <Answer>[]);
        if (_state.shuffleAnswers || _exam) list.shuffle(rnd);
        options[q.id] = list;
      }
      _state.setTopicTotal(_topicId, questions.length);

      var start = 0;
      if (!_exam) {
        _state.setLastSession(widget.ref);
        final done = _state.answersFor(_topicId);
        start = questions.indexWhere((q) => !done.containsKey(q.id));
      }
      setState(() {
        _questions = questions;
        _options = options;
        _fromCache = res.fromCache;
        _loading = false;
        _index = start < 0 ? 0 : start;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_page.hasClients && _index > 0) _page.jumpToPage(_index);
        if (!_exam && start < 0) _showCompletedHint();
      });
      _watch.start();
      if (_exam) {
        _remaining = questions.length * kExamSecondsPerQuestion;
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() => _remaining--);
          if (_remaining <= 0) {
            _timer?.cancel();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('time_up'))));
            _finish(force: true);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _showCompletedHint() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(context.tr('topic_completed_hint')),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
          label: context.tr('see_result'), onPressed: () => _finish(force: true)),
    ));
  }

  int? _picked(Question q) =>
      _exam ? _examPicks[q.id] : _state.answersFor(_topicId)[q.id]?.answerId;

  int get _answeredCount => _questions.where((q) => _picked(q) != null).length;

  void _pick(Question q, Answer a) {
    _autoNext?.cancel();
    if (_exam) {
      Sfx.tap();
      setState(() => _examPicks[q.id] = a.id);
      if (_state.autoNext) {
        _autoNext = Timer(const Duration(milliseconds: 350), _nextUnlessLast);
      }
      return;
    }
    if (_picked(q) != null) return;
    _state.recordAnswer(_topicId, q.id, a.id, a.right);
    a.right ? Sfx.right() : Sfx.wrong();
    setState(() {});
    if (_answeredCount == _questions.length) {
      _state.clearLastSession();
    } else if (a.right && _state.autoNext) {
      _autoNext = Timer(const Duration(milliseconds: 900), _nextUnlessLast);
    }
  }

  void _nextUnlessLast() {
    if (!mounted || _index >= _questions.length - 1) return;
    _goTo(_index + 1);
  }

  void _goTo(int i) {
    _autoNext?.cancel();
    _page.animateToPage(i,
        duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  Future<void> _finish({bool force = false}) async {
    if (_finished) return;
    final unanswered = _questions.length - _answeredCount;
    if (!force && unanswered > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.help_outline_rounded, size: 36),
          title: Text(ctx.tr('finish_confirm_title')),
          content: Text(ctx.tr('finish_confirm_text', {'n': '$unanswered'})),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(ctx.tr('keep_going'))),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(ctx.tr('finish'))),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    _finished = true;
    _timer?.cancel();
    _autoNext?.cancel();
    _watch.stop();

    final picks = <int, int>{};
    var correct = 0, wrong = 0;
    for (final q in _questions) {
      final id = _picked(q);
      if (id == null) continue;
      picks[q.id] = id;
      final right = _options[q.id]!.any((a) => a.id == id && a.right);
      right ? correct++ : wrong++;
    }
    final record = ResultRecord(
      ref: widget.ref,
      mode: widget.mode,
      correct: correct,
      wrong: wrong,
      total: _questions.length,
      seconds: _watch.elapsed.inSeconds,
      date: DateTime.now(),
    );
    _state.addResult(record,
        answeredOutsidePractice: _exam ? picks.length : 0);
    if (!_exam && picks.length == _questions.length) _state.clearLastSession();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          record: record,
          questions: _questions,
          options: _options,
          picks: picks,
        ),
      ),
    );
  }

  Future<bool> _confirmExit() async {
    if (!_exam || _examPicks.isEmpty || _finished) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('exit_exam_title')),
        content: Text(ctx.tr('exit_exam_text')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctx.tr('keep_going'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ctx.tr('exit'),
                  style: const TextStyle(color: kErrorColor))),
        ],
      ),
    );
    return ok == true;
  }

  void _restart() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('restart_practice')),
        content: Text(ctx.tr('restart_confirm')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctx.tr('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ctx.tr('restart'))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _state.resetTopic(_topicId);
    _state.setLastSession(widget.ref);
    setState(() {});
    _page.jumpToPage(0);
  }

  void _report() {
    if (_questions.isEmpty) return;
    final q = _questions[_index];
    final lang = _state.lang;
    sendEmail(
      context,
      '${context.tr('report_subject')} #${q.id}',
      '${widget.ref.group.name.of(lang)} / ${widget.ref.book.name.of(lang)} / '
      '${widget.ref.topic.name.of(lang)}\n'
      '#${q.id}: ${q.text.of(lang)}\n\n${context.tr('report_body')}\n',
    );
  }

  void _openGrid() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _QuestionGrid(
        count: _questions.length,
        current: _index,
        exam: _exam,
        stateOf: (i) {
          final q = _questions[i];
          final id = _picked(q);
          if (id == null) return null;
          if (_exam) return true;
          return _options[q.id]!.any((a) => a.id == id && a.right);
        },
        onSelect: (i) {
          Navigator.pop(ctx);
          _page.jumpToPage(i);
        },
        onFinish: () {
          Navigator.pop(ctx);
          _finish();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = _state.lang;
    return PopScope(
      canPop: !_exam || _examPicks.isEmpty || _finished,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit() && context.mounted) {
          _finished = true;
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(widget.ref.topic.name.of(lang),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(context.tr(_exam ? 'mode_exam' : 'mode_practice'),
                  style: TextStyle(
                      fontSize: 12,
                      color: context.mutedText,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          actions: [
            if (_exam && !_loading && _error == null) _timerChip(context),
            if (_questions.isNotEmpty)
              IconButton(
                tooltip: context.tr('all_questions'),
                icon: const Icon(Icons.grid_view_rounded),
                onPressed: _openGrid,
              ),
            PopupMenuButton<String>(
              onSelected: (v) {
                switch (v) {
                  case 'report':
                    _report();
                  case 'restart':
                    _restart();
                  case 'settings':
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  case 'finish':
                    _finish();
                }
              },
              itemBuilder: (ctx) => [
                if (_questions.isNotEmpty)
                  PopupMenuItem(
                      value: 'finish',
                      child: _menuRow(Icons.flag_rounded, ctx.tr('finish'))),
                if (!_exam && _questions.isNotEmpty)
                  PopupMenuItem(
                      value: 'restart',
                      child: _menuRow(
                          Icons.restart_alt_rounded, ctx.tr('restart'))),
                if (_questions.isNotEmpty)
                  PopupMenuItem(
                      value: 'report',
                      child: _menuRow(
                          Icons.report_gmailerrorred_rounded, ctx.tr('report'))),
                PopupMenuItem(
                    value: 'settings',
                    child: _menuRow(Icons.tune_rounded, ctx.tr('settings'))),
              ],
            ),
          ],
        ),
        body: _body(context),
        bottomNavigationBar: _questions.isEmpty ? null : _bottomBar(context),
      ),
    );
  }

  Widget _menuRow(IconData icon, String text) => Row(children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(text),
      ]);

  Widget _timerChip(BuildContext context) {
    final low = _remaining < 60;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (low ? kErrorColor : context.colors.primary)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined,
              size: 16, color: low ? kErrorColor : context.colors.primary),
          const SizedBox(width: 4),
          Text(formatDuration(max(0, _remaining)),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: low ? kErrorColor : context.colors.primary)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const QuestionSkeleton();
    if (_error != null) {
      return ErrorView(error: _error!, onRetry: () => _load(force: true));
    }
    final answered = _answeredCount;
    final total = _questions.length;
    final checked = _exam
        ? null
        : _state.answersFor(_topicId);
    final correct = checked?.values.where((r) => r.right).length ?? 0;
    return Column(
      children: [
        if (_fromCache) const OfflineBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text(context.tr('question_of',
                  {'n': '${_index + 1}', 'total': '$total'}),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (_exam)
                Text(context.tr('answered_of',
                    {'n': '$answered', 'total': '$total'}),
                    style: TextStyle(color: context.mutedText, fontSize: 13))
              else ...[
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: kSuccessColor),
                const SizedBox(width: 4),
                Text('$correct',
                    style: const TextStyle(
                        color: kSuccessColor, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                const Icon(Icons.cancel_rounded, size: 16, color: kErrorColor),
                const SizedBox(width: 4),
                Text('${(checked?.length ?? 0) - correct}',
                    style: const TextStyle(
                        color: kErrorColor, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: total == 0 ? 0 : answered / total),
            duration: const Duration(milliseconds: 300),
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              backgroundColor: context.colors.surfaceContainerHighest,
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _page,
            itemCount: total,
            onPageChanged: (i) {
              Sfx.tap();
              setState(() => _index = i);
            },
            itemBuilder: (context, i) {
              final q = _questions[i];
              return QuestionView(
                question: q,
                options: _options[q.id] ?? const [],
                pickedId: _picked(q),
                reveal: !_exam,
                onPick: (a) => _pick(q, a),
                onReport: _report,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _bottomBar(BuildContext context) {
    final last = _index == _questions.length - 1;
    final allDone = _answeredCount == _questions.length;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: _index == 0 ? null : () => _goTo(_index - 1),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(56, 50),
                      padding: EdgeInsets.zero),
                  child: Icon(Icons.arrow_back_rounded,
                      semanticLabel: context.tr('previous')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: (last || allDone)
                      ? FilledButton.icon(
                          onPressed: _finish,
                          icon: const Icon(Icons.flag_rounded),
                          label: Text(context.tr('finish')),
                          style: FilledButton.styleFrom(
                              backgroundColor: allDone ? kSuccessColor : null),
                        )
                      : FilledButton.icon(
                          onPressed: () => _goTo(_index + 1),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(context.tr('next_question')),
                        ),
                ),
                if (allDone && !last) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => _goTo(_index + 1),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(56, 50),
                        padding: EdgeInsets.zero),
                    child: Icon(Icons.arrow_forward_rounded,
                        semanticLabel: context.tr('next_question')),
                  ),
                ],
              ],
            ),
          ),
          if (!_exam) const BannerAdBox(),
        ],
      ),
    );
  }
}

class _QuestionGrid extends StatelessWidget {
  final int count;
  final int current;
  final bool exam;

  /// null = unanswered, true = right (or answered in exam), false = wrong.
  final bool? Function(int) stateOf;
  final ValueChanged<int> onSelect;
  final VoidCallback onFinish;

  const _QuestionGrid({
    required this.count,
    required this.current,
    required this.exam,
    required this.stateOf,
    required this.onSelect,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final answeredColor = exam ? context.colors.primary : kSuccessColor;
    return SafeArea(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.tr('all_questions'),
                  style: context.text.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                children: [
                  _legend(context, answeredColor,
                      context.tr(exam ? 'legend_answered' : 'legend_right')),
                  if (!exam) _legend(context, kErrorColor, context.tr('legend_wrong')),
                  _legend(context, context.colors.outlineVariant,
                      context.tr('legend_empty')),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: List.generate(count, (i) {
                      final st = stateOf(i);
                      final color = st == null
                          ? null
                          : (st ? answeredColor : kErrorColor);
                      return Semantics(
                        button: true,
                        label: context.tr('question_of',
                            {'n': '${i + 1}', 'total': '$count'}),
                        child: InkWell(
                          onTap: () => onSelect(i),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color?.withValues(alpha: 0.15),
                              border: Border.all(
                                color: i == current
                                    ? context.colors.primary
                                    : (color ?? context.colors.outlineVariant),
                                width: i == current ? 3 : 1.5,
                              ),
                            ),
                            child: Text('${i + 1}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: color ?? context.colors.onSurface)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onFinish,
                  icon: const Icon(Icons.flag_rounded),
                  label: Text(context.tr('finish')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend(BuildContext context, Color color, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, color: context.mutedText)),
        ],
      );
}
