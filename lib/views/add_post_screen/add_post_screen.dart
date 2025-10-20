// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/views/bottomnavbarscreens/bottomnavbarscreen.dart';
import 'package:instagram/views/post_editor_screen/posteditorscreen.dart';
import 'package:instagram/views/reels_editor_screen/reels_editor_screen.dart';
import 'package:instagram/views/story_editing_screen/story_editor_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _modes = ['Post', 'Story', 'Reel', 'Live'];

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedMedia;
  List<XFile>? _galleryImages;
  int _selectedGalleryIndex = 0;

  // Camera variables
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  FlashMode _flashMode = FlashMode.off;
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _disposeCamera();
    _clearSelection();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  void _clearSelection() {
    _selectedMedia = null;
    _galleryImages?.clear();
    _galleryImages = null;
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;

      _cameraController = CameraController(
        _cameras![_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      if (_isRecording) {
        await _cameraController!.stopVideoRecording();
        _isRecording = false;
      }
      await _cameraController!.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await _disposeCamera();
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    setState(() {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.auto;
      } else if (_flashMode == FlashMode.auto) {
        _flashMode = FlashMode.always;
      } else {
        _flashMode = FlashMode.off;
      }
    });

    await _cameraController!.setFlashMode(_flashMode);
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();

      if (mounted) {
        setState(() {
          if (_currentPage == 0) {
            // Post mode - allow multiple
            _galleryImages ??= [];
            _galleryImages!.add(photo);
            _selectedMedia = photo;
          } else {
            // Story mode - single image
            _selectedMedia = photo;
          }
        });
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _startVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isRecording) {
      // Stop recording
      try {
        final XFile video = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _selectedMedia = video;
        });
      } catch (e) {
        debugPrint('Error stopping video: $e');
      }
    } else {
      // Start recording
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        debugPrint('Error starting video: $e');
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      if (_currentPage == 2) {
        // Reel mode - pick video
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 60),
        );
        if (video != null && mounted) {
          setState(() => _selectedMedia = video);
        }
      } else if (_currentPage == 1) {
        // Story mode - single image
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );
        if (image != null && mounted) {
          setState(() => _selectedMedia = image);
        }
      } else {
        // Post mode - multiple images
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );
        if (images.isNotEmpty && mounted) {
          setState(() {
            _galleryImages = images;
            _selectedMedia = images[0];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  void _handleNext() {
    if (_selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or select media first')),
      );
      return;
    }

    if (_currentPage == 0) {
      // Post
      final images = _galleryImages != null && _galleryImages!.isNotEmpty
          ? _galleryImages!.map((e) => e.path).toList()
          : [_selectedMedia!.path];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostEditorScreen(imagePaths: images),
        ),
      ).then((_) {
        _clearSelection();
        Navigator.pop(context);
      });
    } else if (_currentPage == 1) {
      // Story
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              StoryEditorScreen(imagePath: _selectedMedia!.path),
        ),
      ).then((_) {
        _clearSelection();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBarScreen()),
        );
      });
    } else if (_currentPage == 2) {
      // Reel
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReelEditorScreen(videoPath: _selectedMedia!.path),
        ),
      ).then((_) {
        _clearSelection();
        Navigator.pop(context);
      });
    } else if (_currentPage == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live streaming coming soon!'),
          backgroundColor: AppColors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),

            // Main content
            Expanded(
              child: Stack(
                children: [
                  // Swipable content
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        _clearSelection();
                      });
                    },
                    itemCount: _modes.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          // Preview/Camera area
                          Expanded(child: _buildCameraOrPreview()),

                          // Gallery thumbnails (for Post mode with multiple images)
                          if (index == 0 &&
                              _galleryImages != null &&
                              _galleryImages!.length > 1)
                            _buildGalleryThumbnails(),
                        ],
                      );
                    },
                  ),

                  // Camera controls overlay
                  if (_selectedMedia == null) _buildCameraControls(),
                ],
              ),
            ),

            // Bottom controls
            _buildBottomControls(),

            // Bottom menu indicator
            _buildBottomMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white, size: 28),
            onPressed: () {
              _clearSelection();
              Navigator.pop(context);
            },
          ),
          Text(
            _modes[_currentPage],
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: _selectedMedia != null ? _handleNext : null,
            child: Text(
              'Next',
              style: TextStyle(
                color: _selectedMedia != null ? AppColors.blue : AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraOrPreview() {
    // If media is selected, show preview
    if (_selectedMedia != null) {
      final isVideo =
          _selectedMedia!.path.endsWith('.mp4') ||
          _selectedMedia!.path.endsWith('.mov');

      if (isVideo) {
        return Container(
          color: AppColors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam, size: 80, color: AppColors.white54),
                const SizedBox(height: 16),
                const Text(
                  'Video captured',
                  style: TextStyle(color: AppColors.white54, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      } else {
        return Image.file(
          File(_selectedMedia!.path),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildCameraPreview(),
        );
      }
    }

    // Show camera preview
    return _buildCameraPreview();
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: AppColors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final scale = size.aspectRatio * _cameraController!.value.aspectRatio;

    return ClipRect(
      child: Transform.scale(
        scale: scale < 1 ? 1 / scale : scale,
        child: Center(child: CameraPreview(_cameraController!)),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flash control
            _buildControlButton(
              icon: _flashMode == FlashMode.off
                  ? Icons.flash_off
                  : _flashMode == FlashMode.auto
                  ? Icons.flash_auto
                  : Icons.flash_on,
              onTap: _toggleFlash,
            ),

            const Spacer(),

            // Settings (placeholder)
            _buildControlButton(icon: Icons.settings, onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: .5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: 26),
      ),
    );
  }

  Widget _buildBottomControls() {
    if (_selectedMedia != null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          GestureDetector(
            onTap: _pickFromGallery,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.photo_library, color: AppColors.white),
            ),
          ),

          // Capture button
          GestureDetector(
            onTap: _currentPage == 2 ? _startVideoRecording : _capturePhoto,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 4),
              ),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                  color: _isRecording ? AppColors.red : AppColors.white,
                  borderRadius: _isRecording ? BorderRadius.circular(8) : null,
                ),
              ),
            ),
          ),

          // Switch camera button
          GestureDetector(
            onTap: _switchCamera,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.flip_camera_ios, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryThumbnails() {
    return Container(
      height: 80,
      color: AppColors.black,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: _galleryImages!.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedGalleryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedGalleryIndex = index;
                _selectedMedia = _galleryImages![index];
              });
            },
            child: Container(
              width: 64,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.blue : AppColors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(_galleryImages![index].path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomMenu() {
    return Container(
      height: 80,
      color: AppColors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mode indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_modes.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.3),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Current mode label
          Text(
            _modes[_currentPage].toUpperCase(),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
