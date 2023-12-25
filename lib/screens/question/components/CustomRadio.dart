import 'package:flutter/material.dart';
import 'package:flutter_tests/models/answer.dart';
import 'package:flutter_tests/models/question.dart';

class CustomRadio extends StatefulWidget {
  @override
  createState() {
    return CustomRadioState();
  }
}

class CustomRadioState extends State<CustomRadio> {
  List<RadioModel> sampleData = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ListItem"),
      ),
      body: ListView.builder(
        itemCount: sampleData.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            //highlightColor: Colors.red,
            splashColor: Colors.blueAccent,
            onTap: () {
              setState(() {
                sampleData.forEach((element) => element.isSelected = false);
                sampleData[index].isSelected = true;
              });
            },
            child: RadioItem(sampleData[index]),
          );
        },
      ),
    );
  }
}

class RadioItem extends StatelessWidget {
  final RadioModel _item;
  const RadioItem(this._item, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
              color: _item.question.selectedAnswer != null
                  ? _item.question.selectedAnswer?.answerId == _item.answer.id
                      ? _item.question.selectedAnswer!.right
                          ? Colors.green
                          : Colors.red
                      : _item.answer.right
                          ? Colors.green
                          : Colors.transparent
                  : _item.isSelected
                      ? _item.answer.right
                          ? Colors.green
                          : Colors.red
                      : _item.correctAnswer
                          ? Colors.green
                          : Colors.transparent,
              border: Border.all(
                  width: 1.0,
                  color: _item.isSelected
                      ? _item.answer.right
                          ? Colors.greenAccent
                          : Colors.redAccent
                      : Colors.grey),
              borderRadius: const BorderRadius.all(
                Radius.circular(2.0),
              ),
            ),
            child: Center(
              child: Text(
                _item.buttonText,
                style: TextStyle(
                  color: _item.isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 2.0),
            child: Text(
              _item.answer.name_uz_uz,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _item.isSelected
                    ? _item.answer.right
                        ? Colors.greenAccent
                        : Colors.redAccent
                    : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 10.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RadioModel {
  Question question;
  Answer answer;
  bool isSelected;
  bool correctAnswer;
  final String buttonText;
  RadioModel(this.question, this.answer, this.isSelected, this.correctAnswer,
      this.buttonText);
}

void main() {
  runApp(MaterialApp(
    home: CustomRadio(),
  ));
}
