import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/core/constants/app_images.dart';
import 'package:instagram/views/auth/auth_widgets/auth_textfield_widget.dart';
import 'package:instagram/views/auth/forgot/forgotscreen.dart';
import 'package:instagram/views/auth/signup/signup_with_email.dart';
import 'package:instagram/views/bottomnavbarscreens/bottomnavbarscreen.dart';
import 'package:instagram/widgets/primary_button.dart';
import 'package:instagram/widgets/secondary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String selectedLanguage = 'English (UK)';

  @override
  void initState() {
    super.initState();
    usernameController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (usernameController.text.isEmpty) {
      _showValidationDialog(
        'Enter your username, email address or mobile number to log in',
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      _showValidationDialog('Please enter your password');
      return;
    }

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final pref = await SharedPreferences.getInstance();

    pref.setString("username", username);
    pref.setString("password", password);

    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => BottomNavBarScreen()),
    );
  }

  void _showValidationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: AppColors.black),
            textAlign: TextAlign.center,
          ),
        ),
        actionsPadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to create account page if needed
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'CREATE NEW ACCOUNT',
                      style: const TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ensures no overflow
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select your language',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildLanguageOption('English (US)'),
                        _buildLanguageOption('Afrikaans'),
                        _buildLanguageOption('Bahasa Indonesia'),
                        _buildLanguageOption('Bahasa Melayu'),
                        _buildLanguageOption('Dansk'),
                        _buildLanguageOption('Deutsch'),
                        _buildLanguageOption('English (UK)'),
                        _buildLanguageOption('Español'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = selectedLanguage == language;
    return InkWell(
      onTap: () {
        setState(() {
          selectedLanguage = language;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.blue : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppColors.blue : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),

                // Language Selector
                GestureDetector(
                  onTap: _showLanguageBottomSheet,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedLanguage,
                        style: const TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.darkGrey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.08),

                // Logo
                Image.asset(
                  'assets/images/icon.png',
                  width: screenWidth * 0.35,
                ),
                SizedBox(height: screenHeight * 0.08),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        label: 'Username, email address or mobile number',
                        controller: usernameController,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      AuthTextField(
                        label: 'Password',
                        isPassword: true,
                        controller: passwordController,
                      ),
                      SizedBox(height: screenHeight * 0.025),
                    ],
                  ),
                ),

                // Primary login button
                PrimaryButton(text: 'Log in', onPressed: handleLogin),
                SizedBox(height: screenHeight * 0.025),

                // Forgot Password
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Forgotscreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgotten password?',
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.15),

                // Secondary button
                SecondaryButton(
                  text: 'Create new account',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailAddressPage(),
                      ),
                    );
                  },
                ),

                // Meta logo
                Image.asset(AppImages.metalogo, width: 80, height: 80),
                const SizedBox(width: 8),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
