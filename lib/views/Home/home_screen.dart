import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/views/messenger_screen/messenger_screen.dart';
import 'package:instagram/views/my_story_screen/my_story_screen.dart';
import 'package:instagram/views/notifications_screen/notifications_screen.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';
import 'package:instagram/views/story_viewer_screen/story_viewer_screen.dart';
import 'package:instagram/widgets/post_widget.dart';
import 'package:instagram/widgets/story_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<PostModel> posts;

  @override
  void initState() {
    super.initState();
    posts = List.from(DummyData.posts);
  }

  void _handleLike(String postId) {
    setState(() {
      final index = posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        posts[index].isLiked = !posts[index].isLiked;
        posts[index].likes += posts[index].isLiked ? 1 : -1;
      }
    });
  }

  void _openStory(String userId) {
    final index = DummyData.stories.indexWhere((s) => s.userId == userId);
    if (index != -1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryViewerScreen(
            stories: DummyData.stories,
            initialIndex: index,
          ),
        ),
      ).then((_) {
        // Refresh when coming back from story viewer
        setState(() {});
      });
    }
  }

  void _openMyStory() {
    // Check if current user has story
    final userStoryIndex = DummyData.stories.indexWhere(
      (s) => s.userId == DummyData.currentUser.id,
    );

    if (userStoryIndex != -1) {
      // User has story, open viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryViewerScreen(
            stories: DummyData.stories,
            initialIndex: userStoryIndex,
          ),
        ),
      ).then((_) {
        setState(() {}); // Refresh after viewing
      });
    } else {
      // User has no story, open creation screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyStoryScreen()),
      ).then((_) {
        setState(() {}); // Refresh after creating story
      });
    }
  }

  void _addToStory() {
    // Always open creation screen when tapping plus icon
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyStoryScreen()),
    ).then((_) {
      setState(() {}); // Refresh after adding to story
    });
  }

  void _openProfile(String userId) {
    if (userId == DummyData.currentUser.id) return;
    final user = DummyData.getUserById(userId);
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfileScreen(user: user)),
      ).then((_) {
        setState(() {}); // refresh HomeScreen after returning from profile
      });
    }
  }

  Future<void> _refreshPosts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      posts.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if current user has story (dynamically)
    final currentUserHasStory = DummyData.stories.any(
      (s) => s.userId == DummyData.currentUser.id,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontFamily: 'Billabong',
            fontSize: 32,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.messenger_outline, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MessengerScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: const Text(
                    '15',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        displacement: 60,
        edgeOffset: 10,
        color: Colors.grey[700],
        backgroundColor: Colors.white,
        strokeWidth: 2.2,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Stories Section
            SliverToBoxAdapter(
              child: Container(
                height: 110,
                margin: const EdgeInsets.only(bottom: 2),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  itemCount:
                      1 + DummyData.users.where((u) => u.hasStory).length,
                  itemBuilder: (context, storyIndex) {
                    if (storyIndex == 0) {
                      // Current user's story avatar
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: StoryAvatar(
                          user: DummyData.currentUser,
                          hasStory: currentUserHasStory,
                          isCurrentUser: true,
                          onTap: _openMyStory,
                          onAddStory: _addToStory,
                        ),
                      );
                    }

                    // Other users' stories
                    final storiesUsers = DummyData.users
                        .where((u) => u.hasStory)
                        .toList();
                    final user = storiesUsers[storyIndex - 1];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: StoryAvatar(
                        user: user,
                        hasStory: true,
                        onTap: () => _openStory(user.id),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: Divider(height: 1, thickness: 0.5)),

            // Posts Section
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return PostWidget(
                  post: posts[index],
                  onLike: _handleLike,
                  onProfileTap: _openProfile,
                );
              }, childCount: posts.length),
            ),
          ],
        ),
      ),
    );
  }
}
