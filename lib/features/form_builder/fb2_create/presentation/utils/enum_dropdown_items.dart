/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: enum_dropdown_items.dart
/// Description: `EnumDropdownItems`, the dropdown items of the editor's
///              enums, `AlignmentFromStringExtension` and
///              `DropdownMenuItemListExtension`. These build widgets, so
///              they live in the presentation layer, not next to the enums
///              in domain/ (Home rules 1–2).
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/department_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/arrangement.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/location_drop_down.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/orientation.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

/// Size of the field-type icon in its dropdown rows.
const double kFieldTypeIconSize = 16;

/// The dropdown items of the editor's enums. Each item's value is the
/// stable stored name; only the visible text is translated.
abstract class EnumDropdownItems {
  static DropdownMenuItem<String> _textItem(
    String value,
    String label, {
    TextStyle? style,
  }) => DropdownMenuItem<String>(
    value: value,
    child: Text(
      label,
      style: (style ?? StyleText.fontSize14Weight500).copyWith(
        color: AppColors.secondaryBlack,
      ),
    ),
  );

  /// The access types.
  static List<DropdownMenuItem<String>> get accessManagement => [
    for (final AccessManagement e in AccessManagement.values)
      _textItem(e.name, e.label, style: StyleText.fontSize12Weight400),
  ];

  /// The field alignments.
  static List<DropdownMenuItem<String>> get alignment => [
    for (final AlignmentEnum e in AlignmentEnum.values)
      _textItem(e.name, e.label),
  ];

  /// The option arrangements.
  static List<DropdownMenuItem<String>> get arrangement => [
    for (final Arrangement e in Arrangement.values) _textItem(e.name, e.label),
  ];

  /// The location field types.
  static List<DropdownMenuItem<String>> get locationType => [
    for (final LocationDropDown e in LocationDropDown.values)
      _textItem(e.name, e.label),
  ];

  /// The page orientations.
  static List<DropdownMenuItem<String>> get orientation => [
    for (final OrientationEnum e in OrientationEnum.values)
      _textItem(e.name, e.label, style: StyleText.fontSize12Weight400),
  ];

  /// The field types, each with its icon (Figma node 7444-41905: 8 between
  /// the icon and the text).
  static List<DropdownMenuItem<String>> get fieldType => [
    for (final FormFieldType e in FormFieldType.values)
      DropdownMenuItem<String>(
        value: e.name,
        child: Row(
          children: [
            CustomSvgImage.natural(
              assetPath: e.icon,
              width: kFieldTypeIconSize.sp,
              height: kFieldTypeIconSize.sp,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
            ),
            SizedBox(width: 8.w),
            Text(
              e.label,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryBlack,
              ),
            ),
          ],
        ),
      ),
  ];
}

/// Alignment conversion from the stored alignment name.
extension AlignmentFromStringExtension on String {
  /// The [Alignment] of a stored alignment name (Expand = left).
  Alignment get alignment {
    switch (this) {
      case 'Left':
      case 'Expand':
        return Alignment.centerLeft;
      case 'Right':
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }
}

/// The department dropdown items.
extension DropdownMenuItemListExtension on List<DepartmentEntity> {
  /// One item per department (value = department id), named in the UI
  /// language ([arabic] defaults to the current locale).
  List<DropdownMenuItem<String>> toDropdownMenuItemList({bool? arabic}) {
    final bool ar = arabic ?? Intl.getCurrentLocale().startsWith('ar');
    return map((department) {
      return DropdownMenuItem<String>(
        value: department.id,
        child: Text(
          department.displayName(arabic: ar),
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.secondaryBlack,
          ),
        ),
      );
    }).toList();
  }
}
