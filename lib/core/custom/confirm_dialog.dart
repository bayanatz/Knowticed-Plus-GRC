import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class ConfirmDialog {
  show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required Function onConfirm,
    required Function onCancel,
    String? onConfirmText,
    String? onCancelText,
  }) {
    return showDialog(
      context: context,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return Dialog(
            child: Content(
          title: title,
          subtitle: subtitle,
          icon: icon,
          onConfirm: onConfirm,
          onCancel: onCancel,
          onCancelText: onCancelText,
          onConfirmText: onConfirmText,
        ));
      },
    );
  }
}

class Content extends StatelessWidget {
  Content({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onConfirm,
    required this.onCancel,
    this.onConfirmText,
    this.onCancelText,
  });
  final String title;
  final String subtitle;
  final String icon;
  final Function onConfirm;
  final Function onCancel;
  final String? onConfirmText;
  final String? onCancelText;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    var isMobile = ContextExtension(context).isPhone;
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      width: isTablet ? 500.sp : 300.sp,
      child: Column(
        spacing: 15.sp,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon.contains('.svg')) SvgPicture.asset(icon),
          if (!icon.contains('.svg'))
            Lottie.asset(
              icon,
              width: 70.sp,
              height: 70.sp,
            ),
          Text(title, style: AppTextStyles.font14BlackCairoMedium),
          Text(subtitle,
              style: AppTextStyles.font14SecondaryBlackCairoMedium.copyWith(),
              textAlign: TextAlign.center),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              customButton(
                  color: AppColors.secondaryButton,
                  textStyle: AppTextStyles.font16BlackCairoMedium,
                  title: onCancelText ?? S.of(context).no,
                  function: () {
                    Navigator.of(context).pop();
                    onCancel();
                  }),
              customButton(
                  title: onConfirmText ?? S.of(context).yes,
                  function: () {
                    Navigator.of(context).pop();

                    onConfirm();
                  }),
            ],
          )
        ],
      ),
    );
  }
}
