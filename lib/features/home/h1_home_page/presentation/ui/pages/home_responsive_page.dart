/// Fixed HomeResponsivePage that properly handles resize
///
/// This widget:
/// 1. Detects when screen size changes
/// 2. Cleans up the wrong controller
/// 3. Shows the correct layout (mobile or tablet)

import 'package:flutter/material.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/pages/home_screen.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/home/main_controller/core_widgets/main_widget/custom_appbar.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/pages/role_management_home.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/schedule_controller.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/skeleton_home_controller.dart';
import 'package:grc_module/features/home/main_controller/helper/todo_new_module/todo_stub.dart';
import 'package:grc_module/features/home/main_controller/helper/events/events_stub.dart';

// Import the controllers
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';

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
    // ScheduleController's constructor calls Get.find() for these stub
    // controllers, so they must be registered BEFORE it is created.
    if (!Get.isRegistered<TodoController>()) {
      Get.put(TodoController());
    }
    if (!Get.isRegistered<EventsEmployeeController>()) {
      Get.put(EventsEmployeeController());
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

    // Single page now; HomeScreen branches on form factor internally.
    //
    // On tablet/desktop the home module sits inside the drawer shell's
    // IndexedStack, so a plain Navigator.push from here would cover the whole
    // window — sidebar and app bar included. Hosting a nested Navigator means
    // pages pushed from home (the Calendar screen, for example) render inside
    // the content area and keep the frame, which is the same pattern the
    // settings and services modules use.
    if (!isTablet) return const HomeScreen();

    return Navigator(
      key: homeNavKey,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  void _handleSizeChange(bool isNowTablet) {
    print('🔧 [HOME-RESPONSIVE] Handling size change to ${isNowTablet ? 'tablet' : 'mobile'}');

    if (isNowTablet) {
      // Switched to tablet - remove NavBarCubit
      if (Get.isRegistered<NavBarCubit>()) {
        print('🗑️ [HOME-RESPONSIVE] Removing NavBarCubit');
        Get.delete<NavBarCubit>(force: true);
      }

      // Initialize AppDrawerCubit if needed
      if (!Get.isRegistered<AppDrawerCubit>()) {
        print('✅ [HOME-RESPONSIVE] Initializing AppDrawerCubit');
        Get.put(AppDrawerCubit());
      }
    } else {
      // Switched to mobile - remove AppDrawerCubit
      if (Get.isRegistered<AppDrawerCubit>()) {
        print('🗑️ [HOME-RESPONSIVE] Removing AppDrawerCubit');
        Get.delete<AppDrawerCubit>(force: true);
      }

      // Initialize NavBarCubit if needed
      if (!Get.isRegistered<NavBarCubit>()) {
        print('✅ [HOME-RESPONSIVE] Initializing NavBarCubit');
        Get.put(NavBarCubit());
      }
    }

    // Force rebuild
    if (mounted) {
      setState(() {});
    }
  }
}