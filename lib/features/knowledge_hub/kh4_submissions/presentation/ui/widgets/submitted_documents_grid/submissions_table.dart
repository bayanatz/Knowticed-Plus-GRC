/// Module: knowledge_hub/kh4_submissions/presentation/ui/widgets/submitted_documents_grid
/// ************************* FILE INFO *************************** ///
/// File Name: submissions_table.dart
/// Description: Table — Submissions (S4) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/controller/analytics/analytics_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab/filter_statistics.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

String _getLocalizedAction(BuildContext context, String action) {
  switch (action.toLowerCase()) {
    case 'view':
      return S.of(context).view;
    case 'download':
      return S.of(context).download;
    default:
      return action;
  }
}

/// Minimum column widths (used when the table needs to scroll): number,
/// employee name, department, job title, date, time, action.
const List<double> _minColumnWidths = [80, 180, 160, 130, 130, 120, 100];

Widget statisticsTable(
  BuildContext context, {
  required bool lightMode,
  required List<DocumentUtilizationModel> actions,
  required TextEditingController searchStatisticsController,
  required Map<String, EmployeeData> usersCache,
}) {
  final cubit = context.read<AnalyticsCubit>();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10.w),
        child: filterStatistics(
          context,
          searchController: searchStatisticsController,
          onSearchChanged: (query) {},
        ),
      ),
      // The available width decides whether the table fits or scrolls.
      LayoutBuilder(
        builder: (context, constraints) => _buildResponsiveTable(
          context,
          availableWidth: constraints.maxWidth,
          table: _buildStatisticsTable(
            context,
            actions: actions,
            usersCache: usersCache,
            cubit: cubit,
            columnWidths: _columnWidths(constraints.maxWidth),
          ),
        ),
      ),
    ],
  );
}

double get _totalMinWidth => _minColumnWidths.fold<double>(0, (a, b) => a + b);

/// Columns scaled to fill [availableWidth] when the table fits, otherwise
/// the minimum widths (and the table scrolls sideways).
Map<int, TableColumnWidth> _columnWidths(double availableWidth) {
  final bool fits = availableWidth >= _totalMinWidth;
  final double scale = availableWidth / _totalMinWidth;
  return {
    for (int i = 0; i < _minColumnWidths.length; i++)
      i: FixedColumnWidth(
        fits ? _minColumnWidths[i] * scale : _minColumnWidths[i].sp,
      ),
  };
}

/// Wraps [table] in a horizontal scroll only when it does not fit.
Widget _buildResponsiveTable(
  BuildContext context, {
  required double availableWidth,
  required Widget table,
}) {
  if (availableWidth >= _totalMinWidth) {
    return Padding(
      padding: EdgeInsets.only(top: 10.w),
      child: table,
    );
  }
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Padding(
      padding: EdgeInsets.only(top: 10.w),
      child: SizedBox(
        width: _minColumnWidths.fold<double>(0, (a, b) => a + b.sp),
        child: table,
      ),
    ),
  );
}

Widget _buildStatisticsTable(
  BuildContext context, {
  required List<DocumentUtilizationModel> actions,
  required Map<String, EmployeeData> usersCache,
  required AnalyticsCubit cubit,
  required Map<int, TableColumnWidth> columnWidths,
}) {
  final S s = S.of(context);
  final headers = <String>[
    s.number,
    s.employeeName,
    s.department,
    s.jobTitle,
    s.date,
    s.time,
    s.action,
  ];
  final headerStyle = StyleText.fontSize12Weight400.copyWith(
    color: AppColors.colorWhite,
  );
  return Directionality(
    textDirection: Directionality.of(context),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8.sp),
      child: AnimatedSizeWrap(
        child: Table(
          border: TableBorder.all(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(10.sp),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columnWidths,
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.45),
              ),
              children: headers
                  .map(
                    (name) => Padding(
                      padding: EdgeInsets.all(10.sp),
                      child: Text(
                        name,
                        style: headerStyle,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  )
                  .toList(),
            ),
            ...List.generate(
              actions.length,
              (index) => TableRow(
                decoration: BoxDecoration(
                  color: index.isEven
                      ? AppColors.evenRowColor
                      : AppColors.oddRowColor,
                ),
                children: _buildDataCells(
                  context,
                  index: index,
                  action: actions[index],
                  usersCache: usersCache,
                  cubit: cubit,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

TextStyle get _cellStyle =>
    StyleText.fontSize12Weight400.copyWith(color: AppColors.blackButton);

/// Basic padded cell.
Widget _cell(Widget child) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
    child: DefaultTextStyle.merge(style: _cellStyle, child: child),
  );
}

/// Text cell; empty text shows '-'.
Widget _textCell(String text, {int maxLines = 2}) {
  return _cell(
    Text(
      text.isEmpty ? '-' : text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
    ),
  );
}

/// Employee name cell with avatar.
Widget _employeeCell(String userName, String userPhoto) {
  return _cell(
    Row(
      children: [
        CircleAvatar(
          radius: 12.5.sp,
          backgroundColor: AppColors.transparent,
          backgroundImage: userPhoto.isNotEmpty
              ? NetworkImage(userPhoto)
              : null,
          child: userPhoto.isEmpty
              ? ClipOval(
                  child: CustomSvgImage(
                    assetPath: "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                    width: 30.w,
                    height: 30.h,
                    fit: BoxFit.fill,
                  ),
                )
              : null,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            FormatHelper.capitalize(userName),
            style: _cellStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

/// The cells of one action row.
List<Widget> _buildDataCells(
  BuildContext context, {
  required int index,
  required DocumentUtilizationModel action,
  required Map<String, EmployeeData> usersCache,
  required AnalyticsCubit cubit,
}) {
  final S s = S.of(context);
  final EmployeeData? userData = usersCache[action.currentEmployeeId];
  if (userData == null) {
    khLog(
      '⚠️ [Table Row $index] Missing user data for userId: "${action.currentEmployeeId}"',
      name: 'StatisticsTable',
    );
  }
  final String userName = userData != null
      ? KhLocale.pick(
          context,
          en: userData.currentemployeeName,
          ar: userData.currentemployeeNameArabic,
        )
      : s.khUnknownUser;
  final String userRole = userData != null
      ? KhLocale.pick(
          context,
          en: userData.currentemployeeRole,
          ar: userData.currentemployeeRoleAr,
        )
      : s.notAvailable;
  final String departmentId = userData?.currentemployeeDepartment ?? '';
  final String departmentName = departmentId.isNotEmpty
      ? cubit.getDepartmentName(
          departmentId,
          isEnglish: KhLocale.isEnglish(context),
        )
      : '';

  // An unreadable time shows "—", never the current time.
  final DateTime? dateTime = KhLocale.parseStoredTime(action.currentTimestamp);
  String format(String pattern) =>
      dateTime == null ? '—' : KhLocale.formatDate(context, dateTime, pattern);

  return [
    _textCell('${index + 1}', maxLines: 1),
    _employeeCell(userName, userData?.currentemployeePhoto ?? ''),
    _textCell(
      FormatHelper.capitalize(
        departmentName.isNotEmpty ? departmentName : s.notAvailable,
      ),
    ),
    _textCell(FormatHelper.capitalize(userRole)),
    _textCell(FormatHelper.capitalize(format('dd MMM yyyy')), maxLines: 1),
    _textCell(FormatHelper.capitalize(format('h:mm a')), maxLines: 1),
    // 15/10/2026 — KH vertical report p.20: the action starts where its
    // header does, like every other column.
    _textCell(
      FormatHelper.capitalize(
        _getLocalizedAction(context, action.currentTypeOfAction),
      ),
      maxLines: 1,
    ),
  ];
}
