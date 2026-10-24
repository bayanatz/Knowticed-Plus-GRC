/// Module: roles / r4_active_directory / presentation / ui / widgets / dialogs
///
///*************************** FILE INFO ****************************///
/// File Name: restore_dialog.dart
/// Description: Declares `RestoreDialog`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dialogs/dialog_lottie.dart';

import 'package:knowticed_plus/features/settings/presentation/controller/employee_controller.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

///used when User press on restore button in active_directory home page
class RestoreDialog extends StatefulWidget {
  const RestoreDialog({
    super.key,
    required this.firstOnPressed,
    required this.secondOnPressed,
  });

  final void Function() firstOnPressed;
  final void Function() secondOnPressed;

  @override
  State<RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<RestoreDialog> {
  EmployeeController addEmployeeController = AppControllers.employeeDirectory;
  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? (orientation ? 0.12.w : 0.2.w) : 0.15.w,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.02.w, vertical: 0.01.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? (orientation ? 0.03.h : 0.0.h) : 0.04.h,
                ),
                // 24/10/2026: sized in the layout (was Transform.scale 2x in
                // portrait and on phones, drawing outside the dialog).
                child: DialogLottie(
                  asset:
                      "assets/lottie_assets/main_lottie_assets/lot_status_warning_red.json",
                  size: isTablet ? (orientation ? 0.2.w : 0.09.w) : 0.2.w,
                ),
              ),
              SizedBox(height: isTablet ? (orientation ? 0.03.h : 0.02.h) : 0),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: orientation ? 0.015.h : 0.015.h,
                ),
                child: Text(
                  'Restore Backup',
                  style: StyleText.fontSize16Weight400.copyWith(
                    fontSize: isTablet ? (orientation ? 20.sp : 28.sp) : 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
              ),
              Text(
                S.of(context).chooseWhichBackupYouWantToRestore,
                textAlign: isTablet ? TextAlign.center : TextAlign.center,
                style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: isTablet ? (orientation ? 18.sp : 24.sp) : 16.sp,
                  fontWeight: FontWeight.w600,
                  height: isTablet ? 1.5 : 1.5,
                  color: Theme.of(context).colorScheme.scrim,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.025.h),
                child: Row(
                  textDirection: TextDirection
                      .ltr, // X-73: Cancel left, action right in both languages

                  // direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: customButton(
                        textColor: AppColors.text,
                        title: S.of(context).Cancel,
                        function: () {
                          Navigator.of(context).pop();
                        },
                        color: AppColors.darkGrey,
                      ),
                    ),
                    Container(width: 0.02.w),
                    Expanded(
                      child: customButton(
                        title: S.of(context).secondBackup,
                        function: widget.secondOnPressed,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(width: 0.02.w),
                    Expanded(
                      child: customButton(
                        title: S.of(context).firstBackup,
                        function: widget.firstOnPressed,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
