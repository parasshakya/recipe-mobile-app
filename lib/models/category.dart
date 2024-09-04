class Category {
  String id;
  String name;
  String image;

  Category({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["_id"],
      name: json["name"],
      image: json["image"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"_id": id, "name": name, "image": image};
  }
}
