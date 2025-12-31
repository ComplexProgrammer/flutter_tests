import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
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
    bool isSelected = _item.isSelected;
    bool isAnswered = _item.question.selectedAnswer != null;
    bool isCorrect = _item.answer.right;
    bool wasSelected = isAnswered &&
        _item.question.selectedAnswer?.answerId == _item.answer.id;

    Color getBgColor() {
      if (!isAnswered && !isSelected) return Colors.white;
      if (isAnswered) {
        if (isCorrect) return Colors.green.withOpacity(0.1);
        if (wasSelected && !isCorrect) return Colors.red.withOpacity(0.1);
      } else if (isSelected) {
        return kPrimaryColor.withOpacity(0.1);
      }
      return Colors.white;
    }

    Color getBorderColor() {
      if (!isAnswered && !isSelected) return Colors.grey.shade300;
      if (isAnswered) {
        if (isCorrect) return Colors.green;
        if (wasSelected && !isCorrect) return Colors.red;
      } else if (isSelected) {
        return kPrimaryColor;
      }
      return Colors.grey.shade300;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: getBgColor(),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: getBorderColor(),
          width: (isSelected || (isAnswered && (isCorrect || wasSelected)))
              ? 2.0
              : 1.0,
        ),
      ),
      child: ListTile(
        leading: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: getBorderColor().withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: getBorderColor(), width: 1),
          ),
          child: Center(
            child: Text(
              _item.buttonText,
              style: TextStyle(
                color: getBorderColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          _item.answer.name_uz_uz,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isAnswered && (isCorrect || wasSelected)
                ? getBorderColor()
                : kTextColor,
          ),
        ),
        trailing: isAnswered
            ? (isCorrect
                ? const Icon(Icons.check_circle, color: Colors.green)
                : (wasSelected
                    ? const Icon(Icons.cancel, color: Colors.red)
                    : null))
            : null,
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
