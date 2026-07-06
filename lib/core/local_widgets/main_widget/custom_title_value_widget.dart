import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';


class CustomTitleValueWidget extends StatelessWidget {
  CustomTitleValueWidget(
      {required this.title,
      required this.value,
      this.titleStyle,
      this.valueStyle,
      super.key});
  String title;
  String value;
  TextStyle? titleStyle;
  TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.font14BlackCairoMedium.copyWith(
              color: AppColors.secondaryText,
          ),
        ),
        Text(
     value,
          style: AppTextStyles.font14BlackCairoMedium.copyWith(
              color: AppColors.text,
          ),
        )
      ],
    );
  }
}
