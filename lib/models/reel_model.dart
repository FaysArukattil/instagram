import 'package:video_player/video_player.dart';

class ReelModel {
  final String id;
  final String userId;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  int likes;
  int comments;
  int shares;
  final String timeAgo;
  final String? location;
  bool isLiked;
  bool isMuted;
  bool isReposted;
  VideoPlayerController? controller;

  ReelModel({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    this.shares = 0,
    required this.timeAgo,
    this.location,
    this.isLiked = false,
    this.isMuted = true,
    this.isReposted = false,
  });

  // Convert ReelModel to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'timeAgo': timeAgo,
      'location': location,
      'isLiked': isLiked,
      'isReposted': isReposted,
    };
  }

  // Create ReelModel from JSON
  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      caption: json['caption'] as String,
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      shares: json['shares'] as int? ?? 0,
      timeAgo: json['timeAgo'] as String,
      location: json['location'] as String?,
      isLiked: json['isLiked'] as bool? ?? false,
      isReposted: json['isReposted'] as bool? ?? false,
    );
  }

  // Create a copy with updated fields
  ReelModel copyWith({
    String? id,
    String? userId,
    String? videoUrl,
    String? thumbnailUrl,
    String? caption,
    int? likes,
    int? comments,
    int? shares,
    String? timeAgo,
    String? location,
    bool? isLiked,
    bool? isMuted,
    bool? isReposted,
  }) {
    return ReelModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      timeAgo: timeAgo ?? this.timeAgo,
      location: location ?? this.location,
      isLiked: isLiked ?? this.isLiked,
      isMuted: isMuted ?? this.isMuted,
      isReposted: isReposted ?? this.isReposted,
    );
  }
}
