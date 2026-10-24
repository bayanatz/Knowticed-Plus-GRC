/// Module: services / sv5_service_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: info_text.dart
/// Purpose: Info text — declares isTabletLandscape, infoBox.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

bool isTabletLandscape(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isLandscape =
      MediaQuery.of(context).orientation == Orientation.landscape;
  return size.width >= 600 && isLandscape;
}

Widget infoBox(
  BuildContext context,
  String title,
  String value,
  Color colorBorder,
) {
  var isMobile = ContextExtension(context).isPhone;
  return Container(
    height: isMobile ? 30.sp : 38.sp,
    width: isMobile
        ? 100.sp
        : !isTabletLandscape(context)
            ? 130.sp
            : 150.sp,
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(4.r),
      border: Border.all(color: colorBorder),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          FormatHelper.capitalize(title),
          style: isMobile
              ? StyleText.fontSize10Weight400.copyWith(
                  color: AppColors.secondaryText,
                )
              : StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
        ),
        SizedBox(width: 6.sp),
        Text(
          FormatHelper.capitalize(value),
          style: isMobile
              ? StyleText.fontSize10Weight400.copyWith(
                  color: AppColors.blackButton,
                )
              : StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
        ),
      ],
    ),
  );
}
