/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: description_widget.dart
/// Purpose: The labelled service description block of the request pages.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget descriptionWidget(
  BuildContext context,
  String descriptionAr,
  String descriptionEn,
) {
  var isMobile = ContextExtension(context).isPhone;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          SizedBox(
            child: CustomSvgImage.natural(
              assetPath: // the three-lines glyph read as a menu /
                  // sort icon. Same document-description icon Knowledge Hub uses;
                  // the label now ends with ":" like every other row.
                  "assets/icons_assets/main_icons_assets/ic_file_document_description.svg",
              width: 16.sp,
              height: 16.sp,
              color: AppColors.secondaryText.withValues(alpha: .4),
              fit: BoxFit.scaleDown,
              semanticsLabel: 'Dart Logo',
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            "${S.of(context).serviceDescription}:",
            style: isMobile
                ? StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  )
                : StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
          ),
        ],
      ),
      SizedBox(height: 5.sp),
      Text(
        FormatHelper.capitalize(context.svcPick(descriptionEn, descriptionAr)),
        style: isMobile
            ? StyleText.fontSize12Weight400.copyWith(
                wordSpacing: -1.sp,
                color: AppColors.blackButton,
              )
            : StyleText.fontSize13Weight500
                .copyWith(color: AppColors.secondaryBlack)
                .copyWith(color: AppColors.blackButton),
        textAlign: TextAlign.start,
        softWrap: true,
        overflow: TextOverflow.visible,
      ),
    ],
  );
}
