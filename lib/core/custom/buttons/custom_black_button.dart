/// Module: core/custom/buttons
/// Description: THE black button ("+ Control", "Add Controller", Pause …).
///              ADDED 17/10/2026 (Moataz: "we need the black button like the
///              add control button — make it custom"). Fill = the theme's
///              `blackButton` token (black in light, white in dark so it never
///              disappears); text and icon contrast with it automatically.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/custom/buttons/custom_button_with_svg.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';

Widget customBlackButton({
  required String title,
  required VoidCallback function,

  /// Optional leading icon (e.g. the plus of "+ Control").
  String? image,
  bool fullWidth = false,
  double? fixedWidth,
}) {
  final Color fill = AppColors.blackButton;
  final Color content = AppTheme.readableOn(fill);
  final TextStyle style =
      StyleText.fontSize14Weight500.copyWith(color: content);
  if (image == null) {
    return customButton(
      title: title,
      function: function,
      color: fill,
      textColor: content,
      textStyle: style,
      fullWidth: fullWidth,
      width: fixedWidth,
    );
  }
  return customButtonWithSvg(
    title: title,
    function: function,
    textStyle: style,
    color: fill,
    colorBorder: fill,
    image: image,
    widthImage: 16.w,
    heightImage: 16.h,
    svgColor: content,
    fixedWidth: fixedWidth,
  );
}
