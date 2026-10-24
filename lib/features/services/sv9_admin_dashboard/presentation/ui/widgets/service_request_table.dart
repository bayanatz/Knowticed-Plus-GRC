/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: service_request_table.dart
/// Purpose: The admin dashboard's request table, full width with
///          proportional columns. The department column shows only when
///          every department is listed. Row texts come from
///          ServiceRequestRow; status labels and colours from the shared
///          services helpers.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/services/helpers/services_status_colors.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/admin_cubit.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/dashboard/service_request_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ServiceRequestTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> filteredItems;

  /// The department the list is filtered to; [DashboardAdminCubit.allDepartments]
  /// adds the department column.
  final String? selectedDepartment;
  final void Function(Map<String, dynamic>)? onRowTap;
  final Map<String, String>? enToArDepartments;

  const ServiceRequestTableWidget({
    super.key,
    required this.filteredItems,
    this.onRowTap,
    this.selectedDepartment,
    this.enToArDepartments,
  });

  static const String _maleAvatar =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png';
  static const String _femaleAvatar =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png';

  bool get _showsDepartment =>
      selectedDepartment == DashboardAdminCubit.allDepartments;

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight600.copyWith(color: AppColors.white);

  TextStyle get _cellStyle =>
      StyleText.fontSize13Weight500.copyWith(color: AppColors.blackButton);

  /// Flex widths, in column order.
  List<double> get _flexes => _showsDepartment
      ? const [0.5, 0.9, 1.4, 1.5, 1.5, 1.5, 1.2, 0.8, 1.3]
      : const [0.5, 1.8, 1.5, 1.5, 1.0, 1.0, 0.8, 1.5];

  List<String> _headers(BuildContext context) {
    final s = S.of(context);
    return [
      s.number,
      if (_showsDepartment) s.Department,
      s.ServiceName,
      s.ServiceRequestor,
      s.dbRequesterDepartment,
      s.jobTitle,
      s.RequestedDate,
      s.Status,
      s.ServiceProvider,
    ];
  }

  Widget _cell(Widget child) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        child: DefaultTextStyle.merge(style: _cellStyle, child: child),
      );

  Widget _textCell(
    String text, {
    int maxLines = 2,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return _cell(
      Text(
        FormatHelper.capitalize(text.isEmpty ? '-' : text),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: _cellStyle.copyWith(color: color, fontWeight: fontWeight),
      ),
    );
  }

  /// Avatar then name, in reading order.
  Widget _personCell(String name, bool isMale) {
    return _cell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: CustomSvgImage.natural(
              assetPath: isMale ? _maleAvatar : _femaleAvatar,
              width: 22.sp,
              height: 22.sp,
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              FormatHelper.capitalize(name),
              overflow: TextOverflow.ellipsis,
              style: _cellStyle,
            ),
          ),
        ],
      ),
    );
  }

  /// Rows only look tappable when tapping does something.
  Widget _tappable(Widget child, Map<String, dynamic> item) {
    final onTap = onRowTap;
    if (onTap == null) return child;
    void handleTap() => onTap(item);
    return InkWell(
      onTapDown: hapticDown(handleTap, HapticLevel.low),
      onTap: handleTap,
      child: child,
    );
  }

  TableRow _row(BuildContext context, int index, bool lightMode) {
    final item = filteredItems[index];
    final row = ServiceRequestRow(
      item,
      index,
      enToArDepartments: enToArDepartments,
    );
    final department = row.department(context);
    final cells = <Widget>[
      _textCell(row.number(context), maxLines: 1),
      if (_showsDepartment) _textCell(department),
      _textCell(row.serviceName(context)),
      _personCell(row.requesterName(context), row.isRequesterMale),
      _textCell(department),
      _textCell(row.jobTitle(context)),
      _textCell(row.requestDate(context), maxLines: 1),
      _textCell(
        row.status.isEmpty ? '-' : context.svcStatus(row.status),
        color: ServicesStatusColors.of(row.status),
        fontWeight: FontWeight.w600,
      ),
      _personCell(row.providerName(context), row.isProviderMale),
    ];
    final background = lightMode
        ? (index.isEven ? AppColors.tableLightBackground : AppColors.white)
        : (index.isEven ? AppColors.tableDarkBackground : AppColors.black);
    return TableRow(
      decoration: BoxDecoration(color: background),
      children: [for (final cell in cells) _tappable(cell, item)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final flexes = _flexes;

    return AnimatedSizeWrap(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.sp),
              child: Table(
                border: TableBorder.all(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  for (var i = 0; i < flexes.length; i++)
                    i: FlexColumnWidth(flexes[i]),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: lightMode
                          ? AppColors.black
                          : AppColors.black.withValues(alpha: 0.45),
                    ),
                    children: [
                      for (final name in _headers(context))
                        Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Text(
                            name,
                            style: _headerStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  for (var i = 0; i < filteredItems.length; i++)
                    _row(context, i, lightMode),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
