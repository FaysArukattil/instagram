import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/widgets/post_widget.dart';

class PostScreen extends StatefulWidget {
  final String userId;
  final int initialIndex;

  const PostScreen({
    super.key,
    required this.userId,
    required this.initialIndex,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late PageController _pageController;
  late List<PostModel> userPosts;

  @override
  void initState() {
    super.initState();
    // Get all posts for this user
    userPosts = DummyData.posts
        .where((post) => post.userId == widget.userId)
        .toList();

    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleLike(String postId) {
    setState(() {
      final index = userPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        userPosts[index].isLiked = !userPosts[index].isLiked;
        userPosts[index].likes += userPosts[index].isLiked ? 1 : -1;
      }
    });
  }

  void _openProfile(String userId) {
    // Already on profile screen, so do nothing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          DummyData.getUserById(widget.userId)?.username ?? 'Posts',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: userPosts.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            child: PostWidget(
              post: userPosts[index],
              onLike: _handleLike,
              onProfileTap: _openProfile,
            ),
          );
        },
      ),
    );
  }
}
