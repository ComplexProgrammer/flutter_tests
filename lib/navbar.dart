import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NavBar extends StatelessWidget {
  // const NavBar({super.key});

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
                  'https://complexprogrammer.uz/static/img/man-icon.png',
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              // image: DecorationImage(
              //   image: NetworkImage(
              //     'https://complexprogrammer.uz/static/img/C0mplex.png',
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
              'Test ishlash',
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
          const AboutListTile(
            // <-- SEE HERE
            icon: Icon(
              Icons.info,
              color: Colors.orangeAccent,
            ),
            applicationIcon: Icon(
              Icons.local_play,
            ),
            applicationName: 'School tests',
            applicationVersion: '1.0.25',
            applicationLegalese: '© 2023 Complex Programmer',
            aboutBoxChildren: [
              ///Content goes here...
            ],
            child: Text(
              'About app',
              style: TextStyle(
                color: Colors.orangeAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

_launchURL() async {
  String url = 'https://t.me/schooltestsuzb';
  print(url);
  // if (await canLaunchUrl(Uri.parse(url))) {
  //   await launchUrl(Uri.parse(url));
  // }
  // else {
  //   throw 'Could not launch $url';
  // }
}
