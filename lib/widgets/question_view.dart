import 'package:flutter/material.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/data/models.dart';
import 'package:flutter_tests/widgets/common.dart';

enum OptionState { idle, selected, correct, wrong, dimmed }

String optionLetter(int i) => i < 26 ? String.fromCharCode(65 + i) : '${i + 1}';

/// Visual state of an option. With [reveal] the correct answer is shown once
/// something is picked (practice / review); otherwise only the pick (exam).
OptionState optionStateFor(Answer a, int? pickedId, {required bool reveal}) {
  if (pickedId == null) return OptionState.idle;
  if (!reveal) return a.id == pickedId ? OptionState.selected : OptionState.idle;
  if (a.right) return OptionState.correct;
  if (a.id == pickedId) return OptionState.wrong;
  return OptionState.dimmed;
}

/// One question page: text, optional image, options, feedback and explanation.
class QuestionView extends StatelessWidget {
  final Question question;
  final List<Answer> options;
  final int? pickedId;
  final bool reveal;
  final ValueChanged<Answer>? onPick;
  final VoidCallback? onReport;
  final String? header;

  const QuestionView({
    super.key,
    required this.question,
    required this.options,
    required this.pickedId,
    required this.reveal,
    this.onPick,
    this.onReport,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final lang = AppState.instance.lang;
    final locked = reveal && pickedId != null;
    final explanation = question.explanation.of(lang);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(header!,
                style: TextStyle(
                    color: context.mutedText, fontWeight: FontWeight.w600)),
          ),
        Text(
          question.text.of(lang),
          style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w600, height: 1.4, fontSize: 19),
        ),
        if (question.image.isNotEmpty) ...[
          const SizedBox(height: 14),
          Semantics(
            button: true,
            label: context.tr('zoom_image'),
            child: GestureDetector(
              onTap: () => showZoomableImage(context, question.image),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.white,
                  constraints: const BoxConstraints(maxHeight: 260),
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: NetImage(question.image, fit: BoxFit.contain)),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.zoom_in_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OptionTile(
              letter: optionLetter(i),
              answer: options[i],
              state: optionStateFor(options[i], pickedId, reveal: reveal),
              onTap: (onPick == null || locked)
                  ? null
                  : () => onPick!(options[i]),
            ),
          ),
        if (reveal && pickedId != null) ...[
          const SizedBox(height: 4),
          _FeedbackCard(
            right: options.any((a) => a.id == pickedId && a.right),
            correctLetter: () {
              final i = options.indexWhere((a) => a.right);
              return i < 0 ? null : optionLetter(i);
            }(),
          ),
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.lightbulb_rounded,
                          size: 18, color: kWarningColor),
                      const SizedBox(width: 6),
                      Text(context.tr('explanation'),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 6),
                    Text(explanation, style: const TextStyle(height: 1.4)),
                  ],
                ),
              ),
            ),
          ],
        ],
        if (onReport != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: onReport,
              icon: const Icon(Icons.report_gmailerrorred_rounded, size: 18),
              label: Text(context.tr('report_question')),
              style: TextButton.styleFrom(foregroundColor: context.mutedText),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final bool right;
  final String? correctLetter;
  const _FeedbackCard({required this.right, this.correctLetter});

  @override
  Widget build(BuildContext context) {
    final color = right ? kSuccessColor : kErrorColor;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(right ? Icons.celebration_rounded : Icons.info_rounded,
                color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                right
                    ? context.tr('feedback_right')
                    : context.tr('feedback_wrong',
                        {'letter': correctLetter ?? '?'}),
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionTile extends StatelessWidget {
  final String letter;
  final Answer answer;
  final OptionState state;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.letter,
    required this.answer,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cardBg = Theme.of(context).cardTheme.color ?? c.surface;
    final (Color border, Color bg, Color fg) = switch (state) {
      OptionState.idle => (c.outlineVariant, cardBg, c.onSurface),
      OptionState.selected => (
          c.primary,
          c.primary.withValues(alpha: 0.12),
          c.primary
        ),
      OptionState.correct => (
          kSuccessColor,
          kSuccessColor.withValues(alpha: 0.12),
          kSuccessColor
        ),
      OptionState.wrong => (
          kErrorColor,
          kErrorColor.withValues(alpha: 0.12),
          kErrorColor
        ),
      OptionState.dimmed => (
          c.outlineVariant.withValues(alpha: 0.5),
          cardBg,
          c.onSurface.withValues(alpha: 0.55)
        ),
    };
    final strong = state != OptionState.idle && state != OptionState.dimmed;
    final lang = AppState.instance.lang;
    final text = answer.text.of(lang);
    final stateLabel = switch (state) {
      OptionState.correct => context.tr('legend_right'),
      OptionState.wrong => context.tr('legend_wrong'),
      OptionState.selected => context.tr('selected'),
      _ => '',
    };

    return Semantics(
      button: onTap != null,
      selected: strong,
      label: '$letter. $text. $stateLabel',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: strong ? 2 : 1.2),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: strong ? border : Colors.transparent,
                      border: Border.all(color: border, width: 1.5),
                    ),
                    child: Text(letter,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: strong ? Colors.white : fg)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (text.isNotEmpty)
                          Text(text,
                              style: TextStyle(
                                  fontSize: 16,
                                  height: 1.3,
                                  color: fg,
                                  fontWeight: strong
                                      ? FontWeight.w600
                                      : FontWeight.w500)),
                        if (answer.image.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: GestureDetector(
                              onTap: () =>
                                  showZoomableImage(context, answer.image),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 140),
                                  child: NetImage(answer.image,
                                      fit: BoxFit.contain),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (state == OptionState.correct)
                    const Icon(Icons.check_circle_rounded, color: kSuccessColor)
                  else if (state == OptionState.wrong)
                    const Icon(Icons.cancel_rounded, color: kErrorColor)
                  else if (state == OptionState.selected)
                    Icon(Icons.radio_button_checked_rounded, color: c.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionSkeleton extends StatelessWidget {
  const QuestionSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const Skeleton(height: 10, width: 120, radius: 5),
          const SizedBox(height: 16),
          const Skeleton(height: 22),
          const SizedBox(height: 8),
          const Skeleton(height: 22, width: 220),
          const SizedBox(height: 28),
          for (var i = 0; i < 4; i++) ...[
            const Skeleton(height: 60),
            const SizedBox(height: 10),
          ],
        ],
      );
}
