/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: submitted_document_header.dart
/// Description: Submitted document header — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/submitted_document_info.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

Widget buildSubmittedDocumentHeader(
  BuildContext context, {
  required String documentName,
  required String documentDescription,
  required String documentExtension,
  required bool isMobile,
  required bool lightMode,
}) {
  String getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
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
        return 'assets/icons_assets/main_icons_assets/ic_file_excel_grid.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
    }
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CustomSvgImage(
        assetPath: getFileIcon(documentExtension),
        height: 50.sp,
        width: 45.sp,
        fit: BoxFit.fill,
        // Full-colour icons keep their colours; only the
        // single-colour video/image glyphs are tinted so they show on dark.
        color:
            (getFileIcon(documentExtension).endsWith('knowledgeVideo.svg') ||
                getFileIcon(documentExtension).endsWith('svg_image_icon.svg'))
            ? AppColors.text
            : null,
      ),
      SizedBox(width: 6.w),
      // Expanded gives the name a finite width, so a long
      // name ends in "…" instead of overflowing the card (145px overflow).
      Expanded(
        child: submittedDocumentInfo(
          context,
          documentName: documentName,
          documentDescription: documentDescription,
          isMobile: isMobile,
          lightMode: lightMode,
        ),
      ),
    ],
  );
}
