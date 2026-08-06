import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/onboarding/o3_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:grc_module/features/onboarding/o3_authentication/presentation/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/helper/main_helper/biometric_controller.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isUsebiometrics = false;

  @override
  void initState() {
    print("entered splash screen");
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    _animation.addStatusListener((status) async {
      print("in the spalsh screen");

      if (status == AnimationStatus.completed) {
        print("🎬 Animation completed - determining navigation...");

        // Check onboarding status
        final onboardingCompleted = storage.read('onboarding') == 'true';
        print("📋 Onboarding completed: $onboardingCompleted");

        // Check biometrics status
        final loginController = Get.find<LoginController>();
        final useBiometrics = loginController.isUseBiometrics;
        final hasCredentials = storage.read('email') != null;

        print("🔐 Use biometrics: $useBiometrics");
        print("🔐 Has saved credentials: $hasCredentials");

        // Biometrics will handle auto-login in LoginController.signWithBiometrics()
        // So if biometrics is enabled with credentials, just wait for it
        if (useBiometrics && hasCredentials) {
          print("🔐 Biometrics enabled with credentials - waiting for auto-login");
          // signWithBiometrics() was already called in LoginController.onInit()
          // It will handle navigation, so we just return here
          return;
        }

        // Navigate based on onboarding status
        print("🎬 Navigating to ${onboardingCompleted ? 'login' : 'onboarding'} screen");
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => onboardingCompleted
              ? const SignInScreen()
              : const WelcomeView(),
        ));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: SizedBox(
            width: isPortrait ? 0.15.h : 0.25.h,
            height: storage.read('logo') == null
                ? 0.15.h
                : isPortrait
                ? 0.15.h
                : 0.25.h,
            child: storage.read('logo') == null
                ? SvgPicture.asset(
              themeController.currentTheme == AppColors.darkTheme
                  ? 'assets/icons_assets/main_icons_assets/knowticed_logo_dark.svg'
                  : 'assets/icons_assets/main_icons_assets/knowticed_logo.svg',
              //   fit: BoxFit.fill,
            )
                : SvgPicture.network(
              storage.read('logo'),
              // fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}