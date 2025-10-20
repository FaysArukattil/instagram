import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';
import 'package:instagram/views/post_screen/post_screen.dart';
import 'package:instagram/views/profile_tab_screen/profile_tab_screen.dart';
import 'package:instagram/views/reels_screen/reels_screen.dart';
import 'package:instagram/widgets/universal_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  List<UserModel> _searchResults = [];
  List<dynamic> _shuffledContent = []; // ✅ Mix of posts and reels
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // ✅ Load and shuffle both posts and reels
    _loadContent();
  }

  void _loadContent() {
    final List<dynamic> content = [];

    // Add all posts
    content.addAll(List<PostModel>.from(DummyData.posts));

    // Add all reels
    content.addAll(List<ReelModel>.from(DummyData.reels));

    // Shuffle the mixed content
    content.shuffle(Random());

    setState(() {
      _shuffledContent = content;
    });
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // ✅ Trigger refresh when returning to this screen
    _triggerAutoRefresh();
  }

  @override
  void didPush() {
    // ✅ Trigger refresh when first pushed
    _triggerAutoRefresh();
  }

  void _triggerAutoRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isSearching) {
        _refreshKey.currentState?.show();
      }
    });
  }

  void _searchUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = DummyData.users.where((user) {
        final searchLower = query.toLowerCase();
        return user.username.toLowerCase().contains(searchLower) ||
            user.name.toLowerCase().contains(searchLower);
      }).toList();

      if (DummyData.currentUser.username.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          DummyData.currentUser.name.toLowerCase().contains(
            query.toLowerCase(),
          )) {
        _searchResults.insert(0, DummyData.currentUser);
      }
    });
  }

  Future<void> _refreshContent() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _loadContent(); // ✅ Reload and reshuffle content

        if (_isSearching && _searchResults.isNotEmpty) {
          _searchResults.shuffle(Random());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _refreshContent,
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
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: AppColors.grey600),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.grey600,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.grey600,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchUsers('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.grey200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        onChanged: _searchUsers,
                      ),
                    ],
                  ),
                ),
              ),

              // Search Results or Explore Grid
              _isSearching
                  ? _buildSearchResultsSliver()
                  : _buildExploreGridSliver(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsSliver() {
    if (_searchResults.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.grey400),
              const SizedBox(height: 16),
              Text(
                'No users found',
                style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildUserTile(_searchResults[index]),
        childCount: _searchResults.length,
      ),
    );
  }

  Widget _buildExploreGridSliver() {
    if (_shuffledContent.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No content yet')),
      );
    }

    // ✅ Create grid items from mixed content
    final List<Map<String, dynamic>> gridItems = [];

    for (var item in _shuffledContent) {
      if (item is PostModel) {
        // Add post images
        for (var image in item.images) {
          gridItems.add({
            'type': 'post',
            'imageUrl': image,
            'userId': item.userId,
            'postId': item.id,
            'hasMultiple': item.images.length > 1,
          });
        }
      } else if (item is ReelModel) {
        // Add reel
        gridItems.add({
          'type': 'reel',
          'imageUrl': item.thumbnailUrl,
          'userId': item.userId,
          'reelId': item.id,
          'hasMultiple': false,
        });
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.all(2),
      sliver: SliverGrid(
        gridDelegate: SliverQuiltedGridDelegate(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          repeatPattern: QuiltedGridRepeatPattern.inverted,
          pattern: const [
            QuiltedGridTile(1, 1),
            QuiltedGridTile(1, 1),
            QuiltedGridTile(2, 1),
            QuiltedGridTile(1, 1),
            QuiltedGridTile(1, 1),
          ],
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildGridTile(gridItems[index]),
          childCount: gridItems.length,
        ),
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserProfileScreen(user: user)),
        ).then((_) {
          // ✅ Refresh when returning from profile
          if (mounted && !_isSearching) {
            _triggerAutoRefresh();
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (user.hasStory)
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFF58529),
                            Color(0xFFDD2A7B),
                            Color(0xFF8134AF),
                          ],
                        ),
                      ),
                    ),
                  Container(
                    width: user.hasStory ? 48 : 54,
                    height: user.hasStory ? 48 : 54,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: UniversalImage(
                        imagePath: user.profileImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.name,
                    style: TextStyle(color: AppColors.grey600, fontSize: 13),
                  ),
                  if (user.bio.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        user.bio,
                        style: TextStyle(
                          color: AppColors.grey500,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (user.isOnline)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ Build grid tile for both posts and reels
  Widget _buildGridTile(Map<String, dynamic> data) {
    final String type = data['type'];
    final String imageUrl = data['imageUrl'];
    final String userId = data['userId'];
    final bool hasMultiple = data['hasMultiple'];

    if (type == 'post') {
      // Handle post click
      final userPosts = _shuffledContent
          .whereType<PostModel>()
          .where((p) => p.userId == userId)
          .toList();
      final postIndex = userPosts.indexWhere(
        (p) => p.images.contains(imageUrl),
      );

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreen(
                userId: userId,
                initialIndex: postIndex >= 0 ? postIndex : 0,
              ),
            ),
          ).then((_) {
            if (mounted && !_isSearching) {
              _triggerAutoRefresh();
            }
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            UniversalImage(
              imagePath: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            if (hasMultiple)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.collections,
                  color: AppColors.white,
                  size: 20,
                  shadows: [Shadow(blurRadius: 4, color: AppColors.black54)],
                ),
              ),
          ],
        ),
      );
    } else {
      // Handle reel click
      final userReels = _shuffledContent
          .whereType<ReelModel>()
          .where((r) => r.userId == userId)
          .toList();
      final reelIndex = userReels.indexWhere((r) => r.id == data['reelId']);

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReelsScreen(
                initialIndex: reelIndex >= 0 ? reelIndex : 0,
                userId: userId,
                disableShuffle: true,
              ),
            ),
          ).then((_) {
            if (mounted && !_isSearching) {
              _triggerAutoRefresh();
            }
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            UniversalImage(
              imagePath: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            // ✅ Reel icon overlay
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.play_arrow,
                color: AppColors.white,
                size: 24,
                shadows: [Shadow(blurRadius: 4, color: AppColors.black54)],
              ),
            ),
          ],
        ),
      );
    }
  }
}
