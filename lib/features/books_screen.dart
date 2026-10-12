import 'package:flutter/material.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/data/api.dart';
import 'package:flutter_tests/data/models.dart';
import 'package:flutter_tests/features/topics_screen.dart';
import 'package:flutter_tests/widgets/common.dart';
import 'package:flutter_tests/widgets/loader.dart';

/// Subjects (books) of a class.
class BooksScreen extends StatefulWidget {
  final Group group;
  const BooksScreen({super.key, required this.group});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with ApiLoader<BooksScreen, List<Book>> {
  final _search = TextEditingController();
  String _query = '';

  @override
  Future<ApiResult<List<Book>>> fetch() => Api.books(widget.group.id);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppState.instance.lang;
    final width = MediaQuery.of(context).size.width;
    final columns = width > 900 ? 4 : (width > 600 ? 3 : 2);
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name.of(lang))),
      bottomNavigationBar: const BannerAdBox(),
      body: RefreshIndicator(
        onRefresh: reload,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            offlineSliver(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SearchField(
                  controller: _search,
                  hint: context.tr('search_subject'),
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
            ),
            contentSliver(
              skeleton: SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid.count(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children:
                      List.generate(6, (_) => const Skeleton(radius: 20)),
                ),
              ),
              builder: (books) {
                final list = books
                    .where((b) =>
                        _query.isEmpty ||
                        b.name.of(lang).toLowerCase().contains(_query))
                    .toList();
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyView(
                        icon: Icons.search_off_rounded,
                        text: context.tr(
                            _query.isEmpty ? 'err_empty' : 'nothing_found')),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverGrid.count(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: list
                        .map((b) => _BookTile(group: widget.group, book: b))
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  final Group group;
  final Book book;
  const _BookTile({required this.group, required this.book});

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TopicsScreen(group: group, book: book)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: NetImage(book.image,
                      fit: BoxFit.contain,
                      fallbackIcon: Icons.menu_book_rounded),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                color: context.colors.primary.withValues(alpha: 0.06),
                child: Text(
                  book.name.of(AppState.instance.lang),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, height: 1.2),
                ),
              ),
            ],
          ),
        ),
      );
}
