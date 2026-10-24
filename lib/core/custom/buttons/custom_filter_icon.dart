/// Module: core/custom/buttons
/// Description: CustomFilterIcon — a thin wrapper over [CustomToolbarActionButton]
///              (CHANGED 17/10/2026: one layout for all toolbar actions).
/// Card fill by default (was yellow fill with grey text — unreadable).
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_toolbar_action_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class CustomFilterIcon extends StatelessWidget {
  static const String _svgPath =
      'assets/icons_assets/main_icons_assets/ic_action_filter.svg';

  final String? title;
  final VoidCallback? onTap;

  /// Resting fill (defaults to AppColors.card). Passing AppColors.primary is
  /// read as [active] — older screens lit the button that way.
  final Color? color;
  final Color? borderColor;

  /// IGNORED since 18/10/2026: icon and label always use [ToolbarStyle] so
  /// Filter matches Sort and the search icon in every module. Kept so the
  /// existing call sites still compile.
  final Color? svgColor;

  /// IGNORED since 18/10/2026 — see [svgColor].
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  /// Null = automatic: icon only when upright (portrait / phone).
  final bool? iconOnly;

  /// A filter / sort is applied → yellow fill.
  final bool active;

  /// Side of an icon-only square (default 38).
  final double? size;

  const CustomFilterIcon({
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
    // CHANGED 18/10/2026 (Moataz: the Filter label was brighter and larger
    // than Sort, and the icons were different colours): the resting icon and
    // label come ONLY from [ToolbarStyle], the same tokens `CustomSortButton`
    // and the search field read — a screen can no longer pass its own
    // 16/500 label or black icon. Active (yellow) is unchanged.
    final bool isActive = active || color == AppColors.primary;
    return CustomToolbarActionButton(
      svgPath: _svgPath,
      label: toolbarLabel(title, 'Filter', 'تصفية'),
      fill: isActive ? AppColors.primary : (color ?? AppColors.card),
      contentColor: ToolbarStyle.contentColor,
      haptic: ToolbarHaptic.low,
      onTap: onTap,
      borderColor: borderColor,
      padding: padding,
      iconOnly: iconOnly,
      active: isActive,
      size: size,
      // Same box as CustomSortButton (100 × 38 with its label).
      labelledWidth: ToolbarStyle.labelledWidth,
    );
  }
}
