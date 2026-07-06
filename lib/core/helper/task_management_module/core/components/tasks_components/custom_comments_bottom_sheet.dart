import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_chat_textfield.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_comments_card.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';

class BottomSheetWidget extends StatefulWidget {
  final CardModel cardModel;
  final String department;
  final String board;

  const BottomSheetWidget(
      {super.key,
      required this.cardModel,
      required this.department,
      required this.board});
  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  TextEditingController responseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(TaskDetailsController());

    final TextStyle titleStyle = AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: FontConstants.fontSize020.h,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.inverseSurface,
        height: 1.6);

    return GetBuilder<BoardController>(builder: (controller) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    "Comments".tr,
                    style: titleStyle,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Transform.scale(
                      scale: 1.2,
                      child: SvgPicture.asset(
                        "assets/icons_assets/task_assets/xClose.svg",
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 0.015.h,
              ),
              /* Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.cardModel.comments!.map(
                  (e) =>  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       CustomCommentsContainer(
                      description: e.comment!.last,
                      startTime: e.timestamp!.last,
                      name:controller.empFullName(e.commentCreator!.last,),
                      imagPath: controller.getSingleImage( e.commentCreator!.last,),
                    ),
                    ],
                  )
                  ).toList(),
               ),*/

              SizedBox(
                height: 0.59.h,
                child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  //physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.cardModel.comments!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding:
                          EdgeInsets.only(bottom: index == 5 ? 0 : 0.015.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCommentsContainer(
                            description:
                                widget.cardModel.comments![index].comment!.last,
                            startTime: widget
                                .cardModel
                                .comments![index]
                                .timestamp!
                                .last, // '24 Jan 2024 at 12 : 00 PM ',
                            name: controller.empFullName(
                              widget.cardModel.comments![index].commentCreator!
                                  .last,
                            ),
                            imagPath: controller.getSingleImage(
                              widget.cardModel.comments![index].commentCreator!
                                  .last,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // const Spacer(),
              CustomCommentsTextField(
                hintText: 'Write a Comment'.tr,
                profileImage: controller.getSingleImage(
                  Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
                ),
                onPressed: () {
                  controller
                      .updateCard(
                    board: widget.board,
                    cardModel: widget.cardModel,
                    comment: responseController.text,
                  )
                      .then((value) {
                    responseController.clear();
                  });
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
        ),
      );
    });
  }

/*
@override
  void dispose() {
    responseController.dispose();
    super.dispose();
  }*/
}
