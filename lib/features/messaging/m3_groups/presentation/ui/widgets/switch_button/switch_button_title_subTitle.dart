import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/get_utils.dart';

import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/custom/hover_example.dart';

import '../../../../../../../core/custom/58_default_switch_button.dart';

class SwitchButtonTitleSubTitle extends StatelessWidget {
  const SwitchButtonTitleSubTitle({
    super.key,
    required this.title,
    required this.subTitle,
    required this.value,
    required this.onChanged,
    this.labelWidth,
  });
  final String title;
  final String subTitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double? labelWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth ?? 120.w,
          child: Text(
            title,
            style: AppTextStyles.font14BlackCairoMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        HoverExample(subtitle: subTitle),
        Spacer(),
        DefaultSwitchButton(value: value, onChanged: onChanged),
      ],
    );
  }
}