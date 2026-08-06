import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
class FormActions extends StatelessWidget {
  FormActions({super.key, required this.model});
  HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    return StandardContainer(
        child: SizedBox(
      width: 140.sp,
      child: Column(
        spacing: 5.sp,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).forms,
                style: AppTextStyles.font14BlackCairoMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SvgPicture.asset(
                'assets/icons_assets/roles_assets/form_document.svg',
                width: 20,
                height: 20,
                color: AppColors.primary,
              )
            ],
          ),
          Container(),
          customButtonWithSvg(
              textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                  fontWeight: FontWeight.w500, color: AppColors.textButton),
              image: 'assets/icons_assets/roles_assets/form_document.svg',
              color: AppColors.primary,
              widthImage: 16.sp,
              heightImage: 16.sp,
              colorBorder: Colors.transparent,
              title: S.of(context).createForm,
              function: () {}),
          customButton(
              textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                  fontWeight: FontWeight.w500, color: AppColors.textButton),
              title: S.of(context).viewDraftForm,
              function: () {}),
          customButton(
              textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                  fontWeight: FontWeight.w500, color: AppColors.textButton),
              title: S.of(context).viewRequestedForm,
              function: () {}),
        ],
      ),
    ));
  }
}
