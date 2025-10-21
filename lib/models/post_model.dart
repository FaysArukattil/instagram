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

  // Convert PostModel to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'images': images,
      'caption': caption,
      'likes': likes,
      'comments': comments,
      'timeAgo': timeAgo,
      'location': location,
      'isLiked': isLiked,
      'isSponsored': isSponsored,
    };
  }

  // Create PostModel from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      images: List<String>.from(json['images']),
      caption: json['caption'] as String,
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      timeAgo: json['timeAgo'] as String,
      location: json['location'] as String?,
      isLiked: json['isLiked'] as bool? ?? false,
      isSponsored: json['isSponsored'] as bool? ?? false,
    );
  }

  // Create a copy with updated fields
  PostModel copyWith({
    String? id,
    String? userId,
    List<String>? images,
    String? caption,
    int? likes,
    int? comments,
    String? timeAgo,
    String? location,
    bool? isLiked,
    bool? isSponsored,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      images: images ?? this.images,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      timeAgo: timeAgo ?? this.timeAgo,
      location: location ?? this.location,
      isLiked: isLiked ?? this.isLiked,
      isSponsored: isSponsored ?? this.isSponsored,
    );
  }
}
