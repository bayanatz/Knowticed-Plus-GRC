import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';


import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:grc_module/features/roles/r5_system_logs/data/models/system_logs_model.dart';

import '../../../../../home/main_controller/core_widgets/main_widget/column_request_data.dart';
import 'package:grc_module/generated/l10n.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';

//Created by :Fouad
// At : 18/April/2024
//last edit : 18/April/2024
class SystemLogsDownloadDialog extends StatefulWidget {
  SystemLogsDownloadDialog();

  @override
  State<SystemLogsDownloadDialog> createState() =>
      _SystemLogsDownloadDialogState();
}

class _SystemLogsDownloadDialogState extends State<SystemLogsDownloadDialog> {
  TextEditingController fileName = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet
              ? isPortrait
                  ? 0.18.w
                  : 0.3.w
              : 0.1.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.025.w, vertical: 0.015.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: .02.h),
                child: Text(
                  S.of(context).downloadingFile,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isTablet
                          ? isPortrait
                              ? FontConstants.fontSize021.h
                              : FontConstants.fontSize026.h
                          : FontConstants.fontSize018.h,
                      fontWeight: Get.locale.toString().contains('en')
                          ? FontWeight.w600
                          : FontWeight.w500,
                      height: isTablet ? (isPortrait ? 1.8 : 1.8) : 0.002.h,
                      color: Theme.of(context).colorScheme.inverseSurface),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ColumnRequestData(
                    title: "File Name",
                    fillColor:
                        themeController.currentTheme == AppColors.lightTheme
                            ? AppColors.colorLightGrey
                            : AppColors.colorBlack,
                    isTextField: true,
                    hint: "Enter File Name",
                    
                    maxlines: 1,
                    textController: fileName,
                    controllerfinishState: (value) {},
                    controllerState: (value) {
                      fileName.text = value!;
                    },
                    isOptional: false,
                    isExpanded: true),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: isTablet
                        ? isPortrait
                            ? 0.015.h
                            : 0.015.h
                        : 0.015.h),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: isTablet
                            ? (isPortrait ? 0.045.h : 0.05.h)
                            : 0.035.h,
                        child: customButton(
                          function: () {
                            Navigator.pop(context);
                          },
                          title: S.of(context).Cancel,
                          color: AppColors.colorWhiteDark,
                        ),
                      ),
                      SizedBox(
                        height: isTablet
                            ? (isPortrait ? 0.045.h : 0.05.h)
                            : 0.035.h,
                        child: customButton(
                          function: () {
                            if (fileName.text.isNotEmpty) {
                              Get.find<SystemLogsController>()
                                  .exportSystemLogs(fileName.text);
                            }
                          },
                          title: S.of(context).download,
                          color: AppColors.signOut,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
