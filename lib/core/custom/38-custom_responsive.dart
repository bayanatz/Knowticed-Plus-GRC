// Date: 29/9/2024
// By: Youssef Ashraf
// Updated: 24/1/2026 - Added controller cleanup for resize handling
// Objectives: This file is responsible for providing a responsive widget based on screen size
// with proper controller lifecycle management
import 'package:get/get.dart';



import 'package:flutter/material.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
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
    final isTablet = ContextExtension(context).isTablet;

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
      // Switched to tablet - remove NavBarCubit if it exists
      try {
        // Import NavBarCubit at top of file:
        // import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';

        // Uncomment this when you add the import:
        // if (Get.isRegistered<NavBarCubit>()) {
        //   print('🗑️ [RESPONSIVE] Removing NavBarCubit (switched to tablet)');
        //   Get.delete<NavBarCubit>(force: true);
        // }
      } catch (e) {
        print('⚠️ [RESPONSIVE] Error removing NavBarCubit: $e');
      }
    } else {
      // Switched to mobile - remove AppDrawerCubit if it exists
      try {
        // Import AppDrawerCubit at top of file:
        // import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';

        // Uncomment this when you add the import:
        // if (Get.isRegistered<AppDrawerCubit>()) {
        //   print('🗑️ [RESPONSIVE] Removing AppDrawerCubit (switched to mobile)');
        //   Get.delete<AppDrawerCubit>(force: true);
        // }
      } catch (e) {
        print('⚠️ [RESPONSIVE] Error removing AppDrawerCubit: $e');
      }
    }
  }
}