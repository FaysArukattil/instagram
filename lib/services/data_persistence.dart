import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

/// Service to persist data locally using SharedPreferences
class DataPersistence {
  static const String _postsKey = 'posts_data';
  static const String _commentsKey = 'comments_data';
  static const String _userPostCountKey = 'user_post_count';
  static const String _userFollowersKey = 'user_followers';
  static const String _userFollowingKey = 'user_following';

  // Save posts to local storage
  static Future<void> savePosts(List<PostModel> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = posts.map((post) => post.toJson()).toList();
    await prefs.setString(_postsKey, jsonEncode(postsJson));
  }

  // Load posts from local storage
  static Future<List<PostModel>?> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final postsString = prefs.getString(_postsKey);
    if (postsString == null) return null;

    final List<dynamic> postsJson = jsonDecode(postsString);
    return postsJson.map((json) => PostModel.fromJson(json)).toList();
  }

  // Save comments to local storage
  static Future<void> saveComments(
    Map<String, List<CommentModel>> comments,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = <String, dynamic>{};

    comments.forEach((postId, commentList) {
      commentsJson[postId] = commentList.map((c) => c.toJson()).toList();
    });

    await prefs.setString(_commentsKey, jsonEncode(commentsJson));
  }

  // Load comments from local storage
  static Future<Map<String, List<CommentModel>>?> loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    final commentsString = prefs.getString(_commentsKey);
    if (commentsString == null) return null;

    final Map<String, dynamic> commentsJson = jsonDecode(commentsString);
    final Map<String, List<CommentModel>> result = {};

    commentsJson.forEach((postId, commentListJson) {
      result[postId] = (commentListJson as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();
    });

    return result;
  }

  // Save user post count
  static Future<void> saveUserPostCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userPostCountKey, count);
  }

  // Load user post count
  static Future<int?> loadUserPostCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userPostCountKey);
  }

  // Save user stats
  static Future<void> saveUserStats(int followers, int following) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userFollowersKey, followers);
    await prefs.setInt(_userFollowingKey, following);
  }

  // Load user stats
  static Future<Map<String, int>?> loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final followers = prefs.getInt(_userFollowersKey);
    final following = prefs.getInt(_userFollowingKey);

    if (followers == null || following == null) return null;

    return {'followers': followers, 'following': following};
  }
}
