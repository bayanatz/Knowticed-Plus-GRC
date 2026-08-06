// ignore_for_file: unrelated_type_equality_checks
import 'package:auto_size_text/auto_size_text.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/37-custom_navigate.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'package:grc_module/features/home/h2_nav_bar/utils/functions.dart';
// REMOVED_MODULE: import 'package:grc_module/features/home/h2_nav_bar/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:grc_module/core/theme/haptic_controller.dart';

// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/navigate.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_state.dart';


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
    currentImagePath = widget.imagePath ?? 'assets/icons_assets/main_icons_assets/edit_pencil_square.png';

    final logoFromStorage = storage.read('logo');
    print('🎨 initState - Logo from storage: $logoFromStorage');
    print('🎨 initState - Logo is null: ${logoFromStorage == null}');
    print('🎨 initState - Logo is empty: ${logoFromStorage?.toString().isEmpty ?? true}');
    print('🎨 ========================================');
    print('');
  }

  void _changeImage() {
    setState(() {
      currentImagePath = 'assets/icons_assets/main_icons_assets/image_placeholder_large.png';
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

    // Rebuilds when company branding changes; the logo itself is read from
    // GetStorage below, so the state object isn't used directly here.
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        print('');
        print('📦 ========================================');
        print('📦 BlocBuilder BUILDER FUNCTION CALLED');
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
                      if(Get.find<NavBarCubit>().isAppBarEventAllowed)
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
                          "assets/icons_assets/roles_assets/settings_gear.svg",
                          color:
                          themeController.currentTheme == AppColors.lightTheme
                              ? null
                              : AppColors.colorGreydark,
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