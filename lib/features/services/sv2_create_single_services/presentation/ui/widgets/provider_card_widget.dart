/// Module: services / sv2_create_single_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: provider_card_widget.dart
/// Purpose: Provider card widget — declares ProviderCardWidget.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ProviderCardWidget extends StatelessWidget {
  final EmployeeEntityPro employee;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isEditMode; // ✅ NEW

  const ProviderCardWidget({
    super.key,
    required this.employee,
    required this.isSelected,
    required this.onTap,
    this.isEditMode = false, // ✅ NEW — default false
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final nameEn = [
      employee.firstName,
      employee.lastName,
    ].where((x) => (x ?? '').trim().isNotEmpty).join(' ').trim();

    final nameAr = [
      employee.firstNameInArabic,
      employee.lastNameInArabic,
    ].where((x) => (x ?? '').trim().isNotEmpty).join(' ').trim();

    final displayName = isArabic
        ? (nameAr.isNotEmpty ? nameAr : nameEn)
        : (nameEn.isNotEmpty ? FormatHelper.capitalize(nameEn) : nameAr);

    return GestureDetector(
      onTap: withHaptic(onTap, HapticLevel.low),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.only(
          right: 10.sp,
          left: 0.sp,
          top: 10.sp,
          bottom: 10.sp,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            SizedBox(width: 10.sp),
            Expanded(child: _buildInfo(displayName, isArabic)),
            _buildSelectionIndicator(isEditMode, isSelected),
            SizedBox(width: isArabic ? 10.sp : 0.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 30.r,
      backgroundColor: AppColors.transparent,
      child: ClipOval(
        child: CustomSvgImage.natural(
          assetPath: employee.gender == "male"
              ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
              : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
          fit: BoxFit.cover,
          width: 40.sp,
          height: 40.sp,
        ),
      ),
    );
  }

  Widget _buildInfo(String displayName, bool isArabic) {
    // Get department and role info here...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          displayName,
          style: StyleText.fontSize13Weight500
              .copyWith(color: AppColors.secondaryBlack)
              .copyWith(color: AppColors.text),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        SizedBox(height: 3.sp),
        // Add department and role text here...
      ],
    );
  }

  Widget _buildSelectionIndicator(bool isEditMode, bool isSelected) {
    if (isEditMode) {
      return Container(
        width: 20.sp,
        height: 20.sp,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.secondaryText,
            width: 2,
          ),
          color: isSelected ? AppColors.primary : AppColors.transparent,
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 10.sp,
                  height: 10.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                ),
              )
            : null,
      );
    }

    return CustomCheckBox(
      isSelected: isSelected,
      size: 20.sp,
      borderColor: AppColors.secondaryText,
    );
  }
}
