// ****************** FILE INFO ******************
// File Name: crm_template_element_form_actions.dart
// Purpose: Footer actions of the section/field element form: add field, discard,
//          save-as-section and the add/save button in a single unified row
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Footer actions bar of the section/field element form.
class CrmTemplateElementFormActions extends StatelessWidget {
  const CrmTemplateElementFormActions({
    super.key,
    required this.onDiscard,
    required this.onAddField,
    this.showAddField = true,
    required this.canUseSavedSections,
    required this.isSavingAsSection,
    required this.onSaveAsSection,
    required this.isFormValid,
    required this.isSaving,
    required this.isAddMode,
    required this.onSave,
  });

  final VoidCallback onDiscard;
  final VoidCallback onAddField;
  final bool showAddField;
  final bool canUseSavedSections;
  final bool isSavingAsSection;
  final VoidCallback onSaveAsSection;
  final bool isFormValid;
  final bool isSaving;
  final bool isAddMode;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = kpIsPhoneLayout(context);
    final bool isEnabled = isFormValid && !isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showAddField || canUseSavedSections) ...[
          Row(
            children: [
              if (showAddField) ...[
                customButtonWithSvg(
                  title: S.current.crmAddField,
                  function: onAddField,
                  textStyle: StyleText.fontSize12Weight400
                      .copyWith(
                          color: AppTheme.readableOn(AppColors.blackButton))
                      .copyWith(
                        color: AppTheme.readableOn(AppColors.blackButton),
                        fontWeight: FontWeight.bold,
                      ),
                  color: AppColors.blackButton,
                  image: AppAssets.crmPlusBold,
                  widthImage: 16.sp,
                  heightImage: 16.sp,
                  colorBorder: AppColors.transparent,
                  svgColor: AppTheme.readableOn(AppColors.blackButton),
                ),
              ],
              if (showAddField && canUseSavedSections) SizedBox(width: 12.sp),
              if (canUseSavedSections) ...[
                customButton(
                  title: isSavingAsSection
                      ? S.current.crmSaving
                      : S.current.crmSaveAsSection,
                  function: isSavingAsSection ? () {} : onSaveAsSection,
                  color: AppColors.grey,
                  textStyle: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: isMobile ? 20.sp : 24.sp),
        ],
        if (isMobile)
          Row(
            textDirection: TextDirection
                .ltr, // X-73: Cancel left, action right in both languages

            children: [
              Expanded(
                child: SizedBox(
                  height: 38.sp,
                  child: customButton(
                    title: S.current.crmDiscard,
                    function: onDiscard,
                    color: AppColors.lightGrey,
                    textStyle: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.blackButton,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: SizedBox(
                  height: 38.sp,
                  child: customButton(
                    title: isAddMode ? S.current.crmAdd : S.current.crmSave,
                    function: isEnabled ? onSave : () {},
                    color:
                        isEnabled ? AppColors.primary : AppColors.disabledGrey,
                    textStyle: StyleText.fontSize14Weight500.copyWith(
                      color: isEnabled ? AppColors.black : AppColors.darkGrey,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            textDirection: TextDirection
                .ltr, // X-73: Cancel left, action right in both languages

            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              customButton(
                title: S.current.crmDiscard,
                function: onDiscard,
                color: AppColors.lightGrey,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(width: 12.w),
              customButton(
                title: isAddMode ? S.current.crmAdd : S.current.crmSave,
                function: isEnabled ? onSave : () {},
                color: isEnabled ? AppColors.primary : AppColors.disabledGrey,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: isEnabled ? AppColors.black : AppColors.darkGrey,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
