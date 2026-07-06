// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/checklist_item.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_black_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_textfield_new.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/delete_archive_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/check_list_settings_menu.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_checklist_additional_info_row.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_container_header_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_members_dialog_Tablet.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/set_date_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/set_date_dialog_vertical.dart';

/// Date Created :21/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/November/2023 By Bassem
/// Objectives:  this file represents the checklist section, this file has a progress bar as a indication for the total finshed tasks.
/// also you can add a new element and it will reflect on the progress bar, for example if i entered two elements, and crossed one them by tapping on it, the progress bar will be 50%
/// i can delete this elemnt inside the list, and also i can delete the checklist it self if i dont need it in this project

class ChecklistSection extends StatefulWidget {
  final VoidCallback? onDeletePressed;
  final String? checkListName;
  final String? board;
  final CardCheckLists? cardCheckLists;
  BoardModel? boardModel;
  final CardModel? cardModel;

  final Function(bool)? onExpandCheckListChanged;
  ChecklistSection({
    super.key,
    required this.cardCheckLists,
    this.onDeletePressed,
    this.checkListName,
    this.onExpandCheckListChanged,
    this.board,
    this.cardModel,
    required this.boardModel,
  });

  // Getter method to access expandCheckList value
  bool get isCheckListExpanded => _ChecklistSectionState().expandCheckList;
  @override
  _ChecklistSectionState createState() => _ChecklistSectionState();
}

class _ChecklistSectionState extends State<ChecklistSection> {
  TaskDetailsController taskController = Get.find();

  List<String> items = [];

  Set<int> completedItems = {};
  TextEditingController itemController = TextEditingController();
  bool expandCheckList = false;

  void addItem(String itemName) {
    setState(() {
      items.add(itemName);
    });
    itemController.clear();
  }

  void toggleCompleted(int index) {
    setState(() {
      if (completedItems.contains(index)) {
        completedItems.remove(index);
        taskController.updateCard(
          cardModel: widget.cardModel!,
          board: widget.board!,
          checkListItemTitle: items[index],
          checkListItemStatus: "todo",
          currentCheckList: widget.cardCheckLists,
        );
      } else {
        completedItems.add(index);
        taskController.updateCard(
          cardModel: widget.cardModel!,
          board: widget.board!,
          checkListItemTitle: items[index],
          checkListItemStatus: "done",
          currentCheckList: widget.cardCheckLists,
        );
      }
    });
  }

  double calculateProgress() {
    if (items.isEmpty) {
      return 0.0;
    }
    return completedItems.length / items.length;
  }

  bool _isTextFieldNotEmpty = false;
  bool isYellow = false;

  @override
  void initState() {
    super.initState();
    itemController.addListener(_updateTextFieldState);
    _updateTextFieldState();
    widget.cardCheckLists!.checkListItems?.forEach((element) {
      if (element.itemStatus!.last != "deleted") {
        items.add(element.itemTitle!.last);
      }
      if (element.itemStatus!.last == "done") {
        completedItems.add(items.indexOf(element.itemTitle!.last));
      }
    });
  }

  void _updateTextFieldState() {
    setState(() {
      _isTextFieldNotEmpty = itemController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    itemController.removeListener(_updateTextFieldState);
    itemController.dispose();
    super.dispose();
  }

  void toggleExpandCheckList() {
    setState(() {
      expandCheckList = !expandCheckList;
    });
    // Call the callback function to update the parent widget's state
    widget.onExpandCheckListChanged!(expandCheckList);
  }

  CheckListItems? currentListItem;
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return GetBuilder<TaskDetailsController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomRowWithIcons(
              isCheckList: true,
              onTrashPressed: widget.onDeletePressed,
              iconPath: "assets/icons_assets/task_assets/CheckSquareIcon.svg",
              isExpand: expandCheckList,
              title: widget.checkListName!.tr,
              board: widget.board,
              cardModel: widget.cardModel,
              currentCheckList: widget.cardCheckLists,
              onArrowPressed: () {
                hapticController.triggerHapticFeedback(
                  vibration: VibrateType.lightImpact,
                  hapticFeedback: HapticFeedback.lightImpact,
                );

                setState(() {
                  expandCheckList = !expandCheckList;
                  print("current $expandCheckList");
                });
              },
            ),
            if (expandCheckList == true) SizedBox(height: 0.015.h),
            expandCheckList == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${(calculateProgress() * 100).toInt()}%',
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize020.h,
                            color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhiteDark,
                            height: 1.5),
                      ),
                      SizedBox(
                        width: 0.02.w,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 0.01.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: calculateProgress(),
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.lightPrimary,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : SizedBox.shrink(),
            if (expandCheckList) SizedBox(height: 0.015.h),
            expandCheckList == true
                ?
                // List of texts
                SizedBox(
                    height: null,
                    //height: isTablet ? null: ((calculateProgress() * 100).toInt() == 0)? 0.00.h:     0.1.h ,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 0.01.h : 0.005.h,
                              horizontal: isTablet ? 0.02.h : 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      toggleCompleted(index);
                                    },
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                            width: isTablet
                                                ? (isPortrait
                                                    ? 0.027.h
                                                    : 0.035.h)
                                                : 0.05.w,
                                            completedItems.contains(index)
                                                ? 'assets/icons_assets/main_icons_assets/CheckListOn.svg'
                                                : 'assets/icons_assets/task_assets/CheckSquare.svg',
                                            color: AppColors.lightPrimary),
                                        SizedBox(
                                          width: isTablet
                                              ? (isPortrait ? 0.02.w : 0.025.h)
                                              : 0.02.w,
                                        ),
                                        Text(
                                          items[index].capitalize as String,
                                          style: AppFontStyle.cairoRegularStyle
                                              .copyWith(
                                                  fontSize: isTablet
                                                      ? (isPortrait
                                                          ? FontConstants
                                                              .fontSize020.h
                                                          : FontConstants
                                                              .fontSize025.h)
                                                      : FontConstants
                                                          .fontSize018.h,
                                                  color: themeController
                                                              .currentTheme ==
                                                          AppColors.lightTheme
                                                      ? AppColors.colorBlack
                                                      : AppColors
                                                          .colorWhiteDark,
                                                  decoration: completedItems
                                                          .contains(index)
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : TextDecoration.none,
                                                  height: 1.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  InkWell(
                                      onTapUp: (details) {
                                        final iconPosition =
                                            details.globalPosition;
                                        checkListSettingsMenu(
                                          context: context,
                                          iconPosition: iconPosition,
                                          onAssignMembers: () {
                                            currentListItem = widget
                                                .cardCheckLists?.checkListItems
                                                ?.where((element) =>
                                                    element.itemTitle!.last ==
                                                    items[index])
                                                .first;
                                            //controller.onAssignMembers(context);
                                            print("add members");
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomMemberDialogTablet(
                                                  board: widget.board!,
                                                  cardModel: widget.cardModel!,
                                                  edit: currentListItem
                                                              ?.itemMembers !=
                                                          null &&
                                                      currentListItem!
                                                          .itemMembers!
                                                          .isNotEmpty,
                                                  currentListItem:
                                                      currentListItem,
                                                  boardModel: widget.boardModel,
                                                  currentCheckList:
                                                      widget.cardCheckLists,
                                                  assignCardMember: false,
                                                  selectedMembers:
                                                      currentListItem
                                                              ?.itemMembers ??
                                                          [],
                                                  onApplyPressed: () {},
                                                );
                                              },
                                            );
                                          },
                                          onSetDates: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ShowDateDialogs(
                                                  board: widget.board!,
                                                  cardModel: widget.cardModel!,
                                                  currentCheckList:
                                                      widget.cardCheckLists,
                                                  currentListItem: widget
                                                      .cardCheckLists
                                                      ?.checkListItems
                                                      ?.where((element) =>
                                                          element.itemTitle!
                                                              .last ==
                                                          items[index])
                                                      .first,
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: SvgPicture.asset(
                                        'assets/icons_assets/main_icons_assets/more_menu.svg',
                                        color: AppColors.colorDarkGrey,
                                        height: isPortrait ? 0.008.h : 0.01.h,
                                      )),
                                  SizedBox(width: isPortrait ? 0.02.w : 0.01.w),
                                  GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return DeletOrArchiveDialog(
                                              yesOnPressed: () async {
                                                await controller
                                                    .updateCard(
                                                  cardModel: widget.cardModel!,
                                                  board: widget.board!,
                                                  checkListItemTitle:
                                                      items[index],
                                                  checkListItemStatus:
                                                      "deleted",
                                                  currentCheckList:
                                                      widget.cardCheckLists,
                                                )
                                                    .then((value) {
                                                  items.removeAt(index);
                                                  completedItems.remove(index);
                                                  calculateProgress();
                                                });
                                                setState(() {});

                                                Navigator.of(context).pop();
                                              },
                                              isCheckListElement: true,
                                            );
                                          },
                                        );
                                      },
                                      child: SvgPicture.asset(
                                        'assets/icons_assets/task_assets/xClose.svg',
                                        height: 0.015.h,
                                      )),
                                ],
                              ),

                              /// This widget has the image view for the participents , and also the row of dates and time,
                              CustomChecklistAdditionalInfoRow(
                                currentListItem: widget
                                    .cardCheckLists!.checkListItems!
                                    .where((element) =>
                                        element.itemTitle!.last == items[index])
                                    .first,
                                boardModel: widget.boardModel!,
                                currentCheckList: widget.cardCheckLists,
                                board: widget.board!,
                                cardModel: widget.cardModel!,
                              ),
                              Divider(
                                thickness: 2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(),
            if (expandCheckList == true)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 0.005.h, horizontal: isTablet ? 0.02.h : 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomBlackButton(
                          isYellow: isYellow,
                          buttonText: 'Add Item'.tr,
                          onPressed: () {
                            hapticController.triggerHapticFeedback(
                                vibration: VibrateType.lightImpact,
                                hapticFeedback: HapticFeedback.lightImpact);
                            setState(() {
                              isYellow = !isYellow;
                            });
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                            onTap: widget.onDeletePressed,
                            child: SvgPicture.asset(
                              'assets/icons_assets/task_assets/deleteIcon.svg',
                              height: 0.025.h,
                              color: AppColors.red,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            if (expandCheckList == true && isYellow == true)
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isTablet ? 0.02.h : 0),
                child: Column(
                  crossAxisAlignment: isTablet
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 0.01.h,
                    ),
                    SizedBox(
                      width: isTablet ? 0.4.w : null,
                      height: 0.045.h,
                      child: CustomTextFieldContainer(
                        hint: "Enter New Element".tr,
                        textController: itemController,
                        fillColor: themeController.currentTheme ==
                                AppColors.lightTheme
                            ? AppColors.colorLightGrey
                            : AppColors.colorBlack,
                      ),
                    ),
                    SizedBox(
                      width: isTablet ? 0.4.w : null,
                      // color: Colors.amber,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.005.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  hapticController.triggerHapticFeedback(
                                      vibration: VibrateType.heavyImpact,
                                      hapticFeedback:
                                          HapticFeedback.heavyImpact);
                                  setState(() {
                                    isYellow = false;
                                    itemController.clear();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.colorWhiteDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  minimumSize: Size(
                                      0.13.h,
                                      isTablet
                                          ? (isPortrait ? 0.04.h : 0.05.h)
                                          : 0.05.h),
                                ),
                                child: Text(
                                  'Cancel'.tr,
                                  style: AppFontStyle.cairoRegularStyle
                                      .copyWith(
                                          fontSize: FontConstants.fontSize020.h,
                                          fontWeight: FontWeight.w500,
                                          height: isTablet
                                              ? (isPortrait ? 1.8 : 1.8)
                                              : 1.8,
                                          color: AppColors.colorBlack),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 0.04.w,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  hapticController.triggerHapticFeedback(
                                      vibration: VibrateType.heavyImpact,
                                      hapticFeedback:
                                          HapticFeedback.heavyImpact);
                                  setState(() {
                                    controller
                                        .updateCard(
                                      currentCheckList: widget.cardCheckLists,
                                      cardModel: widget.cardModel!,
                                      board: widget.board!,
                                      checkListItem: itemController.text,
                                    )
                                        .then((v) {
                                      addItem(itemController.text); /////////
                                    });
                                    //itemController.clear();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      itemController.text.isNotEmpty
                                          ? AppColors.bubbleColor
                                          : Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  minimumSize: Size(
                                      0.13.h,
                                      isTablet
                                          ? (isPortrait ? 0.04.h : 0.05.h)
                                          : 0.05.h),
                                ),
                                child: Text(
                                  'Add'.tr,
                                  style: AppFontStyle.cairoRegularStyle
                                      .copyWith(
                                          fontSize: FontConstants.fontSize020.h,
                                          fontWeight: FontWeight.w500,
                                          height: isTablet
                                              ? (isPortrait ? 1.8 : 1.8)
                                              : 1.8,
                                          color: AppColors.textButton),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class ShowDateDialogs extends StatelessWidget {
  final String board;
  final CardModel cardModel;

  final CheckListItems? currentListItem;
  final CardCheckLists? currentCheckList;

  const ShowDateDialogs({
    super.key,
    required this.board,
    required this.cardModel,
    this.currentListItem,
    this.currentCheckList,
  });

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait
        ? SetDateDialogVertical(
            board: board,
            cardModel: cardModel,
            currentListItem: currentListItem,
            currentCheckList: currentCheckList,
          )
        : SetDateDialog(
            board: board,
            cardModel: cardModel,
            currentListItem: currentListItem,
            currentCheckList: currentCheckList,
          );
  }
}
