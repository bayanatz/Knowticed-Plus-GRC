import 'package:flutter/material.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/custom/41_custom_button_sizing.dart';

import './32-custom_svg.dart';

Widget customGridButton({
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
      HapticController.medium(); // action button
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
      child: CustomSvgImage(
        assetPath: 'assets/icons_assets/main_icons_assets/grid_four_squares.svg',
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
customGridButton(
  function: () {},
  isSelected: true,
)
*/
