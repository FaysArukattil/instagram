class UserModel {
  String id;
  String username;
  String name;
  String profileImage; // can be network URL or local file path
  bool hasStory;
  int followers;
  int following;
  int friends; // NEW: Friends count
  int posts;
  String bio;
  bool isVerified;
  bool isFollowing;
  bool isOnline;
  String? lastSeen;
  String gender;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.profileImage,
    this.hasStory = false,
    this.followers = 0,
    this.following = 0,
    this.friends = 0, // NEW: Default value
    this.posts = 0,
    this.bio = '',
    this.isVerified = false,
    this.isFollowing = false,
    this.isOnline = false,
    this.lastSeen,
    this.gender = 'Not specified',
  });
}
