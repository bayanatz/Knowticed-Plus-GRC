// ignore_for_file: unrelated_type_equality_checks
/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_appbar_mobile.dart
/// Description: Declares `CustomAppBarMobile`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - DEBUG-ONLY test-employee badge
///          (compile-time `kDebugTestEmployeeSwitchBuild`).
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/home/h2_nav_bar/utils/functions.dart';
import 'package:knowticed_plus/core/custom/navigation/notification_bell.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_appbar.dart'
    show appNotificationController;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_state.dart';

// REMOVED_MODULE: import 'package:knowticed_plus/feature/notification/notification_screen_mobile.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/navigate.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/pages/settings_screen.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ADDED 9/10/2026 — DEBUG-ONLY test-employee badge.
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/widgets/debug_test_employee_widgets.dart';

//Date:April/3/2023
//by: Bassem Mohamed
//lastUpdate:April/17/2023
//Updated by: Amr Mesbah - Fixed logo to show custom logo in both light and dark mode

class CustomAppBarMobile extends StatefulWidget {
  const CustomAppBarMobile({
    super.key,
    this.title,
    this.isEdit = false,
    this.isHome = false,
    this.isMessage = false,
    this.isYellowContainer = false,
    this.onPressed,
    this.onIconPressed,
    this.imagePath,
    this.showMoreIcon = false,
    this.onTapUp,
    required this.showIcon,
    this.isEmployees = false,
    this.isProject = false,
    this.isStack = false,
    this.stackPhoto,
    this.upPhoto,
    this.isTwoOptions = false,
    this.rowTwoOptions,
    this.showNotification = false,
  });

  final String? title;
  final String? imagePath;
  final bool showIcon;
  final bool? isEdit;
  final bool? isMessage;
  final bool? isHome;
  final bool? isYellowContainer;
  final bool? showMoreIcon;
  final void Function()? onPressed;
  final void Function()? onIconPressed;
  final Function(TapUpDetails)? onTapUp;
  final bool isEmployees;
  final bool isProject;
  final bool isStack;
  final String? stackPhoto;
  final String? upPhoto;
  final bool isTwoOptions;
  final Widget? rowTwoOptions;
  final bool showNotification;

  @override
  State<CustomAppBarMobile> createState() => _CustomAppBarMobileState();
}

class _CustomAppBarMobileState extends State<CustomAppBarMobile> {
  late String currentImagePath;

  @override
  void initState() {
    super.initState();
    currentImagePath = widget.imagePath ??
        'assets/icons_assets/main_icons_assets/ic_action_edit.png';

    storage.read('logo');
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme.of(context).brightness == Brightness.dark;

    // Rebuilds when company branding changes; the logo itself is read from
    // GetStorage below, so the state object isn't used directly here.
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        final String? logoUrl = storage.read('logo');

        // ✅ FIXED: Show custom logo in BOTH light and dark mode
        if (logoUrl == null || logoUrl.isEmpty) {
          if (darkMode) {
          } else {}
        } else {}

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isHome != true) SizedBox(height: 10.h),
              // Non-home layout: back icon + title + optional trailing action.
              // This branch was missing, so every screen passing `title:` /
              // `showIcon:` without `isHome: true` rendered only the 10.h gap
              // above and nothing else.
              if (widget.isHome != true)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.showIcon)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) =>
                              HapticController.low(), // top-of-page navigation
                          onTap: () {
                            (widget.onIconPressed ??
                                () => Navigator.of(context).maybePop())();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 4.h,
                            ),
                            child: Icon(
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.arrow_forward_ios
                                  : Icons.arrow_back_ios,
                              size: 20.sp,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: AutoSizeText(
                          widget.title ?? '',
                          maxLines: 1,
                          minFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize18Weight600.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      // ADDED 9/10/2026 — DEBUG-ONLY compact 🧪 badge (only
                      // during a debug-switch session; absent from release).
                      if (kDebugTestEmployeeSwitchBuild)
                        const DebugTestEmployeeBadge(compact: true),
                      if (widget.isTwoOptions && widget.rowTwoOptions != null)
                        widget.rowTwoOptions!,
                      if (widget.showMoreIcon == true)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.onPressed == null
                              ? null
                              : () {
                                  HapticController.low();
                                  widget.onPressed!();
                                },
                          onTapUp: widget.onTapUp,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 4.h,
                            ),
                            child: Icon(
                              Icons.more_vert,
                              size: 22.sp,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (widget.isHome == true) SizedBox(height: 14.h),
              if (widget.isHome == true)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    children: [
                      // ✅ FIXED LOGO LOGIC
                      Builder(
                        builder: (context) {
                          Widget logoWidget;

                          // ✅ NEW LOGIC: Check for custom logo FIRST, regardless of dark mode
                          if (logoUrl != null && logoUrl.isNotEmpty) {
                            logoWidget = SvgPicture.network(
                              logoUrl,
                              width: 25.w,
                              height: 25.h,
                              fit: BoxFit.fill,
                              placeholderBuilder: (context) {
                                return CustomSvgImage.natural(
                                  assetPath: darkMode
                                      ? "assets/icons_assets/main_icons_assets/logo_knowticed_badge_light.svg"
                                      : "assets/icons_assets/main_icons_assets/logo_knowticed.svg",
                                  width: 25.w,
                                  height: 25.h,
                                  fit: BoxFit.fill,
                                );
                              },
                            );
                          } else if (darkMode) {
                            logoWidget = CustomSvgImage.natural(
                              assetPath:
                                  "assets/icons_assets/main_icons_assets/logo_knowticed_badge_light.svg",
                              width: 25.w,
                              height: 25.h,
                              fit: BoxFit.fill,
                            );
                          } else {
                            logoWidget = CustomSvgImage.natural(
                              assetPath:
                                  "assets/icons_assets/main_icons_assets/logo_knowticed.svg",
                              width: 25.w,
                              height: 25.h,
                              fit: BoxFit.fill,
                            );
                          }

                          return SizedBox(
                            width: 65.h,
                            height: logoUrl == null ? 50.h : 65.h,
                            child: logoWidget,
                          );
                        },
                      ),
                      Spacer(),
                      // ADDED 9/10/2026 — DEBUG-ONLY "DEBUG: test employee"
                      // badge (only during a debug-switch session).
                      // Compile-time constant: absent from release/profile.
                      if (kDebugTestEmployeeSwitchBuild) ...[
                        const DebugTestEmployeeBadge(),
                        SizedBox(width: 10.w),
                      ],
                      // if(Get.find<NavBarCubit>().isAppBarEventAllowed)
                      //   Row(
                      //     children: [
                      //       GestureDetector(
                      //         onTap: () {
                      //           PersistentNavBarNavigator.pushNewScreen(
                      //             context,
                      //             screen: Modules.events.widget,
                      //             withNavBar: false,
                      //           );
                      //         },
                      //         child: SvgPicture.asset(
                      //           Modules.events.iconPath,
                      //           color:
                      //           !AppTheme.isDark
                      //               ? null
                      //               : AppColors.darkerGrey,
                      //         ),
                      //       ),
                      //       SizedBox(width: 10.w)
                      //     ],
                      //   ),
                      GestureDetector(
                        onTap: () {
                          HapticController.low(); // top-of-page navigation
                          // CHANGED 8/9/2026 — was `withNavBar: false`, which
                          // pushes on the ROOT navigator and so hid the bottom
                          // nav bar for the whole settings module. `true`
                          // pushes onto the active tab's nested Navigator
                          // (CustomTabView builds one per tab), so the bar
                          // stays. Every settings sub-page inherits it:
                          // settings_layout's `_open` already uses plain
                          // `Navigator.of(context).push`, which resolves to
                          // that same nested navigator.
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: SettingsScreen(hasBack: true),
                            withNavBar: true,
                          );
                        },
                        // Role QA p.23: the gear (0.6 stroke) looked much
                        // thinner than the bell beside it. Both icons are now
                        // 1.25 at 24 (K-39), same size and grey.
                        // Owner 22/10/2026 ("not equal in size … the colour
                        // seems different … thickness equal by numbers and by
                        // eye"): measured on screen the bell (28) stood 82 px
                        // tall with a 1.8 pt line, the gear 61 px with 1.25 —
                        // the thicker line is why the same grey looked
                        // lighter. Gear 28 + bell 24 (its file's line 1.336):
                        // both ~71 px tall, both lines 1.46 pt.
                        child: CustomSvgImage.natural(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_nav_settings.svg",
                          width: 28,
                          height: 28,
                          color: AppColors.icon,
                        ),
                      ),
                      if (widget.showNotification)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: GestureDetector(
                            onTap: () {
                              navigateTo(context, NotificationLandPage());
                            },
                            // 22/10/2026 — Owner: the same bell as the
                            // tablet, with the unseen count inside it.
                            child: NotificationBell(
                                controller: appNotificationController,
                                size: 28),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
