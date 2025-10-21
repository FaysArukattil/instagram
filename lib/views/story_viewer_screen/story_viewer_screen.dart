// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/story_model.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';
import 'package:instagram/views/three_dot_bottom_sheet/three_dot_bottom_sheet.dart';

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

  bool _isTransitioning = false;
  bool _tapLock = false;

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
              _onProgressCompleteSafe();
            }
          });

    _startProgress();
    _markStoryAsViewed();
  }

  void _markStoryAsViewed() {
    if (_currentUserIndex >= 0 && _currentUserIndex < widget.stories.length) {
      final currentStory = widget.stories[_currentUserIndex];
      currentStory.markAsViewed(DummyData.currentUser.id);

      final mainStoryIndex = DummyData.stories.indexWhere(
        (s) => s.id == currentStory.id,
      );
      if (mainStoryIndex != -1) {
        DummyData.stories[mainStoryIndex].markAsViewed(
          DummyData.currentUser.id,
        );
      }
    }
  }

  void _startProgress() {
    if (!mounted) return;
    _progressController.stop();
    _progressController.reset();
    final images = _currentStoryImages;
    if (images == null || images.isEmpty) {
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

  void _onProgressCompleteSafe() {
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
    } catch (_) {}
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
    } catch (_) {}
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

  void _openUserProfile(String userId) {
    if (userId == DummyData.currentUser.id) return;
    final user = DummyData.getUserById(userId);
    if (user != null) {
      _pauseProgress();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfileScreen(user: user)),
      ).then((_) {
        if (mounted) _resumeProgress();
      });
    }
  }

  Future<void> _openThreeDotMenu(StoryModel story) async {
    _pauseProgress();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ThreeDotBottomSheet(
        story: story,
        onDelete: () {
          setState(() {
            DummyData.stories.removeWhere((s) => s.id == story.id);
            widget.stories.removeWhere((s) => s.id == story.id);
            if (widget.stories.isEmpty) Navigator.pop(context);
          });
        },
      ),
    );
    _resumeProgress();
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.black,
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
              _markStoryAsViewed();
            },
            itemBuilder: (context, pageIndex) {
              final StoryModel pageStory = widget.stories[pageIndex];
              final images = pageStory.images;
              final int displayImageIndex = (pageIndex == _currentUserIndex)
                  ? _currentImageIndex.clamp(0, images.length - 1)
                  : 0;
              final String? imageUrl = images.isEmpty
                  ? null
                  : images[displayImageIndex];
              final UserModel? user = DummyData.getUserById(pageStory.userId);

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl == null)
                    Container(
                      color: AppColors.black,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: AppColors.white),
                      ),
                    )
                  else if (imageUrl.startsWith('http'))
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, prog) {
                        if (prog == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                        );
                      },
                      errorBuilder: (ctx, e, st) => const Center(
                        child: Icon(Icons.broken_image, color: AppColors.white),
                      ),
                    )
                  else
                    Image.file(
                      File(imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, st) => const Center(
                        child: Icon(Icons.broken_image, color: AppColors.white),
                      ),
                    ),

                  // Progress bar
                  Positioned(
                    top: 40,
                    left: 8,
                    right: 8,
                    child: Row(
                      children: List.generate(images.length, (i) {
                        double value;
                        if (pageIndex != _currentUserIndex) {
                          value = 0.0;
                        } else if (i < _currentImageIndex) {
                          value = 1.0;
                        } else if (i == _currentImageIndex) {
                          value = _progressController.value;
                        } else {
                          value = 0.0;
                        }
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                minHeight: 3,
                                value: value,
                                backgroundColor: AppColors.white.withValues(
                                  alpha: 0.25,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // User header
                  Positioned(
                    top: 52,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (user != null) _openUserProfile(user.id);
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    (user?.profileImage != null &&
                                        user!.profileImage.startsWith('http'))
                                    ? NetworkImage(user.profileImage)
                                    : (user?.profileImage != null &&
                                          File(user!.profileImage).existsSync())
                                    ? FileImage(File(user.profileImage))
                                          as ImageProvider
                                    : const AssetImage(
                                        'assets/default_avatar.png',
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.username ?? pageStory.username,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    pageStory.timeAgo,
                                    style: TextStyle(
                                      color: AppColors.white.withValues(
                                        alpha: .8,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: AppColors.white,
                          ),
                          onPressed: () => _openThreeDotMenu(
                            pageStory,
                          ), // ✅ Here’s the 3-dot
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
