import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/screens/adMob/banner.dart';
import 'package:flutter_tests/screens/group/components/categories.dart';
import 'package:flutter_tests/screens/group/components/genre.dart';
import 'package:flutter_tests/screens/group/components/group_carousel.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/img.png',
          ),
          // fit: BoxFit.scaleDown,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Categorylist(),
            // Genres(),
            const SizedBox(height: kDefaultPadding * 4),
            const GroupCarousel(),
            MyBannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
