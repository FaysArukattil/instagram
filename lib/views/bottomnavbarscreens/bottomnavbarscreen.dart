import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/views/Home/home_screen.dart';
import 'package:instagram/views/profile_tab_screen/profile_tab_screen.dart';
import 'package:instagram/views/reels_screen/reels_screen.dart';
import 'package:instagram/views/search_screen/searchscreen.dart';
import 'package:instagram/views/messenger_screen/messenger_screen.dart';
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
  bool _showFriendsReelsOnly = false;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToTab(int tabIndex, int reelIndex, Duration startPosition) {
    setState(() {
      if (tabIndex == 1) {
        _reelsInitialIndex = reelIndex;
        _reelsStartPosition = startPosition;
        _reelsRefreshKey++;
      }
      _currentIndex = tabIndex;
      _pageController.animateToPage(
        tabIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> _getScreens() {
    return [
      // 0: HOME
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

      // 1: REELS
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (_currentIndex == 1) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          }
        },
        child: ReelsScreen(
          key: ValueKey('reels_$_reelsRefreshKey'),
          isVisible: _currentIndex == 1,
          initialIndex: _reelsInitialIndex,
          disableShuffle: _reelsInitialIndex > 0,
          startPosition: _reelsStartPosition,
          showFriendsOnly: _showFriendsReelsOnly,
          onFriendsToggle: (value) {
            setState(() {
              _showFriendsReelsOnly = value;
              _reelsRefreshKey++;
            });
          },
        ),
      ),

      // 2: MESSENGER
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (_currentIndex == 2) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          }
        },
        child: const MessengerScreen(),
      ),

      // 3: SEARCH
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (_currentIndex == 3) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          }
        },
        child: const SearchScreen(),
      ),

      // 4: PROFILE
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (_currentIndex == 4) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          }
        },
        child: ProfileTabScreen(key: ValueKey('profile_$_profileRefreshKey')),
      ),
    ];
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Refresh current tab if tapped again
      if (index == 0) {
        setState(() => _homeRefreshKey++);
      } else if (index == 1) {
        setState(() {
          _reelsInitialIndex = 0;
          _reelsStartPosition = Duration.zero;
          _reelsRefreshKey++;
        });
      } else if (index == 4) {
        setState(() => _profileRefreshKey++);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const ClampingScrollPhysics(),
        children: _getScreens(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 0.5),
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
                  activeIcon: Icons.home_filled,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.play_circle_outlined,
                  activeIcon: Icons.play_circle,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.messenger_outline,
                  activeIcon: Icons.messenger,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.search,
                  activeIcon: Icons.search,
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
          size: 28,
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
          width: 28,
          height: 28,
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
              width: 28,
              height: 28,
            ),
          ),
        ),
      ),
    );
  }
}
