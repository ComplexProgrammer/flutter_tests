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
      height: size.height * 0.2,
      child: Stack(children: [
        Container(
          height: size.height * 0.4 - 25,
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.only(bottomLeft: Radius.circular(50)),
            boxShadow: const [kDefaultShadow],
            color: Color(0xFFF709090),
            image: topic.image != ''
                ? DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: NetworkImage('$baseUrl/media/${topic.image}'),
                  )
                : const DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(
                      'assets/images/img.png',
                    ),
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: size.width * 0.9,
            height: 50,
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
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.left,
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
