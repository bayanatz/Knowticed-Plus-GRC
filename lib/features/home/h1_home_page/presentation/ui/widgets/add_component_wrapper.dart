/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: add_component_wrapper.dart
/// Description: Declares `AddComponentWrapper`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/inputs/custom_textfield.dart';
import 'package:grc_module/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/home/h1_home_page/data/models/home_component_model.dart';

import 'package:grc_module/generated/l10n.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/text_field.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_cubit.dart';

import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

class AddComponentWrapper extends StatelessWidget {
  const AddComponentWrapper({
    required this.component,
    required this.model,
    super.key,
  });
  final Widget component;
  final HomeComponentModel model;

  void _showSLADialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    showAppDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            width: 330.w,
            padding: EdgeInsets.all(24.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      width: 26.sp,
                      height: 26.sp,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CustomSvgImage(
                          assetPath:
                              "assets/icons_assets/home_assets/ic_time_sla.svg",
                          width: 16.w,
                          height: 14.h,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'SLA',
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Using CustomValidatedTextField
                CustomTextField(
                  label: 'SLA Percentage',
                  hint: S.of(context).textHere,
                  controller: textController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                ),

                SizedBox(height: 20.h),

                // Buttons
                Row(
                  textDirection: TextDirection
                      .ltr, // X-73: Cancel left, action right in both languages

                  children: [
                    customButton(
                      title: S.of(context).discard,
                      function: () {
                        Navigator.pop(dialogContext);
                      },
                      width: 135.w,
                      height: 38.h,
                      radius: 8,
                      color: AppColors.darkGrey,
                      textStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    customButton(
                      title: S.of(context).save,
                      function: () {
                        // Handle save action
                        // Add your save logic here
                        // Example: context.read<HomeCubit>().updateSLAPercentage(model, value);
                        Navigator.pop(dialogContext);
                      },
                      width: 135.w,
                      height: 38.h,
                      radius: 8,
                      color: Colors.yellow.shade700,
                      textStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: AppColors.transparent,
      hoverColor: AppColors.transparent,
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        if (!model.component.isEditable) {
          context.read<AppHomeCubit>().editComponent(model);
          Navigator.pop(context);
        }
      },
      child: Stack(
        children: [
          Padding(
            // .w/.h rather than .sp so this padding scales on the same
            // axis as the card widths it sits between — together with
            // the Wrap's 3 it makes up Figma's 15 gutter.
            padding: EdgeInsetsDirectional.only(top: 12.h, end: 12.w),
            child: component,
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(color: AppColors.transparent),
          ),
          if (model.component.isEditable)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: InkWell(
                splashColor: AppColors.transparent,
                hoverColor: AppColors.transparent,
                onTapDown: (_) => HapticController.low(),
                onTap: () {
                  _showSLADialog(context);
                },
                child: Container(
                  width: 25.sp,
                  height: 25.sp,
                  padding: EdgeInsets.all(4.sp),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greyIcon,
                  ),
                  child: CustomSvgImage.natural(
                    assetPath:
                        'assets/icons_assets/main_icons_assets/ic_module_settings.svg',
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
