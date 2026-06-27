/// ******************* FILE INFO *******************
/// File Name: custom_filter.dart
/// Description: this is custom filter can reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/core/theme/app_colors.dart';

class DepartmentFilterChips extends StatelessWidget {
  final String selectedKey; // English canonical key (e.g., "All", "Marketing", "Sales")
  final Function(String key) onSelected; // send back the English canonical key
  final int totalCount;
  final Map<String, int> departmentCounts; // keys are English canonical names
  final Map<String, Color>? labelColors;
  final String userDepartment;
  final bool isArabic;

  const DepartmentFilterChips({
    super.key,
    required this.selectedKey,
    required this.onSelected,
    required this.totalCount,
    required this.departmentCounts,
    required this.userDepartment,
    required this.isArabic,
    this.labelColors,
  });

  // ✅ Translation map
  static const Map<String, String> enToAr = {
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

  // ✅ Get display label based on language
  String _getDisplayLabel(String canonicalKey) {
    //print('🏷️ [CHIP] Getting display label for: "$canonicalKey"');
    //print('🏷️ [CHIP] isArabic: $isArabic');

    if (isArabic) {
      final arabicLabel = enToAr[canonicalKey] ?? canonicalKey;
      //print('🏷️ [CHIP] Returning Arabic: "$arabicLabel"');
      return arabicLabel;
    }

    //print('🏷️ [CHIP] Returning English: "$canonicalKey"');
    return canonicalKey;
  }

  @override
  Widget build(BuildContext context) {
    //print('\n🔍 [FILTER CHIPS] ==========================================');
    //print('🔍 [FILTER CHIPS] selectedKey: "$selectedKey"');
    //print('🔍 [FILTER CHIPS] isArabic: $isArabic');
    //print('🔍 [FILTER CHIPS] totalCount: $totalCount');
    //print('🔍 [FILTER CHIPS] departmentCounts keys: ${departmentCounts.keys.toList()}');
    //print('🔍 [FILTER CHIPS] departmentCounts: $departmentCounts');
    //print('🔍 [FILTER CHIPS] ==========================================\n');

    var isMobile = context.isPhone;
    final List<MapEntry<String, int>> sortedDepartments =
    departmentCounts.entries.toList();

    return !isMobile ? SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ "All" chip - use English key internally
          _buildChip(
            context,
            canonicalKey: 'All',
            displayLabel: _getDisplayLabel('All'),
            count: totalCount,
          ),
          // ✅ Department chips - use English keys internally
          ...sortedDepartments.map((entry) {
            return _buildChip(
              context,
              canonicalKey: entry.key, // English key
              displayLabel: _getDisplayLabel(entry.key), // Localized display
              count: entry.value,
            );
          }),
        ],
      ),
    ) :
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ "All" chip - use English key internally
          _buildChip(
            context,
            canonicalKey: 'All',
            displayLabel: _getDisplayLabel('All'),
            count: totalCount,
          ),
          // ✅ Department chips - use English keys internally
          ...sortedDepartments.map((entry) {
            return _buildChip(
              context,
              canonicalKey: entry.key, // English key
              displayLabel: _getDisplayLabel(entry.key), // Localized display
              count: entry.value,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip(
      BuildContext context, {
        required String canonicalKey, // English key (e.g., "Marketing")
        required String displayLabel, // Localized label (e.g., "التسويق")
        required int count,
      }) {
    //print('🎨 [CHIP BUILD] canonicalKey: "$canonicalKey", displayLabel: "$displayLabel", count: $count');

    // ✅ Compare using English canonical keys
    final bool isSelected = selectedKey == canonicalKey;
    //print('🎨 [CHIP BUILD] isSelected: $isSelected (selectedKey="$selectedKey" vs canonicalKey="$canonicalKey")');

    final isMobile = MediaQuery.of(context).size.width < 600;
    final light = Theme.of(context).brightness == Brightness.light;

    // ✅ Color lookup using canonical key
    final Color? labelColor = labelColors?[canonicalKey];

    return GestureDetector(
      // ✅ Send canonical English key back to parent
      onTap: () {
        //print('👆 [CHIP TAP] Sending canonical key: "$canonicalKey"');
        onSelected(canonicalKey);
      },
      child: Row(
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: light
                  ? (isSelected ? AppColors.primary : AppColors.card)
                  : (isSelected ? AppColors.primary : AppColors.card),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                '$count',
                style: isMobile
                    ? AppTextStyles.font14BlackCairo.copyWith(
                  color: isSelected ? AppColors.textButton : AppColors.text,
                )
                    : AppTextStyles.font20BlackCairoMedium.copyWith(
                  color: isSelected ? AppColors.textButton : AppColors.text,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            FormatHelper.capitalize(displayLabel), // ✅ Display localized label
            style: isMobile
                ? AppTextStyles.font14BlackCairo.copyWith(
              color: labelColor ?? AppColors.text,
            )
                : AppTextStyles.font16BlackMediumCairo.copyWith(
              color: labelColor ?? AppColors.text,
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}