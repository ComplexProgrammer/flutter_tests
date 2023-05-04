import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/book.dart';
import 'package:flutter_tests/screens/topic/components/backdrop.dart';
import 'package:flutter_tests/screens/topic/components/topic_carousel.dart';

class Body extends StatelessWidget {
  final Book book;

  const Body({super.key, required this.book});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Backdrop(size: size, book: book),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              children: [
                Text(
                  "Mavzuni tanlang",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          TopicCarousel(
            book: book,
          ),
        ],
      ),
    );
  }
}
