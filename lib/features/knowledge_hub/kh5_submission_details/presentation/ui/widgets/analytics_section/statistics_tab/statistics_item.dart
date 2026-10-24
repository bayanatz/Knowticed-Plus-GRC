/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab
/// ************************* FILE INFO *************************** ///
/// File Name: statistics_item.dart
/// Description: Build statistics item — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/controller/analytics/analytics_cubit.dart';

Widget buildStatisticsItem(
  BuildContext context, {
  required bool lightMode,
  required bool isMobile,
  required DocumentUtilizationModel action,
  required EmployeeData? userData,
}) {
  // An unreadable time shows "—", never the current time.
  final DateTime? dateTime = KhLocale.parseStoredTime(action.currentTimestamp);
  final formattedDate = dateTime == null
      ? '—'
      : KhLocale.formatDate(context, dateTime, 'dd MMM yyyy');
  final formattedTime = dateTime == null
      ? '—'
      : KhLocale.formatDate(context, dateTime, 'h:mm a');

  // Get user data from EmployeeData model
  final userName = userData == null
      ? S.of(context).khUnknownUser
      : KhLocale.pick(
          context,
          en: userData.currentemployeeName,
          ar: userData.currentemployeeNameArabic,
        );
  final userPhoto = userData?.currentemployeePhoto ?? '';
  final String role = userData == null
      ? ''
      : KhLocale.pick(
          context,
          en: userData.currentemployeeRole,
          ar: userData.currentemployeeRoleAr,
        );
  final userRole = role.isNotEmpty ? role : S.of(context).notAvailable;

  // Get department ID and resolve to department name
  final departmentId = userData?.currentemployeeDepartment ?? '';
  final cubit = context.read<AnalyticsCubit>();
  final String departmentName = cubit.getDepartmentName(
    departmentId,
    isEnglish: KhLocale.isEnglish(context),
  );
  final userDepartment = departmentName.isNotEmpty
      ? departmentName
      : S.of(context).notAvailable;

  final S s = S.of(context);
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color: lightMode ? AppColors.white : AppColors.background,
    ),
    margin: EdgeInsets.symmetric(vertical: 10.w),
    padding: EdgeInsets.all(10.w),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: _statRow(
                label: s.date,
                value: dateTime == null
                    ? '—'
                    : s.khDateAtTime(formattedDate, formattedTime),
              ),
            ),
            _buildActionChip(context, action.currentTypeOfAction),
          ],
        ),
        SizedBox(height: 10.h),
        _statRow(
          label: s.employeeName,
          value: _titleCase(userName),
          leading: CircleAvatar(
            radius: 12.5.sp,
            backgroundColor: AppColors.primary,
            backgroundImage: userPhoto.isNotEmpty
                ? NetworkImage(userPhoto)
                : null,
            child: userPhoto.isEmpty ? Icon(Icons.person, size: 15.sp) : null,
          ),
        ),
        SizedBox(height: 10.h),
        _statRow(label: s.jobTitle, value: _titleCase(userRole)),
        SizedBox(height: 10.h),
        // department name, not ID
        _statRow(label: s.department, value: _titleCase(userDepartment)),
      ],
    ),
  );
}

/// "Label: value" line of a statistics item, with an optional avatar.
Widget _statRow({
  required String label,
  required String value,
  Widget? leading,
}) {
  return Row(
    children: [
      Text(
        '$label: ',
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      if (leading != null) ...[leading, SizedBox(width: 3.w)],
      Flexible(
        child: Text(
          value,
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.blackButton,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

/// The View / Download chip.
Widget _buildActionChip(BuildContext context, String action) {
  return Container(
    width: 60.sp,
    height: 20.sp,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4.r),
      color: AppColors.chatBackground,
    ),
    child: Center(
      child: Text(
        _actionLabel(context, action),
        style: StyleText.fontSize10Weight400.copyWith(
          color: AppColors.blackButton,
        ),
      ),
    ),
  );
}

/// KH mobile report p.17: names, job titles and the
/// action chip were shown exactly as stored ("ibrahim al-shammari",
/// "chief marketing officer (cmo)", "download"). Words are capitalised —
/// including after a hyphen, so "Al-Shammari" — and known abbreviations
/// (CMO, IT…) are upper-cased by FormatHelper. Arabic text is unchanged.
String _titleCase(String value) {
  final String words = FormatHelper.capitalize(value);
  return words.replaceAllMapped(
    RegExp(r'-([a-z])'),
    (m) => '-${m.group(1)!.toUpperCase()}',
  );
}

/// The action chip in the user's language ("View" / "Download").
String _actionLabel(BuildContext context, String action) {
  switch (action.trim().toLowerCase()) {
    case 'view':
      return S.of(context).view;
    case 'download':
      return S.of(context).download;
    default:
      return _titleCase(action);
  }
}
