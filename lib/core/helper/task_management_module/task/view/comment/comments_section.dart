import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:lottie/lottie.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_chat_textfield.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_comments_bottom_sheet.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_comments_card.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_container_header_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';

//App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives: this file represents the comments section for the task
///
class CommentsSection extends StatelessWidget {
  final CardModel cardModel;
  final String department;
  final String board;
  TextEditingController responseController = TextEditingController();

  CommentsSection({
    super.key,
    required this.cardModel,
    required this.department,
    required this.board,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    Get.put(TaskDetailsController());
    return GetBuilder<BoardController>(builder: (controller) {
      return Container(
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
              iconPath: "assets/icons_assets/task_assets/taskDeadline.svg",
              title: "Comments".tr,
              isComments: true,
              cardModel: cardModel,
              onArrowPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: BottomSheetWidget(
                      board: board,
                      cardModel: cardModel,
                      department: department,
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 0.015.h,
            ),
            cardModel.comments!.isEmpty
                ? Container(
                    //   color: Colors.red,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 0.02.h),
                        child: Column(
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Lottie.asset(
                                "assets/lottie_assets/main_lottie_assets/emptyBoardComments.json",
                                width: 0.15.w,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            SizedBox(
                              height: 0.02.h,
                            ),
                            Text(
                              'No Comments Available'.tr,
                              textAlign: TextAlign.center,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: FontConstants.fontSize020.h,
                                fontWeight: FontWeight.w600,
                                color: AppColors.colorGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 0.21.h,
                    child: ListView.builder(
                      itemCount: cardModel.comments!.length > 1
                          ? 2
                          : cardModel.comments!.isNotEmpty
                              ? 1
                              : 0,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding:
                              EdgeInsets.only(bottom: index == 5 ? 0 : 0.015.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // To Display All Comments Of The Card
                              CustomCommentsContainer(
                                description:
                                    cardModel.comments![index].comment!.last,
                                startTime:
                                    cardModel.comments![index].timestamp!.last,
                                name: controller.empFullName(
                                  cardModel
                                      .comments![index].commentCreator!.last,
                                ),
                                imagPath: controller.getSingleImage(
                                  cardModel
                                      .comments![index].commentCreator!.last,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            CustomCommentsTextField(
              hintText: 'Write a Comment'.tr,
              profileImage: controller.getSingleImage(
                  Get.find<MainCoreEmployeeController>().employeeEntity!.email!),
              onPressed: () {
                /// Update Card To Add New Comment To The Card
                controller
                    .updateCard(
                  board: board,
                  cardModel: cardModel,
                  comment: responseController.text,
                )
                    .then((value) {
                  responseController.clear();
                });
                print(responseController.text);
                // Action to perform when the send button is pressed
                hapticController.triggerHapticFeedback(
                    vibration: VibrateType.mediumImpact,
                    hapticFeedback: HapticFeedback.mediumImpact);
              },
              controller: responseController,
              onPressedImage: () {
                // Action to perform when the Image button is pressed
              },
            ),
          ],
        ),
      );
    });
  }
}
