import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/story_model.dart';
import 'package:instagram/views/story_editing_screen/story_editor_screen.dart';

class MyStoryScreen extends StatefulWidget {
  const MyStoryScreen({super.key});

  @override
  State<MyStoryScreen> createState() => _MyStoryScreenState();
}

class _MyStoryScreenState extends State<MyStoryScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        // open editor for camera image (single image)
        _navigateToEditor(image.path, isNetwork: false);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to open camera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      // allow multi-select from gallery
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
      // ignore: unnecessary_null_comparison
      if (images != null && images.isNotEmpty) {
        // Group all selected images into a single story (append if exists)
        final List<String> paths = images.map((x) => x.path).toList();

        final myStoryIndex = DummyData.stories.indexWhere(
          (s) => s.userId == DummyData.currentUser.id,
        );

        if (myStoryIndex != -1) {
          // append to existing story's images
          DummyData.stories[myStoryIndex].images.addAll(paths);
          // update timeAgo
          final existing = DummyData.stories[myStoryIndex];
          DummyData.stories[myStoryIndex] = StoryModel(
            id: existing.id,
            userId: existing.userId,
            username: existing.username,
            profileImageUrl: existing.profileImageUrl,
            images: existing.images,
            timeAgo: 'Just now',
          );
        } else {
          // create new story with all selected images
          DummyData.stories.insert(
            0,
            StoryModel(
              id: 'story_${DateTime.now().millisecondsSinceEpoch}',
              userId: DummyData.currentUser.id,
              username: DummyData.currentUser.username,
              profileImageUrl: DummyData.currentUser.profileImage,
              images: paths,
              timeAgo: 'Just now',
            ),
          );
        }

        // return to Home (so story appears immediately)
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image(s): $e');
    }
  }

  void _navigateToEditor(String imagePath, {bool isNetwork = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StoryEditorScreen(imagePath: imagePath, isNetwork: isNetwork),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF262626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text(
                  'Camera',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text(
                  'Gallery (multi-select)',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dummyImages = [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400',
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400',
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
      'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400',
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400',
      'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400',
      'https://images.unsplash.com/photo-1503264116251-35a269479413?w=400',
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add to story',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _storyCard(
                  "Templates",
                  "Add yours",
                  Colors.pink,
                  () => _showErrorSnackbar('Templates feature coming soon!'),
                ),
                _storyCard(
                  "AI images",
                  "NEW",
                  Colors.blue,
                  () => _showErrorSnackbar('AI images feature coming soon!'),
                ),
              ],
            ),
          ),

          // Recents + Select
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recents',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                TextButton(
                  onPressed: () => _showErrorSnackbar(
                    'Multi-select available via Gallery option',
                  ),
                  child: const Text(
                    'Select',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: dummyImages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => _navigateToEditor(
                    dummyImages[index - 1],
                    isNetwork: true,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      dummyImages[index - 1],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFF1C1C1C),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1C1C1C),
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyCard(String title, String tag, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.image, color: Colors.white, size: 26),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              Positioned(
                top: 6,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
