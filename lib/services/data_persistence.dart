import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../models/reel_model.dart';
import '../models/comment_model.dart';

/// Service to persist all user-created content locally
class DataPersistence {
  static const String _postsKey = 'posts_data';
  static const String _storiesKey = 'stories_data';
  static const String _reelsKey = 'reels_data';
  static const String _repostsKey = 'reposts_data';
  static const String _savedItemsKey = 'saved_items_data';
  static const String _commentsKey = 'comments_data';
  static const String _userPostCountKey = 'user_post_count';

  // ===================== POSTS =====================

  static Future<void> savePosts(List<PostModel> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = posts.map((post) => post.toJson()).toList();
    await prefs.setString(_postsKey, jsonEncode(postsJson));
  }

  static Future<List<PostModel>?> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final postsString = prefs.getString(_postsKey);
    if (postsString == null) return null;

    final List<dynamic> postsJson = jsonDecode(postsString);
    return postsJson.map((json) => PostModel.fromJson(json)).toList();
  }

  // ===================== STORIES =====================

  static Future<void> saveStories(List<StoryModel> stories) async {
    final prefs = await SharedPreferences.getInstance();
    final storiesJson = stories.map((story) => story.toJson()).toList();
    await prefs.setString(_storiesKey, jsonEncode(storiesJson));
  }

  static Future<List<StoryModel>?> loadStories() async {
    final prefs = await SharedPreferences.getInstance();
    final storiesString = prefs.getString(_storiesKey);
    if (storiesString == null) return null;

    final List<dynamic> storiesJson = jsonDecode(storiesString);
    return storiesJson.map((json) => StoryModel.fromJson(json)).toList();
  }

  // ===================== REELS =====================

  static Future<void> saveReels(List<ReelModel> reels) async {
    final prefs = await SharedPreferences.getInstance();
    final reelsJson = reels.map((reel) => reel.toJson()).toList();
    await prefs.setString(_reelsKey, jsonEncode(reelsJson));
  }

  static Future<List<ReelModel>?> loadReels() async {
    final prefs = await SharedPreferences.getInstance();
    final reelsString = prefs.getString(_reelsKey);
    if (reelsString == null) return null;

    final List<dynamic> reelsJson = jsonDecode(reelsString);
    return reelsJson.map((json) => ReelModel.fromJson(json)).toList();
  }

  // ===================== REPOSTS =====================

  static Future<void> saveReposts(Map<String, List<String>> reposts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_repostsKey, jsonEncode(reposts));
  }

  static Future<Map<String, List<String>>?> loadReposts() async {
    final prefs = await SharedPreferences.getInstance();
    final repostsString = prefs.getString(_repostsKey);
    if (repostsString == null) return null;

    final Map<String, dynamic> decoded = jsonDecode(repostsString);
    return decoded.map((key, value) => MapEntry(key, List<String>.from(value)));
  }

  // ===================== SAVED ITEMS =====================

  static Future<void> saveSavedItems(List<String> savedItemIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedItemsKey, savedItemIds);
  }

  static Future<List<String>?> loadSavedItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedItemsKey);
  }

  // ===================== COMMENTS =====================

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

  // ===================== USER STATS =====================

  static Future<void> saveUserPostCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userPostCountKey, count);
  }

  static Future<int?> loadUserPostCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userPostCountKey);
  }

  // ===================== CLEAR ALL DATA =====================

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
