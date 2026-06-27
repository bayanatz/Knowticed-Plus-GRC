import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';

class MainCustomButton extends StatelessWidget {
  final String? buttonText;
  final VoidCallback onPressed;
  final double? height;
  final Color? buttonColor;
  final TextStyle? textStyle;

  const MainCustomButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.height,
    this.buttonColor,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      height: height ?? 50.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(buttonText== null?"":buttonText!.tr,
                style: textStyle ??
                    AppTextStyles.font23BlackSemiBoldCairo
                        .copyWith(color: AppColors.textButton)
            ),
          ],
        ),
      ),
    );
  }
}
