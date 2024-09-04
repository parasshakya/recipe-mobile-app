class Blog {
  String id;
  String title;
  String description;
  String image;

  Blog(
      {required this.id,
      required this.title,
      required this.description,
      required this.image});

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        image: json["image"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "image": image,
      "description": description
    };
  }
}
