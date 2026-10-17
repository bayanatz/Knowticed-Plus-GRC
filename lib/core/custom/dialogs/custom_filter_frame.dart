/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_filter_frame.dart
/// Purpose: THE filter pop-up of the app — `CustomDialogHeader` (yellow
///          round icon + title) and `CustomFilterFrame` (header · rows of
///          fields · Reset / Apply).
/// Author: Knowticed Plus team
/// Created at: 17/10/2026 — moved up from Time Tracker (TtFilterFrame /
///            TtDialogHeader, owner-approved 12–13 Oct) after Moataz compared
///            the Form Builder filter with Time Tracker's ("the size of the
///            buttons … in time tracker it's not like this"). Time Tracker
///            keeps its names as typedefs.
///
/// Rules: fields 36 high (D-18); Reset grey at the LEFT edge, Apply yellow at
/// the RIGHT edge, same width, in both languages (X-73); Apply grey while
/// [canApply] is false; scale-in like every dialog.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/constants/app_assets.dart';
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/generated/l10n.dart';

/// Dialog title row: a 30 yellow circle with the [icon], then the [title].
class CustomDialogHeader extends StatelessWidget {
  const CustomDialogHeader(
      {super.key, required this.title, this.icon = AppAssets.edit});

  final String title;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 30.r,
          height: 30.r,
          padding: EdgeInsetsDirectional.all(7.r),
          decoration:
              BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: CustomSvgImage(assetPath: icon, color: AppColors.textButton),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(title,
              style: StyleText.fontSize18Weight500
                  .copyWith(color: AppColors.text)),
        ),
      ],
    );
  }
}

/// Header "Filter", the field [rows] (each a `CustomFieldPair` or a single
/// field), then Reset (left) · Apply (right). Open it with
/// `CustomDialogManager.showContent` so every filter has the same width.
class CustomFilterFrame extends StatelessWidget {
  const CustomFilterFrame({
    super.key,
    required this.rows,
    required this.onReset,
    required this.onApply,
    this.canApply = true,
    this.applyKey,
  });

  final List<Widget> rows;
  final VoidCallback onReset;
  final VoidCallback onApply;

  /// False while a field is invalid: Apply turns grey and does nothing.
  final bool canApply;
  final Key? applyKey;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ScaleInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomDialogHeader(title: s.filter, icon: AppAssets.filter),
          SizedBox(height: 15.h),
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) SizedBox(height: 15.h),
            rows[i],
          ],
          SizedBox(height: 20.h),
          Row(
            // X-73: Reset left, Apply right in Arabic too.
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 130.w,
                child: customButton(
                  title: s.reset,
                  haptic: HapticController.low,
                  function: onReset,
                  color: AppColors.secondaryAction,
                  textStyle: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.onSecondaryAction),
                ),
              ),
              SizedBox(
                width: 130.w,
                child: KeyedSubtree(
                  key: applyKey,
                  child: canApply
                      ? ShrinkOnTap(
                          child: customButton(
                            title: s.apply,
                            function: onApply,
                            color: AppColors.primary,
                            textStyle: StyleText.fontSize16Weight500
                                .copyWith(color: AppColors.textButton),
                          ),
                        )
                      : customButton(
                          title: s.apply,
                          function: () {},
                          haptic: () {},
                          color: AppColors.disabledButton,
                          textStyle: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.colorGreyDark),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
