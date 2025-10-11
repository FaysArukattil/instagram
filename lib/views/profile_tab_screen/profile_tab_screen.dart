import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/views/add_post_screen/add_post_screen.dart';
import 'package:instagram/views/edit_profile_screen/edit_profil_screen.dart';
import 'package:instagram/views/follower_screen/follower_screen.dart';
import 'package:instagram/views/post_screen/post_screen.dart';
import 'package:instagram/views/reels_screen/reels_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    // Reload data every time dependencies change (when tab is switched to)
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
    setState(() {
      _loadData();
    });
  }

  @override
  void didPush() {
    // Called when this route is pushed onto the navigator
    _loadData();
  }

  @override
  void didPushNext() {
    // Called when a new route is pushed on top of this route
  }

  void _loadData() {
    setState(() {
      currentUser = DummyData.currentUser;

      // Load user's posts
      userPosts = DummyData.posts
          .where((post) => post.userId == currentUser.id)
          .toList();

      // Load user's reels
      userReels = DummyData.reels
          .where((reel) => reel.userId == currentUser.id)
          .toList();

      // Update counts
      _updateFollowerCounts();

      // Calculate friends count (mutual follows)
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

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Your activity'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('QR code'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Saved'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
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
      backgroundColor: Colors.white,
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
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentUser.username,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                  ],
                ),
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          color: Colors.black,
                        ),
                        onPressed: () {},
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
                            '9+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_box_outlined,
                      color: Colors.black,
                    ),
                    onPressed: _navigateToAddPost,
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: _showOptionsMenu,
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
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: currentUser.hasStory
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFFFBAA47),
                                                Color(0xFFD91A46),
                                                Color(0xFFA60F93),
                                              ],
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft,
                                            )
                                          : null,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(3),
                                      child: ClipOval(
                                        child: SizedBox(
                                          width: 84,
                                          height: 84,
                                          child: UniversalImage(
                                            imagePath: currentUser.profileImage,
                                            fit: BoxFit.cover,
                                            placeholder: Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            ),
                                            errorWidget: Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.person,
                                                size: 42,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: _navigateToAddPost,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                          const SizedBox(height: 2),

                          // Username with @ icon
                          Row(
                            children: [
                              const Icon(
                                Icons.alternate_email,
                                size: 14,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                currentUser.username,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
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

                          // Professional Dashboard Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Professional dashboard',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      size: 14,
                                      color: Colors.green[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '6 views in the last 30 days.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

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
                                child: _buildActionButton('Share profile'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

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
                    if (selectedTabIndex == 2)
                      _buildEmptyState('No Reposts Yet'),
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
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
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
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 1,
              ),
            ),
          ),
          child: Icon(icon, color: isSelected ? Colors.black : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (userPosts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
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
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
                placeholder: Container(color: Colors.grey[300]),
                errorWidget: Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 40),
                ),
              ),
              if (post.images.length > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.collections,
                      color: Colors.white,
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
        final fullReelIndex = DummyData.reels.indexWhere(
          (r) => r.id == reel.id,
        );

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReelsScreen(
                  initialIndex: fullReelIndex >= 0 ? fullReelIndex : 0,
                ),
              ),
            ).then((_) => _loadData());
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              UniversalImage(
                imagePath: reel.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: Container(color: Colors.grey[300]),
                errorWidget: Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.videocam, size: 40),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatCount(reel.likes),
                      style: const TextStyle(
                        color: Colors.white,
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
            Icon(Icons.camera_alt_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
