/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: role_access.dart
/// Purpose: Declares `RoleAccess`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';
import 'package:get/get.dart';

/// Shared UI state formerly held by `Mode` in mode_changer.dart.
abstract class RoleAccess {
  /// Controller for the persistent bottom nav bar.
  static PersistentTabController controller =
      PersistentTabController(initialIndex: 0);

  /// The root page context of each bottom-bar tab, recorded by `NavScreen`.
  /// ADDED 22/10/2026 — a calendar card on the phone switches to its
  /// module's tab and opens the section / record inside THAT tab's
  /// navigator, so the bar highlights the module, not Home.
  static final Map<Modules, BuildContext> tabContexts =
      <Modules, BuildContext>{};

  /// Function Name: [openInTab]
  ///
  /// Purpose: Switch the bottom bar to [module]'s tab and show its main page.
  /// With [page], that main page is REPLACED by a fresh [page] (the module
  /// opened on a section / record — its own hints put the detail on top, so
  /// Back leads to the module's main page and there is never a second copy
  /// of the module in the tab). [beforeOpen] runs just before [page] is
  /// built, so one-shot hints are read by [page] and not by the tab's old
  /// page. False when [module] has no tab of its own (the caller pushes it).
  static Future<bool> openInTab(
    Modules module, {
    Widget Function()? page,
    VoidCallback? beforeOpen,
  }) async {
    if (!Get.isRegistered<NavBarCubit>()) return false;
    final int tab = Get.find<NavBarCubit>().navBarModules.indexOf(module);
    if (tab == -1) return false;
    controller.jumpToTab(tab);
    if (page == null) {
      await WidgetsBinding.instance.endOfFrame;
      final BuildContext? tabContext = tabContexts[module];
      if (tabContext != null && tabContext.mounted) {
        Navigator.of(tabContext).popUntil((Route<dynamic> r) => r.isFirst);
      }
      return true;
    }
    // A tab not opened yet builds its page on the next frame.
    await WidgetsBinding.instance.endOfFrame;
    final BuildContext? tabContext = tabContexts[module];
    if (tabContext == null || !tabContext.mounted) return true;
    beforeOpen?.call();
    Navigator.of(tabContext).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        // Same name as the tab's own first page, so "back to the tab's main
        // page" (tapping the selected tab) still finds it.
        settings: ModalRoute.of(tabContext)?.settings,
        pageBuilder: (_, __, ___) => Builder(builder: (BuildContext context) {
          tabContexts[module] = context;
          return page();
        }),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (Route<dynamic> route) => false,
    );
    return true;
  }

  /// Function Name: [openInMoreTab]
  ///
  /// Purpose: Open a module that lives under More (no bar tab of its own) the
  /// way the More page does — pushed inside the More tab — so the bar
  /// highlights More and Back returns to the More list. ADDED 22/10/2026
  /// (Owner: the opened module must be the selected one). False when
  /// [module] is not in the More list (the caller pushes it where it is).
  static Future<bool> openInMoreTab(
    Modules module, {
    required Widget Function() page,
    VoidCallback? beforeOpen,
  }) async {
    if (!Get.isRegistered<NavBarCubit>()) return false;
    final NavBarCubit navBar = Get.find<NavBarCubit>();
    final int moreTab = navBar.navBarModules.indexOf(Modules.more);
    if (moreTab == -1 || !navBar.moreListModules.contains(module)) {
      return false;
    }
    controller.jumpToTab(moreTab);
    await WidgetsBinding.instance.endOfFrame;
    final BuildContext? tabContext = tabContexts[Modules.more];
    if (tabContext == null || !tabContext.mounted) return true;
    final NavigatorState navigator = Navigator.of(tabContext);
    navigator.popUntil((Route<dynamic> r) => r.isFirst);
    beforeOpen?.call();
    navigator.push(MaterialPageRoute<void>(builder: (_) => page()));
    return true;
  }

  /// Current step in the multi-page "add new employee" flow.
  static int addNewEmployeeIndex = 0;
}
