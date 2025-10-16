import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram/widgets/universal_image.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePreviewScreen extends StatelessWidget {
  final String imagePath;
  final String username;
  final String profileLink;

  const ProfilePreviewScreen({
    super.key,
    required this.imagePath,
    required this.username,
    required this.profileLink,
  });

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
                  Share.share(profileLink);
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
                  await Clipboard.setData(ClipboardData(text: profileLink));
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
                  _showQRCode(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.qr_code_2_outlined,
                  color: Colors.white,
                  size: 120,
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profileLink,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Tap background to dismiss
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),

            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'profile_${username}_image',
                  child: ClipOval(
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 3.5,
                      panEnabled: false,
                      child: UniversalImage(
                        imagePath: imagePath,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons (Instagram-like)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOption(Icons.person_add, 'Following', () {}),
                    const SizedBox(width: 24),
                    _buildOption(Icons.send_outlined, 'Share', () {
                      _showShareOptions(context);
                    }),
                    const SizedBox(width: 24),
                    _buildOption(Icons.link, 'Copy link', () async {
                      await Clipboard.setData(ClipboardData(text: profileLink));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile link copied!')),
                      );
                    }),
                    const SizedBox(width: 24),
                    _buildOption(Icons.qr_code_2_outlined, 'QR', () {
                      _showQRCode(context);
                    }),
                  ],
                ),
              ],
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
