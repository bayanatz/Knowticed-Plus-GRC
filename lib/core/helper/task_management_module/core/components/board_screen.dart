import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/borad/view/board_details/widget/project_list_widget_board_screen.dart';
import 'package:demo_app/core/helper/task_management_module/borad/view/board_home/widget/custom_elevated_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_upper_filter.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/circle_progress.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/custom_appbar.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_search.dart';

/// Date Created :19/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives:  this file represents the board screen , this page has a custom container to show the different projects available for the employee

class TaskScreen extends StatefulWidget {
  const TaskScreen({
    super.key,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  BoardController tController = Get.find();

  int selectedFilterIndex = 0;
  final HapticController hapticController = Get.put(HapticController());

  String? departmentDrop;

  String searchText = '';
  int selectedIndex = 0;
  late String departmentFilter;

  List<BoardModel> searchBoards = [];
  List<String> department = ["All"];
  List<String> departmentArabic = ["الكل"];
  @override
  void initState() {
    super.initState();
    searchBoards = [];
    var departmentsEn = Get.find<MainCoreDepartmentController>()
        .departmentModels
        .map((e) => tController.containAbbreviation(e.departmentName ?? ''))
        .toList();
    var departmentsAr = Get.find<MainCoreDepartmentController>()
        .departmentModels
        .map((e) => e.departmentNameInArabic ?? '')
        .toList();
    department.addAll(departmentsEn);
    departmentArabic.addAll(departmentsAr);
  }

  MainCoreDepartmentController addDepartmentController =
      Get.put(MainCoreDepartmentController());

  @override
  Widget build(BuildContext context) {
    log('TaskScreen');
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: GetBuilder<BoardController>(
          builder: (controller) {
            return SafeArea(
                child: Row(
              children: <Widget>[
                // Align(
                //   alignment: Alignment.topCenter,
                //   child: CustomDrawer(
                //     selectedIndex: 2,
                //   ),
                // ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       CustomAppBar(),
                        Expanded(
                          child: Container(
                            color: AppColors.background,
                            child: Padding(
                              padding: EdgeInsets.all(15.h),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Task Management".tr,
                                      style: AppFontStyle.cairoRegularStyle
                                          .copyWith(
                                        fontSize: FontConstants.fontSize028.h,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30.h,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        CustomElevatedButton(
                                          backgroundColor: AppColors.signOut,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 30.h, vertical: 10.w),
                                          child: Text(
                                            'Dashboard',
                                            style: AppFontStyle
                                                .cairoRegularStyle
                                                .copyWith(
                                              fontSize: 16.sp,
                                              color: AppColors.colorBlack,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 13.h,
                                    ),

                                    /// board filter
                                    UpperFilters(
                                      filterTitles: [
                                        'All',
                                        ...Get.locale.toString().contains('en')
                                            ? addDepartmentController
                                                .departmentModels
                                                .map((e) =>
                                                    addDepartmentController
                                                        .containAbbreviation(
                                                            e.departmentName ??
                                                                ''))
                                                .toList()
                                            : addDepartmentController
                                                .departmentModels
                                                .map((e) =>
                                                    e.departmentNameInArabic ??
                                                    '')
                                                .toList(),
                                      ],
                                      selectedIndex: selectedIndex,
                                      selectedIndexState: (value) {
                                        setState(() {
                                          selectedIndex = value;
                                        });
                                      },
                                      selectedDepartmentState: (value) {
                                        setState(
                                          () {
                                            departmentFilter =
                                                value == 'الكل' ||
                                                        value == 'All'
                                                    ? 'all'
                                                    : value;
                                            controller.boards = controller
                                                .filterBoards(value == 'الكل' ||
                                                        value == 'All'
                                                    ? 'all'
                                                    : value);
                                          },
                                        );
                                        controller.onBoardSearch = false;
                                      },
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Row(
                                      crossAxisAlignment: orientation
                                          ? CrossAxisAlignment.start
                                          : CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: CustomSearchFiled2(
                                            fillColor:
                                                themeController.currentTheme ==
                                                        AppColors.lightTheme
                                                    ? AppColors.colorWhite
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .inversePrimary,
                                            hint: "Search".tr,
                                            onChanged: (value) {
                                              setState(() {
                                                controller.onBoardSearch = true;
                                                searchBoards = controller.boards
                                                    .where((element) => element
                                                        .boardName!
                                                        .boardgName!
                                                        .last
                                                        .toLowerCase()
                                                        .contains(value
                                                            .toLowerCase()))
                                                    .toList();
                                              });
                                            },
                                            hintStyle: AppFontStyle
                                                .cairoRegularStyle
                                                .copyWith(
                                                    fontSize: FontConstants
                                                        .fontSize016.h,
                                                    fontWeight: FontWeight.w500,
                                                    height: orientation
                                                        ? 1.4
                                                        : null,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .scrim),
                                            keyBoardType: TextInputType.text,
                                            secondActionIcon:
                                                'assets/icons/g4581.svg',
                                            secondActionIconColor:
                                                AppColors.colorLightGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15.h,
                                    ),

                                    /// This is the custom container responsible for showing the projects data : name of the project, department, description
                                    /// and total members number and also will navigate to the project page
                                    /// Vertical and Horizontal
                                    controller.loading
                                        ? const CircleProgress()
                                        : controller.onBoardSearch
                                            ? ProjectListWidget(
                                                boardModel: searchBoards,
                                              )
                                            : controller.boards.isEmpty
                                                ? const SizedBox()
                                                : ProjectListWidget(
                                                    boardModel:
                                                        controller.boards,
                                                  ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ));
          },
        ));
  }
}
