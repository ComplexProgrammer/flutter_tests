import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/screens/home/components/categories.dart';
import 'package:flutter_tests/screens/home/components/genre.dart';
import 'package:flutter_tests/screens/home/components/group_carousel.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Categorylist(),
          Genres(),
          const SizedBox(height: kDefaultPadding),
          GroupCarousel(),
        ],
      ),
    );
  }
}
