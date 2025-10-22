import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/views/bottomnavbarscreens/bottomnavbarscreen.dart';
import 'package:instagram/widgets/primary_button.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  void _handleAgree(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully!'),
        backgroundColor: AppColors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BottomNavBarScreen()),
      (route) => false,
    );
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
                    "Agree to Instagram's terms and policies",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'People who use our service may have uploaded your contact information to Instagram. ',
                      ),
                      TextSpan(
                        text: 'Learn more',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'By tapping '),
                      const TextSpan(
                        text: 'I agree',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(
                        text:
                            ', you agree to create an account and to Instagram\'s ',
                      ),
                      TextSpan(
                        text: 'Terms',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: ', '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Cookies Policy',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'The '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(
                        text:
                            ' describes the ways we can use the information we collect when you create an account. For example, we use this information to provide, personalise and improve our products, including ads.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.3),
                PrimaryButton(
                  text: 'I agree',
                  onPressed: () => _handleAgree(context),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text(
                      'I already have an account',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
