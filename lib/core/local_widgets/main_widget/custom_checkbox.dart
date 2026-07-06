// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:demo_app/core/custom/33-custom_haptic.dart';

// ignore: must_be_immutable
class CustomCheckbox extends StatefulWidget {
  CustomCheckbox(
      {super.key,
      required this.isChecked,
      required this.onCheckboxState,
      this.isBottomSheet = false});
  bool isChecked;
  final ValueChanged<bool> onCheckboxState;
  bool isBottomSheet;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  final ThemeController themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return InkWell(
      onTap: () {
        hapticController.triggerHapticFeedback(
            vibration: VibrateType.mediumImpact,
            hapticFeedback: HapticFeedback.mediumImpact);
        setState(() {
          widget.isChecked = !widget.isChecked;
          widget.onCheckboxState(widget.isChecked);
        });
      },
      child: widget.isChecked
          ? SvgPicture.asset(
              themeController.currentTheme == AppColors.lightTheme
                  ? 'assets/icons_assets/main_icons_assets/CheckListOn.svg'
                  : 'assets/icons_assets/main_icons_assets/CheckListOff.svg',
                  color: AppColors.lightPrimary,
              height: isPortrait == true
                  ? widget.isBottomSheet == true
                      ? 0.023.h
                      : 0.025.h
                  : 0.035.h,
            )
          : SvgPicture.asset(
              'assets/icons_assets/main_icons_assets/checkBoxNotChecked.svg',
              color: AppColors.lightPrimary,
              height: isPortrait == true
                  ? widget.isBottomSheet == true
                      ? 0.023.h
                      : 0.025.h
                  : 0.035.h,
            ),
    );
  }
}
