import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/question.dart';
import 'package:flutter_tests/screens/answer/components/backdrop.dart';
import 'package:flutter_tests/screens/answer/components/answer_carousel.dart';

class Body extends StatelessWidget {
  final Question question;

  const Body({super.key, required this.question});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Backdrop(size: size, question: question),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              children: [
                Text(
                  "Fanni tanlang",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          AnswerCarousel(
            question: question,
          ),
        ],
      ),
    );
  }
}
