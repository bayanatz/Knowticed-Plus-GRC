///******************** FILE INFO ********************///
/// Purpose: Editable version of health insurance section
/// Author: Assistant
/// Created At: 2025
/// Updated: Editable fields for health insurance information with controllers passed from parent

import 'package:flutter/cupertino.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/settings_header.dart';

import '../../../../../generated/l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../controller/settings_controller.dart';

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
    var isMobile = context.isPhone;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.02.h),
          child: SettingsHeader(
            imagePath: 'assets/icons_assets/main_icons_assets/Insurance Details.svg',
            text: S.of(context).insuranceDetails,
          ),
        ),

        SizedBox(height: 15.sp),

        // Insurance Name and Policy Number Row
        isMobile
            ? Column(
          children: [
            CustomTextField(
              label: 'Insurance Name'.tr,
              hint: 'Enter Insurance Name'.tr,
              controller: insuranceNameController,
              fillColor: AppColors.background,
              enabled: true,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 16),
            CustomTextField(
              label: S.of(context).insurancePolicyNumber,
              hint: 'Enter Policy Number'.tr,
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
                label: 'Insurance Name'.tr,
                hint: 'Enter Insurance Name'.tr,
                controller: insuranceNameController,
                fillColor: AppColors.card,
                enabled: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).insurancePolicyNumber,
                hint: 'Enter Policy Number'.tr,
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