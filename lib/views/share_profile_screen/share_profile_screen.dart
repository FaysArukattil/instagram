import 'package:flutter/material.dart';

class ShareProfileScreen extends StatefulWidget {
  final String username;
  const ShareProfileScreen({super.key, required this.username});

  @override
  State<ShareProfileScreen> createState() => _ShareProfileScreenState();
}

class _ShareProfileScreenState extends State<ShareProfileScreen> {
  // Background gradients (similar to Instagram styles)
  final List<List<Color>> gradients = [
    [Colors.black, Colors.black],
    [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
    [const Color(0xFFFF5F6D), const Color(0xFFFFC371)],
  ];

  int _currentGradientIndex = 0;

  void _changeGradient() {
    setState(() {
      _currentGradientIndex =
          (_currentGradientIndex + 1) % gradients.length; // cycle through
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeGradient,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradients[_currentGradientIndex],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "COLOUR",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                fontSize: 15,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // White rounded QR container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fake QR (simple icon placeholder)
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code_2_rounded,
                            size: 140,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Bottom buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBottomButton(
                      icon: Icons.share_outlined,
                      label: "Share profile",
                      onTap: () {
                        _showSnack(context, "Share profile clicked");
                      },
                    ),
                    const SizedBox(width: 30),
                    _buildBottomButton(
                      icon: Icons.link,
                      label: "Copy link",
                      onTap: () {
                        _showSnack(context, "Link copied!");
                      },
                    ),
                    const SizedBox(width: 30),
                    _buildBottomButton(
                      icon: Icons.download_outlined,
                      label: "Download",
                      onTap: () {
                        _showSnack(context, "Downloaded successfully!");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
