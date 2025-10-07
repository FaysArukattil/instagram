// lib/views/story_editing_screen/story_editor_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/story_model.dart';
import 'package:instagram/views/bottomnavbarscreens/bottomnavbarscreen.dart';

class StoryEditorScreen extends StatefulWidget {
  final String imagePath;
  final bool isNetwork;

  const StoryEditorScreen({
    super.key,
    required this.imagePath,
    this.isNetwork = false,
  });

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _showTextField = false;
  String _textContent = '';
  Offset _textPosition = const Offset(0.5, 0.5);
  Color _textColor = Colors.white;
  double _textSize = 24;

  final List<Color> _colors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _toggleTextField() {
    setState(() {
      _showTextField = !_showTextField;
      if (_showTextField) {
        Future.delayed(const Duration(milliseconds: 100), () {
          // ignore: use_build_context_synchronously
          FocusScope.of(context).requestFocus(FocusNode());
        });
      }
    });
  }

  void _addText() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _textContent = _textController.text;
        _showTextField = false;
        _textController.clear();
      });
    }
  }

  void _postStory() {
    // Find or create user's story
    final userStoryIndex = DummyData.stories.indexWhere(
      (s) => s.userId == DummyData.currentUser.id,
    );

    if (userStoryIndex != -1) {
      // User already has stories, add to existing at the END
      // This ensures new stories appear after viewing old ones
      DummyData.stories[userStoryIndex].images.add(widget.imagePath);

      // Update timeAgo to "Just now" for the story collection
      final existingStory = DummyData.stories[userStoryIndex];
      final updatedStory = StoryModel(
        id: existingStory.id,
        userId: existingStory.userId,
        username: existingStory.username,
        profileImageUrl: existingStory.profileImageUrl,
        images: existingStory.images,
        timeAgo: 'Just now',
      );
      DummyData.stories[userStoryIndex] = updatedStory;
    } else {
      // Create new story for user and insert at the BEGINNING (after current user position)
      final newStory = StoryModel(
        id: 'story_${DateTime.now().millisecondsSinceEpoch}',
        userId: DummyData.currentUser.id,
        username: DummyData.currentUser.username,
        profileImageUrl: DummyData.currentUser.profileImage,
        images: [widget.imagePath],
        timeAgo: 'Just now',
      );

      // Insert at position 0 or 1 depending on if there are other stories
      if (DummyData.stories.isEmpty) {
        DummyData.stories.add(newStory);
      } else {
        DummyData.stories.insert(0, newStory);
      }
    }

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story posted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Go back to home screen (pop twice: editor + my_story_screen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBarScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image Preview
          Positioned.fill(
            child: widget.isNetwork
                ? Image.network(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  )
                : Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  ),
          ),

          // Text overlay (draggable)
          if (_textContent.isNotEmpty)
            Positioned(
              left: _textPosition.dx * size.width - 100,
              top: _textPosition.dy * size.height - 20,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _textPosition = Offset(
                      (_textPosition.dx * size.width + details.delta.dx) /
                          size.width,
                      (_textPosition.dy * size.height + details.delta.dy) /
                          size.height,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _textContent,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: _textSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.text_fields, color: Colors.white),
                    onPressed: _toggleTextField,
                  ),
                  IconButton(
                    icon: const Icon(Icons.draw, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Draw feature coming soon!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.music_note, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Music feature coming soon!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Text Input Field
          if (_showTextField)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Color picker
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _colors.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _textColor = _colors[index];
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: _colors[index],
                                shape: BoxShape.circle,
                                border: _textColor == _colors[index]
                                    ? Border.all(color: Colors.blue, width: 3)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Text input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: TextStyle(
                              color: _textColor,
                              fontSize: _textSize,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type something...',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.white),
                          onPressed: _addText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Size slider
                    Row(
                      children: [
                        const Text(
                          'A',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Expanded(
                          child: Slider(
                            value: _textSize,
                            min: 16,
                            max: 40,
                            activeColor: Colors.white,
                            onChanged: (value) {
                              setState(() {
                                _textSize = value;
                              });
                            },
                          ),
                        ),
                        const Text(
                          'A',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Bar
          if (!_showTextField)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Save to device button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.download, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Post button
                    GestureDetector(
                      onTap: _postStory,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF58529),
                              Color(0xFFDD2A7B),
                              Color(0xFF8134AF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Your story',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.send, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
