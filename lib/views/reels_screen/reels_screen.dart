import 'package:flutter/material.dart';
import 'package:instagram/views/reels_screen/reelscommentscreen.dart';
import 'package:instagram/views/reels_screen/reelssharebottomsheet.dart';
import 'package:video_player/video_player.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';

class ReelsScreen extends StatefulWidget {
  final int initialIndex;
  final VoidCallback? onRefresh;

  const ReelsScreen({super.key, this.initialIndex = 0, this.onRefresh});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  int _currentIndex = 0;
  List<ReelModel> reels = []; // Initialize as empty list
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
    // Pause video when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Videos will auto-pause through their lifecycle management
    } else if (state == AppLifecycleState.resumed) {
      // Videos will auto-resume through their lifecycle management
    }
  }

  void _loadReels({bool shuffle = false}) {
    if (!mounted) return;

    // Get current reel ID if exists
    String? currentReelId;
    if (reels.isNotEmpty &&
        _currentIndex >= 0 &&
        _currentIndex < reels.length) {
      currentReelId = reels[_currentIndex].id;
    }

    setState(() {
      reels = List.from(DummyData.reels);
      if (shuffle) {
        reels.shuffle();

        // Keep shuffling until first reel is different
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
    // When widget key changes (tab tapped), shuffle and reset
    if (widget.key != oldWidget.key) {
      _screenId = DateTime.now().millisecondsSinceEpoch.toString();
      _loadReels(shuffle: true);
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
        physics:
            const ClampingScrollPhysics(), // Enable smooth vertical swiping
        itemBuilder: (context, index) {
          return ReelItem(
            key: ValueKey(
              '${reels[index].id}_$_screenId',
            ), // Unique key with screen ID
            reel: reels[index],
            isActive: index == _currentIndex,
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
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showVolumeIndicator = false;
  bool _showLikeAnimation = false;
  bool _isLongPressing = false;
  bool _isPausedByUser = false;

  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();

    // Like animation setup
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
    // Subscribe to route changes
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Will pause when navigating away
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause video when app goes to background or inactive
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isInitialized && _controller.value.isPlaying) {
        _controller.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume only if this reel is active and not paused by user
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

    // If the reel changed (different video), reinitialize
    if (widget.reel.id != oldWidget.reel.id ||
        widget.reel.videoUrl != oldWidget.reel.videoUrl) {
      _controller.pause();
      _controller.dispose();
      _isInitialized = false;
      _initializeVideo();
      return;
    }

    // Otherwise just handle play/pause
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

    // Hide indicator after 800ms
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showVolumeIndicator = false;
        });
      }
    });
  }

  void _handleDoubleTap() {
    // Always show the animation
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

    // Only actually like if not already liked
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
    // Pause video when opening comments
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
      // Resume video when comments are closed
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
        // Undo repost
        widget.reel.isReposted = false;
        widget.reel.shares--;
        DummyData.removeRepost(widget.reel.id, DummyData.currentUser.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from your profile'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.grey,
          ),
        );
      } else {
        // Add repost
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
    // Pause video when opening share sheet
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
      // Resume video when share sheet is closed
      _isPausedByUser = false;
      if (widget.isActive && mounted) {
        _controller.play();
      }
    });
  }

  void _showMoreOptions() {
    // Pause video when opening more options
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
      // Resume video when options are closed
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
      // Pause video when navigating to profile
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPausedByUser = true;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfileScreen(user: user)),
      ).then((_) {
        // Resume video when returning from profile
        _isPausedByUser = false;
        if (widget.isActive && mounted) {
          _controller.play();
        }
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
    final user = DummyData.getUserById(widget.reel.userId);

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
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player - Full screen
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

          // Gradient overlays
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

          // Volume indicator - centered and bigger
          if (_showVolumeIndicator)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.reel.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

          // Like animation - centered heart
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

          // Long press pause indicator
          if (_isLongPressing)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pause, color: Colors.white, size: 40),
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
                // User info
                GestureDetector(
                  onTap: _openProfile,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(user?.profileImage ?? ''),
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
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user?.isFollowing == true ? 'Following' : 'Follow',
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
                // Caption
                Text(
                  widget.reel.caption,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
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

          // Right side actions
          Positioned(
            bottom: 20,
            right: 12,
            child: Column(
              children: [
                // Like button
                GestureDetector(
                  onTap: _toggleLike,
                  child: Column(
                    children: [
                      Icon(
                        widget.reel.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.reel.isLiked ? Colors.red : Colors.white,
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

                // Comment button
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

                // Repost button (with undo functionality)
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

                // Share button
                GestureDetector(
                  onTap: _showShareSheet,
                  child: const Column(
                    children: [Icon(Icons.send, color: Colors.white, size: 28)],
                  ),
                ),
                const SizedBox(height: 24),

                // More options (three dots)
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
