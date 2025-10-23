import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/views/commentscreen/commentscreen.dart';
import 'package:instagram/views/share_bottom_sheet/share_bottom_sheet.dart';
import 'package:instagram/widgets/universal_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/views/three_dot_bottom_sheet/three_dot_bottom_sheet.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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

class _PostScreenState extends State<PostScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late List<PostModel> userPosts;
  int currentIndex = 0;

  // Heart animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _moveUpAnimation;
  late Animation<double> _wiggleAnimation;

  Offset _tapPosition = Offset.zero;
  bool _showHeart = false;
  List<Color> _currentGradient = [Colors.red, Colors.pink];
  final PhotoViewScaleStateController _scaleStateController =
      PhotoViewScaleStateController();

  @override
  void initState() {
    super.initState();
    userPosts = DummyData.posts
        .where((post) => post.userId == widget.userId)
        .toList();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.4).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0),
      ),
    );

    _moveUpAnimation = Tween<double>(begin: 0, end: -50).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _wiggleAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // --- LIKE HANDLING ---
  void _handleDoubleTapLike(String postId, Offset tapPosition) {
    _tapPosition = tapPosition;
    _showHeartAnimation();

    setState(() async {
      final index = userPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = userPosts[index];
        if (!post.isLiked) {
          await DummyData.likeItem(
            itemType: 'post',
            itemId: post.id,
            userId: post.userId,
          );
          setState(() {
            post.isLiked = true;
            post.likes = DummyData.getPostById(post.id)?.likes ?? post.likes;
          });
        }
      }
    });
  }

  void _showHeartAnimation() {
    _currentGradient = [Colors.red, Colors.pink, Colors.orange, Colors.yellow]
      ..shuffle();
    setState(() => _showHeart = true);
    _animationController.forward();
  }


  // --- OPENERS ---
  void _openComments(PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => CommentsScreen(post: post),
    ).then(
      (_) => setState(() {
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
      backgroundColor: AppColors.transparent,
      builder: (context) => ShareBottomSheet(post: post),
    );
  }

  void _toggleSave(PostModel post) {
    setState(() {
      final isSaved = DummyData.isItemSaved(itemType: 'post', itemId: post.id);

      if (isSaved) {
        DummyData.removeSavedItem(itemType: 'post', itemId: post.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Removed from saved')));
      } else {
        DummyData.saveItem(
          itemType: 'post',
          itemId: post.id,
          userId: post.userId,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved to collection')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userPosts.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('No posts available')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          DummyData.getUserById(widget.userId)?.username ?? 'Posts',
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) => setState(() => currentIndex = index),
        itemCount: userPosts.length,
        itemBuilder: (context, index) {
          final post = userPosts[index];
          final user = DummyData.getUserById(post.userId);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.grey300,
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
                                  color: AppColors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: AppColors.transparent,
                            builder: (context) =>
                                ThreeDotBottomSheet(post: post),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // --- ZOOMABLE IMAGE SECTION (photo_view) ---
                AspectRatio(
                  aspectRatio: 1,
                  child: Listener(
                    onPointerUp: (_) {
                      _scaleStateController.scaleState =
                          PhotoViewScaleState.initial;
                    },
                    child: Stack(
                      children: [
                        ClipRect(
                          child: PhotoViewGallery.builder(
                            itemCount: post.images.length,
                            backgroundDecoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            builder: (context, imgIndex) {
                              return PhotoViewGalleryPageOptions.customChild(
                                child: UniversalImage(
                                  imagePath: post.images[imgIndex],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                scaleStateController: _scaleStateController,
                                minScale: PhotoViewComputedScale.contained,
                                maxScale:
                                    PhotoViewComputedScale.covered * 4.0,
                              );
                            },
                          ),
                        ),

                        // Double-tap like overlay
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onDoubleTapDown: (details) =>
                                _tapPosition = details.localPosition,
                            onDoubleTap: () =>
                                _handleDoubleTapLike(post.id, _tapPosition),
                          ),
                        ),

                        // Heart animation
                        if (_showHeart)
                          Positioned(
                            left: _tapPosition.dx - 50,
                            top: _tapPosition.dy - 50 + _moveUpAnimation.value,
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _wiggleAnimation.value,
                                  child: Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            colors: _currentGradient,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds),
                                      child: Opacity(
                                        opacity: _opacityAnimation.value,
                                        child: const Icon(
                                          Icons.favorite,
                                          size: 100,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // --- Buttons + Captions ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            post.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: post.isLiked
                                ? AppColors.red
                                : AppColors.black,
                            size: 28,
                          ),
                          onPressed: () async {
                            if (post.isLiked) {
                              await DummyData.unlikeItem(
                                itemType: 'post',
                                itemId: post.id,
                              );
                            } else {
                              await DummyData.likeItem(
                                itemType: 'post',
                                itemId: post.id,
                                userId: post.userId,
                              );
                            }
                            setState(() {
                              post.isLiked =
                                  DummyData.getPostById(post.id)?.isLiked ??
                                  false;
                              post.likes =
                                  DummyData.getPostById(post.id)?.likes ??
                                  post.likes;
                            });
                          },
                        ),

                        GestureDetector(
                          onTap: () => _openComments(post),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              'assets/Icons/comment_icon_outline.svg',
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openShare(post),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              'assets/Icons/share_icon_outline.svg',
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            DummyData.isItemSaved(
                                  itemType: 'post',
                                  itemId: post.id,
                                )
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 26,
                          ),
                          onPressed: () => _toggleSave(post),
                        ),
                      ],
                    ),
                  ),

                
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
                                color: AppColors.black,
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
                                color: AppColors.grey600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          post.timeAgo,
                          style: TextStyle(
                            color: AppColors.grey600,
                            fontSize: 11,
                          ),
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
