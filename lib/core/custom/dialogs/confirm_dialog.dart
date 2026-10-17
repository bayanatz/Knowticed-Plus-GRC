/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: confirm_dialog.dart
/// Description: Declares `ConfirmDialog`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:grc_module/core/theme/app_animations.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';

class ConfirmDialog {
  Future<dynamic> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required Function onConfirm,
    required Function onCancel,
    String? onConfirmText,
    String? onCancelText,
  }) {
    return showAppDialog(
      context: context,
      // Delete / remove / log out -> shake once + high haptic; else scale.
      destructive: HapticController.isDestructiveText(
        '$title $subtitle ${onConfirmText ?? ''}',
      ),
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
          ),
        );
      },
    );
  }
}

class Content extends StatelessWidget {
  const Content({
    super.key,
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
    bool isTablet = !kpIsPhoneLayout(context);
    ContextExtension(context).isPhone;
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      width: isTablet ? 500.sp : 300.sp,
      child: Column(
        spacing: 15.sp,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon.contains('.svg')) CustomSvgImage.natural(assetPath: icon),
          if (!icon.contains('.svg'))
            Lottie.asset(icon, width: 70.sp, height: 70.sp),
          Text(title, style: StyleText.fontSize14Weight500),
          Text(
            subtitle,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryBlack)
                .copyWith(),
            textAlign: TextAlign.center,
          ),
          // Role QA p.29: the two fixed-width buttons were wider than the
          // 300 phone dialog together, so No and Yes touched. They now share
          // the row equally with a 12 gap.
          Row(
            textDirection: TextDirection
                .ltr, // X-73: Cancel left, action right in both languages

            children: [
              Expanded(
                child: customButton(
                  fullWidth: true,
                  color: AppColors.darkGrey,
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.text,
                  ),
                  title: onCancelText ?? S.of(context).no,
                  function: () {
                    Navigator.of(context).pop();
                    onCancel();
                  },
                ),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: customButton(
                  fullWidth: true,
                  title: onConfirmText ?? S.of(context).yes,
                  function: () {
                    Navigator.of(context).pop();

                    onConfirm();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
