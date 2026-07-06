import 'package:flutter/material.dart';

import 'package:demo_app/core/helper/main_helper/app_haptics.dart';
import 'package:demo_app/core/custom/41_custom_button_sizing.dart';

Widget customButtonWithIcon({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  double? width, // optional & ignored: sizing is enforced by ButtonSizing
  double? height, // optional & ignored: sizing is enforced by ButtonSizing
  double space = 8,
  double? radius, // optional & ignored: sizing is enforced by ButtonSizing
  required Color color,
  required IconData icon,
  required Color iconColor,
  required double iconSize,
}) {
  return Builder(
    builder: (context) {
      // 38.sp (mobile) / 135.sp (tablet), or null when the content
      // doesn't fit (then wrap with 12.sp horizontal padding).
      final double? buttonWidth = ButtonSizing.width(
        context,
        title: title,
        textStyle: textStyle,
        extraContentWidth: iconSize + space,
      );

      final Widget row = Row(
        mainAxisSize:
            buttonWidth == null ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          SizedBox(width: space),
          Text(title, style: textStyle),
        ],
      );

      return GestureDetector(
        onTap: () {
          AppHaptics.medium(); // action button
          function();
        },
        child: Container(
          width: buttonWidth,
          height: ButtonSizing.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(ButtonSizing.radius),
          ),
          child: buttonWidth == null
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ButtonSizing.horizontalPadding,
                  ),
                  child: row,
                )
              : row,
        ),
      );
    },
  );
}

/*
// ── Usage ─────────────────────────────────────────────────────────────────────
// Sizing is enforced app-wide by ButtonSizing:
// width 38.sp (mobile) / 135.sp (tablet), height 38.sp, radius 8.r.
// If the content doesn't fit, the button wraps it with 12.sp horizontal padding.
customButtonWithIcon(
  title: 'Add',
  function: () {},
  textStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.white),
  color: AppColors.primary,
  icon: Icons.add,
  iconColor: AppColors.white,
  iconSize: 20,
)
*/
