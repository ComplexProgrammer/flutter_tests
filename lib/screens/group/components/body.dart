import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/screens/ads/banner.dart';
import 'package:flutter_tests/screens/group/components/categories.dart';
import 'package:flutter_tests/screens/group/components/genre.dart';
import 'package:flutter_tests/screens/group/components/group_carousel.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: kDefaultPadding),
            const GroupCarousel(),
            const SizedBox(height: kDefaultPadding),
            MyBannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
