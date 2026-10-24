/// Module: services / sv2_create_single_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: sla_action_buttons.dart
/// Purpose: The Back / Submit (or Save) / Save-for-later buttons under the
///          SLA notification form. Split out of the SLA page (rule C7: the
///          page was over 800 lines).
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [SlaActionButtons]
///
/// Purpose: The SLA page's action buttons.
class SlaActionButtons extends StatelessWidget {
  const SlaActionButtons({
    super.key,
    required this.isNewService,
    required this.showSaveForLater,
    required this.isEditingSubmittedService,
    required this.onBack,
    required this.onSubmit,
    required this.onSaveForLater,
  });

  /// True when a new service is being created (Submit), false when an
  /// existing one is edited (Save).
  final bool isNewService;
  final bool showSaveForLater;

  /// When true the third button reads "Discard change".
  final bool isEditingSubmittedService;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final VoidCallback onSaveForLater;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            customButton(
              title: s.back,
              function: onBack,
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.white,
              ),
              width: 150.sp,
              height: 38.sp,
              radius: 8.r,
              color: AppColors.darkGrey,
            ),
            const Spacer(),
            customButton(
              // C16: was getSaveForLaterText(), whose three branches all
              // returned Save.
              title: isNewService ? s.submit : s.Save,
              function: onSubmit,
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.textButton,
              ),
              width: 150.sp,
              height: 38.sp,
              radius: 8.r,
              color: AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: 10.sp),
        if (showSaveForLater)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              customButton(
                title: isEditingSubmittedService
                    ? s.discardChange
                    : s.saveForLater,
                function: onSaveForLater,
                textStyle: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.white,
                ),
                width: 150.sp,
                height: 38.sp,
                radius: 8.r,
                color: AppColors.darkGrey,
              ),
            ],
          ),
      ],
    );
  }
}
