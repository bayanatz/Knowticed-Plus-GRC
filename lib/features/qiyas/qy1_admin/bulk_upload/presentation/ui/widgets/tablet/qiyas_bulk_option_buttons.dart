/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_bulk_option_buttons.dart
/// Purpose: Provides ui action buttons for managing rows in Qiyas bulk vision upload.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget renders three buttons allowing users to:
///              - Add a new row to the bulk upload table.
///              - Duplicate a selected row.
///              - Remove selected rows.
///              Buttons are styled and adapt to screen orientation for responsiveness.
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_black_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_rows_options_controller.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/core/enums/csv_status.dart';

import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_visions_controller.dart';

class QiyasBulkOptionButtons extends StatelessWidget {
  const QiyasBulkOptionButtons(
      {super.key,
      required this.controller,
      required this.status,
      required this.orientation});
  final QiyasBulkVisionsController controller;
  final CsvStatus status;
  final bool orientation;

  // [orientation] is kept for the callers' signature; the black buttons size
  // themselves through ButtonSizing like every other X-06 row action.
  @override
  Widget build(BuildContext context) {
    final S l10n = S.of(context);
    return Row(
      children: [
        customBlackButton(
          title: l10n.row,
          image: 'assets/icons_assets/main_icons_assets/ic_action_plus.svg',
          function: () => controller.addNewRow(status),
        ),
        SizedBox(width: 8.sp),
        customBlackButton(
          title: l10n.duplicate,
          function: () => controller.duplicateRow(status),
        ),
        SizedBox(width: 8.sp),
        customBlackButton(
          title: l10n.removeSelection,
          image:
              'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg',
          function: () => controller.removeSelectedRows(status),
        ),
      ],
    );
  }
}
