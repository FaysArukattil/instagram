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
      id: json['id'],
      userId: json['userId'],
      images: List<String>.from(json['images']),
      caption: json['caption'],
      likes: json['likes'],
      comments: json['comments'],
      timeAgo: json['timeAgo'],
      location: json['location'],
      isLiked: json['isLiked'] ?? false,
      isSponsored: json['isSponsored'] ?? false,
    );
  }
}
