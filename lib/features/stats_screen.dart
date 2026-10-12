import 'package:flutter/material.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/features/quiz_screen.dart';
import 'package:flutter_tests/widgets/common.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('stats'))),
      body: ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final history = s.history;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(children: [
                _big(context, '🔥', '${s.currentStreak}', 'streak_current'),
                const SizedBox(width: 10),
                _big(context, '🏅', '${s.bestStreak}', 'streak_best'),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _big(context, '📝', '${history.length}', 'tests_taken'),
                const SizedBox(width: 10),
                _big(context, '✅', '${s.totalAnswered}', 'questions_answered'),
                const SizedBox(width: 10),
                _big(context, '🎯', '${s.accuracy}%', 'accuracy'),
              ]),
              SectionTitle(context.tr('last_7_days')),
              const _WeekChart(),
              SectionTitle(context.tr('achievements')),
              const _Achievements(),
              SectionTitle(context.tr('history')),
              if (history.isEmpty)
                EmptyView(
                    icon: Icons.history_rounded,
                    text: context.tr('history_empty'))
              else
                ...history.take(30).map((r) => _HistoryTile(r: r)),
            ],
          );
        },
      ),
    );
  }

  Widget _big(BuildContext context, String emoji, String value, String key) =>
      Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                Text(context.tr(key),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(fontSize: 12, color: context.mutedText)),
              ],
            ),
          ),
        ),
      );
}

class _WeekChart extends StatelessWidget {
  const _WeekChart();

  // Listens itself: const instances are not rebuilt by parent rebuilds.
  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: AppState.instance, builder: (context, _) => _build(context));

  Widget _build(BuildContext context) {
    final s = AppState.instance;
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final values = days.map(s.answeredOn).toList();
    final maxV = values.fold<int>(1, (a, b) => b > a ? b : a);
    final weekdays = context.tr('weekdays_short').split(',');
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final v = values[i];
              final isToday = i == 6;
              return Expanded(
                child: Semantics(
                  label: '${weekdays[days[i].weekday - 1]}: $v',
                  excludeSemantics: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(v == 0 ? '' : '$v',
                          style: TextStyle(
                              fontSize: 11, color: context.mutedText)),
                      const SizedBox(height: 4),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: v / maxV),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (_, f, __) => Container(
                          height: 4 + 96 * f,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: isToday
                                ? context.colors.primary
                                : context.colors.primary
                                    .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(weekdays[days[i].weekday - 1],
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday
                                  ? context.colors.primary
                                  : context.mutedText)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Achievements extends StatelessWidget {
  const _Achievements();

  // Listens itself: const instances are not rebuilt by parent rebuilds.
  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: AppState.instance, builder: (context, _) => _build(context));

  Widget _build(BuildContext context) {
    final list = AppState.instance.achievements;
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 600 ? 4 : 2;
      final w = (c.maxWidth - (cols - 1) * 10) / cols;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: list.map((a) {
          final color = a.unlocked ? kWarningColor : context.mutedText;
          return SizedBox(
            width: w,
            child: Card(
              child: Opacity(
                opacity: a.unlocked ? 1 : 0.55,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(a.unlocked ? a.icon : Icons.lock_rounded,
                          color: color, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr(a.id),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                            Text(context.tr('${a.id}_desc'),
                                style: TextStyle(
                                    fontSize: 11, color: context.mutedText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _HistoryTile extends StatelessWidget {
  final ResultRecord r;
  const _HistoryTile({required this.r});

  @override
  Widget build(BuildContext context) {
    final lang = AppState.instance.lang;
    final color = r.percent >= 70
        ? kSuccessColor
        : (r.percent >= 50 ? kWarningColor : kErrorColor);
    final d = r.date;
    final date =
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () => showModeSheet(context, r.ref),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text('${r.percent}',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          title: Text(r.ref.topic.name.of(lang),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${r.ref.book.name.of(lang)} · '
            '${context.tr(r.mode == QuizMode.exam ? 'mode_exam' : 'mode_practice')} · $date',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text('${r.correct}/${r.total}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
