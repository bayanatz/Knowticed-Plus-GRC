/// ************************ FILE INFO ********************************///
/// File Name: 61-custom_color_picker.dart
/// Purpose: Colour selection built on the flex_color_picker package.
///          Replaces the hand-rolled pair
///          settings/.../fields/color_picker_container.dart and
///          settings/.../sections/color_display_section.dart, whose colour
///          wheel had been commented out (leaving a disabled hex field) and
///          which reached into CompanyController just to read a fallback hex.
///          This version is presentational only: it takes the current colours
///          and reports changes back, so it has no controller dependency.
/// Module: core / custom
// *************************************************

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/generated/l10n.dart';

/// A single labelled colour swatch that opens the flex_color_picker dialog.
class CustomColorPickerField extends StatelessWidget {
  const CustomColorPickerField({
    super.key,
    required this.label,
    required this.color,
    required this.onColorSelected,
    this.dialogTitle,
  });

  /// Field caption, e.g. "Primary Color".
  final String label;

  /// Currently selected colour.
  final Color color;

  /// Called with the newly picked colour. Not called if the user cancels.
  final ValueChanged<Color> onColorSelected;

  /// Optional dialog heading; defaults to [label].
  final String? dialogTitle;

  String get _hex => '#${(color.value & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';

  Future<void> _pick(BuildContext context) async {
    final Color picked = await showColorPickerDialog(
      context,
      color,
      title: Text(
        dialogTitle ?? label,
        style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      ),
      width: 40.sp,
      height: 40.sp,
      spacing: 4,
      runSpacing: 4,
      borderRadius: 4,
      wheelDiameter: 190.sp,
      enableShadesSelection: true,
      showColorCode: true,
      colorCodeHasColor: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        copyButton: true,
        pasteButton: true,
        longPressMenu: true,
      ),
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
      actionButtons: const ColorPickerActionButtons(
        okButton: true,
        closeButton: true,
        dialogActionButtons: false,
      ),
    );

    // showColorPickerDialog returns the original colour when cancelled.
    if (picked != color) onColorSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 24.sp,
                  height: 24.sp,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    _hex,
                    textDirection: TextDirection.ltr,
                    style: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.text),
                  ),
                ),
                Icon(Icons.colorize, size: 18.sp, color: AppColors.text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Primary + secondary colour pair, stacked in portrait and side-by-side in
/// landscape. Drop-in replacement for the old `ColorDisplaySection`.
class CustomColorPickerSection extends StatelessWidget {
  const CustomColorPickerSection({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onPrimaryColorSelected,
    required this.onSecondaryColorSelected,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final ValueChanged<Color> onPrimaryColorSelected;
  final ValueChanged<Color> onSecondaryColorSelected;

  @override
  Widget build(BuildContext context) {
    final bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final Widget primary = CustomColorPickerField(
      label: S.of(context).primaryColor,
      color: primaryColor,
      onColorSelected: onPrimaryColorSelected,
    );
    final Widget secondary = CustomColorPickerField(
      label: S.of(context).secondaryColor,
      color: secondaryColor,
      onColorSelected: onSecondaryColorSelected,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context).colors,
          style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: isVertical ? 10.sp : 12.h),
        if (isVertical) ...[
          primary,
          SizedBox(height: 0.015.h),
          secondary,
          SizedBox(height: 0.008.h),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: primary),
              SizedBox(width: 12.w),
              Expanded(child: secondary),
            ],
          ),
      ],
    );
  }
}
