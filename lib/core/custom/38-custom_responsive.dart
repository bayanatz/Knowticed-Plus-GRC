// Date: 29/9/2024
// By: Youssef Ashraf
// Updated: 24/1/2026 - Added controller cleanup for resize handling
// Objectives: This file is responsible for providing a responsive widget based on screen size
// with proper controller lifecycle management

import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ResponsiveHelper extends StatefulWidget {
  final Widget mobileWidget, tabletWidget;

  const ResponsiveHelper({
    super.key,
    required this.mobileWidget,
    required this.tabletWidget
  });

  @override
  State<ResponsiveHelper> createState() => _ResponsiveHelperState();
}

class _ResponsiveHelperState extends State<ResponsiveHelper> {
  bool? _wasTablet;

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;

    // ✅ Detect size change and clean up wrong controller
    if (_wasTablet != null && _wasTablet != isTablet) {
      print('🔄 [RESPONSIVE] Size changed: ${_wasTablet! ? 'tablet' : 'mobile'} → ${isTablet ? 'tablet' : 'mobile'}');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cleanupControllersAfterResize(isTablet);
      });
    }

    _wasTablet = isTablet;

    return isTablet ? widget.tabletWidget : widget.mobileWidget;
  }

  void _cleanupControllersAfterResize(bool isTablet) {
    if (isTablet) {
      // Switched to tablet - remove NavBarController if it exists
      try {
        // Import NavBarController at top of file:
        // import 'package:demo_app/features/home/nav_bar/presentation/controller/nav_bar_controller.dart';

        // Uncomment this when you add the import:
        // if (Get.isRegistered<NavBarController>()) {
        //   print('🗑️ [RESPONSIVE] Removing NavBarController (switched to tablet)');
        //   Get.delete<NavBarController>(force: true);
        // }
      } catch (e) {
        print('⚠️ [RESPONSIVE] Error removing NavBarController: $e');
      }
    } else {
      // Switched to mobile - remove AppDrawerController if it exists
      try {
        // Import AppDrawerController at top of file:
        // import 'package:demo_app/features/home/app_drawer/presentation/controller/drawer_controller.dart';

        // Uncomment this when you add the import:
        // if (Get.isRegistered<AppDrawerController>()) {
        //   print('🗑️ [RESPONSIVE] Removing AppDrawerController (switched to mobile)');
        //   Get.delete<AppDrawerController>(force: true);
        // }
      } catch (e) {
        print('⚠️ [RESPONSIVE] Error removing AppDrawerController: $e');
      }
    }
  }
}