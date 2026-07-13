// ignore_for_file: must_be_immutable

import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';

import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'dart:math' as math;
import 'package:demo_app/core/constants/image_paths.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';

import 'package:demo_app/core/constants/selected_currency_info .dart';

class CustomCard extends StatefulWidget {
  final String name;
  final Widget? icon;
  final bool isSwitchTile;
  final bool hideIcon;
  final bool showCurrency;
  bool currentValue;

  final Function(bool)? onSwitchChanged;
  final Function()? onTap;
  final int index;
  int? selectIndex;

  // NEW: Add a property to track if this card is selected
  final bool isSelected;

  CustomCard({
    super.key,
    required this.name,
    this.icon,
    this.isSwitchTile = false,
    this.currentValue = false,
    this.hideIcon = false,
    this.showCurrency = false,
    this.onSwitchChanged,
    this.onTap,
    this.index = 0,
    this.selectIndex,
    this.isSelected = false, // NEW: Default to false
  });

  @override
  CustomCardState createState() => CustomCardState();
}

class CustomCardState extends State<CustomCard> {
  bool switchValue = false;
  ThemeController themeController = Get.put(ThemeController());
  bool isEnglish = Get.locale.toString().contains('en');
  final HapticController hapticController = Get.put(HapticController());

  // NEW: Method to check if this card is currently selected
  bool get isCurrentlySelected {
    return widget.selectIndex == widget.index || widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    //print("size width ${MediaQuery.of(context).size.width}");
   // print("size height ${MediaQuery.of(context).size.height}");
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final orientation = MediaQuery.of(context).orientation;

    return LayoutBuilder(
      builder: (context, constraints) {
        var isMobile = context.isPhone;
        var lightMode = Theme.of(context).brightness == Brightness.light;

        // NEW: Determine colors based on selection state
        final bool isSelected = isCurrentlySelected;
        final Color backgroundColor = isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent;









        // Replace the existing FlutterSwitch widget in CustomCard with this:

        final trailingWidget = widget.isSwitchTile
            ? Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(
              Get.locale.toString().contains('en') ? 0 : math.pi),
          child: FlutterSwitch(
            // New styling
            activeColor: AppColors.secondaryPrimary,
            height: 22.sp,
            width: 38.sp,
            padding: 3.sp,
            borderRadius: 20.sp,
            toggleSize: 16.sp,
            toggleColor: Colors.white, // White toggle/circle
            inactiveColor: Color(0xFF787880).withOpacity(0.16),
            value: widget.currentValue,
            onToggle: (newValue) {
              setState(() {
                widget.currentValue = newValue;
              });
              widget.onSwitchChanged?.call(widget.currentValue);
            },
          ),
        )
            : Transform.rotate(
          angle: Get.locale.toString().contains('en') ? 3.13 : 0,
          child: Transform.scale(
            scale: MediaQuery.of(context).size.shortestSide > 600
                ? (orientation == Orientation.portrait ? 0.7 : 1)
                : 1.3,
            child: SvgPicture.asset(
              // ignore: deprecated_member_use
              color: AppColors.text,
              ImagePaths.getImagePath(
                context,
                'back_icon',
              ),
            ),
          ),
        );

        return GestureDetector(
          onTap: () {
            print("🟢 CustomCard tapped - index: ${widget.index}, onTap is null: ${widget.onTap == null}, isSwitchTile: ${widget.isSwitchTile}");
            hapticController.triggerHapticFeedback(
                vibration: VibrateType.mediumImpact,
                hapticFeedback: HapticFeedback.mediumImpact);

            // FIRST: Check if it's a switch - don't do anything for selection
            if (widget.isSwitchTile) {
              return;
            }

            // SECOND: If onTap is provided, call it (this is for mobile navigation)
            if (widget.onTap != null) {
              widget.onTap!();
              return; // Important: return here to prevent further execution
            }

            // THIRD: Only update selection for tablet mode (when onTap is null)
            if (!widget.hideIcon) {
              final SettingsScreenState? state =
              context.findAncestorStateOfType<SettingsScreenState>();
              if (state != null) {
                state.setSelectedContainerIndex(widget.index);
              }
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 10.sp,
            ),
            child: Container(
              // NEW: Apply background color based on selection
              decoration: BoxDecoration(
              // color: Colors.red,
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0.01.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.icon != null)
                      Center(
                        child: Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.circular(4.r),
                              // NEW: Change icon background color when selected
                              color: isSelected
                                  ? AppColors.primary.withOpacity(.5)
                                  : AppColors.primary.withOpacity(.15),
                            ),
                            child: SizedBox(
                              // NEW: Apply icon color based on selection
                                child: Center(child: widget.icon)
                            )
                        ),
                      ),
                    if (widget.icon != null)
                      SizedBox(
                          width: isTablet
                              ? (orientation == Orientation.portrait
                              ? 0.01.h
                              : 0.02.h)
                              : 0.015.h),
                    Container(
                      width: widget.icon != null
                          ? isTablet
                          ? (orientation == Orientation.portrait
                          ? 0.2.w
                          : 0.17.w)
                          : 0.55.w
                          : isTablet
                          ? (orientation == Orientation.portrait
                          ? widget.isSwitchTile == true
                          ? 0.2.w
                          : 0.25.w
                          : 0.19.w)
                          : 0.65.w,
                      padding: EdgeInsets.only(
                        top: isTablet
                            ? (orientation == Orientation.portrait
                            ? 0.002.h
                            : 0.008.h)
                            : 0,
                        bottom: isTablet
                            ? (orientation == Orientation.portrait
                            ? 0.002.h
                            : 0.008.h)
                            : 0,
                      ),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Get.locale.toString().contains('en')
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          // NEW: Apply text color based on selection
                          child: Text(
                            widget.name.tr,
                            style: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.text,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          )
                      ),
                    ),
                    if (widget.showCurrency == true) const Spacer(),
                    if (widget.showCurrency == true)
                      Container(
                        height: MediaQuery.of(context).size.shortestSide > 600
                            ? (orientation == Orientation.landscape
                            ? 0.04.h
                            : 0.04.w)
                            : null,
                        decoration: BoxDecoration(
                          color: MediaQuery.of(context).size.shortestSide > 600
                              ? Colors.transparent
                              : AppColors.signOut,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color:
                            MediaQuery.of(context).size.shortestSide > 600
                                ? Colors.black
                                : Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.01.w,
                              vertical:
                              MediaQuery.of(context).size.shortestSide < 600
                                  ? 0.01.w
                                  : 0),
                          child: Row(
                            children: [
                              Transform.scale(
                                scale:
                                MediaQuery.of(context).size.shortestSide >
                                    600
                                    ? 1
                                    : 0.7,
                                child:
                                MediaQuery.of(context).size.shortestSide >
                                    600
                                    ? (orientation == Orientation.portrait
                                    ? SizedBox(
                                  width: 0.04.w,
                                  height: 0.02.h,
                                  child: SvgPicture.asset(
                                    'icons/flags/svg/${SelectedCurrencyInfo.flagImage}',
                                    package: 'country_icons',
                                  ),
                                )
                                    : SizedBox(
                                  width: 0.027.w,
                                  height: 0.03.h,
                                  child: SvgPicture.asset(
                                    'icons/flags/svg/${SelectedCurrencyInfo.flagImage}',
                                    package: 'country_icons',
                                  ),
                                ))
                                    : SizedBox(
                                  width: 0.075.w,
                                  height: 0.025.h,
                                  child: SvgPicture.asset(
                                    'icons/flags/svg/${SelectedCurrencyInfo.flagImage}',
                                    package: 'country_icons',
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 0.01.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (widget.showCurrency == true &&
                        MediaQuery.of(context).size.shortestSide < 600)
                      SizedBox(
                        width: 0.05.w,
                      ),
                    Spacer(),
                    if (widget.hideIcon == false)
                      Container(
                        width: widget.isSwitchTile == true ? null : isMobile ? 0.055.w:  0.020.w,
                        height: widget.isSwitchTile == true ? null :isMobile ? 0.030.h: 0.030.h,
                        child: GestureDetector(
                          onTap: widget.onTap,
                          child: trailingWidget,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}