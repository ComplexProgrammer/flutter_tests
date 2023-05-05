import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/topic.dart';

class Backdrop extends StatelessWidget {
  const Backdrop({
    super.key,
    required this.size,
    required this.topic,
  });

  final Size size;
  final Topic topic;

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
            image: DecorationImage(
              fit: BoxFit.fitHeight,
              image: NetworkImage(
                  'https://complexprogrammer.uz/media/projects/tests/bino_${topic.number.toString()}.png'),
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
                  topic.name_uz_uz,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
        ),
        const SafeArea(child: BackButton())
      ]),
    );
  }
}
