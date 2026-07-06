import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';

import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/main_yellow_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';

/// Date Created :14/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :19/November/2023 By Bassem
/// Objectives: this widget is for showing the meeting or task name, description and start time for each one in addition to images of the participants and the total number of the members enrolled in this event

double height = 0.015.h;

class CustomCreateTaskContainer extends StatefulWidget {
  final bool isProject;
  final String currentBoardName;
  final void Function() onPressed;

  const CustomCreateTaskContainer({
    super.key,
    this.isProject = false,
    required this.onPressed,
    required this.currentBoardName,
  });

  @override
  State<CustomCreateTaskContainer> createState() =>
      _CustomCreateTaskContainerState();
}

final List<String> notify = [
  '10 Minutes Before'.tr,
  '30 Minutes Before'.tr,
  '1 Hour Before'.tr,
];

String? selectedNotify = '10 Minutes Before'.tr;

final List<String> attend = [
  'Yes'.tr,
  'No'.tr,
  'Maybe'.tr,
];

String? selectedAnswer = 'Yes'.tr;

class _CustomCreateTaskContainerState extends State<CustomCreateTaskContainer> {
  TextEditingController cardNameController = TextEditingController();
  TextEditingController cardDescriptionController = TextEditingController();
  //TaskController taskController = Get.find();

  TextStyle customTitleTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: FontConstants.fontSize018.h,
      // ignore: unrelated_type_equality_checks
      color: themeController.currentTheme == AppColors.lightTheme
          ? AppColors.colorBlack
          : AppColors.colorWhiteDark,
      fontWeight: FontWeight.w600,
      height: 1.8);
  TextStyle customSubTitleTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
    fontSize: FontConstants.fontSize016.h,
    // ignore: unrelated_type_equality_checks
    color: themeController.currentTheme == AppColors.lightTheme
        ? AppColors.colorDarkGrey
        : AppColors.colorGreydark,
    fontWeight: FontWeight.w400,
    height: 0.0016.h,
  );
  @override
  Widget build(BuildContext context) {
    Get.put(TaskDetailsController());
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return GetBuilder<BoardController>(builder: (tController) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                vertical: widget.isProject == false ? 0.02.h : 0.01.h,
                horizontal: widget.isProject == false ? 0.025.w : 0),
            decoration: BoxDecoration(
              // ignore: unrelated_type_equality_checks
              color: isTablet
                  ? themeController.currentTheme == AppColors.lightTheme
                      ? AppColors.colorLightGrey
                      : AppColors.darkBackGround
                  : Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //SvgPicture.asset("assets/icons_assets/main_icons_assets/imagePickerPhoto.svg"),
                InkWell(
                  onTap: () {
                    tController.uploadImage("card_images");
                  },
                  child: Stack(
                    children: <Widget>[
                      tController.imageUrl == ""
                          ? CircleAvatar(
                              radius: 0.08.w,
                              backgroundColor: AppColors.barrierColor,
                              child: Center(
                                child: Transform.scale(
                                    scale: 1.2,
                                    child: SvgPicture.asset(
                                        "assets/icons_assets/main_icons_assets/imagePickerPhoto.svg")),
                              ),
                            )
                          : CircleAvatar(
                              radius: 0.08.w,
                              backgroundColor: AppColors.barrierColor,
                              child: Center(
                                child: Transform.scale(
                                  scale: 1.2,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      tController.imageUrl,
                                    ),
                                    radius: 0.06.h,
                                  ),
                                ),
                              ),
                            ),
                      if (tController.imageUrl != "")
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Transform.scale(
                              scale: 1.2,
                              child: SvgPicture.asset(
                                  "assets/icons_assets/task_assets/photo_picker2.svg"),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(
                  height: height,
                ),
                ColumnRequestData(
                  fillColor: Colors.transparent,
                  title: widget.isProject == true ? "Card Name" : "Task Name",
                  isRequired: true,
                  isTextField: true,
                  hint: "Text here",
                  isOptional: false,
                  isExpanded: true,
                  hasPrefix: true,
                  textController: cardNameController,
                  // textController: widget.isGroupEdit == true
                  //     ? null
                  //     : desciption,

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
                  maxlength: 120,
                ),
              ],
            ),
          ),
          if (widget.isProject == false)
            Padding(
              padding: EdgeInsets.only(top: 0.03.h),
              child: ReusableElevatedButton(
                buttonText: 'Create'.tr,
                onPressed: () {
                  hapticController.triggerHapticFeedback(
                    vibration: VibrateType.mediumImpact,
                    hapticFeedback: HapticFeedback.mediumImpact,
                  );
                  tController.createCard(
                      name: cardNameController.text,
                      description: cardDescriptionController.text,
                      currentBoardName: widget.currentBoardName,
                      context: context);
                  setState(() {});
                },
              ),
            ),
        ],
      );
    });
  }
}
