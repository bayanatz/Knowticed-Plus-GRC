import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_font_size.dart';

/// Date Created :14/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives: this widget is for showing the meeting or task name, description and start time for each one in addition to images of the participants and the total number of the members enrolled in this event

class CustomCreateBoardContainer extends StatefulWidget {
  const CustomCreateBoardContainer({
    super.key,
  });

  @override
  State<CustomCreateBoardContainer> createState() =>
      _CustomCreateBoardContainerState();
}
/*
final List<String> department = [
  'Marketing'.tr,
  'Design'.tr,
  'ui UX'.tr,
];
*/

String? selectedDepartment;
String? selectedDepartmentValue;

class _CustomCreateBoardContainerState
    extends State<CustomCreateBoardContainer> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  //TaskController tController = Get.find();

  @override
  void initState() {
    selectedDepartment = null;
    selectedDepartmentValue = null;
    // tController.imageUrl = "";
    super.initState();
  }

  bool switchValue3 = false;
  @override
  bool isAllChecked = false;
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    bool isNotEmpty(TextEditingController controller) {
      return controller.text.isNotEmpty;
    }

    bool isNotEmptyString(String? value) {
      return value != null && value.isNotEmpty;
    }

    if (isNotEmpty(descriptionController) &&
        isNotEmpty(nameController) &&
        isNotEmptyString(selectedDepartment)) {
      isAllChecked = true;
    } else {
      isAllChecked = false;
    }

    bool isButtonEnabled = isAllChecked;
    double imageHight = 0.03.h;
    double space = 0.015.h;
    return Container();
    /* GetBuilder<TaskController>(
      builder: (taskController) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(vertical: 0.01.h, horizontal: 0.025.w),
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
                      taskController.uploadImage("board_images");
                    },
                    child: Stack(
                      children: <Widget>[
                        taskController.imageUrl == ""
                            ? CircleAvatar(
                                radius: 0.04.h,
                                backgroundColor: AppColors.barrierColor,
                                child: Center(
                                  child: Transform.scale(
                                      scale: isTablet ? 1.2 : 0.8,
                                      child: SvgPicture.asset(
                                          "assets/icons_assets/main_icons_assets/pic.svg")),
                                ),
                              )
                            : CircleAvatar(
                                radius: 0.085.w,
                                backgroundColor: AppColors.barrierColor,
                                child: Center(
                                  child: Transform.scale(
                                    scale: 1.2,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        taskController.imageUrl,
                                      ),
                                      radius: 0.06.h,
                                    ),
                                  ),
                                ),
                              ),
                        if (taskController.imageUrl == "")
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Transform.scale(
                                scale: 1.5,
                                child: CircleAvatar(
                                    backgroundColor: AppColors.signOut,
                                    radius: 0.01.h,
                                    child: SvgPicture.asset(
                                      "assets/icons_assets/main_icons_assets/CameraIcon.svg",
                                      color: AppColors.textButton,
                                      height: 0.015.h,
                                    )),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: space),
                  ColumnRequestData(
                    fillColor:
                        themeController.currentTheme == AppColors.lightTheme
                            ? AppColors.colorLightGrey
                            : AppColors.colorBlack,
                    title: "Board Name",
                    isTextField: true,
                    hint: "Enter Board Name",
                    isOptional: false,
                    isExpanded: true,
                    hasPrefix: true,
                    textController: nameController,

                    // textController: widget.isGroupEdit == true
                    //     ? null
                    //     : desciption,

                    controllerState: (value) {
                      setState(() {
                      });
                    },
                    maxlength: 120,
                  ),
                  SizedBox(
                    height: 0.015.h,
                  ),
                  Text(
                    "Department".tr,
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: isTablet
                            ? FontConstants.fontSize022.h
                            : FontConstants.fontSize018.h,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.inverseSurface,
                        height: 1.6),
                  ),
                  CustomDropdownButton2(
                    buttonPadding: EdgeInsets.symmetric(horizontal: 0.02.w),
                    iconHeight: 0.022.h,
                    //borded: true,

                    buttonWidth: double.infinity,

                    dropdownWidth: 0.865.w,
                    buttonHeight: 0.047.h,
                    isBottomSheet: true,
                    hint: 'Select Department'.tr,
                    dropdownItems: Get.locale.toString().contains('en')
                        ? Get.find<AddDepartmentController>()
                            .departmentsEnglishName
                        : Get.find<AddDepartmentController>()
                            .departmentsArabicName,
                    value: selectedDepartment,
                    onChanged: (String? value) {
                      setState(() {
                        selectedDepartmentValue =
                            Get.locale.toString().contains('en')
                                ? value!.toLowerCase()
                                : addDepartmentController
                                    .getDepartmentEnglishNameFromArabicName(
                                        arabicName: value!);

                        selectedDepartment = value;
                      });
                    },
                  ),
                  SizedBox(
                    height: 0.015.h,
                  ),
                  ColumnRequestData(
                    title: "Description",
                    isTextField: true,
                    fillColor:
                        themeController.currentTheme == AppColors.lightTheme
                            ? AppColors.colorLightGrey
                            : AppColors.colorBlack,
                    hint: "Enter Board Description",
                    isOptional: false,

                    textController: descriptionController,
                    isExpanded: true,
              isDescription: true,
                    // textController: widget.isGroupEdit == true
                    //     ? null
                    //     : desciption,
                    maxlines: 2,

                    controllerState: (value) {
                      setState(() {
                      });
                    },
                    maxlength: 120,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.02.h),
                    child: DialogueSwitcher(
                        title: "Creating Messaging Channels",
                        subtitle:
                            "You Can Chat with Team Through Project Board",
                        switchValue: switchValue3,
                        switchValueState: (value) {
                          setState(() {
                            switchValue3 = value;
                          });
                        }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0.02.h),
              child: taskController.loading
                  ? const Center(child: CircleProgress())
                  : MainCustomButton(
                      buttonColor:
                          !isButtonEnabled ? AppColors.GreyBack : null,
                      buttonText: 'Create'.tr,
                      onPressed: isButtonEnabled
                          ? () {
                              hapticController.triggerHapticFeedback(
                                vibration: VibrateType.mediumImpact,
                                hapticFeedback: HapticFeedback.mediumImpact,
                              );

                              taskController
                                  .createBoard(
                                name: nameController.text,
                                description: descriptionController.text,
                                department: selectedDepartmentValue,
                                messaginChannel: switchValue3 ? "yes" : "no",
                                context: context,
                              )
                                  .then((value) {
                                setState(() {
                                  taskController.boards = [];
                                  taskController.boards.addAll(
                                      taskController.filterBoards("All"));
                                  taskController.selectedIndex = 0;
                                });
                              });
                            }
                          : () {},
                    ),
            ),
          ],
        );
      },
    );
  */
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
