import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/custom_appbar_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_search.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/requests_number_container.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/reusable_icon_container.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_invited_members_container_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/invited_members_filter.dart';
import 'package:demo_app/core/theme/app_colors.dart';

/// Date Created : 18/Sep/2024
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit : 18/Sep/2024 By Bassem Mohamed
/// Objectives:  this file represents the  invited members screen
/// that will be shwed in the mobile version, this page will consist of search and filteration row,
/// a listview that will consist of the whole members that are enrolled in this board and have tasks to do, these members represent
/// the ones who are asigned to do tasks ,so the table will have:
/// member name, card name, checklist element name, start date, end date, and status

class InvitedMembersScreenMobile extends StatefulWidget {
  const InvitedMembersScreenMobile({
    super.key,
    required this.boardModel,
  });
  final BoardModel boardModel;

  @override
  State<InvitedMembersScreenMobile> createState() =>
      _InvitedMembersScreenMobileState();
}

class _InvitedMembersScreenMobileState
    extends State<InvitedMembersScreenMobile> {
  TaskDetailsController taskController = Get.put(TaskDetailsController());
  @override
  void initState() {
    super.initState();
    taskController.setInvitedMembers(widget.boardModel);
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return GetBuilder<TaskDetailsController>(
      builder: (taskController) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Container(
              color: themeController.currentTheme == AppColors.lightTheme
                  ? AppColors.colorLightGrey
                  : AppColors.colorBlack,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomAppBarMobile(
                      showIcon: true,
                      title: "Invited Members",
                    ),
                    Container(
                      color:
                          themeController.currentTheme == AppColors.lightTheme
                              ? AppColors.colorLightGrey
                              : AppColors.colorBlack,
                      padding: EdgeInsets.symmetric(horizontal: 0.04.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          /// board search field
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 0.055.h,
                                  child: CustomSearchFiled2(
                                    secondActionIcon: 'assets/icons/g4581.svg',
                                    secondActionIconColor:
                                        AppColors.colorLightGrey,
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    hint: "Search".tr,
                                    hintStyle: AppFontStyle.cairoRegularStyle
                                        .copyWith(
                                            fontSize:
                                                FontConstants.fontSize016.h,
                                            height: 2.4,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer),
                                    keyBoardType: TextInputType.text,
                                    onChanged: (value) {
                                      taskController
                                          .searchInvitedMembersList(value);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 0.03.w),
                              ReusableIconContainer(
                                filterColor: taskController.isFilterEnabled,
                                imagePath: "assets/icons_assets/main_icons_assets/filter_table.svg",
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InvitedMembersFilter(
                                        statusDropDownItems: const [
                                          "Done",
                                          "In Progress",
                                          "Exceeded Deadline",
                                          "Not Started"
                                        ],
                                        statusValue: taskController
                                            .invitedMembersFilterStatus,
                                        startDateValue: taskController
                                            .invitedMembersFilterStartDate,
                                        endDateValue: taskController
                                            .invitedMembersFilterEndDate,
                                        statusState: (value) {
                                          taskController
                                              .updateInvitedMembersFilterStatus(
                                                  value!);
                                        },
                                        starDateValueState: (value) {
                                          taskController
                                              .updateInvitedMembersFilterStartDate(
                                                  value);
                                        },
                                        endDateValueState: (value) {
                                          taskController
                                              .updateInvitedMembersFilterEndDate(
                                                  value);
                                        },
                                        onApplyPressed: () {
                                          taskController.onApplyFilter();
                                          taskController.enableFilter(true);
                                        },
                                        onResetPressed: () {
                                          taskController
                                              .resetInvitedMembersFilter();
                                          taskController.enableFilter(false);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 0.015.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: isPortrait ? 0 : 0.025.h,
                                left: 0,
                                right: 0),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      if (taskController
                                              .invitedMembersFilterStatus ==
                                          "Done") {
                                        taskController
                                            .invitedMembersFilterStatus = null;
                                      } else {
                                        taskController
                                            .updateInvitedMembersFilterStatus(
                                                'Done');
                                      }

                                      taskController.onApplyFilter();
                                      taskController.enableFilter(true);
                                    },
                                    child: RequestsNumberContainer(
                                        isSelected: taskController
                                                .invitedMembersFilterStatus ==
                                            "Done",
                                        title: "Done",
                                        count: taskController
                                            .invitedMembersListWithoutFilter
                                            .where((e) =>
                                                e.status.toLowerCase() ==
                                                "done")
                                            .toList()
                                            .length),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (taskController
                                              .invitedMembersFilterStatus ==
                                          "In Progress") {
                                        taskController
                                            .invitedMembersFilterStatus = null;
                                      } else {
                                        taskController
                                            .updateInvitedMembersFilterStatus(
                                                'In Progress');
                                      }

                                      taskController.onApplyFilter();
                                      taskController.enableFilter(true);
                                    },
                                    child: RequestsNumberContainer(
                                        isSelected: taskController
                                                .invitedMembersFilterStatus ==
                                            "In Progress",
                                        title: "In Progress",
                                        count: taskController
                                            .invitedMembersListWithoutFilter
                                            .where((e) =>
                                                e.status.toLowerCase() ==
                                                "in progress")
                                            .toList()
                                            .length),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (taskController
                                              .invitedMembersFilterStatus ==
                                          "Not Started") {
                                        taskController
                                            .invitedMembersFilterStatus = null;
                                      } else {
                                        taskController
                                            .updateInvitedMembersFilterStatus(
                                                'Not Started');
                                      }

                                      taskController.onApplyFilter();
                                      taskController.enableFilter(true);
                                    },
                                    child: RequestsNumberContainer(
                                        isSelected: taskController
                                                .invitedMembersFilterStatus ==
                                            "Not Started",
                                        title: "Not Started",
                                        count: taskController
                                            .invitedMembersListWithoutFilter
                                            .where((e) =>
                                                e.status.toLowerCase() ==
                                                "not started")
                                            .toList()
                                            .length),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (taskController
                                              .invitedMembersFilterStatus ==
                                          "Exceeded Deadline") {
                                        taskController
                                            .invitedMembersFilterStatus = null;
                                      } else {
                                        taskController
                                            .updateInvitedMembersFilterStatus(
                                                'Exceeded Deadline');
                                      }
                                      taskController.onApplyFilter();
                                      taskController.enableFilter(true);
                                    },
                                    child: RequestsNumberContainer(
                                        isSelected: taskController
                                                .invitedMembersFilterStatus ==
                                            "Exceeded Deadline",
                                        title: "Exceeded Deadline",
                                        count: taskController
                                            .invitedMembersListWithoutFilter
                                            .where((e) =>
                                                e.status.toLowerCase() ==
                                                "exceeded deadline")
                                            .toList()
                                            .length),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 0.01.h,
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: taskController.invitedMembersList.length,
                            itemBuilder: (BuildContext context, int index) {
                              final member =
                                  taskController.invitedMembersList[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 0.015.h),
                                child: CustomInvitedMembersContainerMobile(
                                    invitedMember: member),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
