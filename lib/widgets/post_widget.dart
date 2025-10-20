import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/views/three_dot_bottom_sheet/three_dot_bottom_sheet.dart';
import 'package:instagram/widgets/universal_image.dart';

class PostWidget extends StatefulWidget {
  final PostModel post;
  final Function(String) onLike;
  final Function(String) onProfileTap;
  final Function(PostModel)? onComment;
  final Function(PostModel)? onShare;
  final VoidCallback? onPostUpdated;

  const PostWidget({
    super.key,
    required this.post,
    required this.onLike,
    required this.onProfileTap,
    this.onComment,
    this.onShare,
    this.onPostUpdated,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _showHeart = false;
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = DummyData.isItemSaved(itemType: 'post', itemId: widget.post.id);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0),
      ),
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

  void _handleDoubleTap() {
    if (!widget.post.isLiked) {
      widget.onLike(widget.post.id);
    }
    setState(() => _showHeart = true);
    _animationController.forward();
  }

  void _toggleSave() {
    setState(() {
      if (_isSaved) {
        DummyData.removeSavedItem(itemType: 'post', itemId: widget.post.id);
        _isSaved = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from saved'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        DummyData.saveItem(
          itemType: 'post',
          itemId: widget.post.id,
          userId: widget.post.userId,
        );
        _isSaved = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to collection'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
    widget.onPostUpdated?.call();
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => ThreeDotBottomSheet(post: widget.post),
    ).then((_) {
      setState(() {
        _isSaved = DummyData.isItemSaved(
          itemType: 'post',
          itemId: widget.post.id,
        );
      });
      widget.onPostUpdated?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = DummyData.getUserById(widget.post.userId);
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with UniversalImage for profile picture
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => widget.onProfileTap(widget.post.userId),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.grey300,
                  child: ClipOval(
                    child: UniversalImage(
                      imagePath: user.profileImage,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => widget.onProfileTap(widget.post.userId),
                          child: Text(
                            user.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (widget.post.isSponsored) ...[
                          const SizedBox(width: 4),
                          const Text(
                            '• Sponsored',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.post.location != null)
                      Text(
                        widget.post.location!,
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
                onPressed: _showMoreOptions,
              ),
            ],
          ),
        ),

        // Image carousel with double tap
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: SizedBox(
            height: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: widget.post.images.length,
                  itemBuilder: (context, index) {
                    return UniversalImage(
                      imagePath: widget.post.images[index],
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    );
                  },
                ),
                if (widget.post.images.length > 1)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentPage + 1}/${widget.post.images.length}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                // Animated heart overlay
                if (_showHeart)
                  Center(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _opacityAnimation.value,
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 100,
                              shadows: [
                                Shadow(
                                  blurRadius: 20,
                                  color: AppColors.black54,
                                ),
                              ],
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

        // Page indicators (dots)
        if (widget.post.images.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.post.images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.blue
                        : AppColors.grey300,
                  ),
                ),
              ),
            ),
          ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.post.isLiked ? AppColors.red : AppColors.black,
                  size: 28,
                ),
                onPressed: () => widget.onLike(widget.post.id),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/Icons/comment_icon_outline.svg',
                  width: 26,
                  height: 26,
                  colorFilter: const ColorFilter.mode(
                    AppColors.black,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  if (widget.onComment != null) {
                    widget.onComment!(widget.post);
                  }
                },
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/Icons/share_icon_outline.svg',
                  width: 26,
                  height: 26,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  if (widget.onShare != null) {
                    widget.onShare!(widget.post);
                  }
                },
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: 26,
                  color: AppColors.black,
                ),
                onPressed: _toggleSave,
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
                '${widget.post.likes} likes',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (widget.post.caption.isNotEmpty)
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: '${user.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: widget.post.caption),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              if (widget.post.comments > 0)
                GestureDetector(
                  onTap: () {
                    if (widget.onComment != null) {
                      widget.onComment!(widget.post);
                    }
                  },
                  child: Text(
                    'View all ${widget.post.comments} comments',
                    style: TextStyle(color: AppColors.grey600, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                widget.post.timeAgo,
                style: TextStyle(color: AppColors.grey600, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
