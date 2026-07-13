// Stub NavScreen — mobile nav bar not fully included in demo_app.
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/nav_bar/presentation/ui/pages/more_page.dart';
import 'package:demo_app/features/home/nav_bar/presentation/controller/nav_bar_controller.dart';
import 'package:demo_app/features/roles/system_logs/controller/system_logs_controller.dart';


export 'package:demo_app/features/home/nav_bar/presentation/ui/pages/more_page.dart';

// Global accessor used by event controllers — lazy so it resolves after registration
SystemLogsController get systemLogsController => Get.find<SystemLogsController>();

// GRC theme controller global used by tracking/attendance components
ThemeController themeController = Get.put(ThemeController());

class NavScreen extends StatelessWidget {
  const NavScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // MorePage (and CustomAppBarMobile) call Get.find<NavBarController>(),
    // so make sure it is registered before they build.
    if (!Get.isRegistered<NavBarController>()) {
      Get.put(NavBarController());
    }
    return const MorePage();
  }
}
