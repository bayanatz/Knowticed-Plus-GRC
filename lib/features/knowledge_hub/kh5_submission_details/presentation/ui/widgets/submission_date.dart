/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: submission_date.dart
/// Description: Build submission date — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget buildSubmissionDate(
  BuildContext context, {
  required String submissionDate,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        "${S.of(context).submissionDate}: ",
        style: StyleText.fontSize10Weight400.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      Text(
        submissionDate,
        style: StyleText.fontSize10Weight400.copyWith(
          color: AppColors.blackButton,
        ),
      ),
    ],
  );
}
