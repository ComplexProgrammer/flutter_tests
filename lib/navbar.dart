import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class NavBar extends StatelessWidget {
  // const NavBar({super.key});
  Future<PackageInfo> _getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text(
              "C0mplex",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text("complexprogrammer@mail.ru"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: Image.network(
                    '$baseUrl/static/img/man-icon.png',
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
            ),
            decoration: const BoxDecoration(
              gradient: kPremiumGradient,
            ),
          ),
          _buildDrawerItem(
            icon: Icons.auto_awesome_mosaic_rounded,
            title: 'Testlar',
            color: kPrimaryColor,
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.telegram,
            title: 'Telegram',
            color: const Color(0xFF0088cc),
            onTap: () => _launchURL(),
          ),
          const Divider(indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FutureBuilder<PackageInfo>(
              future: _getPackageInfo(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final data = snapshot.data!;
                return AboutListTile(
                  icon: const Icon(Icons.info_outline, color: kTextLightColor),
                  applicationIcon: const Icon(Icons.question_answer_rounded,
                      color: kPrimaryColor, size: 40),
                  applicationName: data.appName,
                  applicationVersion: data.version,
                  applicationLegalese: '© 2024 Complex Programmer',
                  child: const Text(
                    'Dastur haqida',
                    style: TextStyle(color: kTextLightColor),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: kTextColor, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}

_launchURL() async {
  String url = 'https://t.me/schooltestsuzb';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}
// _initPackageInfo() async {
//   final info = await PackageInfo.fromPlatform();
//   return info;
// }
