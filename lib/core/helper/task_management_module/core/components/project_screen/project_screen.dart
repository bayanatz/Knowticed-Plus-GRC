// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_appbar.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/main_yellow_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/project_screen/widget/cards_container_view.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/project_screen/widget/project_header_section.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/project_screen/widget/search_fext_field.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/project_screen/widget/status_filter_with_add_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_task_container.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';

/// Date Created :20/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :17/2/2025 By Islam Diab
/// Objectives:  this file represents the  the project screen that has all the tasks available dividing them on three different things which is : to do, doing, and done
/// This file has a custom container that shows different detailes about the project like the title, description, end date, number of comments and attachments, and etc

class ProjectScreen extends StatefulWidget {
  final String projectName;
  final BoardModel boardModel;

  const ProjectScreen(
      {super.key, required this.projectName, required this.boardModel});

  @override
  State<ProjectScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ProjectScreen> {
  TaskDetailsController taskController = Get.find();
  final HapticController hapticController = Get.put(HapticController());
  late String cardFilter;
  List<CardModel> searchCards = [];

  @override
  void initState() {
    /// set the initial values
    super.initState();
    taskController.images = [];
    taskController.currentCardMembers = [];
    taskController.getAllMembersNum(widget.boardModel);
    taskController.setMembers(widget.boardModel);
    searchCards = [];
    taskController.filterCards = [];
    // taskController.updatefilterCards(widget.boardModel!);
    for (var element in widget.boardModel.cards) {
      if (element.cardStatus!.cardStatus!.last == "todo") {
        taskController.filterCards.add(element);
      }
    }
    taskController.selectedIndex = 0;
    cardFilter = 'todo';
  }

  @override
  Widget build(BuildContext context) {
    //taskController.setMembers( widget.boardModel);

    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return GetBuilder<TaskDetailsController>(
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(),
                SizedBox(
                  height: 20.h,
                ),
                ProjectHeaderSection(
                  controller: controller,
                  boardModel: widget.boardModel,
                  projectName: widget.projectName.tr,
                ),

                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TabletButton(),
                  ],
                ),
                SizedBox(
                  height: 15.h,
                ),
                CustomTaskContainer(
                  onBoardDetails: true,
                  board: widget.boardModel,
                ),
                SizedBox(
                  height: 15.h,
                ),
                StatusFilterWithAddButton(
                  controller: controller,
                  orientation: orientation,
                  selectedIndexState: (value) {
                    setState(() {
                      controller.selectedIndex = value;
                    });
                  },
                  selectedDepartmentState: (value) {
                    /// get the selected department and filter the cards
                    setState(
                      () {
                        cardFilter = value;
                        controller.onCardSearch = false;
                        controller.filterCards = [];
                        if (value.trim() == 'To Do') {
                          for (var element in widget.boardModel.cards) {
                            if (element.cardStatus!.cardStatus!.last ==
                                "todo") {
                              controller.filterCards.add(element);
                            }
                          }
                        } else {
                          for (var element in widget.boardModel.cards) {
                            if (element.cardStatus!.cardStatus!.last ==
                                value.toLowerCase()) {
                              controller.filterCards.add(element);
                            }
                          }
                        }
                      },
                    );
                  },
                  board: widget.boardModel.boardName!.boardgName!.last,
                ),
                SizedBox(
                  height: 15.h,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),

                  /// This row shows the search bar
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: SearchFextField(
                        orientation: orientation,
                        onChanged: (value) {
                          setState(() {
                            controller.onCardSearch = true;
                            searchCards = controller.filterCards
                                .where((element) => element
                                    .cardName!.cardName!.last
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      )),
                      // SizedBox(
                      //   width: orientation ? 0.05.w : 0.37.h,
                      // ),
                      // ChatElevatedButton(orientation: orientation),
                    ],
                  ),
                ),

                /// This section is for the task container
                widget.boardModel.cards.isNotEmpty
                    ? Expanded(
                        child: CardsContainerView(
                          cards: controller.onCardSearch
                              ? searchCards
                              : controller.filterCards,
                          boardModel: widget.boardModel,
                          projectName: widget.projectName,
                          selectedIndex: controller.selectedIndex,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TabletButton extends StatelessWidget {
  const TabletButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ReusableElevatedButton(
          onTablet: true,
          buttonText: 'Edit'.tr,
          icon: 'assets/icons_assets/main_icons_assets/edit_icon.svg',
          onPressed: () {},
        ),
        SizedBox(
          width: 15.h,
        ),
        ReusableElevatedButton(
          deleteButton: true,
          onTablet: true,
          buttonText: 'Delete'.tr,
          icon: 'assets/icons_assets/main_icons_assets/trashIcon.svg',
          onPressed: () {},
        ),
      ],
    );
  }
}
