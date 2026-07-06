import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:lottie/lottie.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_chat_textfield.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_comments_card.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/theme/app_colors.dart';

class CommentsSectionTablet extends StatefulWidget {
  final CardModel cardModel;
  final String department;
  final String board;

  const CommentsSectionTablet(
      {super.key,
      required this.cardModel,
      required this.department,
      required this.board});

  @override
  State<CommentsSectionTablet> createState() => _CommentsSectionTabletState();
}

class _CommentsSectionTabletState extends State<CommentsSectionTablet> {
  @override
  Widget build(BuildContext context) {
    Get.put(TaskDetailsController());

    TextEditingController responseController = TextEditingController();
    return GetBuilder<BoardController>(
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.02.h),
          child: Container(
            //     color: Colors.yellow,
            //  width: 0.35.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0.01.h),
                  child: Text(
                    "Comments".tr,
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: FontConstants.fontSize030.h,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.02.h),
                  child: SizedBox(
                    height: 0.7.h,
                    child: widget.cardModel.comments!.isEmpty
                        ? Container(
                            //   color: Colors.red,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 0.14.h),
                                child: Column(
                                  children: [
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Lottie.asset(
                                        "assets/lottie_assets/main_lottie_assets/emptyBoardComments.json",
                                        width: 0.15.w,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                    Text(
                                      'No Comments Available'.tr,
                                      textAlign: TextAlign.center,
                                      style: AppFontStyle.cairoRegularStyle
                                          .copyWith(
                                        fontSize: FontConstants.fontSize025.h,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.colorGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            //physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.cardModel.comments!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 0.015.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomCommentsContainer(
                                      description: widget.cardModel
                                          .comments![index].comment!.last,
                                      startTime: widget
                                          .cardModel
                                          .comments![index]
                                          .timestamp!
                                          .last, // '24 Jan 2024 at 12 : 00 PM ',
                                      name: controller.empFullName(
                                        widget.cardModel.comments![index]
                                            .commentCreator!.last,
                                      ),
                                      imagPath: controller.getSingleImage(
                                        widget.cardModel.comments![index]
                                            .commentCreator!.last,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.01.h),
                  child: SizedBox(
                    height: 0.065.h,
                    child: CustomCommentsTextField(
                      hintText: 'Write a Comment'.tr,
                      onPressed: () {
                        // Action to perform when the send button is pressed
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.mediumImpact,
                            hapticFeedback: HapticFeedback.mediumImpact);
                        controller
                            .updateCard(
                          board: widget.board,
                          cardModel: widget.cardModel,
                          comment: responseController.text,
                        )
                            .then((value) {
                          responseController.clear();
                        });
                      },
                      controller: responseController,
                      onPressedImage: () {
                        // Action to perform when the Image button is pressed
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
