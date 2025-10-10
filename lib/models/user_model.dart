class UserModel {
  final String id;
  final String username;
  final String name;
  final String profileImage;
  final bool hasStory;
  int followers;
  int following;
  int posts;
  final String bio;
  final bool isVerified;
  bool isFollowing;
  final bool isOnline;
  final String? lastSeen;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.profileImage,
    this.hasStory = false,
    this.followers = 0,
    this.following = 0,
    this.posts = 0,
    this.bio = '',
    this.isVerified = false,
    this.isFollowing = false,
    this.isOnline = false,
    this.lastSeen,
  });
}
