import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/data/api.dart';
import 'package:flutter_tests/data/models.dart';
import 'package:flutter_tests/features/quiz_screen.dart';
import 'package:flutter_tests/widgets/common.dart';
import 'package:flutter_tests/widgets/loader.dart';

enum _Filter { all, notStarted, inProgress, done }

class TopicsScreen extends StatefulWidget {
  final Group group;
  final Book book;
  const TopicsScreen({super.key, required this.group, required this.book});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen>
    with ApiLoader<TopicsScreen, List<Topic>> {
  final _search = TextEditingController();
  String _query = '';
  _Filter _filter = _Filter.all;

  @override
  Future<ApiResult<List<Topic>>> fetch() => Api.topics(widget.book.id);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Topic t, AppLang lang) {
    if (_query.isNotEmpty && !t.name.of(lang).toLowerCase().contains(_query)) {
      return false;
    }
    final p = AppState.instance.progressOf(t.id);
    return switch (_filter) {
      _Filter.all => true,
      _Filter.notStarted => !p.started,
      _Filter.inProgress => p.started && !p.completed,
      _Filter.done => p.completed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final lang = state.lang;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.book.name.of(lang)),
            Text(widget.group.name.of(lang),
                style: TextStyle(
                    fontSize: 12,
                    color: context.mutedText,
                    fontWeight: FontWeight.w500)),
          ],
        ),
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
              if (result != null)
                SliverToBoxAdapter(child: _BookProgress(topics: result!.data)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: SearchField(
                    controller: _search,
                    hint: context.tr('search_topic'),
                    onChanged: (v) =>
                        setState(() => _query = v.trim().toLowerCase()),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      for (final (f, key) in [
                        (_Filter.all, 'filter_all'),
                        (_Filter.notStarted, 'filter_new'),
                        (_Filter.inProgress, 'filter_progress'),
                        (_Filter.done, 'filter_done'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(context.tr(key)),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              contentSliver(
                skeleton: SliverList.separated(
                  itemCount: 8,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Skeleton(height: 76),
                  ),
                ),
                builder: (topics) {
                  final list = topics.where((t) => _matches(t, lang)).toList();
                  if (list.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        icon: Icons.search_off_rounded,
                        text: context.tr(topics.isEmpty
                            ? 'err_empty'
                            : 'nothing_found'),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _TopicTile(
                        ref: TopicRef(
                            group: widget.group,
                            book: widget.book,
                            topic: list[i]),
                        index: topics.indexOf(list[i]) + 1,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookProgress extends StatelessWidget {
  final List<Topic> topics;
  const _BookProgress({required this.topics});

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final done = topics.where((t) => s.progressOf(t.id).completed).length;
    final fraction = topics.isEmpty ? 0.0 : done / topics.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: fraction,
                        strokeWidth: 6,
                        backgroundColor: context.colors.surfaceContainerHighest,
                        color: kSuccessColor,
                      ),
                    ),
                    Text('${(fraction * 100).round()}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('book_progress'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                        context.tr('topics_done',
                            {'done': '$done', 'total': '${topics.length}'}),
                        style: TextStyle(color: context.mutedText)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final TopicRef ref;
  final int index;
  const _TopicTile({required this.ref, required this.index});

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final p = s.progressOf(ref.topic.id);
    final fav = s.isFavorite(ref.topic.id);
    final Color accent =
        p.completed ? kSuccessColor : context.colors.primary;
    final String status;
    if (p.completed) {
      status = context.tr('status_done', {'percent': '${p.percent}'});
    } else if (p.started) {
      status = p.total > 0
          ? context.tr('status_progress',
              {'answered': '${p.answered}', 'total': '${p.total}'})
          : context.tr('status_started', {'answered': '${p.answered}'});
    } else {
      status = context.tr('status_new');
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModeSheet(context, ref),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: p.completed
                    ? const Icon(Icons.check_rounded, color: kSuccessColor)
                    : Text('$index',
                        style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ref.topic.name.of(s.lang),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            height: 1.25)),
                    const SizedBox(height: 4),
                    Text(status,
                        style: TextStyle(
                            fontSize: 12.5,
                            color: p.started ? accent : context.mutedText,
                            fontWeight: FontWeight.w500)),
                    if (p.started && p.total > 0) ...[
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: p.fraction,
                        minHeight: 4,
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                        backgroundColor: context.colors.surfaceContainerHighest,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: context.tr(fav ? 'fav_remove' : 'fav_add'),
                onPressed: () => s.toggleFavorite(ref),
                icon: Icon(fav ? Icons.star_rounded : Icons.star_border_rounded,
                    color: fav ? kFillStarColor : context.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
