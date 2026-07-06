/// Module: GRC Module Management
/// Description: Provides the bottom action buttons (Discard / Publish / Save /
///              Restore) displayed at the foot of the GRC Module details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: AppColors, customButton, showConfirmDialog, GrcPageMode
/// Revision History: 2026-06-29 - Initial creation
///                    2026-06-30 - Added onAction callback (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_bottom_buttons.dart
/// Purpose: Contains GrcBottomButtons, the bottom row of action buttons for
///          create, edit, and restore modes of the GRC Module details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/grc_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [GrcBottomButtons]
///
/// purpose: renders the bottom action row for the GRC Module details page.
///          Hidden in view mode; shows Discard + Publish/Save/Restore otherwise.
///          Tapping the primary action opens a confirmation dialog before
///          invoking [onAction].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 29/6/2026
class GrcBottomButtons extends StatelessWidget {
  final GrcPageMode mode;
  final VoidCallback onDiscard;
  final VoidCallback onAction;

  /// Called before the confirm dialog. Return false to abort.
  final bool Function()? validate;

  const GrcBottomButtons({
    super.key,
    required this.mode,
    required this.onDiscard,
    required this.onAction,
    this.validate,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == GrcPageMode.view) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: mode == GrcPageMode.restore
          ? MainAxisAlignment.end
          : MainAxisAlignment.spaceBetween,
      children: [
        if (mode != GrcPageMode.restore)
          customButton(
            title: mode == GrcPageMode.create
                ? 'Discard'.tr
                : 'Discard Changes'.tr,
            function: onDiscard,
            height: 38.h,
            width: 150.w,
            color: AppColors.grey,
            textColor: AppColors.text,
            borderColor: AppColors.border,
          ),
        customButton(
          title: mode == GrcPageMode.create
              ? 'Publish'.tr
              : mode == GrcPageMode.restore
                  ? 'Restore'.tr
                  : 'Save'.tr,
          function: () => _onActionTap(context),
          height: 38.h,
          width: 150.w,
          color: AppColors.primary,
          textColor: AppColors.textButton,
        ),
      ],
    );
  }

  void _onActionTap(BuildContext context) {
    if (validate != null && !validate!()) return;
    final isCreate = mode == GrcPageMode.create;
    final isRestore = mode == GrcPageMode.restore;
    showConfirmDialog(
      context: context,
      title: isCreate
          ? "Creating Modules".tr
          : isRestore
              ? "Restoring Module".tr
              : "Editing Modules".tr,
      cancelLabel: "No".tr,
      confirmLabel: "Yes".tr,
      iconWidget: isCreate
          ? SvgPicture.asset('assets/doc.svg')
          : SvgPicture.asset('assets/des.svg'),
      subtitle: isCreate
          ? "Are You Sure You Want To Create This Module ?".tr
          : isRestore
              ? "Are You Sure You Want To Restore This Module ?".tr
              : "Are You Sure You Want To Edit This Module ?".tr,
      onConfirm: onAction,
    );
  }
}
