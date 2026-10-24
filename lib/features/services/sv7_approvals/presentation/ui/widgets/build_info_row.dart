/// Module: services / sv7_approvals / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: build_info_row.dart
/// Purpose: InfoRowApproval, the icon + label + value row of the approvals
///          cards.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

class InfoRowApproval extends StatelessWidget {
  final String? image;
  final String? title;
  final String? value;

  /// How many lines the value may occupy before it ellipsises.
  ///
  /// Defaults to 1. This used to be unbounded, so a long value (e.g. an
  /// "Information Technology" department) silently wrapped onto a second line
  /// and pushed the card past the grid's fixed mainAxisExtent.
  /// Any caller allowing >1 must be reflected in approvalCardExtent().
  final int maxLines;

  const InfoRowApproval(
    this.image,
    this.title,
    this.value, {
    super.key,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.sp),
      child: Row(
        children: [
          if (image != null)
            CustomSvgImage.natural(
              assetPath: image!,
              width: 16.sp,
              height: 16.sp,
              color: AppColors.secondaryText,
            ),
          if (image != null) SizedBox(width: 6.sp),
          if (title != null)
            Text(
              "$title ",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          Expanded(
            child: Text(
              FormatHelper.capitalize(value ?? "-"),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
