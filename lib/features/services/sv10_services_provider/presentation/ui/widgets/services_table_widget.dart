/// Module: services / sv10_services_provider / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: services_table_widget.dart
/// Purpose: The provider's requests as a table (the list view of "my
///          assigned services"). Renamed from custom_table.dart after its
///          class (Provider rule 16); the unused CustomDataTable and its
///          cells were removed (rule 21).
/// Author: Amr Mesbah
/// Created At: 14/10/2025
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): headers, statuses and time units from the
///     translation files (rule 10); the colour is chosen by the status key,
///     never by its translated label (rule 5); bilingual fields through
///     svcPick (rule 11); theme colours only (rule 9).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';
import 'package:knowticed_plus/features/services/helpers/services_status_colors.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/controller/employee_services_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [ServicesTableWidget]
///
/// Purpose: One row per request; tapping a row opens it.
class ServicesTableWidget extends StatelessWidget {
  final List<ServicesHistoryModel> services;
  final void Function(ServicesHistoryModel)? onRowTap;

  const ServicesTableWidget({super.key, required this.services, this.onRowTap});

  TextStyle get _headerStyle =>
      StyleText.fontSize15Weight400.copyWith(color: AppColors.white);

  TextStyle get _cellStyle =>
      StyleText.fontSize13Weight500.copyWith(color: AppColors.blackButton);

  /// The colour of a status, by its key (shared rule).
  static Color statusColor(String status) => ServicesStatusColors.of(status);

  /// Width of a column sized to its longest text, between [min] and [max].
  double _fitWidth(
    BuildContext context,
    Iterable<String> texts, {
    required double empty,
    required double min,
    required double max,
    double padding = 40,
  }) {
    var longest = 0.0;
    for (final t in texts) {
      if (t.trim().isNotEmpty)
        longest = math.max(longest, t.trim().length * 1.0);
    }
    if (longest == 0) return empty;
    return math.max(math.min(longest * 8.sp + padding.sp, max), min);
  }

  Map<int, TableColumnWidth> _columnWidths(BuildContext context) {
    final portrait = context.isPortrait;
    return {
      0: FixedColumnWidth(portrait ? 50.w : 60.w),
      1: FixedColumnWidth(
        _fitWidth(
          context,
          services.map(
            (s) => context.svcPick(
              s.currentServiceNameEnglish,
              s.currentServiceNameArabic,
            ),
          ),
          empty: portrait ? 120.w : 150.w,
          min: portrait ? 100.sp : 120.sp,
          max: 250.w,
        ),
      ),
      2: FixedColumnWidth(
        _fitWidth(
          context,
          services.map(_requesterName(context)),
          empty: portrait ? 150.w : 180.w,
          min: portrait ? 130.sp : 150.sp,
          max: 200.w,
          padding: 60,
        ),
      ),
      3: FixedColumnWidth(portrait ? 100.w : 120.w),
      4: FixedColumnWidth(
        _fitWidth(
          context,
          services.map(
            (s) => context.svcDepartmentName(s.currentDepartmentRequester),
          ),
          empty: portrait ? 100.w : 120.w,
          min: portrait ? 80.sp : 100.sp,
          max: 180.w,
        ),
      ),
      5: FixedColumnWidth(
        _fitWidth(
          context,
          services.map(
            (s) => context.svcPick(
              s.currentJobTitleRequester,
              s.currentJobTitleRequesterArabic,
            ),
          ),
          empty: portrait ? 120.w : 150.w,
          min: portrait ? 100.sp : 130.sp,
          max: 200.w,
        ),
      ),
      6: FixedColumnWidth(
        _fitWidth(
          context,
          services.map((s) => s.currentDurationOfServices),
          empty: portrait ? 80.w : 100.w,
          min: portrait ? 70.sp : 80.sp,
          max: 120.w,
        ),
      ),
      7: FixedColumnWidth(
        _fitWidth(
          context,
          services.map(_unit(context)),
          empty: portrait ? 80.w : 100.w,
          min: portrait ? 90.sp : 100.sp,
          max: 120.w,
        ),
      ),
      8: FixedColumnWidth(portrait ? 100.w : 120.w),
    };
  }

  String Function(ServicesHistoryModel) _requesterName(BuildContext context) =>
      (s) => context.svcPick(
            '${s.currentFirstNameRequester} ${s.currentLastNameRequester}',
            '${s.currentFirstNameRequesterArabic} ${s.currentLastNameRequesterArabic}',
          );

  String Function(ServicesHistoryModel) _unit(BuildContext context) => (s) {
        final count = num.tryParse(s.currentDurationOfServices) ?? 0;
        return context.svcDurationUnit(s.currentSelectedDurationUnit, count);
      };

  Widget _cell(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(style: _cellStyle, child: child),
    );
  }

  Widget _textCell(
    String text, {
    int maxLines = 2,
    bool isBold = false,
    Color? color,
  }) {
    return _cell(
      Text(
        FormatHelper.capitalize(text.isEmpty ? '-' : text),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: _cellStyle.copyWith(
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          color: color ?? _cellStyle.color,
        ),
      ),
    );
  }

  Widget _requesterCell(BuildContext context, ServicesHistoryModel service) {
    final gender = service.currentGenderRequester.toLowerCase();
    final avatar = gender == 'male'
        ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
        : gender == 'female'
            ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png'
            : 'assets/icons_assets/main_icons_assets/ic_user_profile.svg';
    final name = _requesterName(context)(service).trim();
    return _cell(
      Row(
        children: [
          ClipOval(
            child: CustomSvgImage.natural(
              assetPath: avatar,
              fit: BoxFit.scaleDown,
              width: 25.w,
              height: 25.h,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              FormatHelper.capitalize(name.isEmpty ? '-' : name),
              overflow: TextOverflow.ellipsis,
              style: _cellStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tappable(Widget child, ServicesHistoryModel service) {
    return GestureDetector(
      onTapDown: onRowTap != null ? (_) => HapticController.low() : null,
      onTap: onRowTap == null ? null : () => onRowTap!(service),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final headers = <String>[
      s.number,
      s.serviceName,
      s.serviceRequester,
      s.requestDate,
      s.department,
      s.jobTitle,
      s.duration,
      s.timeUnit,
      s.status,
    ];

    return AnimatedSizeWrap(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Table(
            border: TableBorder.all(
              color: AppColors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: _columnWidths(context),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: lightMode ? AppColors.text : AppColors.chatBackground,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8.r),
                  ),
                ),
                children: headers
                    .map(
                      (name) => Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.sp,
                          horizontal: 10.sp,
                        ),
                        child: Text(
                          name,
                          style: _headerStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    )
                    .toList(),
              ),
              ...List.generate(services.length, (index) {
                final service = services[index];
                final rowColor = lightMode
                    ? (index.isEven
                        ? AppColors.whiteDashboardTable
                        : AppColors.white)
                    : (index.isEven
                        ? AppColors.background
                        : AppColors.chatBackground);
                // SVC-PROV-18: the same status rule as the grid.
                final status = EmployeeServicesCubit.statusOf(service);
                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: [
                    _tappable(
                      _textCell(context.svcNumber(index + 1), maxLines: 1),
                      service,
                    ),
                    _tappable(
                      _textCell(
                        context.svcPick(
                          service.currentServiceNameEnglish,
                          service.currentServiceNameArabic,
                        ),
                      ),
                      service,
                    ),
                    _tappable(_requesterCell(context, service), service),
                    _tappable(
                      _textCell(
                        // SVC-PROV-08: date the request was made.
                        RequestDates.format(
                          RequestDates.createdAt(service),
                          locale: Localizations.localeOf(context).languageCode,
                        ),
                        maxLines: 1,
                      ),
                      service,
                    ),
                    _tappable(
                      // SVC-PROV-13: department NAME, not its id.
                      _textCell(
                        context.svcDepartmentName(
                          service.currentDepartmentRequester,
                        ),
                      ),
                      service,
                    ),
                    _tappable(
                      _textCell(
                        context.svcPick(
                          service.currentJobTitleRequester,
                          service.currentJobTitleRequesterArabic,
                        ),
                      ),
                      service,
                    ),
                    _tappable(
                      _textCell(service.currentDurationOfServices),
                      service,
                    ),
                    _tappable(_textCell(_unit(context)(service)), service),
                    _tappable(
                      _textCell(
                        context.svcStatus(status),
                        isBold: true,
                        color: statusColor(status),
                      ),
                      service,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
