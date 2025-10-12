import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/views/Home/home_screen.dart';
import 'package:instagram/views/add_post_screen/add_post_screen.dart';
import 'package:instagram/views/profile_tab_screen/profile_tab_screen.dart';
import 'package:instagram/views/reels_screen/reels_screen.dart';
import 'package:instagram/views/search_screen/searchscreen.dart';
import 'package:instagram/widgets/universal_image.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _currentIndex = 0;
  int _homeRefreshKey = 0;
  int _reelsRefreshKey = 0;
  int _profileRefreshKey = 0;

  List<Widget> _getScreens() {
    return [
      HomeScreen(key: ValueKey('home_$_homeRefreshKey')),
      const SearchScreen(),
      const SizedBox(), // Placeholder for Add Post
      ReelsScreen(key: ValueKey('reels_$_reelsRefreshKey')),
      ProfileTabScreen(key: ValueKey('profile_$_profileRefreshKey')),
    ];
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // Open Add Post screen as a modal
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddPostScreen(),
          fullscreenDialog: true,
        ),
      ).then((_) {
        // Refresh home screen after returning from add post
        setState(() {
          _homeRefreshKey++;
        });
      });
    } else {
      setState(() {
        // If tapping the same tab, refresh it
        if (_currentIndex == index) {
          if (index == 0) {
            // Refresh home
            _homeRefreshKey++;
          } else if (index == 3) {
            // Refresh reels
            _reelsRefreshKey++;
          } else if (index == 4) {
            // Refresh profile
            _profileRefreshKey++;
          }
        } else {
          // Switching to different tab
          if (index == 0) {
            _homeRefreshKey++;
          } else if (index == 3) {
            _reelsRefreshKey++;
          } else if (index == 4) {
            // Always refresh profile when switching to it
            _profileRefreshKey++;
          }
        }
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _getScreens()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.search,
                  activeIcon: Icons.search,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.add_box_outlined,
                  activeIcon: Icons.add_box_outlined,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.movie_outlined,
                  activeIcon: Icons.movie,
                ),
                _buildProfileNavItem(index: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: 26,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildProfileNavItem({required int index}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        _onTabTapped(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: Colors.black, width: 2)
                : null,
          ),
          child: ClipOval(
            child: UniversalImage(
              imagePath: DummyData.currentUser.profileImage,
              fit: BoxFit.cover,
              width: 26,
              height: 26,
            ),
          ),
        ),
      ),
    );
  }
}
