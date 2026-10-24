/// Module: services / sv1_home_page_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: table_widget.dart
/// Purpose: Table (list) view of services, used as an alternate to the grid
///          view on the home services page.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: ServicesHistoryModel, ServiceDisplayStatus, FormatHelper
/// Revision History:
///   - Initial version.
///   - 22/10/2026 (Amr Mesbah): no language flag is passed in; the column
///     order and the provider name come from the reader's locale through
///     the services text helpers, and the two copies of every row are one
///     column list (rule "All text in the translation files").
///   - 02/07/2026 (Knowticed Team): Reformatted import block (was
///     inconsistently indented/interleaved); grouped dart/flutter,
///     third-party, then project imports.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/domain/enums/service_display_status.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/pages/create_new_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/pages/details_services_toggle.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/features/services/domain/enums/service_duration_unit.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';

class ServiceTableWidget extends StatelessWidget {
  final List<ServicesHistoryModel> filteredModel;
  final Map<String, dynamic> selectedProviders;

  const ServiceTableWidget({
    super.key,
    required this.filteredModel,
    required this.selectedProviders,
  });

  // ---------- helpers ----------
  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight600.copyWith(color: AppColors.white);

  TextStyle _cellStyle(BuildContext context) => StyleText.fontSize14Weight400
      .copyWith(fontSize: 13.sp, color: AppColors.text);

  // W14: localized digits via intl's NumberFormat instead of a custom map.
  NumberFormat get _numberFormat => NumberFormat('0', 'en');

  String _fmtInt(int n) => _numberFormat.format(n);

  // W15: status is a typed enum; W13: text comes from the .arb localization.
  //
  // ✅ FIX 26/8/2026 — this used to be
  //
  //     ServiceDisplayStatus.fromRaw(
  //       item.currentStatus.isEmpty ? item.currentState : item.currentStatus)
  //
  // which reaches for `state` ONLY when `status` happens to be empty. A
  // draft's status is never empty — it holds the availability the service
  // will have once published, 'active' by default — so `state` was never
  // consulted and every draft row was labelled Active.
  //
  // `ServiceDisplayStatus.of` reads both, with draft winning.
  ServiceDisplayStatus _statusOf(ServicesHistoryModel item) =>
      ServiceDisplayStatus.of(
        state: item.currentState,
        status: item.currentStatus,
      );

  String _statusText(BuildContext context, ServiceDisplayStatus status) {
    final l = S.of(context);
    switch (status) {
      case ServiceDisplayStatus.active:
        return l.active;
      case ServiceDisplayStatus.inactive:
        return l.inactive;
      case ServiceDisplayStatus.draft:
        return l.draft;
    }
  }

  Color _statusColor(BuildContext context, ServiceDisplayStatus status) {
    switch (status) {
      case ServiceDisplayStatus.active:
        return AppColors.lightGreen;
      case ServiceDisplayStatus.inactive:
        return AppColors.red;
      case ServiceDisplayStatus.draft:
        return AppColors.text;
    }
  }

  /// H13: the unit is read by ServiceDurationUnit and named in the
  /// reader's language (plural form, as a column value).
  String _localizedUnit(BuildContext context, String? key) {
    if (ServiceDurationUnit.parse(key) == null) {
      return FormatHelper.capitalize(key ?? '');
    }
    return context.svcDurationUnit(key, 3);
  }

  String _yesNo(BuildContext context, bool yes) {
    final l = S.of(context);
    return yes ? l.yes : l.no;
  }

  String _formatStartDate(BuildContext context, dynamic timestampOrDateTime) {
    if (timestampOrDateTime == null) return '-';
    DateTime date;
    if (timestampOrDateTime is DateTime) {
      date = timestampOrDateTime;
    } else if (timestampOrDateTime is Timestamp) {
      date = timestampOrDateTime.toDate();
    } else if (timestampOrDateTime is int) {
      date = DateTime.fromMillisecondsSinceEpoch(timestampOrDateTime);
    } else {
      return '-';
    }
    // The reader's locale (Arabic renders Eastern-Arabic digits).
    return DateFormat(
      'dd MMM yyyy',
      Localizations.localeOf(context).languageCode,
    ).format(date);
  }

  String _fmtDuration(BuildContext context, ServicesHistoryModel m) {
    final value = m.currentDurationOfServices.trim();
    if (value.isEmpty) return '-';
    final parsed = num.tryParse(value);
    return parsed != null ? _numberFormat.format(parsed) : value;
  }

  // Basic padded cell builder
  Widget _cell(
    BuildContext context,
    Widget child, {
    EdgeInsets? padding,
    Alignment? align,
  }) {
    return Container(
      // alignment: align ?? Alignment.centerLeft,
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(style: _cellStyle(context), child: child),
    );
  }

  // Text cell with ellipsis and optional maxLines
  Widget _textCell(
    BuildContext context,
    String text, {
    int maxLines = 2,
    TextAlign textAlign = TextAlign.start,
  }) {
    return _cell(
      context,
      Text(
        text.isEmpty ? '-' : text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      ),
    );
  }

  // Wrap a row child to make the whole row tappable
  Widget _rowTapWrapper(
    BuildContext context,
    Widget child,
    VoidCallback onTap,
  ) {
    // Each Table child is wrapped with InkWell so tapping anywhere in the row works.
    return InkWell(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: child,
    );
  }

  // Provider name + avatar cell
  Widget _providerCell(BuildContext context, Map<String, dynamic>? selected) {
    if (selected == null) {
      return _cell(
        context,
        Text(
          '—',
          style: _cellStyle(context)
              .copyWith(fontWeight: FontWeight.w600, color: AppColors.red),
        ),
        align: Alignment.center,
      );
    }
    final firstAr =
        (selected['firstNameInArabic'] ?? selected['firstNameArabic'] ?? '')
            .toString()
            .trim();
    final lastAr =
        (selected['lastNameInArabic'] ?? selected['lastNameArabic'] ?? '')
            .toString()
            .trim();
    final firstEn = (selected['firstName'] ?? '').toString().trim();
    final lastEn = (selected['lastName'] ?? '').toString().trim();

    // The reader's version of the name (svcPick), else the other one.
    var name = context.svcPick(
      FormatHelper.capitalize('$firstEn $lastEn'.trim()),
      '$firstAr $lastAr'.trim(),
    );
    if (name.isEmpty) {
      final email = (selected['email']?.toString() ?? '');
      name = email.contains('@') ? email.split('@').first : '-';
    }
    final isMale =
        (selected['gender']?.toString().toLowerCase() ?? '') == 'male';

    // Avatar first, then the name, in the reading direction.
    return _cell(
      context,
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
              name,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  // New method for department cell
  Widget _departmentCell(BuildContext context, ServicesHistoryModel m) {
    if (m.currentSelectDepartment.isEmpty) {
      return _textCell(context, '-');
    }

    final departments = m.currentSelectDepartment;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show max 2 departments per row, then scroll horizontally
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          direction: Axis.horizontal,
          children: departments.map((dept) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkGrey : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                dept,
                style: _cellStyle(context)
                    .copyWith(fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Replace the existing width calculation methods with these improved versions:

  double calculateWidthOfServicesNameEn(
    BuildContext context,
    List<ServicesHistoryModel> visionsList,
  ) {
    double maxLength = 0;
    for (var vision in visionsList) {
      final name = vision.currentServiceNameEnglish;
      if (name.isNotEmpty) {
        maxLength = math.max(maxLength, name.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 0.sp, 300.w);
    double minWidth = context.isPortrait ? 120.sp : 140.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double calculateWidthOfServicesNameAR(
    BuildContext context,
    List<ServicesHistoryModel> visionsList,
  ) {
    double maxLength = 0;
    for (var vision in visionsList) {
      final name = vision.currentServiceNameArabic;
      if (name.isNotEmpty) {
        maxLength = math.max(maxLength, name.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 0.sp, 300.w);
    double minWidth = context.isPortrait ? 120.sp : 140.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double calculateWidthOfServicesDesEN(
    BuildContext context,
    List<ServicesHistoryModel> visionsList,
  ) {
    double maxLength = 0;
    for (var vision in visionsList) {
      final desc = vision.currentServiceDescriptionEnglish;
      if (desc.isNotEmpty) {
        maxLength = math.max(maxLength, desc.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 150.w : 180.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 0.sp, 300.w);
    double minWidth = context.isPortrait ? 150.sp : 180.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double calculateWidthOfServicesDesAR(
    BuildContext context,
    List<ServicesHistoryModel> visionsList,
  ) {
    double maxLength = 0;
    for (var vision in visionsList) {
      final desc = vision.currentServiceDescriptionArabic;
      if (desc.isNotEmpty) {
        maxLength = math.max(maxLength, desc.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 150.w : 180.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 0.sp, 300.w);
    double minWidth = context.isPortrait ? 150.sp : 180.sp;
    return math.max(calculatedWidth, minWidth);
  }

  /// One table column: its header, width and the cell of each row.
  _Column _col(
    String header,
    double width,
    Widget Function(int index, ServicesHistoryModel m) cell,
  ) =>
      _Column(header, width, cell);

  Widget _bilingualCell(
    BuildContext context,
    String text,
    ui.TextDirection dir,
  ) {
    return _cell(
      context,
      Directionality(
        textDirection: dir,
        child: Text(
          text.isEmpty ? '-' : text,
          textAlign: TextAlign.start,
          style: _cellStyle(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final l = S.of(context);

    final nameEn = _col(
      l.svcServiceNameEnglishColumn,
      calculateWidthOfServicesNameEn(context, filteredModel),
      (_, m) => _bilingualCell(
        context,
        m.currentServiceNameEnglish,
        ui.TextDirection.ltr,
      ),
    );
    final nameAr = _col(
      l.svcServiceNameArabicColumn,
      calculateWidthOfServicesNameAR(context, filteredModel),
      (_, m) => _bilingualCell(
        context,
        m.currentServiceNameArabic,
        ui.TextDirection.rtl,
      ),
    );
    final descEn = _col(
      l.svcServiceDescriptionEnglishColumn,
      calculateWidthOfServicesDesEN(context, filteredModel),
      (_, m) => _bilingualCell(
        context,
        m.currentServiceDescriptionEnglish,
        ui.TextDirection.ltr,
      ),
    );
    final descAr = _col(
      l.svcServiceDescriptionArabicColumn,
      calculateWidthOfServicesDesAR(context, filteredModel),
      (_, m) => _bilingualCell(
        context,
        m.currentServiceDescriptionArabic,
        ui.TextDirection.rtl,
      ),
    );

    // The reader's language comes first.
    final readerFirst = context.svcIsArabic;

    final columns = <_Column>[
      _col(
        l.num,
        60.sp,
        (i, _) => _textCell(context, _fmtInt(i + 1), maxLines: 1),
      ),
      ...(readerFirst
          ? [nameAr, nameEn, descAr, descEn]
          : [nameEn, nameAr, descEn, descAr]),
      _col(
        l.status,
        80.sp,
        (_, m) => _cell(
          context,
          Text(
            _statusText(context, _statusOf(m)),
            style: _cellStyle(context).copyWith(
              fontWeight: FontWeight.w600,
              color: _statusColor(context, _statusOf(m)),
            ),
          ),
        ),
      ),
      _col(
        l.duration,
        90.sp,
        (_, m) => _textCell(context, _fmtDuration(context, m), maxLines: 1),
      ),
      _col(
        l.timeUnit,
        90.sp,
        (_, m) => _textCell(
          context,
          _localizedUnit(context, m.currentSelectedDurationUnit),
          maxLines: 1,
        ),
      ),
      _col(
        l.limitServiceAvailability,
        180.sp,
        (_, m) => _textCell(
          context,
          _yesNo(context, m.currentSelectDepartment.isNotEmpty),
        ),
      ),
      _col(
        l.svcSelectedDepartments,
        220.sp,
        (_, m) => _departmentCell(context, m),
      ),
      _col(
        l.requiresApproval,
        180.sp,
        (_, m) => _textCell(
          context,
          _yesNo(context, m.currentApprovalCycle.isNotEmpty),
        ),
      ),
      _col(
        l.creationDate,
        120.sp,
        (_, m) => _textCell(
          context,
          _formatStartDate(context, m.getTimestampAt(0)),
          maxLines: 1,
        ),
      ),
      _col(
        l.serviceProvider,
        180.sp,
        (_, m) => _providerCell(context, selectedProviders[m.currentId]),
      ),
    ];

    return AnimatedSizeWrap(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.sp),
          child: Table(
            border: TableBorder.all(
              color: AppColors.transparent,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              for (var i = 0; i < columns.length; i++)
                i: FixedColumnWidth(columns[i].width),
            },
            children: [
              // ---------- Header Row ----------
              TableRow(
                decoration: BoxDecoration(
                  color: isLight ? AppColors.black : AppColors.border,
                ),
                children: columns
                    .map(
                      (c) => Padding(
                        padding: EdgeInsets.all(10.sp),
                        child: Text(
                          c.header,
                          style: _headerStyle,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    )
                    .toList(),
              ),

              // ---------- Data Rows ----------
              ...List.generate(filteredModel.length, (index) {
                final m = filteredModel[index];
                final isEven = index.isEven;
                final rowColor = isLight
                    ? (isEven ? AppColors.oddRowColor : AppColors.white)
                    : (isEven ? AppColors.darkDashboardTable : AppColors.black);

                // A draft resumes the wizard; a service opens its details —
                // the same as ServiceGridCard, so both views behave alike.
                void goToService() async {
                  final bool isDraft =
                      _statusOf(m) == ServiceDisplayStatus.draft;

                  final cubit = ServicesManagerCubit.get(context);

                  if (isDraft) {
                    final draftWithPage = await cubit.getDraftWithPage(
                      m.currentId,
                    );
                    if (!context.mounted) return;

                    navigateTo(
                      context,
                      draftWithPage != null
                          ? CreateNewServicesLayout(
                              editingModel: draftWithPage.model,
                              docId: draftWithPage.draftId,
                            )
                          : CreateNewServicesLayout(editingModel: m),
                    );
                    return;
                  }

                  final serviceId = m.currentId;
                  if (serviceId.isEmpty) return;

                  // SVC-HOME-24: the details page loads its own data, so
                  // nothing is fetched (and awaited) here before navigating.
                  navigateTo(
                    context,
                    ToggleDetailsServicesLayout(createServicesModel: m),
                  );
                }

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: columns
                      .map(
                        (c) => _rowTapWrapper(
                          context,
                          c.cell(index, m),
                          goToService,
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// One column of [ServiceTableWidget].
class _Column {
  final String header;
  final double width;
  final Widget Function(int index, ServicesHistoryModel m) cell;

  const _Column(this.header, this.width, this.cell);
}
