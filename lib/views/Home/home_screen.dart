import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/views/commentscreen/commentscreen.dart';
import 'package:instagram/views/messenger_screen/messenger_screen.dart';
import 'package:instagram/views/my_story_screen/my_story_screen.dart';
import 'package:instagram/views/notifications_screen/notifications_screen.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';
import 'package:instagram/views/share_bottom_sheet/share_bottom_sheet.dart';
import 'package:instagram/views/story_viewer_screen/story_viewer_screen.dart';
import 'package:instagram/widgets/post_widget.dart';
import 'package:instagram/widgets/story_avatar.dart';
import 'package:instagram/views/profile_tab_screen/profile_tab_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with RouteAware, SingleTickerProviderStateMixin {
  late List<PostModel> posts;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _loadData();
  @override
  void didPush() => _loadData();

  void _loadData({bool shuffle = false}) {
    if (!mounted) return;
    setState(() {
      posts = List.from(DummyData.posts);
      if (shuffle) posts.shuffle();
    });
  }

  void _handleLike(String postId) {
    setState(() {
      final index = posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        posts[index].isLiked = !posts[index].isLiked;
        posts[index].likes += posts[index].isLiked ? 1 : -1;
        final mainIndex = DummyData.posts.indexWhere((p) => p.id == postId);
        if (mainIndex != -1) {
          DummyData.posts[mainIndex].isLiked = posts[index].isLiked;
          DummyData.posts[mainIndex].likes = posts[index].likes;
        }
      }
    });
  }

  void _openComments(PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsScreen(post: post),
    ).then((_) {
      setState(() {
        final index = posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          posts[index].comments = DummyData.getCommentsForPost(post.id).length;
          final mainIndex = DummyData.posts.indexWhere((p) => p.id == post.id);
          if (mainIndex != -1) {
            DummyData.posts[mainIndex].comments = posts[index].comments;
          }
        }
      });
    });
  }

  void _openShare(PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(post: post),
    );
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
      ).then((_) => _loadData());
    }
  }

  void _openMyStory() {
    final userStoryIndex = DummyData.stories.indexWhere(
      (s) => s.userId == DummyData.currentUser.id,
    );
    if (userStoryIndex != -1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryViewerScreen(
            stories: DummyData.stories,
            initialIndex: userStoryIndex,
          ),
        ),
      ).then((_) => _loadData());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyStoryScreen()),
      ).then((_) => _loadData());
    }
  }

  void _addToStory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyStoryScreen()),
    ).then((_) => _loadData());
  }

  void _openProfile(String userId) {
    if (userId == DummyData.currentUser.id) return;
    final user = DummyData.getUserById(userId);
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfileScreen(user: user)),
      ).then((_) => _loadData());
    }
  }

  Future<void> _refreshPosts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _loadData(shuffle: true);
  }

  void _runSmoothAnimation({required bool open}) {
    _animationController.animateTo(
      open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentUserHasStory = DummyData.stories.any(
      (s) => s.userId == DummyData.currentUser.id,
    );

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final delta = details.primaryDelta ?? 0;
        final newValue =
            _animationController.value + (delta / -(screenWidth * 0.8));

        _animationController.value = newValue.clamp(0.0, 1.0);
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0.0;

        if (velocity.abs() > 100) {
          // Swipe requires less flick speed now
          final velocity = details.primaryVelocity ?? 0.0;
          final open = _animationController.value > 0.5 || velocity < -200;

          _animationController.animateTo(
            open ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        } else {
          if (_animationController.value > 0.15) {
            // lower threshold, opens easier
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        }
      },

      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final offset = -screenWidth * _animationController.value;
          final scale = 1 - (0.05 * _animationController.value);
          final borderRadius = 20.0 * _animationController.value;

          return Stack(
            children: [
              Transform.translate(
                offset: Offset(offset, 0),
                child: Transform.scale(
                  scale: scale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: _buildHomeContent(currentUserHasStory, screenWidth),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(screenWidth + offset, 0),
                child: MessengerScreen(
                  onSwipeBack: () => _runSmoothAnimation(open: false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHomeContent(bool currentUserHasStory, double screenWidth) {
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
                  _runSmoothAnimation(open: true);
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
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return PostWidget(
                  post: posts[index],
                  onLike: _handleLike,
                  onProfileTap: _openProfile,
                  onComment: _openComments,
                  onShare: _openShare,
                );
              }, childCount: posts.length),
            ),
          ],
        ),
      ),
    );
  }
}
