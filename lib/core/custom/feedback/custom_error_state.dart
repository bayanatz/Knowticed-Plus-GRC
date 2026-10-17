/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: 100-custom_error_state.dart
/// Description: `CustomErrorState` — the shared "something went wrong" view,
///              with an optional Retry. The error twin of CustomEmptyState.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/generated/l10n.dart';

/// Use this instead of a hand-written error column on every screen (Rule
/// Bug 2 — "reuse shared widgets, no copies"). Text styles and colours come
/// from the theme; the Retry label comes from the translations.
class CustomErrorState extends StatelessWidget {
  const CustomErrorState({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
  });

  /// Short headline, already translated by the caller.
  final String title;

  /// Optional detail (e.g. the error text). Long text is cut at 3 lines.
  final String? message;

  /// Shows a Retry button when given.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 50.sp, color: AppColors.red),
            SizedBox(height: 10.sp),
            Text(
              title,
              textAlign: TextAlign.center,
              style:
                  StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            ),
            if (message != null && message!.isNotEmpty) ...[
              SizedBox(height: 8.sp),
              Text(
                message!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: 16.sp),
              customButton(title: S.of(context).retry, function: onRetry!),
            ],
          ],
        ),
      ),
    );
  }
}
