/// Module: core/custom/buttons
/// Description: CustomEditIcon — a thin wrapper over [CustomToolbarActionButton]
///              (CHANGED 17/10/2026: one layout for all toolbar actions).
library;

import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/buttons/custom_toolbar_action_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';

class CustomEditIcon extends StatelessWidget {
  static const String _svgPath =
      'assets/icons_assets/main_icons_assets/ic_action_edit.svg';

  final String? title;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final Color? svgColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  /// Null = automatic: icon only when upright (portrait / phone).
  final bool? iconOnly;

  /// A filter / sort is applied → yellow fill.
  final bool active;

  /// Side of an icon-only square (default 38).
  final double? size;

  const CustomEditIcon({
    super.key,
    this.title,
    this.onTap,
    this.color,
    this.borderColor,
    this.svgColor,
    this.textStyle,
    this.padding,
    this.iconOnly,
    this.active = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomToolbarActionButton(
      svgPath: _svgPath,
      label: toolbarLabel(title, 'Edit', 'تعديل'),
      fill: color ?? AppColors.primary,
      contentColor: svgColor ?? AppColors.textButton,
      haptic: ToolbarHaptic.medium,
      onTap: onTap,
      borderColor: borderColor,
      textStyle: textStyle,
      padding: padding,
      iconOnly: iconOnly,
      active: active,
      size: size,
    );
  }
}
