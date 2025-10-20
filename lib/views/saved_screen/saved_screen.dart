import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/saved_item_model.dart';
import 'package:instagram/widgets/universal_image.dart';
import 'package:instagram/views/post_screen/post_screen.dart';
import 'package:instagram/views/reels_screen/reels_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SavedItem> _savedItems = [];
  String _selectedFilter = 'All'; // 'All', 'Posts', 'Reels', 'Collections'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSavedItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSavedItems() {
    setState(() {
      _savedItems = DummyData.getSavedItemsSorted();
    });
  }

  List<SavedItem> _getFilteredItems() {
    if (_selectedFilter == 'Posts') {
      return _savedItems.where((item) => item.itemType == 'post').toList();
    } else if (_selectedFilter == 'Reels') {
      return _savedItems.where((item) => item.itemType == 'reel').toList();
    }
    return _savedItems;
  }

  void _removeSavedItem(SavedItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from saved?'),
        content: Text('Remove this ${item.itemType} from your saved items?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                DummyData.removeSavedItem(
                  itemType: item.itemType,
                  itemId: item.itemId,
                );
                _loadSavedItems();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Removed from saved'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  void _openSavedItem(SavedItem item) {
    if (item.itemType == 'post') {
      final post = DummyData.getPostById(item.itemId);

      if (post == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post not found')));
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostScreen(
            userId: post.userId,
            initialIndex: DummyData.posts.indexWhere((p) => p.id == post.id),
          ),
        ),
      ).then((_) => _loadSavedItems());
    } else if (item.itemType == 'reel') {
      final reel = DummyData.getReelById(item.itemId);

      if (reel == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reel not found')));
        return;
      }

      final reelIndex = DummyData.reels.indexWhere((r) => r.id == reel.id);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReelsScreen(userId: item.userId, initialIndex: reelIndex),
        ),
      ).then((_) => _loadSavedItems());
    }
  }

  Widget _buildThumbnail(SavedItem item) {
    String thumbnailPath = '';
    bool isReel = item.itemType == 'reel';

    if (item.itemType == 'post') {
      final post = DummyData.getPostById(item.itemId);
      if (post != null && post.images.isNotEmpty) {
        thumbnailPath = post.images.first;
      }
    } else if (item.itemType == 'reel') {
      final reel = DummyData.getReelById(item.itemId);
      if (reel != null) {
        thumbnailPath = reel.thumbnailUrl;
      }
    }

    return GestureDetector(
      onTap: () => _openSavedItem(item),
      onLongPress: () => _removeSavedItem(item),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (thumbnailPath.isNotEmpty)
            UniversalImage(imagePath: thumbnailPath, fit: BoxFit.cover)
          else
            Container(
              color: AppColors.grey300,
              child: const Icon(Icons.image, color: AppColors.grey, size: 40),
            ),
          if (isReel)
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
                  Icons.play_arrow,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();
    final savedPosts = _savedItems
        .where((item) => item.itemType == 'post')
        .toList();
    final savedReels = _savedItems
        .where((item) => item.itemType == 'reel')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.black, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Create collection feature coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Collections'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Reels'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Posts'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Collections layout
          if (_selectedFilter == 'Collections')
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(child: Text('No items in collections'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (savedPosts.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Posts',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1,
                                      ),
                                  itemCount: savedPosts.length,
                                  itemBuilder: (context, index) =>
                                      _buildThumbnail(savedPosts[index]),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          if (savedReels.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Reels',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1,
                                      ),
                                  itemCount: savedReels.length,
                                  itemBuilder: (context, index) =>
                                      _buildThumbnail(savedReels[index]),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                        ],
                      ),
                    ),
            ),

          // Grid for Posts/Reels/All
          if (_selectedFilter != 'Collections')
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 80,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No saved items yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Save posts and reels to view them here',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 1,
                          ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return _buildThumbnail(filteredItems[index]);
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.grey200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.grey300!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
