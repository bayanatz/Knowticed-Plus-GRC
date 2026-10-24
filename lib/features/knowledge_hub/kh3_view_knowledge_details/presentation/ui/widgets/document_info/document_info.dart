/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/document_info.dart
/// ************************* FILE INFO *************************** ///
/// File Name: document_info.dart
/// Description: Contains the name, type, department and description of files.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Created At: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget buildDocumentInfo(
  BuildContext context, {
  required String documentName,
  required String documentType,
  required String owningDepartment,
}) {
  final isMobile = ContextExtension(context).isPhone;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow(
        iconPath: 'assets/icons_assets/knowledge_hub_assets/ic_file_name.svg',
        label: '${S.of(context).document_name}: ',
        value: documentName,
      ),
      if (!isMobile) ...[
        _buildInfoRow(
          iconPath: 'assets/icons_assets/knowledge_hub_assets/ic_file_type.svg',
          label: '${S.of(context).document_type}: ',
          value: documentType,
        ),
        _buildInfoRow(
          iconPath:
              'assets/icons_assets/main_icons_assets/ic_org_department_owner.svg',
          label: S.of(context).owning_department,
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
}) {
  return Row(
    children: [
      CustomSvgImage(
        assetPath: iconPath,
        height: 20.h,
        width: 15.w,
        fit: BoxFit.fill,
      ),
      SizedBox(width: 5.w),
      Text(
        label,
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      Text(value, style: StyleText.fontSize14Weight400),
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
            assetPath:
                'assets/icons_assets/main_icons_assets/ic_file_document_description.svg',
            height: 18.h,
            width: 13.w,
            fit: BoxFit.fill,
          ),
          SizedBox(width: 4.w),
          Text(
            '${S.of(context).document_description}: ',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
      SizedBox(height: 4.h),
      Text(
        FormatHelper.capitalize(documentDescription),
        maxLines: null,
        style: StyleText.fontSize10Weight400
            .copyWith(color: AppColors.blackButton),
      ),
    ],
  );
}
