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

    followers = allUsers.where((u) => u.isFollowing).toList();
    following = allUsers.where((u) => u.isFollowing).toList();
    friends = allUsers
        .where((u) => u.isFollowing && DummyData.currentUser.isFollowing)
        .toList();

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
      case 1:
        return following;
      case 2:
        return friends;
      default:
        return followers;
    }
  }

  void _onTabChanged() {
    setState(() {
      filteredList = _getActiveList();
      _filterSearchResults(_searchController.text);
    });
  }

  void _toggleFollow(UserModel user) {
    setState(() {
      user.isFollowing = !user.isFollowing;
      if (user.isFollowing) {
        DummyData.currentUser.following++;
      } else {
        DummyData.currentUser.following--;
      }
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
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: Colors.white,
              floating: true,
              snap: true,
              pinned: true,
              elevation: 0.5,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                DummyData.currentUser.username,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(88),
                child: Column(
                  children: [
                    // Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.black,
                      indicatorWeight: 2,
                      tabs: const [
                        Tab(text: "Followers"),
                        Tab(text: "Following"),
                        Tab(text: "Friends"),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildUserList(followers),
              _buildUserList(following),
              _buildUserList(friends),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    final list = filteredList;

    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final user = list[index];
        return ListTile(
          onTap: () => _openProfile(user),
          leading: CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(user.profileImage),
          ),
          title: Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(user.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _toggleFollow(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isFollowing
                      ? Colors.grey[200]
                      : Colors.blue,
                  foregroundColor: user.isFollowing
                      ? Colors.black
                      : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  user.isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.message_outlined, color: Colors.grey),
                onPressed: () => _openChat(user),
              ),
            ],
          ),
        );
      },
    );
  }
}
