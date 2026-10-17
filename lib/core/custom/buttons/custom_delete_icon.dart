/// Module: core/custom/buttons
/// Description: CustomDeleteIcon — a thin wrapper over [CustomToolbarActionButton]
///              (CHANGED 17/10/2026: one layout for all toolbar actions).
/// Delete is RED with white content (Moataz 17 Oct: "the delete button is red"; TtDeleteButton style).
library;

import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/buttons/custom_toolbar_action_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';

class CustomDeleteIcon extends StatelessWidget {
  static const String _svgPath =
      'assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg';

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

  const CustomDeleteIcon({
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
      label: toolbarLabel(title, 'Delete', 'حذف'),
      fill: color ?? AppColors.red,
      contentColor: svgColor ?? AppColors.white,
      haptic: ToolbarHaptic.high,
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
