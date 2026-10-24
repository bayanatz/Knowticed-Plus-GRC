/// Module: knowledge_hub/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: selected_document_widget.dart
/// Description: `selectedDocumentWidget()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

Widget selectedDocumentWidget(
  BuildContext context, {
  required String fileName,
  required String fileExtension,
  required int fileSize,
  required DateTime uploadedDate,
  required VoidCallback onRemove,
}) {
  final isMobile = ContextExtension(context).isPhone;
  final lightMode = Theme.of(context).brightness == Brightness.light;
  final String ext = fileExtension.toLowerCase().replaceAll('.', '');

  return Container(
    height: 60.h,
    width: !isMobile ? 310.w : double.infinity,
    decoration: BoxDecoration(
      color: lightMode ? AppColors.white : AppColors.background,
      borderRadius: BorderRadius.circular(8.r),
      border: lightMode
          ? Border.all(color: AppColors.borderGrey)
          : Border.all(color: AppColors.transparent),
    ),
    padding: EdgeInsetsDirectional.only(start: 12.w, end: 10.w),
    child: Row(
      children: [
        CustomSvgImage(
          assetPath: _selectedFileIcon(fileExtension),
          color: const {'png', 'jpg', 'jpeg'}.contains(ext)
              ? AppColors.text
              : null,
          height: 36,
          width: 36.w,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.sp),
              Text(
                _formatFileSize(fileSize),
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        _buildRemoveAndDate(
          context,
          uploadedDate: uploadedDate,
          onRemove: onRemove,
        ),
      ],
    ),
  );
}

String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
}

String _selectedFileIcon(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
    case 'ppt':
    case 'pptx':
      return 'assets/icons_assets/main_icons_assets/ic_file_powerpoint.svg';
    case 'doc':
    case 'docx':
      return 'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
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
      return 'assets/icons_assets/main_icons_assets/ic_file_excel_grid.svg';
    default: // png / jpg / jpeg and anything else
      return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
  }
}

/// The remove button above the "Uploaded Date: …" line.
Widget _buildRemoveAndDate(
  BuildContext context, {
  required DateTime uploadedDate,
  required VoidCallback onRemove,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      GestureDetector(
        onTapDown: hapticDown(onRemove, HapticLevel.high),
        onTap: onRemove,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
          ),
          margin: EdgeInsetsDirectional.only(top: 10.h),
          child: Icon(Icons.remove, size: 12.w, color: AppColors.white),
        ),
      ),
      Spacer(),
      Padding(
        padding: EdgeInsetsDirectional.only(bottom: 10.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${S.of(context).uploadedDate}: ',
              style: StyleText.fontSize10Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            Text(
              DateFormat('dd MMM yyyy').format(uploadedDate),
              style: StyleText.fontSize10Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
