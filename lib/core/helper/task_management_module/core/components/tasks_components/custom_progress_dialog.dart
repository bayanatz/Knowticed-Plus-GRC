import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_progress_drop_down.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/app_size.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/custom_elevated_button.dart';

class CustomProgressDialog extends StatefulWidget {
  final String? initialIncrement;
  final Function(String, String)? onApplyPressed;
  final List<String> progressItems;
  final Map<String, String> progressItemsWithColor;
  final CardModel card;
  final String board;

  const CustomProgressDialog({
    super.key,
    this.initialIncrement,
    this.onApplyPressed,
    required this.progressItems,
    required this.progressItemsWithColor,
    required this.card,
    required this.board,
  });

  @override
  State<CustomProgressDialog> createState() => _CustomProgressDialogState();
}

class _CustomProgressDialogState extends State<CustomProgressDialog> {
  TaskDetailsController taskController = Get.put(TaskDetailsController());

  String? increment;
  late DateTime currentDateTime;
  final List<String> incrementItems = ["5", "10", "20", "25"];

  @override
  void initState() {
    super.initState();
    increment = widget.initialIncrement ?? "5";
  }

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    TextStyle dropTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isTablet
          ? isVertical
              ? FontConstants.fontSize019.h
              : FontConstants.fontSize022.h
          : FontConstants.fontSize018.h,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.inverseSurface,
      height: 1.6,
    );
    double widthSize = isTablet ? (isVertical ? 0.48.w : 0.265.w) : 0.9.w;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet
            ? (isVertical ? 0.15 * MediaQuery.of(context).size.width : 0.30 * MediaQuery.of(context).size.width)
            : 0.10 * MediaQuery.of(context).size.width,
        vertical: isTablet
            ? (isVertical ? 0.365 * MediaQuery.of(context).size.height : 0.35 * MediaQuery.of(context).size.height)
            : 0.35 * MediaQuery.of(context).size.height, // Adjusted to prevent overflow
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 15.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        child: GetBuilder<TaskDetailsController>(builder: (controller) {
          return SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.7, // Adjust as needed
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Increment".tr,
                            style: dropTextStyle,
                          ),
                          CustomProgressDropdown(
                            hint: "Select Your Increment".tr,
                            borded: false,
                            board: widget.board,
                            card: widget.card,
                            isProgressDialog: true,
                            buttonHeight: isTablet
                                ? isVertical
                                    ? 0.05.h
                                    : 0.056.h
                                : 0.045.h,
                            buttonWidth: isTablet ? widthSize : widthSize,
                            dropdownWidth:
                                isTablet ? widthSize / 1.5 : widthSize / 1.07,
                            buttonColor: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? AppColors.colorLightGrey
                                : AppColors.colorBlack,
                            backColor: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? AppColors.colorLightGrey
                                : AppColors.colorBlack,
                            buttonDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.moreLightGrey,
                            ),
                            buttonPadding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 0.01.w : 0.02.w),
                            value: increment,
                            dropdownItems: incrementItems,
                            onChanged: (value) {
                              setState(() {
                                increment = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 0.015.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Color Code".tr,
                            style: dropTextStyle,
                          ),
                          CustomProgressColorDropdown(
                            card: widget.card,
                            board: widget.board,
                            value:
                            widget.progressItemsWithColor.keys.toList()[0],
                            dropdownItems:
                            widget.progressItemsWithColor.keys.toList(),
                            dropdownItemsMap: widget.progressItemsWithColor,
                            hint: "Color Code".tr,
                            borded: false,
                            //isProgressDialog: true,
                            buttonHeight: isTablet
                                ? isVertical
                                ? 0.05.h
                                : 0.056.h
                                : 0.045.h,
                            buttonWidth: isTablet ? widthSize : widthSize,
                            dropdownWidth:
                            isTablet ? widthSize / 1.5 : widthSize / 1.05,
                            buttonColor:
                            Theme.of(context).colorScheme.inversePrimary,
                            backColor:
                            Theme.of(context).colorScheme.inversePrimary,
                            buttonDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.moreLightGrey,
                            ),
                            buttonPadding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 0.01.w : 0.02.w),
                            onChanged: (value) {
                              setState(() {
                                //increment = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.025.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: CustomElevatedButton(
                            height: AppSize.h36,
                            onPressed: () {
                              setState(() {
                                increment = "5";
                                currentDateTime = DateTime.now();
                                widget.onApplyPressed?.call(
                                    increment!, currentDateTime.toString());
                                controller.updateCard(
                                  cardModel: widget.card,
                                  board: widget.board,
                                  progressIndicators: [
                                    "5",
                                    "10",
                                    "15",
                                    "20",
                                    "25",
                                    "30",
                                    "35",
                                    "40",
                                    "45",
                                    "50",
                                    "55",
                                    "60",
                                    "65",
                                    "70",
                                    "75",
                                    "80",
                                    "85",
                                    "90",
                                    "95",
                                    "100"
                                  ],
                                  progressColor: [
                                    "red",
                                    "red",
                                    "red",
                                    "red",
                                    "red",
                                    "orange",
                                    "orange",
                                    "orange",
                                    "orange",
                                    "orange",
                                    "yellow",
                                    "yellow",
                                    "yellow",
                                    "yellow",
                                    "yellow",
                                    "green",
                                    "green",
                                    "green",
                                    "green",
                                    "green"
                                  ],
                                );
                                Get.back();
                                // Navigator.pop(context);
                              });
                            },
                            buttonText: "Reset".tr,
                            isGrey: true,
                            fontSize: isTablet
                                ? isVertical
                                    ? FontConstants.fontSize017.h
                                    : FontConstants.fontSize022.h
                                : FontConstants.fontSize016.h,
                            textColor: Theme.of(context).colorScheme.scrim,
                          ),
                        ),
                        SizedBox(
                          width: 0.040.w,
                        ),
                        Expanded(
                          child: CustomElevatedButton(
                            height: AppSize.h36,
                            onPressed: () {
                              setState(() {
                                currentDateTime = DateTime.now();
                                widget.onApplyPressed?.call(
                                    increment!, currentDateTime.toString());
                                if (controller.cardColorsList != null &&
                                    controller.cardColorsList !=
                                        widget
                                            .card.progressIndicator!.colors!) {
                                  controller.updateCard(
                                    cardModel: widget.card,
                                    board: widget.board,
                                    progressIndicators:
                                        controller.cardProgressPercentageList,
                                    progressColor: controller.cardColorsList,
                                  );
                                  print("doneeeeeeeeeeeeeeeeeee");
                                }
                                if (increment == '5' &&
                                    controller.cardSelectedIncreament != "5") {
                                  controller.updateCard(
                                    cardModel: widget.card,
                                    board: widget.board,
                                    progressIndicators: [
                                      "5",
                                      "10",
                                      "15",
                                      "20",
                                      "25",
                                      "30",
                                      "35",
                                      "40",
                                      "45",
                                      "50",
                                      "55",
                                      "60",
                                      "65",
                                      "70",
                                      "75",
                                      "80",
                                      "85",
                                      "90",
                                      "95",
                                      "100"
                                    ],
                                    progressColor: [
                                      "red",
                                      "red",
                                      "red",
                                      "red",
                                      "red",
                                      "orange",
                                      "orange",
                                      "orange",
                                      "orange",
                                      "orange",
                                      "yellow",
                                      "yellow",
                                      "yellow",
                                      "yellow",
                                      "yellow",
                                      "green",
                                      "green",
                                      "green",
                                      "green",
                                      "green"
                                    ],
                                  );
                                }
                                print(box.read<String>(
                                    '${widget.board}${widget.card.cardName!.cardName!.last}increment'));
                                if (increment == '10' &&
                                    controller.cardSelectedIncreament != "10") {
                                  controller.updateCard(
                                    cardModel: widget.card,
                                    board: widget.board,
                                    progressIndicators: [
                                      // todo :: نخلي دي في فايل لوحده نجمعه
                                      "10",
                                      "20",
                                      "30",
                                      "40",
                                      "50",
                                      "60",
                                      "70",
                                      "80",
                                      "90",
                                      "100"
                                    ],
                                    progressColor: [
                                      "red",
                                      "red",
                                      "orange",
                                      "orange",
                                      "orange",
                                      "yellow",
                                      "yellow",
                                      "green",
                                      "green",
                                      "green"
                                    ],
                                  );
                                } else if (increment == '20' &&
                                    controller.cardSelectedIncreament != "20") {
                                  controller.updateCard(
                                    cardModel: widget.card,
                                    board: widget.board,
                                    progressIndicators: [
                                      "20",
                                      "40",
                                      "60",
                                      "80",
                                      "100"
                                    ],
                                    progressColor: [
                                      "red",
                                      "orange",
                                      "yellow",
                                      "green",
                                      "green"
                                    ],
                                  );
                                } else if (increment == '25' &&
                                    controller.cardSelectedIncreament != "25") {
                                  controller.updateCard(
                                    cardModel: widget.card,
                                    board: widget.board,
                                    progressIndicators: [
                                      "25",
                                      "50",
                                      "75",
                                      "100"
                                    ],
                                    progressColor: [
                                      "red",
                                      "orange",
                                      "yellow",
                                      "green"
                                    ],
                                  );
                                }

                                controller.cardSelectedIncreament = null;
                                Navigator.pop(context);
                              });
                            },
                            buttonText: "Apply".tr,
                            fontSize: isTablet
                                ? isVertical
                                    ? FontConstants.fontSize017.h
                                    : FontConstants.fontSize022.h
                                : FontConstants.fontSize016.h,
                            fontweight: FontWeight.w600,
                            textColor: AppColors.textButton,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
