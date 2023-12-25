import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/topic.dart';

class Time extends StatelessWidget {
  const Time({
    super.key,
    required this.minutes,
    required this.seconds,
  });

  final minutes;
  final seconds;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Duration>(
        duration: Duration(
          minutes: minutes,
          seconds: seconds,
        ),
        tween: Tween(
            begin: Duration(
              minutes: minutes,
              seconds: seconds,
            ),
            end: Duration.zero),
        onEnd: () {
          print('Timer ended');
        },
        builder: (BuildContext context, Duration value, Widget? child) {
          final minutes = value.inMinutes;
          final seconds = value.inSeconds % 60;
          var sec = seconds.toString().length == 1 ? '0$seconds' : '$seconds';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              '$minutes:$sec',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
          );
        });
  }
}
