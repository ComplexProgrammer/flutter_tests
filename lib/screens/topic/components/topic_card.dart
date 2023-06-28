import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/book.dart';
import 'package:flutter_tests/models/topic.dart';
import 'package:flutter_tests/screens/question/question_screen.dart';

import '../../../models/group.dart';

class TopicCard extends StatelessWidget {
  final Topic topic;
  final Book book;
  final Group group;
  const TopicCard(
      {super.key,
      required this.topic,
      required this.book,
      required this.group});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuestionScreen(
                    topic: topic,
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
                  color: Color(0xFFF709090),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        'https://complexprogrammer.uz/media/projects/tests/bino_${topic.number.toString()}.png'),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              child: Text(
                topic.name_uz_uz,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
