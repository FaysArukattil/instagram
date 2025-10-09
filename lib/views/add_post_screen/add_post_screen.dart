import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/views/bottomnavbarscreens/bottomnavbarscreen.dart';
import 'package:instagram/views/story_editing_screen/story_editor_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final PageController _modeController = PageController(initialPage: 0);
  int _currentMode = 0; // 0: POST, 1: STORY, 2: REEL, 3: LIVE
  final List<String> _modes = ['POST', 'STORY', 'REEL', 'LIVE'];

  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages;
  XFile? _selectedVideo;

  @override
  void dispose() {
    _modeController.dispose();
    _clearSelection();
    super.dispose();
  }

  void _clearSelection() {
    _selectedImages?.clear();
    _selectedImages = null;
    _selectedVideo = null;
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      _clearSelection();

      if (_currentMode == 2) {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 60),
        );
        if (video != null && mounted) {
          setState(() {
            _selectedVideo = video;
          });
          _navigateToReelEditor();
        }
      } else {
        if (_currentMode == 1) {
          final XFile? image = await _picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1800,
            maxHeight: 1800,
            imageQuality: 85,
          );
          if (image != null && mounted) {
            setState(() {
              _selectedImages = [image];
            });
            _navigateToStoryEditor(image);
          }
        } else {
          final List<XFile> images = await _picker.pickMultiImage(
            maxWidth: 1800,
            maxHeight: 1800,
            imageQuality: 85,
          );
          if (images.isNotEmpty && mounted) {
            setState(() {
              _selectedImages = images;
            });
            if (images.length == 1) {
              _navigateToPostEditor(images[0]);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking media: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      _clearSelection();

      if (_currentMode == 2) {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 60),
        );
        if (video != null && mounted) {
          setState(() {
            _selectedVideo = video;
          });
          _navigateToReelEditor();
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.rear,
        );
        if (image != null && mounted) {
          setState(() {
            _selectedImages = [image];
          });
          if (_currentMode == 0) {
            _navigateToPostEditor(image);
          } else if (_currentMode == 1) {
            _navigateToStoryEditor(image);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error using camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToPostEditor(XFile image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostEditorScreen(imagePath: image.path),
      ),
    ).then((_) {
      _clearSelection();
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _navigateToStoryEditor(XFile image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryEditorScreen(imagePath: image.path),
      ),
    ).then((_) {
      _clearSelection();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBarScreen()),
        );
      }
    });
  }

  void _navigateToReelEditor() {
    if (_selectedVideo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReelEditorScreen(videoPath: _selectedVideo!.path),
        ),
      ).then((_) {
        _clearSelection();
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _startLiveStream() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live streaming feature coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light theme
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      _clearSelection();
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'New post',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_currentMode == 0 &&
                          _selectedImages?.isNotEmpty == true) {
                        _navigateToPostEditor(_selectedImages![0]);
                      } else if (_currentMode == 1 &&
                          _selectedImages?.isNotEmpty == true) {
                        _navigateToStoryEditor(_selectedImages![0]);
                      } else if (_currentMode == 2 && _selectedVideo != null) {
                        _navigateToReelEditor();
                      } else if (_currentMode == 3) {
                        _startLiveStream();
                      }
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Mode Selector
            SizedBox(
              height: 60,
              child: PageView.builder(
                controller: _modeController,
                onPageChanged: (index) {
                  setState(() {
                    _currentMode = index;
                    _clearSelection();
                  });
                },
                itemCount: _modes.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Text(
                      _modes[index],
                      style: TextStyle(
                        color: _currentMode == index
                            ? Colors.black
                            : Colors.grey,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _modes.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentMode == index ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Preview Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildPreviewArea(),
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: _pickImagesFromGallery,
                  ),
                  _buildActionButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: _pickFromCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    if (_selectedImages?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(_selectedImages![0].path),
          fit: BoxFit.cover,
          cacheWidth: 800,
          cacheHeight: 800,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading image',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else if (_selectedVideo != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, size: 64, color: Colors.black),
            const SizedBox(height: 16),
            Text('Video selected', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentMode == 2 ? Icons.videocam : Icons.add_photo_alternate,
              size: 64,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              _getModeHintText(),
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }
  }

  String _getModeHintText() {
    switch (_currentMode) {
      case 0:
        return 'Select photos to create a post';
      case 1:
        return 'Select a photo for your story';
      case 2:
        return 'Select a video for your reel';
      case 3:
        return 'Go live with your followers';
      default:
        return '';
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Post Editor ----------------
class PostEditorScreen extends StatefulWidget {
  final String imagePath;
  const PostEditorScreen({super.key, required this.imagePath});

  @override
  State<PostEditorScreen> createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends State<PostEditorScreen> {
  final TextEditingController _captionController = TextEditingController();
  String? _location;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _sharePost() {
    final newPost = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: DummyData.currentUser.id,
      images: [widget.imagePath],
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
            Image.file(
              File(widget.imagePath),
              width: double.infinity,
              height: 400,
              fit: BoxFit.cover,
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

// ---------------- Reel Editor ----------------
class ReelEditorScreen extends StatefulWidget {
  final String videoPath;
  const ReelEditorScreen({super.key, required this.videoPath});

  @override
  State<ReelEditorScreen> createState() => _ReelEditorScreenState();
}

class _ReelEditorScreenState extends State<ReelEditorScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _shareReel() {
    final newReel = ReelModel(
      id: 'reel_${DateTime.now().millisecondsSinceEpoch}',
      userId: DummyData.currentUser.id,
      videoUrl: widget.videoPath,
      thumbnailUrl: widget.videoPath,
      caption: _captionController.text.trim(),
      likes: 0,
      comments: 0,
      shares: 0,
      timeAgo: 'Just now',
    );

    DummyData.reels.insert(0, newReel);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reel posted successfully!'),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New reel', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: _shareReel,
            child: const Text(
              'Share',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam, size: 100, color: Colors.black),
                  const SizedBox(height: 16),
                  Text('Video: ${widget.videoPath.split('/').last}'),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'Add a caption...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
