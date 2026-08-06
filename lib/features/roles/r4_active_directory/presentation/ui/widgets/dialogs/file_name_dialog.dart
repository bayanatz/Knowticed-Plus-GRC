// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:path_provider/path_provider.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/enums/employee_data.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/active_directory_controller.dart';
import 'package:grc_module/core/theme/theme_controller.dart';
import 'package:grc_module/generated/l10n.dart';

//Created by :Fouad
// At : 18/April/2024
//last edit : 18/April/2024
class FileNameDialog extends StatefulWidget {
  FileNameDialog();

  @override
  State<FileNameDialog> createState() => _FileNameDialogState();
}

TextEditingController fileName = TextEditingController();

class _FileNameDialogState extends State<FileNameDialog> {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    fileName = TextEditingController();
    super.initState();
  }

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal:
                  isTablet ? (isPortrait ? 0.025.w : 0.015.w) : 0.035.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: .008.h, bottom: .02.h),
                child: Text(
                  S.of(context).downloadingFile,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isTablet
                          ? isPortrait
                              ? FontConstants.fontSize021.h
                              : FontConstants.fontSize026.h
                          : FontConstants.fontSize021.h,
                      fontWeight: Get.locale.toString().contains('en')
                          ? FontWeight.w600
                          : FontWeight.w500,
                      height: isTablet ? (isPortrait ? 1.8 : 1.8) : 0.002.h,
                      color: Theme.of(context).colorScheme.inverseSurface),
                ),
              ),
              SizedBox(
                width: double.infinity,


                child: CustomTextField(
                  label: S.of(context).fileName,
                  hint: S.of(context).enterFileName,
                  controller: fileName,
                  maxLines: 1,
                  required: true,
                  fillColor:
                      themeController.currentTheme == AppColors.lightTheme
                          ? AppColors.colorLightGrey
                          : AppColors.colorBlack,
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 28, bottom: isTablet ? .02.h : .008.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customButton(
                      title: S.of(context).Cancel,
                      function: () {
                        Navigator.pop(context);
                      },
                      color: AppColors.colorWhiteDark,
                    ),
                    customButton(
                      title: S.of(context).download,
                      function: () {
                        if (fileName.text.isNotEmpty) {
                          Get.find<ActiveDirectoryController>()
                              .exportToCSV(fileName.text);
                        }
                      },
                      color: AppColors.signOut,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
