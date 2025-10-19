import 'package:flutter/material.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/views/reels_screen/reelscommentscreen.dart';
import 'package:instagram/views/reels_screen/reelssharebottomsheet.dart';
import 'package:video_player/video_player.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';
import 'package:instagram/views/add_post_screen/add_post_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class ReelsScreen extends StatefulWidget {
  final int initialIndex;
  final VoidCallback? onRefresh;
  final bool isVisible;
  final bool disableShuffle;
  final Duration? startPosition;
  final String? userId;
  final List<ReelModel>? specificReels;
  final bool showFriendsOnly;
  final ValueChanged<bool>? onFriendsToggle;

  const ReelsScreen({
    super.key,
    this.initialIndex = 0,
    this.onRefresh,
    this.isVisible = true,
    this.disableShuffle = false,
    this.startPosition,
    this.userId,
    this.specificReels,
    this.showFriendsOnly = false,
    this.onFriendsToggle,
  });

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  int _currentIndex = 0;
  List<ReelModel> reels = [];
  String _screenId = '';
  late bool _showFriendsOnly;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screenId = DateTime.now().millisecondsSinceEpoch.toString();
    _showFriendsOnly = widget.showFriendsOnly;
    _loadReels(shuffle: !widget.disableShuffle);
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Videos will auto-pause
    } else if (state == AppLifecycleState.resumed) {
      // Videos will auto-resume
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
      if (widget.specificReels != null) {
        reels = List.from(widget.specificReels!);
      } else if (widget.userId != null) {
        reels = DummyData.reels
            .where((reel) => reel.userId == widget.userId)
            .toList();
      } else {
        reels = List.from(DummyData.reels);

        if (_showFriendsOnly) {
          reels = reels.where((reel) {
            final user = DummyData.getUserById(reel.userId);
            return user != null && user.isFollowing;
          }).toList();
        }
      }

      for (var reel in reels) {
        reel.isReposted = DummyData.hasUserReposted(
          reel.id,
          DummyData.currentUser.id,
        );
      }

      if (shuffle) {
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
    if (widget.key != oldWidget.key ||
        widget.showFriendsOnly != oldWidget.showFriendsOnly) {
      _screenId = DateTime.now().millisecondsSinceEpoch.toString();
      _showFriendsOnly = widget.showFriendsOnly;
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

  void _openAddPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPostScreen(),
        fullscreenDialog: true,
      ),
    ).then((_) {
      _loadReels(shuffle: !widget.disableShuffle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (_showFriendsOnly) {
                  widget.onFriendsToggle?.call(false);
                }
              },
              child: Text(
                'Reels',
                style: TextStyle(
                  color: !_showFriendsOnly ? Colors.white : Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: () {
                if (!_showFriendsOnly) {
                  widget.onFriendsToggle?.call(true);
                }
              },
              child: Text(
                'Friends',
                style: TextStyle(
                  color: _showFriendsOnly ? Colors.white : Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.add_outlined, color: Colors.white, size: 28),
          onPressed: _openAddPost,
        ),
      ),
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
            startPosition: index == _currentIndex ? widget.startPosition : null,
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
  final Duration? startPosition;

  const ReelItem({
    super.key,
    required this.reel,
    required this.isActive,
    required this.onReelUpdated,
    this.startPosition,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  UserModel? _cachedUser;
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showLikeAnimation = false;
  bool _isLongPressing = false;
  bool _isPausedByUser = false;
  bool _isSeeking = false;
  double _playbackSpeed = 1.0;
  bool _isLeftEdgePressed = false;
  bool _isRightEdgePressed = false;
  Duration? _seekPreviewPosition;
  int _tapCount = 0;
  bool _isProcessingTap = false;
  bool _showMuteIndicator = false;
  double? _dragStartY;
  bool _isInSeekingArea = false;

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
    try {
      if (widget.reel.videoUrl.startsWith('http') ||
          widget.reel.videoUrl.startsWith('https')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.reel.videoUrl),
        )..setLooping(true);
      } else if (widget.reel.videoUrl.startsWith('assets/')) {
        _controller = VideoPlayerController.asset(widget.reel.videoUrl)
          ..setLooping(true);
      } else {
        _controller = VideoPlayerController.file(File(widget.reel.videoUrl))
          ..setLooping(true);
      }

      await _controller.initialize();

      widget.reel.isMuted = false;
      _controller.setVolume(1);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        if (widget.startPosition != null &&
            widget.startPosition!.inMilliseconds > 0) {
          await _controller.seekTo(widget.startPosition!);
        }

        if (widget.isActive) {
          await _controller.play();
        }
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
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
      _showMuteIndicator = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showMuteIndicator = false;
        });
      }
    });
  }

  void _handleDoubleTap() {
    _tapCount = 0;
    _isProcessingTap = false;

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

  void _handleSingleTap() {
    if (_isProcessingTap) return;

    _tapCount++;
    _isProcessingTap = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_tapCount == 1 && mounted) {
        _toggleMute();
      }
      _tapCount = 0;
      _isProcessingTap = false;
    });
  }

  void _handleTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;

    if (dx > screenWidth - 80) {
      _tapCount = 0;
      _isProcessingTap = false;
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
              UserProfileScreen(user: user),
          transitionDuration: Duration.zero,
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

  void _onLongPressStart(LongPressStartDetails details, double screenWidth) {
    final dx = details.globalPosition.dx;
    final edgeThreshold = screenWidth * 0.2;

    if (dx > edgeThreshold && dx < screenWidth - edgeThreshold) {
      setState(() {
        _isLongPressing = true;
      });
      if (_controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }

  void _onLongPressEnd() {
    setState(() {
      _isLongPressing = false;
    });
    if (widget.isActive && !_isPausedByUser) {
      _controller.play();
    }
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
    final screenHeight = MediaQuery.of(context).size.height;

    _isInSeekingArea = _dragStartY! >= screenHeight - 250;

    if (_isInSeekingArea) {
      setState(() {
        _isSeeking = true;
        _seekPreviewPosition = _controller.value.position;
      });
    }
  }

  void _handleHorizontalDrag(
    DragUpdateDetails details,
    double screenWidth,
    double screenHeight,
  ) {
    if (!_isInSeekingArea || !_isSeeking) {
      return;
    }

    if (_isLeftEdgePressed || _isRightEdgePressed) {
      return;
    }

    final delta = details.delta.dx;
    final totalDuration = _controller.value.duration.inMilliseconds;
    final currentPosition =
        _seekPreviewPosition?.inMilliseconds ??
        _controller.value.position.inMilliseconds;

    final seekDelta = (delta / screenWidth) * totalDuration * 1.5;
    final newPosition = (currentPosition + seekDelta.toInt()).clamp(
      0,
      totalDuration,
    );

    setState(() {
      _seekPreviewPosition = Duration(milliseconds: newPosition.toInt());
    });
  }

  void _handleHorizontalDragEnd() {
    if (_seekPreviewPosition != null && _isInSeekingArea) {
      _controller.seekTo(_seekPreviewPosition!);
    }

    setState(() {
      _isSeeking = false;
      _seekPreviewPosition = null;
      _dragStartY = null;
      _isInSeekingArea = false;
    });
  }

  void _handleEdgePress(String edge) {
    setState(() {
      if (edge == 'left') {
        _isLeftEdgePressed = true;
      } else {
        _isRightEdgePressed = true;
      }
      _playbackSpeed = 2.0;
      _controller.setPlaybackSpeed(_playbackSpeed);
    });
  }

  void _handleEdgeRelease() {
    setState(() {
      _isLeftEdgePressed = false;
      _isRightEdgePressed = false;
      _playbackSpeed = 1.0;
      _controller.setPlaybackSpeed(1.0);
    });
  }

  void _handleProgressBarTap(TapDownDetails details, double screenWidth) {
    if (!_isInitialized) return;

    final dx = details.localPosition.dx;
    final progress = (dx / screenWidth).clamp(0.0, 1.0);
    final duration = _controller.value.duration;
    final newPosition = duration * progress;

    _controller.seekTo(newPosition);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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
    final user = _cachedUser ?? DummyData.getUserById(widget.reel.userId);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Listener(
      onPointerDown: (event) {
        final dx = event.position.dx;
        final edgeThreshold = screenWidth * 0.2;

        if (dx < edgeThreshold) {
          _handleEdgePress('left');
        } else if (dx > screenWidth - edgeThreshold) {
          _handleEdgePress('right');
        }
      },
      onPointerUp: (event) {
        if (_isLeftEdgePressed || _isRightEdgePressed) {
          _handleEdgeRelease();
        }
      },
      onPointerCancel: (event) {
        if (_isLeftEdgePressed || _isRightEdgePressed) {
          _handleEdgeRelease();
        }
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTap: _handleSingleTap,
        onDoubleTap: _handleDoubleTap,
        onLongPressStart: (details) => _onLongPressStart(details, screenWidth),
        onLongPressEnd: (_) => _onLongPressEnd(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: _isInitialized
                      ? VideoPlayer(_controller)
                      : const SizedBox.expand(
                          child: ColoredBox(color: Colors.black),
                        ),
                ),
              ),
            ),
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
              height: 250,
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
            if (_showMuteIndicator)
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
            if (_playbackSpeed != 1.0)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${_playbackSpeed}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (_isSeeking && _seekPreviewPosition != null)
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDuration(_seekPreviewPosition!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 80,
              height: 250,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: _handleHorizontalDragStart,
                onHorizontalDragUpdate: (details) =>
                    _handleHorizontalDrag(details, screenWidth, screenHeight),
                onHorizontalDragEnd: (_) => _handleHorizontalDragEnd(),
                onTap: () {},
                child: Container(color: Colors.transparent),
              ),
            ),
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
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: SvgPicture.asset(
                            'assets/Icons/comment_icon_outline.svg',
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
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
                    child: Column(
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: SvgPicture.asset(
                            'assets/Icons/share_icon_outline.svg',
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomVideoProgressIndicator(
                  controller: _controller,
                  seekPreviewPosition: _seekPreviewPosition,
                  onTap: (details) =>
                      _handleProgressBarTap(details, screenWidth),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomVideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController controller;
  final Duration? seekPreviewPosition;
  final void Function(TapDownDetails)? onTap;

  const CustomVideoProgressIndicator({
    super.key,
    required this.controller,
    this.seekPreviewPosition,
    this.onTap,
  });

  @override
  State<CustomVideoProgressIndicator> createState() =>
      _CustomVideoProgressIndicatorState();
}

class _CustomVideoProgressIndicatorState
    extends State<CustomVideoProgressIndicator> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateState);
  }

  @override
  void didUpdateWidget(CustomVideoProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_updateState);
      widget.controller.addListener(_updateState);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.controller.value.duration.inMilliseconds;
    if (duration == 0) {
      return const SizedBox.shrink();
    }

    final position =
        widget.seekPreviewPosition?.inMilliseconds ??
        widget.controller.value.position.inMilliseconds;
    final progress = position / duration;

    return GestureDetector(
      onTapDown: widget.onTap,
      child: Container(
        height: 20,
        margin: const EdgeInsets.only(bottom: 2),
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 2,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 2,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 2,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
