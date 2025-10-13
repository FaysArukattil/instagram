import 'package:flutter/material.dart';
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
