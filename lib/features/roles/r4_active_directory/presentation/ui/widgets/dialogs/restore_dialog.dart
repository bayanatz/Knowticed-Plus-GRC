/// Module: roles / r4_active_directory / presentation / ui / widgets / dialogs
///
///*************************** FILE INFO ****************************///
/// File Name: restore_dialog.dart
/// Description: Declares `RestoreDialog`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/extensions/screen_fraction_extension.dart';
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:lottie/lottie.dart';

import 'package:grc_module/features/settings/presentation/controller/employee_controller.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/di/app_controllers.dart';

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
                child: Transform.scale(
                  scale: isTablet ? (orientation ? 2 : 0.9) : 2,
                  child: Lottie.asset(
                    "assets/lottie_assets/main_lottie_assets/lot_status_warning_red.json",
                    width: 0.1.w,
                    fit: BoxFit.fitHeight,
                  ),
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
