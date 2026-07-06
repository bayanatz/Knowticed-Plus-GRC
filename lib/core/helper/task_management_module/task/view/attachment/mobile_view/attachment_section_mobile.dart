import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/copy_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/delete_archive_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_container_header_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_task_status_container.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/app_strings.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/image_paths.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/attachment/widgets/AttachmentButtonRow_widget.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/attachment/widgets/AttachmentList_widget..dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

//App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives: this file represents the  attachment section for showing the project detailes inside the board screen
// Name: Nour Nabil
// Data: 22/2/2025
// goal: refactor screen

class AttachmentSection extends StatelessWidget {
  final bool showAttach;
  final VoidCallback toggleShowAttach;
  final CardModel cardModel;
  final String board;
  final String department;

  AttachmentSection({
    super.key,
    required this.showAttach,
    required this.department,
    required this.toggleShowAttach,
    required this.cardModel,
    required this.board,
  });

  final TaskDetailsController controller = Get.put(TaskDetailsController());

  @override
  Widget build(BuildContext context) {
    controller.initializeAttachments(cardModel);
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Obx(() => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 0.025.h : 0.04.w, vertical: 0.015.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  height: 30.sp,
                  width: 30.sp,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  padding: EdgeInsets.all(6),
                  child: Center(
                    child: SvgPicture.asset(ImagePaths.getImagePath(context, 'AttachSquareIcon'),
                        height: 16.h, width: 16.w, color: AppColors.black),
                  )),
              SizedBox(width: 10),
              Text(
                "Attachments",
                style: AppTextStyles.font16BlackMediumCairo,
              ),
            ],
          ),
          // CustomRowWithIcons(
          //   iconPath: ImagePaths.getImagePath(context, 'AttachSquareIcon'),
          //   title: AppStrings.attachments.tr,
          //   isExpand: controller.expandAttach.value,
          //   onTrashPressed: toggleShowAttach,
          //   onArrowPressed: controller.toggleExpandAttach,
          // ),
          if (controller.expandAttach.value) ...[
            SizedBox(height: 0.015.h),
            AttachmentList(
                controller: controller, cardModel: cardModel, board: board),
            SizedBox(height: 0.015.h),
            AttachmentButtonRow(
              onAddItem: () => _showAddAttachmentDialog(context),
              onDeleteAll: () => _showDeleteAllDialog(context),
            ),
          ],
        ],
      ),
    ));
  }

  void _showAddAttachmentDialog(BuildContext context) {
    hapticController.triggerHapticFeedback(
        vibration: VibrateType.lightImpact,
        hapticFeedback: HapticFeedback.lightImpact);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CopyCardDialouge(
          title: AppStrings.addAttachment,
          onPressed: () {},
          isAttachment: true,
          cardModel: cardModel,
          board: board,
          department: department,
          iconUrl: ImagePaths.getImagePath(context, 'attachsquareIcon'),
        );
      },
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeletOrArchiveDialog(
          yesOnPressed: () {
            controller.deleteAllAttachments(cardModel, board);
          },
          isAttachment: true,
          isDelete: false,
        );
      },
    );
  }
}