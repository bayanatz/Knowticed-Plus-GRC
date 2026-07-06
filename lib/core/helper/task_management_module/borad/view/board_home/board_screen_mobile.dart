import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/borad/view/board_details/board_details_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/borad/view/board_home/widget/custom_elevated_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_search.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_upper_filter.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/empty_widget.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_task_container.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/core/nav_bar_package.dart/functions.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';

/// Date Created :12/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives: this screen is the Board page, this page consist of multiple widgets:
/// Create New board
/// view available boards
/// navigate to the board detailes
///
class BoardScreenMobile extends StatefulWidget {
  const BoardScreenMobile({super.key});

  @override
  State<BoardScreenMobile> createState() => _BoardScreenMobileState();
}

class _BoardScreenMobileState extends State<BoardScreenMobile> {
  BoardController boardController = Get.find();

  int selectedIndex = 0;
  late String departmentFilter;
  List<BoardModel> boards = [];
  List<BoardModel> searchBoards = [];
  List<String> department = ["All"];
  List<String> departmentArabic = ["الكل"];
  @override
  void initState() {
    super.initState();

    var departmentsEn = addDepartmentController.departmentModels
        .map((e) => boardController.containAbbreviation(e.departmentName ?? ''))
        .toList();
    var departmentsAr = addDepartmentController.departmentModels
        .map((e) => e.departmentNameInArabic ?? '')
        .toList();
    department.addAll(departmentsEn);
    departmentArabic.addAll(departmentsAr);
    searchBoards = [];
  }

  MainCoreDepartmentController addDepartmentController =
  Get.put(MainCoreDepartmentController());
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return GetBuilder<BoardController>(
      builder: (boardController) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            color: themeController.currentTheme == AppColors.lightTheme
                ? AppColors.colorLightGrey
                : AppColors.colorBlack,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 62, left: 13),
                    child: Text(
                      "Task Management",
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xff2D2D2D),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomElevatedButton(
                          backgroundColor: AppColors.signOut,
                          padding: EdgeInsets.symmetric(
                              horizontal: 13.0, vertical: 4.0),
                          child: Text(
                            'Dashboard',
                            style: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize:
                              isTablet ? FontConstants.fontSize022.h : 16.0,
                              color: AppColors.colorBlack,
                              fontWeight:
                              isTablet ? FontWeight.w600 : FontWeight.w500,
                              height: isTablet ? 0.002.h : 2.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    color:
                    themeController.currentTheme == AppColors.lightTheme
                        ? AppColors.colorLightGrey
                        : AppColors.colorBlack,
                    padding: EdgeInsets.symmetric(horizontal: 0.04.w),
                    child: Column(
                      children: [
                        /// board filter
                        UpperFilters(
                          filterTitles: [
                            'All',
                            ...Get.locale.toString().contains('en')
                                ? addDepartmentController.departmentModels
                                .map((e) => addDepartmentController
                                .containAbbreviation(
                                e.departmentName ?? ''))
                                .toList()
                                : addDepartmentController.departmentModels
                                .map((e) => e.departmentNameInArabic ?? '')
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
                                value == 'الكل' || value == 'All'
                                    ? 'all'
                                    : value;
                                boardController.boards =
                                    boardController.filterBoards(
                                        value == 'الكل' || value == 'All'
                                            ? 'all'
                                            : value);
                              },
                            );
                            boardController.onBoardSearch = false;
                          },
                        ),
                        SizedBox(
                          height: 25,
                        ),

                        /// board search field
                        CustomSearchFiled2(
                          secondActionIcon: 'assets/icons/task.svg',
                          secondActionIconColor: AppColors.signOut,
                          fillColor:
                          Theme.of(context).colorScheme.inversePrimary,
                          hint: "Search".tr,
                          hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize: FontConstants.fontSize016.h,
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer),
                          keyBoardType: TextInputType.text,
                          onChanged: (value) {
                            setState(() {
                              boardController.onBoardSearch = true;
                              searchBoards = boardController.boards
                                  .where((element) => element
                                  .boardName!.boardgName!.last
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),

                        SizedBox(
                          height: 0.68.h,
                          child: boardController.loading
                              ? const SizedBox()
                              : boardController.onBoardSearch

                          // search results view
                              ? ListView.builder(
                            itemCount: searchBoards.length,
                            itemBuilder:
                                (BuildContext context, int index) {
                              return Padding(
                                padding:
                                EdgeInsets.only(bottom: 0.015.h),
                                child: Column(
                                  children: [
                                    CustomTaskContainer(
                                      board: searchBoards[index],
                                      onPressed: () {
                                        hapticController
                                            .triggerHapticFeedback(
                                          vibration: VibrateType
                                              .mediumImpact,
                                          hapticFeedback:
                                          HapticFeedback
                                              .mediumImpact,
                                        );
                                        PersistentNavBarNavigator
                                            .pushNewScreen(
                                          context,
                                          withNavBar: true,
                                          screen: ProjectScreenMobile(
                                            boardModel:
                                            searchBoards[index],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                              : boardController.boards.isEmpty
                              ? const EmptyWidget(
                            assetPath:
                            "assets/lottie_assets/main_lottie_assets/emptyTask.json",
                            scale: 3,
                          )

                          /// available boards view
                              : ListView.builder(
                            itemCount:
                            boardController.boards.length,
                            itemBuilder: (BuildContext context,
                                int index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: 0.015.h),
                                child: Column(
                                  children: [
                                    CustomTaskContainer(
                                      board: boardController
                                          .boards[index],
                                      onPressed: () {
                                        hapticController
                                            .triggerHapticFeedback(
                                          vibration: VibrateType
                                              .mediumImpact,
                                          hapticFeedback:
                                          HapticFeedback
                                              .mediumImpact,
                                        );
                                        PersistentNavBarNavigator
                                            .pushNewScreen(
                                          context,
                                          withNavBar: true,
                                          screen:
                                          ProjectScreenMobile(
                                            boardModel:
                                            boardController
                                                .boards[
                                            index],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
}
