import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:demo_app/core/theme/app_colors.dart';

class CategoryFilterChips extends StatelessWidget {
  final String selectedCategory;
  final Function(String category) onSelected;
  final int allCount;
  final int serviceCount;
  final int formCount;
  final int messagesCount;
  final int qiyasCount;
  final bool isArabic;
  final Map<String, Color>? categoryColors;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
    required this.allCount,
    required this.serviceCount,
    required this.formCount,
    required this.messagesCount,
    required this.qiyasCount,
    this.isArabic = false,
    this.categoryColors,
  });

  // Get localized labels
  String get allLabel => isArabic ? 'الكل' : 'All';
  String get serviceLabel => isArabic ? 'خدمة' : 'Service';
  String get formLabel => isArabic ? 'نموذج' : 'Form';
  String get messagesLabel => isArabic ? 'رسائل' : 'Messages';
  String get qiyasLabel => isArabic ? 'قياس' : 'Qiyas';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(context, label: allLabel, count: allCount),
          _buildChip(context, label: serviceLabel, count: serviceCount),
          _buildChip(context, label: formLabel, count: formCount),
          _buildChip(context, label: messagesLabel, count: messagesCount),
          _buildChip(context, label: qiyasLabel, count: qiyasCount),
        ],
      ),
    );
  }

  Widget _buildChip(
      BuildContext context, {
        required String label,
        required int count,
      }) {
    final bool isSelected = selectedCategory == label;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final light = Theme.of(context).brightness == Brightness.light;
    final Color? labelColor = categoryColors?[label];

    return GestureDetector(
      onTap: () => onSelected(label),
      child: Row(
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: light
                  ? (isSelected ? AppColors.primary : AppColors.white)
                  : (isSelected ? AppColors.primary : AppColors.chatBackground),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                '$count',
                style: isMobile
                    ? StyleText.fontSize14Weight600.copyWith(
                  color: isSelected
                      ? AppColors.textButton
                      : (light
                      ? AppColors.secondaryText
                      : AppColors.grey),
                )
                    : StyleText.fontSize20Weight500.copyWith(
                  color: isSelected
                      ? AppColors.textButton
                      : (light
                      ? AppColors.secondaryText
                      : AppColors.grey),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            label,
            style: isMobile
                ? StyleText.fontSize14Weight600.copyWith(
              color: labelColor ??
                  (light
                      ? (isSelected
                      ? AppColors.blackButton
                      : AppColors.secondaryText)
                      : (isSelected
                      ? AppColors.white
                      : AppColors.grey)),
            )
                : StyleText.fontSize16Weight500.copyWith(
              color: labelColor ??
                  (light
                      ? (isSelected
                      ? AppColors.blackButton
                      : AppColors.secondaryText)
                      : (isSelected
                      ? AppColors.white
                      : AppColors.grey)),
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}