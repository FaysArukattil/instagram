class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String profileImageUrl;
  final List<String> images;
  final String timeAgo;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.images,
    required this.timeAgo,
  });
}
