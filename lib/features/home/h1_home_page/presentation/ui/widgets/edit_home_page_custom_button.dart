/// ********************* FILE INFO ****************************
/// File Name: edit_home_page_custom_button.dart
/// Purpose: Custom buttons for editing home page with preview, save, and discard options
/// Author: Amr Mesbah
/// Created at: 21/9/2025
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/pages/preview_page.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/generated/l10n.dart';
class EditHomePageCustomButton extends StatelessWidget {
  const EditHomePageCustomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            customButton(
              width: 150.w,

              function: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomePreview()));
              },
              title: S.of(context).preview,),
            Spacer(),
            customButton(
              width: 150.w,
              function: () {
                context.read<AppHomeCubit>().updateHomeComponents();
              },
              title: S.of(context).Save,)
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            customButton(
              width: 150.w,
              title: S.of(context).discardChange,
              function: () {
                Navigator.of(context).pop();
              },
              color: AppColors.secondaryButton,
              textStyle: AppTextStyles.font16BlackRegularCairo,),
          ],
        )
      ],
    );
  }
}
