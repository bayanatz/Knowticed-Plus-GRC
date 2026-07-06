import 'package:flutter/material.dart';

import 'package:demo_app/core/helper/inventory_module/core/svg_custom.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/main_helper/app_haptics.dart';
import 'package:demo_app/core/custom/41_custom_button_sizing.dart';

Widget customButtonWithSvg({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  double? width, // optional & ignored: sizing is enforced by ButtonSizing
  double? height, // optional & ignored: sizing is enforced by ButtonSizing
  double space = 8,
  double? radius, // optional & ignored: sizing is enforced by ButtonSizing
  required Color color,
  required String image,
  required double widthImage,
  required double heightImage,
  required Color colorBorder,
  Color? svgColor,
  EdgeInsets? padding, // ignored: sizing is enforced by ButtonSizing
}) {
  return Builder(
    builder: (context) {
      final bool iconOnly = title.trim().isEmpty && image.isNotEmpty;

      // Icon-only buttons are always 38.sp × 38.sp.
      // Text buttons: 38.sp (mobile) / 135.sp (tablet), or null when the
      // content doesn't fit (then wrap with 12.sp horizontal padding).
      final double? buttonWidth = iconOnly
          ? ButtonSizing.iconButtonSize
          : ButtonSizing.width(
              context,
              title: title,
              textStyle: textStyle,
              extraContentWidth: image.isNotEmpty ? widthImage + space : 0,
            );

      Widget content;
      if (iconOnly) {
        content = Center(
          child: CustomSvg(
            assetPath: image,
            height: heightImage,
            width: widthImage,
            color: svgColor ?? AppColors.textButton,
            fit: BoxFit.scaleDown,
          ),
        );
      } else {
        final Widget inner = image.isNotEmpty
            ? Row(
                mainAxisSize:
                    buttonWidth == null ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomSvg(
                    assetPath: image,
                    height: heightImage,
                    width: widthImage,
                    color: svgColor,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(width: space),
                  Text(title, style: textStyle),
                ],
              )
            : Center(
                widthFactor: buttonWidth == null ? 1 : null,
                child: Text(title, style: textStyle),
              );

        content = buttonWidth == null
            ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ButtonSizing.horizontalPadding,
                ),
                child: inner,
              )
            : inner;
      }

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
            border: Border.all(color: colorBorder),
            borderRadius: BorderRadius.circular(ButtonSizing.radius),
          ),
          child: content,
        ),
      );
    },
  );
}

/*
// ── Usage ─────────────────────────────────────────────────────────────────────
// Sizing is enforced app-wide by ButtonSizing:
// width 38.sp (mobile) / 135.sp (tablet), height 38.sp, radius 8.r.
// Icon-only buttons (empty title) are always 38.sp × 38.sp.
// If the content doesn't fit, the button wraps it with 12.sp horizontal padding.

// Icon + text
customButtonWithSvg(
  title: 'Export',
  function: () {},
  textStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.textButton),
  color: AppColors.primary,
  image: 'assets/icons_assets/main_icons_assets/icons_export.svg',
  widthImage: 20,
  heightImage: 20,
  colorBorder: AppColors.transparent,
  svgColor: AppColors.textButton,
)

// Icon only (empty title) → 38.sp × 38.sp
customButtonWithSvg(
  title: '',
  function: () {},
  textStyle: StyleText.fontSize14Weight400,
  color: AppColors.primary,
  image: 'assets/icons_assets/main_icons_assets/icons_add.svg',
  widthImage: 20,
  heightImage: 20,
  colorBorder: AppColors.transparent,
)
*/
