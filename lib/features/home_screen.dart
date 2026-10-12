import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/data/api.dart';
import 'package:flutter_tests/data/models.dart';
import 'package:flutter_tests/features/app_drawer.dart';
import 'package:flutter_tests/features/books_screen.dart';
import 'package:flutter_tests/features/quiz_screen.dart';
import 'package:flutter_tests/features/stats_screen.dart';
import 'package:flutter_tests/widgets/common.dart';
import 'package:flutter_tests/widgets/loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with ApiLoader<HomeScreen, List<Group>> {
  @override
  Future<ApiResult<List<Group>>> fetch() async {
    final r = await Api.groups();
    r.data.sort((a, b) => a.number.compareTo(b.number));
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(context.tr('app_name')),
        actions: [
          IconButton(
            tooltip: context.tr('stats'),
            icon: const Icon(Icons.insights_rounded),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
        ],
      ),
      bottomNavigationBar: const BannerAdBox(),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) => RefreshIndicator(
          onRefresh: reload,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              offlineSliver(),
              const SliverToBoxAdapter(child: _StatsHeader()),
              if (state.lastSession != null)
                SliverToBoxAdapter(
                    child: _ContinueCard(ref: state.lastSession!)),
              if (state.favorites.isNotEmpty) ...[
                SliverToBoxAdapter(
                    child: SectionTitle(context.tr('favorites'))),
                SliverToBoxAdapter(
                    child: _FavoritesRow(items: state.favorites)),
              ],
              SliverToBoxAdapter(
                  child: SectionTitle(context.tr('choose_class'))),
              contentSliver(
                skeleton: _grid(List.generate(
                    6, (_) => const Skeleton(radius: 20)), context),
                builder: (groups) => groups.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyView(
                            icon: Icons.inbox_rounded,
                            text: context.tr('err_empty')))
                    : _grid(
                        groups.map((g) => _GroupTile(group: g)).toList(),
                        context),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _grid(List<Widget> children, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.count(
        crossAxisCount: width > 900 ? 4 : (width > 600 ? 3 : 2),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
        children: children,
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const StatsScreen())),
          child: Ink(
            decoration: const BoxDecoration(gradient: kVibrantGradient),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _stat(context, '🔥', '${s.currentStreak}', context.tr('streak_days')),
                _divider(),
                _stat(context, '✅', '${s.answeredToday}', context.tr('today')),
                _divider(),
                _stat(context, '🎯', '${s.accuracy}%', context.tr('accuracy')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 36, color: Colors.white.withValues(alpha: 0.3));

  Widget _stat(BuildContext context, String emoji, String value, String label) =>
      Expanded(
        child: Column(
          children: [
            Text('$emoji $value',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
          ],
        ),
      );
}

class _ContinueCard extends StatelessWidget {
  final TopicRef ref;
  const _ContinueCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    final lang = AppState.instance.lang;
    final p = AppState.instance.progressOf(ref.topic.id);
    if (p.completed) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    QuizScreen(ref: ref, mode: QuizMode.practice)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: p.total == 0 ? 0 : p.fraction,
                        strokeWidth: 5,
                        backgroundColor: context.colors.surfaceContainerHighest,
                      ),
                      Icon(Icons.play_arrow_rounded,
                          color: context.colors.primary, size: 28),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('continue_test'),
                          style: TextStyle(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(ref.topic.name.of(lang),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        '${ref.group.name.of(lang)} · ${ref.book.name.of(lang)}'
                        '${p.total > 0 ? ' · ${p.answered}/${p.total}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(color: context.mutedText, fontSize: 13),
                      ),
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

class _FavoritesRow extends StatelessWidget {
  final List<TopicRef> items;
  const _FavoritesRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final lang = AppState.instance.lang;
    return SizedBox(
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final ref = items[i];
          final p = AppState.instance.progressOf(ref.topic.id);
          return SizedBox(
            width: 220,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => showModeSheet(context, ref),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            color: kFillStarColor, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(ref.book.name.of(lang),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: context.mutedText, fontSize: 12)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(ref.topic.name.of(lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      LinearProgressIndicator(
                        value: p.fraction,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(3),
                        backgroundColor: context.colors.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final Group group;
  const _GroupTile({required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => BooksScreen(group: group))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: NetImage(group.image,
                    fit: BoxFit.contain, fallbackIcon: Icons.school_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 10, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name.of(AppState.instance.lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded,
                      size: 18, color: context.colors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
