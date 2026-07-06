import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drop_down_menu.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/image_paths.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/delete_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';

/// Date Created :23/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/November/2023 By Bassem
/// Objectives:  this file represents the custom container for showing three differen types of attachments whether its image, docx, or pdf

class AttachmentContainer extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final BuildContext context;
  final void Function() onTapDelete;
  final void Function() onTapDownload;

  const AttachmentContainer({
    super.key,
    required this.fileName,
    required this.context,
    required this.fileSize,
    required this.onTapDelete,
    required this.onTapDownload,
  });

  Widget _getFileIcon(isTablet, isPortrait) {
    String fileExtension = fileName.split('.').last.toLowerCase();
    if (fileName.contains('.pdf')) {
      return SvgPicture.asset(
        ImagePaths.getImagePath(context, 'pdfImage'),
        fit: BoxFit.fill,
      );
    } else if (fileName.contains('.docx')) {
      return SvgPicture.asset(
        ImagePaths.getImagePath(context, 'docxImage'),
        fit: BoxFit.fill,
      );
    } else {
      return SvgPicture.asset(
        ImagePaths.getImagePath(context, 'ImagePlaceHolder'),
        fit: BoxFit.fill,
      );;
    }
    /*if (fileExtension == 'pdf') {
        return Icon(Icons.picture_as_pdf,
            size: isTablet ? 0.05.h : 0.03.h, color: Colors.red);
      } else if (fileExtension == 'docx') {
        return Icon(Icons.description,
            size: isTablet ? 0.05.h : 0.03.h, color: Colors.blue);
      } else {
        return Icon(Icons.image,
            size: isTablet ? 0.05.h : 0.03.h, color: Colors.green);
      }*/
  }

  @override
  Widget build(BuildContext context) {
    Get.put(TaskDetailsController());
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 0 : 0.015.h),
      child: Container(
        width: isTablet ? (isPortrait ? 0.39.w : 0.3.h) :  60.h,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: themeController.currentTheme == AppColors.lightTheme
                  ? AppColors.colorBlack
                  : AppColors.colorWhiteDark,
              width: 1.0,
            )),
        padding: isTablet
            ? (isPortrait
                ? EdgeInsets.only(
                    right: 0.01.w, left: 0.01.w, top: 0.01.h, bottom: 0.005.h)
                : EdgeInsets.symmetric(horizontal: 0.015.h, vertical: 0.01.h))
            : EdgeInsets.symmetric(horizontal: 0.015.w, vertical: 0.01.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getFileIcon(isTablet, isPortrait),
            SizedBox(
              width: isTablet ? (isPortrait ? 0.02.w : 0.02.h) : 0.02.w,
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: isTablet
                            ? (isPortrait
                            ? FontConstants.fontSize015.h
                            : FontConstants.fontSize018.h)
                            : FontConstants.fontSize016.h,
                        color: themeController.currentTheme ==
                            AppColors.lightTheme
                            ? AppColors.colorBlack
                            : AppColors.colorWhiteDark,
                        fontWeight: FontWeight.w600,
                        height: isTablet ? 1.6 : 1.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  GetBuilder<TaskDetailsController>(
                    builder: (controller) {
                      return Padding(
                        padding: EdgeInsets.only(
                            top: isTablet ? (isPortrait ? 0 : 0.015.h) : 0.005.h),
                        child: FutureBuilder(
                            future: controller.getFileSize(fileSize),
                            builder: (context, AsyncSnapshot<String> snapshot) {
                              String sizeText = "MB";
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                sizeText = "loading";
                              } else if (snapshot.hasError) {
                                sizeText = "error";
                              } else if (snapshot.hasData) {
                                sizeText = snapshot.data!;
                              }
                              return Text(
                                sizeText,
                                style: AppFontStyle.cairoRegularStyle.copyWith(
                                    fontSize: isTablet
                                        ? (isPortrait
                                        ? FontConstants.fontSize014.h
                                        : FontConstants.fontSize016.h)
                                        : FontConstants.fontSize014.h,
                                    color: themeController.currentTheme ==
                                        AppColors.lightTheme
                                        ? AppColors.colorDarkGrey
                                        : AppColors.colorGreydark,
                                    fontWeight: FontWeight.w400,
                                    height: isPortrait ? 2 : 2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                      );
                    },
                  ),
                ],
              ),
            ),
            Spacer(),
        // Action Buttons Section
             Column(
          children: [
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return DeleteDialog(
                      deleteTitleText: "Delete Attachment",
                      deleteText:
                      "Are You Sure You Want To Delete This Attachment?",
                      yesOnPressed: () async {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const SuccessDialog(
                              title: "Successful",
                              subtitle:
                              "Attachment Has Been Deleted Successfully",
                              lottieAsset: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                            );
                          },
                        );
                        onTapDelete();
                      },
                    );
                  },
                );
              },
              child: SvgPicture.asset(
                ImagePaths.getImagePath(context, 'delete'),
                width: 0.02.h,
                height: 0.02.h,
                color: AppColors.delete,
              )
            ),
            SizedBox(height: 0.01.h),
            InkWell(
              onTap: onTapDownload,
              child: SvgPicture.asset(
                ImagePaths.getImagePath(context, 'Download'),
                width: 0.02.h,
                height: 0.02.h,
                color: themeController.currentTheme ==
                    AppColors.lightTheme
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
              ),
            ),
          ],
        ),


          ],
        ),
      ),
    );
  }
}
