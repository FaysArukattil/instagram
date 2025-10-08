import 'package:flutter/material.dart';
import 'package:instagram/views/reels_screen/reelscommentscreen.dart';
import 'package:instagram/views/reels_screen/reelssharebottomsheet.dart';
import 'package:video_player/video_player.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';

class ReelsScreen extends StatefulWidget {
  final int initialIndex;

  const ReelsScreen({super.key, this.initialIndex = 0});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  late List<ReelModel> reels;

  @override
  void initState() {
    super.initState();
    reels = List.from(DummyData.reels);
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
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
        itemBuilder: (context, index) {
          return ReelItem(
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

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isMuted = true;
  bool _showVolumeIndicator = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    );

    await _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(_isMuted ? 0 : 1);

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
    if (widget.isActive && !oldWidget.isActive) {
      _controller.play();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
      _showVolumeIndicator = true;
    });

    // Hide indicator after 1 second
    Future.delayed(const Duration(milliseconds: 800), () {
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
    widget.onReelUpdated();
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReelCommentsScreen(reel: widget.reel),
    ).then((_) => widget.onReelUpdated());
  }

  void _handleRepost() {
    setState(() {
      if (widget.reel.isReposted) {
        // Undo repost
        widget.reel.isReposted = false;
        widget.reel.shares--;
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReelShareBottomSheet(reel: widget.reel),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMoreOptionsSheet(),
    );
  }

  Widget _buildMoreOptionsSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfileScreen(user: user)),
      );
    }
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
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
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
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
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
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
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
