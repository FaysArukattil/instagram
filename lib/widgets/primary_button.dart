import 'package:flutter/material.dart';
import 'package:instagram/core/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;

  const PrimaryButton({
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.blue
              : AppColors.blue.withValues(alpha: 0.3),
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.blue.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          shadowColor: AppColors.transparent,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
