/// Module: core / custom / labels
///
///*************************** FILE INFO ****************************///
/// File Name: count_chip.dart
/// Description: "Label: value" count chip (Total Services: 20, Total
///              Requests: 3) — label in the secondary colour, value in the
///              text colour, sized to its content.
/// Author: Moataz Handousa
/// Created at: 18/10/2026
///
/// Moataz (third time, 18/10/2026): in every "label: value" pair the title
/// and the value have different colours. The bulk-upload chips drew both in
/// one colour inside a fixed-width box.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class KpCountChip extends StatelessWidget {
  const KpCountChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text.rich(
        TextSpan(children: <TextSpan>[
          TextSpan(
            text: '$label: ',
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
          TextSpan(
            text: value,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ]),
      ),
    );
  }
}
