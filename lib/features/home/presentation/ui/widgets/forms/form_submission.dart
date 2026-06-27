import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/widgets/standard_container.dart';
import 'package:demo_app/features/home/data/models/form_submissions_model.dart';
import 'package:percentages_with_animation/percentages_with_animation.dart';

import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart' show CustomButton;
import 'package:demo_app/features/home/core_widgets/main_widget/custom_icon_button.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

class FormSubmission extends StatelessWidget {
  FormSubmission({required this.model, super.key});
  FormSubmissionsModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 175.h,
      width: 300.sp,
      child: StandardContainer(
          child: Column(
        spacing: 8.sp,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).formSubmissions,
                style: AppTextStyles.font14BlackCairoMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SvgPicture.asset(
                'assets/skeleton/home/icons/form.svg',
                width: 20,
                height: 20,
                color: AppColors.primary,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).formName,
                  style: AppTextStyles.font12SecondaryBlackCairoRegular),
              CircularPercentage(
                currentPercentage: 50,
                maxPercentage: 100,
                size: 70.sp,
                duration: 2000,
                percentageStrokeWidth: 8.sp,
                percentageColor: Colors.green,
                backgroundColor: AppColors.greyIcon,
                backgroundStrokeWidth: 2.sp,
                centerTextStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                onCurrentValue: (currentValue) {},
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                  textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                      fontWeight: FontWeight.w500, color: AppColors.textButton),
                  buttonText: 'View Submissions'.tr,
                  onTap: () {}),
              CustomIconButton(
                  iconPath: 'assets/skeleton/home/icons/form_reminder.svg',
                  textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                      fontWeight: FontWeight.w500, color: AppColors.textButton),
                  buttonText: 'Remind All'.tr,
                  onTap: () {}),
            ],
          )
        ],
      )),
    );
  }
}
