import 'package:flutter/material.dart';
import 'package:demo_app/core/helper/data_grc_module/constant/theme_controller.dart';

///Youssef Ashraf:
///Adding Horizontal animation  to a given child, used in message bubble
class SlideAnimation extends StatefulWidget {
  final Widget child;

  ///reverse the animation to be Down To Up
  final bool? leftToRight;
  final double delay;
  const SlideAnimation({
    super.key,
    required this.child,
    this.leftToRight,
    this.delay = 0.0,
  });

  @override
  SlideAnimationState createState() => SlideAnimationState();
}

class SlideAnimationState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> translateAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    translateAnimation = Tween<Offset>(
      begin: widget.leftToRight ?? false
          ? const Offset(-1, 0)
          : const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );
    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.ease,
      ),
    );
    Future.delayed(Duration(milliseconds: (500 * widget.delay).round()))
        .then((value) {
      startAnimation();
    });
  }

  /// Start the animation. If animations are enabled, reset and play the animation.
  /// Otherwise, set the animation to the final state (i.e. the end of the animation).
  void startAnimation() {
    if (themeController.animationsEnabled.value) {
      // Enable animation: reset and play
      controller
        ..reset()
        ..forward();
    } else {
      // Disable animation: instantly show final state
      controller.value = 1; // Skip to the end value for fade and translate
      translateAnimation = AlwaysStoppedAnimation(Offset.zero);
      fadeAnimation = AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: translateAnimation,
        child: widget.child,
      ),
    );
  }
}
