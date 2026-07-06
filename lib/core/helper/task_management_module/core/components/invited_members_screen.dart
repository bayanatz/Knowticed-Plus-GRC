// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_appbar.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_table_body.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_table_header_new.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/requests_number_container.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/bread_crumbs_navigation_members.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/invited_members_filter.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/search_filter_row_invited_members.dart';

/// Date Created : 18/Sep/2024
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit : 18/Sep/2024 By Bassem Mohamed
/// Objectives:  this file represents the  invited members screen
/// that will be shwed in the tablet version, this page will consist of search and filteration row,
/// a table that will consist of the whole members that are enrolled in this board and have tasks to do, these members represent
/// the ones who are asigned to do tasks ,so the table will have:
/// member name, card name, checklist element name, start date, end date, and status

class InvitedMembersScreen extends StatefulWidget {
  const InvitedMembersScreen({
    super.key,
    required this.boardModel,
  });
  final BoardModel boardModel;
  @override
  State<InvitedMembersScreen> createState() => _InvitedMembersScreenState();
}

class _InvitedMembersScreenState extends State<InvitedMembersScreen> {
  final HapticController hapticController = Get.put(HapticController());
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
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAppBar(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 0.02.h, vertical: 0.02.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// bread crumbs section for the invited members page
                            BreadCrumbsNavigationMembers(),
                            SizedBox(
                              height: isPortrait ? 0.02.h : 0.03.h,
                            ),
                            Text(
                              "Invited Members".tr,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: isPortrait
                                    ? FontConstants.fontSize030.h
                                    : FontConstants.fontSize035.h,
                                color: themeController.currentTheme ==
                                        AppColors.lightTheme
                                    ? AppColors.colorBlack
                                    : AppColors.colorWhiteDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 0.01.h,
                            ),

                            /// filteration row section for the invited members page
                            SearchFilterRowInvitedMembers(
                              filterColor: controller.isFilterEnabled,
                              onSearchChanged: (value) {
                                controller.searchInvitedMembersList(value);
                              },
                              onFilterPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InvitedMembersFilter(
                                      statusDropDownItems: const [
                                        "Done",
                                        "Exceeded Deadline",
                                        "In Progress",
                                        "Not Started"
                                      ],
                                      statusValue:
                                          controller.invitedMembersFilterStatus,
                                      startDateValue: controller
                                          .invitedMembersFilterStartDate,
                                      endDateValue: controller
                                          .invitedMembersFilterEndDate,
                                      statusState: (value) {
                                        controller
                                            .updateInvitedMembersFilterStatus(
                                                value!);
                                      },
                                      starDateValueState: (value) {
                                        controller
                                            .updateInvitedMembersFilterStartDate(
                                                value);
                                      },
                                      endDateValueState: (value) {
                                        controller
                                            .updateInvitedMembersFilterEndDate(
                                                value);
                                      },
                                      onApplyPressed: () {
                                        controller.onApplyFilter();

                                        controller.enableFilter(true);
                                      },
                                      onResetPressed: () {
                                        controller.resetInvitedMembersFilter();

                                        print("Filters reset");
                                        setState(() {
                                          controller.enableFilter(false);
                                        });
                                      },
                                    );
                                  },
                                );
                              }, onEditPressed: () {  },
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
                                        if (controller
                                                .invitedMembersFilterStatus ==
                                            "Done") {
                                          controller
                                                  .invitedMembersFilterStatus =
                                              null;
                                        } else {
                                          controller
                                              .updateInvitedMembersFilterStatus(
                                                  'Done');
                                        }

                                        taskController.onApplyFilter();
                                        taskController.enableFilter(true);
                                      },
                                      child: RequestsNumberContainer(
                                          isSelected: controller
                                                  .invitedMembersFilterStatus ==
                                              "Done",
                                          title: "Done",
                                          count: controller
                                              .invitedMembersListWithoutFilter
                                              .where((e) =>
                                                  e.status.toLowerCase() ==
                                                  "done")
                                              .toList()
                                              .length),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (controller
                                                .invitedMembersFilterStatus ==
                                            "In Progress") {
                                          controller
                                                  .invitedMembersFilterStatus =
                                              null;
                                        } else {
                                          controller
                                              .updateInvitedMembersFilterStatus(
                                                  'In Progress');
                                        }

                                        taskController.onApplyFilter();
                                        taskController.enableFilter(true);
                                      },
                                      child: RequestsNumberContainer(
                                          isSelected: controller
                                                  .invitedMembersFilterStatus ==
                                              "In Progress",
                                          title: "In Progress",
                                          count: controller
                                              .invitedMembersListWithoutFilter
                                              .where((e) =>
                                                  e.status.toLowerCase() ==
                                                  "in progress")
                                              .toList()
                                              .length),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (controller
                                                .invitedMembersFilterStatus ==
                                            "Not Started") {
                                          controller
                                                  .invitedMembersFilterStatus =
                                              null;
                                        } else {
                                          controller
                                              .updateInvitedMembersFilterStatus(
                                                  'Not Started');
                                        }

                                        taskController.onApplyFilter();
                                        taskController.enableFilter(true);
                                      },
                                      child: RequestsNumberContainer(
                                          isSelected: controller
                                                  .invitedMembersFilterStatus ==
                                              "Not Started",
                                          title: "Not Started",
                                          count: controller
                                              .invitedMembersListWithoutFilter
                                              .where((e) =>
                                                  e.status.toLowerCase() ==
                                                  "not started")
                                              .toList()
                                              .length),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (controller
                                                .invitedMembersFilterStatus ==
                                            "Exceeded Deadline") {
                                          controller
                                                  .invitedMembersFilterStatus =
                                              null;
                                        } else {
                                          controller
                                              .updateInvitedMembersFilterStatus(
                                                  'Exceeded Deadline');
                                        }
                                        taskController.onApplyFilter();
                                        taskController.enableFilter(true);
                                      },
                                      child: RequestsNumberContainer(
                                          isSelected: controller
                                                  .invitedMembersFilterStatus ==
                                              "Exceeded Deadline",
                                          title: "Exceeded Deadline",
                                          count: controller
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

                            SizedBox(
                              width: double.infinity,
                              // decoration: BoxDecoration(
                              //   color: Theme.of(context)
                              //       .colorScheme
                              //       .inversePrimary,
                              //   borderRadius: BorderRadius.circular(8),
                              // ),
                              // padding: EdgeInsets.all(0.02.h),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: isPortrait ? 1.44.w : 1.09.w,
                                  //  height: isPortrait ? 0.7.h : 0.6.h,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomTableHeaderNew(titles: [
                                        'NO'.tr,
                                        'Member'.tr,
                                        'Card'.tr,
                                        'Tasks'.tr,
                                        'Start Date'.tr,
                                        'End Date'.tr,
                                        'Status'.tr,
                                      ], columnsCount: 7),
                                      ListView.builder(
                                          padding: EdgeInsets.zero,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: controller
                                              .invitedMembersList.length,
                                          itemBuilder: (context, index) {
                                            final member = controller
                                                .invitedMembersList[index];
                                            return Container(
                                              decoration: BoxDecoration(
                                                // borderRadius: BorderRadius.circular(8),
                                                color: index % 2 == 0
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainerHighest
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .inversePrimary,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 0.02.w,
                                                    vertical: 0.025.h),
                                                child: GestureDetector(
                                                  onTap: () {},
                                                  child: Row(
                                                    children: [
                                                      // NO
                                                      CustomTableBody(
                                                        text: Get.locale
                                                                .toString()
                                                                .contains('en')
                                                            ? "${index + 1}"
                                                            : convertNumberToArabic(
                                                                "${index + 1}"),
                                                      ),
                                                      // Member
                                                      CustomTableBody(
                                                        profileImage:
                                                            member.memberImage,
                                                        text: member.memberName,
                                                      ),

                                                      // Card
                                                      CustomTableBody(
                                                          text: member.card),
                                                      // Task
                                                      CustomTableBody(
                                                          text: member.task),

                                                      // Start Date
                                                      CustomTableBody(
                                                        text: member.startDate !=
                                                                null
                                                            ? Get.locale
                                                                    .toString()
                                                                    .contains(
                                                                        'en')
                                                                ? (member
                                                                    .startDate!)
                                                                : translateDate(
                                                                    member
                                                                        .startDate!)
                                                            : "-",
                                                      ),
                                                      // End Date
                                                      CustomTableBody(
                                                        text: member.endDate !=
                                                                null
                                                            ? Get.locale
                                                                    .toString()
                                                                    .contains(
                                                                        'en')
                                                                ? (member
                                                                    .endDate!)
                                                                : translateDate(
                                                                    member
                                                                        .endDate!)
                                                            : "-",
                                                      ),
                                                      // Status
                                                      CustomTableBody(
                                                          text: member.status),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          })
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
