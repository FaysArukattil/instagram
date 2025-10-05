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
}
