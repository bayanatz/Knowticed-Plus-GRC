/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: custom_drawer.dart
/// Description: Declares `CustomDrawer`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/core/custom/layout/overflow_fade.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/helper/offline_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/svg_custom.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
// The package does not export its drag listeners; they are the only ones
// that start a drag on its list (see _buildMenuItems).
// ignore: implementation_imports
import 'package:animated_reorderable_list/src/component/drag_listener.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_appbar.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/skeleton/employees/employees_views/employee_attendance.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/feature/notification/notification_screen.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/skeleton/authentication/welcome_screen/views/start_sign_in.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/navigate.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/home_responsive_page.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/no_internet_screen.dart';
import 'package:page_transition/page_transition.dart';

// REMOVED_MODULE: import '../../../../../external/calender/calendar_screen.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_page.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/clear_page_notification.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/pin_notification.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_haptic.dart';

import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';

import 'package:get_storage/get_storage.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/ui/widgets/drawer_logo_container.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/ui/widgets/drawer_menu_item.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/ui/widgets/drawer_reorder_button.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final ThemeController themeController = Get.find<ThemeController>();
  final SystemLogsController systemLogsController =
      Get.find<SystemLogsController>();
  final GetStorage storage = GetStorage();
  AppDrawerCubit appDrawerController = Get.put(AppDrawerCubit());
  List<Widget> screens = [];

  /// The module the hidden stack keeps while a notification page shows
  /// (22/10/2026 — see the content area in build).
  int _lastModuleIndex = 0;
  int? draggingIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    appDrawerController.reload();
    var settings = Get.put(SettingsController());
    settings.onInit();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      themeController.initTheme();
    });
    screens = appDrawerController.drawerItems;
    appDrawerController.loadAppVersion();
  }

  @override
  void didUpdateWidget(covariant CustomDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screens = appDrawerController.drawerItems;
  }

  int get settingsModuleIndex {
    for (int i = 0; i < appDrawerController.drawerTitles.length; i++) {
      if (appDrawerController.drawerTitles[i].toLowerCase() == 'settings' ||
          appDrawerController.drawerTitles[i].toLowerCase() == 'الإعدادات') {
        return i;
      }
    }
    return -1;
  }

  bool get isReorderingEnabled {
    return settingsModuleIndex != -1 &&
        appDrawerController.selectedIndex == settingsModuleIndex &&
        appDrawerController.isReorderingActive;
  }

  void _onItemTapped(int index) {
    if (appDrawerController.isReorderingActive) return;

    hapticController.triggerHapticFeedback(
      vibration: VibrateType.lightImpact,
      hapticFeedback: HapticFeedback.lightImpact,
    );

    if (index == appDrawerController.allowedDrawerModules.length) {
      // MIGRATED 22/8/2026: was `CustomLogOutDialogBox`, a one-off dialog
      // widget that duplicated what CustomDialogManager already does — and did
      // it worse: it ignored the `title` and `subtitle` it was handed and
      // printed its own hardcoded ones, took a non-localized `buttonText`, and
      // had no success step. That widget's file is deleted; every confirm flow
      // in the app goes through the one manager now.
      CustomDialogManager.showDialogFlow(
        context: context,
        confirmLottie:
            'assets/lottie_assets/main_lottie_assets/lot_action_logout.json',
        confirmTitle: S.of(context).logout,
        confirmSubtitle: S.of(context).confirmLogout,
        confirmYesText: S.of(context).yes,
        confirmNoText: S.of(context).Cancel,
        onConfirm: () async {
          hapticController.triggerHapticFeedback(
            vibration: VibrateType.heavyImpact,
            hapticFeedback: HapticFeedback.heavyImpact,
          );
          systemLogsController.systemLogsAction('logout');
          return true;
        },
        // No "signed out successfully" dialog: the sign-in screen appearing
        // IS the confirmation, and the extra dialog just added a tap.
        showSuccessDialog: false,
        successLottie:
            'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
        successTitle: S.of(context).logout,
        successSubtitle: S.of(context).signedOutSuccessfully,
        // Navigation runs after the success dialog closes, so sign-in is not
        // pushed underneath it.
        //
        // FIXED 22/8/2026: this used to land on `Onboarding()` — the intro
        // carousel — so signing out replayed the eight welcome slides. The
        // mobile More tab already went to SignInScreen; both agree now.
        onSuccessComplete: () {
          if (!context.mounted) return;
          // 14/10/2026 — KH large-screen report p.4: the drawer kept the
          // module that was open at sign-out, so the NEXT account signed in
          // straight into it before Home loaded. Back to Home (index 0).
          appDrawerController.updateSelectedIndex(0);
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: const SignInScreen(),
            ),
            (Route<dynamic> route) => false,
          );
        },
      );
    } else {
      // 22/10/2026 — Owner: a Home card opened Time Tracker inside Home's own
      // page stack; its main page has no back button and tapping Home here
      // kept it open, so he was stuck. Tapping Home always lands on Home.
      // 22/10/2026 — Owner: EXCEPT after a calendar card opened a module —
      // then Home returns to the Calendar page he came from. Tapping Home
      // while already on Home still goes to the Home page.
      if (appDrawerController.allowedDrawerModules[index] == Modules.home) {
        final bool backToCalendar = NotificationRouting.returnToCalendar &&
            appDrawerController.selectedIndex != index;
        NotificationRouting.returnToCalendar = false;
        if (!backToCalendar) {
          final NavigatorState? homeNav =
              homeNavKey.currentState as NavigatorState?;
          homeNav?.popUntil((Route<dynamic> route) => route.isFirst);
        }
      }
      appDrawerController.updateSelectedIndex(index);
      String moduleName = appDrawerController.drawerTitles[index].toLowerCase();
      if (moduleName.contains('home') || moduleName.contains('الرئيسية')) {
        systemLogsController.systemLogsAction('home');
      } else if (moduleName.contains('task') || moduleName.contains('مهام')) {
        systemLogsController.systemLogsAction('tasks');
      } else if (moduleName.contains('database') ||
          moduleName.contains('قاعدة البيانات')) {
        systemLogsController.systemLogsAction('database');
      } else if (moduleName.contains('employee') ||
          moduleName.contains('موظف')) {
        systemLogsController.systemLogsAction('employees');
      } else if (moduleName.contains('inventory') ||
          moduleName.contains('مخزون')) {
        systemLogsController.systemLogsAction('inventory management');
      } else if (moduleName.contains('role') ||
          moduleName.contains('صلاحيات')) {
        systemLogsController.systemLogsAction('roles');
      } else if (moduleName.contains('to do') || moduleName.contains('قائمة')) {
        systemLogsController.systemLogsAction('to do list');
      } else if (moduleName.contains('request') ||
          moduleName.contains('طلبات')) {
        systemLogsController.systemLogsAction('requests');
      } else if (moduleName.contains('setting') ||
          moduleName.contains('إعدادات')) {
        systemLogsController.systemLogsAction('settings');
      } else if (moduleName.contains('service') ||
          moduleName.contains('خدمات')) {
        systemLogsController.systemLogsAction('services');
      } else if (moduleName.contains('knowledge') ||
          moduleName.contains('المعرفة')) {
        // 14/10/2026 — KH report p.25: opening Knowledge Hub was not logged.
        systemLogsController.systemLogsAction(
          'knowledge hub',
          module: Modules.knowledgeHub,
        );
      }
    }
  }

  void _moveItem(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    setState(() {
      final modules = List<Modules>.from(
        appDrawerController.allowedDrawerModules,
      );
      final item = modules.removeAt(oldIndex);
      modules.insert(newIndex, item);

      appDrawerController.saveCustomOrder(modules);
      screens = appDrawerController.drawerItems;

      if (appDrawerController.selectedIndex == oldIndex) {
        appDrawerController.updateSelectedIndex(newIndex);
      } else if (oldIndex < appDrawerController.selectedIndex &&
          newIndex >= appDrawerController.selectedIndex) {
        appDrawerController.updateSelectedIndex(
          appDrawerController.selectedIndex - 1,
        );
      } else if (oldIndex > appDrawerController.selectedIndex &&
          newIndex <= appDrawerController.selectedIndex) {
        appDrawerController.updateSelectedIndex(
          appDrawerController.selectedIndex + 1,
        );
      }
    });

    hapticController.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context).languageCode == 'ar';
    final orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        List<ConnectivityResult> connectivity,
        Widget child,
      ) {
        bool connected = !connectivity.contains(ConnectivityResult.none);
        return Stack(
          children: [
            child,
            if (!connected)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const NoInternetScreen(
                    backgroundColor: AppColors.transparent,
                  ),
                ),
              ),
          ],
        );
      },
      child: BlocProvider<AppHomeCubit>(
        // init() replaces the old constructor side-effects; HomeResponsivePage
        // later calls initFor(context) to localize the quote.
        create: (context) => AppHomeCubit()..init(),
        child: Scaffold(
          // ── Watermark ──────────────────────────────────────────────────
          // ADDED 26/8/2026, and wrapped HERE — around the whole shell body —
          // rather than around each page.
          //
          // WatermarkLayer was already applied at HomeResponsivePage,
          // RoleScreenHost and the settings shell, but all three of those sit
          // in the CONTENT column of the Row below. That left the two things a
          // screenshot most obviously identifies untouched: the 90.sp sidebar
          // on the leading edge and the CustomAppBar across the top. Wrapping
          // the body means the stamp covers the sidebar, the app bar and the
          // content in one pass, on every module the shell hosts — home,
          // settings, roles, the notification pages, all of them.
          //
          // The inner layers do NOT need removing and are NOT drawn twice:
          // WatermarkLayer publishes a _WatermarkScope and any descendant
          // layer hands its child straight back. The outermost one wins, which
          // is now this one. See watermark_layer.dart.
          //
          // Inside the Scaffold rather than around it, so the layer is laid
          // out against the body's bounded constraints.
          //
          // CHANGED 28/9/2026 (Settings bug report p.1 — "watermark must show
          // only in modules user choose"). This layer used to omit `module`,
          // which means ALWAYS STAMP, and because it is the OUTERMOST layer it
          // won over every module-aware layer inside it — so un-ticking a tile
          // in the Watermark Modules grid changed nothing on desktop/tablet.
          // It now passes the module the sidebar has selected, so the grid
          // decides. The notification pages (indices past the module list)
          // have no tile and keep the always-stamp default.
          body: BlocBuilder<AppDrawerCubit, AppDrawerState>(
            bloc: Get.find<AppDrawerCubit>(),
            builder: (context, _) => WatermarkLayer(
              module: _selectedWatermarkModule(),
              child: Container(
                color: AppColors.card,
                child: BlocBuilder<AppDrawerCubit, AppDrawerState>(
                  bloc: Get.find<AppDrawerCubit>(),
                  builder: (context, _) {
                    final controller = Get.find<AppDrawerCubit>();
                    screens = appDrawerController.drawerItems;

                    // FIXED 17/10/2026: no top safe area — the logo and the
                    // app bar (avatar, name) drew under the iPad status bar
                    // and the avatar sat on the battery %. The card colour
                    // still fills behind the status bar.
                    return SafeArea(
                      bottom: false,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 90.sp,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(0.r),
                                bottomRight: Radius.circular(0.r),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [_buildLogoContainer(orientation)],
                                ),
                                SizedBox(height: 5.h),
                                // Owner 21/10/2026: Reorder sits ABOVE Roles — the first
                                // thing pressed, then the modules are moved. Home Layout only.
                                DrawerReorderButton(
                                  cubit: appDrawerController,
                                  compact: orientation,
                                ),
                                Expanded(child: _buildMenuItems(orientation)),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: orientation ? 10.h : 15.h,
                                  ),
                                  child: _buildMenuItem(
                                    orientation,
                                    appDrawerController
                                        .allowedDrawerModules.length,
                                    'assets/icons_assets/home_assets/ic_action_logout.svg',
                                    S.of(context).logOut,
                                    isLogout: true,
                                  ),
                                ),
                                if (appDrawerController.appVersion.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 8.h,
                                      bottom: 12.h,
                                    ),
                                    child: Text(
                                      appDrawerController.appVersion,
                                      style: StyleText.fontSize12Weight500
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                CustomAppBar(),
                                // 22/10/2026 — Owner: "When I click on a
                                // notification, to see it, there is lag."
                                // The module IndexedStack used to sit behind
                                // `if (selectedIndex >= 0)`, so opening the
                                // bell threw EVERY module page away and View
                                // built them ALL again (an IndexedStack builds
                                // every child) before the target appeared.
                                // The stack now stays mounted, hidden and with
                                // its tickers off, under the notification
                                // pages; View rebuilds only the module it
                                // opens (AppDrawerCubit.remountModulePage).
                                Expanded(
                                  child: Builder(builder: (context) {
                                    final int moduleCount = appDrawerController
                                        .allowedDrawerModules.length;
                                    // FIXED 17/10/2026: was "not 18–21", which
                                    // hid whichever modules sat at positions
                                    // 18–21 (CRM for the admin). The
                                    // notification pages are negative now, so
                                    // any index from 0 up is a module.
                                    final bool showingModule =
                                        controller.selectedIndex >= 0 &&
                                            controller.selectedIndex <
                                                moduleCount;
                                    if (showingModule) {
                                      _lastModuleIndex =
                                          controller.selectedIndex;
                                    }
                                    final int stackIndex = moduleCount == 0
                                        ? 0
                                        : _lastModuleIndex.clamp(
                                            0, moduleCount - 1);
                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        if (moduleCount > 0)
                                          Offstage(
                                            key: const ValueKey<String>(
                                                'shell_module_stack'),
                                            offstage: !showingModule,
                                            child: TickerMode(
                                              enabled: showingModule,
                                              // Page components slide in when
                                              // the module changes (state of
                                              // each module is kept).
                                              child: SlideSwitcher(
                                                triggerValue: stackIndex,
                                                child: IndexedStack(
                                                  index: stackIndex,
                                                  // Moataz 23/10/2026: only
                                                  // the visible module ticks
                                                  // — this is also how a
                                                  // hidden Watermark editor
                                                  // knows to stop hiding the
                                                  // stamp (see NoWatermark).
                                                  children: <Widget>[
                                                    for (int i = 0;
                                                        i < screens.length;
                                                        i++)
                                                      TickerMode(
                                                        // A ValueKey around the
                                                        // page's GlobalKey: the
                                                        // page (KeyedSubtree)
                                                        // already owns that
                                                        // GlobalKey, and using it
                                                        // on its parent too logged
                                                        // "Multiple widgets used
                                                        // the same GlobalKey" on
                                                        // iPad (24/10/2026).
                                                        key: ValueKey<Key?>(
                                                            screens[i].key),
                                                        enabled:
                                                            showingModule &&
                                                                i == stackIndex,
                                                        child: screens[i],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (controller.selectedIndex ==
                                            NotificationRouting.inboxShellIndex)
                                          NotificationLandPage(),
                                        if (controller.selectedIndex ==
                                            NotificationRouting
                                                .clearedShellIndex)
                                          CleanedNotificationLandPage(),
                                        if (controller.selectedIndex ==
                                            NotificationRouting
                                                .pinnedShellIndex)
                                          PinNotificationLandPage(),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The module the sidebar currently shows, for the watermark's per-module
  /// opt-out. Null (always stamp) for the notification pages, which use
  /// negative shell indices and have no tile in the Watermark grid.
  Modules? _selectedWatermarkModule() {
    final int index = appDrawerController.selectedIndex;
    final List<Modules> modules = appDrawerController.allowedDrawerModules;
    if (index < 0 || index >= modules.length) return null;
    return modules[index];
  }

  Widget _buildLogoContainer(bool orientation) =>
      DrawerLogoContainer(logoUrl: storage.read('logo') as String?);

  /// Rail item scale for the current height (see _buildMenuItems).
  double _itemScale = 1;

  Widget _buildMenuItems(bool orientation) {
    return BlocBuilder<AppDrawerCubit, AppDrawerState>(
      bloc: appDrawerController,
      builder: (BuildContext context, AppDrawerState state) {
        final bool isReorderingActiveValue =
            appDrawerController.isReorderingActive;

        final isReordering = settingsModuleIndex != -1 &&
            appDrawerController.selectedIndex == settingsModuleIndex &&
            isReorderingActiveValue;

        if (isReordering) {
          return ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: AnimatedReorderableListView(
              controller: _scrollController,
              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Material(
                    elevation: 10,
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    child: child,
                  ),
                );
              },
              buildDefaultDragHandles: false,
              key: ValueKey(
                'reorderable_${appDrawerController.selectedIndex}_${appDrawerController.isReorderingActive}',
              ),
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              items: appDrawerController.allowedDrawerModules,
              // ✅ KEY RULE: The key MUST always be on the ROOT widget returned
              // by itemBuilder. Here Padding is the root, so key goes on Padding.
              // Do NOT pass key to _buildMenuItem when Padding wraps it.
              itemBuilder: (context, i) {
                // Key = the module itself (an index in the key changed it on
                // every move, so the list could not track the dragged item).
                final itemKey = ValueKey(
                  '${appDrawerController.allowedDrawerModules[i]}',
                );
                final Widget menuItem = _buildMenuItem(
                  orientation,
                  i,
                  appDrawerController.drawerIcons[i],
                  appDrawerController.drawerTitles[i],
                );
                // 18/10/2026 (Moataz: "I cannot drag any of them"): with
                // buildDefaultDragHandles off, nothing started a drag. Each
                // item is now its own handle — press-and-drag with a mouse,
                // long-press-and-drag on a touch screen (so scrolling still
                // works there).
                final bool touch =
                    defaultTargetPlatform == TargetPlatform.iOS ||
                        defaultTargetPlatform == TargetPlatform.android;
                return Padding(
                  key: itemKey, // ✅ Key on root widget (Padding)
                  // Owner 21/10/2026: centred at the item's own width, in line
                  // with the Reorder button above (uneven 10 / 20 sides pushed
                  // every item right and stretched it).
                  padding: EdgeInsets.only(top: 5.h),
                  // 21/10/2026 (Moataz: still could not drag): Flutter's
                  // Reorderable*DragStartListener looks for Flutter's own
                  // reorderable list and found none inside this package's
                  // list, so a press started nothing. The package's own
                  // listeners talk to its list.
                  child: Center(
                    child: touch
                        ? ReorderableGridDelayedDragStartListener(
                            index: i,
                            dragStartDelay: const Duration(milliseconds: 300),
                            child: menuItem,
                          )
                        : ReorderableGridDragStartListener(
                            index: i, child: menuItem),
                  ),
                );
              },
              enterTransition: [FadeIn(), ScaleIn()],
              exitTransition: [FadeIn(), ScaleIn()],
              insertDuration: const Duration(milliseconds: 300),
              removeDuration: const Duration(milliseconds: 300),
              dragStartDelay: const Duration(milliseconds: 300),
              onReorder: (oldIndex, newIndex) {
                _moveItem(oldIndex, newIndex);
              },
              isSameItem: (a, b) => a == b,
            ),
          );
        } else {
          // CHANGED 13/10/2026 (form builder vertical bug report p.36 —
          // "increase padding between icons and expand them on the nav bar"):
          // in portrait the icons sat packed at the top of a tall rail with
          // empty space under them. The spare height is now shared out as a
          // gap between the icons (capped, so a short list does not drift
          // apart). When the icons already fill the rail the gap is 0 and the
          // list scrolls exactly as before.
          return LayoutBuilder(
            builder: (context, constraints) {
              final int count = appDrawerController.allowedDrawerModules.length;
              // Compact (portrait) item: 8.h top pad + 26.sp icon + 9.h bottom.
              final double itemHeight = 8.h + 26.sp + 9.h;
              // 18/10/2026: landscape items (icon + label) shrink so every
              // module fits the rail without scrolling.
              final double labelled = 8.h + 26.sp + 6.h + 14 + 5.h + 4.h;
              _itemScale = (!orientation &&
                      count > 0 &&
                      constraints.maxHeight.isFinite)
                  ? (constraints.maxHeight / count / labelled).clamp(0.6, 1.0)
                  : 1.0;
              double gap = 0;
              if (orientation && count > 0 && constraints.maxHeight.isFinite) {
                gap = ((constraints.maxHeight - count * itemHeight) / count)
                    .clamp(0.0, 36.h)
                    .toDouble();
              }
              // CHANGED 17/10/2026 (macOS resize test): in a short window the
              // list scrolls but nothing showed it — the top / bottom edge now
              // fades while more modules hide there.
              return OverflowFade(
                axis: Axis.vertical,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView.builder(
                    controller: _scrollController,
                    key: PageStorageKey('drawer_list_view'),
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: count,
                    itemBuilder: (context, i) {
                      // Key on the root widget (the Padding), as in reorder mode.
                      return Padding(
                        key: ValueKey(
                          '${appDrawerController.allowedDrawerModules[i]}_$i',
                        ),
                        padding: EdgeInsets.symmetric(vertical: gap / 2),
                        child: _buildMenuItem(
                          orientation,
                          i,
                          appDrawerController.drawerIcons[i],
                          appDrawerController.drawerTitles[i],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildMenuItem(
    bool orientation,
    int index,
    String iconPath,
    String title, {
    Key? key,
    bool isLogout = false,
  }) {
    // The key must sit on the root widget returned here: in reorder mode the
    // Padding wrapper owns it (key is null), in list mode this widget does.
    return DrawerMenuItem(
      key: key,
      cubit: appDrawerController,
      scale: _itemScale,
      compact: orientation,
      index: index,
      iconPath: iconPath,
      title: title,
      isLogout: isLogout,
      onTap: _onItemTapped,
    );
  }
}
