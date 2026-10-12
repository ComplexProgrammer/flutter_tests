import 'package:flutter/material.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/data/models.dart';
import 'package:flutter_tests/widgets/common.dart';
import 'package:flutter_tests/widgets/question_view.dart';

enum ReviewFilter { wrong, skipped, all }

/// Walks through finished questions with the correct answers revealed.
class ReviewScreen extends StatefulWidget {
  final List<Question> questions;
  final Map<int, List<Answer>> options;
  final Map<int, int> picks;
  final ReviewFilter initialFilter;

  const ReviewScreen({
    super.key,
    required this.questions,
    required this.options,
    required this.picks,
    this.initialFilter = ReviewFilter.wrong,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late ReviewFilter _filter = widget.initialFilter;
  final _page = PageController();
  int _index = 0;

  bool _isWrong(Question q) {
    final id = widget.picks[q.id];
    return id != null &&
        !(widget.options[q.id] ?? const []).any((a) => a.id == id && a.right);
  }

  List<Question> get _items => widget.questions.where((q) {
        return switch (_filter) {
          ReviewFilter.all => true,
          ReviewFilter.wrong => _isWrong(q),
          ReviewFilter.skipped => !widget.picks.containsKey(q.id),
        };
      }).toList();

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final wrongCount = widget.questions.where(_isWrong).length;
    final skippedCount =
        widget.questions.where((q) => !widget.picks.containsKey(q.id)).length;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('review_title'))),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                for (final (f, label) in [
                  (ReviewFilter.wrong, '${context.tr('legend_wrong')} ($wrongCount)'),
                  (ReviewFilter.skipped, '${context.tr('legend_empty')} ($skippedCount)'),
                  (ReviewFilter.all, '${context.tr('filter_all')} (${widget.questions.length})'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _filter == f,
                      onSelected: (_) {
                        setState(() {
                          _filter = f;
                          _index = 0;
                        });
                        if (_page.hasClients) _page.jumpToPage(0);
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyView(
                    icon: Icons.celebration_rounded,
                    text: context.tr('review_empty'))
                : PageView.builder(
                    controller: _page,
                    itemCount: items.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                      final q = items[i];
                      final number = widget.questions.indexOf(q) + 1;
                      final skipped = !widget.picks.containsKey(q.id);
                      return QuestionView(
                        header: context.tr('question_of', {
                              'n': '$number',
                              'total': '${widget.questions.length}'
                            }) +
                            (skipped ? ' · ${context.tr('legend_empty')}' : ''),
                        question: q,
                        options: widget.options[q.id] ?? const [],
                        // Skipped questions still show the right answer.
                        pickedId: widget.picks[q.id] ?? -1,
                        reveal: true,
                      );
                    },
                  ),
          ),
          if (items.length > 1)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    IconButton.outlined(
                      tooltip: context.tr('previous'),
                      onPressed: _index == 0
                          ? null
                          : () => _page.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text('${_index + 1} / ${items.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    IconButton.outlined(
                      tooltip: context.tr('next_question'),
                      onPressed: _index >= items.length - 1
                          ? null
                          : () => _page.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
