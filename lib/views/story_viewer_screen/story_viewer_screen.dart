import 'dart:async';
import 'package:flutter/material.dart';
import 'package:instagram/models/story_model.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StoryViewerScreenState createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late PageController _pageController;
  int _currentUserIndex = 0;
  int _currentStoryIndex = 0;
  bool _isPaused = false;
  Timer? _timer;
  double _progress = 0.0;

  double _dragOffsetY = 0.0;

  static const storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentUserIndex);
    _startStoryTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startStoryTimer() {
    _timer?.cancel();
    _progress = 0.0;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPaused) {
        setState(() {
          _progress += 50 / storyDuration.inMilliseconds;
          if (_progress >= 1) {
            _progress = 1;
            _nextStory();
          }
        });
      }
    });
  }

  void _nextStory() {
    final currentUser = widget.stories[_currentUserIndex];
    if (_currentStoryIndex < currentUser.images.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _progress = 0.0;
      });
      _startStoryTimer();
    } else {
      _nextUser();
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _progress = 0.0;
      });
      _startStoryTimer();
    } else {
      _previousUser();
    }
  }

  void _nextUser() {
    if (_currentUserIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousUser() {
    if (_currentUserIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildProgressBars(StoryModel currentUser) {
    return Positioned(
      top: 40,
      left: 8,
      right: 8,
      child: Row(
        children: List.generate(currentUser.images.length, (index) {
          double value;
          if (index < _currentStoryIndex) {
            value = 1;
          } else if (index == _currentStoryIndex) {
            value = _progress;
          } else {
            value = 0;
          }
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserInfo(StoryModel currentUser) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(currentUser.profileImageUrl),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentUser.username, // 👈 name
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                currentUser.timeAgo, // 👈 time
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPage(StoryModel currentUser) {
    final safeIndex = _currentStoryIndex.clamp(
      0,
      currentUser.images.length - 1,
    );
    final currentImage = currentUser.images[safeIndex];

    return GestureDetector(
      // Tap zones
      onTapUp: (details) {
        final width = MediaQuery.of(context).size.width;
        if (details.localPosition.dx > width / 2) {
          _nextStory();
        } else {
          _previousStory();
        }
      },
      // Pause on hold
      onLongPressStart: (_) => setState(() => _isPaused = true),
      onLongPressEnd: (_) => setState(() => _isPaused = false),
      // Swipe down to dismiss
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffsetY += details.delta.dy;
        });
      },
      onVerticalDragEnd: (details) {
        if (_dragOffsetY > 150) {
          Navigator.pop(context);
        } else {
          setState(() {
            _dragOffsetY = 0.0;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(0, _dragOffsetY, 0),
        curve: Curves.easeOut,
        child: Opacity(
          opacity: (1 - (_dragOffsetY.abs() / 300)).clamp(0.0, 1.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                currentImage,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              ),
              _buildProgressBars(currentUser),
              _buildUserInfo(currentUser),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.stories.length,
        onPageChanged: (index) {
          setState(() {
            _currentUserIndex = index;
            _currentStoryIndex = 0;
            _progress = 0.0;
          });
          _startStoryTimer();
        },
        itemBuilder: (context, index) {
          return _buildStoryPage(widget.stories[index]);
        },
      ),
    );
  }
}
