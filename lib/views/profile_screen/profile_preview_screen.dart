import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram/views/share_profile_screen/share_profile_screen.dart';
import 'package:instagram/widgets/universal_image.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePreviewScreen extends StatefulWidget {
  final String imagePath;
  final String username;
  final String profileLink;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const ProfilePreviewScreen({
    super.key,
    required this.imagePath,
    required this.username,
    required this.profileLink,
    required this.isFollowing,
    required this.onFollowToggle,
  });

  @override
  State<ProfilePreviewScreen> createState() => _ProfilePreviewScreenState();
}

class _ProfilePreviewScreenState extends State<ProfilePreviewScreen>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  double _previousScale = 1.0;
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
  }

  void _toggleFollowing() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    widget.onFollowToggle();
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text(
                  'Share profile',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  SharePlus.instance.share(ShareParams());
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: Colors.white),
                title: const Text(
                  'Copy link',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(text: widget.profileLink),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile link copied!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.qr_code_2_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Show QR Code',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ShareProfileScreen(username: widget.username),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _previousScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // Animate back to original size
    Future.delayed(Duration.zero, () {
      setState(() {
        _scale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double baseSize = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Tap outside to close
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.black.withValues(alpha: .85)),
              ),
            ),

            // ✅ Zoomable circular profile picture (returns to normal)
            Center(
              child: Hero(
                tag: 'profile_${widget.username}_image',
                child: GestureDetector(
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  child: AnimatedScale(
                    scale: _scale,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: ClipOval(
                      child: Container(
                        width: baseSize,
                        height: baseSize,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: UniversalImage(
                          imagePath: widget.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Username & options
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...[
                        _buildOption(
                          _isFollowing ? Icons.check_circle : Icons.person_add,
                          _isFollowing ? 'Following' : 'Follow',
                          _toggleFollowing,
                        ),
                        const SizedBox(width: 28),
                      ],
                      _buildOption(Icons.send_outlined, 'Share', () {
                        _showShareOptions(context);
                      }),
                      const SizedBox(width: 28),
                      _buildOption(Icons.link, 'Copy link', () async {
                        await Clipboard.setData(
                          ClipboardData(text: widget.profileLink),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile link copied!')),
                        );
                      }),
                      const SizedBox(width: 28),
                      _buildOption(Icons.qr_code_2_outlined, 'QR', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ShareProfileScreen(username: widget.username),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // Close button
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.white24,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
