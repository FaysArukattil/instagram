import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/views/auth/auth_widgets/auth_textfield_widget.dart';
import 'package:instagram/views/auth/signup/signup_detailpage_logininfo.dart';
import 'package:instagram/widgets/primary_button.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isValid = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = _passwordController.text;

    setState(() {
      _errorMessage = null;

      if (password.isEmpty) {
        _isValid = false;
        return;
      }

      if (password.length < 8) {
        _isValid = false;
        _errorMessage = 'Password must be at least 8 characters';
        return;
      }

      final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      if (!hasLowercase) {
        _isValid = false;
        _errorMessage = 'Password must contain at least one lowercase letter';
        return;
      }

      final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      if (!hasUppercase) {
        _isValid = false;
        _errorMessage = 'Password must contain at least one uppercase letter';
        return;
      }

      final hasNumber = RegExp(r'[0-9]').hasMatch(password);
      if (!hasNumber) {
        _isValid = false;
        _errorMessage = 'Password must contain at least one number';
        return;
      }

      final hasSpecialChar = RegExp(
        r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/;~`]',
      ).hasMatch(password);
      if (!hasSpecialChar) {
        _isValid = false;
        _errorMessage = 'Password must contain at least one special character';
        return;
      }

      _isValid = true;
      _errorMessage = null;
    });
  }

  void _handleNext() {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Password is required';
      });
      return;
    }

    if (_isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SaveLoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Create a password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Create a password with at least 8 characters including one uppercase letter, one lowercase letter, one number, and one special character.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: screenHeight * 0.4),
                PrimaryButton(
                  text: 'Next',
                  onPressed: _isValid ? _handleNext : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
