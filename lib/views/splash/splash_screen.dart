import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/core/constants/app_images.dart';
import 'package:instagram/views/auth/login/login_screen.dart';
import 'package:instagram/views/bottomnavbarscreens/bottomnavbarscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checklogin();
  }

  Future<void> checklogin() async {
    final pref = await SharedPreferences.getInstance();
    Future.delayed(Duration(seconds: 2), () {
      final isLoggedIn = pref.getBool('is_logged_in') ?? false;
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBarScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: size.height * 0.15),

            // Instagram Logo
            Expanded(
              child: Center(
                child: Image.asset(
                  AppImages.instagramlogo,
                  height: size.height * 0.55,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            //Meta Logo
            Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.05),
              child: Column(
                children: [
                  const Text(
                    "from",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.5,
                      color: AppColors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Image.asset(
                    AppImages.metalogo,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
