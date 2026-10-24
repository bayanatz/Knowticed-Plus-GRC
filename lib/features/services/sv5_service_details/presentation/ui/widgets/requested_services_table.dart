/// Module: services / sv5_service_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: requested_services_table.dart
/// Purpose: Table — declares TableDetailsServicesWidget.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

// 'dart:math' removed 31/8/2026 — nothing in this file used it.
import 'package:knowticed_plus/core/di/app_controllers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/table/default_data_table.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/pages/approval_request_details_toggle.dart';

import 'package:knowticed_plus/features/services/helpers/services_text.dart';

class TableDetailsServicesWidget extends StatelessWidget {
  final BuildContext context;
  final ServicesHistoryModel parentModel;
  final List<Map<String, dynamic>> map;

  TableDetailsServicesWidget({
    super.key,
    required this.context,
    required this.parentModel,
    required this.map,
  });

  // ✅ Get controllers
  MainCoreEmployeeController get _employeeController => AppControllers.employee;

  // Status color mapping
  final Map<String, Color> _statusTextColors = {
    'approved': AppColors.green,
    'done': AppColors.lightGreen,
    'rejected': AppColors.red,
    'pending': AppColors.orange,
    'inprogress': AppColors.secondaryPrimary,
    'cancel': AppColors.red,
    'canceled': AppColors.red,
    'breached sla': AppColors.red,
    'branchsla': AppColors.red,
  };

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight600.copyWith(color: AppColors.white);

  /// CHANGED 31/8/2026: 12.sp semibold, matching System Logs / Active
  /// Directory (see custom_table_body.dart) and the Services dashboard table.
  /// Was `font13SecondaryBlackCairo` — a size that existed nowhere else in the
  /// app's tables.
  TextStyle _cellStyle(BuildContext context) {
    return StyleText.fontSize12Weight600.copyWith(color: AppColors.text);
  }

  String _fmtInt(int n) => n.toString();

  /// The body of one cell.
  ///
  /// CHANGED 31/8/2026: height pinned to 38.h and centred, so a row never
  /// changes height and each value sits under the middle of its heading —
  /// `CustomTableBody`'s shape, which is what the Roles tables use. The old
  /// `Container` with 10/8.sp padding and start-aligned text belonged to the
  /// hand-built `Table` this file no longer renders.
  Widget _cell(BuildContext context, Widget child) {
    return SizedBox(
      height: 38.h,
      child: Align(
        alignment: Alignment.center,
        child: DefaultTextStyle.merge(style: _cellStyle(context), child: child),
      ),
    );
  }

  Widget _textCell(
    BuildContext context,
    String text, {
    int maxLines = 1,
    TextAlign textAlign = TextAlign.center,
    Color? textColor,
  }) {
    return _cell(
      context,
      Text(
        FormatHelper.capitalize(text.isEmpty ? '-' : text),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: textColor != null
            ? _cellStyle(context).copyWith(color: textColor)
            : null,
      ),
    );
  }

  /// One heading, as a `DataColumn`.
  ///
  /// `headingRowAlignment` rather than a `Center` around the `Text`: DataTable
  /// lays a heading out in a Row that hands its child unbounded width, so a
  /// `Center` would centre nothing. It is direction-aware, so this reads the
  /// same in Arabic.
  DataColumn _headerColumn(String text) {
    return DataColumn(
      headingRowAlignment: MainAxisAlignment.center,
      label: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        child: Text(
          text,
          style: _headerStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _requesterCell(BuildContext context, Map<String, dynamic> item) {
    final model = item['model'] as ServicesHistoryModel;

    String email = '';
    if (model.currentEmailRequester.isNotEmpty) {
      email = model.currentEmailRequester;
    }

    String requester = '-';
    String? gender = 'male';

    if (email.isNotEmpty) {
      requester = _employeeController.getEmployeeNameEnglishArabic(
        email,
        !context.svcIsArabic,
      );
      final employee = _employeeController.mapOfEmployeesWithEmailKey[email];
      gender = employee?.gender?.toLowerCase() ?? 'male';
    }

    final isMale = (gender) == 'male';

    // Avatar, then the name, in the reading direction.
    return _cell(
      context,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: CustomSvgImage.natural(
              assetPath: isMale
                  ? "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png"
                  : "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png",
              width: 22.sp,
              height: 22.sp,
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              FormatHelper.capitalize(
                requester.trim().isEmpty ? '-' : requester.trim(),
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _providerCell(BuildContext context, Map<String, dynamic> item) {
    final model = item['model'] as ServicesHistoryModel;

    String providerName = '-';
    String? providerGender;

    if (model.currentProviderServices.isNotEmpty) {
      // ✅ FIX: Match assigned provider email instead of always using .first
      final assignedEmail =
          model.currentAssignedProviderEmail.toLowerCase().trim();

      ServiceEmployeeModel? provider;

      if (assignedEmail.isNotEmpty) {
        for (final p in model.currentProviderServices) {
          if ((p.email?.toLowerCase().trim() ?? '') == assignedEmail) {
            provider = p;
            break;
          }
        }
      }

      // Fallback to first if no match found
      provider ??= model.currentProviderServices.first;

      // The reader's version of the name, else the other one.
      providerName = context.svcPick(
        "${provider.firstName ?? ''} ${provider.lastName ?? ''}".trim(),
        "${provider.firstNameInArabic ?? ''} ${provider.lastNameInArabic ?? ''}"
            .trim(),
      );

      providerGender = provider.gender?.toLowerCase();
    }

    if (providerName.isEmpty || providerName == '') {
      return _textCell(context, '-');
    }

    final isMale = (providerGender ?? 'male') == 'male';

    // Avatar, then the name, in the reading direction.
    return _cell(
      context,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: CustomSvgImage.natural(
              assetPath: isMale
                  ? "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png"
                  : "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png",
              width: 22.sp,
              height: 22.sp,
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              FormatHelper.capitalize(providerName),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return _statusTextColors[status.toLowerCase()] ??
        (lightMode ? AppColors.secondaryText : AppColors.white);
  }

  // ✅ UPDATED - Dynamic department fetching
  String _getDepartmentText(ServicesHistoryModel model) {
    String email = '';
    if (model.currentEmailRequester.isNotEmpty) {
      email = model.currentEmailRequester;
    }

    if (email.isEmpty) return '-';

    // Get employee from controller
    final employee = _employeeController.mapOfEmployeesWithEmailKey[email];

    if (employee == null || employee.departmentId == null) {
      return '-';
    }

    // The reader's name of the department.
    return context.svcDepartmentName(employee.departmentId);
  }

  String _getJobTitle(ServicesHistoryModel model) {
    String email = '';
    if (model.currentEmailRequester.isNotEmpty) {
      email = model.currentEmailRequester;
    }

    if (email.isEmpty) return '-';

    return _employeeController.getEmployeeJobTitle(email);
  }

  String _formatRequestedDate(ServicesHistoryModel model) {
    if (model.timestamps.isEmpty) return '-';

    final date = DateTime.fromMillisecondsSinceEpoch(model.timestamps.first);
    return DateFormat(
      'dd MMM yyyy',
      Localizations.localeOf(context).languageCode,
    ).format(date);
  }

  @override
  Widget build(BuildContext context) {
    // CHANGED 31/8/2026: was a hand-built `Table` with FlexColumnWidth ratios
    // and a `TableRow` header painted by a lightMode ternary.
    //
    // It is r4's DefaultDataTable now — the same component System Logs and
    // Active Directory use, and the same one the Services dashboard table
    // moved onto — so all three read as one table: dark heading band in
    // AppColors.header, centred 14.sp labels over centred 12.sp values, and
    // columns measured from their own content.
    //
    // fillWidth: true keeps what the FlexColumnWidth ratios were for. Without
    // it DefaultDataTable's horizontal scroll view hands the table unbounded
    // width and it sizes to content, leaving empty space beside a seven-column
    // table. The flex RATIOS themselves are gone: DataTable distributes
    // surplus space itself, so keeping them would have been a second, ignored
    // opinion about column widths.
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.sp),
          child: DefaultDataTable(
            fillWidth: true,
            columns: [
              _headerColumn(S.of(context).number),
              _headerColumn(S.of(context).serviceRequester),
              _headerColumn(S.of(context).department),
              _headerColumn(S.of(context).jobTitle),
              _headerColumn(S.of(context).RequestedDate),
              _headerColumn(S.of(context).status),
              _headerColumn(S.of(context).serviceProvider),
            ],
            rows: _dataRows(context),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  /// The request rows.
  ///
  /// Striping rides on `DataRow.color` rather than a `BoxDecoration`: DataTable
  /// paints the row itself, so a coloured box nested in a cell would sit inside
  /// the cell padding instead of behind the whole row.
  ///
  /// The row tap is `DataRow.onSelectChanged`, which replaces the per-cell
  /// InkWell wrapper (`_rowTapWrapper`) the old Table needed — seven InkWells
  /// per row, each with its own ripple, to fake one tappable row.
  /// DefaultDataTable sets `showCheckboxColumn: false`, so making rows
  /// selectable adds no checkbox column.
  List<DataRow> _dataRows(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return List.generate(map.length, (index) {
      final item = map[index];
      final model = item['model'] as ServicesHistoryModel;
      final isEven = index.isEven;
      final rowColor = lightMode
          ? (isEven ? AppColors.background : AppColors.white)
          : (isEven ? AppColors.darkDashboardTable : AppColors.black);

      void goToDetails() {
        final detailsIndex = map.indexOf(item);

        if (model.currentProviderServices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).requestHasNoAssignedProvider),
              backgroundColor: AppColors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        navigateTo(
          context,
          ServicesApprovalDetailsToggle(
            createServicesModel: model,
            index: detailsIndex,
            approvalModel: model,
            fromTable: true,
          ),
        );
      }

      return DataRow(
        color: WidgetStatePropertyAll(rowColor),
        onSelectChanged: (_) => goToDetails(),
        cells: [
          DataCell(_textCell(context, _fmtInt(index + 1))),
          DataCell(_requesterCell(context, item)),
          DataCell(_textCell(context, _getDepartmentText(model))),
          DataCell(_textCell(context, _getJobTitle(model))),
          DataCell(_textCell(context, _formatRequestedDate(model))),
          DataCell(
            _textCell(
              context,
              context.svcStatus(item['status']?.toString()),
              textColor: _getStatusColor(
                item['status']?.toString() ?? '',
                context,
              ),
            ),
          ),
          DataCell(_providerCell(context, item)),
        ],
      );
    });
  }
}

Widget tableDetailsServices(
  BuildContext context,
  ServicesHistoryModel parentModel,
  List<Map<String, dynamic>> map,
) {
  return TableDetailsServicesWidget(
    context: context,
    parentModel: parentModel,
    map: map,
  );
}
