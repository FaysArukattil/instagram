import 'package:flutter/material.dart';
import 'package:instagram/views/commentscreen/commentscreen.dart';
import 'package:instagram/views/share_bottom_sheet/share_bottom_sheet.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../data/dummy_data.dart';

class PostWidget extends StatefulWidget {
  final PostModel post;
  final Function(String) onLike;
  final Function(String) onProfileTap;

  const PostWidget({
    super.key,
    required this.post,
    required this.onLike,
    required this.onProfileTap,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with SingleTickerProviderStateMixin {
  int currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _showHeart = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showHeart = false;
        });
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    // Only like if not already liked
    if (!widget.post.isLiked) {
      widget.onLike(widget.post.id);
    }

    // Show heart animation
    setState(() {
      _showHeart = true;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final user = DummyData.getUserById(widget.post.userId);
    if (user == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPostHeader(user),
        _buildPostImages(),
        _buildPostActions(user),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildPostHeader(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onProfileTap(user.id),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(user.profileImage),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onProfileTap(user.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  if (widget.post.location != null)
                    Text(
                      widget.post.location!,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  if (widget.post.isSponsored)
                    const Text(
                      'Sponsored',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildPostImages() {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: SizedBox(
            height: 400,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.post.images.length,
              onPageChanged: (index) {
                setState(() {
                  currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.post.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),
        ),
        if (_showHeart)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 120,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                  ),
                ),
              );
            },
          ),
        if (widget.post.images.length > 1)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${currentImageIndex + 1}/${widget.post.images.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        if (widget.post.images.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.post.images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentImageIndex == index
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostActions(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => widget.onLike(widget.post.id),
                child: Icon(
                  widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.post.isLiked ? Colors.red : Colors.black,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CommentsScreen(post: widget.post),
                  );
                },
                child: const Icon(Icons.chat_bubble_outline, size: 26),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ShareBottomSheet(post: widget.post),
                  );
                },
                child: const Icon(Icons.send, size: 26),
              ),
              const Spacer(),
              const Icon(Icons.bookmark_border, size: 26),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.post.likes} likes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: user.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ${widget.post.caption}'),
              ],
            ),
          ),
          if (widget.post.comments > 0) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CommentsScreen(post: widget.post),
                );
              },
              child: Text(
                'View all ${widget.post.comments} comments',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            widget.post.timeAgo,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
