import 'package:flutter/material.dart';

import 'package:demo_app/core/custom/32-custom_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import '../theme/app_colors.dart';

Widget customButtonWithSvg({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  double? width,
  required double height,
  required double space,
  required double radius,
  required Color color,
  required String image,
  required double widthImage,
  required double heightImage,
  required Color colorBorder,
  Color? svgColor,
  EdgeInsets? padding,
}) {
  return GestureDetector(
    onTap: function,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: colorBorder),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: (title.trim().isEmpty && image.isNotEmpty)
          ? Center(
        child: CustomSvg(
          assetPath: image,
          height: heightImage,
          width: widthImage,
          color: svgColor ?? AppColors.textButton,
          fit: BoxFit.scaleDown,
        ),
      )
          : Padding(
        padding: padding ?? EdgeInsets.zero,
        child: image.isNotEmpty
            ? Row(
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
          child: Text(title, style: textStyle),
        ),
      ),
    ),
  );
}

/*
// ── Usage ─────────────────────────────────────────────────────────────────────

// Icon + text
customButtonWithSvg(
  title: 'Export',
  function: () {},
  textStyle: TextStyle(fontSize: 14, color: AppColors.textButton),
  width: 160,
  height: 48,
  space: 8,
  radius: 8,
  color: AppColors.primary,
  image: 'assets/icons/export.svg',
  widthImage: 20,
  heightImage: 20,
  colorBorder: Colors.transparent,
  svgColor: AppColors.textButton,
)

// Icon only (empty title)
customButtonWithSvg(
  title: '',
  function: () {},
  textStyle: TextStyle(),
  width: 48,
  height: 48,
  space: 0,
  radius: 8,
  color: AppColors.primary,
  image: 'assets/icons/add.svg',
  widthImage: 20,
  heightImage: 20,
  colorBorder: Colors.transparent,
)
*/
