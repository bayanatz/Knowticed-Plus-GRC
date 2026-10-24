/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employee_card.dart
/// Purpose: Reusable employee statistics card widget
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class EmployeeStatsCard extends StatelessWidget {
  final List<Map<String, dynamic>> filteredItems;
  final String locale;
  final Map<String, String> enToArDepartments;
  final List<String> Function(List<Map<String, dynamic>>)
      getUniqueProviderEmails;
  final Map<String, dynamic> Function(String) calculateProviderStats;

  const EmployeeStatsCard({
    super.key,
    required this.filteredItems,
    required this.locale,
    required this.enToArDepartments,
    required this.getUniqueProviderEmails,
    required this.calculateProviderStats,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredItems.isEmpty) return const SizedBox();

    final uniqueProviders = getUniqueProviderEmails(filteredItems);
    final statsList = uniqueProviders.map((email) {
      return calculateProviderStats(email);
    }).toList();

    return Column(
      children: List.generate(statsList.length, (index) {
        final providerStats = statsList[index];

        final item = filteredItems.firstWhere(
          (e) => e['provider'] == providerStats['name'],
        );
        final selectedProvider = item['selectedProvider'] ?? {};

        return _EmployeeCard(
          providerStats: providerStats,
          selectedProvider: selectedProvider,
          locale: locale,
          enToArDepartments: enToArDepartments,
        );
      }),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> providerStats;
  final Map<String, dynamic> selectedProvider;
  final String locale;
  final Map<String, String> enToArDepartments;

  const _EmployeeCard({
    required this.providerStats,
    required this.selectedProvider,
    required this.locale,
    required this.enToArDepartments,
  });

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    final providerName = _getProviderName(selectedProvider, locale);
    final providerTitle = _getProviderTitle(selectedProvider, locale);
    final originalDept = providerStats['department'] ?? '-';
    final localizedDepartment = locale == 'ar'
        ? enToArDepartments[originalDept] ?? originalDept
        : originalDept;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.sp),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return isMobile
                ? _buildMobileLayout(
                    context,
                    providerName,
                    providerTitle,
                    localizedDepartment,
                    lightMode,
                  )
                : _buildTabletLayout(
                    context,
                    providerName,
                    providerTitle,
                    localizedDepartment,
                    lightMode,
                  );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    String providerName,
    String providerTitle,
    String localizedDepartment,
    bool lightMode,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 12.sp),
            _buildAvatar(),
            SizedBox(width: 6.sp),
            _buildEmployeeInfo(
              context,
              providerName,
              providerTitle,
              localizedDepartment,
              lightMode,
            ),
          ],
        ),
        SizedBox(height: 15.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInfoBox(
              context,
              "${S.of(context).ServicesDone}:",
              providerStats["done"].toString(),
              AppColors.transparent,
              lightMode,
            ),
            SizedBox(width: 8.sp),
            _buildInfoBox(
              context,
              "${S.of(context).svcPlannedHours}:",
              providerStats["hours"].toStringAsFixed(1),
              AppColors.transparent,
              lightMode,
            ),
            SizedBox(width: 8.sp),
            _buildInfoBox(
              context,
              "${S.of(context).BreachedSLA}:",
              providerStats["breached"].toString(),
              AppColors.red,
              lightMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    String providerName,
    String providerTitle,
    String localizedDepartment,
    bool lightMode,
  ) {
    final isTabletLandscape = _isTabletLandscape(context);

    return Row(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10.sp),
                _buildAvatar(),
                SizedBox(width: 6.sp),
                _buildEmployeeInfo(
                  context,
                  providerName,
                  providerTitle,
                  localizedDepartment,
                  lightMode,
                ),
              ],
            ),
          ],
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInfoBox(
              context,
              "${S.of(context).ServicesDone}:",
              providerStats["done"].toString(),
              AppColors.transparent,
              lightMode,
            ),
            SizedBox(width: isTabletLandscape ? 30.sp : 8.sp),
            _buildInfoBox(
              context,
              "${S.of(context).svcPlannedHours}:",
              providerStats["hours"].toStringAsFixed(1),
              AppColors.transparent,
              lightMode,
            ),
            SizedBox(width: isTabletLandscape ? 30.sp : 8.sp),
            _buildInfoBox(
              context,
              "${S.of(context).BreachedSLA}:",
              providerStats["breached"].toString(),
              AppColors.red,
              lightMode,
            ),
            SizedBox(width: isTabletLandscape ? 30.sp : 8.sp),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return ClipOval(
      child: CustomSvgImage.natural(
        assetPath:
            "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
        fit: BoxFit.scaleDown,
        width: 40.sp,
        height: 40.sp,
        semanticsLabel: 'Profile',
      ),
    );
  }

  Widget _buildEmployeeInfo(
    BuildContext context,
    String providerName,
    String providerTitle,
    String localizedDepartment,
    bool lightMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 5.sp),
        Text(
          FormatHelper.capitalize(providerName.isNotEmpty ? providerName : '-'),
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(width: 17.sp),
        Text(
          FormatHelper.capitalize(
            providerTitle.isNotEmpty ? providerTitle : '-',
          ),
          style: StyleText.fontSize12Weight500.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        SizedBox(width: 24.sp),
        Text(
          FormatHelper.capitalize(localizedDepartment),
          style: StyleText.fontSize12Weight500.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(
    BuildContext context,
    String title,
    String value,
    Color colorBorder,
    bool lightMode,
  ) {
    final isMobile = ContextExtension(context).isPhone;
    final isTabletLandscape = _isTabletLandscape(context);

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
        border: Border.all(color: colorBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            FormatHelper.capitalize(title),
            style: isMobile
                ? StyleText.fontSize10Weight400.copyWith(
                    wordSpacing: 0,
                    letterSpacing: 0,
                    color: AppColors.secondaryText,
                  )
                : !isTabletLandscape
                    ? StyleText.fontSize13Weight500
                        .copyWith(color: AppColors.secondaryBlack)
                        .copyWith(color: AppColors.secondaryText)
                    : StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.secondaryText,
                      ),
          ),
          SizedBox(width: 6.sp),
          Text(
            FormatHelper.capitalize(value),
            style: isMobile
                ? StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.blackButton,
                  )
                : !isTabletLandscape
                    ? StyleText.fontSize13Weight500
                        .copyWith(color: AppColors.secondaryBlack)
                        .copyWith(color: AppColors.blackButton)
                    : StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  String _getProviderName(
    Map<String, dynamic> selectedProvider,
    String locale,
  ) {
    if (locale == 'ar') {
      final arabicFirst =
          selectedProvider['firstNameInArabic']?.toString().trim() ?? '';
      final arabicLast =
          selectedProvider['lastNameInArabic']?.toString().trim() ?? '';

      if (arabicFirst.isNotEmpty || arabicLast.isNotEmpty) {
        final arabicName = '$arabicFirst $arabicLast'.trim();
        if (arabicName.isNotEmpty && arabicName != 'null null') {
          return arabicName;
        }
      }
    }

    final englishFirst = selectedProvider['firstName']?.toString().trim() ?? '';
    final englishLast = selectedProvider['lastName']?.toString().trim() ?? '';
    final englishName = '$englishFirst $englishLast'.trim();
    return englishName.isNotEmpty && englishName != 'null null'
        ? englishName
        : '-';
  }

  String _getProviderTitle(
    Map<String, dynamic> selectedProvider,
    String locale,
  ) {
    return locale == 'ar'
        ? selectedProvider['titleInArabic']?.toString().trim() ??
            selectedProvider['title']?.toString().trim() ??
            '-'
        : selectedProvider['title']?.toString().trim() ?? '-';
  }

  bool _isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }
}
