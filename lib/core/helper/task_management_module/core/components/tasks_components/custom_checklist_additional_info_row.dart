import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';

import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/checklist_item.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_members_dialog_Tablet.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_members_dialog_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/image_row_widget.dart';

class CustomChecklistAdditionalInfoRow extends StatelessWidget {
  final CheckListItems currentListItem;
  final CardCheckLists? currentCheckList;
  final CardModel cardModel;
  final String board;
  final BoardModel boardModel;

  CustomChecklistAdditionalInfoRow(
      {super.key,
      required this.currentListItem,
      required this.currentCheckList,
      required this.cardModel,
      required this.boardModel,
      required this.board});

  BoardController controller = Get.put(BoardController());

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.width > 600;
    TextStyle textStyle = AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: isTablet
            ? (isPortrait
                ? FontConstants.fontSize022.w
                : FontConstants.fontSize012.w)
            : FontConstants.fontSize014.h,
        color: themeController.currentTheme == AppColors.lightTheme
            ? AppColors.colorBlack
            : AppColors.colorWhiteDark,
        fontWeight: FontWeight.w400,
        height: 2);
    DateTime? parsedEndDateTime;
    DateTime? parsedEndDate;
    // Parse the end date string (DD/MM/YYYY) into a DateTime object

    if (currentListItem.itemEndDate != null &&
        currentListItem.itemEndDate!.isNotEmpty) {
      parsedEndDate =
          DateFormat('dd/MM/yyyy').parse(currentListItem.itemEndDate!.last);
    }

    // Check if endTime is provided
    if (currentListItem.itemEndTime != null &&
        currentListItem.itemEndTime!.isNotEmpty) {
      // Parse the end time string (e.g., "09:30 AM")
      final timeFormat = DateFormat('hh:mm a'); // For parsing "09:30 AM" format
      final parsedEndTime = timeFormat.parse(currentListItem.itemEndTime!.last);

      // Combine the date and time into a full DateTime object
      if (parsedEndDate != null) {
        parsedEndDateTime = DateTime(
          parsedEndDate.year,
          parsedEndDate.month,
          parsedEndDate.day,
          parsedEndTime.hour,
          parsedEndTime.minute,
        );
      }
    } else {
      // If no time is provided, just use the date
      if (parsedEndDate != null) {
        parsedEndDateTime = DateTime(parsedEndDate.year, parsedEndDate.month,
            parsedEndDate.day, 23, 59, 59); // End of the day
      }
    }

    DateTime now = DateTime.now(); // Current date and time

    // Check if the deadline has passed
    bool isPastDeadline =
        parsedEndDateTime != null && parsedEndDateTime.isBefore(now);
    return Column(
      children: [
        if (isPortrait &&
            currentListItem.itemMembers != null &&
            currentListItem.itemMembers!.isNotEmpty)

          /// the following widget is responsible for showing the image row,
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.01.h),
            child: GestureDetector(
              onTap: () {
                if (isTablet) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomMemberDialogTablet(
                        board: board,
                        cardModel: cardModel,
                        boardModel: boardModel,
                        edit: currentListItem.itemMembers != null &&
                            currentListItem.itemMembers!.isNotEmpty,
                        currentListItem: currentListItem,
                        currentCheckList: currentCheckList,
                        assignCardMember: false,
                        selectedMembers: currentListItem.itemMembers ?? [],
                        onApplyPressed: () {},
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomMemberDialogMobile(
                        board: board,
                        boardModel: boardModel,
                        cardModel: cardModel,
                        edit: currentListItem.itemMembers != null &&
                            currentListItem.itemMembers!.isNotEmpty,
                        currentListItem: currentListItem,
                        currentCheckList: currentCheckList,
                        assignCardMember: false,
                        selectedMembers: currentListItem.itemMembers ?? [],
                        onApplyPressed: () {},
                      );
                    },
                  );
                }
              },
              child: ImageRowWidget(
                checkListImages: currentListItem.itemMembers!
                    .map((e) => controller.getSingleImage(e))
                    .toList(),
                memebrName: controller
                    .empFullName(
                      currentListItem.itemMembers![0],
                    )
                    .capitalize!,
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isPortrait &&
                currentListItem.itemMembers != null &&
                currentListItem.itemMembers!.isNotEmpty)
              SvgPicture.asset(
                width: isTablet ? (isPortrait ? 0.027.h : 0.035.h) : 0.05.w,
                'assets/icons_assets/task_assets/CheckSquare.svg',
                color: Colors.transparent,
              ),
            if (!isPortrait &&
                currentListItem.itemMembers != null &&
                currentListItem.itemMembers!.isNotEmpty)
              SizedBox(
                width: isTablet ? (isPortrait ? 0.02.w : 0.025.h) : 0.02.w,
              ),
            if (!isPortrait &&
                currentListItem.itemMembers != null &&
                currentListItem.itemMembers!.isNotEmpty)
              GestureDetector(
                onTap: () {
                  if (isTablet) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomMemberDialogTablet(
                          board: board,
                          cardModel: cardModel,
                          edit: currentListItem.itemMembers != null &&
                              currentListItem.itemMembers!.isNotEmpty,
                          currentListItem: currentListItem,
                          currentCheckList: currentCheckList,
                          boardModel: boardModel,
                          assignCardMember: false,
                          selectedMembers: currentListItem.itemMembers ?? [],
                          onApplyPressed: () {},
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomMemberDialogMobile(
                          board: board,
                          cardModel: cardModel,
                          boardModel: boardModel,
                          edit: currentListItem.itemMembers != null &&
                              currentListItem.itemMembers!.isNotEmpty,
                          currentListItem: currentListItem,
                          currentCheckList: currentCheckList,
                          assignCardMember: false,
                          selectedMembers: currentListItem.itemMembers ?? [],
                          onApplyPressed: () {},
                        );
                      },
                    );
                  }
                },
                child: ImageRowWidget(
                  checkListImages: currentListItem.itemMembers!
                      .map((e) => controller.getSingleImage(e))
                      .toList(),
                  memebrName: controller
                      .empFullName(
                        currentListItem.itemMembers![0],
                      )
                      .capitalize!,
                ),
              ),
            if (!isPortrait) const Spacer(),
            if (currentListItem.itemStartDate != null &&
                currentListItem.itemStartDate!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        width:
                            isTablet ? (isPortrait ? 0.03.w : 0.015.w) : 0.05.w,
                        'assets/icons_assets/main_icons_assets/icons_calendar.svg',
                        color: AppColors.grey,
                      ),
                      SizedBox(
                        width:
                            isTablet ? (isPortrait ? 0.01.w : 0.005.w) : 0.02.w,
                      ),
                      if (currentListItem.itemStartDate != null &&
                          currentListItem.itemStartDate!.isNotEmpty)
                        SizedBox(
                          //    color: Colors.amber,
                          width: isTablet
                              ? (isPortrait ? 0.23.w : 0.13.w)
                              : 0.32.w,
                          child: Text(
                            "Start Date: ${localizeNumber(currentListItem.itemStartDate!.last)}",
                            style: textStyle,
                          ),
                        ),
                    ],
                  ),
                  if (!isTablet)
                    SizedBox(
                      height: 0.01.h,
                    ),
                  if (currentListItem.itemStartTime != null &&
                      currentListItem.itemStartTime!.isNotEmpty)
                    Row(
                      children: [
                        SvgPicture.asset(
                          width: isTablet
                              ? (isPortrait ? 0.03.w : 0.015.w)
                              : 0.05.w,
                          "assets/icons_assets/task_assets/ClockCircleIcon.svg",
                          color: AppColors.grey,
                        ),
                        SizedBox(
                          width: isTablet
                              ? (isPortrait ? 0.01.w : 0.005.w)
                              : 0.02.w,
                        ),
                        SizedBox(
                          width: isTablet
                              ? (isPortrait ? 0.11.w : 0.06.w)
                              : 0.15.w,
                          child: Text(
                            localizeNumber(currentListItem.itemStartTime!.last),
                            style: textStyle.copyWith(),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            if (currentListItem.itemEndDate != null &&
                currentListItem.itemEndDate!.isNotEmpty)
              SizedBox(
                width: 0.02.w,
              ),
            if (isPortrait &&
                currentListItem.itemEndDate != null &&
                currentListItem.itemEndDate!.isNotEmpty)
              const Spacer(),
            if (currentListItem.itemEndDate != null &&
                currentListItem.itemEndDate!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        width:
                            isTablet ? (isPortrait ? 0.03.w : 0.015.w) : 0.05.w,
                        'assets/icons_assets/main_icons_assets/icons_calendar.svg',
                        color: isPastDeadline
                            ? AppColors.delete
                            : AppColors.grey,
                      ),
                      SizedBox(
                        width:
                            isTablet ? (isPortrait ? 0.01.w : 0.005.w) : 0.02.w,
                      ),
                      if (currentListItem.itemEndDate != null &&
                          currentListItem.itemEndDate!.isNotEmpty)
                        SizedBox(
                          width: isTablet
                              ? (isPortrait ? 0.23.w : 0.13.w)
                              : 0.32.w,
                          child: Text(
                            "End Date: ${localizeNumber(currentListItem.itemEndDate!.last)}",
                            style: textStyle.copyWith(
                              color: isPastDeadline ? AppColors.delete : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (!isTablet)
                    SizedBox(
                      height: 0.01.h,
                    ),
                  Row(
                    children: [
                      if (currentListItem.itemEndTime != null &&
                          currentListItem.itemEndTime!.isNotEmpty)
                        Row(
                          children: [
                            SvgPicture.asset(
                              width: isTablet
                                  ? (isPortrait ? 0.03.w : 0.015.w)
                                  : 0.05.w,
                              "assets/icons_assets/task_assets/ClockCircleIcon.svg",
                              color: isPastDeadline
                                  ? AppColors.delete
                                  : AppColors.grey,
                            ),
                            SizedBox(
                              width: isTablet
                                  ? (isPortrait ? 0.01.w : 0.005.w)
                                  : 0.02.w,
                            ),
                            SizedBox(
                              width: isTablet
                                  ? (isPortrait ? 0.11.w : 0.06.w)
                                  : 0.15.w,
                              //  color: Colors.amber,
                              child: Text(
                                localizeNumber(
                                    currentListItem.itemEndTime!.last),
                                style: textStyle.copyWith(
                                  color: isPastDeadline
                                      ? AppColors.delete
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(
                        width: 0.005.w,
                      ),
                      if (isPastDeadline)
                        Text(
                          "Exceeded Deadline".tr,
                          style: textStyle.copyWith(
                            fontSize: isTablet
                                ? (isPortrait
                                    ? FontConstants.fontSize020.w
                                    : FontConstants.fontSize010.w)
                                : FontConstants.fontSize012.h,
                            color: AppColors.delete,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
