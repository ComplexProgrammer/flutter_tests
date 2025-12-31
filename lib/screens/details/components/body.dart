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
      children: [
        Backdrop(size: size, group: group),
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "${group.name_uz_uz} fanni tanlang",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(
                      height: kDefaultPadding / 2,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 64,
                width: 64,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    alignment: Alignment.center,
                    backgroundColor: kSecondaryColor,
                    minimumSize: const Size(double.infinity, 200),
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const SizedBox(
                      child: Icon(
                    Icons.add,
                    size: 28,
                    color: Colors.white,
                  )),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
