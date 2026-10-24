/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: table_dashboard.dart
/// Purpose: The department dashboard's request table (tablet), newest
///          request first, built on the shared DefaultDataTable so it reads
///          like the other tables. Row texts come from ServiceRequestRow.
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
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/table/default_data_table.dart';
import 'package:knowticed_plus/features/services/helpers/services_status_colors.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/dashboard/service_request_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ServicesDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> displayedItems;
  final Map<String, String> enToArDepartments;

  const ServicesDataTable({
    super.key,
    required this.displayedItems,
    required this.enToArDepartments,
  });

  static const String _maleAvatar =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png';
  static const String _femaleAvatar =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png';

  /// A heading centred over its column (direction-aware).
  DataColumn _headerColumn(String text) {
    return DataColumn(
      headingRowAlignment: MainAxisAlignment.center,
      label: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        child: Text(
          text,
          style: StyleText.fontSize14Weight600.copyWith(color: AppColors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// A value cell; the height is pinned so a row never grows.
  DataCell _cell(String text, {Color? color}) {
    return DataCell(
      SizedBox(
        height: 38.h,
        child: Align(
          child: Text(
            text.isEmpty ? '-' : FormatHelper.capitalize(text),
            style: StyleText.fontSize12Weight600.copyWith(
              color: color ?? AppColors.text,
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  /// A value cell with the person's avatar.
  DataCell _personCell(String name, bool isMale) {
    return DataCell(
      SizedBox(
        height: 38.h,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: CustomSvgImage.natural(
                assetPath: isMale ? _maleAvatar : _femaleAvatar,
                width: 25.sp,
                height: 25.sp,
              ),
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                name.isEmpty ? '-' : FormatHelper.capitalize(name),
                style: StyleText.fontSize12Weight600.copyWith(
                  color: AppColors.text,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _row(BuildContext context, ServiceRequestRow row, Color color) {
    return DataRow(
      color: WidgetStatePropertyAll(color),
      cells: [
        _cell(row.number(context)),
        _cell(row.serviceName(context)),
        _personCell(row.requesterName(context), row.isRequesterMale),
        _cell(row.department(context)),
        _cell(row.jobTitle(context)),
        _cell(row.requestDate(context)),
        _cell(
          row.statusLabel(context),
          color: ServicesStatusColors.of(row.status),
        ),
        _personCell(row.providerName(context), row.isProviderMale),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final evenColor =
        lightMode ? AppColors.evenRowColor : AppColors.oddRowColor;
    final oddColor = lightMode ? AppColors.white : AppColors.black;
    // Newest request first; rows without a date last (bug report p9).
    final items = List<Map<String, dynamic>>.from(displayedItems)
      ..sort(ServiceRequestRow.compareNewestFirst);

    return AnimatedSizeWrap(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp),
        child: DefaultDataTable(
          // The columns are narrower than the content area; fill it.
          fillWidth: true,
          columns: [
            _headerColumn(s.NO),
            _headerColumn(s.ServiceName),
            _headerColumn(s.ServiceRequestor),
            _headerColumn(s.department),
            _headerColumn(s.jobTitle),
            _headerColumn(s.RequestedDate),
            _headerColumn(s.Status),
            _headerColumn(s.ServiceProvider),
          ],
          rows: [
            for (var i = 0; i < items.length; i++)
              _row(
                context,
                ServiceRequestRow(
                  items[i],
                  i,
                  enToArDepartments: enToArDepartments,
                ),
                i.isEven ? evenColor : oddColor,
              ),
          ],
        ),
      ),
    );
  }
}
