/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: submitted_document_data_row.dart
/// Description: Build submitted document data row — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget buildInfoRow({
  required String label,
  required String value,
  required String iconPath,
  required bool lightMode,
}) {
  return Row(
    children: [
      CustomSvgImage(
        assetPath: iconPath,
        fit: BoxFit.fill,
        width: 16.w,
        height: 16.h,
      ),
      SizedBox(width: 5.w),
      Text(
        label,
        style: StyleText.fontSize14Weight400.copyWith(
          overflow: TextOverflow.ellipsis,
          color: AppColors.secondaryText,
        ),
      ),
      // Long values end in "…" instead of overflowing.
      Flexible(
        child: Text(
          FormatHelper.capitalize(value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
      ),
    ],
  );
}

Widget buildSubmittedDocumentDescription(
  BuildContext context, {
  required String documentDescription,
  required bool isMobile,
  required bool lightMode,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/ic_file_description_light.svg',
            fit: BoxFit.fill,
            width: 16.w,
            height: 16.h,
          ),
          SizedBox(width: 5.w),
          //submission details screen
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${S.of(context).document_description}: ",
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                Flexible(
                  child: Text(
                    FormatHelper.capitalize(documentDescription),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.blackButton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: 4.h),
    ],
  );
}
