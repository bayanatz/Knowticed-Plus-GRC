/// Module: core/custom/buttons
/// Description: THE List / Grid view switch button. MERGED 17/10/2026 from
///              customGridButton + customTableButton (Moataz: "isn't it both
///              the same? but different icons") — one button, [ViewMode]
///              picks the icon. Unselected fill = card (the Grid copy ignored
///              `color`; the Table copy defaulted to the page colour).
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

enum ViewMode { grid, list }

Widget customViewModeButton({
  required ViewMode mode,
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
    onTapDown: (_) => HapticController.low(), // list / grid view switch
    onTap: () {
      function();
    },
    child: BounceSwitcher(
      // Bounce when switching between list and grid views (X-15).
      triggerValue: isSelected,
      child: Container(
        width: ButtonSizing.iconButtonSize, // 38.sp × 38.sp on all devices
        height: ButtonSizing.iconButtonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ?? AppColors.primary)
              : (color ?? AppColors.card),
          borderRadius: BorderRadius.circular(ButtonSizing.radius),
        ),
        child: CustomSvgImage(
          assetPath: mode == ViewMode.grid
              ? 'assets/icons_assets/main_icons_assets/ic_nav_grid.svg'
              : 'assets/icons_assets/main_icons_assets/ic_action_list_bulleted.svg',
          width: iconSize,
          height: iconSize,
          color: isSelected
              ? (selectedSvgColor ?? AppColors.textButton)
              : (svgColor ?? AppColors.text),
          fit: BoxFit.scaleDown,
        ),
      ),
    ),
  );
}
