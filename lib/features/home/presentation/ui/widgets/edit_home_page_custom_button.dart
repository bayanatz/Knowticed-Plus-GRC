/// ********************* FILE INFO ****************************
/// File Name: edit_home_page_custom_button.dart
/// Purpose: Custom buttons for editing home page with preview, save, and discard options
/// Author: Mohamed Elrashidy
/// Created at: 21/9/2025
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../controller/home_cubit.dart';
import '../pages/preview_page.dart';

class EditHomePageCustomButton extends StatelessWidget {
  const EditHomePageCustomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomButton(
              width: 150.w,

              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomePreview()));
              },
              buttonText: 'Preview'.tr,
            ),
            Spacer(),
            CustomButton(
              width: 150.w,
              onTap: () {
                context.read<AppHomeCubit>().updateHomeComponents();
              },
              buttonText: 'Save'.tr,
            )
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            CustomButton(
              width: 150.w,
              buttonText: 'Discard Changes'.tr,
              onTap: () {
                Navigator.of(context).pop();
              },
              buttonColor: AppColors.secondaryButton,
              textStyle: AppTextStyles.font16BlackRegularCairo,
            ),
          ],
        )
      ],
    );
  }
}
