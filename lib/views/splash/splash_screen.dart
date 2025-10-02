import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';
import 'package:instagram/core/constants/app_images.dart';
import 'package:instagram/views/Home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        //To  check if widget is still in tree and not disposed
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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
                      color: Colors.black54,
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
