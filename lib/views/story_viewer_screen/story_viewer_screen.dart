// lib/views/story_viewer_screen/story_viewer_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/story_model.dart';
import 'package:instagram/models/user_model.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentUserIndex;
  int _currentImageIndex = 0;

  // Controls the "fill" of the current top indicator (0.0..1.0)
  late AnimationController _progressController;
  static const Duration storyDuration = Duration(seconds: 5);

  // vertical drag for interactive dismiss
  double _verticalDrag = 0.0;
  bool _isDismissing = false;

  // prevent double transitions
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialIndex.clamp(0, widget.stories.length - 1);
    _pageController = PageController(initialPage: _currentUserIndex);

    _progressController =
        AnimationController(vsync: this, duration: storyDuration)
          ..addListener(() {
            // redraw progress bars
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _onProgressComplete();
            }
          });

    _startProgress();
  }

  void _startProgress() {
    // restart the progress for the current image
    if (mounted) {
      _progressController.stop();
      _progressController.reset();
      _progressController.forward();
    }
  }

  void _pauseProgress() {
    _progressController.stop();
  }

  void _resumeProgress() {
    if (!_progressController.isAnimating) {
      _progressController.forward();
    }
  }

  void _onProgressComplete() {
    // advance to next image or next user
    final story = widget.stories[_currentUserIndex];
    if (_currentImageIndex < story.images.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
      _startProgress();
    } else {
      _goToNextUserOrClose();
    }
  }

  void _goToNextUserOrClose() {
    if (_isTransitioning) return;
    if (_currentUserIndex < widget.stories.length - 1) {
      _isTransitioning = true;
      _pageController
          .nextPage(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
          )
          .whenComplete(() {
            // onPageChanged will reset indices and progress
            _isTransitioning = false;
          });
    } else {
      Navigator.pop(context);
    }
  }

  void _goToPreviousUserOrClose() {
    if (_isTransitioning) return;
    if (_currentUserIndex > 0) {
      _isTransitioning = true;
      _pageController
          .previousPage(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
          )
          .whenComplete(() {
            _isTransitioning = false;
          });
    } else {
      Navigator.pop(context);
    }
  }

  // Tap handlers (instant image navigation)
  void _onTapAtPosition(Offset localPosition, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (localPosition.dx < width / 2) {
      // left side tap
      if (_currentImageIndex > 0) {
        setState(() => _currentImageIndex--);
        _startProgress();
      } else {
        // go to previous user
        _goToPreviousUserOrClose();
      }
    } else {
      // right side tap
      final story = widget.stories[_currentUserIndex];
      if (_currentImageIndex < story.images.length - 1) {
        setState(() => _currentImageIndex++);
        _startProgress();
      } else {
        _goToNextUserOrClose();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Interactive vertical dismiss animation helper
  Future<void> _performDismissAnimation(double screenHeight) async {
    if (_isDismissing) return;
    _isDismissing = true;
    // animate the container off-screen downwards
    setState(() {
      _verticalDrag = screenHeight;
    });
    await Future.delayed(const Duration(milliseconds: 220));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final story = widget.stories[_currentUserIndex];
    final UserModel? user = DummyData.getUserById(story.userId);

    // compute opacity during vertical drag: 1 -> 0.5 approx
    final double opacity = (1 - (_verticalDrag.abs() / (screenHeight * 0.9)))
        .clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,

        // Taps left/right for image navigation (instant)
        onTapUp: (details) => _onTapAtPosition(details.localPosition, context),

        // long press to pause/resume
        onLongPressStart: (_) {
          _pauseProgress();
        },
        onLongPressEnd: (_) {
          _resumeProgress();
        },

        // vertical drag for dismiss
        onVerticalDragUpdate: (details) {
          // only allow downward drag
          if (details.delta.dy > 0) {
            _pauseProgress();
            setState(() {
              _verticalDrag += details.delta.dy;
              // cap to screen height
              if (_verticalDrag > screenHeight) _verticalDrag = screenHeight;
            });
          }
        },
        onVerticalDragEnd: (details) {
          if (_verticalDrag > 140) {
            // dismiss with animation
            _performDismissAnimation(screenHeight);
          } else {
            // bounce back
            setState(() {
              _verticalDrag = 0;
            });
            _resumeProgress();
          }
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _verticalDrag, 0),
          child: Opacity(
            opacity: opacity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.stories.length,
              onPageChanged: (int newIndex) {
                // reset indices when page changes
                setState(() {
                  _currentUserIndex = newIndex;
                  _currentImageIndex = 0;
                });
                // restart progress for new page
                _progressController.reset();
                _startProgress();
              },
              itemBuilder: (context, pageIndex) {
                final StoryModel pageStory = widget.stories[pageIndex];
                final images = pageStory.images;
                // If this page is the active one use _currentImageIndex, else show first image
                final int displayImageIndex = (pageIndex == _currentUserIndex)
                    ? _currentImageIndex.clamp(0, images.length - 1)
                    : 0;
                final String imageUrl = images[displayImageIndex];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // image (cover entire screen)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.black,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    // top indicators (animated)
                    Positioned(
                      top: 40,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: List.generate(images.length, (i) {
                          double value;
                          if (pageIndex != _currentUserIndex) {
                            // other pages show no progress (or 0)
                            value = (i == 0)
                                ? 1.0
                                : 0.0; // show first filled for inactive? choose 0 for all if you prefer
                            // We'll show 0 for all so they look empty when not active:
                            value = 0.0;
                          } else {
                            if (i < _currentImageIndex) {
                              value = 1.0;
                            } else if (i == _currentImageIndex) {
                              value = _progressController.value;
                            } else {
                              value = 0.0;
                            }
                          }
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  minHeight: 3,
                                  value: value,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.25,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // user info (avatar, name, time)
                    if (user != null)
                      Positioned(
                        top: 52,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(user.profileImage),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  pageStory.timeAgo,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
