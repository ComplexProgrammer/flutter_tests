class BookType {
  int id;
  String code;
  String description;

  BookType({
    required this.id,
    required this.code,
    required this.description,
  });
  factory BookType.fromJson(Map<String, dynamic> json) => BookType(
        id: json["id"],
        code: json["code"],
        description: json["description"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": code,
        "description": description,
      };
}
