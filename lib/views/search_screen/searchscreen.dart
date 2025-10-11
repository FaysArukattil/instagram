import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';
import 'package:instagram/views/post_screen/post_screen.dart';
import 'package:instagram/widgets/universal_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      for (var post in DummyData.posts) {
        post.images.shuffle();
      }
      _searchResults.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: _refreshContent,
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
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchUsers('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey[200],
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
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No users found',
                style: TextStyle(
                  color: Colors.grey[600],
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
    final List<Map<String, dynamic>> imageData = [];

    for (var post in DummyData.posts) {
      for (var image in post.images) {
        imageData.add({
          'imageUrl': image,
          'userId': post.userId,
          'hasMultiple': post.images.length > 1,
        });
      }
    }

    if (imageData.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No posts yet')),
      );
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
          (context, index) => _buildImageTile(imageData[index]),
          childCount: imageData.length,
        ),
      ),
    );
  }

  /// ✅ Fixed User Tile (UniversalImage used for both local + network images)
  Widget _buildUserTile(UserModel user) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserProfileScreen(user: user)),
        );
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
                      color: Colors.white,
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
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.name,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  if (user.bio.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        user.bio,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(Map<String, dynamic> data) {
    final String imageUrl = data['imageUrl'];
    final String userId = data['userId'];
    final bool hasMultiple = data['hasMultiple'];

    final userPosts = DummyData.posts.where((p) => p.userId == userId).toList();
    final postIndex = userPosts.indexWhere((p) => p.images.contains(imageUrl));

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
        );
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
                color: Colors.white,
                size: 20,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
        ],
      ),
    );
  }
}
