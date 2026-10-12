import 'package:flutter/material.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/features/home_screen.dart';

/// First-launch intro: pick a language, then three short feature slides.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  static const _slides = [
    (Icons.translate_rounded, 'onb_lang_title', 'onb_lang_text'),
    (Icons.school_rounded, 'onb1_title', 'onb1_text'),
    (Icons.timer_rounded, 'onb2_title', 'onb2_text'),
    (Icons.insights_rounded, 'onb3_title', 'onb3_text'),
  ];

  void _finish() {
    AppState.instance.setOnboardingSeen();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: _finish, child: Text(context.tr('skip'))),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final (icon, title, text) = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon,
                              size: 72, color: context.colors.primary),
                        ),
                        const SizedBox(height: 32),
                        Text(context.tr(title),
                            textAlign: TextAlign.center,
                            style: context.text.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(context.tr(text),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: context.mutedText,
                                fontSize: 16,
                                height: 1.4)),
                        if (i == 0) ...[
                          const SizedBox(height: 24),
                          const LanguagePicker(),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.all(4),
                  height: 8,
                  width: i == _index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? context.colors.primary
                        : context.colors.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: last
                      ? _finish
                      : () => _page.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut),
                  child: Text(context.tr(last ? 'start' : 'next')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: AppLang.values
          .map((l) => ChoiceChip(
                label: Text(l.label),
                selected: state.lang == l,
                onSelected: (_) => state.setLang(l),
              ))
          .toList(),
    );
  }
}
