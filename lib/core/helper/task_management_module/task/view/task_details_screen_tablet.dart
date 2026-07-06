// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/attachment/tablet_view/attachment_section_tablet.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/checklist/checklist_section_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/comment/comments_column_tablet.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/comment/comments_section.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/deadline/mobile_view/deadLine_section_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/header/header_section.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/header/task_details_header_section.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/member/member_section_mobile.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_appbar.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drawer.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/add_edit_card_deadline_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/copy_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/delete_archive_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_members_dialog_Tablet.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_task_components_detailes.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';

/// Date Created :21/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives:  this file represents the task details screen , this screen can be accessed by taping on the task container in the project screen
/// this file has all the customization of the data previously showed in the project scrren

class TaskDetailsTabletScreen extends StatefulWidget {
  final String projectName;
  final String listName;
  final String department;
  final List<CardModel> cards;
  final CardModel currentCard;
  final BoardModel boardModel;

  const TaskDetailsTabletScreen({
    super.key,
    required this.projectName,
    required this.listName,
    required this.department,
    required this.cards,
    required this.boardModel,
    required this.currentCard,
  });

  @override
  State<TaskDetailsTabletScreen> createState() =>
      _TaskDetailsTabletScreenState();
}

class _TaskDetailsTabletScreenState extends State<TaskDetailsTabletScreen> {
  bool showMembers = false;
  int selectedIndex = 0;
  late String departmentFilter;

  bool showChecklistSection = false;
  bool showDates = false;
  bool showAttachment = false;
  int attachCounter = 5;
  bool slideActive = false;

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

  List<TextEditingController> checklistControllers = [];
  bool _checkListExpanded = false;

  void _updateCheckListExpanded(bool value) {
    setState(() {
      _checkListExpanded = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = Get.put(HapticController());
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final TextStyle titleStyle = AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: orientation
            ? FontConstants.fontSize019.h
            : FontConstants.fontSize022.h,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.inverseSurface,
        height: 1.6);

    cardCheckLists = widget.currentCard.cardCheckLists!.where(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // CustomDrawer(
                //   selectedIndex: 2,
                // ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.start,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomAppBar(),
                        Container(
                          color: orientation
                              ? themeController.currentTheme ==
                                      AppColors.lightTheme
                                  ? AppColors.colorLightGrey
                                  : AppColors.colorBlack
                              : Theme.of(context).colorScheme.inversePrimary,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // First Column (Grey)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0.02.h,
                                ),
                                color: themeController.currentTheme ==
                                        AppColors.lightTheme
                                    ? AppColors.colorLightGrey
                                    : AppColors.colorBlack,
                                width: orientation ? 0.87.w : 0.64.w,
                                height: orientation ? 0.89.h : 0.87.h,

                                /// this section is the bread crumbs for the page, the user can navigate back to the board and project page by pressing on them
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 0.02.h,
                                      ),

                                      /// This widget has the bread crumbs section, with the task name, list name, more button
                                      TaskDetailsAppBarTablet(
                                        boardModel: widget.boardModel,
                                        listName: widget.currentCard.cardStatus!
                                            .cardStatus!.last,
                                        cards: widget.cards,
                                        projectName: widget.projectName,
                                        taskName: widget.currentCard.cardName!
                                            .cardName!.last,
                                      ),

                                      /// Header Section includies: - Task Image, Task name, task Description
                                      TaskDetailsHeaderWidget(
                                        card: widget.currentCard,
                                        board: widget.projectName,
                                        department: widget.department,
                                      ),

                                      ///This Container is responsible for adding members, adding checklist, dates and attachments
                                      ///Add Quick Actions
                                      ////////////////////////////////////////////////////////
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0.025.h,
                                            vertical: 0.02.h),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Add Quick Actions".tr,
                                                style: titleStyle,
                                              ),
                                              SizedBox(
                                                height: 0.015.h,
                                              ),
                                              Column(
                                                children: [
                                                  orientation
                                                      ? Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      CustomContainerWithImage(
                                                                    imagePath:
                                                                        "assets/icons_assets/task_assets/member.svg",
                                                                    text:
                                                                        'Members',
                                                                    changeColor: widget
                                                                            .currentCard
                                                                            .cardMembers!
                                                                            .cardMembersStatus!
                                                                            .contains("invited")
                                                                        ? true
                                                                        : false,
                                                                    onPressed:
                                                                        () {
                                                                      hapticController.triggerHapticFeedback(
                                                                          vibration: VibrateType
                                                                              .mediumImpact,
                                                                          hapticFeedback:
                                                                              HapticFeedback.mediumImpact);

                                                                      /// check if user is task owner or not and show dialog for adding members
                                                                      if (!widget
                                                                          .currentCard
                                                                          .cardMembers!
                                                                          .cardMembersStatus!
                                                                          .contains(
                                                                              "invited")) {
                                                                        if (widget.currentCard.cardCreator!.cardCreator!.last ==
                                                                            Get.find<MainCoreEmployeeController>().employeeEntity!.email!) {
                                                                          List<String>
                                                                              boardMembers =
                                                                              [];
                                                                          if (widget.boardModel.boardMember?.boardMembers != null &&
                                                                              widget.boardModel.boardMember?.boardMembers != []) {
                                                                            for (int i = 0;
                                                                                i < widget.boardModel.boardMember!.boardMembers!.length;
                                                                                i++) {
                                                                              if (widget.boardModel.boardMember!.boardMembersStatus![i] == "invited") {
                                                                                boardMembers.add(widget.boardModel.boardMember!.boardMembers![i]);
                                                                              }
                                                                            }
                                                                          }
                                                                          if (boardMembers
                                                                              .isNotEmpty) {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return CustomMemberDialogTablet(
                                                                                  board: widget.projectName,
                                                                                  boardModel: widget.boardModel,
                                                                                  cardModel: widget.currentCard,
                                                                                  assignCardMember: true,
                                                                                  selectedMembers: const [],
                                                                                  onApplyPressed: () {
                                                                                    setState(() {
                                                                                      showMembers = true;
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
                                                                                  subtitle: "No Board Members Found\nPlease Add Board Members First",
                                                                                  lottieAsset: "assets/lottie_assets/main_lottie_assets/lottie_attension.json",
                                                                                );
                                                                              },
                                                                            );
                                                                          }
                                                                        } else {
                                                                          /// Show a warning message to the user that only the task owner can add members.
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return const SuccessDialog(
                                                                                title: "Warning",
                                                                                subtitle: "Only task owner can add members",
                                                                                lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                                                                              );
                                                                            },
                                                                          );
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 0.04.w,
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      CustomContainerWithImage(
                                                                    imagePath:
                                                                        "assets/icons_assets/task_assets/Square.svg",
                                                                    text:
                                                                        'Check Lists',
                                                                    changeColor:
                                                                        cardCheckLists
                                                                            .isNotEmpty,
                                                                    onPressed:
                                                                        () {
                                                                      hapticController.triggerHapticFeedback(
                                                                          vibration: VibrateType
                                                                              .mediumImpact,
                                                                          hapticFeedback:
                                                                              HapticFeedback.mediumImpact);
                                                                      TextEditingController
                                                                          newController =
                                                                          TextEditingController();

                                                                      /// show dialog for adding checklist
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return CopyCardDialouge(
                                                                            textController:
                                                                                newController,
                                                                            cardModel:
                                                                                widget.currentCard,
                                                                            board:
                                                                                widget.projectName,
                                                                            title:
                                                                                "Add Checklists",
                                                                            onPressed:
                                                                                () {
                                                                              checklistControllers.add(newController);
                                                                              print(newController.text);
                                                                              if (newController.text.isNotEmpty) {
                                                                                setState(() {
                                                                                  showChecklistSection = !showChecklistSection;
                                                                                });
                                                                              }
                                                                            },
                                                                            isCheckList:
                                                                                true,
                                                                            iconUrl:
                                                                                'assets/icons_assets/task_assets/CheckSquareIcon.svg',
                                                                          );
                                                                        },
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 0.015.h,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      CustomContainerWithImage(
                                                                    imagePath:
                                                                        "assets/icons_assets/main_icons_assets/icons_calendar.svg",
                                                                    text:
                                                                        'Dates',
                                                                    changeColor: widget.currentCard.startDate!.startDate!.isNotEmpty &&
                                                                            widget.currentCard.startTime!.startTime!.isNotEmpty
                                                                        ? true
                                                                        : false,
                                                                    onPressed:
                                                                        () {
                                                                      hapticController
                                                                          .triggerHapticFeedback(
                                                                        vibration:
                                                                            VibrateType.mediumImpact,
                                                                        hapticFeedback:
                                                                            HapticFeedback.mediumImpact,
                                                                      );

                                                                      /// check if user is task owner or not and show dialog for adding dates
                                                                      if (widget
                                                                              .currentCard
                                                                              .startDate!
                                                                              .startDate!
                                                                              .isEmpty &&
                                                                          widget
                                                                              .currentCard
                                                                              .startTime!
                                                                              .startTime!
                                                                              .isEmpty) {
                                                                        if (widget.currentCard.cardCreator!.cardCreator!.last ==
                                                                            Get.find<MainCoreEmployeeController>().employeeEntity!.email!) {
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return AddEditCardDeadlineDialouge(
                                                                                title: "Task Deadline",
                                                                                cardModel: widget.currentCard,
                                                                                board: widget.projectName,
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    showDates = true;
                                                                                  });
                                                                                },
                                                                                iconUrl: 'assets/icons_assets/task_assets/taskDeadline.svg',
                                                                              );
                                                                            },
                                                                          );
                                                                          /* 
                                                                                                    showDialog( 
                                                                                                      context: context, 
                                                                                                      builder: (BuildContext  context) {
                                                                                                       return CopyCardDialouge(
                                                                                                        title:"Task Deadline",
                                                                                                        cardModel: widget.currentCard,
                                                                                                         board: widget.projectName,
                                                                                                         onPressed: () {
                                                                                                                        setState(() {
                                                                                                                          showDates = true;
                                                                                                                           });
                                                                                                                         },
                                                                                                                         isDates: true,
                                                                                                                          iconUrl:'assets/icons_assets/task_assets/taskDeadline.svg',
                                                                                                         );
                                                                                                     },
                                                                                                    );*/
                                                                        } else {
                                                                          /// Show a warning message to the user that only the task owner can add deadline.
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return const SuccessDialog(
                                                                                title: "Warning",
                                                                                subtitle: "Only task owner can add deadline",
                                                                                lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                                                                              );
                                                                            },
                                                                          );
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 0.04.w,
                                                                ),

                                                                /// Attachments section
                                                                Expanded(
                                                                  child:
                                                                      CustomContainerWithImage(
                                                                    imagePath:
                                                                        "assets/icons_assets/task_assets/attachsquare.svg",
                                                                    text:
                                                                        'Attachments',
                                                                    changeColor: widget
                                                                            .currentCard
                                                                            .cardAttachments!
                                                                            .cardAttachments!
                                                                            .isNotEmpty &&
                                                                        widget
                                                                            .currentCard
                                                                            .cardAttachments!
                                                                            .cardAttachmentsStatus!
                                                                            .contains("uploaded"),
                                                                    onPressed:
                                                                        () {
                                                                      hapticController.triggerHapticFeedback(
                                                                          vibration: VibrateType
                                                                              .mediumImpact,
                                                                          hapticFeedback:
                                                                              HapticFeedback.mediumImpact);

                                                                      /// show dialog for adding attachments
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return CopyCardDialouge(
                                                                            title:
                                                                                "Add Attachment",
                                                                            cardModel:
                                                                                widget.currentCard,
                                                                            board:
                                                                                widget.projectName,
                                                                            onPressed:
                                                                                () {
                                                                              setState(() {
                                                                                showAttachment = true;
                                                                              });
                                                                            },
                                                                            isAttachment:
                                                                                true,
                                                                            iconUrl:
                                                                                'assets/icons_assets/task_assets/attachsquareIcon.svg',
                                                                          );
                                                                        },
                                                                      );

                                                                      print(
                                                                          'Attachment Container Pressed!');
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        )
                                                      : Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            CustomContainerWithImage(
                                                              imagePath:
                                                                  "assets/icons_assets/task_assets/member.svg",
                                                              text: 'Members',
                                                              changeColor: widget
                                                                      .currentCard
                                                                      .cardMembers!
                                                                      .cardMembersStatus!
                                                                      .contains(
                                                                          "invited")
                                                                  ? true
                                                                  : false,
                                                              onPressed: () {
                                                                hapticController.triggerHapticFeedback(
                                                                    vibration:
                                                                        VibrateType
                                                                            .mediumImpact,
                                                                    hapticFeedback:
                                                                        HapticFeedback
                                                                            .mediumImpact);

                                                                /// check if user is task owner or not and show dialog for adding members
                                                                if (!widget
                                                                    .currentCard
                                                                    .cardMembers!
                                                                    .cardMembersStatus!
                                                                    .contains(
                                                                        "invited")) {
                                                                  if (widget
                                                                          .currentCard
                                                                          .cardCreator!
                                                                          .cardCreator!
                                                                          .last ==
                                                                      Get.find<
                                                                              MainCoreEmployeeController>()
                                                                          .employeeEntity!
                                                                          .email!) {
                                                                    List<String>
                                                                        boardMembers =
                                                                        [];
                                                                    if (widget.boardModel.boardMember?.boardMembers !=
                                                                            null &&
                                                                        widget.boardModel.boardMember?.boardMembers !=
                                                                            []) {
                                                                      for (int i =
                                                                              0;
                                                                          i < widget.boardModel.boardMember!.boardMembers!.length;
                                                                          i++) {
                                                                        if (widget.boardModel.boardMember!.boardMembersStatus![i] ==
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
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return CustomMemberDialogTablet(
                                                                            boardModel:
                                                                                widget.boardModel,
                                                                            board:
                                                                                widget.projectName,
                                                                            cardModel:
                                                                                widget.currentCard,
                                                                            assignCardMember:
                                                                                true,
                                                                            selectedMembers: const [],
                                                                            onApplyPressed:
                                                                                () {
                                                                              setState(() {
                                                                                showMembers = true;
                                                                              });
                                                                            },
                                                                          );
                                                                        },
                                                                      );
                                                                    } else {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return const SuccessDialog(
                                                                            title:
                                                                                "Warning",
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
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return const SuccessDialog(
                                                                          title:
                                                                              "Warning",
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
                                                              text:
                                                                  'Check Lists',
                                                              changeColor: widget
                                                                          .currentCard
                                                                          .cardCheckLists !=
                                                                      null &&
                                                                  widget
                                                                      .currentCard
                                                                      .cardCheckLists!
                                                                      .isNotEmpty,
                                                              onPressed: () {
                                                                hapticController.triggerHapticFeedback(
                                                                    vibration:
                                                                        VibrateType
                                                                            .mediumImpact,
                                                                    hapticFeedback:
                                                                        HapticFeedback
                                                                            .mediumImpact);
                                                                TextEditingController
                                                                    newController =
                                                                    TextEditingController();

                                                                /// show dialog for adding checklist
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return CopyCardDialouge(
                                                                      textController:
                                                                          newController,
                                                                      cardModel:
                                                                          widget
                                                                              .currentCard,
                                                                      board: widget
                                                                          .projectName,
                                                                      title:
                                                                          "Add Checklists",
                                                                      onPressed:
                                                                          () {
                                                                        checklistControllers
                                                                            .add(newController);
                                                                        print(newController
                                                                            .text);
                                                                        if (newController
                                                                            .text
                                                                            .isNotEmpty) {
                                                                          setState(
                                                                              () {
                                                                            showChecklistSection =
                                                                                !showChecklistSection;
                                                                          });
                                                                        }
                                                                      },
                                                                      isCheckList:
                                                                          true,
                                                                      iconUrl:
                                                                          'assets/icons_assets/task_assets/CheckSquareIcon.svg',
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                            CustomContainerWithImage(
                                                              imagePath:
                                                                  "assets/icons_assets/main_icons_assets/icons_calendar.svg",
                                                              text: 'Dates',
                                                              changeColor: widget
                                                                          .currentCard
                                                                          .startDate!
                                                                          .startDate!
                                                                          .isNotEmpty &&
                                                                      widget
                                                                          .currentCard
                                                                          .startTime!
                                                                          .startTime!
                                                                          .isNotEmpty
                                                                  ? true
                                                                  : false,
                                                              onPressed: () {
                                                                hapticController
                                                                    .triggerHapticFeedback(
                                                                  vibration:
                                                                      VibrateType
                                                                          .mediumImpact,
                                                                  hapticFeedback:
                                                                      HapticFeedback
                                                                          .mediumImpact,
                                                                );

                                                                /// check if user is task owner or not and show dialog for adding dates
                                                                if (widget
                                                                        .currentCard
                                                                        .startDate!
                                                                        .startDate!
                                                                        .isEmpty &&
                                                                    widget
                                                                        .currentCard
                                                                        .startTime!
                                                                        .startTime!
                                                                        .isEmpty) {
                                                                  if (widget
                                                                          .currentCard
                                                                          .cardCreator!
                                                                          .cardCreator!
                                                                          .last ==
                                                                      Get.find<
                                                                              MainCoreEmployeeController>()
                                                                          .employeeEntity!
                                                                          .email!) {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AddEditCardDeadlineDialouge(
                                                                          title:
                                                                              "Task Deadline",
                                                                          cardModel:
                                                                              widget.currentCard,
                                                                          board:
                                                                              widget.projectName,
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              showDates = true;
                                                                            });
                                                                          },
                                                                          iconUrl:
                                                                              'assets/icons_assets/task_assets/taskDeadline.svg',
                                                                        );
                                                                      },
                                                                    );
                                                                    /* 
                                            showDialog( 
                                              context: context, 
                                              builder: (BuildContext  context) {
                                               return CopyCardDialouge(
                                                title:"Task Deadline",
                                                cardModel: widget.currentCard,
                                                 board: widget.projectName,
                                                 onPressed: () {
                                                  setState(() {
                                                    showDates = true;
                                                     });
                                                   },
                                                   isDates: true,
                                                    iconUrl:'assets/icons_assets/task_assets/taskDeadline.svg',
                                                 );
                                             },
                                            );*/
                                                                  } else {
                                                                    /// Show a warning message to the user that only the task owner can add deadline.
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return const SuccessDialog(
                                                                          title:
                                                                              "Warning",
                                                                          subtitle:
                                                                              "Only task owner can add deadline",
                                                                          lottieAsset:
                                                                              "assets/lottie_assets/main_lottie_assets/error.json",
                                                                        );
                                                                      },
                                                                    );
                                                                  }
                                                                }
                                                              },
                                                            ),

                                                            /// Attachments section
                                                            CustomContainerWithImage(
                                                              imagePath:
                                                                  "assets/icons_assets/task_assets/attachsquare.svg",
                                                              text:
                                                                  'Attachments',
                                                              changeColor: widget
                                                                      .currentCard
                                                                      .cardAttachments!
                                                                      .cardAttachments!
                                                                      .isNotEmpty &&
                                                                  widget
                                                                      .currentCard
                                                                      .cardAttachments!
                                                                      .cardAttachmentsStatus!
                                                                      .contains(
                                                                          "uploaded"),
                                                              onPressed: () {
                                                                hapticController.triggerHapticFeedback(
                                                                    vibration:
                                                                        VibrateType
                                                                            .mediumImpact,
                                                                    hapticFeedback:
                                                                        HapticFeedback
                                                                            .mediumImpact);

                                                                /// show dialog for adding attachments
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return CopyCardDialouge(
                                                                      title:
                                                                          "Add Attachment",
                                                                      cardModel:
                                                                          widget
                                                                              .currentCard,
                                                                      board: widget
                                                                          .projectName,
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          showAttachment =
                                                                              true;
                                                                        });
                                                                      },
                                                                      isAttachment:
                                                                          true,
                                                                      iconUrl:
                                                                          'assets/icons_assets/task_assets/attachsquareIcon.svg',
                                                                    );
                                                                  },
                                                                );

                                                                print(
                                                                    'Attachment Container Pressed!');
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                  SizedBox(
                                                    height: 0.005.h,
                                                  )
                                                ],
                                              ),
                                            ]),
                                      ),

                                      /// Members Section
                                      ////////////////////////////////////////////////////////
                                      /// Check if the card has members or not
                                      if (widget.currentCard.cardMembers!
                                          .cardMembersStatus!
                                          .contains("invited")) ...[
                                        SizedBox(
                                          height: 0.015.h,
                                        ),

                                        /// show members
                                        MemberContainer(
                                          boardModel: widget.boardModel,
                                          department: widget
                                              .boardModel
                                              .boardDeparment!
                                              .boardgDepartment!
                                              .last,
                                          showMembers: showMembers,
                                          board: widget.boardModel.boardName!
                                              .boardgName!.last,
                                          cardModel: widget.currentCard,
                                          toggleShowMembers: toggleShowMembers,
                                        ),
                                      ],

                                      /// Check List Section
                                      /////////////////////////////////////////////////////////////////
                                      /// Check if the card has checklist or not
                                      if (widget.currentCard.cardCheckLists !=
                                              null &&
                                          widget.currentCard.cardCheckLists!
                                              .isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.only(top: 0.02.h),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: cardCheckLists.length,
                                              itemBuilder: (context, index) {
                                                print(
                                                    "listview: ${cardCheckLists[index].checkListTitle!.last}");
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 0.02.h),
                                                  child: ChecklistWidget(
                                                    boardModel:
                                                        widget.boardModel,
                                                    board: widget.projectName,
                                                    cardModel:
                                                        widget.currentCard,
                                                    checklist:
                                                        cardCheckLists[index],
                                                    onDeletePressed: () {
                                                      hapticController
                                                          .triggerHapticFeedback(
                                                        vibration: VibrateType
                                                            .heavyImpact,
                                                        hapticFeedback:
                                                            HapticFeedback
                                                                .heavyImpact,
                                                      );
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
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
                                                                cardModel: widget
                                                                    .currentCard,
                                                                board: widget
                                                                    .projectName,
                                                                checkListStatus:
                                                                    "deleted",
                                                                currentCheckList:
                                                                    cardCheckLists[
                                                                        index],
                                                              )
                                                                  .then((e) {
                                                                //  hideLoadingIndicator();

                                                                Navigator
                                                                    .pushReplacement(
                                                                  context,
                                                                  PageTransition(
                                                                    type: PageTransitionType
                                                                        .fade,
                                                                    child:
                                                                        CustomDrawer(
                                                                      initialIndex:
                                                                          1,
                                                                      screens: [
                                                                        Container(),
                                                                        TaskDetailsTabletScreen(
                                                                          currentCard:
                                                                              widget.currentCard,
                                                                          boardModel:
                                                                              widget.boardModel,
                                                                          cards:
                                                                              widget.cards,
                                                                          projectName:
                                                                              widget.projectName,
                                                                          listName:
                                                                              widget.listName,
                                                                          department: widget.department,
                                                                        ),
                                                                        Container(),
                                                                        Container(),
                                                                        Container(),
                                                                        Container(),
                                                                        Container(),
                                                                        Container(),
                                                                      ],
                                                                    ),
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

                                      // if (widget.currentCard.cardCheckLists![0]
                                      //         .checkListTitle!.isNotEmpty &&
                                      //     widget.currentCard.cardCheckLists![0]
                                      //             .checkListStatus!.last !=
                                      //         "deleted") ...[
                                      //   SizedBox(
                                      //     height: 0.015.h,
                                      //   ),
                                      //   ChecklistWidget(
                                      //     board: widget.projectName,
                                      //     cardModel: widget.currentCard,
                                      //     checklist: widget
                                      //             .currentCard.cardCheckLists![
                                      //         0], //checklistControllers,
                                      //   ),
                                      // ],

                                      ////////////////////////////////////////////////////////////////

                                      /// Dates Section
                                      ////////////////////////////////////////////
                                      /// Check if the card has dates or not
                                      if (widget.currentCard.startDate!
                                              .startDate!.isNotEmpty &&
                                          widget.currentCard.startTime!
                                              .startTime!.isNotEmpty) ...[
                                        SizedBox(
                                          height: 0.015.h,
                                        ),
                                        DeadlineContainer(
                                          showDates: showDates,
                                          toggleShowMembers: toggleShowDates,
                                          cardModel: widget.currentCard,
                                          board: widget.projectName,
                                        ),
                                      ],

                                      ///Show Attachment Section
                                      /////////////////////////////////////////////////
                                      /// Check if the card has attachments or not
                                      if (widget.currentCard.cardAttachments!
                                              .cardAttachments!.isNotEmpty &&
                                          widget.currentCard.cardAttachments!
                                              .cardAttachmentsStatus!
                                              .contains("uploaded")) ...[
                                        SizedBox(
                                          height: 0.015.h,
                                        ),
                                        AttachmentSectionTablet(
                                          cardModel: widget.currentCard,
                                          board: widget.projectName,
                                          showAttach: showAttachment,
                                          toggleShowAttach: toggleShowAttach,
                                        ),
                                      ],

                                      ////////////////////////////////////////////////
                                      ///Comments Section Veritcal
                                      /////////////////////////////////////////////////
                                      if (orientation)
                                        SizedBox(
                                          height: 0.015.h,
                                        ),
                                      if (orientation)
                                        CommentsSection(
                                          board: widget.projectName,
                                          cardModel: widget.currentCard,
                                          department: widget
                                              .boardModel
                                              .boardDeparment!
                                              .boardgDepartment!
                                              .last,
                                        ),
                                      ////////////////////////////////////////////////
                                      SizedBox(
                                        height: orientation ? 0 : 0.03.h,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              if (!orientation)

                                /// Second Column (White)
                                /// This column is the comments section for this specific task , their are containers to view the comments left on this section, who send it, in which time, and also the body of the comment
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CommentsSectionTablet(
                                        board: widget.projectName,
                                        cardModel: widget.currentCard,
                                        department: widget
                                            .boardModel
                                            .boardDeparment!
                                            .boardgDepartment!
                                            .last,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
