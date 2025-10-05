class PostModel {
  final String id;
  final String userId;
  final List<String> images;
  final String caption;
  int likes;
  int comments;
  final String timeAgo;
  final String? location;
  bool isLiked;
  final bool isSponsored;

  PostModel({
    required this.id,
    required this.userId,
    required this.images,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    this.location,
    this.isLiked = false,
    this.isSponsored = false,
  });
}
