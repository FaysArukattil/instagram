import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/reel_model.dart';
import 'package:instagram/views/share_profile_screen/share_profile_screen.dart';

class ThreeDotBottomSheet extends StatefulWidget {
  final PostModel? post;
  final ReelModel? reel;

  const ThreeDotBottomSheet({super.key, this.post, this.reel})
    : assert(
        post != null || reel != null,
        'Either post or reel must be provided',
      );

  @override
  State<ThreeDotBottomSheet> createState() => _ThreeDotBottomSheetState();
}

class _ThreeDotBottomSheetState extends State<ThreeDotBottomSheet> {
  late bool isSaved;
  late bool isReposted;
  late bool isFollowing;
  late String userId;
  late String itemId;
  late String itemType;

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      itemType = 'post';
      itemId = widget.post!.id;
      userId = widget.post!.userId;
      isReposted = false; // Posts don't have repost in your model
    } else {
      itemType = 'reel';
      itemId = widget.reel!.id;
      userId = widget.reel!.userId;
      isReposted = widget.reel!.isReposted;
    }

    isSaved = DummyData.isItemSaved(itemType: itemType, itemId: itemId);

    final user = DummyData.getUserById(userId);
    isFollowing = user?.isFollowing ?? false;
  }

  bool get isCurrentUser => userId == DummyData.currentUser.id;

  void _toggleSave() {
    setState(() {
      if (isSaved) {
        DummyData.removeSavedItem(itemType: itemType, itemId: itemId);
        isSaved = false;
        _showSnackBar('Removed from saved');
      } else {
        DummyData.saveItem(itemType: itemType, itemId: itemId, userId: userId);
        isSaved = true;
        _showSnackBar('Saved to collection');
      }
    });
  }

  void _toggleRepost() {
    if (widget.reel != null) {
      setState(() {
        if (isReposted) {
          widget.reel!.isReposted = false;
          widget.reel!.shares = widget.reel!.shares > 0
              ? widget.reel!.shares - 1
              : 0;
          DummyData.removeRepost(widget.reel!.id, DummyData.currentUser.id);
          isReposted = false;
          _showSnackBar('Removed from your profile');
        } else {
          widget.reel!.isReposted = true;
          widget.reel!.shares++;
          DummyData.addRepost(widget.reel!.id, DummyData.currentUser.id);
          isReposted = true;
          _showSnackBar('Reposted to your profile');
        }
      });
    }
    Navigator.pop(context);
  }

  void _openQRCode() {
    Navigator.pop(context);
    final user = DummyData.getUserById(userId);
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShareProfileScreen(username: user.name),
        ),
      );
    }
  }

  void _toggleFollow() {
    setState(() {
      final user = DummyData.getUserById(userId);
      if (user != null) {
        user.isFollowing = !user.isFollowing;
        user.followers += user.isFollowing ? 1 : -1;
        isFollowing = user.isFollowing;
        _showSnackBar(
          user.isFollowing
              ? 'Following ${user.username}'
              : 'Unfollowed ${user.username}',
        );
      }
    });
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Save option
              _buildOption(
                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                text: isSaved ? 'Remove from saved' : 'Save',
                onTap: _toggleSave,
              ),

              // Repost option (only for reels)
              if (widget.reel != null)
                _buildOption(
                  icon: Icons.repeat,
                  text: isReposted ? 'Remove repost' : 'Repost',
                  iconColor: isReposted ? Colors.green : null,
                  onTap: _toggleRepost,
                ),

              // QR code option
              _buildOption(
                icon: Icons.qr_code,
                text: 'QR code',
                onTap: _openQRCode,
              ),

              const Divider(height: 16),

              // Follow/Unfollow (only show if not current user)
              if (!isCurrentUser)
                _buildOption(
                  icon: isFollowing
                      ? Icons.person_remove_outlined
                      : Icons.person_add_outlined,
                  text: isFollowing ? 'Unfollow' : 'Follow',
                  onTap: _toggleFollow,
                ),

              // About this account
              _buildOption(
                icon: Icons.person_outline,
                text: 'About this account',
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Account info feature coming soon');
                },
              ),

              // AI info
              _buildOption(
                icon: Icons.info_outline,
                text: 'AI info',
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('AI info feature coming soon');
                },
              ),

              const Divider(height: 16),

              // Not interested
              _buildOption(
                icon: Icons.not_interested_outlined,
                text: 'Not interested',
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('We\'ll show you less like this');
                },
              ),

              const Divider(height: 16),

              // Report
              _buildOption(
                icon: Icons.flag_outlined,
                text: 'Report',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Report submitted');
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isDestructive = false,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (isDestructive ? Colors.red : Colors.black),
        size: 24,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
