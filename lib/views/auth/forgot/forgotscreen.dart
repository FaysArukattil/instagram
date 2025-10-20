import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/views/auth/auth_widgets/auth_textfield_widget.dart';
import 'package:instagram/widgets/primary_button.dart';
import 'package:instagram/widgets/secondary_button.dart';

class Forgotscreen extends StatelessWidget {
  const Forgotscreen({super.key});

  void _showInfoDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.06;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title with close button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'To help you find your account, we need more info',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 24),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'Enter your email address or username so that we can use a secure process to help you get back in.',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: AppColors.black87,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: "OK",
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.06;

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
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Title
                Text(
                  "Find your account",
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter your email address or username.",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: AppColors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showInfoDialog(context),
                      child: Text(
                        "Can't reset your password?",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Email/Username TextField
                AuthTextField(label: "Email address or username"),

                const SizedBox(height: 16),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(text: "Continue", onPressed: () {}),
                ),

                const SizedBox(height: 16),

                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Find by mobile number instead",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: AppColors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColors.grey300, thickness: 1),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppColors.grey300, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Facebook Login Button
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    text: "Log In With Facebook",
                    onPressed: () {},
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
