import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/screens/group/components/body.dart';

class GroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Body(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      leading: const IconButton(
        padding: EdgeInsets.only(left: kDefaultPadding),
        icon: Icon(Icons.menu),
        onPressed: null,
      ),
      actions: const <Widget>[
        IconButton(
          onPressed: null,
          icon: Icon(
            Icons.telegram,
          ),
        )
      ],
    );
  }
}
