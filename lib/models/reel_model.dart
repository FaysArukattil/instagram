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
}
