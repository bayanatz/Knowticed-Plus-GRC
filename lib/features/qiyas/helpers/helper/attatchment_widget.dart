import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/media_handler.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/cards/custom_title_value_widget.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class AttatchmentWidget extends StatelessWidget {
  const AttatchmentWidget(
      {this.showMinus = true,
      required this.fileName,
      required this.fileSize,
      required this.filePath,
      this.uploadDate,
      this.onTap,
      super.key});
  final bool showMinus;
  final String fileName;
  final String filePath;
  final String fileSize;
  final String? uploadDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        splashColor: Colors.transparent,
        onTapDown: (_) => HapticController.medium(),
        onTap: () {
          if (filePath.contains('http')) {
            final TextEditingController titleController =
                TextEditingController();
            CustomDialogManager.showInput(
              context: context,
              controller: titleController,
              title: 'تحميل',
              fieldLabel: 'العنوان',
              confirmText: 'نعم',
              leadingIcon: CircleAvatar(
                radius: 15.sp,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.cloud_download_outlined,
                  color: AppColors.textButton,
                  size: 20.sp,
                ),
              ),
              onConfirm: () async {
                showLoadingIndicator();
                try {
                  await MediaHandler()
                      .downloadFile(filePath, titleController.text);
                } finally {
                  hideLoadingIndicator();
                  titleController.dispose();
                }
              },
            );
          }
        },
        child: Container(
            padding: EdgeInsets.all(10.sp),
            width: isTablet ? 330.sp : double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.secondaryBlack, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  _getFileIcon(fileName),
                  width: 24.sp,
                  height: 24.sp,
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  child: Column(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              fileName,
                              style: StyleText.fontSize14Weight500,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          (showMinus)
                              ? Row(
                                  children: [
                                    SizedBox(width: 8.sp),
                                    InkWell(
                                        onTapDown:
                                            hapticDown(onTap, HapticLevel.high),
                                        onTap: onTap,
                                        splashColor: Colors.transparent,
                                        child: SvgPicture.asset(
                                          'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg',
                                          width: 12.sp,
                                          height: 12.sp,
                                        )),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fileSize,
                            style: StyleText.fontSize12Weight500
                                .copyWith(color: AppColors.secondaryBlack),
                          ),
                          if (uploadDate != null)
                            CustomTitleValueWidget(
                                title: 'تاريخ', value: uploadDate!)
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }

  String _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/ic_file_powerpoint.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
      case 'png':
      case 'jpg':
      case 'jpeg':
        return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'mkv':
      case 'webm':
        return 'assets/icons_assets/main_icons_assets/ic_file_video.svg';
      case 'xlsx':
      case 'xls':
      case 'xlsm':
      case 'csv':
        return 'assets/icons_assets/main_icons_assets/ic_file_excel.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
    }
  }
}
