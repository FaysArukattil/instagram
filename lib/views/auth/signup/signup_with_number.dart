import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/views/auth/signup/signup_confirmationpage.dart';
import 'package:instagram/views/auth/signup/signup_with_email.dart';
import 'package:instagram/widgets/primary_button.dart';
import 'package:instagram/widgets/secondary_button.dart';

class MobileNumberPage extends StatefulWidget {
  const MobileNumberPage({super.key});

  @override
  State<MobileNumberPage> createState() => _MobileNumberPageState();
}

class _MobileNumberPageState extends State<MobileNumberPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isValid = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhoneNumber);
  }

  void _validatePhoneNumber() {
    final phone = _phoneController.text.trim();
    setState(() {
      _showError = false;
      _isValid = phone.length >= 10;
    });
  }

  void _handleNext() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ConfirmationCodePage(contact: phone, isEmail: false),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What's your mobile number?",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter the mobile number on which you can be contacted. No one will see this on your profile.",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _showError ? AppColors.red : AppColors.borderGrey,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Mobile number',
                      hintStyle: const TextStyle(
                        color: AppColors.hintGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.018,
                        horizontal: screenWidth * 0.04,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      suffixIcon: _showError
                          ? Padding(
                              padding: EdgeInsets.only(
                                right: screenWidth * 0.03,
                              ),
                              child: Icon(
                                Icons.error,
                                color: AppColors.red,
                                size: 22,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                if (_showError) ...[
                  SizedBox(height: screenHeight * 0.01),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mobile number required.',
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: screenHeight * 0.02),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "You may receive WhatsApp and SMS notifications from us for security and login purposes.",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.hintGrey,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                PrimaryButton(
                  text: 'Next',
                  onPressed: _isValid ? _handleNext : null,
                ),
                SizedBox(height: screenHeight * 0.015),
                SecondaryButton(
                  text: 'Sign up with email address',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailAddressPage(),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'I already have an account',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
