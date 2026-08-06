/// Module: GRC Policy Management
/// Description: Score badge + "Previous Control Owners" button row for the
///              Control Details page, extracted from ControlDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter, CustomButton
/// Revision History: 2026-07-21 - Initial creation (inline in
///                                control_details_page.dart)
///                   2026-07-28 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_score_and_previous_owners_row_widget.dart
/// Purpose: Contains ControlScoreAndPreviousOwnersRowWidget, the Score
///          badge paired with the "Previous Control Owners" button.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/7/2026

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/generated/l10n.dart';

/// class name: [ControlScoreAndPreviousOwnersRowWidget]
///
/// purpose: renders the Control's Score badge next to the "Previous
///          Control Owners" button.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/7/2026
class ControlScoreAndPreviousOwnersRowWidget extends StatelessWidget {
  final int score;
  final VoidCallback onPreviousOwnersTap;

  const ControlScoreAndPreviousOwnersRowWidget({
    super.key,
    required this.score,
    required this.onPreviousOwnersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text.rich(
            TextSpan(
              text: '${S.of(context).score}: ',
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryText),
              children: [
                TextSpan(
                  text: '$score',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: AppColors.green),
                ),
              ],
            ),
          ),
        ),
        customButton(
          title: S.of(context).previousControlOwners,
          function: onPreviousOwnersTap,
          height: 38.h,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }
}
