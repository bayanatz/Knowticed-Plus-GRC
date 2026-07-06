import 'package:demo_app/features/home/presentation/ui/pages/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/board_screen.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/image_paths.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';

// Date Created :12/November/2023
// Developer Name : Bassem Mohamed
// App Version : Version 2
// Date of Last Edit :23/November/2023 By Bassem
// Objectives:  this class named CustomDrawer created for controlling the drawer navigation with styling and the icons and screens that open on tap.

class CustomDrawer extends StatefulWidget {
  int? initialIndex;
  final List<Widget>? screens;

  CustomDrawer({
    super.key,
    this.initialIndex,
    this.screens,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int _selectedIndex = 0;

  final List<Widget> _defaultScreens = [
    Container(),
    const TaskScreen(),
  ];

  List<Widget> get _screens => widget.screens ?? _defaultScreens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
  }

  void _onItemTapped(int index) {
    hapticController.triggerHapticFeedback(
        vibration: VibrateType.lightImpact,
        hapticFeedback: HapticFeedback.lightImpact);
    print(_selectedIndex);

    if (widget.initialIndex == 18 || widget.initialIndex == 19) {
      setState(() {
        widget.initialIndex = null;
      });
    }
    if (widget.initialIndex != 18 || widget.initialIndex != 19) {
      setState(() {
        _selectedIndex = 0;
      });
    }
    if (index == 8) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: const SelectionUser(),
        ),
      );
      //  Mode.hr = false;
      // Mode.owner = false;
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color background = Theme.of(context).colorScheme.inversePrimary;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double height = 0.02.h;

    return OfflineBuilder(
      connectivityBuilder: (
        context,
        connectivity,
        child,
      ) {
        final bool connected = connectivity != ConnectivityResult.none;
        return Stack(
          children: [
            child,
            if (!connected)
              Positioned.fill(
                child: Scaffold(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  body: const NoInternetScreen(),
                ),
              ),
          ],
        );
      },
      child: Scaffold(
        body: Row(
          children: [
            Container(
              width: orientation ? 0.12.w : 0.10.w,
              decoration: BoxDecoration(color: background),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  Column(
                    children: <Widget>[
                      _buildLogoContainer(orientation),
                      SizedBox(height: 0.02.h),
                      _buildMenuItems(orientation, height),
                      Padding(
                        padding: EdgeInsets.only(
                            top: orientation ? 0.015.h : 0.02.h),
                        child: _buildMenuItem(
                            8, 'assets/icons_assets/main_icons_assets/Logout.svg', "Log Out".tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //  if (_selectedIndex == 19) Expanded(child: const NotificationView()),
            if (_selectedIndex != 8 &&
                widget.initialIndex != 18 &&
                widget.initialIndex != 19)
              Expanded(
                child: _screens[_selectedIndex],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoContainer(bool orientation) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.02.h),
      child: SizedBox(
        width: orientation ? 0.06.h : .085.h,
        height: orientation
            ? storage.read('logo') == null
                ? 0.05.h
                : 0.06.h
            : storage.read('logo') == null
                ? .065.h
                : .085.h,
        child: storage.read('logo') == null
            ? SvgPicture.asset(ImagePaths.getImagePath(context, 'logo'))
            : SvgPicture.network(storage.read('logo'), fit: BoxFit.fill),
      ),
    );
  }

  Widget _buildMenuItems(bool orientation, double height) {
    return SizedBox(
      height: orientation ? 0.8.h : 0.735.h,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildMenuItem(0, 'assets/icons_assets/task_assets/home.svg', "Home".tr),
            SizedBox(height: orientation ? height : 0),
            _buildMenuItem(1, 'assets/icons_assets/main_icons_assets/task_manage.svg', "Tasks".tr),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index, String iconPath, String title) {
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final bool isSelected = _selectedIndex == index;
    final iconColor = isSelected
        ? AppColors.textButton
        : themeController.currentTheme == AppColors.lightTheme
            ? AppColors.colorDarkGrey
            : AppColors.colorGreydark;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: orientation ? 0.08.w : 0.12.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.barColor : null,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: 0.01.h, vertical: orientation ? 0 : 0.005.h),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0.01.h),
              child: SvgPicture.asset(
                iconPath,
                width: orientation ? 0.02.w : 0.02.h,
                height: orientation ? 0.035.w : 0.035.h,
                color: iconColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 0.01.h, bottom: orientation ? 0.002.h : 0.005.h),
              child: orientation
                  ? const SizedBox.shrink()
                  : Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: FontConstants.fontSize019.h,
                          color: isSelected
                              ? AppColors.textButton
                              : themeController.currentTheme ==
                                      AppColors.lightTheme
                                  ? AppColors.colorDarkGrey
                                  : AppColors.colorGreydark,
                          fontWeight: FontWeight.w500,
                          height: orientation == true ? null : 1.2),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
