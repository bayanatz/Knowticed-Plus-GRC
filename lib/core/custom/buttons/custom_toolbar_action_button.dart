/// Module: core/custom/buttons
/// Description: THE toolbar action button (Delete / Edit / Filter / Sort and
///              any icon + label action above a list). ADDED 17/10/2026 —
///              the four buttons repeated the same layout; they now wrap this.
///
/// Moataz, chat 17 Oct 11:22: "in the vertical mode they are only icons, in
/// the horizontal icon with text" → icon only when the screen is upright
/// (iPad portrait or phone), icon + label when it is sideways.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

enum ToolbarHaptic { low, medium, high }

/// ADDED 18/10/2026 (Moataz: "Filter and Sort use different fonts and
/// colours, the search / filter / sort icons are different colours") —
/// THE one look of the search · filter · sort row, read by
/// [CustomToolbarActionButton] (Filter), `CustomSortButton` and
/// `AppSearchTextField`'s search icon. Change it here, never per screen.
abstract final class ToolbarStyle {
  /// Resting icon + label colour of Filter / Sort and the search icon.
  static Color get contentColor => AppColors.secondaryText;

  /// Icon side of the search, filter and sort icons.
  static double get iconSize => 20.sp;

  /// Width of Filter / Sort while they show their label — the To-Do Sort
  /// (D-148): 100 × 38, so Filter and Sort are always the same box.
  static double get labelledWidth => 100.sp;

  /// Gap between a toolbar icon and its label.
  static double get iconTextGap => 8.sp;

  /// Label of Filter and Sort (and Delete / Edit): 14 medium.
  // 22/10/2026 — Owner: "make Search, Filter, Sort and all toolbar action
  // buttons the same weight 500" — was 14 regular (400).
  static TextStyle label([Color? color]) =>
      StyleText.fontSize14Weight500.copyWith(color: color ?? contentColor);

  /// ADDED 22/10/2026 — Owner: the one style of every toolbar text — the
  /// search's typed text and hint, Filter / Sort, and the action buttons
  /// (Clean All, + Add, Export, …) and the header-row navigation buttons:
  /// 14 medium. Pass the colour the button needs.
  static TextStyle text([Color? color]) => color == null
      ? StyleText.fontSize14Weight500
      : StyleText.fontSize14Weight500.copyWith(color: color);
}

class CustomToolbarActionButton extends StatelessWidget {
  const CustomToolbarActionButton({
    super.key,
    required this.svgPath,
    required this.label,
    required this.fill,
    required this.contentColor,
    required this.haptic,
    this.onTap,
    this.borderColor,
    this.textStyle,
    this.padding,
    this.iconOnly,
    this.active = false,
    this.size,
    this.labelledWidth,
  });

  /// ADDED 18/10/2026: width while the label shows. Null = [ButtonSizing]'s
  /// 135 (Delete / Edit); Filter passes [ToolbarStyle.labelledWidth].
  final double? labelledWidth;

  final String svgPath;
  final String label;
  final Color fill;
  final Color contentColor;
  final ToolbarHaptic haptic;
  final VoidCallback? onTap;
  final Color? borderColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  /// Null = automatic: icon only when upright (portrait / phone).
  final bool? iconOnly;

  /// ADDED 17/10/2026: a filter / sort is applied → yellow fill (the module
  /// copies TtFilterButton, NotificationFilterButton, the Services department
  /// filter all had this; now the shared button has it once).
  final bool active;

  /// Side of an icon-only square (default 38). The in-card Edit is 30.
  final double? size;

  void _haptic() {
    switch (haptic) {
      case ToolbarHaptic.low:
        HapticController.low();
      case ToolbarHaptic.medium:
        HapticController.medium();
      case ToolbarHaptic.high:
        HapticController.high();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool upright = ContextExtension(context).isPhone ||
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final bool onlyIcon = iconOnly ?? upright;
    final Color bg = active ? AppColors.primary : fill;
    final Color fg =
        active ? AppTheme.readableOn(AppColors.primary) : contentColor;

    // ToolbarStyle.iconSize unless the square is SMALLER than the toolbar's
    // (the in-card 30 Edit) — Knowledge Hub's 38.sp Filter drew a 21pt icon.
    final double iconSide =
        (size == null || size! >= ButtonSizing.iconButtonSize)
            ? ToolbarStyle.iconSize
            : size! * 0.55;
    final Widget svg = CustomSvgImage(
      assetPath: svgPath,
      width: iconSide,
      height: iconSide,
      color: fg,
      fit: BoxFit.scaleDown,
    );
    final TextStyle style = textStyle ?? ToolbarStyle.label(fg);
    final double? width = onlyIcon
        ? (size ?? ButtonSizing.iconButtonSize)
        : ButtonSizing.width(
            context,
            title: label,
            textStyle: style,
            extraContentWidth: iconSide + ToolbarStyle.iconTextGap,
            fixedWidth: labelledWidth,
          );

    return Tooltip(
      message: onlyIcon ? label : '',
      child: GestureDetector(
        // X-104: haptic on finger-down, action on the tap.
        onTapDown: onTap == null ? null : (_) => _haptic(),
        onTap: onTap,
        child: Container(
          width: width,
          height:
              onlyIcon ? (size ?? ButtonSizing.height) : ButtonSizing.height,
          padding: onlyIcon
              ? null
              : (width == null
                  ? EdgeInsets.symmetric(
                      horizontal: ButtonSizing.horizontalPadding)
                  : (padding ?? EdgeInsets.zero)),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: borderColor ?? AppColors.transparent),
            borderRadius: BorderRadius.circular(ButtonSizing.radius),
          ),
          child: onlyIcon
              ? Center(child: svg)
              : Row(
                  mainAxisSize:
                      width == null ? MainAxisSize.min : MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    svg,
                    SizedBox(width: ToolbarStyle.iconTextGap),
                    Flexible(
                      child: Text(label,
                          style: style,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Arabic or English default label.
String toolbarLabel(String? title, String en, String ar) =>
    title ?? (Get.locale?.languageCode == 'ar' ? ar : en);
