import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/question.dart';
import 'package:flutter_tests/screens/answer/answer_screen.dart';

class QuestionCard extends StatelessWidget {
  final Question question;

  const QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AnswerScreen(
                    question: question,
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
                  image: const DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        'http://complexprogrammer.uz/static/img/school_tests_bg.png'),
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
