import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/views/three_dot_bottom_sheet/three_dot_bottom_sheet.dart';
import 'package:video_player/video_player.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/views/commentscreen/commentscreen.dart';
import 'package:instagram/views/share_bottom_sheet/share_bottom_sheet.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class ReelWidget extends StatefulWidget {
  final ReelModel reel;
  final VoidCallback? onReelUpdated;
  final void Function(int, int, Duration)? onNavigateToReels;

  const ReelWidget({
    super.key,
    required this.reel,
    this.onReelUpdated,
    this.onNavigateToReels,
  });

  @override
  State<ReelWidget> createState() => _ReelWidgetState();
}

class _ReelWidgetState extends State<ReelWidget>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late bool _isSaved;
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showVolumeIndicator = false;
  late AnimationController _likeAnimationController;
  bool _isPausedByUser = false;
  bool _showHeartAnimation = false;
  bool _isVisible = false;
  bool _isDisposing = false; // Add flag to prevent operations during disposal

  // Animation properties for gradient heart
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _moveUpAnimation;
  late Animation<double> _wiggleAnimation;
  Offset _tapPosition = Offset.zero;

  // Tap handling variables
  int _tapCount = 0;
  Timer? _tapTimer;

  final Random _random = Random();
  late List<Color> _currentGradient;

  final List<List<Color>> _gradients = [
    [
      Color(0xFFfeda75),
      Color(0xFFfa7e1e),
      Color(0xFFd62976),
      Color(0xFF962fbf),
      Color(0xFF4f5bd5),
    ],
    [
      Color(0xFFf09433),
      Color(0xFFe6683c),
      Color(0xFFdc2743),
      Color(0xFFcc2366),
      Color(0xFFbc1888),
    ],
    [Color(0xFF833ab4), Color(0xFFfd1d1d), Color(0xFFfcb045)],
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
    _isSaved = DummyData.isItemSaved(itemType: 'reel', itemId: widget.reel.id);

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Scale animation with bounce effect
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.6,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.4,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_likeAnimationController);

    // Fade out animation
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: const Interval(0.4, 1.0),
      ),
    );

    // Move up animation
    _moveUpAnimation = Tween<double>(begin: 0, end: -50).animate(
      CurvedAnimation(parent: _likeAnimationController, curve: Curves.easeOut),
    );

    // Wiggle animation
    _wiggleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: -0.1,
          end: 0.1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.1,
          end: -0.05,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -0.05,
          end: 0.05,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.05,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_likeAnimationController);

    _likeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isDisposing) {
        if (mounted) {
          setState(() => _showHeartAnimation = false);
        }
        _likeAnimationController.reset();
      }
    });

    _currentGradient = _gradients[_random.nextInt(_gradients.length)];
  }

  Future<void> _initializeVideo() async {
    if (_isDisposing) return;

    try {
      if (widget.reel.videoUrl.startsWith('http') ||
          widget.reel.videoUrl.startsWith('https')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.reel.videoUrl),
        );
      } else if (widget.reel.videoUrl.startsWith('assets/')) {
        _controller = VideoPlayerController.asset(widget.reel.videoUrl);
      } else {
        _controller = VideoPlayerController.file(File(widget.reel.videoUrl));
      }

      await _controller.initialize();

      if (_isDisposing || !mounted) {
        _controller.dispose();
        return;
      }

      _controller.setLooping(true);

      widget.reel.isMuted = false;
      _controller.setVolume(1);

      if (mounted && !_isDisposing) {
        setState(() {
          _isInitialized = true;
        });

        if (_isVisible && !_isPausedByUser) {
          _controller.play();
        }
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted || _isDisposing) return;

    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction > 0.5;

    if (_isVisible != wasVisible) {
      if (_isVisible && _isInitialized && !_isPausedByUser) {
        _controller.play();
      } else if (!_isVisible && _isInitialized) {
        _controller.pause();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposing) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isInitialized && _controller.value.isPlaying) {
        _controller.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isInitialized && _isVisible && !_isPausedByUser) {
        _controller.play();
      }
    }
  }

  @override
  void didUpdateWidget(ReelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only reinitialize if the reel ID actually changed
    if (widget.reel.id != oldWidget.reel.id) {
      _isDisposing = true;
      _controller.dispose();
      _isInitialized = false;
      _isDisposing = false;
      _initializeVideo();
    } else {
      // Just update the saved state without reinitializing
      final newSavedState = DummyData.isItemSaved(
        itemType: 'reel',
        itemId: widget.reel.id,
      );
      if (_isSaved != newSavedState && mounted && !_isDisposing) {
        setState(() {
          _isSaved = newSavedState;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    _tapTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _likeAnimationController.dispose();
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _toggleMute() {
    if (_isDisposing || !mounted) return;

    setState(() {
      widget.reel.isMuted = !widget.reel.isMuted;
      _controller.setVolume(widget.reel.isMuted ? 0 : 1);
      _showVolumeIndicator = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && !_isDisposing) {
        setState(() {
          _showVolumeIndicator = false;
        });
      }
    });
  }

  void _toggleLike() {
    if (_isDisposing || !mounted) return;

    setState(() {
      widget.reel.isLiked = !widget.reel.isLiked;
      widget.reel.likes += widget.reel.isLiked ? 1 : -1;
    });

    // Persist like/unlike in DummyData
    if (widget.reel.isLiked) {
      DummyData.likeItem(
        itemType: 'reel',
        itemId: widget.reel.id,
        userId: widget.reel.userId,
      );
    } else {
      DummyData.unlikeItem(itemType: 'reel', itemId: widget.reel.id);
    }

    Future.microtask(() {
      if (mounted && !_isDisposing) {
        widget.onReelUpdated?.call();
      }
    });
  }

  void _handleTap() {
    if (_isDisposing) return;

    _tapCount++;

    debugPrint('👆 TAP DETECTED! Count: $_tapCount');

    // Cancel any existing timer
    _tapTimer?.cancel();

    if (_tapCount == 1) {
      // Wait to see if there's a double tap
      _tapTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted && !_isDisposing && _tapCount == 1) {
          // Single tap confirmed - navigate to reel screen
          debugPrint('✅ SINGLE TAP CONFIRMED - Opening reel screen');
          _openReelScreen();
        }
        _tapCount = 0;
      });
    } else if (_tapCount >= 2) {
      // Double tap confirmed immediately
      debugPrint('❤️ DOUBLE TAP - Showing heart animation');

      // Only toggle like if not already liked
      if (!widget.reel.isLiked) {
        _toggleLike();
      }
      _startHeartAnimation();

      // Reset count immediately after handling double tap
      _tapCount = 0;

      // Cancel timer since we've handled the double tap
      _tapTimer?.cancel();
    }
  }

  void _startHeartAnimation() {
    if (_isDisposing || !mounted) return;

    _currentGradient = _gradients[_random.nextInt(_gradients.length)];
    setState(() => _showHeartAnimation = true);
    _likeAnimationController.forward();
  }

  void _toggleFollow() {
    if (_isDisposing || !mounted) return;

    setState(() {
      final user = DummyData.getUserById(widget.reel.userId);
      if (user != null) {
        user.isFollowing = !user.isFollowing;
        user.followers += user.isFollowing ? 1 : -1;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isFollowing
                  ? 'Following ${user.username}'
                  : 'Unfollowed ${user.username}',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: user.isFollowing
                ? AppColors.blue
                : AppColors.grey700,
          ),
        );
      }
    });

    Future.microtask(() {
      if (mounted && !_isDisposing) {
        widget.onReelUpdated?.call();
      }
    });
  }

  void _openComments() {
    if (_isDisposing) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPausedByUser = true;
    }

    final tempPost = PostModel(
      id: widget.reel.id,
      userId: widget.reel.userId,
      images: [widget.reel.thumbnailUrl],
      caption: widget.reel.caption,
      likes: widget.reel.likes,
      comments: widget.reel.comments,
      timeAgo: widget.reel.timeAgo,
      location: widget.reel.location,
      isLiked: widget.reel.isLiked,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsScreen(post: tempPost),
    ).then((_) {
      if (_isDisposing || !mounted) return;

      _isPausedByUser = false;
      if (_isVisible && mounted) {
        _controller.play();
      }
      setState(() {
        widget.reel.comments = DummyData.getCommentsForPost(
          widget.reel.id,
        ).length;
      });

      Future.microtask(() {
        if (mounted && !_isDisposing) {
          widget.onReelUpdated?.call();
        }
      });
    });
  }

  void _handleRepost() {
    if (_isDisposing || !mounted) return;

    setState(() {
      if (widget.reel.isReposted) {
        widget.reel.isReposted = false;
        widget.reel.shares = widget.reel.shares > 0
            ? widget.reel.shares - 1
            : 0;
        DummyData.removeRepost(widget.reel.id, DummyData.currentUser.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from your profile'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.grey,
          ),
        );
      } else {
        widget.reel.isReposted = true;
        widget.reel.shares++;
        DummyData.addRepost(widget.reel.id, DummyData.currentUser.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reposted to your profile'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.green,
          ),
        );
      }
    });

    Future.microtask(() {
      if (mounted && !_isDisposing) {
        widget.onReelUpdated?.call();
      }
    });
  }

  void _openShare() {
    if (_isDisposing) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPausedByUser = true;
    }

    final tempPost = PostModel(
      id: widget.reel.id,
      userId: widget.reel.userId,
      images: [widget.reel.thumbnailUrl],
      caption: widget.reel.caption,
      likes: widget.reel.likes,
      comments: widget.reel.comments,
      timeAgo: widget.reel.timeAgo,
      location: widget.reel.location,
      isLiked: widget.reel.isLiked,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => ShareBottomSheet(post: tempPost),
    ).then((_) {
      if (_isDisposing || !mounted) return;

      _isPausedByUser = false;
      if (_isVisible && mounted) {
        _controller.play();
      }
    });
  }

  void _openReelScreen() {
    if (_isDisposing) return;

    // Only navigate if callback exists
    if (widget.onNavigateToReels == null) {
      return;
    }

    // Find this exact reel's index in the main reels list
    final reelIndex = DummyData.reels.indexWhere((r) => r.id == widget.reel.id);

    if (reelIndex == -1) {
      return;
    }

    final currentPosition = _isInitialized
        ? _controller.value.position
        : Duration.zero;

    // Navigate to reels tab (index 1) with the specific reel index
    widget.onNavigateToReels!(1, reelIndex, currentPosition);
  }

  void _showMoreOptions() {
    if (_isDisposing) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPausedByUser = true;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) => ThreeDotBottomSheet(reel: widget.reel),
    ).then((_) {
      if (_isDisposing || !mounted) return;

      _isPausedByUser = false;
      if (_isVisible && mounted) {
        _controller.play();
      }
      setState(() {});

      Future.microtask(() {
        if (mounted && !_isDisposing) {
          widget.onReelUpdated?.call();
        }
      });
    });
  }

  void _toggleSave() {
    if (_isDisposing || !mounted) return;

    setState(() {
      if (_isSaved) {
        DummyData.removeSavedItem(itemType: 'reel', itemId: widget.reel.id);
        _isSaved = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from saved'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        DummyData.saveItem(
          itemType: 'reel',
          itemId: widget.reel.id,
          userId: widget.reel.userId,
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

    // Use microtask to avoid calling during build
    Future.microtask(() {
      if (mounted && !_isDisposing) {
        widget.onReelUpdated?.call();
      }
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final user = DummyData.getUserById(widget.reel.userId);
    final isCurrentUser = user?.id == DummyData.currentUser.id;

    return VisibilityDetector(
      key: Key('reel_${widget.reel.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Container(
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: user?.profileImage != null
                        ? NetworkImage(user!.profileImage)
                        : null,
                    backgroundColor: AppColors.grey300,
                    child: user?.profileImage == null
                        ? const Icon(Icons.person, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? 'Unknown',
                          style: const TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (widget.reel.location != null)
                          Text(
                            widget.reel.location!,
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isCurrentUser) ...[
                    GestureDetector(
                      onTap: _toggleFollow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: user?.isFollowing == true
                              ? AppColors.grey200
                              : AppColors.blue,
                          border: user?.isFollowing == true
                              ? Border.all(color: AppColors.grey300!)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user?.isFollowing == true ? 'Following' : 'Follow',
                          style: TextStyle(
                            color: user?.isFollowing == true
                                ? AppColors.black
                                : AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: _showMoreOptions,
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.grey600,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            // Music info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.music_note, size: 16, color: AppColors.grey600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.reel.caption.length > 40
                          ? '${widget.reel.caption.substring(0, 40)}...'
                          : widget.reel.caption,
                      style: TextStyle(
                        color: AppColors.grey700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Video Container with GestureDetector overlay
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                // Store tap position for heart animation
                final RenderBox? box = context.findRenderObject() as RenderBox?;
                if (box != null) {
                  _tapPosition = box.globalToLocal(details.globalPosition);
                }
              },
              onTap: _handleTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isInitialized)
                    SizedBox(
                      width: double.infinity,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_controller),
                            // Gradient Heart Animation
                            if (_showHeartAnimation)
                              AnimatedBuilder(
                                animation: _likeAnimationController,
                                builder: (context, child) {
                                  return Positioned(
                                    left: _tapPosition.dx - 50,
                                    top:
                                        _tapPosition.dy -
                                        50 +
                                        _moveUpAnimation.value,
                                    child: Transform.rotate(
                                      angle: _wiggleAnimation.value,
                                      child: Transform.scale(
                                        scale: _scaleAnimation.value,
                                        child: Opacity(
                                          opacity: _opacityAnimation.value,
                                          child: ShaderMask(
                                            shaderCallback: (bounds) =>
                                                LinearGradient(
                                                  colors: _currentGradient,
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ).createShader(
                                                  Rect.fromLTWH(
                                                    0,
                                                    0,
                                                    bounds.width,
                                                    bounds.height,
                                                  ),
                                                ),
                                            child: const Icon(
                                              Icons.favorite,
                                              size: 100,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 20,
                                                  color: AppColors.black54,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            // Mute Button (Bottom Right)
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: GestureDetector(
                                onTap: _toggleMute,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.black.withValues(
                                      alpha: 0.5,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.reel.isMuted
                                        ? Icons.volume_off
                                        : Icons.volume_up,
                                    color: AppColors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            // Volume Indicator
                            if (_showVolumeIndicator)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.reel.isMuted
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  color: AppColors.white,
                                  size: 28,
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.grey200,
                      height: 400,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
            // Action buttons - Save button moved to right
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Icon(
                          widget.reel.isLiked
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: widget.reel.isLiked
                              ? AppColors.red
                              : AppColors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _openComments,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset(
                            'assets/Icons/comment_icon_outline.svg',
                            colorFilter: const ColorFilter.mode(
                              AppColors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _handleRepost,
                        child: Icon(
                          Icons.repeat,
                          color: widget.reel.isReposted
                              ? AppColors.green
                              : AppColors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _openShare,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset(
                            'assets/Icons/share_icon_outline.svg',
                            colorFilter: const ColorFilter.mode(
                              AppColors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Save button on the right
                  GestureDetector(
                    onTap: _toggleSave,
                    child: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.black,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatCount(widget.reel.likes)} likes',
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.reel.caption,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _openComments,
                    child: Text(
                      'View all ${_formatCount(widget.reel.comments)} comments',
                      style: TextStyle(color: AppColors.grey600, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
