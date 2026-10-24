/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/build_document_header.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_document_header.dart
/// Description: Contains the document header with dynamic file icon
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget buildDocumentHeader(
  BuildContext context, {
  required String documentName,
  required String documentType,
  required String owningDepartment,
  required String documentExtension,
}) {
  ContextExtension(context).isPhone;

  return Row(
    children: [
      Center(
        child: CustomSvgImage(
          assetPath: _getFileIcon(documentExtension),
          width: 70.w,
          height: 70.h,
          // The file icon keeps its own colours (blue
          // Word, green Excel, red PDF…). Tinting EVERY icon black/white
          // turned them all into the same flat silhouette. Only the
          // single-colour glyphs (video, generic document) are tinted, so they
          // stay visible on a dark card.
          color: _isMonochromeIcon(documentExtension) ? AppColors.text : null,
          fit: BoxFit.contain,
        ),
      ),
      SizedBox(width: 8.w),
      Expanded(
        child: buildDocumentInfo(
          context,
          documentName: documentName,
          documentType: documentType,
          owningDepartment: owningDepartment,
        ),
      ),
    ],
  );
}

Widget buildDocumentInfo(
  BuildContext context, {
  required String documentName,
  required String documentType,
  required String owningDepartment,
}) {
  final isMobile = ContextExtension(context).isPhone;
  final lightMode = Theme.of(context).brightness == Brightness.light;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow(
        lightMode: lightMode,
        iconPath: 'assets/icons_assets/knowledge_hub_assets/ic_file_name.svg',
        label: '${S.of(context).document_name}: ',
        value: documentName,
      ),
      if (!isMobile) ...[
        SizedBox(height: 8.h),
        _buildInfoRow(
          lightMode: lightMode,
          iconPath: 'assets/icons_assets/knowledge_hub_assets/ic_file_type.svg',
          label: '${S.of(context).document_type}: ',
          value: documentType,
        ),
        SizedBox(height: 8.h),
        _buildInfoRow(
          lightMode: lightMode,
          iconPath: 'assets/icons_assets/main_icons_assets/ic_org_department_owner.svg',
          label: '${S.of(context).owning_department}: ',
          value: owningDepartment,
        ),
      ],
    ],
  );
}

Widget _buildInfoRow({
  required String label,
  required String value,
  required String iconPath,
  required bool lightMode,
}) {
  return Row(
    children: [
      CustomSvgImage(
        assetPath: iconPath,
        height: 16.h,
        width: 16.w,
        fit: BoxFit.contain,
      ),
      SizedBox(width: 5.w),
      Text(
        label,
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: StyleText.fontSize12Weight500.copyWith(
            color: AppColors.blackButton,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget buildDocumentDescription(
  BuildContext context, {
  required String documentDescription,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/ic_file_document_description.svg',
            height: 16.h,
            width: 16.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 6.w),
          Text(
            '${S.of(context).document_description}: ',
            style: StyleText.fontSize12Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
      SizedBox(height: 8.h),
      Text(
        FormatHelper.capitalize(documentDescription),
        maxLines: null,
        style: StyleText.fontSize12Weight400.copyWith(
          height: 1.6,
          color: AppColors.text,
        ),
      ),
    ],
  );
}

// ✅ GET CORRECT FILE ICON BASED ON EXTENSION
String _getFileIcon(String extension) {
  final ext = extension.toLowerCase().trim().replaceAll('.', '');

  switch (ext) {
    case 'pdf':
      return 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
    case 'ppt':
    case 'pptx':
      return 'assets/icons_assets/main_icons_assets/ic_file_powerpoint.svg';
    case 'doc':
      return 'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
    case 'docx':
      return 'assets/icons_assets/knowledge_hub_assets/ic_file_word.svg';
    case 'xls':
    case 'xlsx':
      return 'assets/icons_assets/main_icons_assets/ic_file_excel.svg';
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'bmp':
    case 'webp':
      return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
    case 'mp4':
    case 'mov':
    case 'avi':
    case 'mkv':
      return 'assets/icons_assets/main_icons_assets/ic_file_video.svg';
    default:
      return 'assets/icons_assets/knowledge_hub_assets/ic_file_type.svg';
  }
}

/// Icons drawn in a single (black) colour — they need a theme tint to be
/// visible in dark mode. Every other file icon is full-colour and is shown as is.
bool _isMonochromeIcon(String extension) {
  final path = _getFileIcon(extension);
  return path.endsWith('knowledgeVideo.svg') ||
      path.endsWith('svg_image_icon.svg') ||
      path.endsWith('document_type_icon.svg');
}
