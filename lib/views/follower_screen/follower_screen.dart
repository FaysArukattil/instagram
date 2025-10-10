import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/views/chatscreen/chatscreen.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;

  const FollowersScreen({super.key, required this.userId});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  List<UserModel> followers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  void _loadFollowers() {
    // Simulate loading followers
    // In real app, this would fetch from backend
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        // Get followers who are following this user
        followers = DummyData.users.where((user) => user.isFollowing).toList();
        isLoading = false;
      });
    });
  }

  void _handleFollowToggle(UserModel user) {
    setState(() {
      final userIndex = DummyData.users.indexWhere((u) => u.id == user.id);
      if (userIndex != -1) {
        DummyData.users[userIndex].isFollowing =
            !DummyData.users[userIndex].isFollowing;

        // Update current user's following count
        if (DummyData.users[userIndex].isFollowing) {
          DummyData.currentUser.following++;
        } else {
          DummyData.currentUser.following--;
        }
      }
    });
  }

  void _handleRemoveFollower(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${user.username}?'),
        content: Text(
          'Instagram won\'t tell ${user.username} they were removed from your followers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                followers.removeWhere((f) => f.id == user.id);
                DummyData.currentUser.followers--;
              });
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openChat(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(user: user)),
    );
  }

  void _openProfile(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfileScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = widget.userId == DummyData.currentUser.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isCurrentUser ? DummyData.currentUser.username : 'Followers',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.grey))
          : followers.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No followers yet',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: followers.length,
              itemBuilder: (context, index) {
                final user = followers[index];
                return _buildFollowerItem(user, isCurrentUser);
              },
            ),
    );
  }

  Widget _buildFollowerItem(UserModel user, bool isCurrentUser) {
    return ListTile(
      onTap: () => _openProfile(user),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(user.profileImage),
      ),
      title: Text(
        user.username,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(user.name),
      trailing: SizedBox(
        width: isCurrentUser ? 140 : 110,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isCurrentUser)
              OutlinedButton(
                onPressed: () => _handleRemoveFollower(user),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.black, fontSize: 13),
                ),
              )
            else
              ElevatedButton(
                onPressed: () => _handleFollowToggle(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isFollowing
                      ? Colors.grey[200]
                      : Colors.blue,
                  foregroundColor: user.isFollowing
                      ? Colors.black
                      : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  user.isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _openChat(user),
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
