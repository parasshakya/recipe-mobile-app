class Cuisine {
  String id;
  String name;
  String image;

  Cuisine({required this.id, required this.name, required this.image});

  factory Cuisine.fromJson(Map<String, dynamic> json) {
    return Cuisine(id: json['_id'], name: json["name"], image: json["image"]);
  }

  Map<String, dynamic> toJson() {
    return {"_id": id, "name": name, "image": image};
  }
}
