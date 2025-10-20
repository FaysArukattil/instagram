import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/core/constants/app_images.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/views/commentscreen/commentscreen.dart';
import 'package:instagram/views/add_post_screen/add_post_screen.dart';
import 'package:instagram/views/my_story_screen/my_story_screen.dart';
import 'package:instagram/views/notifications_screen/notifications_screen.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';
import 'package:instagram/views/profile_tab_screen/profile_tab_screen.dart';
import 'package:instagram/views/share_bottom_sheet/share_bottom_sheet.dart';
import 'package:instagram/views/story_viewer_screen/story_viewer_screen.dart';
import 'package:instagram/widgets/post_widget.dart';
import 'package:instagram/widgets/reel_widget.dart';
import 'package:instagram/widgets/story_avatar.dart';
import 'package:instagram/models/story_model.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int, int, Duration)? onNavigateToReels;

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
  List<dynamic> feedItems = [];

  @override
  void initState() {
    super.initState();
    _loadData(shuffle: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
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
        posts.shuffle(Random());
        reels.shuffle(Random());
      }

      // Create feed with posts and reels interspersed
      feedItems = [];
      int postIndex = 0;
      int reelIndex = 0;

      // Add 2 posts, then 1 reel, repeat
      while (postIndex < posts.length || reelIndex < reels.length) {
        // Add 2 posts
        if (postIndex < posts.length) {
          feedItems.add(posts[postIndex]);
          postIndex++;
        }
        if (postIndex < posts.length) {
          feedItems.add(posts[postIndex]);
          postIndex++;
        }

        // Add 1 reel
        if (reelIndex < reels.length) {
          feedItems.add(reels[reelIndex]);
          reelIndex++;
        }
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
      backgroundColor: AppColors.transparent,
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
      backgroundColor: AppColors.transparent,
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

  void _openAddPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPostScreen(),
        fullscreenDialog: true,
      ),
    ).then((_) => _loadData());
  }

  Future<void> _refreshPosts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _loadData(shuffle: true);
  }

  Widget _buildFeedItem(BuildContext context, int index) {
    final item = feedItems[index];

    if (item is ReelModel) {
      return ReelWidget(
        key: ValueKey('reel_${item.id}'),
        reel: item,
        onReelUpdated: () => _loadData(),
        onNavigateToReels: widget.onNavigateToReels,
      );
    } else if (item is PostModel) {
      return PostWidget(
        key: ValueKey('post_${item.id}'),
        post: item,
        onLike: _handleLike,
        onProfileTap: _openProfile,
        onComment: _openComments,
        onShare: _openShare,
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Flexible(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset(AppImages.instagramtext, height: 120),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.add_outlined,
            color: AppColors.black,
            size: 28,
          ),
          onPressed: _openAddPost,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
              color: AppColors.black,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          SystemNavigator.pop();
        },
        child: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _refreshPosts,
          displacement: 60,
          edgeOffset: 10,
          color: AppColors.grey700,
          backgroundColor: AppColors.white,
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
                        // Current user's story
                        final userStory = DummyData.stories.firstWhere(
                          (s) => s.userId == DummyData.currentUser.id,
                          orElse: () => StoryModel(
                            id: '',
                            userId: DummyData.currentUser.id,
                            username: DummyData.currentUser.username,
                            profileImageUrl: DummyData.currentUser.profileImage,
                            images: [],
                            timeAgo: '',
                          ),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: StoryAvatar(
                            user: DummyData.currentUser,
                            story: userStory.id.isNotEmpty ? userStory : null,
                            hasStory: DummyData.stories.any(
                              (s) => s.userId == DummyData.currentUser.id,
                            ),
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

                      // Find the story for this user
                      final userStory = DummyData.stories.firstWhere(
                        (s) => s.userId == user.id,
                        orElse: () => StoryModel(
                          id: '',
                          userId: user.id,
                          username: user.username,
                          profileImageUrl: user.profileImage,
                          images: [],
                          timeAgo: '',
                        ),
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: StoryAvatar(
                          user: user,
                          story: userStory.id.isNotEmpty ? userStory : null,
                          hasStory: true,
                          onTap: () => _openStory(user.id),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Divider(height: 1, thickness: 0.5),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildFeedItem(context, index),
                  childCount: feedItems.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
