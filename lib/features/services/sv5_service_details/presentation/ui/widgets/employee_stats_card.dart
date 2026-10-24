/// Module: services / sv5_service_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employee_stats_card.dart
/// Purpose: One responsive card for an employee on the service-details
///          Employees tab (rule H12: replaces the separate mobile and tablet
///          card widgets, which repeated the same data and stats boxes).
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/info_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [EmployeeStatsCard]
///
/// Purpose: Avatar, name, department, job title, role and the done / hours /
/// breached boxes of one employee. [compact] stacks the boxes under the
/// details (phones); otherwise they sit beside them.
class EmployeeStatsCard extends StatelessWidget {
  const EmployeeStatsCard({
    required this.providerStats,
    required this.compact,
    super.key,
  });

  /// The map built by calculateStatsForEmployee.
  final Map<String, dynamic> providerStats;
  final bool compact;

  static const String _femaleAvatar =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png';
  static const String _maleAvatar =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png';

  @override
  Widget build(BuildContext context) {
    final details = _details(context);
    final stats = _stats(context);
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(context),
              SizedBox(width: 12.sp),
              Expanded(child: details),
            ],
          ),
          SizedBox(height: 12.sp),
          stats,
        ],
      );
    }
    return Row(
      children: [
        _avatar(context),
        SizedBox(width: !isTabletLandscape(context) ? 10.sp : 15.sp),
        Expanded(flex: 3, child: details),
        Expanded(flex: 4, child: stats),
      ],
    );
  }

  Widget _avatar(BuildContext context) {
    final size = compact ? 45.sp : 50.sp;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isFemale =
        providerStats["gender"]?.toString().toLowerCase() == 'female';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: compact
            ? null
            : Border.all(
                color: lightMode
                    ? AppColors.secondaryText.withValues(alpha: 0.2)
                    : AppColors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
      ),
      child: ClipOval(
        child: CustomSvgImage.natural(
          assetPath: isFemale ? _femaleAvatar : _maleAvatar,
          fit: BoxFit.cover,
          width: size,
          height: size,
        ),
      ),
    );
  }

  Widget _roleChip() {
    final role = providerStats["role"]?.toString() ?? '';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6.sp : 8.sp,
        vertical: 2.sp,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        FormatHelper.capitalize(role),
        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _secondaryLine(String text) {
    final style =
        compact ? StyleText.fontSize12Weight400 : StyleText.fontSize13Weight500;
    return Row(
      children: [
        Expanded(
          child: Text(
            FormatHelper.capitalize(text),
            style: style.copyWith(color: AppColors.secondaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _details(BuildContext context) {
    // Rule "All text in the translation files": an empty value reads as the
    // translated "Not available".
    final notAvailable = S.of(context).notAvailable;
    String orNotAvailable(Object? v) {
      final text = v?.toString().trim() ?? '';
      return (text.isEmpty || text == '-') ? notAvailable : text;
    }

    final fullName = orNotAvailable(providerStats["name"]);
    final department = orNotAvailable(providerStats["department"]);
    final jobTitle = orNotAvailable(providerStats["title"]);
    final hasRole = (providerStats["role"]?.toString() ?? '').isNotEmpty;

    final name = Text(
      FormatHelper.capitalize(fullName),
      style: (compact
              ? StyleText.fontSize14Weight600
              : StyleText.fontSize16Weight600)
          .copyWith(color: AppColors.blackButton),
      maxLines: compact ? 2 : 1,
      overflow: TextOverflow.ellipsis,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compact)
          name
        else
          Row(
            children: [
              Expanded(child: name),
              if (hasRole) ...[SizedBox(width: 8.sp), _roleChip()],
            ],
          ),
        SizedBox(height: compact ? 4.sp : 6.sp),
        _secondaryLine(department),
        SizedBox(height: compact ? 3.sp : 4.sp),
        _secondaryLine(jobTitle),
        if (compact && hasRole) ...[SizedBox(height: 4.sp), _roleChip()],
      ],
    );
  }

  Widget _stats(BuildContext context) {
    final s = S.of(context);
    final gap = compact ? 8.sp : (!isTabletLandscape(context) ? 8.sp : 12.sp);
    final done = providerStats["done"]?.toString() ?? '0';
    final hours = (providerStats["hours"] as num?)?.toStringAsFixed(1) ?? '0.0';
    final breached = providerStats["breached"]?.toString() ?? '0';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: infoBox(
            context,
            "${s.DoneServices}:",
            done,
            AppColors.transparent,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: infoBox(
            context,
            "${s.svcPlannedHours}:",
            hours,
            AppColors.transparent,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: infoBox(context, "${s.BreachedSLA}:", breached, AppColors.red),
        ),
      ],
    );
  }
}
