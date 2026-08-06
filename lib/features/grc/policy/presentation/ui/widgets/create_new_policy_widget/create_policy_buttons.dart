/// The Back + Save-For-Later button column shared by every step of the
/// Create Policy flow, plus a caller-supplied trailing action button.
/// Replaces CreatePolicyStep1Buttons and CreatePolicyStep2Buttons, which
/// were the same widget with a different trailing button hardcoded in.
library;

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/generated/l10n.dart';

class CreatePolicyBackSaveButtons extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSaveForLater;
  final Widget trailingButton;

  const CreatePolicyBackSaveButtons({
    super.key,
    required this.onBack,
    required this.onSaveForLater,
    required this.trailingButton,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            customButton(
              title: S.of(context).back,
              function: onBack,
              height: 38.h,
              width: 150.w,
              color: AppColors.grey,
              textStyle:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            ),
            SizedBox(height: 10.h),
            customButton(
              title: S.of(context).saveForLater,
              function: onSaveForLater,
              height: 38.h,
              width: 150.w,
              color: AppColors.grey,
              textStyle:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            ),
          ],
        ),
        trailingButton,
      ],
    );
  }
}
