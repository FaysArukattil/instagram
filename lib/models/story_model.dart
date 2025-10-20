class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String profileImageUrl;
  final List<String> images;
  final String timeAgo;
  final Set<String> viewedBy; // Track which users have seen this story

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.images,
    required this.timeAgo,
    Set<String>? viewedBy,
  }) : viewedBy = viewedBy ?? {};

  // Method to mark as viewed by current user
  void markAsViewed(String currentUserId) {
    viewedBy.add(currentUserId);
  }

  // Check if viewed by current user
  bool isViewedBy(String userId) {
    return viewedBy.contains(userId);
  }

  // Copy constructor for immutability
  StoryModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? profileImageUrl,
    List<String>? images,
    String? timeAgo,
    Set<String>? viewedBy,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      images: images ?? this.images,
      timeAgo: timeAgo ?? this.timeAgo,
      viewedBy: viewedBy ?? this.viewedBy,
    );
  }
}
