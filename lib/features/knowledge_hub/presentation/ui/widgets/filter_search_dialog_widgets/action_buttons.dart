/// Module: knowledge_hub/presentation/ui/widgets/filter_search_dialog_widgets
///
///*************************** FILE INFO ****************************///
/// File Name: action_buttons.dart
/// Description: `buildActionButtons()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

Widget buildActionButtons(
  BuildContext context, {
  required bool isMobile,
  required void Function() function,
  required void Function() onApplyClicked,
}) {
  Theme.of(context).brightness == Brightness.light;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      customButton(
        height: 38.h,
        width: isMobile ? 130.w : 150.w,
        title: S.of(context).reset,
        function: function,
        color: AppColors.secondaryAction, // branding (KH mobile p.6/7/10)
        textStyle: StyleText.fontSize16Weight400.copyWith(
          color: AppColors.onSecondaryAction,
        ),
      ),
      SizedBox(width: 45.w),
      customButton(
        height: 38.h,
        width: isMobile ? 130.w : 150.w,
        title: S.of(context).apply,
        function: onApplyClicked,
        textStyle: StyleText.fontSize16Weight500.copyWith(
          color: AppColors.textButton,
        ),
      ),
    ],
  );
}
