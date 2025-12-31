import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/book.dart';
import 'package:flutter_tests/screens/book/components/book_carousel.dart';
import 'package:flutter_tests/screens/topic/topic_screen.dart';

import '../../../models/group.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final Group group;
  const BookCard({super.key, required this.book, required this.group});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TopicScreen(
            book: book,
            group: group,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [kDefaultShadow],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: book.image.isNotEmpty
                    ? Image.network(
                        '$baseUrl/media/${book.image}',
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/img.png',
                        fit: BoxFit.cover,
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Text(
                  book.name_uz_uz,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
