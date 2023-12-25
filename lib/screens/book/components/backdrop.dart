import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/group.dart';

import '../../group/group_screen.dart';

class Backdrop extends StatelessWidget {
  const Backdrop({
    super.key,
    required this.size,
    required this.group,
  });

  final Size size;
  final Group group;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.4,
      child: Stack(children: [
        Container(
          height: size.height * 0.4 - 50,
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.only(bottomLeft: Radius.circular(50)),
            boxShadow: const [kDefaultShadow],
            color: Color(0xFFF909080),
            image: DecorationImage(
              fit: BoxFit.fitWidth,
              image: NetworkImage(
                  "http://complexprogrammer.uz/media/${group.image}"),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: size.width * 0.9,
            height: 100,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  topLeft: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 5),
                    blurRadius: 50,
                    color: Color(0xFF12153D),
                  )
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Fanni tanlang",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
        // const SafeArea(child: BackButton())
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 5),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupScreen(),
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              size: 24.0,
              color: Colors.white,
            ),
          ),
        ),
      ]),
    );
  }
}
