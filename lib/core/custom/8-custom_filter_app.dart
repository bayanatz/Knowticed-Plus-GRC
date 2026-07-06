// Date: 3/3/2026
// CreatedBy : Amr Mesbah
// Purpose: Reusable horizontal status chip filter widget

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';

class StatusChipFilter extends StatelessWidget {
  /// List of chip items to display
  final List<StatusChipItem> items;

  /// Currently selected key
  final String selectedKey;

  /// Called when a chip is tapped — returns the tapped item's key
  final ValueChanged<String> onSelected;

  /// Selected chip background color — defaults to primary
  final Color? selectedColor;

  /// Selected count text color — defaults to white
  final Color? selectedCountTextColor;

  /// Unselected chip background color — defaults to theme card color
  final Color? unselectedColor;

  /// Spacing between chips — defaults to 30.sp
  final double? chipSpacing;

  /// Spacing between count box and label — defaults to 15.sp
  final double? innerSpacing;

  /// Size of the count box — defaults to 45.sp (35.sp on mobile)
  final double? chipSize;

  const StatusChipFilter({
    super.key,
    required this.items,
    required this.selectedKey,
    required this.onSelected,
    this.selectedColor,
    this.selectedCountTextColor,
    this.unselectedColor,
    this.chipSpacing,
    this.innerSpacing,
    this.chipSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final isMobile = context.isPhone;

    final resolvedSelectedColor = selectedColor ?? theme.colorScheme.primary;
    final resolvedUnselectedColor =
        unselectedColor ?? (isLight ? AppColors.white : theme.cardColor);
    final resolvedSelectedCountColor = selectedCountTextColor ?? AppColors.white;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final isSelected = item.key == selectedKey;
          return _StatusChip(
            item: item,
            isSelected: isSelected,
            isLight: isLight,
            selectedColor: resolvedSelectedColor,
            unselectedColor: resolvedUnselectedColor,
            selectedCountTextColor: resolvedSelectedCountColor,
            chipSpacing: chipSpacing ?? 30.sp,
            innerSpacing: innerSpacing ?? 15.sp,
            chipSize: chipSize ?? (isMobile ? 35.sp : 45.sp),
            onTap: () => onSelected(item.key),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal chip widget
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final StatusChipItem item;
  final bool isSelected;
  final bool isLight;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedCountTextColor;
  final double chipSpacing;
  final double innerSpacing;
  final double chipSize;
  final VoidCallback onTap;

  const _StatusChip({
    required this.item,
    required this.isSelected,
    required this.isLight,
    required this.selectedColor,
    required this.unselectedColor,
    required this.selectedCountTextColor,
    required this.chipSpacing,
    required this.innerSpacing,
    required this.chipSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ── Label color logic ─────────────────────────────────────────────────
    // Priority: item.labelColor → selected: AppColors.text / unselected: AppColors.secondaryText
    final Color labelColor = item.labelColor ??
        (isSelected ? AppColors.text : AppColors.secondaryText);

    // ── Count text color ──────────────────────────────────────────────────
    final Color countColor =
    isSelected ? AppColors.textButton : AppColors.text;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Count box ───────────────────────────────────────────────────
          Container(
            width: chipSize,
            height: chipSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              item.count.toString(),
              textAlign: TextAlign.center,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
                leadingDistribution: TextLeadingDistribution.even,
              ),
              style: StyleText.fontSize20Weight500.copyWith(
                color: countColor,
                height: 1.0,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
          ),

          SizedBox(width: innerSpacing),

          // ── Label ───────────────────────────────────────────────────────
          Text(
            item.label,
            style: StyleText.fontSize16Weight600.copyWith(color: labelColor),
          ),

          SizedBox(width: chipSpacing),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model for a single chip
// ─────────────────────────────────────────────────────────────────────────────

class StatusChipItem {
  /// Unique identifier — used to match [StatusChipFilter.selectedKey]
  final String key;

  /// Display label shown next to the count box
  final String label;

  /// Count shown inside the box
  final int count;

  /// Optional fixed label color.
  /// If null → selected uses AppColors.text, unselected uses AppColors.secondaryText.
  final Color? labelColor;

  const StatusChipItem({
    required this.key,
    required this.label,
    required this.count,
    this.labelColor,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Department / status filter helper
// Reproduces the behaviour of the former DepartmentFilterChips widget so it can
// be used together with [StatusChipFilter]:
//   • prepends an "All" chip (canonical key 'All') showing [totalCount]
//   • localizes known English department names to Arabic when [isArabic]
//   • capitalizes labels via FormatHelper.capitalize
// The chip `key` stays the English/canonical value so selection logic is
// unchanged; only the displayed label is localized.
// ─────────────────────────────────────────────────────────────────────────────

/// English → Arabic labels for known departments (and the "All" chip).
const Map<String, String> kDepartmentEnToAr = {
  'All': 'الكل',
  'Executive': 'الإدارة التنفيذية',
  'Customer Support': 'دعم العملاء',
  'Finance': 'المالية',
  'Operations': 'العمليات',
  'Information Technology': 'تقنية المعلومات',
  'Human Resources': 'الموارد البشرية',
  'Marketing': 'التسويق',
  'Sales': 'المبيعات',
  'Data Management': 'إدارة البيانات',
  'Compliance & Legal': 'الامتثال والشؤون القانونية',
  'Software': 'البرمجيات',
};

/// Builds the [StatusChipItem] list for a department/status filter.
List<StatusChipItem> departmentChipItems({
  required int totalCount,
  required Map<String, int> departmentCounts,
  required bool isArabic,
  Map<String, Color>? labelColors,
}) {
  String displayLabel(String key) {
    final raw = isArabic ? (kDepartmentEnToAr[key] ?? key) : key;
    return FormatHelper.capitalize(raw);
  }

  return [
    StatusChipItem(
      key: 'All',
      label: displayLabel('All'),
      count: totalCount,
    ),
    ...departmentCounts.entries.map(
      (entry) => StatusChipItem(
        key: entry.key,
        label: displayLabel(entry.key),
        count: entry.value,
        labelColor: labelColors?[entry.key],
      ),
    ),
  ];
}


// How to Use
// StatusChipFilter(
//   selectedKey: selectedStateFilter,
//   onSelected: (key) => setState(() {
//     selectedStateFilter = key;
//     _applyFilters();
//   }),
//   items: [
//     StatusChipItem(key: "In Use",       label: S.of(context).inUse,       count: stateCounts["In Use"]!,       labelColor: const Color(0xFF4BB609)),
//     StatusChipItem(key: "Returned",     label: S.of(context).returned,     count: stateCounts["Returned"]!,     labelColor: const Color(0xFFDF1C1C)),
//     StatusChipItem(key: "Maintenance",  label: S.of(context).maintenance,  count: stateCounts["Maintenance"]!,  labelColor: const Color(0xFFE5B800)),
//     StatusChipItem(key: "Under Repair", label: S.of(context).underRepair,  count: stateCounts["Under Repair"]!, labelColor: const Color(0xFFFFDE59)),
//     StatusChipItem(key: "Damaged",      label: S.of(context).damaged,      count: stateCounts["Damaged"]!,      labelColor: const Color(0xFFBA1B1B)),
//     StatusChipItem(key: "Missing",      label: S.of(context).missing,      count: stateCounts["Missing"]!,      labelColor: const Color(0xFF797979)),
//     StatusChipItem(key: "Stolen",       label: S.of(context).stolen,       count: stateCounts["Stolen"]!,       labelColor: const Color(0xFF797979)),
//   ],
// ),