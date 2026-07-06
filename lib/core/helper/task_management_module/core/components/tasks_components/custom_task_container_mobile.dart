import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/copy_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/delete_archive_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/delete_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/sort_option_widget.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';

/// Date Created :19/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives:  this file represents the  custom container for showing the project detailes inside the board screen
class CustomTaskContainerMobile extends StatefulWidget {
  final String taskTitle;
  final String listName;
  final String? boardImage;
  final VoidCallback onPressed;
  final VoidCallback? isArchive;
  final CardModel? cardModel;
  final String? board;
  final BoardModel? boardModel;

  const CustomTaskContainerMobile({
    super.key,
    required this.taskTitle,
    required this.listName,
    required this.onPressed,
    this.boardImage,
    this.isArchive,
    this.cardModel,
    this.board,
    this.boardModel,
  });

  @override
  State<CustomTaskContainerMobile> createState() =>
      _CustomTaskContainerMobileState();
}

class _CustomTaskContainerMobileState extends State<CustomTaskContainerMobile> {
  TextEditingController textController = TextEditingController();
  String? taskStatus = "important";
  String? taskCompletionPercentage = "90";
  Color? percentageColor = AppColors.unBlock;
  Color getProgressColor(String value) {
    if (value == "red") {
      return AppColors.delete;
    } else if (value == "orange") {
      return AppColors.warning;
    } else if (value == "yellow") {
      return AppColors.yellowColor;
    } else {
      return AppColors.unBlock;
    }
  }

  @override
  void initState() {
    if (widget.cardModel!.cardProgress!.cardProgress!.isNotEmpty &&
        widget.cardModel!.cardProgress!.cardProgress!.last != "0") {
      percentageColor = getProgressColor(
        widget.cardModel!.progressIndicator!.colors![widget
            .cardModel!.progressIndicator!.progressPercentage!
            .indexOf(widget.cardModel!.cardProgress!.cardProgress!.last)],
      );
    } else {
      percentageColor = AppColors.colorWhite;
    }

    super.initState();
  }

  String formatTimestampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat dateFormat = DateFormat("dd MMM yyyy 'at' hh : mm a");
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  String formatTimestampToStringInArabic(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat dateFormat =
        DateFormat("dd MMM yyyy ${'at'.tr} mm : hh a", 'ar');
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    taskStatus!.toLowerCase();
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return InkWell(
      onTap: widget.onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isTablet ? (orientation ? 0.015.w : 0.01.w) : 0.0.w),
        child: Container(
          decoration: BoxDecoration(
            color: themeController.currentTheme == AppColors.lightTheme
                ? AppColors.colorWhite
                : Theme.of(context).colorScheme.inversePrimary,
            // color: themeController.currentTheme == AppColors.lightTheme
            //     ? AppColors.colorLightGrey
            //     : AppColors.colorBlack,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: isTablet ? (orientation ? 0.02.w : 0.01.w) : 0.03.w,
              vertical: 0.012.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: widget.cardModel!.cardImage!.cardImage!.last.isURL
                    ? Image.network(
                        widget.cardModel!.cardImage!.cardImage!.last,
                        fit: BoxFit.cover,
                        width:
                            isTablet ? (orientation ? 0.05.w : 0.05.h) : 0.1.w,
                        height: isTablet
                            ? (orientation ? 0.035.h : 0.045.h)
                            : 0.045.h,
                      )
                    : Image.asset(
                        "assets/png_assets/taskImage.png",
                        fit: BoxFit.cover,
                        width:
                            isTablet ? (orientation ? 0.05.w : 0.05.h) : 0.1.w,
                        height: isTablet
                            ? (orientation ? 0.035.h : 0.045.h)
                            : 0.045.h,
                      ),
              ),
              SizedBox(
                width: isTablet ? (orientation ? 0.001.h : 0.02.h) : 0.02.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: isTablet
                                ? (orientation ? 0.255.w : 0.18.w)
                                : 0.64.w,
                            //       color: Colors.amber,
                            child: Text(
                              widget.cardModel!.cardName!.cardName!.last
                                  .capitalize as String,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: isTablet
                                      ? (orientation
                                          ? FontConstants.fontSize019.h
                                          : FontConstants.fontSize022.h)
                                      : FontConstants.fontSize020.h,
                                  color: themeController.currentTheme ==
                                          AppColors.lightTheme
                                      ? AppColors.colorBlack
                                      : AppColors.colorWhiteDark,
                                  fontWeight: FontWeight.w600,
                                  height: isTablet ? 1.8 : 1.5
                                  // height: 0.002.h,
                                  ),
                            ),
                          ),
                          if (widget.listName != "Archived" &&
                              widget.listName != "Deleted")
                            InkWell(
                                onTapUp: (details) {
                                  hapticController.triggerHapticFeedback(
                                      vibration: VibrateType.lightImpact,
                                      hapticFeedback:
                                          HapticFeedback.lightImpact);

                                  if (widget.cardModel!.cardCreator!
                                          .cardCreator!.last ==
                                      Get.find<MainCoreEmployeeController>()
                                          .employeeEntity!
                                          .email!) {
                                    final iconPosition = details.globalPosition;
                                    _showSortMenu(
                                        context, iconPosition, textController,
                                        board: widget.board!,
                                        card: widget.cardModel!,
                                        boardModel: widget.boardModel!);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const SuccessDialog(
                                          title: "Warning",
                                          subtitle:
                                              "Only Card Owner Can Edit This Card",
                                          lottieAsset:
                                              "assets/lottie_assets/main_lottie_assets/error.json",
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  //    color: Colors.red,
                                  height: isTablet
                                      ? (orientation ? 0.05.w : 0.03.w)
                                      : 0.1.w,
                                  width: isTablet
                                      ? (orientation ? 0.05.w : 0.03.w)
                                      : 0.1.w,
                                  padding: EdgeInsets.all(isTablet
                                      ? (orientation ? 0.007.h : 0.01.h)
                                      : 0.01.h),
                                  child: SvgPicture.asset(
                                    "assets/icons_assets/task_assets/threeDotsVertical.svg",
                                    height: 0.023.h,
                                    color: themeController.currentTheme ==
                                            AppColors.lightTheme
                                        ? null
                                        : AppColors.colorGreydark,
                                  ),
                                )),
                          if (widget.listName == "Archived" ||
                              widget.listName == "Deleted")
                            InkWell(
                                onTap: widget.isArchive,
                                child: SvgPicture.asset(
                                  "assets/icons_assets/task_assets/ArchiveRedo.svg",
                                  height: 0.023.h,
                                  color: themeController.currentTheme ==
                                          AppColors.lightTheme
                                      ? null
                                      : AppColors.colorGreydark,
                                ))
                        ],
                      ),

                      /// Task priority + Completion Percentage
                      // if (taskStatus != null &&
                      //     taskStatus!.isNotEmpty &&
                      //     percentageColor != null &&
                      //     taskCompletionPercentage != null &&
                      //     taskCompletionPercentage!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 0.01.h : 0.005.h),
                        child: SizedBox(
                          //  color: Colors.amber,
                          width: isTablet
                              ? (orientation ? 0.29.w : 0.198.w)
                              : 0.7.w,
                          child: Row(
                            children: [
                              if (widget.cardModel!.cardPriority!.cardPriority!
                                  .isNotEmpty)
                                SvgPicture.asset(
                                  widget.cardModel!.cardPriority!.cardPriority!
                                              .last
                                              .toLowerCase() ==
                                          "urgent"
                                      ? 'assets/icons_assets/main_icons_assets/urgentBell.svg'
                                      : widget.cardModel!.cardPriority!
                                                  .cardPriority!.last
                                                  .toLowerCase() ==
                                              "important"
                                          ? 'assets/icons_assets/main_icons_assets/important.svg'
                                          : widget.cardModel!.cardPriority!
                                                      .cardPriority!.last
                                                      .toLowerCase() ==
                                                  "medium"
                                              ? 'assets/icons_assets/main_icons_assets/medium.svg'
                                              : widget.cardModel!.cardPriority!
                                                          .cardPriority!.last
                                                          .toLowerCase() ==
                                                      "low"
                                                  ? 'assets/icons_assets/main_icons_assets/lowPriority.svg'
                                                  : "",
                                  height: isTablet
                                      ? (orientation ? 0.022.w : 0.015.w)
                                      : 0.04.w,
                                ),
                              SizedBox(
                                  width: isTablet
                                      ? (orientation ? 0.01.w : 0.005.w)
                                      : 0.015.w),
                              // if (widget.cardModel!.cardPriority!.cardPriority!
                              //     .isNotEmpty)
                              SizedBox(
                                width: isTablet
                                    ? (orientation ? 0.09.w : 0.06.w)
                                    : null,
                                child: Align(
                                  alignment:
                                      Get.locale.toString().contains('ar')
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.cardModel!.cardPriority!
                                              .cardPriority!.isNotEmpty
                                          ? "${widget.cardModel!.cardPriority!.cardPriority!.last.tr.capitalize}"
                                          : " ",
                                      style: AppFontStyle.cairoRegularStyle
                                          .copyWith(
                                        fontSize: isTablet
                                            ? orientation
                                                ? FontConstants.fontSize013.h
                                                : FontConstants.fontSize018.h
                                            : FontConstants.fontSize016.h,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (widget.cardModel!.cardPriority!.cardPriority!
                                  .isNotEmpty)
                                SizedBox(
                                  height: 0.01.h,
                                  width: isTablet
                                      ? (orientation ? 0.09.w : 0.07.w)
                                      : 0.35.w,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: double.parse(
                                            widget
                                                    .cardModel
                                                    ?.cardProgress
                                                    ?.cardProgress
                                                    ?.lastOrNull ??
                                                "0",
                                          ) /
                                          100,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        percentageColor!,
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.cardModel!.cardPriority!.cardPriority!
                                  .isNotEmpty)
                                SizedBox(
                                  width: isTablet ? 0.005.w : 0.015.w,
                                ),
                              if (widget.cardModel!.cardProgress!.cardProgress!
                                  .isNotEmpty)
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 0.0.w),
                                  child: FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                      Get.locale.toString().contains('en')
                                          ? "${widget.cardModel!.cardProgress!.cardProgress!.last}%"
                                          : "${convertNumberToArabic(widget.cardModel!.cardProgress!.cardProgress!.last)}%",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFontStyle.cairoRegularStyle
                                          .copyWith(
                                        fontSize: isTablet
                                            ? orientation
                                                ? FontConstants.fontSize013.h
                                                : FontConstants.fontSize018.h
                                            : FontConstants.fontSize016.h,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.cardModel!.lastUpdate!.lastUpdate != null &&
                      widget.cardModel!.lastUpdate!.lastUpdate!.isEmpty)
                    Row(
                      children: [
                        SizedBox(
                          width:
                              isTablet ? (orientation ? 0.21.w : 0.17.w) : null,
                          child: Align(
                            alignment: Get.locale.toString().contains('en')
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${"Last Edit:".tr} -",
                                style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: isTablet
                                      ? orientation
                                          ? FontConstants.fontSize013.h
                                          : FontConstants.fontSize018.h
                                      : FontConstants.fontSize012.h,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isTablet
                              ? (orientation ? 0.018.w : 0.013.w)
                              : 0.04.w,
                        )
                      ],
                    ),

                  /// last update time of the card
                  if (widget.cardModel!.lastUpdate != null &&
                      widget.cardModel!.lastUpdate!.lastUpdate!.isNotEmpty)
                    Row(
                      children: [
                        SizedBox(
                          // color: Colors.amber,
                          width: isTablet
                              ? (orientation ? 0.26.w : 0.185.w)
                              : null,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "${"Last Edit:".tr} ${Get.locale.toString().contains('ar') ? formatTimestampToStringInArabic(widget.cardModel!.lastUpdate!.lastUpdate!.last) : formatTimestampToString(widget.cardModel!.lastUpdate!.lastUpdate!.last)}",
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: isTablet
                                    ? orientation
                                        ? FontConstants.fontSize013.h
                                        : FontConstants.fontSize018.h
                                    : FontConstants.fontSize012.h,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isTablet
                              ? (orientation ? 0.018.w : 0.013.w)
                              : 0.04.w,
                        )
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum StatusWant {
  // ignore: constant_identifier_names
  Move,
  // ignore: constant_identifier_names
  Archive,
  // ignore: constant_identifier_names
  Copy,
  // ignore: constant_identifier_names
  Delete,
}

void _showSortMenu(
  BuildContext context,
  Offset iconPosition,
  TextEditingController textController, {
  required String board,
  required CardModel card,
  required BoardModel boardModel,
}) async {
  BoardController taskController = Get.put(BoardController());

  final List<StatusWant> sortOptions = [
    StatusWant.Move,
    StatusWant.Archive,
    StatusWant.Copy,
    StatusWant.Delete,
  ];

  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final double menuOffsetX = iconPosition.dx - (-9.0);
  final double menuOffsetY = iconPosition.dy - (-7.0);

  final RelativeRect position = RelativeRect.fromLTRB(
    menuOffsetX,
    menuOffsetY,
    overlay.size.width - menuOffsetX,
    overlay.size.height,
  );

  selectedOption = await showMenu(
    elevation: 0,
    shadowColor: Colors.transparent,
    color: Theme.of(context).colorScheme.onPrimary,
    context: context,
    constraints: BoxConstraints(
      minHeight: 0.0.h,
    ),
    position: position,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    items: sortOptions.map((option) {
      return CustomPopupMenuItem<StatusWant>(
          first: option.index == 0,
          last: option.index == sortOptions.length - 1,
          color: Theme.of(context).colorScheme.onPrimary,
          value: option,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getSortOptionLabel(option, context),
            ],
          ));
    }).toList(),
  );

  if (selectedOption != null) {
    // Call the appropriate dialog function based on the selected option
    switch (selectedOption!) {
      case StatusWant.Copy:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CopyCardDialouge(
              title: "Copy Card",
              cardModel: card,
              board: board,
              boardModel: boardModel,
              onPressed: () async {
                await taskController.copyCard(
                  name: textController.text,
                  context: context,
                  currentBoardName: board.capitalize!,
                  cardModel: card,
                );
              },
              iconUrl: 'assets/icons_assets/task_assets/NewCopy.svg',
              textController: textController,
            );
          },
        );
        break;
      case StatusWant.Move:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CopyCardDialouge(
              onPressed: () {},
              title: "Move Card",
              isMove: true,
              cardModel: card,
              board: board,
              boardModel: boardModel,
              iconUrl: 'assets/icons_assets/task_assets/moveIcon.svg',
              textController: null,
            );
          },
        );
        break;

      case StatusWant.Archive:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DeletOrArchiveDialog(
              yesOnPressed: () async {
                await taskController.updateCard(
                  cardModel: card,
                  board: board,
                  boardModel: boardModel,
                  cardStatus: "archived",
                );
              },
            );
          },
        );
        break;
      case StatusWant.Delete:
        showDialog(
            context: context,
            builder: (context) {
              return DeleteDialog(
                deleteTitleText: "Delete Task",
                deleteText: "Are You Sure You Want To Delete This Task?",
                yesOnPressed: () async {
                  await taskController
                      .updateCard(
                    cardModel: card,
                    board: board,
                    boardModel: boardModel,
                    cardStatus: "deleted",
                  )
                      .then(
                    (value) {
                      try {
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const SuccessDialog(
                                title: "Successful",
                                subtitle:
                                    "This Task Has Been Deleted Successfully",
                                lottieAsset: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                              );
                            });
                      } catch (e) {
                        log('message error $e');
                      }
                    },
                  );
                },
              );
            });
        break;
    }
  }
}

StatusWant? selectedOption;
Widget _getSortOptionLabel(StatusWant option, BuildContext context) {
  switch (option) {
    case StatusWant.Delete:
      return const SortOptionWidget(
        iconAddress: 'assets/icons_assets/task_assets/trashIconTask.svg',
        text: "Delete",
      );
    case StatusWant.Archive:
      return const SortOptionWidget(
        iconAddress: 'assets/icons_assets/task_assets/archiveIcon.svg',
        text: "Archive",
      );
    case StatusWant.Move:
      return const SortOptionWidget(
        iconAddress: 'assets/icons_assets/task_assets/moveIcon.svg',
        text: "Move",
      );
    case StatusWant.Copy:
      return const SortOptionWidget(
        iconAddress: 'assets/icons_assets/task_assets/NewCopy.svg',
        text: "Copy",
      );
  }
}

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  final Color color;
  final bool first;
  final bool last;

  const CustomPopupMenuItem({
    super.key,
    required T super.value,
    super.enabled,
    required Widget super.child,
    required this.color,
    this.first = false,
    this.last = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomPopupMenuItemState<T> createState() => _CustomPopupMenuItemState<T>();
}

class _CustomPopupMenuItemState<T>
    extends PopupMenuItemState<T, CustomPopupMenuItem<T>> {
  late BorderRadius borderRadius;
  double radius = 10;
  @override
  Widget build(BuildContext context) {
    if (widget.first) {
      borderRadius = BorderRadius.only(
          topLeft: Radius.circular(radius), topRight: Radius.circular(radius));
    } else if (widget.last) {
      borderRadius = BorderRadius.only(
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius));
    } else {
      borderRadius = BorderRadius.zero;
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        color: widget.color,
        child: super.build(context),
      ),
    );
  }
}
