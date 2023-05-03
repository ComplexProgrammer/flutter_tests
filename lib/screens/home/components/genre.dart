import 'package:flutter/material.dart';
import 'package:flutter_tests/components/genre_card.dart';
import 'package:flutter_tests/constants.dart';

class Genres extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> genres = [
      "Matematika",
      "Fizika",
      "Kimyo",
      "Adabiyot",
      "Tarix"
    ];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) => GenreCard(
          genre: genres[index],
        ),
      ),
    );
  }
}
