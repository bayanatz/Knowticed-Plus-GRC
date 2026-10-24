/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employee_card.dart
/// Purpose: The provider cards of the department dashboard's employees
///          tab — name, title and department, with services done, planned
///          hours and breached SLA.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';

/// One "title: value" stat box.
class InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final Color borderColor;
  final bool isTabletLandscape;
  final Color? titleColor;
  final Color? valueColor;

  const InfoBox({
    super.key,
    required this.title,
    required this.value,
    this.borderColor = AppColors.transparent,
    this.isTabletLandscape = false,
    this.titleColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = kpIsPhoneLayout(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final style = isMobile
        ? StyleText.fontSize10Weight500.copyWith(
            wordSpacing: 0,
            letterSpacing: 0,
          )
        : isTabletLandscape
            ? StyleText.fontSize16Weight500
            : StyleText.fontSize13Weight500;

    return Container(
      height: isMobile ? 30.sp : 38.sp,
      width: isMobile
          ? 100.sp
          : isTabletLandscape
              ? 160.sp
              : 130.sp,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            FormatHelper.capitalize(title),
            style: style.copyWith(
              color: titleColor ??
                  (lightMode ? AppColors.mediumGrey : AppColors.grey),
            ),
          ),
          SizedBox(width: 6.sp),
          Text(
            value,
            style: style.copyWith(
              color: valueColor ??
                  (lightMode
                      ? AppColors.black.withValues(alpha: 0.87)
                      : AppColors.white.withValues(alpha: 0.70)),
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeCardDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> filteredItems;
  final Map<String, String> enToArDepartments;
  final List<String> Function(List<Map<String, dynamic>>) getUniqueProviders;
  final Map<String, dynamic> Function(String) calculateProviderStats;
  final String servicesDoneText;
  final String totalHoursText;
  final String breachedSLAText;
  final bool isTabletLandscape;
  final Color? cardBackgroundColor;
  final Color? textColor;
  final Color? subtitleColor;
  final Color? breachedBorderColor;

  const EmployeeCardDashboard({
    super.key,
    required this.filteredItems,
    required this.enToArDepartments,
    required this.getUniqueProviders,
    required this.calculateProviderStats,
    required this.servicesDoneText,
    required this.totalHoursText,
    required this.breachedSLAText,
    this.isTabletLandscape = false,
    this.cardBackgroundColor,
    this.textColor,
    this.subtitleColor,
    this.breachedBorderColor,
  });

  static String _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return (text.isEmpty || text == 'null') ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    if (filteredItems.isEmpty) return const SizedBox.shrink();

    final isMobile = kpIsPhoneLayout(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final cardColor = cardBackgroundColor ??
        (lightMode ? AppColors.white : AppColors.darkGrey);
    final nameColor = textColor ??
        (lightMode
            ? AppColors.black.withValues(alpha: 0.87)
            : AppColors.white.withValues(alpha: 0.70));
    final subColor =
        subtitleColor ?? (lightMode ? AppColors.mediumGrey : AppColors.grey);

    final cards = <Widget>[];
    for (final email in getUniqueProviders(filteredItems)) {
      final stats = calculateProviderStats(email);
      final item = filteredItems.firstWhere(
        (e) => e['provider'] == stats['name'],
        orElse: () => const {},
      );
      if (item.isEmpty) continue;

      final provider = item['selectedProvider'] is Map
          ? item['selectedProvider'] as Map
          : const {};
      final name = context.svcPick(
        '${provider['firstName'] ?? ''} ${provider['lastName'] ?? ''}'.trim(),
        '${provider['firstNameInArabic'] ?? ''} ${provider['lastNameInArabic'] ?? ''}'
            .trim(),
      );
      final title = context.svcPick(
        provider['title']?.toString(),
        provider['titleInArabic']?.toString(),
      );
      final department = _text(stats['department']);
      final identity = _ProviderIdentity(
        name: _text(name),
        title: _text(title),
        department: context.svcIsArabic
            ? enToArDepartments[department] ?? department
            : department,
        isMale: provider['gender']?.toString().toLowerCase() != 'female',
        nameColor: nameColor,
        subColor: subColor,
      );
      final gap = SizedBox(
        width: !isMobile && isTabletLandscape ? 30.sp : 8.sp,
      );
      final boxes = <Widget>[
        InfoBox(
          title: '$servicesDoneText:',
          value: context.svcNumber(stats['done'] as num? ?? 0),
          isTabletLandscape: isTabletLandscape,
        ),
        gap,
        InfoBox(
          title: '$totalHoursText:',
          value: context.svcNumber(
            num.parse(((stats['hours'] as num?) ?? 0).toStringAsFixed(1)),
          ),
          isTabletLandscape: isTabletLandscape,
        ),
        gap,
        InfoBox(
          title: '$breachedSLAText:',
          value: context.svcNumber(stats['breached'] as num? ?? 0),
          borderColor: breachedBorderColor ?? AppColors.red,
          isTabletLandscape: isTabletLandscape,
        ),
        if (!isMobile) gap,
      ];

      cards.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.sp),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 10.sp),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: isMobile
                ? Column(
                    children: [
                      identity,
                      SizedBox(height: 15.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: boxes,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      identity,
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: boxes,
                      ),
                    ],
                  ),
          ),
        ),
      );
    }
    return Column(children: cards);
  }
}

/// Avatar with the provider's name, title and department.
class _ProviderIdentity extends StatelessWidget {
  final String name;
  final String title;
  final String department;
  final bool isMale;
  final Color nameColor;
  final Color subColor;

  const _ProviderIdentity({
    required this.name,
    required this.title,
    required this.department,
    required this.isMale,
    required this.nameColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final sub = StyleText.fontSize12Weight500.copyWith(color: subColor);
    return Row(
      children: [
        SizedBox(width: 10.sp),
        ClipOval(
          child: CustomSvgImage.natural(
            assetPath: isMale
                ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
            fit: BoxFit.scaleDown,
            width: 40.sp,
            height: 40.sp,
          ),
        ),
        SizedBox(width: 6.sp),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FormatHelper.capitalize(name),
              style: StyleText.fontSize14Weight500.copyWith(color: nameColor),
            ),
            SizedBox(height: 4.h),
            Text(FormatHelper.capitalize(title), style: sub),
            SizedBox(height: 4.h),
            Text(FormatHelper.capitalize(department), style: sub),
          ],
        ),
      ],
    );
  }
}
