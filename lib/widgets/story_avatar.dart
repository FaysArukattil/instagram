import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/models/story_model.dart';
import 'package:instagram/widgets/universal_image.dart';

class StoryAvatar extends StatelessWidget {
  final UserModel user;
  final StoryModel? story;
  final bool hasStory;
  final bool isCurrentUser;
  final VoidCallback onTap;
  final VoidCallback? onAddStory;

  const StoryAvatar({
    super.key,
    required this.user,
    required this.hasStory,
    this.isCurrentUser = false,
    required this.onTap,
    this.onAddStory,
    this.story,
  });

  @override
  Widget build(BuildContext context) {
    // Check if story is viewed by current user
    bool isStoryViewed = story != null
        ? story!.isViewedBy(DummyData.currentUser.id)
        : false;

    // Show gradient ring only if has story and NOT viewed
    bool showGradientRing = hasStory && !isStoryViewed;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Gradient ring for unviewed stories
                if (showGradientRing)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF58529),
                          Color(0xFFDD2A7B),
                          Color(0xFF8134AF),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),

                // Grey ring for viewed stories
                if (hasStory && isStoryViewed && !isCurrentUser)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.grey300!, width: 2),
                    ),
                  ),

                // White border + profile image
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: !hasStory || isCurrentUser
                        ? Border.all(color: AppColors.grey300!, width: 1.5)
                        : null,
                  ),
                  padding: EdgeInsets.all(
                    showGradientRing || (hasStory && isStoryViewed) ? 2.5 : 0,
                  ),
                  child: ClipOval(
                    child: UniversalImage(
                      imagePath: user.profileImage,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        color: AppColors.grey300,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                // Plus icon for current user
                if (isCurrentUser)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: onAddStory ?? onTap,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              user.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
