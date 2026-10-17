/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: main_responsive.dart
/// Purpose: Declares `MainResponsiveScreen`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
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
  const MainResponsiveScreen({super.key});

  @override
  State<MainResponsiveScreen> createState() => _MainResponsiveScreenState();
}

class _MainResponsiveScreenState extends State<MainResponsiveScreen> {
  bool? _wasMobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The app's one phone / tablet rule (kpIsPhoneLayout), so the shell
        // and the pages inside it always agree.
        final bool isMobile = kpIsPhoneLayout(context);

        // CHANGED 17/10/2026 (macOS resize test — red screen when the window
        // went from wide to phone width): the new shell's controller is
        // registered BEFORE that shell builds (it used to come one frame
        // later), the old one is removed after the frame, and each shell has
        // its own key so the old tree is torn down instead of half-reused.
        _ensureController(isMobile);
        if (_wasMobile != null && _wasMobile != isMobile) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleResize(isMobile);
          });
        }

        _wasMobile = isMobile;

        return KeyedSubtree(
          key: ValueKey<bool>(isMobile),
          child: isMobile ? const NavScreen() : CustomDrawer(),
        );
      },
    );
  }

  /// Registers BOTH shells' controllers if missing. Pages outside the shell
  /// (Qiyas CreateModuleController, Org Chart) ask for AppDrawerCubit even in
  /// the phone layout — "AppDrawerCubit not found" (17/10/2026). They are
  /// light, so both always exist.
  void _ensureController(bool isMobile) {
    if (!Get.isRegistered<NavBarCubit>()) Get.put(NavBarCubit());
    if (!Get.isRegistered<AppDrawerCubit>()) Get.put(AppDrawerCubit());
  }

  /// CHANGED 17/10/2026 (macOS resize test — "AppDrawerCubit not found"):
  /// nothing is deleted on a resize any more. Dragging the window across the
  /// phone width and back within a frame or two let a late clean-up delete the
  /// controller the layout on screen had just been given. Both controllers
  /// stay registered (they are light); this only makes sure the one for the
  /// layout showing NOW exists, then rebuilds.
  void _handleResize(bool isMobile) {
    _ensureController(_wasMobile ?? isMobile);
    if (mounted) setState(() {});
  }
}
