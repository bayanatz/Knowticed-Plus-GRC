// ****************** FILE INFO ******************
// File Name: crm_template_options_editor.dart
// Purpose: Shared CRM template choice option editor
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmTemplateOptionsEditor extends StatelessWidget {
  const CrmTemplateOptionsEditor({
    required this.model,
    required this.onChanged,
    required this.readOnly,
    this.title,
    this.infoMessage,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final VoidCallback onChanged;
  final bool readOnly;
  final String? title;
  final String? infoMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (infoMessage != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title ?? S.current.crmChoices,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.black,
                ),
              ),
              SizedBox(width: 8.sp),
              Tooltip(
                message: infoMessage!,
                child: CustomSvgImage(
                  assetPath: AppAssets.crmInfo,
                  width: 16.sp,
                  height: 16.sp,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sp),
        ],
        for (int i = 0; i < model.options.length; i++) ...[
          _buildOptionItem(context, model.options[i], i),
          SizedBox(height: 16.sp),
        ],
        if (!readOnly) ...[
          customButtonWithSvg(
            title: title ?? S.current.crmChoose,
            function: () {
              model.addOption();
              onChanged();
            },
            textStyle: StyleText.fontSize12Weight400
                .copyWith(color: AppTheme.readableOn(AppColors.blackButton))
                .copyWith(
                  color: AppTheme.readableOn(AppColors.blackButton),
                  fontWeight: FontWeight.bold,
                ),
            color: AppColors.blackButton,
            image: AppAssets.crmPlusBold,
            widthImage: 14.sp,
            heightImage: 14.sp,
            colorBorder: AppColors.transparent,
            svgColor: AppTheme.readableOn(AppColors.blackButton),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    CrmTemplateOptionEditModel option,
    int index,
  ) {
    final String optionLabel = title != null
        ? '$title ${index + 1}'
        : '${S.current.crmChoice} ${index + 1}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              optionLabel,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.black,
              ),
            ),
            if (!readOnly)
              GestureDetector(
                onTapDown: (_) => HapticController.high(),
                onTap: () {
                  model.removeOption(option);
                  onChanged();
                },
                child: CustomSvgImage(
                  assetPath: AppAssets.crmMinusSolid,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.sp),
        buildResponsiveFields(
          context: context,
          left: CustomTextField(
            controller: option.enController,
            hint: 'Text Here',
            readOnly: readOnly,
          ),
          right: Directionality(
            textDirection: TextDirection.rtl,
            child: CustomTextField(
              controller: option.arController,
              hint: 'اكتب هنا',
              textAlign: TextAlign.right,
              readOnly: readOnly,
            ),
          ),
        ),
      ],
    );
  }
}
