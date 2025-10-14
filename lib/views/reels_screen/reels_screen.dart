import 'package:flutter/material.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/views/reels_screen/reelscommentscreen.dart';
import 'package:instagram/views/reels_screen/reelssharebottomsheet.dart';
import 'package:video_player/video_player.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';

class ReelsScreen extends StatefulWidget {
  final int initialIndex;
  final VoidCallback? onRefresh;
  final bool isVisible;
  final bool disableShuffle;

  const ReelsScreen({
    super.key,
    this.initialIndex = 0,
    this.onRefresh,
    this.isVisible = true,
    this.disableShuffle = false,
  });

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  int _currentIndex = 0;
  List<ReelModel> reels = [];
  String _screenId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screenId = DateTime.now().millisecondsSinceEpoch.toString();
    _loadReels(shuffle: true);
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Videos will auto-pause through their lifecycle management
    } else if (state == AppLifecycleState.resumed) {
      // Videos will auto-resume through their lifecycle management
    }
  }

  void _loadReels({bool shuffle = false}) {
    if (!mounted) return;

    String? currentReelId;
    if (reels.isNotEmpty &&
        _currentIndex >= 0 &&
        _currentIndex < reels.length) {
      currentReelId = reels[_currentIndex].id;
    }

    setState(() {
      reels = List.from(DummyData.reels);

      for (var reel in reels) {
        reel.isReposted = DummyData.hasUserReposted(
          reel.id,
          DummyData.currentUser.id,
        );
      }

      if (shuffle && !widget.disableShuffle) {
        reels.shuffle();

        int attempts = 0;
        while (attempts < 20 &&
            reels.isNotEmpty &&
            currentReelId != null &&
            reels[0].id == currentReelId) {
          reels.shuffle();
          attempts++;
        }
      }
    });
  }

  @override
  void didUpdateWidget(ReelsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.key != oldWidget.key) {
      _screenId = DateTime.now().millisecondsSinceEpoch.toString();
      _loadReels(shuffle: !widget.disableShuffle);
      _currentIndex = 0;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: reels.length,
        onPageChanged: _onPageChanged,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          return ReelItem(
            key: ValueKey('${reels[index].id}_$_screenId'),
            reel: reels[index],
            isActive: index == _currentIndex && widget.isVisible,
            onReelUpdated: () => setState(() {}),
          );
        },
      ),
    );
  }
}

class ReelItem extends StatefulWidget {
  final ReelModel reel;
  final bool isActive;
  final VoidCallback onReelUpdated;

  const ReelItem({
    super.key,
    required this.reel,
    required this.isActive,
    required this.onReelUpdated,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem>
    with TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  UserModel? _cachedUser;
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showVolumeIndicator = false;
  bool _showLikeAnimation = false;
  bool _isLongPressing = false;
  bool _isPausedByUser = false;

  // ✅ NEW: Swipe animation variables
  double _horizontalDragOffset = 0.0;
  bool _isDraggingHorizontally = false;

  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  void _loadUserData() {
    _cachedUser = DummyData.getUserById(widget.reel.userId);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _initializeVideo();

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _likeAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Will pause when navigating away
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isInitialized && _controller.value.isPlaying) {
        _controller.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isInitialized && widget.isActive && !_isPausedByUser) {
        _controller.play();
      }
    }
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    );

    await _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(widget.reel.isMuted ? 0 : 1);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      if (widget.isActive) {
        _controller.play();
      }
    }
  }

  @override
  void didUpdateWidget(ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadUserData();

    if (widget.reel.id != oldWidget.reel.id ||
        widget.reel.videoUrl != oldWidget.reel.videoUrl) {
      _controller.pause();
      _controller.dispose();
      _isInitialized = false;
      _initializeVideo();
      return;
    }

    if (widget.isActive && !oldWidget.isActive) {
      if (!_isPausedByUser) {
        _controller.play();
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _likeAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      widget.reel.isMuted = !widget.reel.isMuted;
      _controller.setVolume(widget.reel.isMuted ? 0 : 1);
      _showVolumeIndicator = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showVolumeIndicator = false;
        });
      }
    });
  }

  void _handleDoubleTap() {
    setState(() {
      _showLikeAnimation = true;
    });

    _likeAnimationController.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showLikeAnimation = false;
          });
        }
      });
    });

    if (!widget.reel.isLiked) {
      setState(() {
        widget.reel.isLiked = true;
        widget.reel.likes++;
      });
      widget.onReelUpdated();
    }
  }

  void _toggleLike() {
    setState(() {
      widget.reel.isLiked = !widget.reel.isLiked;
      widget.reel.likes += widget.reel.isLiked ? 1 : -1;
    });
    widget.onReelUpdated();
  }

  void _openComments() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPausedByUser = true;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReelCommentsScreen(reel: widget.reel),
    ).then((_) {
      _isPausedByUser = false;
      if (widget.isActive && mounted) {
        _controller.play();
      }
      widget.onReelUpdated();
    });
  }

  void _handleRepost() {
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
            backgroundColor: Colors.grey,
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
            backgroundColor: Colors.green,
          ),
        );
      }
    });
    widget.onReelUpdated();
  }

  void _showShareSheet() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPausedByUser = true;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReelShareBottomSheet(reel: widget.reel),
    ).then((_) {
      _isPausedByUser = false;
      if (widget.isActive && mounted) {
        _controller.play();
      }
    });
  }

  void _showMoreOptions() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPausedByUser = true;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildMoreOptionsSheet(),
    ).then((_) {
      _isPausedByUser = false;
      if (widget.isActive && mounted) {
        _controller.play();
      }
    });
  }

  Widget _buildMoreOptionsSheet() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            _buildMoreOption(Icons.bookmark_border, 'Save', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to collection')),
              );
            }),
            _buildMoreOption(Icons.qr_code, 'QR code', () {
              Navigator.pop(context);
            }),
            _buildMoreOption(Icons.link, 'Copy link', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied to clipboard')),
              );
            }),
            _buildMoreOption(Icons.share, 'Share to...', () {
              Navigator.pop(context);
              _showShareSheet();
            }),
            const Divider(),
            _buildMoreOption(Icons.person_remove_outlined, 'Unfollow', () {
              Navigator.pop(context);
            }),
            _buildMoreOption(Icons.visibility_off_outlined, 'Hide', () {
              Navigator.pop(context);
            }),
            _buildMoreOption(Icons.info_outline, 'About this account', () {
              Navigator.pop(context);
            }),
            const Divider(),
            _buildMoreOption(Icons.report_outlined, 'Report', () {
              Navigator.pop(context);
            }, isDestructive: true),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOption(
    IconData icon,
    String text,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black),
      title: Text(
        text,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  void _openProfile() {
    final user = DummyData.getUserById(widget.reel.userId);
    if (user != null) {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPausedByUser = true;
      }

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SwipeableProfileScreen(user: user),
          transitionDuration: Duration.zero, // Instant transition
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      ).then((_) {
        _isPausedByUser = false;
        if (widget.isActive && mounted) {
          _controller.play();
        }
      });
    }
  }

  // ✅ NEW: Handle horizontal drag start
  void _onHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _isDraggingHorizontally = true;
    });
  }

  // ✅ NEW: Handle horizontal drag update
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _horizontalDragOffset += details.delta.dx;
      // Limit the drag offset (negative for left swipe)
      _horizontalDragOffset = _horizontalDragOffset.clamp(
        -MediaQuery.of(context).size.width,
        0.0,
      );
    });
  }

  // ✅ NEW: Handle horizontal drag end
  void _onHorizontalDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;

    // If dragged more than 30% of screen width to the left, navigate to profile
    if (_horizontalDragOffset < -screenWidth * 0.3) {
      // Keep the offset while navigating to avoid jitter
      _openProfile();
      // Reset after navigation completes
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _horizontalDragOffset = 0.0;
            _isDraggingHorizontally = false;
          });
        }
      });
    } else {
      // Animate back to original position
      setState(() {
        _horizontalDragOffset = 0.0;
        _isDraggingHorizontally = false;
      });
    }
  }

  void _onLongPressStart() {
    setState(() {
      _isLongPressing = true;
    });
    _controller.pause();
  }

  void _onLongPressEnd() {
    setState(() {
      _isLongPressing = false;
    });
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    final user = _cachedUser ?? DummyData.getUserById(widget.reel.userId);

    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleMute,
      onDoubleTap: _handleDoubleTap,
      onLongPressStart: (_) => _onLongPressStart(),
      onLongPressEnd: (_) => _onLongPressEnd(),
      // ✅ NEW: Add horizontal drag gestures
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ NEW: Animated video container that moves with swipe
          AnimatedContainer(
            duration: _isDraggingHorizontally
                ? Duration.zero
                : const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_horizontalDragOffset, 0, 0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
                // Top gradient
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 200,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 200,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Volume indicator
                if (_showVolumeIndicator)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.reel.isMuted
                            ? Icons.volume_off
                            : Icons.volume_up,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                // Like animation
                if (_showLikeAnimation)
                  Center(
                    child: AnimatedBuilder(
                      animation: _likeAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _likeAnimation.value,
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 100,
                          ),
                        );
                      },
                    ),
                  ),
                // Long press indicator
                if (_isLongPressing)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                // Bottom info section
                Positioned(
                  bottom: 20,
                  left: 12,
                  right: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _openProfile,
                        child: Row(
                          children: [
                            CircleAvatar(
                              key: ValueKey(user?.profileImage ?? ''),
                              radius: 18,
                              backgroundImage: user?.profileImage != null
                                  ? NetworkImage(user!.profileImage)
                                  : null,
                              backgroundColor: Colors.grey[300],
                              child: user?.profileImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 18,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                user?.username ?? 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (user?.id != DummyData.currentUser.id)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  user?.isFollowing == true
                                      ? 'Following'
                                      : 'Follow',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.reel.caption,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.reel.location != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.reel.location!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Right side action buttons
                Positioned(
                  bottom: 20,
                  right: 12,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Column(
                          children: [
                            Icon(
                              widget.reel.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.reel.isLiked
                                  ? Colors.red
                                  : Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCount(widget.reel.likes),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _openComments,
                        child: Column(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCount(widget.reel.comments),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _handleRepost,
                        child: Column(
                          children: [
                            Icon(
                              Icons.repeat,
                              color: widget.reel.isReposted
                                  ? Colors.green
                                  : Colors.white,
                              size: 30,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCount(widget.reel.shares),
                              style: TextStyle(
                                color: widget.reel.isReposted
                                    ? Colors.green
                                    : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _showShareSheet,
                        child: const Column(
                          children: [
                            Icon(Icons.send, color: Colors.white, size: 28),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _showMoreOptions,
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ✅ NEW: Profile preview on the right (visible when swiping left)
          if (_horizontalDragOffset < 0)
            Positioned(
              left: MediaQuery.of(context).size.width + _horizontalDragOffset,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: UserProfileScreen(user: user!),
            ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

// ✅ NEW: Swipeable wrapper for profile screen
class SwipeableProfileScreen extends StatefulWidget {
  final UserModel user;

  const SwipeableProfileScreen({super.key, required this.user});

  @override
  State<SwipeableProfileScreen> createState() => _SwipeableProfileScreenState();
}

class _SwipeableProfileScreenState extends State<SwipeableProfileScreen> {
  double _horizontalDragOffset = 0.0;
  bool _isDraggingHorizontally = false;

  void _onHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _isDraggingHorizontally = true;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _horizontalDragOffset += details.delta.dx;
      // Only allow dragging to the right (positive values)
      _horizontalDragOffset = _horizontalDragOffset.clamp(
        0.0,
        MediaQuery.of(context).size.width,
      );
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;

    // If dragged more than 30% of screen width to the right, go back
    if (_horizontalDragOffset > screenWidth * 0.3) {
      Navigator.pop(context);
    } else {
      // Animate back to original position
      setState(() {
        _horizontalDragOffset = 0.0;
        _isDraggingHorizontally = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          // The profile screen
          AnimatedContainer(
            duration: _isDraggingHorizontally
                ? Duration.zero
                : const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_horizontalDragOffset, 0, 0),
            child: UserProfileScreen(user: widget.user),
          ),
          // Optional: Add a shadow effect on the left edge while dragging
          if (_horizontalDragOffset > 0)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: .3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
