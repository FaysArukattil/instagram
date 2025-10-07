import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';
import 'package:instagram/widgets/post_widget.dart';

class PostScreen extends StatefulWidget {
  final String userId;
  final int initialIndex;

  const PostScreen({super.key, required this.userId, this.initialIndex = 0});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late List<PostModel> userPosts;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Get all posts from this user
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
    final user = DummyData.getUserById(userId);
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfileScreen(user: user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userPosts.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Posts',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'No posts available',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

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
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
