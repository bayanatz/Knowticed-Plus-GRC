/// Module: services / presentation / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: reuse_text.dart
/// Purpose: textCorner, the icon + label + value row used on the request cards
///          (shimmer while the value is "...").
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/show_requests_shimmer.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget textCorner({
  required String image,
  required String label,
  required String content,
  required BuildContext context,
}) {
  final isShimmer = content.trim() == "...";
  ContextExtension(context).isPhone;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CustomSvgImage.natural(
        assetPath: image,
        width: 16.w,
        height: 16.h,
        fit: BoxFit.fill,
      ),
      SizedBox(width: 5.w),
      Text(
        FormatHelper.capitalize(label),
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      isShimmer
          ? Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: masterShimmerPlaceholder(
                  context: context,
                  width: 100.w,
                  height: 5.sp,
                ),
              ),
            )
          : Expanded(
              child: Text(
                FormatHelper.capitalize(content),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
            ),
    ],
  );
}
