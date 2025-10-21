class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String profileImageUrl;
  final List<String> images;
  final String timeAgo;
  final Set<String> viewedBy;
  final int createdAt;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.images,
    required this.timeAgo,
    Set<String>? viewedBy,
    int? createdAt,
  }) : viewedBy = viewedBy ?? {},
       createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  // Method to mark as viewed by current user
  void markAsViewed(String currentUserId) {
    viewedBy.add(currentUserId);
  }

  // Check if viewed by current user
  bool isViewedBy(String userId) {
    return viewedBy.contains(userId);
  }

  // Convert StoryModel to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'images': images,
      'timeAgo': timeAgo,
      'viewedBy': viewedBy.toList(),
      'createdAt': createdAt,
    };
  }

  // Create StoryModel from JSON
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
      images: List<String>.from(json['images']),
      timeAgo: json['timeAgo'] as String,
      viewedBy: Set<String>.from(json['viewedBy'] ?? []),
      createdAt: json['createdAt'] as int?,
    );
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
    int? createdAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      images: images ?? this.images,
      timeAgo: timeAgo ?? this.timeAgo,
      viewedBy: viewedBy ?? this.viewedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
