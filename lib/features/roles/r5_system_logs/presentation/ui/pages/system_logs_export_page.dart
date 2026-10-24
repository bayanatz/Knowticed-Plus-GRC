/// Module: roles / r5_system_logs / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: system_logs_export_page.dart
/// Description: The tablet System Logs Export — his Figma two-page export
///              (3944:60975 Export Details → 3944:61163 Employees, X-112)
///              instead of the old file-name-only dialog (owner 21/10/2026:
///              "the export is not like this way in Figma"). The form is the
///              same `LogsMobileExportDetailsPage` the phone tab shows, under
///              the iPad crumb "System Logs › Export Details" (X-65: no back
///              arrow; the first crumb goes back).
/// Author: Moataz Handousa
/// Created at: 21/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/ui/pages/logs_mobile_export_details_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class SystemLogsExportPage extends StatelessWidget {
  const SystemLogsExportPage({super.key});

  /// Pushes the page on the Roles module's own navigator.
  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SystemLogsExportPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final TextStyle crumb =
        StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryText);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsetsDirectional.all(15.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTapDown: (_) => HapticController.low(),
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(s.systemsLogs, style: crumb),
                ),
                Text('  ›  ', style: crumb),
                Text(
                  s.exportDetails,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.text),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: ConstrainedBox(
                  // The Figma form is one column of fields; on a wide iPad it
                  // keeps the export dialog width (X-20 wide 820) instead of
                  // stretching each field across the screen.
                  constraints: BoxConstraints(maxWidth: 820.w),
                  child: const LogsMobileExportDetailsPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
