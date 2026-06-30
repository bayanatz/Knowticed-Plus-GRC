/// ************************* FILE INFO *************************** ///
/// File Name: grc_bottom_buttons.dart
/// Purpose: This file contains the implementation of the GrcBottomButtons widget, which provides bottom action buttons for managing GRC modules. It includes discard and save functionality with confirmation dialogs.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 2026-06-29

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/grc_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class GrcBottomButtons extends StatelessWidget {
  final GrcPageMode mode;
  final VoidCallback onDiscard;

  const GrcBottomButtons({
    super.key,
    required this.mode,
    required this.onDiscard,
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
            height: 48.h,
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
          height: 48.h,
          width: 150.w,
          color: AppColors.primary,
          textColor: AppColors.textButton,
        ),
      ],
    );
  }

  void _onActionTap(BuildContext context) {
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
      iconAsset: isCreate ? 'assets/doc.svg' : 'assets/des.svg',
      subtitle: isCreate
          ? "Are You Sure You Want To Create This Module ?".tr
          : isRestore
              ? "Are You Sure You Want To Restore This Module ?".tr
              : "Are You Sure You Want To Edit This Module ?".tr,
      onConfirm: () {
        showSuccessDialog(
          context: context,
          title: isCreate
              ? "Created Modules".tr
              : isRestore
                  ? "Restored Modules".tr
                  : "Edited Modules".tr,
          subtitle: isCreate
              ? "You Successfully Created This GRC Module".tr
              : isRestore
                  ? "You Successfully Restored This Module".tr
                  : "You Successfully Edited This Module".tr,
        );
      },
    );
  }
}
