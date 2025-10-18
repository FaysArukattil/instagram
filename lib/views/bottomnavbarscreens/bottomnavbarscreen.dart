import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _reelsInitialIndex = 0;
  Duration _reelsStartPosition = Duration.zero;

  void _navigateToTab(int tabIndex, int reelIndex, Duration startPosition) {
    setState(() {
      if (tabIndex == 3) {
        _reelsInitialIndex = reelIndex;
        _reelsStartPosition = startPosition;
        _reelsRefreshKey++;
      }
      _currentIndex = tabIndex;
    });
  }

  List<Widget> _getScreens() {
    return [
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (_currentIndex == 0) {
            SystemNavigator.pop();
          }
        },
        child: HomeScreen(
          key: ValueKey('home_$_homeRefreshKey'),
          onNavigateToReels: _navigateToTab,
        ),
      ),
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (_currentIndex == 1) {
            setState(() {
              _currentIndex = 0;
            });
          }
        },
        child: const SearchScreen(),
      ),
      const SizedBox(),
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (_currentIndex == 3) {
            setState(() {
              _currentIndex = 0;
            });
          }
        },
        child: ReelsScreen(
          key: ValueKey('reels_$_reelsRefreshKey'),
          isVisible: _currentIndex == 3,
          initialIndex: _reelsInitialIndex,
          disableShuffle: true,
          startPosition: _reelsStartPosition,
        ),
      ),
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (_currentIndex == 4) {
            setState(() {
              _currentIndex = 0;
            });
          }
        },
        child: ProfileTabScreen(key: ValueKey('profile_$_profileRefreshKey')),
      ),
    ];
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddPostScreen(),
          fullscreenDialog: true,
        ),
      ).then((_) {
        setState(() {
          _homeRefreshKey++;
          _profileRefreshKey++;
          _reelsRefreshKey++;
        });
      });
    } else {
      // Always increment key when tapping home to force complete rebuild
      if (index == 0) {
        setState(() {
          _homeRefreshKey++;
          _currentIndex = index;
        });
      } else {
        setState(() {
          _currentIndex = index;
        });
      }
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
      onTap: () {
        if (index == 3) {
          final reelCount = DummyData.reels.length;
          if (reelCount <= 1) {
            setState(() => _currentIndex = 3);
            return;
          }

          final rnd = Random();
          int newStart = rnd.nextInt(reelCount);
          if (newStart == _reelsInitialIndex) {
            newStart = (newStart + 1) % reelCount;
          }

          setState(() {
            _reelsInitialIndex = newStart;
            _reelsStartPosition = Duration.zero;
            _reelsRefreshKey++;
            _currentIndex = 3;
          });
        } else {
          _onTabTapped(index);
        }
      },
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
              key: ValueKey(DummyData.currentUser.profileImage),
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
