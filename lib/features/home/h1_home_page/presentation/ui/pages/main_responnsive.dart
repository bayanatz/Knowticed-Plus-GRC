import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/ui/pages/custom_drawer.dart';
// Real bottom-nav NavScreen (PersistentTabView), not the stub in
// onboarding/authentication/welcome_screen which only shows MorePage.
import 'package:grc_module/features/home/h2_nav_bar/presentation/ui/pages/nav_screen.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';

/// Main Responsive Screen
///
/// This widget switches between CustomDrawer (desktop/tablet) and NavScreen (mobile)
/// based on screen width, and properly manages controller lifecycle during resize
class MainResponsiveScreen extends StatefulWidget {
  const MainResponsiveScreen({Key? key}) : super(key: key);

  @override
  State<MainResponsiveScreen> createState() => _MainResponsiveScreenState();
}

class _MainResponsiveScreenState extends State<MainResponsiveScreen> {
  bool? _wasMobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double MOBILE_BREAKPOINT = 600;
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < MOBILE_BREAKPOINT;

        print('🏗️ [MAIN-RESPONSIVE] Building with width: $screenWidth');
        print('🏗️ [MAIN-RESPONSIVE] Is mobile: $isMobile');

        // ✅ Detect size change
        if (_wasMobile != null && _wasMobile != isMobile) {
          print('🔄 [MAIN-RESPONSIVE] Size changed: ${_wasMobile! ? 'mobile' : 'desktop'} → ${isMobile ? 'mobile' : 'desktop'}');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleResize(isMobile);
          });
        }

        _wasMobile = isMobile;

        // ✅ Show appropriate layout
        if (isMobile) {
          print('📱 [MAIN-RESPONSIVE] Showing mobile layout (NavScreen)');
          return const NavScreen();
        } else {
          print('🖥️ [MAIN-RESPONSIVE] Showing desktop layout (CustomDrawer)');
          return CustomDrawer();
        }
      },
    );
  }

  void _handleResize(bool isMobile) {
    print('🔧 [MAIN-RESPONSIVE] Handling resize to ${isMobile ? 'mobile' : 'desktop'}');

    if (isMobile) {
      // Switched to mobile - clean up drawer, add navbar
      if (Get.isRegistered<AppDrawerCubit>()) {
        print('🗑️ [MAIN-RESPONSIVE] Removing AppDrawerCubit');
        Get.delete<AppDrawerCubit>(force: true);
      }

      if (!Get.isRegistered<NavBarCubit>()) {
        print('✅ [MAIN-RESPONSIVE] Initializing NavBarCubit');
        Get.put(NavBarCubit());
      }
    } else {
      // Switched to desktop - clean up navbar, add drawer
      if (Get.isRegistered<NavBarCubit>()) {
        print('🗑️ [MAIN-RESPONSIVE] Removing NavBarCubit');
        Get.delete<NavBarCubit>(force: true);
      }

      if (!Get.isRegistered<AppDrawerCubit>()) {
        print('✅ [MAIN-RESPONSIVE] Initializing AppDrawerCubit');
        Get.put(AppDrawerCubit());
      }
    }

    // Force rebuild
    if (mounted) {
      setState(() {});
    }
  }
}