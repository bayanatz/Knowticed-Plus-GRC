/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_popup_menu_button.dart
/// Purpose: Declares `CustomPopupMenuButton`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

/// ******************* FILE INFO *******************
/// File Name: custom_pop_up.dart
/// Description: this is custom calender dropdown can reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_toolbar_action_button.dart'
    show ToolbarStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CustomPopupMenuButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final List<PopupOption> options;
  final Function(String) onSelected;
  final Color backgroundColor;
  final Color iconColor;
  final double width;
  final double height;

  /// The option currently chosen, for a SORT menu (23/10/2026, Moataz).
  /// Pass '' when nothing is chosen: the button and every row stay grey. Pass
  /// an option's value and the button turns yellow (primary) and that row is
  /// yellow with dark text; the other rows stay grey. Null (action menus:
  /// Delete, Edit…) leaves the menu exactly as it was.
  final String? selectedValue;

  /// Called when the CHOSEN row is tapped again, to clear the choice. Without
  /// it, tapping the chosen row just calls [onSelected] again.
  final VoidCallback? onCleared;

  const CustomPopupMenuButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.options,
    required this.onSelected,
    required this.backgroundColor,
    required this.iconColor,
    this.width = 155,
    this.height = 38,
    this.selectedValue,
    this.onCleared,
  });

  /// The toolbar grey on a plain button; on a filled (yellow) one the
  /// caller's readable colour.
  /// A sort menu passes [selectedValue]: '' = nothing chosen (button and rows
  /// grey), a value = that option chosen (button yellow, row yellow).
  bool get _active => (selectedValue ?? '').isNotEmpty;

  Color get _contentColor => _active
      ? AppColors.textButton
      : (backgroundColor == AppColors.primary
          ? iconColor
          : ToolbarStyle.contentColor);

  @override
  Widget build(BuildContext context) {
    Theme.of(context).brightness == Brightness.light;
    return PopupMenuButton<String>(
      tooltip: "",
      onSelected: (String value) {
        if (onCleared != null && value == selectedValue) {
          onCleared!();
        } else {
          onSelected(value);
        }
      },
      offset: Offset(0, height + 2),
      // No padding above the first row or below the last: the default 8 (and
      // my later 4) left an empty strip under a highlighted last row. The rows
      // carry their own vertical padding.
      menuPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : AppColors.chatBackground,
      itemBuilder: (context) => options.map((option) {
        return HoverablePopupMenuItem(
          value: option.value,
          label: option.label,
          selected: option.value == selectedValue,
          labelColor: option.labelColor ??
              (selectedValue == null ? null : AppColors.secondaryText),
        );
      }).toList(),
      child: Container(
        width: title.isEmpty ? 38.sp : width.w,
        // 21/10/2026 (D-274): `.r`, not `.h` — `.h` is 1.34 on a landscape iPad
        // and made every 38-high Sort button 51 beside 38-high Search fields.
        height: height.r,
        decoration: BoxDecoration(
          color: _active ? AppColors.primary : backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.transparent),
        ),
        // 22/10/2026 — Owner: the Sort icon beside Filter was smaller (16
        // vs 20) and a different grey. Both now take the toolbar's icon size
        // and colour (ToolbarStyle); the icon-only square has no side padding
        // so the 20 icon is not squeezed.
        padding: title.isEmpty
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: 10.5.sp),
        child: title.isEmpty
            ? Center(
                child: CustomSvgImage(
                  assetPath: iconPath,
                  width: ToolbarStyle.iconSize,
                  height: ToolbarStyle.iconSize,
                  color: _contentColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomSvgImage(
                    assetPath: iconPath,
                    width: ToolbarStyle.iconSize,
                    height: ToolbarStyle.iconSize,
                    color: _contentColor,
                  ),
                  SizedBox(width: 8.sp),
                  FittedBox(
                    child: Text(
                      title,
                      // 22/10/2026 — Owner: search, sort, filter and the
                      // toolbar buttons (Clean All, + Request …) share one
                      // text size in every module: 14 (was 16).
                      style: ToolbarStyle.label(_contentColor),
                    ),
                  ),
                  SizedBox(width: 4.sp),
                ],
              ),
      ),
    );
  }
}

class PopupOption {
  final String value;
  final String label;

  /// Optional resting colour for this one row's label.
  ///
  /// ADDED 15/8/2026: destructive rows ("Delete") are red in the Figma while
  /// every other row keeps the theme's text colour. Without this the caller
  /// had to rebuild the whole menu locally to recolour a single item, which
  /// is how a second, drifting copy of this widget gets born. Null keeps the
  /// previous behaviour exactly — white on dark, black on light.
  final Color? labelColor;

  PopupOption({required this.value, required this.label, this.labelColor});
}

// ✅ Custom hoverable item
class HoverablePopupMenuItem extends StatefulWidget
    implements PopupMenuEntry<String> {
  final String value;
  final String label;

  /// The row is the chosen option of a sort menu: primary fill, dark text.
  final bool selected;

  /// Resting label colour. Null falls back to the theme default.
  final Color? labelColor;

  /// Row fill while the pointer is over it. Null keeps the historical
  /// [AppColors.primary].
  final Color? hoverColor;

  /// Label colour while hovered. Null keeps the historical
  /// [AppColors.textButton], which is what reads on top of the primary fill.
  ///
  /// Both are additive: the existing [CustomPopupMenuButton] passes neither
  /// and is unchanged.
  final Color? hoverLabelColor;

  /// Where the label sits in the row. Defaults to [Alignment.center], which
  /// is what [CustomPopupMenuButton] has always drawn; a menu hung off a card
  /// with a mix of short and long labels ("Edit" / "Previous Module Owners")
  /// wants [Alignment.centerLeft] instead.
  final AlignmentGeometry alignment;

  final double _height;

  const HoverablePopupMenuItem({
    super.key,
    required this.value,
    required this.label,
    this.labelColor,
    this.selected = false,
    this.hoverColor,
    this.hoverLabelColor,
    this.alignment = Alignment.center,
    double height = kMinInteractiveDimension,
  }) : _height = height;

  @override
  State<HoverablePopupMenuItem> createState() => _HoverablePopupMenuItemState();

  @override
  double get height => _height;

  @override
  bool represents(String? value) => value == this.value;
}

class _HoverablePopupMenuItemState extends State<HoverablePopupMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: withHaptic(
          () => Navigator.pop(context, widget.value), HapticLevel.low),
      // Owner rule 23/10/2026 ("no hovers in anything"): the row no longer
      // changes colour under the mouse; `isHovered` stays false.
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 12.sp),
        decoration: BoxDecoration(
          color: widget.selected
              ? AppColors.primary
              : (isHovered
                  ? (widget.hoverColor ?? AppColors.primary)
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Align(
          alignment: widget.alignment,
          // The row is as wide as the menu, so it must not also stretch to the
          // widest label's height.
          heightFactor: 1,
          child: Text(
            widget.label,
            style: StyleText.fontSize14Weight500.copyWith(
              // Hover wins over labelColor: the row is repainted underneath,
              // so a red "Delete" left red on the default primary fill would
              // be red-on-yellow the moment the pointer touched it.
              // labelColor only paints the resting state.
              // CHANGED 17/10/2026: hovered text contrasts with the hover
              // fill (was the fixed button-text colour — light on yellow in
              // dark mode, unreadable).
              color: widget.selected
                  ? AppColors.textButton
                  : isHovered
                      ? (widget.hoverLabelColor ??
                          AppTheme.readableOn(
                              widget.hoverColor ?? AppColors.primary))
                      : (widget.labelColor ??
                          (isDark ? AppColors.white : AppColors.blackButton)),
            ),
          ),
        ),
      ),
    );
  }
}
