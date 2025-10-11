import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/views/follower_screen/follower_screen.dart';
import 'package:instagram/views/reels_screen/reels_screen.dart';
import 'package:instagram/views/post_screen/post_screen.dart';
import 'package:instagram/views/chatscreen/chatscreen.dart';
import 'package:instagram/widgets/universal_image.dart'; // ✅ Added import

class UserProfileScreen extends StatefulWidget {
  final UserModel user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late bool isFollowing;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    isFollowing = widget.user.isFollowing;
    _tabController = TabController(length: 3, vsync: this);
  }

  void _toggleFollow() {
    setState(() {
      isFollowing = !isFollowing;
      widget.user.isFollowing = isFollowing;
      if (isFollowing) {
        widget.user.followers += 1;
      } else {
        widget.user.followers -= 1;
      }
    });
  }

  void _openFollowers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowersScreen(userId: widget.user.id),
      ),
    ).then((_) => setState(() {}));
  }

  void _openFollowing() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowersScreen(userId: widget.user.id),
      ),
    ).then((_) => setState(() {}));
  }

  void _openMessage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
    );
  }

  void _openPostScreen(List<PostModel> posts, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PostScreen(userId: widget.user.id, initialIndex: initialIndex),
      ),
    );
  }

  void _openReelsScreen(List<ReelModel> reels, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReelsScreen(initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPosts = DummyData.posts
        .where((post) => post.userId == widget.user.id)
        .toList();
    final userReels = DummyData.reels
        .where((reel) => reel.userId == widget.user.id)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.user.username,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    /// ✅ Changed to UniversalImage (CircleAvatar replaced)
                    ClipOval(
                      child: UniversalImage(
                        imagePath: widget.user.profileImage,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            widget.user.posts.toString(),
                            'Posts',
                            null,
                          ),
                          _buildStatColumn(
                            widget.user.followers.toString(),
                            'Followers',
                            _openFollowers,
                          ),
                          _buildStatColumn(
                            widget.user.following.toString(),
                            'Following',
                            _openFollowing,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.user.bio,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing
                              ? Colors.grey.shade200
                              : Colors.blue,
                          foregroundColor: isFollowing
                              ? Colors.black
                              : Colors.white,
                          elevation: 0,
                        ),
                        child: Text(isFollowing ? 'Following' : 'Follow'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _openMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                          elevation: 0,
                        ),
                        child: const Text('Message'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.grid_on)),
              Tab(icon: Icon(Icons.video_library_outlined)),
              Tab(icon: Icon(Icons.person_pin_outlined)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsGrid(userPosts),
                _buildReelsGrid(userReels),
                const Center(child: Text('No tagged posts yet')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(List<PostModel> posts) {
    if (posts.isEmpty) {
      return const Center(child: Text('No posts yet'));
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () => _openPostScreen(posts, index),

          /// ✅ Replaced Image.network → UniversalImage
          child: UniversalImage(imagePath: post.images[0], fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildReelsGrid(List<ReelModel> reels) {
    if (reels.isEmpty) {
      return const Center(child: Text('No reels yet'));
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: reels.length,
      itemBuilder: (context, index) {
        final reel = reels[index];

        return GestureDetector(
          onTap: () {
            final fullReelIndex = DummyData.reels.indexWhere(
              (r) => r.id == reel.id,
            );
            _openReelsScreen(reels, fullReelIndex >= 0 ? fullReelIndex : 0);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// ✅ Replaced Image.network → UniversalImage
              UniversalImage(imagePath: reel.thumbnailUrl, fit: BoxFit.cover),
              const Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 36,
              ),
            ],
          ),
        );
      },
    );
  }
}
