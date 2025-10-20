import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/core/constants/app_images.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/views/auth/login/login_screen.dart';
import 'package:instagram/views/saved_screen/saved_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settingscreen extends StatefulWidget {
  const Settingscreen({super.key});

  @override
  State<Settingscreen> createState() => _SettingscreenState();
}

class _SettingscreenState extends State<Settingscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings and activity',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: AppColors.grey600),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: AppColors.grey600),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Your account section
          _buildSectionTitle('Your account'),
          _buildSettingItem(
            icon: Icons.perm_identity_outlined,
            title: 'Accounts Centre',
            subtitle: 'Password, security, personal details',
            onTap: () => _showAccountsCentreSheet(context),
            showMetaLogo: true,
          ),

          const Divider(height: 1, thickness: 0.5),

          // How you use Instagram section
          _buildSectionTitle('How you use Instagram'),
          _buildSettingItem(
            icon: Icons.archive_outlined,
            title: 'Saved',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedScreen()),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.archive_outlined,
            title: 'Archive',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.timelapse_outlined,
            title: 'Your activity',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.schedule_outlined,
            title: 'Time spent',
            onTap: () {},
          ),

          const Divider(height: 1, thickness: 0.5),

          // For professionals section
          _buildSectionTitle('For professionals'),
          _buildSettingItem(
            icon: Icons.insights_outlined,
            title: 'Insights',
            subtitle: 'Not subscribed',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.update_outlined,
            title: 'Meta Business Suite',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.schedule_send_outlined,
            title: 'Scheduled content',
            trailing: '0',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.video_collection_outlined,
            title: 'Creator tools and controls',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.payment_outlined,
            title: 'Ads payments',
            onTap: () {},
          ),

          const Divider(height: 1, thickness: 0.5),

          // Who can see your content section
          _buildSectionTitle('Who can see your content'),
          _buildSettingItem(
            icon: Icons.lock_outlined,
            title: 'Account privacy',
            subtitle: 'Public',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.person_off_outlined,
            title: 'Close friends',
            trailing: '0',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.no_accounts_outlined,
            title: 'Crossposting',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.block_outlined,
            title: 'Blocked',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.visibility_off_outlined,
            title: 'Hide story, live and location',
            onTap: () {},
          ),

          const Divider(height: 1, thickness: 0.5),

          // How others can interact with you section
          _buildSectionTitle('How others can interact with you'),
          _buildSettingItem(
            icon: Icons.message_outlined,
            title: 'Messages',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.sell_outlined,
            title: 'Tags and mentions',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.comment_outlined,
            title: 'Comments',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.share_outlined,
            title: 'Sharing and reuse',
            subtitle: 'Restricted',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.check_circle_outline,
            title: 'Restricted',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.motion_photos_pause_outlined,
            title: 'Limit interactions',
            trailing: 'Off',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.filter_none_outlined,
            title: 'Hidden words',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.person_add_outlined,
            title: 'Follow and invite friends',
            onTap: () {},
          ),

          const Divider(height: 1, thickness: 0.5),

          // What you see section
          _buildSectionTitle('What you see'),
          _buildSettingItem(
            icon: Icons.star_outline,
            title: 'Favourites',
            trailing: '0',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.volume_off_outlined,
            title: 'Muted accounts',
            trailing: '0 / 3',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.tune_outlined,
            title: 'Content preferences',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.favorite_outline,
            title: 'Like and share counts',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.subscriptions_outlined,
            title: 'Subscriptions',
            onTap: () {},
          ),

          const Divider(height: 1, thickness: 0.5),

          // Your app and media section
          _buildSectionTitle('Your app and media'),
          _buildSettingItem(
            icon: Icons.devices_outlined,
            title: 'Device permissions',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.archive_outlined,
            title: 'Archiving and deletion',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.accessibility_new_outlined,
            title: 'Accessibility',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.language_outlined,
            title: 'Language and translations',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.data_usage_outlined,
            title: 'Data usage and media quality',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.web_outlined,
            title: 'App website and features',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.explore_outlined,
            title: 'Early access to features',
            onTap: () {},
          ),

          const Divider(height: 1, thickness: 0.5),

          // Family Centre
          _buildSectionTitle('Family Centre'),
          _buildSettingItem(
            icon: Icons.family_restroom_outlined,
            title: 'Supervision for Teen Accounts',
            onTap: () {},
          ),

          const Divider(height: 1, thickness: 0.5),

          // Orders and payments
          _buildSectionTitle('Orders and payments'),

          const Divider(height: 1, thickness: 0.5),

          // More info and support
          _buildSectionTitle('More info and support'),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Help',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.shield_outlined,
            title: 'Privacy Centre',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.account_circle_outlined,
            title: 'Account Status',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {},
          ),

          const Divider(height: 1, thickness: 0.5),

          // Also from Meta
          _buildSectionTitle('Also from Meta'),
          _buildSettingItem(
            icon: Icons.message_outlined,
            title: 'Meta AI',
            subtitle: 'Get answers, advice and generate images',
            hasNotificationDot: true,
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.waving_hand_outlined,
            title: 'WhatsApp',
            subtitle: 'Message privately with friends and family',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.video_library_outlined,
            title: 'Edits',
            subtitle: 'Create videos with powerful editing tools',
            hasNotificationDot: true,
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.group_outlined,
            title: 'Threads',
            subtitle: 'Start conversations on topics you care about',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.facebook_outlined,
            title: 'Facebook',
            subtitle: "Connect with friends on Meta's other social app",
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.messenger_outline,
            title: 'Messenger',
            subtitle: 'Chat and share seamlessly with friends',
            onTap: () {},
          ),

          const Divider(height: 1, thickness: 0.5),

          // Login section
          _buildSectionTitle('Login'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Add account',
                style: TextStyle(
                  color: AppColors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // Logout section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton(
              onPressed: () => _showLogoutDialog(context),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Log out',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Log out of all accounts',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.grey600,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailing,
    required VoidCallback onTap,
    bool showMetaLogo = false,
    bool hasNotificationDot = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Icon(icon, color: AppColors.black87, size: 26),
                if (hasNotificationDot)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (showMetaLogo)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Image.asset(
                      AppImages.metabluelogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Meta',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  trailing,
                  style: TextStyle(fontSize: 14, color: AppColors.grey600),
                ),
              ),
            Icon(Icons.chevron_right, color: AppColors.grey400, size: 24),
          ],
        ),
      ),
    );
  }

  void _showAccountsCentreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AccountsCentreSheet(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Log out of your account?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.clear();

                  // Add logout logic here
                },
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Divider(height: 1),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountsCentreSheet extends StatelessWidget {
  const AccountsCentreSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.95,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          AppImages.metabluelogo,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Meta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 28),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accounts Centre',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Manage your connected experiences and account settings across Meta technologies such as Facebook, Instagram and Meta Horizon.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: const Text(
                      'Learn more',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Profiles
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.grey300,
                        backgroundImage:
                            (DummyData.currentUser.profileImage
                                .toString()
                                .startsWith('http'))
                            ? NetworkImage(
                                DummyData.currentUser.profileImage.toString(),
                              )
                            : AssetImage(
                                    DummyData.currentUser.profileImage
                                        .toString(),
                                  )
                                  as ImageProvider,
                      ),
                      title: const Text(
                        'Profiles',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(DummyData.currentUser.username.toString()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showProfilesSheet(context),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Connected experiences
                  const Text(
                    'Connected experiences',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildListItem(
                    icon: Icons.people_outline,
                    title: 'Sharing across profiles',
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _buildListItem(
                    icon: Icons.login_outlined,
                    title: 'Logging in with accounts',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account settings
                  const Text(
                    'Account settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleItem(
                    icon: Icons.shield_outlined,
                    title: 'Password and security',
                    onTap: () {},
                  ),
                  _buildSimpleItem(
                    icon: Icons.badge_outlined,
                    title: 'Personal details',
                    onTap: () {},
                  ),
                  _buildSimpleItem(
                    icon: Icons.description_outlined,
                    title: 'Your information and permissions',
                    onTap: () {},
                  ),
                  _buildSimpleItem(
                    icon: Icons.campaign_outlined,
                    title: 'Ad preferences',
                    onTap: () {},
                  ),
                  _buildSimpleItem(
                    icon: Icons.credit_card_outlined,
                    title: 'Meta Pay',
                    onTap: () {},
                  ),
                  _buildSimpleItem(
                    icon: Icons.subscriptions_outlined,
                    title: 'Subscriptions',
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  // Accounts
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_circle_outlined,
                              color: AppColors.grey700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Accounts',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Review the accounts that you have in this Accounts Centre.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text(
                            'Add more accounts',
                            style: TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // More from Meta
                  const Text(
                    'More from Meta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.verified,
                                color: AppColors.blue,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Meta Verified',
                                style: TextStyle(fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.visibility,
                                color: AppColors.blue,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'AI glasses',
                                style: TextStyle(fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grey700),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grey700, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            Icon(Icons.chevron_right, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }

  void _showProfilesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ProfilesSheet(),
    );
  }
}

class ProfilesSheet extends StatelessWidget {
  const ProfilesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 28),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 8),

              // Title
              const Text(
                'Profiles',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              // Description
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey700,
                    height: 1.4,
                  ),
                  children: const [
                    TextSpan(
                      text:
                          'Manage your profile info, and use the same info across Facebook, Instagram and Meta Horizon. Add more profiles by adding your accounts. ',
                    ),
                    TextSpan(
                      text: 'Learn more',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Profile Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.grey300,
                    backgroundImage:
                        (DummyData.currentUser.profileImage
                            .toString()
                            .startsWith('http'))
                        ? NetworkImage(
                            DummyData.currentUser.profileImage.toString(),
                          )
                        : AssetImage(
                                DummyData.currentUser.profileImage.toString(),
                              )
                              as ImageProvider,
                  ),

                  title: Text(
                    DummyData.currentUser.username.toString(),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: const Text(
                    'Facebook, Instagram',
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),

              const SizedBox(height: 16),

              // Add accounts button
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Add accounts',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
