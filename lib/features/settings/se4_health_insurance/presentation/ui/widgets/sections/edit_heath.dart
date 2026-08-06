///******************** FILE INFO ********************///
/// Purpose: Editable version of health insurance section
/// Author: Assistant
/// Created At: 2025
/// Updated: Editable fields for health insurance information with controllers passed from parent
import 'package:get/get.dart';

import 'package:flutter/cupertino.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/settings_header.dart';

import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class EditableHealthInsuranceSection extends StatelessWidget {
  // Controllers passed from parent
  final TextEditingController insuranceNameController;
  final TextEditingController insurancePolicyNumberController;

  const EditableHealthInsuranceSection({
    super.key,
    required this.insuranceNameController,
    required this.insurancePolicyNumberController,
  });

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.02.h),
          child: SettingsHeader(
            imagePath: 'assets/icons_assets/main_icons_assets/insurance_document_shield.svg',
            text: S.of(context).insuranceDetails,
          ),
        ),

        SizedBox(height: 15.sp),

        // Insurance Name and Policy Number Row
        isMobile
            ? Column(
          children: [
            CustomTextField(
              label: S.of(context).insuranceName,
              hint: S.of(context).enterInsuranceName,
              controller: insuranceNameController,
              fillColor: AppColors.background,
              enabled: true,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 16),
            CustomTextField(
              label: S.of(context).insurancePolicyNumber,
              hint: S.of(context).enterPolicyNumber,
              controller: insurancePolicyNumberController,
              fillColor: AppColors.card,
              enabled: true,
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: S.of(context).insuranceName,
                hint: S.of(context).enterInsuranceName,
                controller: insuranceNameController,
                fillColor: AppColors.card,
                enabled: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).insurancePolicyNumber,
                hint: S.of(context).enterPolicyNumber,
                controller: insurancePolicyNumberController,
                enabled: true,
                fillColor: AppColors.card,
              ),
            ),
          ],
        ),
      ],
    );
  }
}