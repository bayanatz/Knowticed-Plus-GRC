/// ***************************** FILE INFO ***************************** ///
/// File Name: champion_vision_text_field.dart
/// Purpose: Defines the dropdown field for selecting "Vision" in the Qiyas Create Control Champion form.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `ChampionVisionTextField` widget, which displays a dropdown for selecting a "Vision" in the
///              "Qiyas Create Control Champion" form. It updates the corresponding controller and allows for dynamic selection
///              of topics based on the selected vision.
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_app_dropdown.dart';

class ChampionVisionTextField extends StatelessWidget {
  ChampionVisionTextField({
    super.key,
    required this.index,
  });
  final QiyasCreateChampionControllerCubit controller = sl();
  final int index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8.sp,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'المنظور',
                style: StyleText.fontSize14Weight400.copyWith(height: 1.2),
              ),
            ],
          ),
          AppDropdown(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء اختيار المنظور';
                }
                return null;
              },
              value: controller.visionControllersList[index].text.isNotEmpty
                  ? controller.visionControllersList[index].text
                  : null,
              height: 38.sp,
              fillColor: AppColors.background,
              // hintColor: Colors.red,   // ← add this
              onChanged: (value) {
                controller.visionControllersList[index].text = value!;
                controller.clearTopicControllerIndex(index);
                controller.clearCriteriationControllerIndex(index);
                controller.clearDocumentControllerIndex(index);
                controller.clearDateControllerIndex(index);
                controller.emitState(VisionsDataChanged());
              },
              items: controller
                  .uniqueVisionNames()
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            Text(e,
                                textAlign: TextAlign.right,
                                style: StyleText.fontSize14Weight400
                                    .copyWith(color: AppColors.secondaryBlack)
                                    .copyWith()),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
              hintText: 'اختر المنظور',
              textButton:
                  controller.visionControllersList[index].text.isNotEmpty
                      ? controller.visionControllersList[index].text
                      : null),
        ],
      ),
    );
  }
}
