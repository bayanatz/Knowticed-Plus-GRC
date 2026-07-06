import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/borad/view/board_create/widget/employee_list_view.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_search.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/custom_drop_down_menu.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogue_switchers_row.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/main_yellow_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';

/// Date Created :14/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives: this widget is for showing the meeting or task name, description and start time for each one in addition to images of the participants and the total number of the members enrolled in this event

///update 26/02/2025 By Islam Diab
class CustomCreateBoardContainer extends StatefulWidget {
  final BoardModel? boardModel;
  const CustomCreateBoardContainer({
    super.key,
    this.boardModel,
  });

  @override
  State<CustomCreateBoardContainer> createState() =>
      _CustomCreateBoardContainerState();
}

String? selectedDepartment;
List<String> departmentsList = [];

class _CustomCreateBoardContainerState
    extends State<CustomCreateBoardContainer> {
  BoardController tController = Get.find();
  MainCoreDepartmentController addDepartmentController = Get.find();


  List<EmployeeEntityPro> searchEmployees = [];
  MainCoreEmployeeController addEmployeeController = Get.find();

  List<EmployeeUtils> selectedEmployees = [];

  void updateSelectedEmployees(List<EmployeeUtils> employees) {
    setState(() {
      selectedEmployees = employees;
      print('selectedEmployees: ${selectedEmployees.last.email}');
    });
  }

  @override
  void initState() {
    tController.imageUrl = "";
    tController.onSearchEmployee = false; // Ensure it's false at the beginning
    super.initState();
    searchEmployees = [];
  }

  bool switchValue3 = false;
  @override
  Widget build(BuildContext context) {

    TextEditingController descriptionController = TextEditingController(
      text: widget.boardModel?.boardDescription!.boardDescription!.last ?? '',
    );
    TextEditingController nameController = TextEditingController(
        text: widget.boardModel?.boardName!.boardgName!.last ?? '');
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    double space = 15.h;

    return GetBuilder<BoardController>(
      builder: (boardController) {
        void createBoard() {
          if (selectedEmployees.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select at least one employee')),
            );
            return;
          }

          log("Selected Employees: ${selectedEmployees.map((e) => e.email).join(', ')}");

          boardController
              .createBoard(
            members: selectedEmployees.map((e) => e.email).toList(), // Pass only IDs
            name: nameController.text,
            description: descriptionController.text,
            department: addDepartmentController.getDepartmentId(selectedDepartment ?? 'No selected'),
            messaginChannel: switchValue3 ? "yes" : "no",
            context: context,
          )
              .then(
                (value) {
              setState(() {
                boardController.boards = [];
                boardController.boards.addAll(boardController.filterBoards("All"));
                boardController.selectedIndex = 0;
              });
            },
          );
        }
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
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
                      boardController.uploadImage("board_images");
                    },
                    child: Stack(
                      children: <Widget>[
                        boardController.imageUrl == ""
                            ? CircleAvatar(
                                radius: 0.085.w,
                                backgroundColor: AppColors.barrierColor,
                                child: Center(
                                  child: Transform.scale(
                                      scale: 1.2,
                                      child: SvgPicture.asset(
                                          "assets/icons_assets/main_icons_assets/imagePickerPhoto.svg")),
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
                                        boardController.imageUrl,
                                      ),
                                      radius: 0.06.h,
                                    ),
                                  ),
                                ),
                              ),
                        if (boardController.imageUrl != "")
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
                  SizedBox(height: space),
                  ColumnRequestData(
                    title: "Board Name".tr,
                    isTextField: true,
                    hint: "Text here".tr,
                    isOptional: false,

                    isExpanded: true,
                    hasPrefix: true,
                    textController: nameController,

                    // textController: widget.isGroupEdit == true
                    //     ? null
                    //     : desciption,

                    // controllerState: (value) {
                    //   setState(() {
                    //     print('value description ${value!}');
                    //   });
                    // },
                    maxlength: 120,
                  ),

                  SizedBox(
                    height: 15.h,
                  ),
                  ColumnRequestData(
                    title: "Description".tr,
                    isTextField: true,
                    hint: "Text here".tr,
                    isOptional: false,
                    textController: descriptionController,
                    isExpanded: true,
                    isSetting: true,
                    // textController: widget.isGroupEdit == true
                    //     ? null
                    //     : desciption,
                    maxlines: 500,

                    controllerState: (value) {
                      setState(() {
                        print('value description ${value!}');
                      });
                    },
                    maxlength: 120,
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
                    buttonColor: Colors.transparent,
                    buttonWidth: double.infinity,
                    backColor: Colors.transparent,
                    dropdownWidth: 0.865.w,
                    buttonHeight: 0.047.h,
                    isBottomSheet: true,
                    hint: widget.boardModel?.boardDeparment!.boardgDepartment!
                            .last ??
                        'Choose Department'.tr,
                    dropdownItems: addDepartmentController.departmentModels
                        .map((e) => addDepartmentController
                            .containAbbreviation(e.departmentName ?? ''))
                        .toList(),
                    value: selectedDepartment,

                    onChanged: (String? value) {
                      setState(() {
                        selectedDepartment = value;
                        departmentsList.addIf(
                            !departmentsList.contains(value), value ?? '');
                      });
                    },
                  ),
                  SizedBox(
                    height: 9,
                  ),
                  if (departmentsList.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: departmentsList
                          .map((e) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: AppColors.colorLightGrey,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        e,
                                        style: AppFontStyle.cairoRegularStyle,
                                      ),
                                      SizedBox(
                                        width: 9,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            departmentsList.remove(e);
                                          });
                                        },
                                        child: SvgPicture.asset(
                                          'assets/icons/delete_attachment.svg',
                                          height: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    )
                  else
                    SizedBox.shrink(),
                  SizedBox(
                    height: 0.015.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.02.h),
                    child: DialogueSwitcher(
                      title: "Creating Messaging Channels",
                      switchValue: switchValue3,
                      switchValueState: (value) {
                        setState(() {
                          switchValue3 = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 0.015.h,
                  ),
                  Text(
                    "Employee  Information".tr,
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: isTablet
                            ? FontConstants.fontSize022.h
                            : FontConstants.fontSize018.h,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.inverseSurface,
                        height: 1.6),
                  ),
                  CustomSearchFiled2(
                    isSecondIcon: true,
                    fillColor: AppColors.colorLightGrey,
                    hint: "Search".tr,
                    hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize016.h,
                        color: Theme.of(context).colorScheme.tertiaryContainer),
                    keyBoardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        boardController.onSearchEmployee = true;
                        searchEmployees = boardController
                            .addEmployeeController.allEmployeesEntities!
                            .where((element) => element.firstName!
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    secondActionIcon: 'assets/icons/g4581.svg',
                    secondActionIconColor: AppColors.colorLightGrey,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  boardController.onSearchEmployee
                      // ? Text(
                      //     'data',
                      //     style: AppFontStyle.cairoRegularStyle,
                      //   )
                      // : Text('data1', style: AppFontStyle.cairoRegularStyle),
                      ? EmployeeListView(
                    onSelectionChanged: updateSelectedEmployees, // Pass callback
                          employees: searchEmployees,
                        )

                      : EmployeeListView(
                    onSelectionChanged: updateSelectedEmployees, // Pass callback
                          employees: boardController
                              .addEmployeeController.allEmployeesEntities!,
                        )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: boardController.loading
                  ? const Center(child: CircularProgressIndicator())
                  : Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 135,
                        child: ReusableElevatedButton(
                          buttonText: 'Create'.tr,
                          onPressed: () {
                            hapticController.triggerHapticFeedback(
                              vibration: VibrateType.mediumImpact,
                              hapticFeedback: HapticFeedback.mediumImpact,
                            );
                           createBoard();
                            // boardController
                            //     .createBoard(
                            //   members: selectedEmployees.map((e) => e.id).toList(), // Pass only IDs
                            //   name: nameController.text,
                            //   description: descriptionController.text,
                            //   department: addDepartmentController
                            //       .getDepartmentId(selectedDepartment ?? 'asd'),
                            //   messaginChannel: switchValue3 ? "yes" : "no",
                            //   context: context,
                            // )
                            //     .then(
                            //   (value) {
                            //     setState(
                            //       () {
                            //         boardController.boards = [];
                            //         boardController.boards.addAll(
                            //             boardController.filterBoards("All"));
                            //         boardController.selectedIndex = 0;
                            //       },
                            //     );
                            //   },
                            // );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // @override
  // void dispose() {
  //   nameController.dispose();
  //   descriptionController.dispose();
  //   super.dispose();
  // }
}
