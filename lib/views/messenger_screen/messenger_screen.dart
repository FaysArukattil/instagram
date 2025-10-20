import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/views/chatscreen/chatscreen.dart';

class MessengerScreen extends StatefulWidget {
  final VoidCallback? onSwipeBack;
  final ValueChanged<DragUpdateDetails>? onHorizontalDragUpdate;
  final ValueChanged<DragEndDetails>? onHorizontalDragEnd;

  const MessengerScreen({
    super.key,
    this.onSwipeBack,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
  });

  @override
  State<MessengerScreen> createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
  String selectedTab = 'Primary';
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final Map<String, List<Map<String, dynamic>>> tabMessages = {
    'Primary': [
      {
        'userId': 'user_3',
        'message': 'Hii 😊',
        'time': '3d',
        'hasUnread': true,
      },
      {
        'userId': 'user_4',
        'message': 'Hello where you at?',
        'time': '3d',
        'hasUnread': true,
      },
      {
        'userId': 'user_2',
        'message': 'Mentioned you in ...',
        'time': '1w',
        'hasUnread': true,
        'isMuted': true,
        'showCamera': true,
      },
      {
        'userId': 'user_8',
        'message': '4+ new messages',
        'time': '4w',
        'hasUnread': true,
        'showCamera': true,
      },
      {
        'userId': 'user_7',
        'message': 'Sent a reel by __dev...',
        'time': '4w',
        'hasUnread': true,
        'showCamera': true,
      },
      {
        'userId': 'user_12',
        'message': 'Sent a reel by fitness_freak',
        'time': '4w',
        'hasUnread': true,
        'showCamera': true,
      },
    ],
    'General': [
      {
        'userId': 'user_8',
        'message': '4+ new messa...',
        'time': '113w',
        'showPlay': true,
      },
      {
        'userId': 'user_9',
        'message': '4+ new messages',
        'time': '6w',
        'hasUnread': true,
        'showCamera': true,
      },
      {
        'userId': 'user_5',
        'message': 'Sent you a post',
        'time': '8w',
        'showCamera': true,
      },
    ],
    'Requests': [
      {
        'userId': 'user_11',
        'message': 'Wants to send you a message',
        'time': '2w',
      },
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _getFilteredUsers() {
    if (searchQuery.isEmpty) return [];
    final query = searchQuery.toLowerCase();
    return DummyData.users.where((user) {
      return user.username.toLowerCase().contains(query) ||
          user.name.toLowerCase().contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredMessages() {
    if (searchQuery.isEmpty) return tabMessages[selectedTab] ?? [];
    final query = searchQuery.toLowerCase();
    final messages = tabMessages[selectedTab] ?? [];
    return messages.where((msg) {
      final user = DummyData.getUserById(msg['userId']);
      if (user == null) return false;
      return user.username.toLowerCase().contains(query) ||
          user.name.toLowerCase().contains(query) ||
          msg['message'].toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMessages = _getFilteredMessages();
    final searchResults = searchQuery.isNotEmpty
        ? _getFilteredUsers()
        : <UserModel>[];

    return GestureDetector(
      onHorizontalDragUpdate: widget.onHorizontalDragUpdate,
      onHorizontalDragEnd: widget.onHorizontalDragEnd,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,

          title: Row(
            children: [
              Expanded(
                child: Text(
                  DummyData.currentUser.username,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.black),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz, color: AppColors.black),
              onPressed: () {},
            ),

            IconButton(
              icon: const Icon(Icons.edit_square, color: AppColors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchBar(),
              if (searchQuery.isEmpty) _buildStoriesAndTabs(),
              _buildMessageList(filteredMessages, searchResults),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesAndTabs() {
    return Column(
      children: [
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildNoteItem(
                image: DummyData.currentUser.profileImage,
                label: 'Your note',
                noteText: 'Weekend\nplans?',
              ),
              _buildStoryItem(
                image: DummyData.users[1].profileImage,
                label: DummyData.users[1].name.split(' ')[0],
                noteText: 'Blabla...\npt829!',
              ),
              _buildStoryItem(
                image: DummyData.users[2].profileImage,
                label: DummyData.users[2].name.split(' ')[0],
                isOnline: true,
              ),
              _buildStoryItem(
                image: DummyData.users[9].profileImage,
                label: DummyData.users[9].name.split(' ')[0],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: tabMessages.keys.map((tab) {
              final isSelected = selectedTab == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildTab(tab, isSelected),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList(
    List<Map<String, dynamic>> messages,
    List<UserModel> searchResults,
  ) {
    final itemCount = searchResults.isNotEmpty
        ? searchResults.length
        : messages.length;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (searchResults.isNotEmpty) {
          return _buildMessageItemFromUser(searchResults[index]);
        }
        return _buildMessageItemFromData(messages[index]);
      },
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue50 : AppColors.grey100,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.blue : AppColors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteItem({
    required String image,
    required String label,
    required String noteText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(radius: 32, backgroundImage: NetworkImage(image)),
              Positioned(
                top: -18,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    noteText,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 64,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem({
    required String image,
    required String label,
    String? noteText,
    bool isOnline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(radius: 32, backgroundImage: NetworkImage(image)),
              if (noteText != null)
                Positioned(
                  top: -18,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      noteText,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 64,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItemFromUser(UserModel user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(user.profileImage),
      ),
      title: Text(user.username),
      subtitle: Text(user.bio.isEmpty ? 'Tap to message' : user.bio),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(user: user)),
      ),
    );
  }

  Widget _buildMessageItemFromData(Map<String, dynamic> msgData) {
    final user = DummyData.getUserById(msgData['userId']);
    if (user == null) return const SizedBox.shrink();

    final bool hasUnread = msgData['hasUnread'] ?? false;
    final bool isMuted = msgData['isMuted'] ?? false;
    final bool showCamera = msgData['showCamera'] ?? false;
    final bool showPlay = msgData['showPlay'] ?? false;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(user: user)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(user.profileImage),
                ),
                if (user.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          msgData['message'],
                          style: TextStyle(
                            color: hasUnread
                                ? AppColors.black
                                : AppColors.grey600,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMuted)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.volume_off,
                            size: 16,
                            color: AppColors.grey,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  msgData['time'],
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showPlay)
                      const Icon(
                        Icons.play_arrow,
                        color: AppColors.grey,
                        size: 20,
                      ),
                    if (showCamera)
                      const Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.grey,
                        size: 20,
                      ),
                    if (hasUnread && !showPlay && !showCamera)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
