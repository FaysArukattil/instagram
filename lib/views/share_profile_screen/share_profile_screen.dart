import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class ShareProfileScreen extends StatefulWidget {
  final String username;
  const ShareProfileScreen({super.key, required this.username});

  @override
  State<ShareProfileScreen> createState() => _ShareProfileScreenState();
}

class _ShareProfileScreenState extends State<ShareProfileScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isLoading = false;

  // Instagram-like gradient backgrounds
  final List<List<Color>> gradients = [
    // Black
    [const Color(0xFF000000), const Color(0xFF000000)],

    // Classic Instagram gradient (orange-pink-purple)
    [const Color(0xFFFCAF45), const Color(0xFFFD1D1D), const Color(0xFF833AB4)],

    // Cyan to Blue
    [const Color(0xFF00F5A0), const Color(0xFF00D9F5)],

    // Green to Blue gradient
    [const Color(0xFF11998E), const Color(0xFF38EF7D)],

    // Blue to Purple
    [const Color(0xFF4158D0), const Color(0xFFC850C0)],

    // Pink to Purple
    [const Color(0xFFE100FF), const Color(0xFF7F00FF)],

    // Orange to Pink
    [const Color(0xFFFFAA00), const Color(0xFFFF6B9D)],
  ];

  int _currentGradientIndex = 0;

  void _changeGradient() {
    setState(() {
      _currentGradientIndex = (_currentGradientIndex + 1) % gradients.length;
    });
  }

  // Copy profile link to clipboard
  Future<void> _copyLink() async {
    final profileUrl = 'https://instagram.com/${widget.username}';
    await Clipboard.setData(ClipboardData(text: profileUrl));
    if (mounted) {
      _showSnack(context, 'Link copied to clipboard');
    }
  }

  // Capture QR code as image
  Future<Uint8List?> _captureQrCode() async {
    try {
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing QR code: $e');
      return null;
    }
  }

  // Share profile
  Future<void> _shareProfile() async {
    setState(() => _isLoading = true);

    try {
      final imageBytes = await _captureQrCode();
      if (imageBytes == null) {
        throw Exception('Failed to capture QR code');
      }

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Follow me on Instagram: @${widget.username}\nhttps://instagram.com/${widget.username}',
      );
    } catch (e) {
      if (mounted) {
        _showSnack(context, 'Failed to share profile');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Save to gallery using Gal
  Future<void> _saveToGallery() async {
    setState(() => _isLoading = true);

    try {
      // Request permission for Android 13+
      if (Platform.isAndroid) {
        final androidInfo = await Permission.storage.status;
        if (androidInfo.isDenied) {
          final status = await Permission.photos.request();
          if (status.isDenied) {
            if (mounted) {
              _showSnack(context, 'Storage permission denied');
            }
            return;
          }
        }
      } else if (Platform.isIOS) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          if (mounted) {
            _showSnack(context, 'Photos permission denied');
          }
          return;
        }
      }

      final imageBytes = await _captureQrCode();
      if (imageBytes == null) {
        throw Exception('Failed to capture QR code');
      }

      // Save to temporary file first
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/instagram_qr_${widget.username}.png',
      ).create();
      await file.writeAsBytes(imageBytes);

      // Save to gallery using Gal
      await Gal.putImage(file.path, album: 'Instagram QR Codes');

      if (mounted) {
        _showSnack(context, 'Saved to gallery');
      }
    } catch (e) {
      if (mounted) {
        _showSnack(context, 'Failed to save: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'COLOUR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  fontSize: 14,
                ),
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // QR Code Container
                    RepaintBoundary(
                      key: _qrKey,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Real QR Code
                            QrImageView(
                              data: 'https://instagram.com/${widget.username}',
                              version: QrVersions.auto,
                              size: 220,
                              backgroundColor: Colors.white,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: _getQrColor(),
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: _getQrColor(),
                              ),
                              errorCorrectionLevel: QrErrorCorrectLevel.H,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '@${widget.username}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Action Buttons
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBottomButton(
                            icon: Icons.share_outlined,
                            label: 'Share profile',
                            onTap: _shareProfile,
                          ),
                          _buildBottomButton(
                            icon: Icons.link,
                            label: 'Copy link',
                            onTap: _copyLink,
                          ),
                          _buildBottomButton(
                            icon: Icons.download_outlined,
                            label: 'Download',
                            onTap: _saveToGallery,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getQrColor() {
    // Return matching color for QR code based on current gradient
    final gradientColors = gradients[_currentGradientIndex];
    if (_currentGradientIndex == 0) return Colors.black;
    return gradientColors[0];
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
