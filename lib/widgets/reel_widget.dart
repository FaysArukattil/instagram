import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/views/reels_screen/reels_screen.dart';
import 'package:instagram/views/commentscreen/commentscreen.dart';
import 'package:instagram/views/share_bottom_sheet/share_bottom_sheet.dart';
import 'dart:io';

class ReelWidget extends StatefulWidget {
  final ReelModel reel;
  final VoidCallback? onReelUpdated;
  final bool isVisible;

  const ReelWidget({
    super.key,
    required this.reel,
    this.onReelUpdated,
    this.isVisible = true,
  });

  @override
  State<ReelWidget> createState() => _ReelWidgetState();
}

class _ReelWidgetState extends State<ReelWidget>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showVolumeIndicator = false;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _isPausedByUser = false;
  bool _showHeartAnimation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _likeAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  Future<void> _initializeVideo() async {
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
      _controller.setLooping(true);

      widget.reel.isMuted = false;
      _controller.setVolume(1);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        if (widget.isVisible && !_isPausedByUser) {
          _controller.play();
        }
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
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
      if (_isInitialized && widget.isVisible && !_isPausedByUser) {
        _controller.play();
      }
    }
  }

  @override
  void didUpdateWidget(ReelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.reel.id != oldWidget.reel.id) {
      _controller.dispose();
      _isInitialized = false;
      _initializeVideo();
      return;
    }

    if (widget.isVisible && !oldWidget.isVisible) {
      if (!_isPausedByUser) {
        _controller.play();
      }
    } else if (!widget.isVisible && oldWidget.isVisible) {
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

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showVolumeIndicator = false;
        });
      }
    });
  }

  void _toggleLike() {
    setState(() {
      widget.reel.isLiked = !widget.reel.isLiked;
      widget.reel.likes += widget.reel.isLiked ? 1 : -1;
    });
    widget.onReelUpdated?.call();
  }

  void _handleDoubleTapLike() {
    if (!widget.reel.isLiked) {
      setState(() {
        widget.reel.isLiked = true;
        widget.reel.likes++;
        _showHeartAnimation = true;
      });
      widget.onReelUpdated?.call();

      _likeAnimationController.forward(from: 0.0).then((_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _showHeartAnimation = false;
            });
          }
        });
      });
    }
  }

  void _openComments() {
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
      _isPausedByUser = false;
      if (widget.isVisible && mounted) {
        _controller.play();
      }
      setState(() {
        widget.reel.comments = DummyData.getCommentsForPost(
          widget.reel.id,
        ).length;
      });
      widget.onReelUpdated?.call();
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
    widget.onReelUpdated?.call();
  }

  void _openShare() {
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
      builder: (context) => ShareBottomSheet(post: tempPost),
    ).then((_) {
      _isPausedByUser = false;
      if (widget.isVisible && mounted) {
        _controller.play();
      }
    });
  }

  void _openReelScreen() {
    final reelIndex = DummyData.reels.indexWhere((r) => r.id == widget.reel.id);
    if (reelIndex != -1) {
      // Store the current playback position
      final currentPosition = _controller.value.position;

      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPausedByUser = true;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReelsScreen(
            initialIndex: reelIndex,
            isVisible: true,
            disableShuffle: true,
            startPosition: currentPosition,
          ),
        ),
      ).then((_) {
        _isPausedByUser = false;
        if (mounted && widget.isVisible) {
          _controller.play();
        }
        widget.onReelUpdated?.call();
      });
    }
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
      if (widget.isVisible && mounted) {
        _controller.play();
      }
    });
  }

  Widget _buildMoreOptionsSheet() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
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
              const SizedBox(height: 20),
              _buildMoreOption(Icons.bookmark_outline, 'Save', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved to collection')),
                );
              }),
              _buildMoreOption(Icons.repeat, 'Remix', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Remix feature coming soon')),
                );
              }),
              _buildMoreOption(Icons.qr_code, 'QR code', () {
                Navigator.pop(context);
              }),
              const Divider(height: 16),
              _buildMoreOption(
                Icons.not_interested_outlined,
                'Not interested',
                () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('We\'ll show you less like this'),
                    ),
                  );
                },
              ),
              _buildMoreOption(Icons.person_outline, 'About this account', () {
                Navigator.pop(context);
              }),
              _buildMoreOption(Icons.info_outline, 'AI info', () {
                Navigator.pop(context);
              }),
              const Divider(height: 16),
              _buildMoreOption(Icons.flag_outlined, 'Report', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted')),
                );
              }, isDestructive: true),
              _buildMoreOption(
                Icons.tune_outlined,
                'Manage content preferences',
                () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
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
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.black,
        size: 22,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
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

  @override
  Widget build(BuildContext context) {
    final user = DummyData.getUserById(widget.reel.userId);

    return GestureDetector(
      onDoubleTap: _handleDoubleTapLike,
      onTap: _openReelScreen,
      child: Container(
        color: Colors.white,
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
                    backgroundColor: Colors.grey[300],
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
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (widget.reel.location != null)
                          Text(
                            widget.reel.location!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showMoreOptions,
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
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
                  Icon(Icons.music_note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.reel.caption.length > 40
                          ? '${widget.reel.caption.substring(0, 40)}...'
                          : widget.reel.caption,
                      style: TextStyle(
                        color: Colors.grey[700],
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
            // Video Container
            Stack(
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
                          // Heart Animation
                          if (_showHeartAnimation && _likeAnimation.value > 0)
                            AnimatedBuilder(
                              animation: _likeAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _likeAnimation.value,
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 80,
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
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.reel.isMuted
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  color: Colors.white,
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
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.reel.isMuted
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey[200],
                    height: 400,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
            // Action buttons
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
                              ? Colors.red
                              : Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _openComments,
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _handleRepost,
                        child: Icon(
                          Icons.repeat,
                          color: widget.reel.isReposted
                              ? Colors.green
                              : Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _openShare,
                        child: const Icon(
                          Icons.send,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ],
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
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.reel.caption,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _openComments,
                    child: Text(
                      'View all ${_formatCount(widget.reel.comments)} comments',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
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
