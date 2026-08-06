import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/svg_custom.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';

import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/home/main_controller/core_widgets/dialogs/custom_logout_dialog.dart';
import 'package:grc_module/features/home/main_controller/core_widgets/main_widget/custom_appbar.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/employees/employees_views/employee_attendance.dart';
// REMOVED_MODULE: import 'package:grc_module/feature/notification/notification_screen.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/start_sign_in.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/navigate.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:grc_module/main.dart';
import 'package:grc_module/core/theme/theme_controller.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/pages/no_internet_screen.dart';
import 'package:page_transition/page_transition.dart';

// REMOVED_MODULE: import '../../../../../external/calender/calendar_screen.dart';
import 'package:grc_module/features/notification/presentation/ui/pages/notification_page.dart';
import 'package:grc_module/features/notification/presentation/ui/pages/clear_page_notification.dart';
import 'package:grc_module/features/notification/presentation/ui/pages/pin_notification.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/pages/role_management_home.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
import '../../../../../../core/custom/33-custom_haptic.dart';
import '../../controller/app_drawer_cubit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import '../../utils/app_drawer_update_ids.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
// Global RxBool to control reordering from anywhere in the app
final RxBool isDrawerReorderingActive = false.obs;

class CustomDrawer extends StatefulWidget {
  CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final ThemeController themeController = Get.find<ThemeController>();
  final SystemLogsController systemLogsController = Get.find<SystemLogsController>();
  final GetStorage storage = GetStorage();
  AppDrawerCubit appDrawerController = Get.put(AppDrawerCubit());
  List<Widget> screens = [];
  int? draggingIndex;
  String appVersion = '';
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _menuItemsKey = GlobalKey();

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
    _loadAppVersion();
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

  Future<void> _loadAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = 'v${packageInfo.version}';
      });
    } catch (e) {
      setState(() {
        appVersion = '';
      });
    }
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
        isDrawerReorderingActive.value;
  }

  void _onItemTapped(int index) {
    if (isDrawerReorderingActive.value) return;

    hapticController.triggerHapticFeedback(
        vibration: VibrateType.lightImpact,
        hapticFeedback: HapticFeedback.lightImpact);

    if (index == appDrawerController.allowedDrawerModules.length) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomLogOutDialogBox(
            title: "Sign Out",
            subtitle: "Are You Sure You Want To Sign Out?",
            imagePath: "assets/lottie_assets/home_lottie_assets/newLogOut.json",
            backgroundColor: AppColors.primary,
            showButtons: true,
            buttonText: 'Yes',
            buttoncolor: AppColors.primary,
            buttonFontColor: AppColors.textButton,
            onConfirm: () {
              hapticController.triggerHapticFeedback(
                  vibration: VibrateType.heavyImpact,
                  hapticFeedback: HapticFeedback.heavyImpact);
              systemLogsController.systemLogsAction('logout');
              // AppDrawerCubit.isHr = false;
              // AppDrawerCubit.isOwner = false;
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const Onboarding(),
                ),
                    (Route<dynamic> route) => false,
              );
            },
          );
        },
      );
    } else {
      appDrawerController.updateSelectedIndex(index);
      String moduleName =
      appDrawerController.drawerTitles[index].toLowerCase();
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
      } else if (moduleName.contains('to do') ||
          moduleName.contains('قائمة')) {
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
      }
    }
  }

  void _moveItem(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    setState(() {
      final modules =
      List<Modules>.from(appDrawerController.allowedDrawerModules);
      final item = modules.removeAt(oldIndex);
      modules.insert(newIndex, item);

      appDrawerController.saveCustomOrder(modules);
      screens = appDrawerController.drawerItems;

      if (appDrawerController.selectedIndex == oldIndex) {
        appDrawerController.updateSelectedIndex(newIndex);
      } else if (oldIndex < appDrawerController.selectedIndex &&
          newIndex >= appDrawerController.selectedIndex) {
        appDrawerController
            .updateSelectedIndex(appDrawerController.selectedIndex - 1);
      } else if (oldIndex > appDrawerController.selectedIndex &&
          newIndex <= appDrawerController.selectedIndex) {
        appDrawerController
            .updateSelectedIndex(appDrawerController.selectedIndex + 1);
      }
    });

    hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final background = Theme.of(context).colorScheme.inversePrimary;
    final orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return OfflineBuilder(
      connectivityBuilder:
          (BuildContext context, ConnectivityResult connectivity, Widget child) {
        bool connected = connectivity != ConnectivityResult.none;
        return Stack(
          children: [
            child,
            if (!connected)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.5),
                  child: const NoInternetScreen(
                      backgroundColor: Colors.transparent),
                ),
              ),
          ],
        );
      },
      child: BlocProvider<AppHomeCubit>(
        create: (context) => AppHomeCubit(),
        child: Scaffold(
          body: Container(
            color: AppColors.card,
            child: BlocBuilder<AppDrawerCubit, AppDrawerState>(
              bloc: Get.find<AppDrawerCubit>(),
              builder: (context, _) {
                final controller = Get.find<AppDrawerCubit>();
                screens = appDrawerController.drawerItems;

                return Row(
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
                            children: [
                              _buildLogoContainer(orientation),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Expanded(
                            child: _buildMenuItems(orientation),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: orientation ? 10.h : 15.h),
                            child: _buildMenuItem(
                              orientation,
                              appDrawerController.allowedDrawerModules.length,
                              'assets/icons_assets/home_assets/logout_arrow.svg',
                              S.of(context).logOut,
                              isLogout: true,
                            ),
                          ),
                          if (appVersion.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(
                                top: 8.h,
                                bottom: 12.h,
                              ),
                              child: Text(
                                appVersion,
                                style: StyleText.fontSize12Weight500.copyWith(
                                  color: Theme.of(context).brightness ==
                                      Brightness.light
                                      ? AppColors.blackButton
                                      : AppColors.white,
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
                          if (controller.selectedIndex == 19)
                            Expanded(child: NotificationLandPage()),
                          if (controller.selectedIndex == 20)
                            Expanded(child: CleanedNotificationLandPage()),
                          if (controller.selectedIndex == 21)
                            Expanded(child: PinNotificationLandPage()),
                          if (controller.selectedIndex !=
                              appDrawerController
                                  .allowedDrawerModules.length &&
                              controller.selectedIndex != 18 &&
                              controller.selectedIndex != 19 &&
                              controller.selectedIndex != 20 &&
                              controller.selectedIndex != 21)
                            Expanded(
                              child: IndexedStack(
                                index: controller.selectedIndex,
                                children: screens,
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoContainer(bool orientation) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Center(
        child: CircleAvatar(
          radius: 40.w,
          backgroundColor: Colors.transparent,
          child: storage.read('logo') == null
              ? SvgPicture.asset(
            lightMode
                ? "assets/icons_assets/home_assets/new_size_logo.svg"
                : "assets/icons_assets/main_icons_assets/knowticed_logo_dark.svg",
            width: 60.w,
            height: 60.w,
            fit: BoxFit.contain,
          )
              : SvgPicture.network(
            storage.read('logo'),
            width: 60.w,
            height: 60.w,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems(bool orientation) {
    return Obx(() {
      final isReorderingActiveValue = isDrawerReorderingActive.value;
      print(
          '🔄 Obx rebuild - isDrawerReorderingActive.value: $isReorderingActiveValue');

      final isReordering = settingsModuleIndex != -1 &&
          appDrawerController.selectedIndex == settingsModuleIndex &&
          isReorderingActiveValue;

      print('🔄 Obx rebuild - isReordering: $isReordering');

      if (isReordering) {
        return ScrollConfiguration(
          behavior:
          ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: AnimatedReorderableListView(
            controller: _scrollController,
            padding: EdgeInsets.only(left: 5.w),
            proxyDecorator:
                (Widget child, int index, Animation<double> animation) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Material(
                  elevation: 10,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  child: child,
                ),
              );
            },
            buildDefaultDragHandles: false,
            key: ValueKey(
                'reorderable_${appDrawerController.selectedIndex}_${isDrawerReorderingActive.value}'),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            items: appDrawerController.allowedDrawerModules,
            // ✅ KEY RULE: The key MUST always be on the ROOT widget returned
            // by itemBuilder. Here Padding is the root, so key goes on Padding.
            // Do NOT pass key to _buildMenuItem when Padding wraps it.
            itemBuilder: (context, i) {
              final itemKey = ValueKey(
                  '${appDrawerController.allowedDrawerModules[i]}_$i');
              return Padding(
                key: itemKey, // ✅ Key on root widget (Padding)
                padding:  EdgeInsets.only(top: 5.h,right: 20.w, left: 10.w),
                child: _buildMenuItem(
                  orientation,
                  i,
                  appDrawerController.drawerIcons[i],
                  appDrawerController.drawerTitles[i],
                  // ✅ No key here — Padding above owns the key
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
        return ScrollConfiguration(
          behavior:
          ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.builder(
            controller: _scrollController,
            key: PageStorageKey('drawer_list_view'),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: appDrawerController.allowedDrawerModules.length,
            itemBuilder: (context, i) {
              return _buildMenuItem(
                orientation,
                i,
                appDrawerController.drawerIcons[i],
                appDrawerController.drawerTitles[i],
                // ✅ Key on Obx (root) when no wrapper — this is correct
                key: ValueKey(
                    '${appDrawerController.allowedDrawerModules[i]}_$i'),
              );
            },
          ),
        );
      }
    });
  }

  Widget _buildMenuItem(
      bool orientation,
      int index,
      String iconPath,
      String title, {
        Key? key,
        bool isLogout = false,
      }) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isSelected =
        appDrawerController.selectedIndex == index && !isLogout;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // ✅ When called from reorder mode (with Padding wrapper): key is null here,
    //    because the Padding is the root and owns the key.
    // ✅ When called from ListView mode (no wrapper): key is passed here,
    //    and Obx becomes the root widget with the key.
    return Obx(
      key: key,
          () {
        final isReorderingActiveValue = isDrawerReorderingActive.value;
        print(
            '🎯 MenuItem Obx rebuild - index: $index, isReorderingActive: $isReorderingActiveValue');

        return GestureDetector(
          onTap: () => _onItemTapped(index),
          child: Container(
            width: orientation ? 40.w : 70.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isReorderingActiveValue && !isLogout
                  ? Border.all(
                  color: AppColors.primary.withOpacity(0.5), width: 1)
                  : null,
            ),
            padding: EdgeInsets.symmetric(
                horizontal: 5.w, vertical: orientation ? 0 : 2.h),
            child: Container(
              decoration: isSelected
                  ? BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.secondaryPrimary,
              )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: SvgPicture.asset(
                      iconPath,
                      width: 26.w,
                      fit: BoxFit.fill,
                      height: 26.h,
                      color: isSelected
                          ? AppColors.secondaryPrimaryText
                          : AppColors.secondaryText,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 8.h, bottom: orientation ? 1.h : 5.h),
                    child: orientation
                        ? SizedBox.shrink()
                        : FittedBox(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style:
                        AppTextStyles.font10BlackCairoMediam.copyWith(
                          color: isSelected
                              ? AppColors.secondaryPrimaryText
                              : AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}