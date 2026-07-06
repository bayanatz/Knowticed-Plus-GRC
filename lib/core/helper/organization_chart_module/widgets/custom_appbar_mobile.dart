// ignore_for_file: unrelated_type_equality_checks
import 'package:auto_size_text/auto_size_text.dart';
import 'package:demo_app/features/notification/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/local_widgets/buttons/custom_icon_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/constants/image_paths.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/inventory_module/core/navigate.dart';
import 'package:demo_app/features/home/nav_bar/presentation/controller/nav_bar_controller.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:demo_app/features/onboarding/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:demo_app/core/nav_bar_package.dart/functions.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/core/helper/settings/presentation/controller/add_company_controller.dart';

import 'package:demo_app/core/helper/database_builder/constant/haptic_controller.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';

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
    print('');
    print('🎨 ========================================');
    print('🎨 CustomAppBarMobile initState CALLED');
    print('🎨 ========================================');
    currentImagePath = widget.imagePath ?? 'assets/images/edit.png';

    final logoFromStorage = storage.read('logo');
    print('🎨 initState - Logo from storage: $logoFromStorage');
    print('🎨 initState - Logo is null: ${logoFromStorage == null}');
    print('🎨 initState - Logo is empty: ${logoFromStorage?.toString().isEmpty ?? true}');
    print('🎨 ========================================');
    print('');
  }

  void _changeImage() {
    setState(() {
      currentImagePath = 'assets/images/other_image.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme.of(context).brightness == Brightness.dark;

    print('');
    print('🏗️ ========================================');
    print('🏗️ CustomAppBarMobile BUILD METHOD CALLED');
    print('🏗️ ========================================');
    print('🏗️ Dark mode: $darkMode');
    print('🏗️ isHome: ${widget.isHome}');

    return BlocBuilder<CompanyController, CompanyState>(
      bloc: Get.find<CompanyController>(),
      builder: (context, state) {
        print('');
        print('📦 ========================================');
        print('📦 GetBuilder BUILDER FUNCTION CALLED');
        print('📦 ========================================');

        final String? logoUrl = storage.read('logo');

        print('📦 Logo from storage.read("logo"): $logoUrl');
        print('📦 Logo is null: ${logoUrl == null}');
        print('📦 Logo is empty: ${logoUrl?.isEmpty ?? true}');
        print('📦 Dark mode: $darkMode');
        print('📦 Which logo will be shown:');

        // ✅ FIXED: Show custom logo in BOTH light and dark mode
        if (logoUrl == null || logoUrl.isEmpty) {
          if (darkMode) {
            print('📦 → DARK MODE + NO CUSTOM LOGO: Will show light_app_icon.svg');
          } else {
            print('📦 → LIGHT MODE + NO CUSTOM LOGO: Will show logo_app.svg');
          }
        } else {
          print('📦 → CUSTOM LOGO EXISTS: Will show network logo in ${darkMode ? "DARK" : "LIGHT"} mode: $logoUrl');
        }
        print('📦 ========================================');
        print('');

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isHome != true)
                SizedBox(height: 10.h),
              if (widget.isHome == true)
                SizedBox(height: 14.h),
              if (widget.isHome == true)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    children: [
                      // ✅ FIXED LOGO LOGIC
                      Builder(
                        builder: (context) {
                          print('');
                          print('🖼️ ========================================');
                          print('🖼️ LOGO WIDGET BUILDER CALLED');
                          print('🖼️ ========================================');
                          print('🖼️ Building logo widget now...');
                          print('🖼️ darkMode: $darkMode');
                          print('🖼️ logoUrl: $logoUrl');

                          Widget logoWidget;

                          // ✅ NEW LOGIC: Check for custom logo FIRST, regardless of dark mode
                          if (logoUrl != null && logoUrl.isNotEmpty) {
                            print('🖼️ ✅ RENDERING: Custom logo from network (${darkMode ? "DARK" : "LIGHT"} mode)');
                            print('🖼️ URL: $logoUrl');
                            logoWidget = SvgPicture.network(
                              logoUrl,
                              width: 25.w,
                              height: 25.h,
                              fit: BoxFit.fill,
                              placeholderBuilder: (context) {
                                print('🖼️ 📍 Placeholder shown while loading');
                                return SvgPicture.asset(
                                  darkMode ? "assets/icons_assets/main_icons_assets/light_app_icon.svg" : "assets/icons_assets/main_icons_assets/logo_app.svg",
                                  width: 25.w,
                                  height: 25.h,
                                  fit: BoxFit.fill,
                                );
                              },
                            );
                          } else if (darkMode) {
                            print('🖼️ ✅ RENDERING: light_app_icon.svg (dark mode, no custom logo)');
                            logoWidget = SvgPicture.asset(
                              "assets/icons_assets/main_icons_assets/light_app_icon.svg",
                              width: 25.w,
                              height: 25.h,
                              fit: BoxFit.fill,
                            );
                          } else {
                            print('🖼️ ✅ RENDERING: logo_app.svg (light mode, no custom logo)');
                            logoWidget = SvgPicture.asset(
                              "assets/icons_assets/main_icons_assets/logo_app.svg",
                              width: 25.w,
                              height: 25.h,
                              fit: BoxFit.fill,
                            );
                          }

                          print('🖼️ Logo widget created successfully');
                          print('🖼️ ========================================');
                          print('');

                          return SizedBox(
                            width: 65.h,
                            height: logoUrl == null ? 50.h : 65.h,
                            child: logoWidget,
                          );
                        },
                      ),
                      Spacer(),
                      if(Get.find<NavBarController>().isAppBarEventAllowed)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: Modules.events.widget,
                                  withNavBar: false,
                                );
                              },
                              child: SvgPicture.asset(
                                Modules.events.iconPath,
                                color:
                                themeController.currentTheme == AppColors.lightTheme
                                    ? null
                                    : AppColors.colorGreydark,
                              ),
                            ),
                            SizedBox(width: 10.w)
                          ],
                        ),
                      GestureDetector(
                        onTap: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: SettingsScreen(
                              hasBack: true,
                            ),
                            withNavBar: false,
                          );
                        },
                        child: SvgPicture.asset(
                          "assets/icons_assets/main_icons_assets/assets_settings.svg",
                          color:
                          themeController.currentTheme == AppColors.lightTheme
                              ? null
                              : AppColors.colorGreydark,
                        ),
                      ),
                      if (widget.showNotification)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: GestureDetector(
                            onTap: () {
                              navigateTo(context, NotificationLandPage());
                            },
                            child: SvgPicture.asset(
                              "assets/icons_assets/main_icons_assets/noti.svg",
                              color: themeController.currentTheme ==
                                  AppColors.lightTheme
                                  ? null
                                  : AppColors.colorGreydark,
                              fit: BoxFit.fill,
                            ),
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
    print('');
    print('🗑️ ========================================');
    print('🗑️ CustomAppBarMobile DISPOSED');
    print('🗑️ ========================================');
    print('');
    super.dispose();
  }
}