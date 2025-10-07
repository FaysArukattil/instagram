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
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95,
    );
    if (image != null && mounted) {
      _navigateToEditor(image.path, isNetwork: false);
    }
  }

  Future<void> _pickFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 95);
    // ignore: unnecessary_null_comparison
    if (images != null && images.isNotEmpty) {
      final List<String> paths = images.map((x) => x.path).toList();

      final myIndex = DummyData.stories.indexWhere(
        (s) => s.userId == DummyData.currentUser.id,
      );
      if (myIndex != -1) {
        DummyData.stories[myIndex].images.addAll(paths);
        final existing = DummyData.stories[myIndex];
        DummyData.stories[myIndex] = StoryModel(
          id: existing.id,
          userId: existing.userId,
          username: existing.username,
          profileImageUrl: existing.profileImageUrl,
          images: existing.images,
          timeAgo: 'Just now',
        );
      } else {
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
      if (mounted) Navigator.pop(context);
    }
  }

  void _navigateToEditor(String path, {bool isNetwork = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StoryEditorScreen(imagePath: path, isNetwork: isNetwork),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dummyImages = [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1080',
      'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=1080',
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=1080',
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1080',
    ];

    return Scaffold(
      backgroundColor: Colors.white, // ✅ white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add to story",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gallery"),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Suggestions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: dummyImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () =>
                      _navigateToEditor(dummyImages[index], isNetwork: true),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(dummyImages[index], fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
