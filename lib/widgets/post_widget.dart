import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/views/three_dot_bottom_sheet/three_dot_bottom_sheet.dart';
import 'package:instagram/widgets/universal_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
  // ignore: unused_field
  int _currentPage = 0;
  late bool _isSaved;
  final PhotoViewScaleStateController _scaleStateController =
      PhotoViewScaleStateController();

  // --- Double-tap heart animation state ---
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _moveUpAnimation;
  late Animation<double> _wiggleAnimation;
  bool _showHeart = false;
  Offset _tapPosition = Offset.zero;
  final Random _random = Random();
  late List<Color> _currentGradient;
  final List<List<Color>> _gradients = const [
    [Color(0xFFfeda75), Color(0xFFfa7e1e), Color(0xFFd62976)],
    [Color(0xFF833ab4), Color(0xFFfd1d1d), Color(0xFFfcb045)],
    [Color(0xFFf09433), Color(0xFFe6683c), Color(0xFFdc2743)],
  ];

  @override
  void initState() {
    super.initState();
    _isSaved = DummyData.isItemSaved(itemType: 'post', itemId: widget.post.id);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
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
    _currentGradient = _gradients[_random.nextInt(_gradients.length)];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startHeartAnimation() {
    _currentGradient = _gradients[_random.nextInt(_gradients.length)];
    setState(() => _showHeart = true);
    _animationController.forward();
  }

  Future<void> _handleDoubleTapLike() async {
    _startHeartAnimation();
    final post = widget.post;
    if (!post.isLiked) {
      await DummyData.likeItem(
        itemType: 'post',
        itemId: post.id,
        userId: post.userId,
      );
      setState(() {
        post.isLiked = DummyData.getPostById(post.id)?.isLiked ?? true;
        post.likes = DummyData.getPostById(post.id)?.likes ?? post.likes;
      });
      widget.onPostUpdated?.call();
    }
  }

  void _toggleSave() {
    setState(() {
      if (_isSaved) {
        DummyData.removeSavedItem(itemType: 'post', itemId: widget.post.id);
        _isSaved = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Removed from saved')));
      } else {
        DummyData.saveItem(
          itemType: 'post',
          itemId: widget.post.id,
          userId: widget.post.userId,
        );
        _isSaved = true;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved to collection')));
      }
    });
    widget.onPostUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    final user = DummyData.getUserById(widget.post.userId);
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
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
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
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
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.transparent,
                    builder: (context) =>
                        ThreeDotBottomSheet(post: widget.post),
                  );
                },
              ),
            ],
          ),
        ),

        // IMAGE SECTION WITH PACKAGE-BASED ZOOM
        AspectRatio(
          aspectRatio: 1,
          child: Listener(
            onPointerUp: (_) {
              _scaleStateController.scaleState = PhotoViewScaleState.initial;
            },
            child: Stack(
              children: [
                ClipRect(
                  child: PhotoViewGallery.builder(
                    pageController: _pageController,
                    itemCount: widget.post.images.length,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    builder: (context, index) {
                      final path = widget.post.images[index];
                      return PhotoViewGalleryPageOptions.customChild(
                        child: UniversalImage(
                          imagePath: path,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        scaleStateController: _scaleStateController,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 4.0,
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onDoubleTapDown: (d) => _tapPosition = d.localPosition,
                    onDoubleTap: () {
                      _handleDoubleTapLike();
                    },
                  ),
                ),
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
                              shaderCallback: (bounds) => LinearGradient(
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

        // ACTIONS
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
                onPressed: () async {
                  final post = widget.post;
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
                        DummyData.getPostById(post.id)?.isLiked ?? false;
                    post.likes =
                        DummyData.getPostById(post.id)?.likes ?? post.likes;
                  });
                  widget.onPostUpdated?.call();
                },
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
                  if (widget.onShare != null) widget.onShare!(widget.post);
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

        // CAPTION
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
