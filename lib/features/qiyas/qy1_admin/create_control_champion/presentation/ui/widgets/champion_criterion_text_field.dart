/// ***************************** FILE INFO ***************************** ///
/// File Name: champion_criterion_text_field.dart
/// Purpose: Defines a custom widget for displaying a dropdown for selecting a "criterion" in the Qiyas control champion creation form.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `ChampionCriterionTextField` widget, which is used for rendering a dropdown
///              for selecting a criterion in the "Qiyas Create Control Champion" form. The widget integrates with the
///              `QiyasCreateControlChampionController` to manage state and handles the selection of criterion values
///              based on the topic selected. It also includes ui adjustments for different screen sizes and themes (light/dark).
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

class ChampionCriterionTextField extends StatelessWidget {
  ChampionCriterionTextField({super.key, required this.index});
  final QiyasCreateChampionControllerCubit controller = sl();
  final int index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.sp,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'المعيار',
            style: StyleText.fontSize14Weight400.copyWith(height: 1.2),
          ),
          AppDropdown(
              value: controller.criterionControllersList[index].text.isNotEmpty
                  ? controller.criterionControllersList[index].text
                  : null,
              height: 38.sp,
              fillColor: AppColors.background,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء اختيار المعيار';
                }
                return null;
              },
              onChanged: (value) {
                controller.criterionControllersList[index].text = value!;
                controller.clearDocumentControllerIndex(index);
                controller.clearDateControllerIndex(index);
                controller.emitState(VisionsDataChanged());
              },
              items: controller
                  .getCriterionNames(
                      addControllerIndex: index,
                      topicName: controller.topicControllersList[index].text,
                      visionName: controller.visionControllersList[index].text)
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e,
                                textAlign: TextAlign.right,
                                softWrap: true,
                                style: StyleText.fontSize14Weight400
                                    .copyWith(color: AppColors.secondaryBlack)
                                    .copyWith(height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
              menuItemHeight: 90.sp,
              hintText: 'اختر المعيار',
              textButton:
                  controller.criterionControllersList[index].text.isNotEmpty
                      ? controller.criterionControllersList[index].text
                      : null),
        ],
      ),
    );
  }
}
