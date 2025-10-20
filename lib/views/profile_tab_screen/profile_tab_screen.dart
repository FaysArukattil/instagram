import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/views/add_post_screen/add_post_screen.dart';
import 'package:instagram/views/edit_profile_screen/edit_profil_screen.dart';
import 'package:instagram/views/follower_screen/follower_screen.dart';
import 'package:instagram/views/post_screen/post_screen.dart';
import 'package:instagram/views/profile_screen/profile_preview_screen.dart';
import 'package:instagram/views/reels_screen/reels_screen.dart';
import 'package:instagram/views/settings_screen/settingscreen.dart';
import 'package:instagram/views/share_profile_screen/share_profile_screen.dart';
import 'package:instagram/views/story_viewer_screen/story_viewer_screen.dart';
import 'package:instagram/widgets/universal_image.dart';
import 'package:instagram/widgets/primary_button.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  late UserModel currentUser;
  int selectedTabIndex = 0;
  List<PostModel> userPosts = [];
  List<ReelModel> userReels = [];
  List<ReelModel> userReposts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (mounted) {
      setState(() {
        _loadData();
      });
    }
  }

  void _loadData() {
    if (!mounted) return;

    setState(() {
      currentUser = DummyData.currentUser;
      userPosts = DummyData.posts
          .where((post) => post.userId == currentUser.id)
          .toList();
      userReels = DummyData.getReelsForUser(currentUser.id);
      userReposts = DummyData.getRepostsForUser(currentUser.id);
      _updateFollowerCounts();

      final followingIds = DummyData.followingMap[currentUser.id] ?? [];
      final allUsers = DummyData.users;
      final followers = allUsers.where((u) {
        final userFollowingList = DummyData.followingMap[u.id] ?? [];
        return userFollowingList.contains(currentUser.id);
      }).toList();
      currentUser.friends = followers
          .where((u) => followingIds.contains(u.id))
          .length;
    });
  }

  void _updateFollowerCounts() {
    final currentUserId = DummyData.currentUser.id;
    DummyData.currentUser.followers = DummyData.getFollowerCount(currentUserId);
    DummyData.currentUser.following = DummyData.getFollowingCount(
      currentUserId,
    );
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: currentUser),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _navigateToFollowersScreen(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowersScreen(
          userId: currentUser.id,
          initialTabIndex: initialIndex,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToAddPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPostScreen(),
        fullscreenDialog: true,
      ),
    ).then((_) => _loadData());
  }

  void _handleProfilePictureTap() {
    final userStoryIndex = DummyData.stories.indexWhere(
      (story) => story.userId == currentUser.id,
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
      _openProfilePreview();
    }
  }

  void _openProfilePreview() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ProfilePreviewScreen(
            imagePath: currentUser.profileImage,
            username: currentUser.username,
            profileLink: "https://instagram.com/${currentUser.username}",
            isFollowing: false,
            onFollowToggle: () {},
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.9,
                end: 1.0,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
    }
    return count.toString();
  }

  Future<void> _refreshProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: AppColors.white,
                elevation: 0,
                pinned: true,
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: Text(
                  currentUser.username,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.add_outlined,
                    color: AppColors.black,
                    size: 28,
                  ),
                  onPressed: _navigateToAddPost,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: AppColors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Settingscreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),

                          // Profile Picture and Stats
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _handleProfilePictureTap,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (currentUser.hasStory)
                                      Container(
                                        width: 90,
                                        height: 90,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFFBAA47),
                                              Color(0xFFD91A46),
                                              Color(0xFFA60F93),
                                            ],
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      width: 84,
                                      height: 84,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    Hero(
                                      tag:
                                          'profile_${currentUser.username}_image',
                                      child: ClipOval(
                                        child: SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: UniversalImage(
                                            imagePath: currentUser.profileImage,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatColumn(
                                      _formatCount(currentUser.friends),
                                      'friends',
                                      () => _navigateToFollowersScreen(0),
                                    ),
                                    _buildStatColumn(
                                      _formatCount(currentUser.followers),
                                      'followers',
                                      () => _navigateToFollowersScreen(1),
                                    ),
                                    _buildStatColumn(
                                      _formatCount(currentUser.following),
                                      'following',
                                      () => _navigateToFollowersScreen(2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Name
                          Text(
                            currentUser.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Username with @ icon
                          Row(
                            children: [
                              const Text(
                                '@ ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                currentUser.username,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.black87,
                                ),
                              ),
                            ],
                          ),

                          if (currentUser.bio.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              currentUser.bio,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  'Edit profile',
                                  onTap: _navigateToEditProfile,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildActionButton(
                                  'Share profile',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ShareProfileScreen(
                                              username: DummyData
                                                  .currentUser
                                                  .username,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tab Bar
                          Row(
                            children: [
                              _buildTabIcon(Icons.grid_on, 0),
                              _buildTabIcon(Icons.video_library_outlined, 1),
                              _buildTabIcon(Icons.repeat, 2),
                              _buildTabIcon(Icons.person_pin_outlined, 3),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Content Area
                    if (selectedTabIndex == 0) _buildPostsGrid(),
                    if (selectedTabIndex == 1) _buildReelsGrid(),
                    if (selectedTabIndex == 2) _buildRepostsGrid(),
                    if (selectedTabIndex == 3)
                      _buildEmptyState('No Tagged Posts'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildTabIcon(IconData icon, int index) {
    final isSelected = selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
            if (index == 2) {
              _loadData();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.black : AppColors.transparent,
                width: 1,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? AppColors.black : AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (userPosts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.black, width: 2),
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Create your first post',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Give this space some love.',
                style: TextStyle(fontSize: 16, color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Create',
                onPressed: _navigateToAddPost,
                width: 120,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PostScreen(userId: currentUser.id, initialIndex: index),
              ),
            ).then((_) => _loadData());
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              UniversalImage(
                imagePath: post.images.isNotEmpty ? post.images.first : '',
                fit: BoxFit.cover,
              ),
              if (post.images.length > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: .6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.collections,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReelsGrid() {
    if (userReels.isEmpty) {
      return _buildEmptyState('No Reels Yet');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: userReels.length,
      itemBuilder: (context, index) {
        final reel = userReels[index];

        return GestureDetector(
          onTap: () {
            final fullReelIndex = DummyData.reels.indexWhere(
              (r) => r.id == reel.id,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReelsScreen(
                  initialIndex: fullReelIndex >= 0 ? fullReelIndex : 0,
                  isVisible: true,
                  disableShuffle: true,
                  userId: currentUser.id,
                ),
              ),
            ).then((_) => _loadData());
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              UniversalImage(imagePath: reel.thumbnailUrl, fit: BoxFit.cover),
              Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: AppColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatCount(reel.likes),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRepostsGrid() {
    if (userReposts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.black, width: 2),
                ),
                child: const Icon(Icons.repeat, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Repost videos you love',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Share reels to your profile so you can easily find them later.',
                style: TextStyle(fontSize: 16, color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: userReposts.length,
      itemBuilder: (context, index) {
        final reel = userReposts[index];

        return GestureDetector(
          onTap: () {
            final fullReelIndex = DummyData.reels.indexWhere(
              (r) => r.id == reel.id,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReelsScreen(
                  initialIndex: fullReelIndex >= 0 ? fullReelIndex : 0,
                  isVisible: true,
                  disableShuffle: true,
                  userId: currentUser.id,
                ),
              ),
            ).then((_) => _loadData());
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              UniversalImage(imagePath: reel.thumbnailUrl, fit: BoxFit.cover),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.repeat,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: AppColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatCount(reel.likes),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Icon(Icons.camera_alt_outlined, size: 60, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 18, color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }
}
