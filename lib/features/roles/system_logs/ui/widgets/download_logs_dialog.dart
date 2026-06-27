import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/roles/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/column_request_data.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/roles/system_logs/controller/system_logs_controller.dart';
import 'package:demo_app/features/roles/system_logs/data/models/system_logs_model.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';

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
                  "Downloading File".tr,
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
                        child: MainCustomIconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          buttonText: "Cancel".tr,
                       
                          buttonStyle: ElevatedButton.styleFrom(
                            minimumSize: isTablet
                                ? Size(0.1.w, 0.05.h)
                                : Size(0.076.w, 0.035.h),
                            backgroundColor: AppColors.colorWhiteDark,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            )),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: isTablet
                            ? (isPortrait ? 0.045.h : 0.05.h)
                            : 0.035.h,
                        child: MainCustomIconButton(
                          onPressed: () {
                            if (fileName.text.isNotEmpty) {
                              Get.find<SystemLogsController>()
                                  .exportSystemLogs(fileName.text);
                            }
                          },
                          buttonText: "Download".tr,
                         
                          buttonStyle: ElevatedButton.styleFrom(
                            minimumSize: isTablet
                                ? Size(0.1.w, 0.05.h)
                                : Size(0.076.w, 0.035.h),
                            backgroundColor: AppColors.signOut,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            )),
                          ),
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
