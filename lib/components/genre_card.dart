import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';

class GenreCard extends StatelessWidget {
  final String genre;

  const GenreCard({super.key, required this.genre});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: kDefaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 4,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black26,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        genre,
        style: const TextStyle(
          color: kTextColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
