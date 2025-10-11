class CommentModel {
  final String id;
  final String userId;
  final String text;
  final String timeAgo;
  int likes;
  bool isLiked;
  final bool isAuthor;

  CommentModel({
    required this.id,
    required this.userId,
    required this.text,
    required this.timeAgo,
    this.likes = 0,
    this.isLiked = false,
    this.isAuthor = false,
  });

  // Convert CommentModel to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'timeAgo': timeAgo,
      'likes': likes,
      'isLiked': isLiked,
      'isAuthor': isAuthor,
    };
  }

  // Create CommentModel from JSON
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      userId: json['userId'],
      text: json['text'],
      timeAgo: json['timeAgo'],
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isAuthor: json['isAuthor'] ?? false,
    );
  }
}
