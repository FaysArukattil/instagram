import 'package:flutter/material.dart';
import '../models/user_model.dart';

class StoryAvatar extends StatelessWidget {
  final UserModel user;
  final bool hasStory;
  final bool isCurrentUser;
  final VoidCallback onTap;

  const StoryAvatar({
    super.key,
    required this.user,
    required this.hasStory,
    this.isCurrentUser = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasStory
                    ? const LinearGradient(
                        colors: [Colors.purple, Colors.orange, Colors.yellow],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : null,
              ),
              padding: const EdgeInsets.all(2),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(user.profileImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isCurrentUser)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 70,
              child: Text(
                isCurrentUser ? 'Your story' : user.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
