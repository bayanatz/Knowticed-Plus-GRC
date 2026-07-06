import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/switchs_data_column.dart';

// ignore: must_be_immutable
class DialogueSwitcher extends StatefulWidget {
  DialogueSwitcher(
      {super.key,
      required this.title,
      required this.switchValue,
      required this.switchValueState});
  final String title;
  bool switchValue;
  ValueChanged<bool> switchValueState;

  @override
  State<DialogueSwitcher> createState() => _DialogueSwitcherState();
}

class _DialogueSwitcherState extends State<DialogueSwitcher> {
  final HapticController hapticController = Get.put(HapticController());

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SwitchColumn(
          title: widget.title,
        ),
        SizedBox(
          width: isTablet ? .2.w : null,
        ),
        Transform.scale(
          scale: isTablet ? 1.1 : 0.9,
          child: GestureDetector(
            onTap: () {
              hapticController.triggerHapticFeedback(
                  vibration: VibrateType.lightImpact,
                  hapticFeedback: HapticFeedback.lightImpact);
              setState(() {
                setState(() {
                  widget.switchValue = !widget.switchValue;
                  widget.switchValueState(widget.switchValue);
                });
              });
            },
            child: SvgPicture.asset(
              widget.switchValue
                  ? 'assets/icons_assets/main_icons_assets/NewSwitchOn.svg'
                  // ignore: unrelated_type_equality_checks
                  : themeController.currentTheme == AppColors.lightTheme
                      ? 'assets/icons_assets/main_icons_assets/NewSwitchOff.svg'
                      : 'assets/icons_assets/main_icons_assets/NewSwitchOff.svg',
            ),
          ),
        ),
      ],
    );
  }
}
