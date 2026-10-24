/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/document_info_card.dart
/// ************************* FILE INFO *************************** ///
/// File Name: document_info_card.dart
/// Description: Contains the document info without inquiries and comments.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/ui/widgets/document_info/build_document_header.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget buildDocumentInfoCard(
  BuildContext context, {
  required String publishDate,
  required String documentName,
  required String documentType,
  required String owningDepartment,
  required String documentDescription,
  required String documentExtension,
}) {
  final isMobile = ContextExtension(context).isPhone;

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color: AppColors.card,
    ),
    padding: EdgeInsets.all(15.sp),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildDocumentHeader(
          context,
          documentName: documentName,
          documentType: documentType,
          owningDepartment: owningDepartment,
          documentExtension: documentExtension,
        ),
        SizedBox(height: 15.h),
        buildDocumentDescription(
          context,
          documentDescription: documentDescription,
        ),
        if (isMobile) ...[
          SizedBox(height: 15.h),
          Row(
            children: [
              CustomSvgImage(
                assetPath:
                    'assets/icons_assets/knowledge_hub_assets/ic_file_type.svg',
                height: 15.h,
                width: 15.h,
              ),
              SizedBox(width: 5.w),
              Text(
                '${S.of(context).document_type}: ',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Expanded(
                child: Text(
                  documentType,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.blackButton,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              CustomSvgImage(
                assetPath:
                    'assets/icons_assets/main_icons_assets/ic_org_department_owner.svg',
                height: 15.h,
                width: 15.h,
              ),
              SizedBox(width: 5.w),
              Text(
                '${S.of(context).owning_department}: ',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Expanded(
                child: Text(
                  owningDepartment,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.blackButton,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget buildPublishDate(BuildContext context, {required String publishDate}) {
  return Row(
    children: [
      Text(
        '${S.of(context).publish_date}: ',
        style: StyleText.fontSize10Weight400
            .copyWith(color: AppColors.secondaryText),
      ),
      Text(
        publishDate,
        style: StyleText.fontSize10Weight400
            .copyWith(color: AppColors.blackButton),
      ),
    ],
  );
}
