import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/image_paths.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_progress_drop_down.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_progress_dialog.dart';

class ProgressSection extends StatefulWidget {
  const ProgressSection({
    super.key,
    required this.card,
    required this.board,
  });

  final CardModel card;
  final String board;
  @override
  State<ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<ProgressSection> {
  TaskDetailsController taskController = Get.put(TaskDetailsController());

  String? progressValue = "0";
  late List<String> progressItems;
  late Map<String, String> progressItemsWithColor;
  String increment = "5";
  late String currentDateTime;

  String formatTimestampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat dateFormat = DateFormat("dd MMM yyyy 'at' hh:mm a");
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  String formatTimestampArabicToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat dateFormat = DateFormat("dd MMM yyyy ${'at'.tr} mm:hh a", 'ar');

    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  /// Handles the apply action for the progress section.
  /// This function updates the increment value in the box and updates the card's progress value.
  /// If the card's progress value is not empty, it calls the updateCard method of the taskController
  /// with the updated card model, board, and progress value. After updating the card's progress value,
  /// it sets the state of the progress section with the new increment value, progress items, current date time,
  /// and formatted current date time. If the card's progress value is empty, it sets the state of the
  /// progress section with the new increment value, progress items, current date time, and formatted current date time.
  void _handleApply(String selectedIncrement, String currentDateTime) async {
    await box.write(
        '${widget.board}${widget.card.cardName!.cardName!.last}increment',
        selectedIncrement);
    taskController.updatecardSelectedIncreament(selectedIncrement);
    if (widget.card.cardProgress!.cardProgress!.isNotEmpty) {
      await taskController
          .updateCard(
        cardModel: widget.card,
        board: widget.board,
        progress: "0",
      )
          .then((value) {
        progressValue = "0";
        setState(() {
          increment = selectedIncrement;
          progressItems = generateProgressItems(increment);
          progressItemsWithColor = generateProgressItemsWithColor(increment);
          taskController.onChnagedColorDropDown(
              progressItemsWithColor.keys.toList(),
              progressItems,
              progressItemsWithColor.keys.toList()[0]);

          this.currentDateTime = currentDateTime.toString();
          this.currentDateTime = _formatDateTime(DateTime.now());
        });
      });
    } else {
      print("xxxxxxxxxxxxxxxxxxxxxxxxxxx");
      print(selectedIncrement);
      setState(() {
        increment = selectedIncrement;
        progressItems = generateProgressItems(increment);
        progressItemsWithColor = generateProgressItemsWithColor(increment);
        taskController.onChnagedColorDropDown(
            progressItemsWithColor.keys.toList(),
            progressItems,
            progressItemsWithColor.keys.toList()[0]);

        print(progressItems);
        print(progressItemsWithColor);
        this.currentDateTime = currentDateTime.toString();
        this.currentDateTime = _formatDateTime(DateTime.now());
      });
    }
  }

  final box = GetStorage();

  @override
  void initState() {
    super.initState();

    /// Initialize the increment value from the box.
    increment = box.read<String>(
        '${widget.board}${widget.card.cardName!.cardName!.last}increment') ??
        "5";
    //taskController.updatecardSelectedIncreament(selectedIncrement);

    if (widget.card.cardProgress!.cardProgress!.isNotEmpty) {
      progressValue = widget.card.cardProgress!.cardProgress!.last;
    }
    progressItems = generateProgressItems(increment);
    progressItemsWithColor = generateProgressItemsWithColor(increment);
    currentDateTime = _formatDateTime(DateTime.now());
  }

  List<String> generateProgressItems(String increment) {
    List<String> progressItems = [];

    if (increment == "5") {
      for (int i = 0; i <= 100; i += 5) {
        progressItems.add("$i");
      }
    } else if (increment == "10") {
      for (int i = 0; i <= 100; i += 10) {
        progressItems.add("$i");
      }
    } else if (increment == "20") {
      for (int i = 0; i <= 100; i += 20) {
        progressItems.add("$i");
      }
    } else {
      progressItems = ["0", "25", "50", "75", "100"];
    }

    return progressItems;
  }

  Map<String, String> generateProgressItemsWithColor(String increment) {
    Map<String, String> progressItemsWithColor = {};

    if (increment == "5") {
      for (int i = 0; i <= 100; i += 5) {
        if (i > 0 && i <= 25) {
          progressItemsWithColor["$i"] = "red";
        } else if (i <= 50) {
          progressItemsWithColor["$i"] = "orange";
        } else if (i <= 75) {
          progressItemsWithColor["$i"] = "yellow";
        } else {
          progressItemsWithColor["$i"] = "green";
        }
      }
    } else if (increment == "10") {
      for (int i = 0; i <= 100; i += 10) {
        if (i <= 20) {
          progressItemsWithColor["$i"] = "red";
        } else if (i <= 50) {
          progressItemsWithColor["$i"] = "orange";
        } else if (i <= 70) {
          progressItemsWithColor["$i"] = "yellow";
        } else {
          progressItemsWithColor["$i"] = "green";
        }
      }
    } else if (increment == "20") {
      for (int i = 0; i <= 100; i += 20) {
        if (i == 20) {
          progressItemsWithColor["$i"] = "red";
        } else if (i == 40) {
          progressItemsWithColor["$i"] = "orange";
        } else if (i == 60 || i == 70) {
          progressItemsWithColor["$i"] = "yellow";
        } else {
          progressItemsWithColor["$i"] = "green";
        }
      }
    } else {
      progressItemsWithColor = {
        "0": "red",
        "25": "orange",
        "50": "yellow",
        "75": "green",
        "100": "green"
      };
    }

    return progressItemsWithColor;
  }

  String _formatDateTime(DateTime dateTime) {
    String formattedDate =
    DateFormat("dd MMM yyyy 'at' hh:mm a").format(dateTime);
    return "Last Update: $formattedDate";
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double widthSize = isTablet ? (isVertical ? 0.35.w : 0.27.w) : 0.9.w;
    return GetBuilder<BoardController>(builder: (controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 15.h,),
          SizedBox(
            width: widthSize,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: "Progress".tr,
                    style: AppTextStyles.font14BlackCairoMedium,
                    children: [
                      WidgetSpan(
                        child: SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    /// only task owner can edit the progress
                    if (widget.card.cardCreator!.cardCreator!.last ==
                        Get.find<MainCoreEmployeeController>()
                            .employeeEntity!
                            .email!) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomProgressDialog(
                            card: widget.card,
                            board: widget.board,
                            progressItemsWithColor: progressItemsWithColor,
                            progressItems: progressItems,
                            initialIncrement: increment,
                            onApplyPressed: _handleApply,
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const SuccessDialog(
                            title: "Warning",
                            subtitle: "Only Card Owner Can Edit The Progress",
                            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                          );
                        },
                      );
                    }
                  },
                  child: SvgPicture.asset(
                    ImagePaths.getImagePath(context, 'threeDotsDialog'),
                    height: isVertical ? 0.007.h : 0.01.h,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
              ],
            ),
          ),
          CustomProgressDropdown(
            hint: "Select Your Progress".tr,
            board: widget.board,
            card: widget.card,
            borded: false,
            buttonHeight: isTablet
                ? isVertical
                ? 0.06.h
                : 0.07.h
                : 38.h,
            buttonWidth: widthSize,
            dropdownWidth: widthSize - 5,
            buttonColor: themeController.currentTheme == AppColors.lightTheme
                ? AppColors.colorLightGrey
                : AppColors.colorBlack,
            backColor: themeController.currentTheme == AppColors.lightTheme
                ? AppColors.colorLightGrey
                : AppColors.colorBlack,
            buttonDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: themeController.currentTheme == AppColors.lightTheme
                  ? AppColors.colorLightGrey
                  : AppColors.colorBlack,
              border: Border.all(color: Colors.transparent),
            ),
            buttonPadding: EdgeInsets.symmetric(horizontal: isTablet ? 0.01.w : 0.02.w),
            value: progressValue,
            dropdownItems: ["0", ...widget.card.progressIndicator!.progressPercentage!],
            onChanged: (value) async {
              if (widget.card.cardCreator!.cardCreator!.last ==
                  Get.find<MainCoreEmployeeController>().employeeEntity!.email!) {
                setState(() {
                  progressValue = value;
                });

                /// update card progress
                await controller.updateCard(
                  cardModel: widget.card,
                  board: widget.board,
                  progress: value!.toLowerCase(),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const SuccessDialog(
                      title: "Warning",
                      subtitle: "Only Card Owner Can Edit The Progress",
                      lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                    );
                  },
                );
              }
            },
          ),
          SizedBox(
            height: 0.005.h,
          ),

          // /// last update time of the card progress
          // if (widget.card.cardProgress!.timestamp != null &&
          //     widget.card.cardProgress!.timestamp!.isNotEmpty)
          //   Text(
          //     //currentDateTime,
          //     "${"Last Update:".tr}${Get.locale.toString().contains('ar') ? formatTimestampArabicToString(widget.card.cardProgress!.timestamp!.last) : formatTimestampToString(widget.card.cardProgress!.timestamp!.last)}",
          //     style: AppFontStyle.cairoRegularStyle.copyWith(
          //         fontSize: isTablet
          //             ? isVertical
          //             ? FontConstants.fontSize013.h
          //             : FontConstants.fontSize018.h
          //             : FontConstants.fontSize012.h,
          //         fontWeight: FontWeight.w600,
          //         color: Theme.of(context).colorScheme.tertiaryContainer,
          //         height: 1.6),
          //   ),
        ],
      );
    });
  }
}
