import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/helper/task_management_module/borad/view/board_details/widget/custom_board_details.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/core/nav_bar_package.dart/functions.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/checklist_item.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/task_details_screen_mobile.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/custom_appbar_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_black_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_search.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_upper_filter.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/copy_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_members_dialog_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_task_container_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/theme/app_colors.dart';

/// Date Created :12/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives: this screen is the Project page, this page consist of multiple widgets:
/// view available tasks
/// navigate to the task detailes
///
class ProjectScreenMobile extends StatefulWidget {
  BoardModel? boardModel;

  ProjectScreenMobile({
    super.key,
    required this.boardModel,
  });

  @override
  State<ProjectScreenMobile> createState() => _ProjectScreenMobileState();
}

class _ProjectScreenMobileState extends State<ProjectScreenMobile> {
  TaskDetailsController taskController = Get.find();
  BoardController bController = Get.find();
  late String cardFilter;
  List<CardModel> searchCards = [];
  // List<CardModel> filterCards=[];

  @override
  void initState() {
    // تأجيل التحديث حتى بعد انتهاء عملية البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchCards = [];
      taskController.filterCards = [];
      taskController.currentCardMembers = [];
      taskController.setMembers(widget.boardModel!);
      bController.updatefilterCards(widget.boardModel!.cards,'todo');
      for (var element in widget.boardModel!.cards) {
        if (element.cardStatus!.cardStatus!.last == "todo") {
          taskController.filterCards.add(element);
        }
      }
      taskController.selectedIndex = 0;
      cardFilter = 'todo';
});
      /// check if card has uploaded attachments or not

    super.initState();
  }

  /// Returns a card list based on the given index.
  String getStringAtIndex(int index) {
    switch (index) {
      case 0:
        return "To Do".tr;
      case 1:
        return "Doing".tr;
      case 2:
        return "Done".tr;
      case 3:
        return "Archived".tr;
      case 4:
        return "Deleted".tr;
      default:
        return "Invalid index".tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BoardController>(
      builder: (bController) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Container(
              color: themeController.currentTheme == AppColors.lightTheme
                  ? AppColors.colorLightGrey
                  : AppColors.colorBlack,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAppBarMobile(
                        showIcon: true,
                        title: widget
                            .boardModel!.boardName!.boardgName!.last.capitalize,
                        imagePath: "assets/icons_assets/main_icons_assets/shareIcon.svg",
                        isProject: false,
                        onIconPressed: () {
                          hapticController.triggerHapticFeedback(
                              vibration: VibrateType.mediumImpact,
                              hapticFeedback: HapticFeedback.mediumImpact);
                          // Set the board members.
                          if (widget.boardModel!.boardCreator! ==
                              Get.find<MainCoreEmployeeController>()
                                  .employeeEntity!
                                  .email!) {
                            List<String> boardMembers =
                                taskController.currentCardMembers;

                            if (taskController.currentCardMembers.isNotEmpty) {
                              if (boardMembers[0] ==
                                  Get.find<MainCoreEmployeeController>()
                                      .employeeEntity!
                                      .email!) {
                                boardMembers.removeAt(0);
                              }
                            }

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomMemberDialogMobile(
                                  currentListItem: CheckListItems(),
                                  assignCardMember: true,
                                  board: widget
                                      .boardModel!.boardName!.boardgName!.last,
                                  cardModel: CardModel(),
                                  edit: true,
                                  isboard: true,
                                  boardModel: widget.boardModel!,
                                  onApplyPressed: () {
                                    setState(() {});
                                  },
                                  selectedMembers: boardMembers,
                                );
                              },
                            );
                          } else {
                            /// Show a warning message to the user that only the board owner can set members.
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const SuccessDialog(
                                  title: "Warning",
                                  subtitle: "Only Board Owner Can Set Members",
                                  lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                                );
                              },
                            );
                          }
                          /*showDialog(
                              context: context,
                              builder: (context) {
                                return ShareBoardDialogue(
                                  boardModel: widget.boardModel!,
                                );
                              });*/
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomBoardDetails(board: widget.boardModel!),
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                        color: themeController.currentTheme ==
                            AppColors.lightTheme
                            ? AppColors.colorLightGrey
                            : AppColors.colorBlack,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Upper Filters Section
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0.0.w, vertical: 10),
                              child: UpperFilters(
                                cardFilter: true,
                                filterTitles: const [
                                  'To Do',
                                  'Doing',
                                  'Done',
                                  'Archived',
                                  'Deleted',
                                ],
                                selectedIndex: bController.selectedIndex,
                                selectedIndexState: (value) {
                                  setState(() {
                                    bController.selectedIndex = value;
                                  });
                                },
                                selectedDepartmentState: (value) {
                                  setState(
                                        () {
                                      cardFilter = value;
                                      bController.onCardSearch = false;
                                      bController.filterCards = [];
                                      if (value.trim() == 'To Do') {
                                        for (var element
                                        in widget.boardModel!.cards) {
                                          if (element.cardStatus!.cardStatus!
                                              .last ==
                                              "todo") {
                                            bController.filterCards
                                                .add(element);
                                          }
                                        }
                                      } else {
                                        for (var element
                                        in widget.boardModel!.cards) {
                                          if (element.cardStatus!.cardStatus!
                                              .last ==
                                              value.toLowerCase()) {
                                            bController.filterCards
                                                .add(element);
                                          }
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                            // Search Field
                            SizedBox(
                              height: 0.045.h,
                              child: CustomSearchFiled2(
                                onBoardDetails: true,
                                secondActionIcon: 'assets/icons/g4581.svg',
                                secondActionIconColor:
                                AppColors.colorLightGrey,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                hint: "Search".tr,
                                hintStyle: AppFontStyle.cairoRegularStyle
                                    .copyWith(
                                    fontSize: FontConstants.fontSize016.h,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer),
                                keyBoardType: TextInputType.text,
                                onChanged: (value) {
                                  // Filter the cards based on the search text
                                  setState(() {
                                    bController.onCardSearch = true;
                                    searchCards = bController.filterCards
                                        .where((element) => element
                                        .cardName!.cardName!.last
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                        .toList();
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 0.015.h,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                    ? AppColors.colorWhite
                                    : Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              height: 0.66.h,
                              width: double.infinity,
                              child: widget.boardModel!.cards.isNotEmpty
                                  ? bController.onCardSearch
                              // Display the search results
                                  ? ListView.builder(
                                itemCount: searchCards.length,
                                itemBuilder: (BuildContext context,
                                    int index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 0.015.h),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        if (index == 0)
                                          SizedBox(height: 0.015.h),
                                        CustomTaskContainerMobile(
                                          taskTitle:
                                          searchCards[index]
                                              .cardName!
                                              .cardName!
                                              .last,
                                          boardImage:
                                          searchCards[index]
                                              .cardImage!
                                              .cardImage!
                                              .last,
                                          boardModel:
                                          widget.boardModel,
                                          board: widget
                                              .boardModel!
                                              .boardName!
                                              .boardgName!
                                              .last,
                                          cardModel:
                                          searchCards[index],
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
                                              TaskDetailsMobile(
                                                department: widget
                                                    .boardModel!
                                                    .boardDeparment!
                                                    .boardgDepartment!
                                                    .last,
                                                board: widget
                                                    .boardModel!
                                                    .boardName!
                                                    .boardgName!
                                                    .last,
                                                cardModel:
                                                searchCards[
                                                index],
                                                boardModel: widget
                                                    .boardModel!,
                                                cards: searchCards,
                                                /*
                                                      listName: getStringAtIndex(
                                                          selectedIndex),
                                                          */
                                              ),
                                            );
                                          },

                                          /// use only if its archive
                                          isArchive: () async {
                                            if (searchCards[index]
                                                .cardCreator!
                                                .cardCreator!
                                                .last ==
                                                Get.find<
                                                    MainCoreEmployeeController>()
                                                    .employeeEntity!
                                                    .email!) {
                                              int statusIndex =
                                                  searchCards[index]
                                                      .cardStatus!
                                                      .cardStatus!
                                                      .length;
                                              await bController
                                                  .updateCard(
                                                cardModel:
                                                searchCards[
                                                index],
                                                board: widget
                                                    .boardModel!
                                                    .boardName!
                                                    .boardgName!
                                                    .last,
                                                archiveReturn: true,
                                                boardModel: widget
                                                    .boardModel!,
                                                cardStatus: searchCards[
                                                index]
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
                                              bController
                                                  .selectedIndex),
                                        ),
                                        //  if (index == listCounter)
                                        SizedBox(height: 0.01.h),
                                        if (index ==
                                            bController.filterCards
                                                .length -
                                                1)
                                        // Show "Add More" button at the end of the list
                                          Padding(
                                            padding:
                                            EdgeInsets.symmetric(
                                                horizontal:
                                                0.02.w),
                                            child: CustomBlackButton(
                                              buttonText:
                                              'Add More'.tr,
                                              onPressed: () {
                                                hapticController.triggerHapticFeedback(
                                                    vibration:
                                                    VibrateType
                                                        .lightImpact,
                                                    hapticFeedback:
                                                    HapticFeedback
                                                        .lightImpact);
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext
                                                  context) {
                                                    return CopyCardDialouge(
                                                      board: widget
                                                          .boardModel!
                                                          .boardName!
                                                          .boardgName!
                                                          .last,
                                                      /*boardModel: widget
                                                                .boardModel!,*/
                                                      title:
                                                      "Create Card",
                                                      onPressed: () {
                                                        setState(
                                                                () {});
                                                      },
                                                      isCard: true,
                                                      isCreatingCard:
                                                      true,
                                                      iconUrl:
                                                      'assets/icons_assets/task_assets/addCardIcon.svg',
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),

                                        /// use only if its archive
                                      ],
                                    ),
                                  );
                                },
                              )

                              /// this is used when there is no search
                                  : ListView.builder(
                                /* itemCount: widget.boardModel!.cards
                                          .length, */
                                itemCount:
                                bController.filterCards.length,
                                itemBuilder: (BuildContext context,
                                    int index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 0.015.h),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        if (index == 0)
                                          SizedBox(height: 0.015.h),
                                        CustomTaskContainerMobile(
                                          taskTitle: bController
                                              .filterCards[index]
                                              .cardName!
                                              .cardName!
                                              .last,
                                          boardImage: bController
                                              .filterCards[index]
                                              .cardImage!
                                              .cardImage!
                                              .last,
                                          boardModel:
                                          widget.boardModel,
                                          board: widget
                                              .boardModel!
                                              .boardName!
                                              .boardgName!
                                              .last,
                                          cardModel: bController
                                              .filterCards[index],
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
                                              withNavBar: false,
                                              screen:
                                              TaskDetailsMobile(
                                                department: widget
                                                    .boardModel!
                                                    .boardDeparment!
                                                    .boardgDepartment!
                                                    .last,
                                                board: widget
                                                    .boardModel!
                                                    .boardName!
                                                    .boardgName!
                                                    .last,
                                                cardModel: bController
                                                    .filterCards[
                                                index],
                                                boardModel: widget
                                                    .boardModel!,
                                                cards: bController
                                                    .filterCards,
                                                /*
                                                      listName: getStringAtIndex(
                                                          selectedIndex),
                                                          */
                                              ),
                                            );
                                          },

                                          /// use only if its archive
                                          isArchive: () async {
                                            if (bController
                                                .filterCards[
                                            index]
                                                .cardCreator!
                                                .cardCreator!
                                                .last ==
                                                Get.find<
                                                    MainCoreEmployeeController>()
                                                    .employeeEntity!
                                                    .email!) {
                                              int statusIndex =
                                                  bController
                                                      .filterCards[
                                                  index]
                                                      .cardStatus!
                                                      .cardStatus!
                                                      .length;

                                              await bController
                                                  .updateCard(
                                                cardModel: bController
                                                    .filterCards[
                                                index],
                                                board: widget
                                                    .boardModel!
                                                    .boardName!
                                                    .boardgName!
                                                    .last,
                                                boardModel: widget
                                                    .boardModel!,
                                                archiveReturn: true,
                                                cardStatus: bController
                                                    .filterCards[
                                                index]
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
                                              bController
                                                  .selectedIndex),
                                        ),
                                        //  if (index == listCounter)
                                        SizedBox(height: 0.01.h),
                                        if (index ==
                                            bController.filterCards
                                                .length -
                                                1)
                                        // Show "Add More" button at the end of the list
                                          Padding(
                                            padding:
                                            EdgeInsets.symmetric(
                                                horizontal:
                                                0.02.w),
                                            child: CustomBlackButton(
                                              buttonText:
                                              'Add More'.tr,
                                              onPressed: () {
                                                hapticController.triggerHapticFeedback(
                                                    vibration:
                                                    VibrateType
                                                        .lightImpact,
                                                    hapticFeedback:
                                                    HapticFeedback
                                                        .lightImpact);
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext
                                                  context) {
                                                    return CopyCardDialouge(
                                                      board: widget
                                                          .boardModel!
                                                          .boardName!
                                                          .boardgName!
                                                          .last,
                                                      /*boardModel: widget
                                                                .boardModel!,*/
                                                      title:
                                                      "Create Card",
                                                      onPressed: () {
                                                        setState(
                                                                () {});
                                                      },
                                                      isCard: true,
                                                      isCreatingCard:
                                                      true,
                                                      iconUrl:
                                                      'assets/icons_assets/task_assets/addCardIcon.svg',
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              )
                                  : Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 0.02.w),
                                    child: CustomBlackButton(
                                      buttonText: 'Add Card'.tr,
                                      onPressed: () {
                                        hapticController
                                            .triggerHapticFeedback(
                                            vibration: VibrateType
                                                .lightImpact,
                                            hapticFeedback:
                                            HapticFeedback
                                                .lightImpact);
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext context) {
                                            return CopyCardDialouge(
                                              board: widget
                                                  .boardModel!
                                                  .boardName!
                                                  .boardgName!
                                                  .last,
                                              /*widget.boardModel!,*/
                                              title: "Create Card",
                                              onPressed: () {
                                                setState(() {});
                                              },
                                              isCard: true,
                                              isCreatingCard: true,
                                              iconUrl:
                                              'assets/icons_assets/task_assets/addCardIcon.svg',
                                            );
                                          },
                                        );
                                        // setState(() {
                                        //   listCounter += 1;
                                        //   print(listCounter);
                                        // });
                                        // RestartWidget.restartApp(context);
                                      },
                                    ),
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
            ),
          ),
        );
      },
    );
  }
}
