import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/main_yellow_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/filters_appbar.dart';

class AddCardDialog extends StatefulWidget {
  const AddCardDialog({
    super.key,
    required this.board,
  });
  final String board;
  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  TaskDetailsController taskController = Get.put(TaskDetailsController());
  late TextEditingController cardDesciption;
  late TextEditingController cardName;

  @override
  void initState() {
    taskController.imageUrl = "";
    cardDesciption = TextEditingController();
    cardName = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(BoardController());
    return GetBuilder<BoardController>(
      builder: (controller) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: 0.3.w,
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            height: 0.74.h,
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 0.02.w, vertical: 0.015.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FiltersAppBar(
                      imageUrl: "assets/icons_assets/task_assets/create_board.svg",
                      title: "Add Card"),
                  // SvgPicture.asset("assets/icons_assets/main_icons_assets/imagePickerPhoto.svg"),
                  InkWell(
                    onTap: () {
                      controller.uploadImage("card_images");
                    },
                    child: Stack(
                      children: <Widget>[
                        controller.imageUrl == ""
                            ? CircleAvatar(
                                radius: 0.035.w,
                                backgroundColor: AppColors.barrierColor,
                                child: Center(
                                  child: Transform.scale(
                                      scale: 1.3,
                                      child: SvgPicture.asset(
                                          "assets/icons_assets/main_icons_assets/imagePickerPhoto.svg")),
                                ),
                              )
                            : CircleAvatar(
                                radius: 0.035.w,
                                backgroundColor: AppColors.barrierColor,
                                child: Center(
                                  child: Transform.scale(
                                    scale: 1.2,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        controller.imageUrl,
                                      ),
                                      radius: 0.06.h,
                                    ),
                                  ),
                                ),
                              ),
                        if (controller.imageUrl != "")
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Transform.scale(
                                scale: 1.5,
                                child: SvgPicture.asset(
                                    "assets/icons_assets/task_assets/photo_picker2.svg"),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 0.015.h,
                  ),
                  ColumnRequestData(
                    fillColor: Colors.transparent,
                    title: "Card Name",
                    isRequired: true,
                    isTextField: true,
                    hint: "Text here",
                    isOptional: false,
                    isExpanded: true,
                    hasPrefix: true,
                    textController: cardName,
                    controllerfinishState: (value) {
                      setState(() {});
                    },
                    controllerState: (value) {
                      setState(() {
                        print('value description ${value!}');
                      });
                    },
                    maxlength: 120,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.015.h),
                    child: ColumnRequestData(
                      title: "Description",
                      isTextField: true,
                      hint: "Text here",
                      isOptional: false,
                      isExpanded: true,
                      isSetting: true,
                      maxlines: 2,
                      maxlength: 120,
                      textController: cardDesciption,
                      controllerfinishState: (value) {
                        setState(() {});
                      },
                      controllerState: (value) {
                        setState(() {
                          print('value description ${value!}');
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.03.h),
                    child: ReusableElevatedButton(
                      buttonText: 'Add'.tr,
                      onPressed: () {
                        controller.createCard(
                            name: cardName.text,
                            description: cardDesciption.text,
                            currentBoardName: widget.board.capitalize!,
                            context: context);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    cardDesciption.dispose();
    cardName.dispose();
    super.dispose();
  }
}
