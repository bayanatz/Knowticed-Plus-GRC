/// Fixed HomeResponsivePage that properly handles resize
///
/// This widget:
/// 1. Detects when screen size changes
/// 2. Cleans up the wrong controller
/// 3. Shows the correct layout (mobile or tablet)

import 'package:flutter/material.dart';
import 'package:demo_app/features/home/presentation/ui/pages/mobile/home_screen_mobile.dart';
import 'package:demo_app/features/home/presentation/ui/pages/tablet/tablet_home_screen.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_appbar.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/responsive_helper.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/role_management_home.dart';
import '../../controller/schedule_controller.dart';
import '../../controller/skeleton_home_controller.dart';

// Import the controllers
import '../../../app_drawer/presentation/controller/drawer_controller.dart';
import '../../../nav_bar/presentation/controller/nav_bar_controller.dart';

GlobalKey homeNavKey = GlobalKey();

class HomeResponsivePage extends StatefulWidget {
  const HomeResponsivePage({super.key});

  @override
  State<HomeResponsivePage> createState() => _HomeResponsivePageState();
}

class _HomeResponsivePageState extends State<HomeResponsivePage> {
  bool? _wasTablet;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    if (!Get.isRegistered<SkeletonHomeController>()) {
      Get.put(SkeletonHomeController());
    }
    if (!Get.isRegistered<ScheduleController>()) {
      Get.put(ScheduleController());
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Check if current size is tablet
    final isTablet = MediaQuery.of(context).size.width >= 768.0;

    // ✅ Detect size change
    if (_wasTablet != null && _wasTablet != isTablet) {
      print('🔄 [HOME-RESPONSIVE] Size changed: ${_wasTablet! ? 'tablet' : 'mobile'} → ${isTablet ? 'tablet' : 'mobile'}');

      // Clean up wrong controller after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSizeChange(isTablet);
      });
    }

    _wasTablet = isTablet;

    return ResponsiveHelper(
      mobileWidget: HomeScreenMobile(),
      tabletWidget: Navigator(
        key: homeNavKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => TabletHomeScreen(),
          );
        },
      ),
    );
  }

  void _handleSizeChange(bool isNowTablet) {
    print('🔧 [HOME-RESPONSIVE] Handling size change to ${isNowTablet ? 'tablet' : 'mobile'}');

    if (isNowTablet) {
      // Switched to tablet - remove NavBarController
      if (Get.isRegistered<NavBarController>()) {
        print('🗑️ [HOME-RESPONSIVE] Removing NavBarController');
        Get.delete<NavBarController>(force: true);
      }

      // Initialize AppDrawerController if needed
      if (!Get.isRegistered<AppDrawerController>()) {
        print('✅ [HOME-RESPONSIVE] Initializing AppDrawerController');
        Get.put(AppDrawerController());
      }
    } else {
      // Switched to mobile - remove AppDrawerController
      if (Get.isRegistered<AppDrawerController>()) {
        print('🗑️ [HOME-RESPONSIVE] Removing AppDrawerController');
        Get.delete<AppDrawerController>(force: true);
      }

      // Initialize NavBarController if needed
      if (!Get.isRegistered<NavBarController>()) {
        print('✅ [HOME-RESPONSIVE] Initializing NavBarController');
        Get.put(NavBarController());
      }
    }

    // Force rebuild
    if (mounted) {
      setState(() {});
    }
  }
}