import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:lottie/lottie.dart';

import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/33-custom_haptic.dart';
import 'package:grc_module/generated/l10n.dart';

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
  EmployeeController addEmployeeController = Get.find();
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? (orientation ? 0.12.w : 0.2.w) : 0.15.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
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
                    vertical:
                        isTablet ? (orientation ? 0.03.h : 0.0.h) : 0.04.h),
                child: Transform.scale(
                  scale: isTablet ? (orientation ? 2 : 0.9) : 2,
                  child: Lottie.asset(
                    "assets/lottie_assets/main_lottie_assets/lottie_attension.json",
                    width: 0.1.w,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              SizedBox(
                height: isTablet ? (orientation ? 0.03.h : 0.02.h) : 0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: orientation ? 0.015.h : 0.015.h),
                child: Text(
                  'Restore Backup',
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isTablet
                          ? (orientation
                              ? FontConstants.fontSize025.h
                              : FontConstants.fontSize035.h)
                          : FontConstants.fontSize022.h,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.inverseSurface),
                ),
              ),
              Text(
                S.of(context).chooseWhichBackupYouWantToRestore,
                textAlign: isTablet ? TextAlign.center : TextAlign.center,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? (orientation
                            ? FontConstants.fontSize022.h
                            : FontConstants.fontSize030.h)
                        : FontConstants.fontSize020.h,
                    fontWeight: FontWeight.w600,
                    height: isTablet ? 1.5 : 1.5,
                    color: Theme.of(context).colorScheme.scrim),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.025.h),
                child: Row(
                  // direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: customButton(
                        title: S.of(context).Cancel,
                        function: () {
                          Navigator.of(context).pop();
                        },
                        color: AppColors.colorGreydark,
                      ),
                    ),
                    Container(width: 0.02.w),
                    Expanded(
                      child: customButton(
                        title: S.of(context).secondBackup,
                        function: widget.secondOnPressed,
                        color: AppColors.bubbleColor,
                      ),
                    ),
                    Container(width: 0.02.w),
                    Expanded(
                      child: customButton(
                        title: S.of(context).firstBackup,
                        function: widget.firstOnPressed,
                        color: AppColors.bubbleColor,
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
