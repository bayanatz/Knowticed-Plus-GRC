import 'package:demo_app/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:demo_app/features/roles/core_widgets/main_widget/app_dropdown.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

// ============================================================
// 1. SORT OPTION ENUM WITH AR/EN SUPPORT
// ============================================================
enum SortOptionRole {
  firstName,
  lastName,
  firstLogin,
  lastLogin;

  // Get localized name
  String get localizedName {
    String currentLang = Get.locale?.languageCode ?? 'en';
    final translations = {
      'en': _englishName,
      'ar': _arabicName,
    };
    return translations[currentLang] ?? _englishName;
  }

  // English names
  String get _englishName {
    switch (this) {
      case SortOptionRole.firstName:
        return 'First Name';
      case SortOptionRole.lastName:
        return 'Last Name';
      case SortOptionRole.firstLogin:
        return 'First Login';
      case SortOptionRole.lastLogin:
        return 'Last Login';
    }
  }

  // Arabic names
  String get _arabicName {
    switch (this) {
      case SortOptionRole.firstName:
        return 'الاسم الأول';
      case SortOptionRole.lastName:
        return 'اسم العائلة';
      case SortOptionRole.firstLogin:
        return 'أول تسجيل دخول';
      case SortOptionRole.lastLogin:
        return 'آخر تسجيل دخول';
    }
  }
}

// ============================================================
// 2. SORT DROPDOWN WIDGET
// ============================================================
class SortDropdownWidgetRole extends StatelessWidget {
  final SortOptionRole? selectedSortOptionRole;
  final Function(SortOptionRole?) onChanged;
  final bool isMobile;
  final bool isPortrait;

  const SortDropdownWidgetRole({
    super.key,
    required this.selectedSortOptionRole,
    required this.onChanged,
    this.isMobile = false,
    this.isPortrait = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isPortrait ? 38.h : 100.sp,
        height: 40.h,
      child: AppDropdown(
        height: 40.h,
        yOffset: isPortrait ? 50.sp : 16.sp,
        borderRadius: 8.r,
        isAllCornersRounded: true,
        value: selectedSortOptionRole,
        width: double.infinity,
        menuWidth: 150.sp, // Increased for Arabic text
        fillColor: AppColors.field,
        menuItemHeight: 35.h,
        customButton: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          width: 100.sp,
        // height: 30.h,
          decoration: BoxDecoration(
            color: selectedSortOptionRole != null
                ? AppColors.primary
                : AppColors.field,
            // borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                fit: BoxFit.scaleDown,
                AppAssets.sort,
                color: selectedSortOptionRole != null
                    ? AppColors.textButton
                    : AppColors.secondaryText,
              ),
              if (!isMobile) SizedBox(width: 8.sp),
              if (!isMobile)
                Text(
                  'Sort'.tr,
                  style: AppTextStyles.font14BlackRegularCairo.copyWith(
                    color: selectedSortOptionRole != null
                        ? AppColors.textButton
                        : AppColors.secondaryText,
                  ),
                )
            ],
          ),
        ),
        textButton: 'Sort'.tr,
        isSelectedItemHasBackGround: true,
        items: SortOptionRole.values.map((SortOptionRole sort) {
          bool isSelected = selectedSortOptionRole == sort;
          return DropdownMenuItem<SortOptionRole>(
            value: sort,
            child: Container(
              alignment: AlignmentDirectional.centerStart, // ✅ RTL support
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              width: double.infinity,
              height: double.infinity,
              color: !isSelected ? Colors.transparent : AppColors.primary,
              child: Text(
                sort.localizedName, // ✅ Uses enum localization
                style: isSelected
                    ? AppTextStyles.font14BlackCairo
                    .copyWith(color: AppColors.textButton)
                    : AppTextStyles.font14SecondaryBlackCairo,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
        onChanged: (dynamic value) {
          if (value is SortOptionRole?) {
            onChanged(value);
          }
        },
      ),
    );
  }
}