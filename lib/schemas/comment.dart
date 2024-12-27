class Comment {
  final String userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  // Factory constructor to create a Comment object from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json["userId"],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Method to convert a Comment object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
