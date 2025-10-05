import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Track followed users and removed users
  final Set<String> _followedUsers = {};
  final Set<String> _removedUsers = {};

  void _toggleFollow(String userId) {
    setState(() {
      if (_followedUsers.contains(userId)) {
        _followedUsers.remove(userId);
      } else {
        _followedUsers.add(userId);
      }
    });
  }

  void _removeUser(String userId) {
    setState(() {
      _removedUsers.add(userId);
    });
  }

  bool _isFollowing(String userId) {
    return _followedUsers.contains(userId);
  }

  bool _isRemoved(String userId) {
    return _removedUsers.contains(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          // Ads notification
          _buildNotificationItem(
            icon: Icons.trending_up,
            iconBackgroundColor: Colors.grey[200]!,
            title: 'Ads',
            subtitle: 'Recent activity from your ads.',
            timeAgo: null,
            showDivider: true,
          ),

          // Caught up notification
          _buildCaughtUpNotification(),

          // Section header
          _buildSectionHeader('Today'),

          // Today's notifications
          _buildUserNotification(
            user: DummyData.users[0],
            text: 'posted a thread that you might like.',
            timeAgo: '3h',
            hasImage: true,
            imageUrl:
                'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=150',
            badge: Icons.grid_on,
          ),

          _buildUserNotification(
            user: DummyData.users[2],
            text: 'mentioned you in a comment: @fuhad_arang congrats ❤️',
            timeAgo: '3h',
            hasImage: true,
            imageUrl:
                'https://images.unsplash.com/photo-1614680376593-902f74cf0d41?w=150',
            showViewReply: true,
          ),

          // Section header
          _buildSectionHeader('Last 7 days'),

          _buildUserNotification(
            user: DummyData.users[4],
            text:
                'liked a reel suggested for you in your blend with m tech racer.',
            timeAgo: '2d',
            hasImage: true,
            imageUrl:
                'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=150',
            badge: Icons.favorite,
            badgeColor: Colors.red,
          ),

          _buildFollowSuggestion(
            user: DummyData.users[5],
            subtitle: ', who you might know, is on Instagram.',
            timeAgo: '2d',
          ),

          _buildChannelInvite(
            users: [DummyData.users[6], DummyData.users[7]],
            othersCount: 7,
            timeAgo: '3d',
          ),

          _buildUserNotification(
            user: DummyData.users[8],
            text:
                ', ajasmm02 and 3 others liked your comment: @syedshahadnaanuddin he just reminds the parent...',
            timeAgo: '5d',
            hasImage: true,
            imageUrl:
                'https://images.unsplash.com/photo-1519741497674-611481863552?w=150',
            badge: Icons.favorite,
            badgeColor: Colors.red,
            showMore: true,
          ),

          _buildFollowSuggestion(
            user: DummyData.users[10],
            subtitle: '. You have 3 mutuals.',
            timeAgo: '5d',
            showAvatar: false,
            customIcon: _buildCustomAvatar('NW'),
          ),

          // Section header
          _buildSectionHeader('Last 30 days'),

          _buildUserNotification(
            user: DummyData.users[11],
            text: 'liked your post.',
            timeAgo: '12d',
            hasImage: true,
            imageUrl:
                'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=150',
          ),

          _buildFollowSuggestion(
            user: DummyData.users[12],
            subtitle: '. You have 47 mutuals.',
            timeAgo: '15d',
            customText: 'New follow suggestion:\n',
          ),

          _buildUserNotification(
            user: DummyData.users[13],
            text: 'liked your comment: ❤️',
            timeAgo: '18d',
            hasImage: true,
            imageUrl:
                'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=150',
          ),

          const SizedBox(height: 24),

          // People you don't follow back section
          _buildSectionHeader('People you don\'t follow back'),
          const SizedBox(height: 8),

          ...List.generate(8, (index) {
            final user = DummyData.users[index];
            if (_isRemoved(user.id)) {
              return const SizedBox.shrink();
            }
            return _buildFollowBackItem(user: user);
          }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconBackgroundColor,
    required String title,
    required String subtitle,
    String? timeAgo,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.black, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (timeAgo != null)
                Text(
                  timeAgo,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  Widget _buildCaughtUpNotification() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.black, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You\'re all caught up',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    children: const [
                      TextSpan(text: 'See new activity for '),
                      TextSpan(
                        text: 'no_immune_',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildUserNotification({
    required user,
    required String text,
    required String timeAgo,
    bool hasImage = false,
    String? imageUrl,
    IconData? badge,
    Color? badgeColor,
    bool showViewReply = false,
    bool showMore = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(user.profileImage),
              ),
              if (badge != null)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(badge, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' $text '),
                      TextSpan(
                        text: timeAgo,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (showViewReply) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'View Reply',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                if (showMore) ...[
                  const SizedBox(height: 4),
                  Text(
                    'more',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          if (hasImage && imageUrl != null) ...[
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                imageUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowSuggestion({
    required user,
    required String subtitle,
    required String timeAgo,
    bool showAvatar = true,
    Widget? customIcon,
    String? customText,
  }) {
    final isFollowing = _isFollowing(user.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (customIcon != null)
            customIcon
          else if (showAvatar)
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(user.profileImage),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  if (customText != null)
                    TextSpan(
                      text: customText,
                      style: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                  TextSpan(
                    text: user.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: subtitle),
                  TextSpan(
                    text: ' $timeAgo',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _toggleFollow(user.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing ? Colors.grey[200] : Colors.blue,
              foregroundColor: isFollowing ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isFollowing ? 'Following' : 'Follow',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelInvite({
    required List users,
    required int othersCount,
    required String timeAgo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(users[0].profileImage),
                    backgroundColor: Colors.white,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(users[1].profileImage),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: users[0].username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: users[1].username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        ' and $othersCount others invited you to join their channels. ',
                  ),
                  TextSpan(
                    text: timeAgo,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAvatar(String text) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildFollowBackItem({required user}) {
    final isFollowing = _isFollowing(user.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(user.profileImage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (user.name != null)
                  Text(
                    user.name!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _toggleFollow(user.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing ? Colors.grey[200] : Colors.blue,
              foregroundColor: isFollowing ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isFollowing ? 'Following' : 'Follow back',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _removeUser(user.id),
            icon: const Icon(Icons.close, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
