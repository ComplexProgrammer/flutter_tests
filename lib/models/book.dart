class Book {
  int id;
  String name_en_us;
  String name_ru_ru;
  String name_uz_crl;
  String name_uz_uz;
  String book_type;
  int group_id;
  Book({
    required this.id,
    required this.name_en_us,
    required this.name_ru_ru,
    required this.name_uz_crl,
    required this.name_uz_uz,
    required this.book_type,
    required this.group_id,
  });
  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json["id"],
        name_en_us: json["name_en_us"],
        name_ru_ru: json["name_ru_ru"],
        name_uz_crl: json["name_uz_crl"],
        name_uz_uz: json["name_uz_uz"],
        book_type: json["book_type"],
        group_id: json["group_id"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name_en_us,
        "name_ru_ru": name_ru_ru,
        "name_uz_crl": name_uz_crl,
        "name_uz_uz": name_uz_uz,
        "book_type": book_type,
        "group_id": group_id,
      };
}
