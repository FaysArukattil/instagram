import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/views/chatscreen/chatscreen.dart';

class MessengerScreen extends StatefulWidget {
  const MessengerScreen({super.key});

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
    if (searchQuery.isEmpty) {
      return [];
    }

    final query = searchQuery.toLowerCase();
    return DummyData.users.where((user) {
      return user.username.toLowerCase().contains(query) ||
          user.name.toLowerCase().contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredMessages() {
    if (searchQuery.isEmpty) {
      return tabMessages[selectedTab] ?? [];
    }

    final query = searchQuery.toLowerCase();
    final messages = tabMessages[selectedTab] ?? [];

    return messages.where((messageData) {
      final user = DummyData.getUserById(messageData['userId']);
      if (user == null) return false;

      return user.username.toLowerCase().contains(query) ||
          user.name.toLowerCase().contains(query) ||
          messageData['message'].toString().toLowerCase().contains(query);
    }).toList();
  }

  // Handle swipe gesture to go back
  void _handleSwipe(DragEndDetails details) {
    // Swipe right (positive velocity) - go back
    if (details.primaryVelocity! > 0) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMessages = _getFilteredMessages();
    final searchResults = searchQuery.isNotEmpty ? _getFilteredUsers() : [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                DummyData.currentUser.username,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.trending_up, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Filter',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Show search results if searching
              if (searchQuery.isNotEmpty && searchResults.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Users',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ...List.generate(searchResults.length, (index) {
                  final user = searchResults[index];
                  return _buildMessageItem(
                    user: user,
                    message: user.bio.isEmpty ? 'Tap to message' : user.bio,
                    time: '',
                    hasUnread: false,
                  );
                }),
              ],

              // Stories section (only show when not searching)
              if (searchQuery.isEmpty) ...[
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

                // Tabs
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildTab('Primary', 14),
                      const SizedBox(width: 8),
                      _buildTab('General', 0),
                      const SizedBox(width: 8),
                      _buildTab('Requests', 1),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Messages list
              if (searchQuery.isEmpty || filteredMessages.isNotEmpty) ...[
                if (searchQuery.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ...List.generate(filteredMessages.length, (index) {
                  final messageData = filteredMessages[index];
                  final user = DummyData.getUserById(messageData['userId']);

                  if (user == null) return const SizedBox.shrink();

                  return _buildMessageItem(
                    user: user,
                    message: messageData['message'],
                    time: messageData['time'],
                    hasUnread: messageData['hasUnread'] ?? false,
                    isMuted: messageData['isMuted'] ?? false,
                    showCamera: messageData['showCamera'] ?? false,
                    showPlay: messageData['showPlay'] ?? false,
                  );
                }),
              ],

              // No results message
              if (searchQuery.isNotEmpty &&
                  searchResults.isEmpty &&
                  filteredMessages.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching for people or messages',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    final isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count > 0 && isSelected)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 15,
              ),
            ),
            if (count > 0)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
          ],
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
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
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
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      noteText,
                      style: const TextStyle(
                        color: Colors.white,
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
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
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
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
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
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        noteText,
                        style: const TextStyle(
                          color: Colors.white,
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
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem({
    required user,
    required String message,
    required String time,
    bool hasUnread = false,
    bool isMuted = false,
    bool showCamera = false,
    bool showPlay = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(user: user)),
        );
      },
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
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: hasUnread ? Colors.black : Colors.grey[600],
                            fontSize: 14,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          ' · $time',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      if (isMuted) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.volume_off,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (showPlay)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'PLAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else if (showCamera)
              Icon(Icons.camera_alt_outlined, color: Colors.grey[600], size: 24)
            else if (hasUnread)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
