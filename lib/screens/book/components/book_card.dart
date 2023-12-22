import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/book.dart';
import 'package:flutter_tests/screens/topic/topic_screen.dart';

import '../../../models/group.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final Group group;

  const BookCard({super.key, required this.book, required this.group});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TopicScreen(
                    book: book,
                    group: group,
                  ))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: const [kDefaultShadow],
                  color: Color(0xFFF709080),
                  // image: DecorationImage(
                  //   fit: BoxFit.fill,
                  //   image: NetworkImage(
                  //       'https://complexprogrammer.uz/media/projects/tests/${book.type}.png'),
                  // ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
