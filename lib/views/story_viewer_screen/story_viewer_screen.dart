// lib/views/story_viewer_screen/story_viewer_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/story_model.dart';

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

  late AnimationController _progressController;
  static const Duration storyDuration = Duration(seconds: 5);

  // prevent double transitions/taps
  bool _isTransitioning = false;
  bool _tapLock = false;

  // vertical drag for dismiss
  double _verticalDrag = 0.0;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    _currentUserIndex = widget.initialIndex.clamp(0, widget.stories.length - 1);
    _pageController = PageController(initialPage: _currentUserIndex);

    _progressController =
        AnimationController(vsync: this, duration: storyDuration)
          ..addListener(() {
            if (mounted) setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _onProgressComplete();
            }
          });

    _startProgress();
  }

  void _startProgress() {
    if (!mounted) return;
    _progressController.stop();
    _progressController.reset();

    final images = _currentStoryImages;
    if (images == null || images.isEmpty) {
      // no images: advance to next user (tiny delay to let UI settle)
      Future.microtask(() => _goToNextUserOrClose());
      return;
    }

    _progressController.forward();
  }

  void _pauseProgress() {
    if (_progressController.isAnimating) _progressController.stop();
  }

  void _resumeProgress() {
    if (!_progressController.isAnimating) _progressController.forward();
  }

  List<String>? get _currentStoryImages {
    if (_currentUserIndex < 0 || _currentUserIndex >= widget.stories.length) {
      return null;
    }
    return widget.stories[_currentUserIndex].images;
  }

  void _onProgressComplete() {
    try {
      final images = _currentStoryImages;
      if (images == null || images.isEmpty) {
        _goToNextUserOrClose();
        return;
      }

      if (_currentImageIndex < images.length - 1) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1).clamp(
            0,
            images.length - 1,
          );
        });
        _startProgress();
      } else {
        _goToNextUserOrClose();
      }
    } catch (_) {
      // swallow race conditions
    }
  }

  void _onTapAtPosition(Offset localPosition, BuildContext context) {
    if (_tapLock || _isTransitioning) return;
    _tapLock = true;
    Future.delayed(const Duration(milliseconds: 120), () {
      _tapLock = false;
    });

    final width = MediaQuery.of(context).size.width;
    final images = _currentStoryImages;

    try {
      if (localPosition.dx < width / 2) {
        // left -> previous image or previous user
        if (images != null && _currentImageIndex > 0) {
          setState(() {
            _currentImageIndex = (_currentImageIndex - 1).clamp(
              0,
              images.length - 1,
            );
          });
          _startProgress();
        } else {
          _goToPreviousUserOrClose();
        }
      } else {
        // right -> next image or next user
        if (images != null && _currentImageIndex < images.length - 1) {
          setState(() {
            _currentImageIndex = (_currentImageIndex + 1).clamp(
              0,
              images.length - 1,
            );
          });
          _startProgress();
        } else {
          _goToNextUserOrClose();
        }
      }
    } catch (_) {
      // swallow race conditions
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
            _isTransitioning = false;
          });
    } else {
      if (mounted) Navigator.pop(context);
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
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _performDismissAnimation(double screenHeight) async {
    if (_isDismissing) return;
    _isDismissing = true;
    setState(() {
      _verticalDrag = screenHeight;
    });
    await Future.delayed(const Duration(milliseconds: 220));
    if (mounted) Navigator.pop(context);
  }

  bool _isNetworkPath(String path) {
    try {
      final uri = Uri.tryParse(path);
      return uri != null &&
          uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  ImageProvider? _avatarImageFor(StoryModel pageStory) {
    final user = DummyData.getUserById(pageStory.userId);
    final candidate = (pageStory.profileImageUrl.isNotEmpty)
        ? pageStory.profileImageUrl
        : (user?.profileImage ?? '');
    if (candidate.isEmpty) return null;
    if (_isNetworkPath(candidate)) return NetworkImage(candidate);
    return FileImage(File(candidate));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _onTapAtPosition(details.localPosition, context),
        onLongPressStart: (_) => _pauseProgress(),
        onLongPressEnd: (_) => _resumeProgress(),
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0) {
            _pauseProgress();
            setState(() {
              _verticalDrag += details.delta.dy;
              if (_verticalDrag > screenHeight) _verticalDrag = screenHeight;
            });
          }
        },
        onVerticalDragEnd: (details) {
          if (_verticalDrag > 140) {
            _performDismissAnimation(screenHeight);
          } else {
            setState(() {
              _verticalDrag = 0;
            });
            _resumeProgress();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _verticalDrag, 0),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.stories.length,
            onPageChanged: (int newIndex) {
              if (!mounted) return;
              setState(() {
                _currentUserIndex = newIndex.clamp(
                  0,
                  widget.stories.length - 1,
                );
                _currentImageIndex = 0;
              });
              _progressController.reset();
              _startProgress();
            },
            itemBuilder: (context, pageIndex) {
              final StoryModel pageStory = widget.stories[pageIndex];
              final images = pageStory.images;
              final bool hasImages = images.isNotEmpty;

              final int displayImageIndex = hasImages
                  ? ((pageIndex == _currentUserIndex)
                        ? _currentImageIndex.clamp(0, images.length - 1)
                        : 0)
                  : 0;

              final String? imageUrl = hasImages
                  ? images[displayImageIndex]
                  : null;

              final user = DummyData.getUserById(pageStory.userId);
              final avatarImage = _avatarImageFor(pageStory);

              Widget imageWidget;
              if (imageUrl == null) {
                imageWidget = Container(color: Colors.black);
              } else if (_isNetworkPath(imageUrl)) {
                imageWidget = Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white),
                  ),
                );
              } else {
                imageWidget = Image.file(
                  File(imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white),
                  ),
                );
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  imageWidget,

                  if (hasImages)
                    Positioned(
                      top: 40,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: List.generate(images.length, (i) {
                          double value;
                          if (pageIndex != _currentUserIndex) {
                            value = 0.0;
                          } else {
                            if (i < _currentImageIndex)
                              value = 1.0;
                            else if (i == _currentImageIndex)
                              value = _progressController.value;
                            else
                              value = 0.0;
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

                  Positioned(
                    top: 52,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: avatarImage,
                          backgroundColor: Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? pageStory.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              pageStory.timeAgo,
                              style: TextStyle(
                                color: Colors.white.withOpacity(.8),
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
    );
  }
}
