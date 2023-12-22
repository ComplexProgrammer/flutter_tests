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

  Column buildGroupCard(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [kDefaultShadow],
              // color: Colors.black.withOpacity(0.0),
              color: Color(0xFFF909080),
              image: DecorationImage(
                fit: BoxFit.contain,
                image: NetworkImage(
                    "https://complexprogrammer.uz/media/tests/images/label_${group.number.toString()}.png"),
              ),
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
        //   child: Text(
        //     group.name_uz_uz,
        //     style: Theme.of(context).textTheme.headline5,
        //   ),
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Image.network(
        //       'https://complexprogrammer.uz/static/img/school_tests_bg.png',
        //       height: 20,
        //     ),
        //     const SizedBox(
        //       width: kDefaultPadding / 2,
        //     ),
        //     Text(
        //       "${group.name_uz_uz}",
        //       style: Theme.of(context).textTheme.bodyText2,
        //     ),
        //   ],
        // )
      ],
    );
  }
}
