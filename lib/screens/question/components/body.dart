import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/topic.dart';
import 'package:flutter_tests/screens/question/components/backdrop.dart';
import 'package:flutter_tests/screens/question/components/question_carousel.dart';

class Body extends StatelessWidget {
  final Topic topic;

  const Body({super.key, required this.topic});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Backdrop(size: size, topic: topic),
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
          QuestionCarousel(
            topic: topic,
          ),
        ],
      ),
    );
  }
}
