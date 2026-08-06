import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
class ScheduleMessage extends StatelessWidget {
  ScheduleMessage({required this.model, super.key});
  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    var l = S.of(context);
    return StandardContainer(
        child: SizedBox(
          width: 140.sp,
          child: Column(
            spacing: 10.sp,
            children: [
              Text(
                l.scheduleMessage,
                style: AppTextStyles.font14BlackCairoMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                spacing: 5.sp,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.forGroup,
                    style: AppTextStyles.font14BlackCairoRegular
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  customButton(
                    title: l.createNew,
                    textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textButton,
                    ),
                    function: () {},)
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5.sp,
                children: [
                  Text(
                    l.forDirectMessage,
                    style: AppTextStyles.font14BlackCairoRegular
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  customButton(
                    title: l.createNew,
                    textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textButton,
                    ),
                    function: () {},)
                ],
              ),
            ],
          ),
        ));
  }
}