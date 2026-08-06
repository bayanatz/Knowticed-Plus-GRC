// Stub NavScreen — mobile nav bar not fully included in knowticed.
import 'package:grc_module/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/ui/pages/more_page.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';


export 'package:grc_module/features/home/h2_nav_bar/presentation/ui/pages/more_page.dart';

// Global accessor used by event controllers — lazy so it resolves after registration
SystemLogsController get systemLogsController => Get.find<SystemLogsController>();

// GRC theme controller global used by tracking/attendance components
ThemeController themeController = Get.put(ThemeController());

class NavScreen extends StatelessWidget {
  const NavScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // MorePage (and CustomAppBarMobile) call Get.find<NavBarCubit>(),
    // so make sure it is registered before they build.
    if (!Get.isRegistered<NavBarCubit>()) {
      Get.put(NavBarCubit());
    }
    return const MorePage();
  }
}
