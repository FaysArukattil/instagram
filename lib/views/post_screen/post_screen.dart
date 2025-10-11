import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/services/data_persistence.dart';
import 'package:instagram/views/commentscreen/commentscreen.dart';
import 'package:instagram/views/share_bottom_sheet/share_bottom_sheet.dart';
import 'package:instagram/widgets/universal_image.dart';

class PostScreen extends StatefulWidget {
  final String userId;
  final int initialIndex;

  const PostScreen({
    super.key,
    required this.userId,
    required this.initialIndex,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late PageController _pageController;
  late List<PostModel> userPosts;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    userPosts = DummyData.posts
        .where((post) => post.userId == widget.userId)
        .toList();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleLike(String postId) {
    setState(() {
      final index = userPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        userPosts[index].isLiked = !userPosts[index].isLiked;
        userPosts[index].likes += userPosts[index].isLiked ? 1 : -1;

        // Update in main data
        final mainIndex = DummyData.posts.indexWhere((p) => p.id == postId);
        if (mainIndex != -1) {
          DummyData.posts[mainIndex].isLiked = userPosts[index].isLiked;
          DummyData.posts[mainIndex].likes = userPosts[index].likes;
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
    ).then(
      (_) => setState(() {
        // Update comment count
        final index = userPosts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          userPosts[index].comments = DummyData.getCommentsForPost(
            post.id,
          ).length;
        }
      }),
    );
  }

  void _openShare(PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(post: post),
    );
  }

  void _showPostOptions(PostModel post) {
    final isOwnPost = post.userId == DummyData.currentUser.id;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwnPost)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(post);
                },
              ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share to...'),
              onTap: () {
                Navigator.pop(context);
                _openShare(post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(PostModel post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Post?'),
          content: const Text(
            'Are you sure you want to delete this post? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePost(post);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(PostModel post) async {
    // Remove from main posts list
    DummyData.posts.removeWhere((p) => p.id == post.id);

    // Update user post count
    DummyData.currentUser.posts--;

    // Save updated data
    await DataPersistence.savePosts(DummyData.posts);
    await DataPersistence.saveUserPostCount(DummyData.currentUser.posts);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back if this was the only post or last post
      if (userPosts.length <= 1) {
        Navigator.pop(context);
      } else {
        // Refresh the list
        setState(() {
          userPosts = DummyData.posts
              .where((p) => p.userId == widget.userId)
              .toList();

          // Adjust current index if needed
          if (currentIndex >= userPosts.length) {
            currentIndex = userPosts.length - 1;
            _pageController.jumpToPage(currentIndex);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userPosts.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('No posts available')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          DummyData.getUserById(widget.userId)?.username ?? 'Posts',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemCount: userPosts.length,
        itemBuilder: (context, index) {
          final post = userPosts[index];
          final user = DummyData.getUserById(post.userId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile picture using UniversalImage
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[300],
                        child: ClipOval(
                          child: UniversalImage(
                            imagePath: user?.profileImage ?? '',
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (post.location != null)
                              Text(
                                post.location!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onPressed: () => _showPostOptions(post),
                      ),
                    ],
                  ),
                ),

                // Images with proper aspect ratio
                SizedBox(
                  height: MediaQuery.of(context).size.width,
                  child: post.images.length == 1
                      ? UniversalImage(
                          imagePath: post.images[0],
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        )
                      : PageView.builder(
                          itemCount: post.images.length,
                          itemBuilder: (context, imgIndex) {
                            return UniversalImage(
                              imagePath: post.images[imgIndex],
                              width: double.infinity,
                              height: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: post.isLiked ? Colors.red : Colors.black,
                          size: 28,
                        ),
                        onPressed: () => _handleLike(post.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, size: 26),
                        onPressed: () => _openComments(post),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send_outlined, size: 26),
                        onPressed: () => _openShare(post),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border, size: 26),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Likes and caption
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${post.likes} likes',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (post.caption.isNotEmpty)
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '${user?.username ?? "Unknown"} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: post.caption),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (post.comments > 0)
                        GestureDetector(
                          onTap: () => _openComments(post),
                          child: Text(
                            'View all ${post.comments} comments',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        post.timeAgo,
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
