import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/views/chatscreen/chatscreen.dart';
import 'package:instagram/views/profile_screen/profile_screen.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;
  final int initialTabIndex;

  const FollowersScreen({
    super.key,
    required this.userId,
    this.initialTabIndex = 0,
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> followers = [];
  List<UserModel> following = [];
  List<UserModel> friends = [];
  List<UserModel> filteredList = [];

  // Category lists
  List<UserModel> notFollowingBack = [];
  List<UserModel> leastInteracted = [];
  List<UserModel> creators = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(_onTabChanged);
    _loadData();

    _searchController.addListener(() {
      _filterSearchResults(_searchController.text);
    });
  }

  void _loadData() {
    final allUsers = DummyData.users;
    final currentUserId = DummyData.currentUser.id;

    // Get following: users the current user follows
    final followingIds = DummyData.followingMap[currentUserId] ?? [];
    following = allUsers.where((u) => followingIds.contains(u.id)).toList();

    // Get followers: users whose following list contains current user
    followers = allUsers.where((u) {
      final userFollowingList = DummyData.followingMap[u.id] ?? [];
      return userFollowingList.contains(currentUserId);
    }).toList();

    // Get friends: mutual follows
    friends = followers.where((u) => followingIds.contains(u.id)).toList();

    // Categories for followers tab
    notFollowingBack = followers
        .where((u) => !followingIds.contains(u.id))
        .toList();
    leastInteracted = followers.take(5).toList();
    creators = followers.where((u) => u.posts > 50).toList();

    filteredList = _getActiveList();
  }

  void _filterSearchResults(String query) {
    final activeList = _getActiveList();
    if (query.isEmpty) {
      setState(() => filteredList = activeList);
    } else {
      setState(() {
        filteredList = activeList
            .where(
              (user) =>
                  user.username.toLowerCase().contains(query.toLowerCase()) ||
                  user.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      });
    }
  }

  List<UserModel> _getActiveList() {
    switch (_tabController.index) {
      case 0: // Friends
        return friends;
      case 1: // Followers
        return followers;
      case 2: // Following
        return following;
      default:
        return [];
    }
  }

  void _onTabChanged() {
    setState(() {
      _loadData();
      _filterSearchResults(_searchController.text);
    });
  }

  void _toggleFollow(UserModel user) {
    setState(() {
      final currentUserId = DummyData.currentUser.id;

      DummyData.followingMap.putIfAbsent(currentUserId, () => []);

      final isCurrentlyFollowing = DummyData.followingMap[currentUserId]!
          .contains(user.id);

      if (isCurrentlyFollowing) {
        DummyData.followingMap[currentUserId]!.remove(user.id);
        DummyData.currentUser.following--;
        user.followers--;
        user.isFollowing = false;
      } else {
        DummyData.followingMap[currentUserId]!.add(user.id);
        DummyData.currentUser.following++;
        user.followers++;
        user.isFollowing = true;
      }

      _loadData();
      _filterSearchResults(_searchController.text);
    });
  }

  void _openChat(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(user: user)),
    );
  }

  void _openProfile(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserProfileScreen(user: user)),
    ).then((_) {
      setState(() {
        _loadData();
        _filterSearchResults(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
        title: Text(
          DummyData.currentUser.username,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[500],
              indicatorColor: Colors.black,
              indicatorWeight: 1,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                Tab(text: "${friends.length} friends"),
                Tab(text: "${followers.length} followers"),
                Tab(text: "${following.length} following"),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsTab(),
                _buildFollowersTab(),
                _buildFollowingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Column(
      children: [
        _buildSearchBar(),
        if (_searchController.text.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Followers you follow back',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ),
        Expanded(child: _buildUserList()),
      ],
    );
  }

  Widget _buildFollowersTab() {
    if (_searchController.text.isNotEmpty) {
      return Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildUserList()),
        ],
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: ListView(
            children: [
              if (notFollowingBack.isNotEmpty) ...[
                _buildCategoryHeader('Categories'),
                _buildCategoryItem(
                  'People you don\'t follow back',
                  '${notFollowingBack[0].username} and ${notFollowingBack.length - 1} others',
                  Icons.person_outline,
                  () => _showCategoryList(
                    'People you don\'t follow back',
                    notFollowingBack,
                  ),
                ),
              ],
              if (leastInteracted.isNotEmpty)
                _buildCategoryItem(
                  'Least interacted with',
                  '${leastInteracted[0].username} and ${leastInteracted.length - 1} others',
                  Icons.access_time,
                  () => _showCategoryList(
                    'Least interacted with',
                    leastInteracted,
                  ),
                ),
              if (creators.isNotEmpty)
                _buildCategoryItem(
                  'Creators',
                  '${creators[0].username} and ${creators.length - 1} others',
                  Icons.star_outline,
                  () => _showCategoryList('Creators', creators),
                ),
              const SizedBox(height: 8),
              _buildCategoryHeader('All followers'),
              ..._buildAllFollowersList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowingTab() {
    if (_searchController.text.isNotEmpty) {
      return Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildUserList()),
        ],
      );
    }

    final currentUserId = DummyData.currentUser.id;

    // People who don't follow backr
    final notFollowingBackList = following.where((u) {
      final userFollowingList = DummyData.followingMap[u.id] ?? [];
      return !userFollowingList.contains(currentUserId);
    }).toList();

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: ListView(
            children: [
              if (notFollowingBackList.isNotEmpty) ...[
                _buildCategoryHeader('Categories'),
                _buildCategoryItem(
                  'People you don\'t follow back',
                  notFollowingBackList.length > 1
                      ? '${notFollowingBackList[0].username} and ${notFollowingBackList.length - 1} others'
                      : notFollowingBackList[0].username,
                  Icons.person_outline,
                  () => _showCategoryList(
                    'People you don\'t follow back',
                    notFollowingBackList,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sorted by Default',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Icon(Icons.swap_vert, color: Colors.grey[700]),
                  ],
                ),
              ),
              ..._buildAllFollowingList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildCategoryItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey[700]),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
    );
  }

  List<Widget> _buildAllFollowersList() {
    return followers.map((user) {
      final isFollowing =
          DummyData.followingMap[DummyData.currentUser.id]?.contains(user.id) ??
          false;
      return _buildUserTile(user, isFollowing, showRemoveButton: false);
    }).toList();
  }

  List<Widget> _buildAllFollowingList() {
    return following.map((user) {
      return _buildUserTile(user, true, showRemoveButton: false);
    }).toList();
  }

  Widget _buildUserList() {
    final list = filteredList;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final user = list[index];
        final isFollowing =
            DummyData.followingMap[DummyData.currentUser.id]?.contains(
              user.id,
            ) ??
            false;
        return _buildUserTile(user, isFollowing);
      },
    );
  }

  Widget _buildUserTile(
    UserModel user,
    bool isFollowing, {
    bool showRemoveButton = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => _openProfile(user),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(user.profileImage),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 14),
          ],
        ],
      ),
      subtitle: Text(
        user.name,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showRemoveButton)
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () => _toggleFollow(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? Colors.grey[200] : Colors.blue,
                  foregroundColor: isFollowing ? Colors.black : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow back',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => _openChat(user),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 32),
              ),
              child: const Text(
                'Message',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showMoreOptions(user),
            child: const Icon(Icons.more_vert, color: Colors.black, size: 20),
          ),
        ],
      ),
    );
  }

  void _showCategoryList(String title, List<UserModel> users) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryListScreen(title: title, users: users),
      ),
    ).then((_) {
      setState(() {
        _loadData();
        _filterSearchResults(_searchController.text);
      });
    });
  }

  void _showMoreOptions(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_remove_outlined),
                title: const Text('Remove Follower'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleFollow(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: const Text('Block'),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// Category List Screen
class CategoryListScreen extends StatelessWidget {
  final String title;
  final List<UserModel> users;

  const CategoryListScreen({
    super.key,
    required this.title,
    required this.users,
  });

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
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final isFollowing =
              DummyData.followingMap[DummyData.currentUser.id]?.contains(
                user.id,
              ) ??
              false;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(user.profileImage),
            ),
            title: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              user.name,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            trailing: SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? Colors.grey[200] : Colors.blue,
                  foregroundColor: isFollowing ? Colors.black : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
