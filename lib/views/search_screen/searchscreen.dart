import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/views/post_screen/post_screen.dart';
import 'package:instagram/widgets/universal_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PostModel> _displayedPosts = [];

  @override
  void initState() {
    super.initState();
    _displayedPosts = List.from(DummyData.posts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedPosts = List.from(DummyData.posts);
      } else {
        _displayedPosts = DummyData.posts.where((post) {
          final user = DummyData.getUserById(post.userId);
          final username = user?.username.toLowerCase() ?? '';
          final caption = post.caption.toLowerCase();
          final searchLower = query.toLowerCase();

          return username.contains(searchLower) ||
              caption.contains(searchLower) ||
              (post.location?.toLowerCase().contains(searchLower) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          onChanged: _onSearch,
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
      body: _displayedPosts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No posts found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemCount: _displayedPosts.length,
              itemBuilder: (context, index) {
                final post = _displayedPosts[index];

                return GestureDetector(
                  onTap: () {
                    // Find the actual index in DummyData.posts
                    final actualIndex = DummyData.posts.indexWhere(
                      (p) => p.id == post.id,
                    );

                    if (actualIndex != -1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostScreen(
                            userId: post.userId,
                            initialIndex: DummyData.posts
                                .where((p) => p.userId == post.userId)
                                .toList()
                                .indexWhere((p) => p.id == post.id),
                          ),
                        ),
                      ).then((_) {
                        // Refresh when coming back
                        setState(() {
                          _displayedPosts = List.from(DummyData.posts);
                        });
                      });
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Post thumbnail
                      UniversalImage(
                        imagePath: post.images[0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),

                      // Multiple images indicator
                      if (post.images.length > 1)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            Icons.collections,
                            color: Colors.white,
                            size: 20,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black54),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
