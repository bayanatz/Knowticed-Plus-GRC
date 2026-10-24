/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: table_rows_load_error.dart
/// Description: Declares `TableRowsLoadError`.
/// Author: Amr Mesbah
/// Created at: 23/10/2026
///
/// Shown in place of a table's grid when its rows could not be read
/// (DB-TABLE-01). An empty grid there would say the table has no data, which
/// is not true and invites an edit that saves over the stored rows.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/create_table_strings.dart';

class TableRowsLoadError extends StatelessWidget {
  const TableRowsLoadError({super.key, required this.onRetry});

  /// Reads the rows again.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              strings.rowsLoadFailed,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.red,
              ),
            ),
            SizedBox(height: 12.h),
            customButton(
              title: strings.retry,
              function: onRetry,
              wrapContent: true,
              color: AppColors.primary,
              textColor: AppColors.textButton,
            ),
          ],
        ),
      ),
    );
  }
}
