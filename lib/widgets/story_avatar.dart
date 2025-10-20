import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/widgets/universal_image.dart'; // ✅ Import your UniversalImage

class StoryAvatar extends StatelessWidget {
  final UserModel user;
  final bool hasStory;
  final bool isCurrentUser;
  final VoidCallback onTap;
  final VoidCallback? onAddStory; // For adding more stories

  const StoryAvatar({
    super.key,
    required this.user,
    required this.hasStory,
    this.isCurrentUser = false,
    required this.onTap,
    this.onAddStory,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70, // Fixed width to prevent overflow
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Story ring gradient (if has story)
                if (hasStory && !isCurrentUser)
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

                // White border + profile image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: hasStory && !isCurrentUser
                        ? null
                        : Border.all(color: AppColors.grey300!, width: 1),
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: ClipOval(
                    child: UniversalImage(
                      imagePath:
                          user.profileImage, // ✅ Works for both local/network
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        color: AppColors.grey300,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                // Plus icon for current user (to add story)
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
              user.username, // ✅ Always shows the user's name now
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
