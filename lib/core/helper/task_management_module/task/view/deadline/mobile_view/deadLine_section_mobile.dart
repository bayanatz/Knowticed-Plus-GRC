import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_container_header_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/app_strings.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/image_paths.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/theme/app_colors.dart';

// Name: Nour Nabil
// role: refactor code
// last update date: 19/2
class DeadlineContainer extends StatelessWidget {
  final bool showDates;
  final CardModel cardModel;
  final String board;
  final VoidCallback toggleShowMembers;

  DeadlineContainer({
    super.key,
    required this.showDates,
    required this.toggleShowMembers,
    required this.cardModel,
    required this.board,
  });

  final TaskDetailsController controller = Get.put(TaskDetailsController());

  @override
  Widget build(BuildContext context) {
    controller.initializeDates(cardModel);
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return cardModel.startDate!.startDate!.isNotEmpty
        ? Obx(() => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 0.025.h : 0.04.w, vertical: 0.015.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomRowWithIcons(
                    iconPath: ImagePaths.getImagePath(context, 'taskDeadline'),
                    title: AppStrings.taskDeadline.tr,
                    isDate: true,
                    isExpand: controller.expandDates.value,
                    board: board,
                    cardModel: cardModel,
                    onArrowPressed: controller.toggleExpandDates,
                  ),
                  if (controller.expandDates.value) ...[
                    SizedBox(height: 0.015.h),
                    _buildDateTimeRow(
                        AppStrings.startDate,
                        controller.hintStartDate,
                        controller.startTimeHint,
                        isTablet,
                        context),
                    SizedBox(height: 0.015.h),
                    _buildDateTimeRow(
                        AppStrings.endDate,
                        controller.hintEndDate,
                        controller.endTimeHint,
                        isTablet,
                        context),
                    SizedBox(height: 0.01.h),
                  ]
                ],
              ),
            ))
        : const SizedBox();
  }

  Widget _buildDateTimeRow(String dateTitle, String dateHint, String timeHint,
      bool isTablet, context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ColumnRequestData(
            fillColor: AppColors.colorLightGrey,
            title: dateTitle.tr,
            isTextField: true,
            hint: dateHint,
            isOptional: false,
            isExpanded: true,
            enabled: false,
            hasPrefix: true,
            hasSuffix: true,
            suffixUrl: ImagePaths.getImagePath(context, 'calendar2'),
          ),
        ),
        SizedBox(width: isTablet ? 0.04.h : 0.04.w),
        Expanded(
          child: ColumnRequestData(
            fillColor: AppColors.colorLightGrey,
            title: "",
            isTextField: true,
            hint: timeHint,
            isOptional: false,
            enabled: false,
            isExpanded: true,
            hasPrefix: true,
            hasSuffix: true,
            suffixUrl: ImagePaths.getImagePath(context, 'calendar2'),
          ),
        ),
      ],
    );
  }
}
