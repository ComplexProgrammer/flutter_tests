import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/group.dart';
import 'package:flutter_tests/screens/details/components/backdrop.dart';

class Body extends StatelessWidget {
  final Group group;

  const Body({super.key, required this.group});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Backdrop(size: size, group: group),
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${group.name_uz_uz}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Kerakli fanni tanlang va bilimingizni sinang",
                      style: TextStyle(color: kTextLightColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kSecondaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_stories_rounded,
                      color: Colors.white),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
