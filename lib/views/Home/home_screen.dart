import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/views/messenger_screen/messenger_screen.dart';
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
    // find the index of the tapped user's story
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
      );
    }
  }

  void _openProfile(String userId) {
    if (userId == DummyData.currentUser.id) return;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontFamily: 'Billabong',
            fontSize: 20,
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
                  child: const Text(
                    '15',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          // story section
          if (index == 0) {
            return Column(
              children: [
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount:
                        1 +
                        DummyData.users
                            .where((u) => u.hasStory)
                            .length, // current user + others
                    itemBuilder: (context, storyIndex) {
                      if (storyIndex == 0) {
                        return StoryAvatar(
                          user: DummyData.currentUser,
                          hasStory: DummyData.currentUser.hasStory,
                          isCurrentUser: true,
                          onTap: () {
                            if (DummyData.currentUser.hasStory) {
                              _openStory(DummyData.currentUser.id);
                            }
                          },
                        );
                      }

                      final storiesUsers = DummyData.users
                          .where((u) => u.hasStory)
                          .toList();
                      final user = storiesUsers[storyIndex - 1];

                      return Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: StoryAvatar(
                          user: user,
                          hasStory: true,
                          onTap: () => _openStory(user.id),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
              ],
            );
          }

          // posts
          return PostWidget(
            post: posts[index - 1],
            onLike: _handleLike,
            onProfileTap: _openProfile,
          );
        },
      ),
    );
  }
}
