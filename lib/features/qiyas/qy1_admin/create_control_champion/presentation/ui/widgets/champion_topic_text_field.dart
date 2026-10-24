/// ***************************** FILE INFO ***************************** ///
/// File Name: champion_topic_text_field.dart
/// Purpose: Defines the dropdown field for selecting "Topic" in the Qiyas Create Control Champion form.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `ChampionTopicTextField` widget, which displays a dropdown for selecting a "Topic" based on the
///              selected "Vision" in the "Qiyas Create Control Champion" form. It updates the corresponding controller and binds the
///              selected topics to the vision, allowing for dynamic topic selection based on the vision choice.
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

class ChampionTopicTextField extends StatelessWidget {
  ChampionTopicTextField({
    super.key,
    required this.index,
  });
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
            'المحور',
            style: StyleText.fontSize14Weight400.copyWith(height: 1.2),
          ),
          AppDropdown(
              value: controller.topicControllersList[index].text.isNotEmpty
                  ? controller.topicControllersList[index].text
                  : null,
              height: 38.sp,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء اختيار المحور';
                }
                return null;
              },
              fillColor: AppColors.background,
              onChanged: (value) {
                controller.topicControllersList[index].text = value!;
                controller.clearCriteriationControllerIndex(index);
                controller.clearDocumentControllerIndex(index);
                controller.clearDateControllerIndex(index);
                controller.emitState(VisionsDataChanged());
              },
              items: controller
                  .getTopicNames(
                      controller.visionControllersList[index].text, index)
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
                                    .copyWith(color: AppColors.secondaryBlack)),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
              hintText: 'اختر المحور',
              textButton: controller.topicControllersList[index].text.isNotEmpty
                  ? controller.topicControllersList[index].text
                  : null),
        ],
      ),
    );
  }
}
