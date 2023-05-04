import 'package:flutter/material.dart';

class Answer {
  int id;
  String name_en_us;
  String name_ru_ru;
  String name_uz_crl;
  String name_uz_uz;
  String image;
  int number;
  bool right;
  Answer({
    required this.id,
    required this.name_en_us,
    required this.name_ru_ru,
    required this.name_uz_crl,
    required this.name_uz_uz,
    required this.image,
    required this.number,
    required this.right,
  });
  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        id: json["id"],
        name_en_us: json["name_en_us"],
        name_ru_ru: json["name_ru_ru"],
        name_uz_crl: json["name_uz_crl"],
        name_uz_uz: json["name_uz_uz"],
        image: json["image"],
        number: json["number"],
        right: json["right"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name_en_us,
        "name_ru_ru": name_ru_ru,
        "name_uz_crl": name_uz_crl,
        "name_uz_uz": name_uz_uz,
        "image": image,
        "number": number,
        "right": right,
      };
}
