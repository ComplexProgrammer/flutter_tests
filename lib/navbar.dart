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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("C0mplex"),
            accountEmail: const Text("complexprogrammer@mail.ru"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.lightBlueAccent,
              child: ClipOval(
                child: Image.network(
                  '$baseUrl/static/img/man-icon.png',
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              // image: DecorationImage(
              //   image: NetworkImage(
              //     '$baseUrl/static/img/C0mplex.png',
              //   ),
              //   fit: BoxFit.fill,
              // ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.textsms_sharp,
              color: Colors.greenAccent,
            ),
            title: const Text(
              'Testlar',
              style: TextStyle(
                color: Colors.greenAccent,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.telegram,
              color: Colors.blueAccent,
            ),
            title: const Text(
              'Telegram',
              style: TextStyle(
                color: Colors.blueAccent,
              ),
            ),
            onTap: () => _launchURL(),
          ),
          Center(
            child: FutureBuilder<PackageInfo>(
              future: _getPackageInfo(),
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                if (snapshot.hasError) {
                  return const Text('ERROR');
                } else if (!snapshot.hasData) {
                  return const Text('Loading...');
                }

                final data = snapshot.data!;
                return AboutListTile(
                  icon: const Icon(
                    Icons.info,
                    color: Colors.orangeAccent,
                  ),
                  applicationIcon: const Icon(
                    Icons.question_answer_outlined,
                  ),
                  applicationName: data.appName,
                  applicationVersion: data.version,
                  applicationLegalese: '© 2024 Complex Programmer',
                  aboutBoxChildren: [
                    ///Content goes here...
                  ],
                  child: const Text(
                    'About app',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
