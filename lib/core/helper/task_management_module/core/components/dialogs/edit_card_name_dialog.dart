// Date Created :16/April/2024
// Developer Name : Abdullah Ibrahim
//App Version : Version 2
// Objectives: Edit card name and description dialog.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/screen_size.dart';

import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_create_task_container.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/main_yellow_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_container_header_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';

class EditCardDetailsDialouge extends StatefulWidget {
  EditCardDetailsDialouge({
    super.key,
    required this.title,
    this.taskName,
    this.taskDescription,
    required this.onPressed,
    this.textController,
    this.board,
    this.cardModel,
  });

  final String title;
  final String? taskName;
  final String? taskDescription;

  final String? board;
  final CardModel? cardModel;
  final void Function() onPressed;
  TextEditingController? textController;
  @override
  State<EditCardDetailsDialouge> createState() =>
      _EditCardDetailsDialougeState();
}

class _EditCardDetailsDialougeState extends State<EditCardDetailsDialouge> {
  TextEditingController cardNameController = TextEditingController();
  TextEditingController cardDescriptionController = TextEditingController();
  TaskDetailsController taskController = Get.find();
  String? listValue;

  final HapticController hapticController = Get.put(HapticController());

  TextEditingController titleCont = TextEditingController();

  @override
  initState() {
    if (widget.taskName != null) {
      cardNameController.text = widget.taskName!;
    }
    if (widget.taskDescription != null) {
      cardDescriptionController.text = widget.taskDescription!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return GetBuilder<TaskDetailsController>(
      builder: (controller) {
        return Dialog(
          insetPadding:
              EdgeInsets.symmetric(horizontal: isTablet ? 0.33.w : 0.04.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            /* height:isTablet
                        ? 0.45.h
                        : 0.40.h,*/
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 0.015.w : 0.04.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.01.h),
                      child: CustomRowWithIcons(
                        iconPath: "assets/icons_assets/task_assets/editIconReq.svg",
                        title: widget.title.tr,
                        hideDelete: true,
                        onArrowPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    if (widget.taskName != null)
                      ColumnRequestData(
                        fillColor: Colors.transparent,
                        title: "Task Name",
                        isRequired: true,
                        isTextField: true,
                        hint: "Text here",
                        isOptional: false,
                        isExpanded: true,
                        hasPrefix: true,
                        textController: cardNameController,
                        controllerState: (value) {
                          setState(() {
                            print('value description ${value!}');
                          });
                        },
                        maxlength: 120,
                      ),
                    SizedBox(
                      height: height,
                    ),
                    if (widget.taskDescription != null)
                      ColumnRequestData(
                        title: "Description",
                        isTextField: true,
                        hint: "Text here",
                        isOptional: false,
                        isExpanded: true,
                        isSetting: true,
                        textController: cardDescriptionController,
                        // textController: widget.isGroupEdit == true
                        //     ? null
                        //     : desciption,
                        maxlines: 2,
                        controllerfinishState: (value) {},

                        controllerState: (value) {
                          setState(() {
                            print('value description ${value!}');
                          });
                        },
                        maxlength: 500,
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: 0.02.h),
                      child: Padding(
                        padding: EdgeInsets.only(top: 0.0.h),
                        child: ReusableElevatedButton(
                          buttonText: 'Save'.tr,
                          onPressed: () async {
                            widget.onPressed();
                            hapticController.triggerHapticFeedback(
                                vibration: VibrateType.heavyImpact,
                                hapticFeedback: HapticFeedback.heavyImpact);

                            if (widget.taskDescription != null &&
                                controller.isFieldValid(
                                    cardDescriptionController.text)) {
                              await controller.updateCard(
                                cardModel: widget.cardModel!,
                                board: widget.board!,
                                cardDescription: cardDescriptionController.text,
                              );
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SuccessDialog(
                                    title: "Successful".tr,
                                    subtitle:
                                        "Card Description Updated Successfully"
                                            .tr,
                                    lottieAsset: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                                  );
                                },
                              );
                            } else if (widget.taskName != null &&
                                controller
                                    .isFieldValid(cardNameController.text)) {
                              await controller.updateCard(
                                cardModel: widget.cardModel!,
                                board: widget.board!,
                                cardName: cardNameController.text,
                              );
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SuccessDialog(
                                    title: "Successful".tr,
                                    subtitle:
                                        "Card Name Updated Successfully".tr,
                                    lottieAsset: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                                  );
                                },
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return const SuccessDialog(
                                    title: "Failure",
                                    subtitle: "Please Fill The Field",
                                    lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                                  );
                                },
                              );
                            }

                            setState(() {});
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
