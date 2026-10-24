/// Module: services / sv2_create_single_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: sla_mobile_percentage_field.dart
/// Purpose: "When service SLA is about to be breached [ __ ] %" on the phone
///          SLA step. Split out of the screen (Provider rule 7).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [SlaMobilePercentageField]
///
/// Purpose: One SLA percentage, bound to the page's [controller].
class SlaMobilePercentageField extends StatelessWidget {
  const SlaMobilePercentageField({
    required this.controller,
    required this.onChanged,
    this.indent = 25,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// Start padding, in sp.
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent.sp, top: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            S.of(context).whenServiceSlaIsAboutToBeBreached,
            style: StyleText.fontSize10Weight600.copyWith(
              color: AppColors.text,
            ),
          ),
          SizedBox(width: 6.sp),
          CustomTextField(
            onlyDigits: true,
            hint: S.of(context).EnterPercentage,
            width: 102.w,
            valueStyle: StyleText.fontSize12Weight500,
            fillColor: AppColors.background,
            controller: controller,
            onChanged: onChanged,
            height: 28.sp,
          ),
          SizedBox(width: 4.sp),
          Text(
            '%',
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
