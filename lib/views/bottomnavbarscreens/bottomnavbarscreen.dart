import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/core/constants/app_colors.dart';
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
      HomeScreen(
        key: ValueKey('home_$_homeRefreshKey'),
        onNavigateToReels: _navigateToTab,
      ),
      ReelsScreen(
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
      const MessengerScreen(),
      const SearchScreen(),
      ProfileTabScreen(key: ValueKey('profile_$_profileRefreshKey')),
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
      if (index == 0) setState(() => _homeRefreshKey++);
      if (index == 1) {
        setState(() {
          _reelsInitialIndex = 0;
          _reelsStartPosition = Duration.zero;
          _reelsRefreshKey++;
        });
      }
      if (index == 4) setState(() => _profileRefreshKey++);
    }
  }

  Widget _buildNavItem({
    required int index,
    required String iconPath,
    required String activeIconPath,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          isSelected ? activeIconPath : iconPath,
          width: 28,
          height: 28,
        ),
      ),
    );
  }

  Widget _buildProfileNavItem({required int index}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: isSelected
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.black, width: 2),
              )
            : null,
        child: ClipOval(
          child: UniversalImage(
            key: ValueKey(DummyData.currentUser.profileImage),
            imagePath: DummyData.currentUser.profileImage,
            width: 28,
            height: 28,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
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
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.grey200!, width: 0.5),
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
                  iconPath: 'assets/Icons/home_outline.svg',
                  activeIconPath: 'assets/Icons/home_filled.svg',
                ),
                _buildNavItem(
                  index: 1,
                  iconPath: 'assets/Icons/reel_outline.svg',
                  activeIconPath: 'assets/Icons/reel_filled.svg',
                ),
                _buildNavItem(
                  index: 2,
                  iconPath: 'assets/Icons/message_outline.svg',
                  activeIconPath: 'assets/Icons/message_filled.svg',
                ),
                _buildNavItem(
                  index: 3,
                  iconPath: 'assets/Icons/search_outline.svg',
                  activeIconPath: 'assets/Icons/search_filled.svg',
                ),
                _buildProfileNavItem(index: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
