import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/views/bottomnavbarscreens/bottomnavbarscreen.dart';
import 'package:instagram/views/reels_editor_screen/reels_editor_screen.dart';
import 'package:instagram/views/story_editing_screen/story_editor_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _modes = ['Post', 'Story', 'Reel', 'Live'];

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedMedia;
  List<XFile>? _galleryImages;
  int _selectedGalleryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _clearSelection();
    super.dispose();
  }

  void _clearSelection() {
    _selectedMedia = null;
    _galleryImages?.clear();
    _galleryImages = null;
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  Future<void> _loadGalleryImages() async {
    // In a real app, you'd load recent gallery images here
    // For now, we'll wait for user selection
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      if (_currentPage == 2) {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 60),
        );
        if (video != null && mounted) {
          setState(() => _selectedMedia = video);
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );
        if (image != null && mounted) {
          setState(() => _selectedMedia = image);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleNext() {
    if (_selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select media first')),
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
        // ignore: use_build_context_synchronously
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
          // ignore: use_build_context_synchronously
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
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      });
    } else if (_currentPage == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live streaming coming soon!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),

            // Main swipable content area
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
                          // Preview area for each mode
                          Expanded(child: _buildPreviewArea()),

                          // Gallery thumbnails (for Post mode with multiple images)
                          if (index == 0 &&
                              _galleryImages != null &&
                              _galleryImages!.length > 1)
                            _buildGalleryThumbnails(),
                        ],
                      );
                    },
                  ),

                  // Fixed Camera/Gallery buttons overlay
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      ignoring: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCameraButton(
                            Icons.photo_library,
                            'Gallery',
                            _pickFromGallery,
                          ),
                          _buildCameraButton(
                            Icons.camera_alt,
                            'Camera',
                            _pickFromCamera,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () {
              _clearSelection();
              Navigator.pop(context);
            },
          ),
          Text(
            _modes[_currentPage],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: _handleNext,
            child: const Text(
              'Next',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    if (_selectedMedia != null) {
      final isVideo = _currentPage == 2;
      if (isVideo) {
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam, size: 80, color: Colors.white54),
                const SizedBox(height: 16),
                Text(
                  'Video selected',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      } else {
        return Image.file(
          File(_selectedMedia!.path),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildEmptyState(),
        );
      }
    }

    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentPage == 2 ? Icons.videocam : Icons.photo_camera,
              size: 80,
              color: Colors.white38,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateText(),
              style: const TextStyle(color: Colors.white54, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryThumbnails() {
    return Container(
      height: 80,
      color: Colors.black,
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
                  color: isSelected ? Colors.blue : Colors.transparent,
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
      color: Colors.black,
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
                      ? Colors.white
                      : Colors.white.withValues(alpha: .3),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Current mode label
          Text(
            _modes[_currentPage].toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateText() {
    switch (_currentPage) {
      case 0:
        return 'Tap to select photos\nfor your post';
      case 1:
        return 'Tap to select photo\nfor your story';
      case 2:
        return 'Tap to select video\nfor your reel';
      case 3:
        return 'Go live with\nyour followers';
      default:
        return '';
    }
  }
}

// ---------------- Post Editor ----------------
class PostEditorScreen extends StatefulWidget {
  final List<String> imagePaths;
  const PostEditorScreen({super.key, required this.imagePaths});

  @override
  State<PostEditorScreen> createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends State<PostEditorScreen> {
  final TextEditingController _captionController = TextEditingController();
  String? _location;
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _sharePost() {
    final newPost = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: DummyData.currentUser.id,
      images: widget.imagePaths,
      caption: _captionController.text.trim(),
      likes: 0,
      comments: 0,
      timeAgo: 'Just now',
      location: _location,
      isLiked: false,
    );

    DummyData.posts.insert(0, newPost);
    DummyData.currentUser.posts++;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post shared successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New post',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _sharePost,
            child: const Text(
              'Share',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image carousel
            SizedBox(
              height: 400,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.imagePaths.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(widget.imagePaths[index]),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  if (widget.imagePaths.length > 1)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${widget.imagePaths.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _captionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Write a caption...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(_location ?? 'Add location'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => setState(() => _location = 'Sample Location'),
            ),
          ],
        ),
      ),
    );
  }
}
