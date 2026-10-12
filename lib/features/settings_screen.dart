import 'package:flutter/material.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/services.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/data/api.dart';
import 'package:flutter_tests/features/onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ListenableBuilder(
        listenable: s,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _header(context, 'settings_language'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                  alignment: Alignment.centerLeft, child: LanguagePicker()),
            ),
            _header(context, 'settings_appearance'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_rounded),
                      label: Text(context.tr('theme_system'))),
                  ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_rounded),
                      label: Text(context.tr('theme_light'))),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_rounded),
                      label: Text(context.tr('theme_dark'))),
                ],
                selected: {s.themeMode},
                onSelectionChanged: (v) => s.setThemeMode(v.first),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.format_size_rounded),
              title: Text(context.tr('text_size')),
              subtitle: Slider(
                value: s.textScale,
                min: 0.85,
                max: 1.4,
                divisions: 11,
                label: '${(s.textScale * 100).round()}%',
                onChanged: s.setTextScale,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(context.tr('text_preview'),
                      style: const TextStyle(fontSize: 17, height: 1.4)),
                ),
              ),
            ),
            _header(context, 'settings_quiz'),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up_rounded),
              title: Text(context.tr('sound')),
              value: s.sound,
              onChanged: s.setSound,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.vibration_rounded),
              title: Text(context.tr('haptics')),
              value: s.haptics,
              onChanged: s.setHaptics,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.fast_forward_rounded),
              title: Text(context.tr('auto_next')),
              subtitle: Text(context.tr('auto_next_desc')),
              value: s.autoNext,
              onChanged: s.setAutoNext,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.shuffle_rounded),
              title: Text(context.tr('shuffle')),
              subtitle: Text(context.tr('shuffle_desc')),
              value: s.shuffleAnswers,
              onChanged: s.setShuffle,
            ),
            if (isMobile)
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_rounded),
                title: Text(context.tr('reminders')),
                subtitle: Text(context.tr('reminders_desc')),
                value: s.reminders,
                onChanged: (v) {
                  s.setReminders(v);
                  Reminders.apply(v);
                },
              ),
            _header(context, 'settings_data'),
            ListTile(
              leading: const Icon(Icons.cleaning_services_rounded),
              title: Text(context.tr('clear_cache')),
              subtitle: Text(context.tr('clear_cache_desc')),
              onTap: () async {
                await Api.clearCache();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.tr('done'))));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded,
                  color: kErrorColor),
              title: Text(context.tr('reset_progress'),
                  style: const TextStyle(color: kErrorColor)),
              subtitle: Text(context.tr('reset_progress_desc')),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(ctx.tr('reset_progress')),
                    content: Text(ctx.tr('reset_progress_confirm')),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(ctx.tr('cancel'))),
                      FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: kErrorColor),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(ctx.tr('delete'))),
                    ],
                  ),
                );
                if (ok == true) await s.resetAllProgress();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String key) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(context.tr(key).toUpperCase(),
            style: TextStyle(
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.8)),
      );
}
