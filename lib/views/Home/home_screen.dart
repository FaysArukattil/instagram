import 'dart:math';

import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/views/commentscreen/commentscreen.dart';
import 'package:instagram/views/messenger_screen/messenger_screen.dart';
import 'package:instagram/views/my_story_screen/my_story_screen.dart';
import 'package:instagram/views/notifications_screen/notifications_screen.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';
import 'package:instagram/views/share_bottom_sheet/share_bottom_sheet.dart';
import 'package:instagram/views/story_viewer_screen/story_viewer_screen.dart';
import 'package:instagram/widgets/post_widget.dart';
import 'package:instagram/widgets/reel_widget.dart';
import 'package:instagram/widgets/story_avatar.dart';
import 'package:instagram/views/profile_tab_screen/profile_tab_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int, int, Duration)?
  onNavigateToReels; // (tabIndex, reelIndex, startPosition)

  const HomeScreen({super.key, this.onNavigateToReels});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with RouteAware, SingleTickerProviderStateMixin {
  void _triggerAutoRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshKey.currentState?.show();
      }
    });
  }

  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  late List<PostModel> posts;
  late List<ReelModel> reels;
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
      // if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _triggerAutoRefresh();
  }

  @override
  void didPush() {
    _triggerAutoRefresh();
  }

  void _loadData({bool shuffle = false}) {
    if (!mounted) return;
    setState(() {
      posts = List.from(DummyData.posts);
      reels = List.from(DummyData.reels);
      if (shuffle) {
        posts.shuffle();
        reels.shuffle();
      }
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
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      posts = List.from(DummyData.posts);
      reels = List.from(DummyData.reels);

      // 🔀 Shuffle like reels
      posts.shuffle(Random());
      reels.shuffle(Random());
    });
  }

  void _runSmoothAnimation({required bool open}) {
    _animationController.animateTo(
      open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildFeedItem(BuildContext context, int index) {
    // Calculate the pattern: every 3 items, insert a reel (pattern: post, post, reel)
    final itemPosition = index % 3;

    if (itemPosition == 2 && reels.isNotEmpty) {
      // Display reel
      final reelIndex = (index ~/ 3);
      if (reelIndex < reels.length) {
        return ReelWidget(
          reel: reels[reelIndex],
          onReelUpdated: () => _loadData(),
          onNavigateToReels: widget
              .onNavigateToReels, // Pass the callback with both parameters
        );
      }
    }

    // Display post
    final postIndex = index - (index ~/ 3);
    if (postIndex < posts.length) {
      return PostWidget(
        post: posts[postIndex],
        onLike: _handleLike,
        onProfileTap: _openProfile,
        onComment: _openComments,
        onShare: _openShare,
      );
    }

    return const SizedBox.shrink();
  }

  int _calculateTotalItems() {
    final postCount = posts.length;
    final reelCount = reels.length;
    // Total items = posts + reels (reels distributed every 3 items)
    return postCount + reelCount;
  }

  @override
  Widget build(BuildContext context) {
    DummyData.stories.any((s) => s.userId == DummyData.currentUser.id);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final delta = details.primaryDelta ?? 0;
        _animationController.value -= delta / MediaQuery.of(context).size.width;
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond.dx;

        if (velocity < -100) {
          // swipe left → open
          _animationController.animateTo(
            1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        } else if (velocity > 100) {
          // swipe right → close
          _animationController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        } else {
          // snap to nearest
          if (_animationController.value >= 0.5) {
            _animationController.animateTo(
              1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          } else {
            _animationController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final screenWidth = MediaQuery.of(context).size.width;
          final offset = -screenWidth * _animationController.value;

          return Stack(
            children: [
              Transform.translate(
                offset: Offset(offset, 0),
                child: _buildHomeContent(
                  DummyData.stories.any(
                    (s) => s.userId == DummyData.currentUser.id,
                  ),
                  screenWidth,
                ),
              ),
              Transform.translate(
                offset: Offset(screenWidth + offset, 0),
                child: MessengerScreen(
                  onSwipeBack: () => _animationController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  ),
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
        key: _refreshKey,
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
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildFeedItem(context, index),
                childCount: _calculateTotalItems(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
