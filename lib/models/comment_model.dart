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
      id: json['id'] as String,
      userId: json['userId'] as String,
      text: json['text'] as String,
      timeAgo: json['timeAgo'] as String,
      likes: json['likes'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isAuthor: json['isAuthor'] as bool? ?? false,
    );
  }

  // Create a copy with updated fields
  CommentModel copyWith({
    String? id,
    String? userId,
    String? text,
    String? timeAgo,
    int? likes,
    bool? isLiked,
    bool? isAuthor,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      timeAgo: timeAgo ?? this.timeAgo,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      isAuthor: isAuthor ?? this.isAuthor,
    );
  }
}
