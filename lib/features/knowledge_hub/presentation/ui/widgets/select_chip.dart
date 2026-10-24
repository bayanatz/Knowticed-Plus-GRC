/// Module: knowledge_hub/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: select_chip.dart
/// Description: Shows the items picked in a dropdown as removable chips under it.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class SelectChip extends StatelessWidget {
  final List<String> departments;
  final List<String> selectedDepartments;
  final double width;
  final Color color;
  final String title;
  final bool apper;
  final Function(String) onAdd;
  final Function(String) onRemove;
  final bool singleSelect;
  final String iconAsset;
  final double triggerHeight;
  final double? menuWidth;
  final double? menuItemHeight;
  final bool capitalizeDepartments; // New parameter

  const SelectChip({
    super.key,
    this.title = '',
    required this.departments,
    required this.width,
    required this.color,
    required this.selectedDepartments,
    required this.onAdd,
    required this.onRemove,
    this.apper = true,
    this.singleSelect = false,
    this.iconAsset =
        "assets/icons_assets/main_icons_assets/ic_nav_chevron_down_gray.svg",
    this.triggerHeight = 36.0,
    this.menuWidth,
    this.menuItemHeight,
    this.capitalizeDepartments = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    final label = title.isNotEmpty ? title : S.of(context).department;

    // Create a mapping between original and capitalized values
    final Map<String, String> originalToCapitalized = {};
    final Map<String, String> capitalizedToOriginal = {};

    if (capitalizeDepartments) {
      for (final dept in departments) {
        final capitalized = FormatHelper.capitalize(dept);
        originalToCapitalized[dept] = capitalized;
        capitalizedToOriginal[capitalized] = dept;
      }
    }

    // Use either capitalized or original based on setting
    final displayDepartments = capitalizeDepartments
        ? departments.map((d) => originalToCapitalized[d]!).toList()
        : departments;

    final displaySelectedDepartments = capitalizeDepartments
        ? selectedDepartments.map((d) => originalToCapitalized[d]!).toList()
        : selectedDepartments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: CustomMultiSelectFilter<String>(
            values: List<String>.from(displaySelectedDepartments),
            items: [
              for (final String i in displayDepartments)
                MultiSelectDropdownItem<String>(value: i, label: i),
            ],
            onChanged: multiSelectToggleBridge(
              List<String>.from(displaySelectedDepartments),
              (String item) => ((value) {
                final v = value as String;

                // Convert back to original case for callback
                final originalValue = capitalizeDepartments
                    ? (capitalizedToOriginal[v] ?? v)
                    : v;

                if (selectedDepartments.contains(originalValue)) {
                  onRemove(originalValue);
                } else {
                  if (singleSelect) {
                    for (final s in List<String>.from(selectedDepartments)) {
                      onRemove(s);
                    }
                  }
                  onAdd(originalValue);
                }
              })(item),
            ),
            hint: (label),
            height: triggerHeight,
            fillColor: color,
          ),
        ),

        SizedBox(height: 8.sp),

        // Selected departments, wrapped to the available width.
        apper
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 8.sp,
                    runSpacing: 8.sp,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: selectedDepartments.map((dept) {
                      return _buildChip(context, dept, constraints.maxWidth);
                    }).toList(),
                  );
                },
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  /// One selected department, with its remove button.
  Widget _buildChip(BuildContext context, String dept, double maxWidth) {
    final displayName = capitalizeDepartments
        ? FormatHelper.capitalize(dept)
        : dept;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth - 16.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.greyBack
            : AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              displayName,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.blackButton,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 6.sp),
          GestureDetector(
            onTapDown: (_) => HapticController.high(),
            onTap: () => onRemove(dept),
            child: CircleAvatar(
              radius: 7.r,
              backgroundColor: AppColors.red,
              child: Icon(Icons.remove, color: AppColors.white, size: 10.sp),
            ),
          ),
        ],
      ),
    );
  }
}
