import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';

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
        backgroundColor: AppColors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New post',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _sharePost,
            child: const Text(
              'Share',
              style: TextStyle(
                color: AppColors.blue,
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
                          color: AppColors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${widget.imagePaths.length}',
                          style: const TextStyle(
                            color: AppColors.white,
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
