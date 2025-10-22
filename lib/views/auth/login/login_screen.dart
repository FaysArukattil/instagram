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
  bool _isLoading = false;

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

  // Validation Methods
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username, email or mobile number is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 3) {
      return 'Must be at least 3 characters';
    }

    if (!_isValidEmail(trimmedValue) &&
        !_isValidPhone(trimmedValue) &&
        !_isValidUsername(trimmedValue)) {
      return 'Invalid format. Use username, email or phone';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }

    final password = value.trim();

    // Check length
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Must contain at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Must contain at least one number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    // Must contain at least one special character
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Helper validation methods
  bool _isValidEmail(String value) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(value);
  }

  bool _isValidPhone(String value) {
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    return phoneRegex.hasMatch(value);
  }

  bool _isValidUsername(String value) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9._]{3,30}$');
    return usernameRegex.hasMatch(value);
  }

  Future<void> handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final username = usernameController.text.trim();
      final password = passwordController.text.trim();

      await Future.delayed(const Duration(milliseconds: 800));

      final pref = await SharedPreferences.getInstance();
      await pref.setString("username", username);
      await pref.setString("password", password);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBarScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Login Error',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
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
                        color: AppColors.black,
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
                style: const TextStyle(fontSize: 16, color: AppColors.black),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.blue : AppColors.grey,
                  width: 2,
                ),
                color: isSelected ? AppColors.blue : AppColors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            // Responsive padding
            final horizontalPadding = isTablet
                ? constraints.maxWidth * 0.15
                : constraints.maxWidth * 0.05;

            // Responsive logo size
            final logoSize = isTablet
                ? constraints.maxWidth * 0.15
                : constraints.maxWidth * 0.35;

            // Responsive spacing
            final topSpacing = isLandscape
                ? constraints.maxHeight * 0.01
                : constraints.maxHeight * 0.02;

            final logoTopSpacing = isLandscape
                ? constraints.maxHeight * 0.02
                : constraints.maxHeight * 0.08;

            final logoBottomSpacing = isLandscape
                ? constraints.maxHeight * 0.02
                : constraints.maxHeight * 0.08;

            final fieldSpacing = isLandscape
                ? constraints.maxHeight * 0.01
                : constraints.maxHeight * 0.015;

            final buttonSpacing = isLandscape
                ? constraints.maxHeight * 0.015
                : constraints.maxHeight * 0.025;

            final bottomSpacing = isLandscape
                ? constraints.maxHeight * 0.03
                : constraints.maxHeight * 0.15;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: topSpacing),

                        // Language Selector
                        GestureDetector(
                          onTap: _showLanguageBottomSheet,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                selectedLanguage,
                                style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.darkGrey,
                                size: isTablet ? 24 : 20,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: logoTopSpacing),

                        // Logo
                        Image.asset('assets/images/icon.png', width: logoSize),
                        SizedBox(height: logoBottomSpacing),

                        // Form - constrained width for tablets
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 500 : double.infinity,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                AuthTextField(
                                  label:
                                      'Username, email address or mobile number',
                                  controller: usernameController,
                                  validator: _validateUsername,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                ),
                                SizedBox(height: fieldSpacing),
                                AuthTextField(
                                  label: 'Password',
                                  isPassword: true,
                                  controller: passwordController,
                                  validator: _validatePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => handleLogin(),
                                ),
                                SizedBox(height: buttonSpacing),
                              ],
                            ),
                          ),
                        ),

                        // Buttons - constrained width for tablets
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 500 : double.infinity,
                          ),
                          child: Column(
                            children: [
                              // Primary login button with loading state
                              _isLoading
                                  ? SizedBox(
                                      height: isTablet ? 52 : 48,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.blue,
                                        ),
                                      ),
                                    )
                                  : PrimaryButton(
                                      text: 'Log in',
                                      onPressed: handleLogin,
                                      height: isTablet ? 52 : 48,
                                    ),
                              SizedBox(height: buttonSpacing),

                              // Forgot Password
                              IgnorePointer(
                                ignoring: _isLoading,
                                child: GestureDetector(
                                  onTap: () {
                                    if (!_isLoading) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Forgotscreen(),
                                        ),
                                      );
                                    }
                                  },
                                  child: Opacity(
                                    opacity: _isLoading ? 0.5 : 1.0,
                                    child: Text(
                                      'Forgotten password?',
                                      style: TextStyle(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: isTablet ? 16 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: bottomSpacing),

                        // Secondary button - constrained width for tablets
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 500 : double.infinity,
                          ),
                          child: IgnorePointer(
                            ignoring: _isLoading,
                            child: Opacity(
                              opacity: _isLoading ? 0.5 : 1.0,
                              child: SecondaryButton(
                                text: 'Create new account',
                                height: isTablet ? 52 : 48,
                                onPressed: () {
                                  if (!_isLoading) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EmailAddressPage(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Meta logo
                        Image.asset(
                          AppImages.metalogo,
                          width: isTablet ? 100 : 80,
                          height: isTablet ? 100 : 80,
                        ),
                        SizedBox(height: topSpacing),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
