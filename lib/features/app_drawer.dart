import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/services.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/features/settings_screen.dart';
import 'package:flutter_tests/features/stats_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 24, 20, 20),
            decoration: const BoxDecoration(gradient: kVibrantGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.quiz_rounded,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 14),
                Text(context.tr('app_name'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  '🔥 ${s.currentStreak} ${context.tr('streak_days')}   '
                  '✅ ${s.totalAnswered}   🎯 ${s.accuracy}%',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _item(context, Icons.home_rounded, 'home',
              () => Navigator.pop(context)),
          _item(context, Icons.insights_rounded, 'stats',
              () => _push(context, const StatsScreen())),
          _item(context, Icons.settings_rounded, 'settings',
              () => _push(context, const SettingsScreen())),
          const Divider(indent: 16, endIndent: 16),
          _item(context, Icons.telegram, 'telegram',
              () => openLink(context, kTelegramUrl),
              color: const Color(0xFF0088CC)),
          _item(context, Icons.share_rounded, 'share_app',
              () => Share.share('${context.tr('share_app_text')}\n$kStoreUrl')),
          _item(context, Icons.star_rate_rounded, 'rate_app',
              () => openLink(context, kStoreUrl),
              color: kFillStarColor),
          _item(context, Icons.mail_outline_rounded, 'feedback',
              () => sendEmail(context, context.tr('feedback_subject'), '')),
          _item(context, Icons.privacy_tip_outlined, 'privacy',
              () => openLink(context, kPrivacyUrl)),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) => _item(
              context,
              Icons.info_outline_rounded,
              'about',
              () => showAboutDialog(
                context: context,
                applicationName: context.tr('app_name'),
                applicationVersion: snap.data?.version,
                applicationIcon: const Icon(Icons.quiz_rounded, size: 40),
                applicationLegalese: '© ${DateTime.now().year} Complex Programmer',
              ),
              subtitle: snap.hasData
                  ? '${context.tr('version')} ${snap.data!.version}'
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String key, VoidCallback onTap,
          {Color? color, String? subtitle}) =>
      ListTile(
        leading: Icon(icon, color: color ?? context.colors.primary),
        title: Text(context.tr(key),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle == null ? null : Text(subtitle),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      );
}
