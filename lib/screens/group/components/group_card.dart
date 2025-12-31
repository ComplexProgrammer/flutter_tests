import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/group.dart';
import 'package:flutter_tests/screens/book/book_screen.dart';
import 'package:flutter_tests/screens/details/details_screen.dart';

class GroupCard extends StatelessWidget {
  final Group group;

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: OpenContainer(
        closedBuilder: (context, action) => buildGroupCard(context),
        openBuilder: (context, action) => BookScreen(group: group),
      ),
      // child: InkWell(
      //   onTap: () => Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => BookScreen(
      //                 group: group,
      //               ))),
      //   child: buildGroupCard(context),
      // ),
    );
  }

  Widget buildGroupCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [kDefaultShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: (group.image != null && group.image!.isNotEmpty)
                  ? Image.network(
                      "$baseUrl/media/${group.image}",
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/img.png',
                      fit: BoxFit.cover,
                    ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Text(
                  group.name_uz_uz ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
