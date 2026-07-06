import 'package:flutter/material.dart';

import 'package:demo_app/core/helper/inventory_module/core/svg_custom.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/main_helper/app_haptics.dart';
import 'package:demo_app/core/custom/41_custom_button_sizing.dart';

Widget customTableButton({
  required VoidCallback function,
  bool isSelected = false,
  double width = 40, // ignored: sizing is enforced by ButtonSizing
  double height = 40, // ignored: sizing is enforced by ButtonSizing
  double radius = 8, // ignored: sizing is enforced by ButtonSizing
  double iconSize = 20,
  Color? color,
  Color? selectedColor,
  Color? svgColor,
  Color? selectedSvgColor,
}) {
  return GestureDetector(
    onTap: () {
      AppHaptics.medium(); // action button
      function();
    },
    child: Container(
      width: ButtonSizing.iconButtonSize, // 38.sp × 38.sp on all devices
      height: ButtonSizing.iconButtonSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? (selectedColor ?? AppColors.primary)
            : (color ?? AppColors.transparent),
        borderRadius: BorderRadius.circular(ButtonSizing.radius),
      ),
      child: CustomSvg(
        assetPath: 'assets/tableView.svg',
        width: iconSize,
        height: iconSize,
        color: isSelected
            ? (selectedSvgColor ?? AppColors.white)
            : (svgColor ?? AppColors.textButton),
        fit: BoxFit.scaleDown,
      ),
    ),
  );
}

/*
// ── Usage ─────────────────────────────────────────────────────────────────────
customTableButton(
  function: () {},
  isSelected: false,
)
*/
