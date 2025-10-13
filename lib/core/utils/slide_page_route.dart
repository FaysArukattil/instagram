import 'package:flutter/material.dart';

/// Custom page route for Instagram-style horizontal slide transitions
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final SlideDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.leftToRight,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // Define the begin and end offsets based on direction
           Offset begin;
           Offset end = Offset.zero;

           if (direction == SlideDirection.leftToRight) {
             // Slide from left (for going back)
             begin = const Offset(-1.0, 0.0);
           } else {
             // Slide from right (for going forward)
             begin = const Offset(1.0, 0.0);
           }

           // Use a curved animation for smooth motion
           var curve = Curves.easeInOutCubic;
           var tween = Tween(
             begin: begin,
             end: end,
           ).chain(CurveTween(curve: curve));

           var offsetAnimation = animation.drive(tween);

           // Add slide out animation for the old page
           var reverseTween = Tween(
             begin: Offset.zero,
             end: direction == SlideDirection.leftToRight
                 ? const Offset(0.3, 0.0) // Old page slides right slightly
                 : const Offset(-0.3, 0.0), // Old page slides left slightly
           ).chain(CurveTween(curve: curve));

           var reverseAnimation = secondaryAnimation.drive(reverseTween);

           return SlideTransition(
             position: offsetAnimation,
             child: SlideTransition(position: reverseAnimation, child: child),
           );
         },
         transitionDuration: const Duration(milliseconds: 300),
         reverseTransitionDuration: const Duration(milliseconds: 300),
       );
}

enum SlideDirection { leftToRight, rightToLeft }
