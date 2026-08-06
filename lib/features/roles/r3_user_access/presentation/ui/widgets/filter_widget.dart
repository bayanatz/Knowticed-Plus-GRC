import 'package:grc_module/core/constants/app_assets.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/custom/1-custom_dropdwon.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/generated/l10n.dart';

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
      child: CustomDropdown<SortOptionRole>(
        value: selectedSortOptionRole,
        fillColor: AppColors.field,
        borderRadius: BorderRadius.circular(8.r),
        hint: S.of(context).Sort,
        suffixIcon: CustomSvgImage(
          assetPath: AppAssets.sort,
          color: selectedSortOptionRole != null
              ? AppColors.textButton
              : AppColors.secondaryText,
        ),
        items: SortOptionRole.values.map((SortOptionRole sort) {
          return DropdownItem<SortOptionRole>(
            value: sort,
            label: sort.localizedName, // ✅ Uses enum localization
          );
        }).toList(),
        onChanged: (value) {
          onChanged(value);
        },
      ),
    );
  }
}