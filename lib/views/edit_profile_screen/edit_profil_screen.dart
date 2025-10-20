import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/data/dummy_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/widgets/universal_image.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _pronounsController;
  late String _gender;
  String? _profileImagePath;
  bool _showThreadsBanner = true;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u.name);
    _usernameController = TextEditingController(text: u.username);
    _bioController = TextEditingController(text: u.bio);
    _pronounsController = TextEditingController();
    _gender = u.gender;
    _profileImagePath = u.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _pronounsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.black),
                title: const Text('Take a photo'),
                onTap: () async {
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _profileImagePath = pickedFile.path;
                    });
                  }
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.black,
                ),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _profileImagePath = pickedFile.path;
                    });
                  }
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectGender() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Select Gender',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Male'),
              trailing: _gender == 'Male'
                  ? const Icon(Icons.check, color: AppColors.blue)
                  : null,
              onTap: () {
                setState(() => _gender = 'Male');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Female'),
              trailing: _gender == 'Female'
                  ? const Icon(Icons.check, color: AppColors.blue)
                  : null,
              onTap: () {
                setState(() => _gender = 'Female');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Other'),
              trailing: _gender == 'Other'
                  ? const Icon(Icons.check, color: AppColors.blue)
                  : null,
              onTap: () {
                setState(() => _gender = 'Other');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Not specified'),
              trailing: _gender == 'Not specified'
                  ? const Icon(Icons.check, color: AppColors.blue)
                  : null,
              onTap: () {
                setState(() => _gender = 'Not specified');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    // Update current user
    DummyData.currentUser
      ..name = _nameController.text.trim()
      ..username = _usernameController.text.trim()
      ..bio = _bioController.text.trim()
      ..gender = _gender
      ..profileImage = _profileImagePath ?? DummyData.currentUser.profileImage;

    // ✅ FIX: Also update the user in the users list if exists
    final userIndex = DummyData.users.indexWhere(
      (u) => u.id == DummyData.currentUser.id,
    );
    if (userIndex != -1) {
      DummyData.users[userIndex] = DummyData.currentUser;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final imageToShow = _profileImagePath ?? widget.user.profileImage;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _saveProfile();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () {
              _saveProfile();
            },
          ),
          title: const Text(
            'Edit profile',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 24),
            // Profile pictures section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: UniversalImage(
                        imagePath: imageToShow,
                        fit: BoxFit.cover,
                        placeholder: Container(
                          color: AppColors.grey300,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: Container(
                          color: AppColors.grey200,
                          child: const Icon(Icons.person, size: 40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  ClipOval(
                    child: Container(
                      width: 80,
                      height: 80,
                      color: AppColors.grey200,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.grey400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _pickImage,
                child: const Text(
                  'Change profile picture',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('Name', _nameController, widget.user.name),
                  const SizedBox(height: 12),
                  _buildInputField(
                    'Username',
                    _usernameController,
                    widget.user.username,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField('Pronouns', _pronounsController, ''),
                  const SizedBox(height: 12),
                  _buildInputField(
                    'Bio',
                    _bioController,
                    widget.user.bio,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Add Link
                  const Text(
                    'Add Link',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 20),

                  // Banners
                  _buildMenuRow('Banners', showBadge: true, badgeCount: '1'),
                  const SizedBox(height: 12),

                  // Gender
                  _buildGenderField(),
                  const SizedBox(height: 20),

                  // Show Threads banner
                  _buildThreadsBanner(),
                  const SizedBox(height: 24),

                  // Profile information section
                  const Text(
                    'Profile information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  _buildMenuRow('Page', trailingText: 'Connect or create'),
                  const SizedBox(height: 4),
                  _buildMenuRow('Category', trailingText: 'Photographer'),
                  const SizedBox(height: 4),
                  _buildMenuRow('Contact options'),
                  const SizedBox(height: 20),

                  _buildMenuRow('Action buttons', trailingText: 'None active'),
                  const SizedBox(height: 4),
                  _buildMenuRow('Profile display', trailingText: 'All hidden'),
                  const SizedBox(height: 4),
                  _buildMenuRow(
                    'Music',
                    trailingText: 'Add music to your profile',
                  ),
                  const SizedBox(height: 24),

                  // Bottom links
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: const Text(
                      'Personal information settings',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: const Text(
                      'Show that your profile is verified',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String placeholder, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.grey600, fontSize: 14),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey300!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey300!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return InkWell(
      onTap: _selectGender,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey300!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender',
              style: TextStyle(color: AppColors.grey600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _gender,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                ),
                Icon(Icons.keyboard_arrow_down, color: AppColors.grey400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Show Threads banner',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 4),
                Text(
                  'When turned off, the Instagram badge on your Threads profile will also disappear.',
                  style: TextStyle(fontSize: 13, color: AppColors.grey600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: _showThreadsBanner,
            onChanged: (value) {
              setState(() {
                _showThreadsBanner = value;
              });
            },
            activeThumbColor: AppColors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(
    String title, {
    String? trailingText,
    bool showBadge = false,
    String? badgeCount,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            Row(
              children: [
                if (showBadge && badgeCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeCount,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                if (trailingText != null)
                  Text(
                    trailingText,
                    style: TextStyle(fontSize: 16, color: AppColors.grey600),
                  ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: AppColors.grey400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
