/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: default_dialog.dart
/// Description: Declares `DefaultDialog`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/messaging/helpers/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_weights.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

//Youssef Ashraf,mohamed mohy
///Default Result Dialog after specific Action has been performed
class DefaultDialog extends StatelessWidget implements DestructiveDialog {
  @override
  bool get isDestructive => HapticController.isDestructiveText(
        '${title ?? ''} ${subTitle ?? ''} ${okButtonText ?? ''}',
      );

  final dynamic Function()? onConfirm;
  final String? lottieAsset, svgAsset;
  final String? title;
  final String? subTitle;
  final bool showButtons;
  final bool autoClose;
  final String? okButtonText;
  final String? cancelButtonText;
  final double? width, height;
  final Widget? customWidget, customIconWidget;

  /// Inner padding. ADDED 12/10/2026 (Form Builder bug report p.19 / p.28 /
  /// p.58): the default 8 left the No button almost touching the dialog edge
  /// next to the app's standard dialogs, which use 24. Null keeps the old 8 so
  /// every existing caller is unchanged.
  final EdgeInsetsGeometry? padding;

  const DefaultDialog({
    super.key,
    this.onConfirm,
    this.lottieAsset,
    this.title,
    this.subTitle,
    this.showButtons = false,
    this.okButtonText,
    this.cancelButtonText,
    this.autoClose = true,
    this.width,
    this.svgAsset,
    this.customWidget,
    this.customIconWidget,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // FIXED 17/10/2026: the auto-close timer was started on EVERY build, so a
    // dialog that rebuilt closed several screens, and when the widget was
    // shown inline (the customs preview) it closed the page under it. It now
    // starts once and only closes the dialog's own route while it is on top.
    return _AutoClose(
      enabled: autoClose,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.card,
        ),
        padding:
            padding ?? EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        width: width ?? (ContextExtension(context).isTablett ? 410 : 343),
        height: height,
        child: customWidget ??
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (lottieAsset != null || svgAsset != null)
                  Container(
                    alignment: Alignment.center,
                    height: 100.h,
                    width: 100.w,
                    margin: EdgeInsets.only(left: 8.w, right: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: lottieAsset != null
                        ? LottieBuilder.asset(
                            lottieAsset!,
                            frameRate: const FrameRate(120),
                          )
                        : CustomSvgImage.natural(
                            assetPath: svgAsset!, height: 50.h, width: 50.w),
                  ),
                if (customIconWidget != null) customIconWidget!,
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize14Weight500.copyWith(
                          fontSize: 20.sp,
                          height: 1,
                        ),
                      ),
                    if (title != null) SizedBox(height: 20.sp),
                    if (subTitle != null)
                      Text(
                        subTitle!,
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize14Weight400
                            .copyWith(color: AppColors.secondaryBlack)
                            .copyWith(
                              height: 1,
                              fontWeight: AppFontWeights.medium,
                            ),
                      ),
                    if (!showButtons && subTitle != null)
                      SizedBox(height: 30.sp),
                    if (showButtons)
                      Column(
                        children: [
                          verticalSpace(15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // FIXED 12/10/2026 (Form Builder mobile bug
                              // report, Restore dialog): two fixed 130.w
                              // buttons + 30 gap were wider than the 343 dialog
                              // on a phone, so "Yes" ran past its right edge.
                              // Each button now shrinks to share the width,
                              // like CustomDialogManager's confirm buttons.
                              // Its colours ("branding") are the app's
                              // secondary-action pair, not Material greys.
                              Flexible(
                                child: customButton(
                                  width: ContextExtension(context).isPhone
                                      ? 130.w
                                      : 120.w,
                                  color: AppColors.darkGrey,
                                  textStyle: StyleText.fontSize14Weight500
                                      .copyWith(color: AppColors.text),
                                  height:
                                      38, // 4.r corners (form bug report #7/#10)
                                  title: cancelButtonText ?? S.of(context).no,
                                  function: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                              horizontalSpace(
                                ContextExtension(context).isPhone ? 15 : 30,
                              ),
                              Flexible(
                                child: customButton(
                                  width: ContextExtension(context).isPhone
                                      ? 130.w
                                      : 120.w,
                                  height:
                                      38, // 4.r corners (form bug report #7/#10)
                                  title: okButtonText ?? S.of(context).yes,
                                  color: AppColors.primary,
                                  function: () {
                                    Navigator.of(context).pop();

                                    onConfirm?.call();
                                  },
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(15),
                        ],
                      ),
                  ],
                ),
              ],
            ),
      ),
    );
  }
}

/// Closes the route this widget is on after 2 s — once, and only while that
/// route is still the top one.
class _AutoClose extends StatefulWidget {
  const _AutoClose({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  State<_AutoClose> createState() => _AutoCloseState();
}

class _AutoCloseState extends State<_AutoClose> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) return;
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route is PopupRoute && route.isCurrent) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
