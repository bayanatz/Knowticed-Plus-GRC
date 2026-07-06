// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/screen_size.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/task_details_screen_tablet.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drawer.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_task_container_mobile.dart';

/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives: represents the task container section in the project screen
class CardsContainer extends StatefulWidget {
  final int filterIndex;
  final int totalLength;
  final String taskTitle;
  final String? editTime;
  final VoidCallback onPressed;
  final VoidCallback? isArchive;
  final List<CardModel> cards;
  final String projectName;
  final BoardModel boardModel;

  const CardsContainer({
    super.key,
    required this.filterIndex,
    required this.totalLength,
    required this.taskTitle,
    required this.onPressed,
    this.isArchive,
    this.editTime,
    required this.projectName,
    required this.cards,
    required this.boardModel,
  });
  @override
  _CardsContainerState createState() => _CardsContainerState();
}

class _CardsContainerState extends State<CardsContainer> {
  int listCounter = 6;

  TaskDetailsController taskController = Get.find();
  late String cardFilter;
  //List<CardModel> searchCards = [];
  // List<CardModel> filterCards=[];

  /* @override
  void initState() {
    super.initState();
    searchCards = [];
    taskController.filterCards = [];
    // taskController.updatefilterCards(widget.boardModel!);
    widget.boardModel.cards.forEach((element) {
      if (element.cardStatus!.cardStatus!.last == "todo") {
        taskController.filterCards.add(element);
      }
    });
    taskController.selectedIndex = 0;
    cardFilter = 'todo';
  }*/

  String getStringAtIndex(int index) {
    switch (index) {
      case 0:
        return "To Do";
      case 1:
        return "Doing";
      case 2:
        return "Done";
      case 3:
        return "Archived";
      case 4:
        return "Deleted";
      default:
        return "Invalid index";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return GetBuilder<BoardController>(
      builder: (controller) {
        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              // color: themeController.currentTheme == AppColors.lightTheme
              //     ? AppColors.colorWhite
              //     : Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            //   height: orientation ? 0.7.h : 0.55.h,
            child: orientation
                ? SingleChildScrollView(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: (widget.cards.length / 2).ceil(),
                      itemBuilder: (BuildContext context, int index) {
                        int firstIndex = index * 2;
                        int secondIndex = firstIndex + 1;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.01.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: firstIndex < widget.cards.length
                                    ? CustomTaskContainerMobile(
                                        boardModel: widget.boardModel,
                                        board: widget.projectName,
                                        cardModel: widget.cards[firstIndex],
                                        taskTitle: widget.taskTitle,
                                        onPressed: () {
                                          hapticController
                                              .triggerHapticFeedback(
                                            vibration: VibrateType.mediumImpact,
                                            hapticFeedback:
                                                HapticFeedback.mediumImpact,
                                          );

                                          Navigator.pushReplacement(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType.fade,
                                              child: CustomDrawer(
                                                initialIndex: 1,
                                                screens: [
                                                  Container(),
                                                  TaskDetailsTabletScreen(
                                                    department: widget.boardModel.boardDeparment!.boardgDepartment!.last,
                                                    currentCard: widget
                                                        .cards[firstIndex],
                                                    boardModel:
                                                        widget.boardModel,
                                                    cards: widget.cards,
                                                    projectName:
                                                        widget.projectName,
                                                    listName: getStringAtIndex(
                                                        widget.filterIndex),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },

                                        /// use only if its archive
                                        isArchive: () async {
                                          if (widget
                                                  .cards[firstIndex]
                                                  .cardCreator!
                                                  .cardCreator!
                                                  .last ==
                                              Get.find<MainCoreEmployeeController>()
                                                  .employeeEntity!
                                                  .email!) {
                                            int statusIndex = widget
                                                .cards[firstIndex]
                                                .cardStatus!
                                                .cardStatus!
                                                .length;
                                            await controller.updateCard(
                                              cardModel:
                                                  widget.cards[firstIndex],
                                              board: widget.boardModel
                                                  .boardName!.boardgName!.last,
                                              boardModel: widget.boardModel,
                                              archiveReturn: true,
                                              cardStatus: widget
                                                  .cards[firstIndex]
                                                  .cardStatus!
                                                  .cardStatus![statusIndex - 2],
                                            );
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return const SuccessDialog(
                                                  title: "Warning",
                                                  subtitle:
                                                      "Only Task Owner Can Eidt Status Of This Card",
                                                  lottieAsset:
                                                      "assets/lottie_assets/main_lottie_assets/error.json",
                                                );
                                              },
                                            );
                                          }
                                        },
                                        listName: getStringAtIndex(
                                            widget.filterIndex),
                                      )
                                    : SizedBox(),
                              ),
                              // SizedBox(width: 0.03.w),
                              Expanded(
                                child: secondIndex < widget.cards.length
                                    ? CustomTaskContainerMobile(
                                        boardModel: widget.boardModel,
                                        board: widget.projectName,
                                        cardModel: widget.cards[secondIndex],
                                        taskTitle: widget.taskTitle,
                                        onPressed: () {
                                          hapticController
                                              .triggerHapticFeedback(
                                            vibration: VibrateType.mediumImpact,
                                            hapticFeedback:
                                                HapticFeedback.mediumImpact,
                                          );
                                          Navigator.pushReplacement(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType.fade,
                                              child: CustomDrawer(
                                                initialIndex: 1,
                                                screens: [
                                                  Container(),
                                                  TaskDetailsTabletScreen(
                                                    department: widget.boardModel.boardDeparment!.boardgDepartment!.last,
                                                    currentCard: widget
                                                        .cards[secondIndex],
                                                    cards: widget.cards,
                                                    boardModel:
                                                        widget.boardModel,
                                                    projectName:
                                                        widget.projectName,
                                                    listName: getStringAtIndex(
                                                        widget.filterIndex),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },

                                        /// use only if its archive
                                        isArchive: () async {
                                          if (widget
                                                  .cards[secondIndex]
                                                  .cardCreator!
                                                  .cardCreator!
                                                  .last ==
                                              Get.find<MainCoreEmployeeController>()
                                                  .employeeEntity!
                                                  .email!) {
                                            int statusIndex = widget
                                                .cards[secondIndex]
                                                .cardStatus!
                                                .cardStatus!
                                                .length;
                                            await controller.updateCard(
                                              cardModel:
                                                  widget.cards[secondIndex],
                                              board: widget.boardModel
                                                  .boardName!.boardgName!.last,
                                              boardModel: widget.boardModel,
                                              archiveReturn: true,
                                              cardStatus: widget
                                                  .cards[secondIndex]
                                                  .cardStatus!
                                                  .cardStatus![statusIndex - 2],
                                            );
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return const SuccessDialog(
                                                  title: "Warning",
                                                  subtitle:
                                                      "Only Task Owner Can Eidt Status Of This Card",
                                                  lottieAsset:
                                                      "assets/lottie_assets/main_lottie_assets/error.json",
                                                );
                                              },
                                            );
                                          }
                                        },
                                        listName: getStringAtIndex(
                                            widget.filterIndex),
                                      )
                                    : SizedBox(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(top: 0.0.h),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: (widget.cards.length / 3).ceil() * 3,
                        itemBuilder: (BuildContext context, int index) {
                          int firstIndex = index * 3;
                          int secondIndex = firstIndex + 1;
                          int thirdIndex = firstIndex + 2;

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: firstIndex < widget.cards.length
                                      ? CustomTaskContainerMobile(
                                          taskTitle: widget.taskTitle,
                                          boardModel: widget.boardModel,
                                          board: widget.projectName,
                                          cardModel: widget.cards[firstIndex],
                                          onPressed: () {
                                            hapticController
                                                .triggerHapticFeedback(
                                              vibration:
                                                  VibrateType.mediumImpact,
                                              hapticFeedback:
                                                  HapticFeedback.mediumImpact,
                                            );
                                            Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                type: PageTransitionType.fade,
                                                child: CustomDrawer(
                                                  initialIndex: 1,
                                                  screens: [
                                                    Container(),
                                                    TaskDetailsTabletScreen(
                                                      department: widget.boardModel.boardDeparment!.boardgDepartment!.last,
                                                      currentCard: widget
                                                          .cards[firstIndex],
                                                      cards: widget.cards,
                                                      boardModel:
                                                          widget.boardModel,
                                                      projectName:
                                                          widget.projectName,
                                                      listName:
                                                          getStringAtIndex(
                                                              widget
                                                                  .filterIndex),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },

                                          /// use only if its archive
                                          isArchive: () async {
                                            if (widget
                                                    .cards[firstIndex]
                                                    .cardCreator!
                                                    .cardCreator!
                                                    .last ==
                                                Get.find<
                                                        MainCoreEmployeeController>()
                                                    .employeeEntity!
                                                    .email!) {
                                              int statusIndex = widget
                                                  .cards[firstIndex]
                                                  .cardStatus!
                                                  .cardStatus!
                                                  .length;
                                              await controller.updateCard(
                                                cardModel:
                                                    widget.cards[firstIndex],
                                                board: widget
                                                    .boardModel
                                                    .boardName!
                                                    .boardgName!
                                                    .last,
                                                boardModel: widget.boardModel,
                                                archiveReturn: true,
                                                cardStatus: widget
                                                        .cards[firstIndex]
                                                        .cardStatus!
                                                        .cardStatus![
                                                    statusIndex - 2],
                                              );
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const SuccessDialog(
                                                    title: "Warning",
                                                    subtitle:
                                                        "Only Task Owner Can Eidt Status Of This Card",
                                                    lottieAsset:
                                                        "assets/lottie_assets/main_lottie_assets/error.json",
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          listName: getStringAtIndex(
                                              widget.filterIndex),
                                        )
                                      : SizedBox(),
                                ),
                                Expanded(
                                  child: secondIndex < widget.cards.length
                                      ? CustomTaskContainerMobile(
                                          boardModel: widget.boardModel,
                                          board: widget.projectName,
                                          cardModel: widget.cards[secondIndex],
                                          taskTitle: widget.taskTitle,
                                          onPressed: () {
                                            hapticController
                                                .triggerHapticFeedback(
                                              vibration:
                                                  VibrateType.mediumImpact,
                                              hapticFeedback:
                                                  HapticFeedback.mediumImpact,
                                            );
                                            Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                type: PageTransitionType.fade,
                                                child: CustomDrawer(
                                                  initialIndex: 1,
                                                  screens: [
                                                    Container(),
                                                    TaskDetailsTabletScreen(
                                                      department: widget.boardModel.boardDeparment!.boardgDepartment!.last,
                                                      currentCard: widget
                                                          .cards[secondIndex],
                                                      cards: widget.cards,
                                                      boardModel:
                                                          widget.boardModel,
                                                      projectName:
                                                          widget.projectName,
                                                      listName:
                                                          getStringAtIndex(
                                                              widget
                                                                  .filterIndex),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },

                                          /// use only if its archive
                                          isArchive: () async {
                                            if (widget
                                                    .cards[secondIndex]
                                                    .cardCreator!
                                                    .cardCreator!
                                                    .last ==
                                                Get.find<
                                                        MainCoreEmployeeController>()
                                                    .employeeEntity!
                                                    .email!) {
                                              int statusIndex = widget
                                                  .cards[secondIndex]
                                                  .cardStatus!
                                                  .cardStatus!
                                                  .length;
                                              await controller.updateCard(
                                                cardModel:
                                                    widget.cards[secondIndex],
                                                board: widget
                                                    .boardModel
                                                    .boardName!
                                                    .boardgName!
                                                    .last,
                                                boardModel: widget.boardModel,
                                                archiveReturn: true,
                                                cardStatus: widget
                                                        .cards[secondIndex]
                                                        .cardStatus!
                                                        .cardStatus![
                                                    statusIndex - 2],
                                              );
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const SuccessDialog(
                                                    title: "Warning",
                                                    subtitle:
                                                        "Only Task Owner Can Eidt Status Of This Card",
                                                    lottieAsset:
                                                        "assets/lottie_assets/main_lottie_assets/error.json",
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          listName: getStringAtIndex(
                                              widget.filterIndex),
                                        )
                                      : SizedBox(),
                                ),
                                Expanded(
                                  child: thirdIndex < widget.cards.length
                                      ? CustomTaskContainerMobile(
                                          boardModel: widget.boardModel,
                                          board: widget.projectName,
                                          cardModel: widget.cards[thirdIndex],
                                          taskTitle: widget.taskTitle,
                                          onPressed: () {
                                            hapticController
                                                .triggerHapticFeedback(
                                              vibration:
                                                  VibrateType.mediumImpact,
                                              hapticFeedback:
                                                  HapticFeedback.mediumImpact,
                                            );
                                            Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                type: PageTransitionType.fade,
                                                child: CustomDrawer(
                                                  initialIndex: 1,
                                                  screens: [
                                                    Container(),
                                                    TaskDetailsTabletScreen(
                                                      department: widget.boardModel.boardDeparment!.boardgDepartment!.last,
                                                      currentCard: widget
                                                          .cards[thirdIndex],
                                                      cards: widget.cards,
                                                      boardModel:
                                                          widget.boardModel,
                                                      projectName:
                                                          widget.projectName,
                                                      listName:
                                                          getStringAtIndex(
                                                              widget
                                                                  .filterIndex),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },

                                          /// use only if its archive
                                          isArchive: () async {
                                            if (widget
                                                    .cards[secondIndex]
                                                    .cardCreator!
                                                    .cardCreator!
                                                    .last ==
                                                Get.find<
                                                        MainCoreEmployeeController>()
                                                    .employeeEntity!
                                                    .email!) {
                                              int statusIndex = widget
                                                  .cards[secondIndex]
                                                  .cardStatus!
                                                  .cardStatus!
                                                  .length;
                                              await controller.updateCard(
                                                cardModel:
                                                    widget.cards[secondIndex],
                                                board: widget
                                                    .boardModel
                                                    .boardName!
                                                    .boardgName!
                                                    .last,
                                                boardModel: widget.boardModel,
                                                archiveReturn: true,
                                                cardStatus: widget
                                                        .cards[secondIndex]
                                                        .cardStatus!
                                                        .cardStatus![
                                                    statusIndex - 2],
                                              );
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const SuccessDialog(
                                                    title: "Warning",
                                                    subtitle:
                                                        "Only Task Owner Can Eidt Status Of This Card",
                                                    lottieAsset:
                                                        "assets/lottie_assets/main_lottie_assets/error.json",
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          listName: getStringAtIndex(
                                              widget.filterIndex),
                                        )
                                      : SizedBox(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
