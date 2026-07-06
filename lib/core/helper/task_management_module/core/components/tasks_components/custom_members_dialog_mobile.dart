import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/checklist_item.dart';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_search.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/filters_appbar.dart';
import 'package:demo_app/core/utils/app_image_provider.dart';

/// Date Created :22/April/2024
/// Developer Name : Abdullah Ibrahim
/// App Version : Version 2
/// Objectives: represents the Members dialog for the task or the board
///
class Person {
  final String fullName;
  final String email;
  final String imageUrl;
  bool isSelected;

  Person({
    required this.fullName,
    required this.email,
    required this.imageUrl,
    this.isSelected = false,
  });
}

class CustomMemberDialogMobile extends StatefulWidget {
  final VoidCallback? onApplyPressed;

  final bool assignCardMember;
  final String board;
  final BoardModel? boardModel;
  final bool? isboard;
  final CardModel cardModel;
  final List<String> selectedMembers;
  final bool edit;
  final CheckListItems currentListItem;
  final CardCheckLists? currentCheckList;

  const CustomMemberDialogMobile({
    super.key,
    this.onApplyPressed,
    this.currentCheckList,
    required this.currentListItem,
    required this.assignCardMember,
    required this.board,
    required this.cardModel,
    required this.selectedMembers,
    this.edit = false,
    required this.boardModel,
    this.isboard,
  });

  @override
  _CustomMemberDialogMobileState createState() =>
      _CustomMemberDialogMobileState();
}

class _CustomMemberDialogMobileState extends State<CustomMemberDialogMobile> {
  TaskDetailsController taskController = Get.find();
  BoardController boardController = Get.find();
  List<Widget> selectedPersons = [];
  List<Person> persons = [];
  List<Person> searchPersons = [];

  MainCoreEmployeeController addEmployeeController =
      Get.put(MainCoreEmployeeController());
  List<String> boardMembers = [];
  @override
  void initState() {
    super.initState();
    taskController.onCardMemeberSearch = false;
    if (widget.boardModel?.boardMember?.boardMembers != null &&
        widget.boardModel?.boardMember?.boardMembers != []) {
      for (int i = 0;
          i < widget.boardModel!.boardMember!.boardMembers!.length;
          i++) {
        if (widget.boardModel!.boardMember!.boardMembersStatus![i] ==
            "invited") {
          boardMembers.add(widget.boardModel!.boardMember!.boardMembers![i]);
        }
      }
      // addEmployeeController.allEmployees!
      for (var element in boardMembers) {
        if (element !=
            Get.find<MainCoreEmployeeController>().employeeEntity!.email!) {
          persons.add(
            Person(
              fullName: addEmployeeController.getEmployeeName(element),
              email: element,
              imageUrl: boardController.getSingleImage(element),
              isSelected:
                  (widget.edit && widget.selectedMembers.contains(element))
                      ? true
                      : false,
            ),
          );
        }
      }
      selectedPersons = [];
      for (var person in persons) {
        if (person.isSelected) {
          selectedPersons.add(Padding(
            padding: EdgeInsets.only(
                right: Get.locale.toString().contains('en') ? 0.02.h : 0,
                left: Get.locale.toString().contains('ar') ? 0.02.h : 0),
            child: person.imageUrl.isURL
                ? CircleAvatar(
                    radius: 0.02.h,
                    backgroundImage: NetworkImage(person.imageUrl),
                  )
                : CircleAvatar(
                    radius: 0.02.h,
                    backgroundImage: appImageProvider(person.imageUrl),
                  ),
          ));
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = Get.put(HapticController());
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return GetBuilder<BoardController>(
      builder: (controller) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: 0.04.w,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            height: 0.5.h,
            width: double.infinity,
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 0.04.w, vertical: 0.02.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FiltersAppBar(
                    imageUrl: "assets/icons_assets/task_assets/memberIcon.svg",
                    title: "Members",
                  ),

                  /// Search field for the members
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.006.h),
                    child: SizedBox(
                      height: 0.045.h,
                      child: CustomSearchFiled2(
                        secondActionIcon: 'assets/icons/g4581.svg',
                        secondActionIconColor: AppColors.colorLightGrey,
                        fillColor: themeController.currentTheme ==
                                AppColors.lightTheme
                            ? AppColors.colorLightGrey
                            : AppColors.colorBlack,
                        hint: "Search".tr,
                        hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize016.h,
                            color: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer),
                        keyBoardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            taskController.onCardMemeberSearch = true;
                            searchPersons = persons
                                .where((element) => element.fullName
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                  ),

                  /// Selected members list
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 0.01.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: selectedPersons.isNotEmpty
                                  ? selectedPersons
                                  : [
                                      Text(
                                        'No Members Selected'.tr,
                                        style: AppFontStyle.cairoRegularStyle
                                            .copyWith(
                                          fontSize: FontConstants.fontSize020.h,
                                          fontWeight: FontWeight.w600,
                                          color: themeController.currentTheme ==
                                                  AppColors.lightTheme
                                              ? AppColors.colorGrey
                                              : AppColors.colorGreydark,
                                        ),
                                      )
                                    ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Suggestions list for the search
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Suggestions'.tr,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize020.h,
                            fontWeight: FontWeight.w600,
                            height: 0.002.h,
                            color: AppColors.lightPrimary),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: taskController.onCardMemeberSearch
                          ?

                          /// Display the search results
                          Column(
                              children: [
                                for (var person in searchPersons)
                                  SizedBox(
                                    height: 0.05.h,
                                    child: ListTile(
                                      leading: person.imageUrl.isURL
                                          ? CircleAvatar(
                                              radius: 0.02.h,
                                              backgroundImage:
                                                  NetworkImage(person.imageUrl))
                                          : CircleAvatar(
                                              radius: 0.02.h,
                                              backgroundImage:
                                                  appImageProvider(person.imageUrl),
                                            ),
                                      title: Text(
                                          '${person.fullName.capitalize}',
                                          style: AppFontStyle.cairoRegularStyle
                                              .copyWith(
                                            fontSize:
                                                FontConstants.fontSize018.h,
                                            fontWeight: FontWeight.w400,
                                            height: 0.00.h,
                                            color: themeController
                                                        .currentTheme ==
                                                    AppColors.lightTheme
                                                ? AppColors.colorBlack
                                                : AppColors.colorWhiteDark,
                                          )),
                                      trailing: InkWell(
                                        child: GestureDetector(
                                          onTap: () {
                                            hapticController
                                                .triggerHapticFeedback(
                                                    vibration: VibrateType
                                                        .mediumImpact,
                                                    hapticFeedback:
                                                        HapticFeedback
                                                            .mediumImpact);
                                            setState(() {
                                              person.isSelected =
                                                  !person.isSelected;
                                            });
                                            selectedPersons = [];

                                            for (var person in persons) {
                                              if (person.isSelected) {
                                                selectedPersons.add(Padding(
                                                  padding: EdgeInsets.only(
                                                      right: Get.locale
                                                              .toString()
                                                              .contains('en')
                                                          ? 0.02.h
                                                          : 0,
                                                      left: Get.locale
                                                              .toString()
                                                              .contains('ar')
                                                          ? 0.02.h
                                                          : 0),
                                                  child: person.imageUrl.isURL
                                                      ? CircleAvatar(
                                                          radius: 0.02.h,
                                                          backgroundImage:
                                                              NetworkImage(person
                                                                  .imageUrl))
                                                      : CircleAvatar(
                                                          radius: 0.02.h,
                                                          backgroundImage:
                                                              appImageProvider(person
                                                                  .imageUrl),
                                                        ),
                                                ));
                                              }
                                            }
                                          },
                                          child: person.isSelected
                                              ? SvgPicture.asset(
                                                  'assets/icons_assets/main_icons_assets/CheckListOn.svg',
                                                  color:
                                                      AppColors.lightPrimary,
                                                  height: 0.025.h,
                                                )
                                              : SvgPicture.asset(
                                                  'assets/icons_assets/main_icons_assets/CheckListOff.svg',
                                                  height: 0.025.h,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )

                          /// Display all the members
                          : Column(
                              children: [
                                for (var person in persons)
                                  SizedBox(
                                    height: 0.05.h,
                                    child: ListTile(
                                      leading: person.imageUrl.isURL
                                          ? CircleAvatar(
                                              radius: 0.02.h,
                                              backgroundImage:
                                                  NetworkImage(person.imageUrl))
                                          : CircleAvatar(
                                              radius: 0.02.h,
                                              backgroundImage:
                                                  appImageProvider(person.imageUrl),
                                            ),
                                      title: Text(
                                          '${person.fullName.capitalize}',
                                          style: AppFontStyle.cairoRegularStyle
                                              .copyWith(
                                            fontSize:
                                                FontConstants.fontSize018.h,
                                            fontWeight: FontWeight.w400,
                                            height: 0.00.h,
                                            color: themeController
                                                        .currentTheme ==
                                                    AppColors.lightTheme
                                                ? AppColors.colorBlack
                                                : AppColors.colorWhiteDark,
                                          )),
                                      trailing: InkWell(
                                        child: GestureDetector(
                                          onTap: () {
                                            hapticController
                                                .triggerHapticFeedback(
                                                    vibration: VibrateType
                                                        .mediumImpact,
                                                    hapticFeedback:
                                                        HapticFeedback
                                                            .mediumImpact);
                                            setState(() {
                                              person.isSelected =
                                                  !person.isSelected;
                                            });
                                            selectedPersons = [];

                                            for (var person in persons) {
                                              if (person.isSelected) {
                                                selectedPersons.add(Padding(
                                                  padding: EdgeInsets.only(
                                                      right: Get.locale
                                                              .toString()
                                                              .contains('en')
                                                          ? 0.02.h
                                                          : 0,
                                                      left: Get.locale
                                                              .toString()
                                                              .contains('ar')
                                                          ? 0.02.h
                                                          : 0),
                                                  child: person.imageUrl.isURL
                                                      ? CircleAvatar(
                                                          radius: 0.02.h,
                                                          backgroundImage:
                                                              NetworkImage(person
                                                                  .imageUrl))
                                                      : CircleAvatar(
                                                          radius: 0.02.h,
                                                          backgroundImage:
                                                              appImageProvider(person
                                                                  .imageUrl),
                                                        ),
                                                ));
                                              }
                                            }
                                          },
                                          child: person.isSelected
                                              ? SvgPicture.asset(
                                                  'assets/icons_assets/main_icons_assets/CheckListOn.svg',
                                                  color:
                                                      AppColors.lightPrimary,
                                                  height: 0.025.h,
                                                )
                                              : SvgPicture.asset(
                                                  'assets/icons_assets/main_icons_assets/CheckListOff.svg',
                                                  height: 0.025.h,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 0.02.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            hapticController.triggerHapticFeedback(
                                vibration: VibrateType.heavyImpact,
                                hapticFeedback: HapticFeedback.heavyImpact);

                            /// onApplyPressed
                            if (widget.onApplyPressed != null) {
                              widget.onApplyPressed!();

                              /// Get selected members from the list
                              List<String> members = [];
                              for (var element in persons) {
                                if (element.isSelected) {
                                  members.add(element.email);
                                  print(element.email);
                                  print(element.fullName);
                                }
                              }
                              if (widget.isboard == true) {
                                /// Update board with selected members
                                controller
                                    .updateBoard(
                                  boardModel: widget.boardModel!,
                                  boardId: widget.boardModel!.boardId!,
                                  invitationMember: members,
                                )
                                    .then((value) {
                                  Navigator.pop(context);
                                });
                              } else {
                                if (widget.assignCardMember) {
                                  controller
                                      .updateCard(
                                          invitationMember: members,
                                          cardModel: widget.cardModel,
                                          board: widget.board)
                                      .then((value) {});
                                } else {
                                  print("add members");
                                  controller
                                    ..updateCard(
                                            listItemMember: members,
                                            currentListItem:
                                                widget.currentListItem,
                                            currentCheckList:
                                                widget.currentCheckList,
                                            cardModel: widget.cardModel,
                                            board: widget.board)
                                        .then((value) {});
                                }
                                // /// Update card with selected members
                                // controller.updateCard(
                                //     invitationMember: members,
                                //     cardModel: widget.cardModel,
                                //     board: widget.board);
                              }

                              setState(() {
                                selectedPersons.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                persons.any((person) => person.isSelected)
                                    ? AppColors.bubbleColor
                                    : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            minimumSize: Size(0.13.h, 0.04.h),
                          ),
                          child: Text(
                            'Apply'.tr,
                            style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: FontConstants.fontSize020.h,
                                fontWeight: FontWeight.w500,
                                height: 0.002.h,
                                color: AppColors.textButton),
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
