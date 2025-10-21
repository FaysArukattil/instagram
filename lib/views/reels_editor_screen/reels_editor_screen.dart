import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/reel_model.dart';

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

  void _shareReel() async {
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

    // 💾 SAVE TO SHARED PREFERENCES
    await DummyData.saveUserReels();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reel posted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New reel', style: TextStyle(color: AppColors.black)),
        actions: [
          TextButton(
            onPressed: _shareReel,
            child: const Text(
              'Share',
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 400,
              color: AppColors.black12,
              child: const Center(
                child: Icon(
                  Icons.play_arrow,
                  size: 100,
                  color: AppColors.black54,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
