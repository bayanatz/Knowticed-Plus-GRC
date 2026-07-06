import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/circle_progress.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_search.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/filters_appbar.dart';
import 'package:demo_app/core/utils/app_image_provider.dart';

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

class CustomShareMemberDialogTablet extends StatefulWidget {
  final VoidCallback? onApplyPressed;
  final BoardModel board;
  final List<String> selectedMembers;
  final bool edit;

  const CustomShareMemberDialogTablet({
    super.key,
    this.onApplyPressed,
    required this.board,
    required this.selectedMembers,
    required this.edit,
  });
  @override
  _CustomShareMemberDialogTabletState createState() =>
      _CustomShareMemberDialogTabletState();
}

class _CustomShareMemberDialogTabletState
    extends State<CustomShareMemberDialogTablet> {
  TaskDetailsController taskController = Get.find();
  BoardController boardController = Get.find();
  List<Widget> selectedPersons = [];
  List<Person> persons = [];
  List<Person> searchPersons = [];

  @override
  void initState() {
    super.initState();
    taskController.onCardMemeberSearch = false;
    for (var element
        in taskController.addEmployeeController.allEmployeesEntities!) {
      if (element.email! !=
          Get.find<MainCoreEmployeeController>().employeeEntity!.email!) {
        persons.add(
          Person(
            fullName: Get.locale.toString().contains('en')
                ? "${element.firstName!} ${element.middleName!}"
                : "${element.firstNameInArabic!}  ${element.lastNameInArabic!}",
            email: element.email!,
            imageUrl: boardController.getSingleImage(element.email!),
            isSelected:
                (widget.edit && widget.selectedMembers.contains(element.email!))
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

  @override
  Widget build(BuildContext context) {
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final HapticController hapticController = Get.put(HapticController());
    return GetBuilder<BoardController>(
      builder: (controller) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: isVertical ? 0.1.w : 0.3.h,
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
            height: 0.8.h,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isVertical ? 0.025.w : 0.04.h,
                  vertical: isVertical ? 0.015.h : 0.025.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FiltersAppBar(
                    imageUrl: "assets/icons_assets/task_assets/memberIcon.svg",
                    title: "Members",
                  ),
                  CustomSearchFiled2(
                    secondActionIcon: 'assets/icons/g4581.svg',
                    secondActionIconColor: AppColors.colorLightGrey,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surface, //Theme.of(context).colorScheme.surfaceVariant,
                    hint: "Search".tr,
                    hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: isVertical
                            ? FontConstants.fontSize016.h
                            : FontConstants.fontSize022.h,
                        fontWeight: FontWeight.w500,
                        height: 0.0018.h,
                        color: Theme.of(context).colorScheme.inverseSurface),
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
                  Padding(
                    padding: EdgeInsets.only(
                      top: isVertical ? 0.01.h : 0.02.h,
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
                                          fontSize: isVertical
                                              ? FontConstants.fontSize021.h
                                              : FontConstants.fontSize026.h,
                                          fontWeight: FontWeight.w600,
                                          height: isVertical ? 0 : 0.002.h,
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
                  SizedBox(
                    height: isVertical ? 0.0.h : 0.02.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Suggestions'.tr,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: isVertical
                                ? FontConstants.fontSize021.h
                                : FontConstants.fontSize026.h,
                            fontWeight: FontWeight.w600,
                            height: 0.002.h,
                            color: AppColors.lightPrimary),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: isVertical ? 0.01.h : 0.02.h,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: taskController.onCardMemeberSearch
                          ? Column(
                              children: [
                                for (var person in searchPersons)
                                  ListTile(
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
                                    title: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          '${person.fullName.capitalize}',
                                          style: AppFontStyle.cairoRegularStyle
                                              .copyWith(
                                            fontSize: isVertical
                                                ? FontConstants.fontSize020.h
                                                : FontConstants.fontSize025.h,
                                            fontWeight: FontWeight.w400,
                                            height: isVertical ? 1.6 : 0.002.h,
                                            color: themeController
                                                        .currentTheme ==
                                                    AppColors.lightTheme
                                                ? AppColors.colorBlack
                                                : AppColors.colorWhiteDark,
                                          )),
                                    ),
                                    trailing: InkWell(
                                      child: GestureDetector(
                                        onTap: () {
                                          hapticController
                                              .triggerHapticFeedback(
                                                  vibration:
                                                      VibrateType.mediumImpact,
                                                  hapticFeedback: HapticFeedback
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
                                                color: AppColors.lightPrimary,
                                                height: isVertical
                                                    ? 0.03.h
                                                    : 0.035.h,
                                              )
                                            : SvgPicture.asset(
                                                'assets/icons_assets/main_icons_assets/CheckListOff.svg',
                                                height: isVertical
                                                    ? 0.03.h
                                                    : 0.035.h,
                                              ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Column(
                              children: [
                                for (var person in persons)
                                  ListTile(
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
                                    title: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          '${person.fullName.capitalize}',
                                          style: AppFontStyle.cairoRegularStyle
                                              .copyWith(
                                            fontSize: isVertical
                                                ? FontConstants.fontSize020.h
                                                : FontConstants.fontSize025.h,
                                            fontWeight: FontWeight.w400,
                                            height: isVertical ? 1.6 : 0.002.h,
                                            color: themeController
                                                        .currentTheme ==
                                                    AppColors.lightTheme
                                                ? AppColors.colorBlack
                                                : AppColors.colorWhiteDark,
                                          )),
                                    ),
                                    trailing: InkWell(
                                      child: GestureDetector(
                                        onTap: () {
                                          hapticController
                                              .triggerHapticFeedback(
                                                  vibration:
                                                      VibrateType.mediumImpact,
                                                  hapticFeedback: HapticFeedback
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
                                                color: AppColors.lightPrimary,
                                                height: isVertical
                                                    ? 0.03.h
                                                    : 0.035.h,
                                              )
                                            : SvgPicture.asset(
                                                'assets/icons_assets/main_icons_assets/CheckListOff.svg',
                                                height: isVertical
                                                    ? 0.03.h
                                                    : 0.035.h,
                                              ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                  /*
              SizedBox(
                height: 0.02.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: ColumnRequestData(
                        fillColor: Colors.transparent,
                        title: "Start Date",
                        isTextField: true,
                        hint: hintDate,
                        enabled: false,
                        isOptional: false,
                        isExpanded: true,
                        hasPrefix: true,
                        hasSuffix: true,
                        suffixUrl: "assets/icons_assets/main_icons_assets/calendar2.svg",
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 0.02.w,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: ColumnRequestData(
                        fillColor: Colors.transparent,
                        title: "End Date",
                        isTextField: true,
                        hint: hintDate,
                        isOptional: false,
                        isExpanded: true,
                        enabled: false,
                        hasPrefix: true,
                        hasSuffix: true,
                        suffixUrl: "assets/icons_assets/main_icons_assets/calendar2.svg",
                      ),
                    ),
                  ),
                ],
              ),
             */
                  SizedBox(
                    height: 0.01.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.01.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        controller.loading
                            ? const Center(child: CircleProgress())
                            : ElevatedButton(
                                onPressed: () {
                                  hapticController.triggerHapticFeedback(
                                      vibration: VibrateType.heavyImpact,
                                      hapticFeedback:
                                          HapticFeedback.heavyImpact);
                                  if (widget.onApplyPressed != null) {
                                    widget.onApplyPressed!();
                                    List<String> members = [];
                                    for (var element in persons) {
                                      if (element.isSelected) {
                                        members.add(element.email);
                                        print(element.email);
                                        print(element.fullName);
                                      }
                                    }
                                    controller
                                        .updateBoard(
                                      boardId: widget.board.boardId!,
                                      boardModel: widget.board,
                                      invitationMember: members,
                                    )
                                        .then((value) {
                                      // systemLogsController.systemLogsAction(
                                      //     SystemActions.inviteBoardMembers);
                                    });
                                    setState(() {
                                      selectedPersons.clear();
                                      Navigator.pop(context);
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
                                  minimumSize: Size(0.13.h, 0.05.h),
                                ),
                                child: Text(
                                  'Apply'.tr,
                                  style: AppFontStyle.cairoRegularStyle
                                      .copyWith(
                                          fontSize: isVertical
                                              ? FontConstants.fontSize021.h
                                              : FontConstants.fontSize026.h,
                                          fontWeight: FontWeight.w500,
                                          height: isVertical ? 1.6 : 0.002.h,
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
