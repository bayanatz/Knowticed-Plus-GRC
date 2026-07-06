import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/add_edit_card_deadline_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/attachments_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/sectionTitle.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_attachments_container.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/core/nav_bar_package.dart/functions.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/checklist_item.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/attachment/mobile_view/attachment_section_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/checklist/checkList.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/checklist/checklist_section_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/comment/comments_section.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/deadline/mobile_view/deadLine_section_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/header/header_section.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_appbar_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/copy_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/delete_archive_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_members_dialog_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_task_components_detailes.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/deadline/mobile_view/deadLine_Section.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/member/member_section_mobile.dart';

/// Date Created :12/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives: this screen is the Project page, this page consist of multiple widgets:
/// view available tasks
/// navigate to the task detailes
///

class TaskDetailsMobile extends StatefulWidget {
  final CardModel cardModel;
  final String department;
  final String board;
  final List<CardModel> cards;
  final BoardModel boardModel;

  const TaskDetailsMobile({
    super.key,
    required this.cardModel,
    required this.department,
    required this.board,
    required this.cards,
    required this.boardModel,
  });

  @override
  State<TaskDetailsMobile> createState() => _TaskDetailsMobileState();
}

class _TaskDetailsMobileState extends State<TaskDetailsMobile> {
  TaskDetailsController taskController = Get.find();

  bool showMembers = false;
  int selectedIndex = 0;
  late String departmentFilter;
  bool showChecklistSection = false;
  bool showDates = false;
  bool showAttachment = true;
  int attachCounter = 5;
  bool slideActive = false;
  TextEditingController checkListController = TextEditingController();

  List<CardCheckLists> cardCheckLists = [];

  @override
  void initState() {
    super.initState();
    departmentFilter = 'all';
  }

  void toggleShowMembers() {
    setState(() {
      showMembers = !showMembers;
    });
  }

  void toggleShowDates() {
    setState(() {
      showDates = !showDates;
    });
  }

  void toggleShowAttach() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeletOrArchiveDialog(
          yesOnPressed: () {
            setState(() {
              showAttachment = false;
              Navigator.of(context).pop();
            });
          },
          isDelete: true,
        );
      },
    );
  }

  bool _checkListExpanded = false;

  void _updateCheckListExpanded(bool value) {
    setState(() {
      _checkListExpanded = value;
    });
  }

  @override
  Widget build(BuildContext context) {


    cardCheckLists = widget.cardModel.cardCheckLists!.where(
      (element) {
        print(
            "checklist: ${element.checkListTitle!.last} status: ${element.checkListStatus!.last}");
        return element.checkListStatus!.last.toLowerCase() != "deleted";
      },
    ).toList();
    return GetBuilder<BoardController>(
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Container(
              color: AppColors.colorLightGrey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBarMobile(
                    showIcon: true,
                    title: widget.cardModel.cardName!.cardName!.last.capitalize,
                  ),
                  Expanded(
                    child: Container(
                      color:
                          themeController.currentTheme == AppColors.lightTheme
                              ? AppColors.colorLightGrey
                              : AppColors.colorBlack,
                      padding: EdgeInsets.symmetric(horizontal: 0.04.w),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 0.015.h,
                            ),

                            /// Header Section includies: - Task Image, Task name, task Description
                            TaskDetailsHeaderWidget(
                              card: widget.cardModel,
                              board: widget.board,
                              department: widget.department,
                            ),

                            ///This Container is responsible for adding members, adding checklist, dates and attachments
                            ///Add Quick Actions
                            ////////////////////////////////////////////////////////
                            SectionTitle(
                                title: 'Add Quick Action',
                               ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0.04.w, vertical: 0.015.h),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomContainerWithImage(
                                              imagePath:
                                                  "assets/icons_assets/task_assets/member.svg",
                                              text: 'Members',
                                              isShown: showMembers,
                                              changeColor: widget
                                                      .cardModel
                                                      .cardMembers!
                                                      .cardMembersStatus!
                                                      .contains("invited")
                                                  ? true
                                                  : false,
                                              onPressed: () {
                                                setState(() {
                                                  showMembers =
                                                      !showMembers;
                                                });
                                                hapticController
                                                    .triggerHapticFeedback(
                                                        vibration: VibrateType
                                                            .mediumImpact,
                                                        hapticFeedback:
                                                            HapticFeedback
                                                                .mediumImpact);

                                                /// check if user is task owner or not and show dialog for adding members
                                                if (!widget
                                                    .cardModel
                                                    .cardMembers!
                                                    .cardMembersStatus!
                                                    .contains("invited")) {
                                                  if (widget
                                                          .cardModel
                                                          .cardCreator!
                                                          .cardCreator!
                                                          .last ==
                                                      Get.find<
                                                              MainCoreEmployeeController>()
                                                          .employeeEntity!
                                                          .email!) {
                                                    List<String> boardMembers =
                                                        [];
                                                    if (widget
                                                                .boardModel
                                                                .boardMember
                                                                ?.boardMembers !=
                                                            null &&
                                                        widget
                                                                .boardModel
                                                                .boardMember
                                                                ?.boardMembers !=
                                                            []) {
                                                      for (int i = 0;
                                                          i <
                                                              widget
                                                                  .boardModel
                                                                  .boardMember!
                                                                  .boardMembers!
                                                                  .length;
                                                          i++) {
                                                        if (widget
                                                                .boardModel
                                                                .boardMember!
                                                                .boardMembersStatus![i] ==
                                                            "invited") {
                                                          boardMembers.add(widget
                                                              .boardModel
                                                              .boardMember!
                                                              .boardMembers![i]);
                                                        }
                                                      }
                                                    }
                                                    if (boardMembers
                                                        .isNotEmpty) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return CustomMemberDialogMobile(
                                                            assignCardMember:
                                                                true,
                                                            currentListItem:
                                                                CheckListItems(),
                                                            boardModel: widget
                                                                .boardModel,
                                                            cardModel: widget
                                                                .cardModel,
                                                            board: widget.board,
                                                            selectedMembers:  widget
                                                                .boardModel
                                                                .boardMember!
                                                                .boardMembers!,
                                                            onApplyPressed: () {
                                                              setState(() {
                                                                showMembers =
                                                                    true;
                                                              });
                                                            },
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const SuccessDialog(
                                                            title: "Warning",
                                                            subtitle:
                                                                "No Board Members Found\nPlease Add Board Members First",
                                                            lottieAsset:
                                                                "assets/lottie_assets/main_lottie_assets/lottie_attension.json",
                                                          );
                                                        },
                                                      );
                                                    }
                                                  } else {
                                                    /// Show a warning message to the user that only the task owner can add members.
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return const SuccessDialog(
                                                          title: "Warning",
                                                          subtitle:
                                                              "Only task owner can add members",
                                                          lottieAsset:
                                                              "assets/lottie_assets/main_lottie_assets/error.json",
                                                        );
                                                      },
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                            CustomContainerWithImage(
                                              imagePath:
                                                  "assets/icons_assets/task_assets/Square.svg",
                                              text: 'Check List',
                                              // changeColor: widget
                                              //         .cardModel
                                              //         .cardCheckLists![0]
                                              //         .checkListTitle!
                                              //         .isNotEmpty &&
                                              changeColor: widget
                                                      .cardModel
                                                      .cardCheckLists!
                                                      .isNotEmpty &&
                                                  widget
                                                          .cardModel
                                                          .cardCheckLists![0]
                                                          .checkListStatus!
                                                          .last !=
                                                      "deleted",
                                              onPressed: () {
                                                hapticController
                                                    .triggerHapticFeedback(
                                                        vibration: VibrateType
                                                            .mediumImpact,
                                                        hapticFeedback:
                                                            HapticFeedback
                                                                .mediumImpact);

                                                /// show dialog for adding checklist
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CopyCardDialouge(
                                                      textController:
                                                          checkListController,
                                                      title: "Add Checklist",
                                                      cardModel:
                                                          widget.cardModel,
                                                      board: widget.board,
                                                      isCheckList: true,
                                                      onPressed: () {
                                                        print(
                                                            checkListController
                                                                .text);
                                                        if (checkListController
                                                            .text.isNotEmpty) {
                                                          setState(() {
                                                            showChecklistSection =
                                                                !showChecklistSection;
                                                          });
                                                        }
                                                      },
                                                      iconUrl:
                                                          'assets/icons_assets/task_assets/CheckSquareIcon.svg',
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomContainerWithImage(
                                              imagePath:
                                                  "assets/icons_assets/main_icons_assets/icons_calendar.svg",
                                              text: 'Dates',
                                              isShown : showDates,
                                              changeColor: widget
                                                          .cardModel
                                                          .startDate!
                                                          .startDate!
                                                          .isNotEmpty &&
                                                      widget
                                                          .cardModel
                                                          .startTime!
                                                          .startTime!
                                                          .isNotEmpty
                                                  ? true
                                                  : false,
                                              onPressed: () {
                                                setState(() {
                                                  showDates = !showDates;
                                                });
                                                hapticController
                                                    .triggerHapticFeedback(
                                                        vibration: VibrateType
                                                            .mediumImpact,
                                                        hapticFeedback:
                                                            HapticFeedback
                                                                .mediumImpact);

                                                /// check if user is task owner or not and show dialog for adding dates
                                                if (widget.cardModel.startDate!
                                                        .startDate!.isEmpty &&
                                                    widget.cardModel.startTime!
                                                        .startTime!.isEmpty) {
                                                  if (widget
                                                          .cardModel
                                                          .cardCreator!
                                                          .cardCreator!
                                                          .last ==
                                                      Get.find<
                                                              MainCoreEmployeeController>()
                                                          .employeeEntity!
                                                          .email!) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return

                                                            //AddDeadline();

                                                            AddEditCardDeadlineDialouge(
                                                          title:
                                                              "Task Deadline",
                                                          cardModel:
                                                              widget.cardModel,
                                                          board: widget.board,
                                                          onPressed: () {
                                                            setState(() {
                                                              log('1show asasd $showDates');

                                                              showDates = !showDates;
                                                              log('2show asasd $showDates');
                                                            });
                                                          },
                                                          iconUrl:
                                                              'assets/icons_assets/task_assets/taskDeadline.svg',
                                                        );
                                                      },
                                                    );
                                                    /* showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return CopyCardDialouge(
                                                        title: "Task Deadline",
                                                        cardModel:
                                                            widget.cardModel,
                                                        board: widget.board,
                                                        onPressed: () {
                                                          setState(() {
                                                            showDates = true;
                                                          });
                                                        },
                                                        isDates: true,
                                                        iconUrl:
                                                            'assets/icons_assets/task_assets/taskDeadline.svg',
                                                      );
                                                    },
                                                  );*/
                                                  } else {
                                                    /// Show a warning message to the user that only the task owner can add deadline.
                                                    // showDialog(
                                                    //   context: context,
                                                    //   builder: (context) {
                                                    //     return const SuccessDialog(
                                                    //       title: "Warning",
                                                    //       subtitle:
                                                    //           "Only task owner can add deadline",
                                                    //       lottieAsset:
                                                    //           "assets/lottie_assets/main_lottie_assets/error.json",
                                                    //     );
                                                    //   },
                                                    // );
                                                  }
                                                }
                                              },
                                            ),

                                            /// Attachments section
                                            CustomContainerWithImage(
                                              imagePath: "assets/icons_assets/task_assets/attachsquare.svg",
                                              text: 'Attachments',
                                              changeColor: widget.cardModel.cardAttachments?.cardAttachments?.isNotEmpty == true &&
                                                  widget.cardModel.cardAttachments?.cardAttachmentsStatus?.contains("uploaded") == true,
                                              isShown: showAttachment,
                                              onPressed: () {
                                                hapticController.triggerHapticFeedback(
                                                  vibration: VibrateType.mediumImpact,
                                                  hapticFeedback: HapticFeedback.mediumImpact,
                                                );

                                                bool hasAttachments = widget.cardModel.cardAttachments?.cardAttachments?.isNotEmpty == true &&
                                                    widget.cardModel.cardAttachments?.cardAttachmentsStatus?.contains("uploaded") == true;

                                                if (hasAttachments) {
                                                  // If attachments exist, toggle showAttachment
                                                  setState(() {
                                                    showAttachment = !showAttachment;
                                                  });
                                                } else {
                                                  // If no attachments exist, open the dialog
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return CopyCardDialouge(
                                                        title: "Add Attachment",
                                                        cardModel: widget.cardModel,
                                                        department: widget.department,
                                                        board: widget.board,
                                                        onPressed: () {
                                                          setState(() {
                                                            showAttachment = true;
                                                          });
                                                        },
                                                        isAttachment: true,
                                                        iconUrl: 'assets/icons_assets/task_assets/attachsquareIcon.svg',
                                                      );
                                                    },
                                                  );
                                                }

                                                print('Attachment Container Pressed!');
                                              },
                                            ),

                                          ],
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),

                            /// Members Section
                            ////////////////////////////////////////////////////////
                            /// Check if the card has members or not
                            /// showMembers
                                if (widget.cardModel.cardMembers!.cardMembers!
                          .isNotEmpty &&
                      widget.cardModel.cardMembers!.cardMembers!
                          .isNotEmpty && showMembers) ...[
                                  SizedBox(
                                    height: 0.015.h,
                                  ),
                                  SectionTitle(
                                    title: 'Members',
                                  ),
                                  /// show members
                                  MemberContainer(
                                    boardModel: widget.boardModel,
                                    department: widget
                                        .boardModel
                                        .boardDeparment!
                                        .boardgDepartment!
                                        .last,
                                    showMembers: true,
                                    board: widget.boardModel.boardName!
                                        .boardgName!.last,
                                    cardModel: widget.cardModel,
                                    toggleShowMembers: toggleShowMembers,
                                  ),
                                ],



                            /// Check List Section
                            /////////////////////////////////////////////////////////////////
                            /// Check if the card has checklist or not
                            if (widget.cardModel.cardCheckLists!.isNotEmpty &&
                                widget.cardModel.cardCheckLists![0]
                                    .checkListStatus!.last !=
                                    "deleted") ...[
                              /// show checklist
                              ChecklistWidget(
                                checklist: widget.cardModel.cardCheckLists![0],
                                board: widget.board,
                                cardModel: widget.cardModel,
                                boardModel: null,
                              ),

                              Padding(
                                padding: EdgeInsets.only(top: 0.02.h),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ListView.builder(
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: cardCheckLists.length,
                                    itemBuilder: (context, index) {
                                      print(
                                          "listview: ${cardCheckLists[index].checkListTitle!.last}");
                                      return Padding(
                                        padding:
                                        EdgeInsets.only(bottom: 0.02.h),
                                        child: ChecklistWidget(
                                          board: widget.board,
                                          boardModel: widget.boardModel,
                                          cardModel: widget.cardModel,
                                          checklist: cardCheckLists[index],
                                          onDeletePressed: () {
                                            hapticController
                                                .triggerHapticFeedback(
                                              vibration:
                                              VibrateType.heavyImpact,
                                              hapticFeedback:
                                              HapticFeedback.heavyImpact,
                                            );
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return DeletOrArchiveDialog(
                                                  yesOnPressed: () {
                                                    // Navigator.of(
                                                    //   //         context)
                                                    //   //     .pop();
                                                    // showLoadingIndicator();

                                                    // showChecklistSection = false;
                                                    //widget.checklistItems.removeAt(index);
                                                    controller
                                                        .updateCard(
                                                      cardModel:
                                                      widget.cardModel,
                                                      board: widget.board,
                                                      checkListStatus:
                                                      "deleted",
                                                      currentCheckList:
                                                      cardCheckLists[index],
                                                    )
                                                        .then((e) {
                                                      //  hideLoadingIndicator();

                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                      PersistentNavBarNavigator
                                                          .pushNewScreen(
                                                        context,
                                                        withNavBar: false,
                                                        screen:
                                                        TaskDetailsMobile(
                                                          cards: widget.cards,
                                                          department: widget
                                                              .boardModel
                                                              .boardDeparment!
                                                              .boardgDepartment!
                                                              .last,
                                                          board: widget.board,
                                                          cardModel:
                                                          widget.cardModel,
                                                          boardModel:
                                                          widget.boardModel,
                                                          /*
                                                    listName: getStringAtIndex(
                                                        selectedIndex),
                                                        */
                                                        ),
                                                      );
                                                    });
                                                    // setState(() {
                                                    //   // Navigator.of(
                                                    //   //         context)
                                                    //   //     .pop();
                                                    // });

                                                    // RestartWidget
                                                    //     .restartApp(
                                                    //         context);
                                                  },
                                                  isDelete: true,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 15)
                            ],

                            /// Dates Section
                            ////////////////////////////////////////////
                            /// Check if the card has dates or not
                            if (widget.cardModel.startDate!.startDate!
                                    .isNotEmpty &&
                                widget.cardModel.startTime!.startTime!
                                    .isNotEmpty && showDates) ...[
                              // SizedBox(
                              //   height: 0.015.h,
                              // ),
                              SizedBox(
                                height: 20,
                              ),
                              /// show dates section
                              DeadlineSection(     // todo :: remove edit icon and make on text field
                                  cardModel: widget.cardModel,
                                  board: widget.board,
                                  toggleShowMembers: toggleShowMembers),

                            ],

                            ///Show Attachment Section
                            /////////////////////////////////////////////////
                            /// Check if the card has attachments or not
                            if (widget.cardModel.cardAttachments!
                                    .cardAttachments!.isNotEmpty &&
                                widget.cardModel.cardAttachments!
                                    .cardAttachmentsStatus!
                                    .contains("uploaded") && showAttachment) ...[
                              SizedBox(
                                height: 0.015.h,
                              ),
                              /// show attachment section
                              AttachmentSection(
                                showAttach: showAttachment,
                                toggleShowAttach: toggleShowAttach,
                                cardModel: widget.cardModel,
                                board: widget.board,
                                  department: widget.department.tr
                              ),
                            ],

                            SizedBox(
                              height: 0.015.h,
                            ),

                            ////////////////////////////////////////////////
                            /// Comments Section
                            ////////////////////////////////////////////////
                            CommentsSection(
                              board: widget.board,
                              cardModel: widget.cardModel,
                              department: widget.department,
                            ),
                            SizedBox(
                              height: 0.015.h,
                            ),
                          ],
                        ),
                      ),
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
