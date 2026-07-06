import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drop_down_menu.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_textfield_new.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/progress_section.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/sectionTitle.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/app_size.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/custom_description_text_field.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/edit_card_name_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';

class TaskDetailsHeaderWidget extends StatefulWidget {
  const TaskDetailsHeaderWidget(
      {super.key, required this.card, required this.board,required this.department});
  final CardModel card;
  final String board;
  final String department;

  @override
  State<TaskDetailsHeaderWidget> createState() =>
      _TaskDetailsHeaderWidgetState();
}

class _TaskDetailsHeaderWidgetState extends State<TaskDetailsHeaderWidget> {
  bool isEnabledTask = true;
  bool isEnabledDesc = true;
  late TextEditingController name;
  late TextEditingController description;

  bool isTaskOwner = true;
  String? priorityValue;
  String? progressValue;

  @override
  void initState() {
    name = TextEditingController();
    description = TextEditingController();
    if (widget.card.cardPriority != null &&
        widget.card.cardPriority!.cardPriority!.isNotEmpty) {
      priorityValue = widget.card.cardPriority!.cardPriority!.last.capitalize;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double widthSize = isTablet ? (orientation ? 0.35.w : 0.27.w) : 0.9.w;
    final TextStyle titleStyle = AppTextStyles.font16BlackRegularCairo.copyWith( // todo
        fontSize: orientation
            ? FontConstants.fontSize025.h
            : FontConstants.fontSize022.h,
        fontWeight: FontWeight.bold,

        height: 1.6);

    return GetBuilder<TaskDetailsController>(builder: (controller) {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppSize.radius),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 15.h : 10.h, vertical:isTablet ?  15.h : 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.h,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSize.radius),
                          ),
                          child: widget.card.cardImage!.cardImage!.last != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppSize.radius),
                            child: Image.network(
                              widget.card.cardImage!.cardImage!.last,
                              fit: BoxFit.cover,
                              height: isTablet ? 0.4.h : 0.4.h,
                            ),
                          )
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(AppSize.radius),
                            child: Image.asset(
                              isTablet
                                  ? "assets/png_assets/taskImageTab.png"
                                  : "assets/png_assets/taskImage.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (widget.card.cardCreator!.cardCreator!.last ==
                                Get.find<MainCoreEmployeeController>()
                                    .employeeEntity!
                                    .email!) {
                              controller.updateCardImage(
                                taskID: widget.card.cardId!,
                                department: widget.department,
                                cardModel: widget.card,
                                boardName: widget.board,
                                board: widget.board,
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return const SuccessDialog(
                                    title: "Warning",
                                    subtitle: "Only Task Owner Can Edit Image",
                                    lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            height: 15.h,
                            width: 15.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.signOut,
                            ),
                            padding: EdgeInsets.all(1),
                            child: SvgPicture.asset(
                              'assets/icons_assets/task_assets/CameraEdit.svg',
                              height: orientation ? 0.02.h : 0.03.h,
                              color: AppColors.textButton,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSize.h8),
                      constraints: BoxConstraints(
                          maxWidth: 80.w,
                          maxHeight: 30.h
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(AppSize.radius),
                      ),
                      child: Center(
                        child: Text(
                          (widget.card.cardStatus?.cardStatus?.last ?? '')
                              .split(' ')
                              .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
                              .join(' '),
                          style: AppTextStyles.font16BlackMediumCairo,
                        ),
                      ),
                    )

                  ],
                ),

                /// Task Card
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Task Name
                      ColumnRequestData(
                        controllerfinishState: (value) {
                          if (name.text.isNotEmpty  &&
                              controller
                                  .isFieldValid(name.text)) {
                             controller.updateCard(
                              cardModel: widget.card,
                              board: widget.board,
                              cardName: name.text,
                            );
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SuccessDialog(
                                  title: "Successful".tr,
                                  subtitle:
                                  "Card Name Updated Successfully".tr,
                                  lottieAsset: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const SuccessDialog(
                                  title: "Failure",
                                  subtitle: "Please Fill The Field",
                                  lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                                );
                              },
                            );
                          }
                        },
                        heightField: AppSize.heightField,
                        fillColor:
                        themeController.currentTheme == AppColors.lightTheme
                            ? AppColors.moreLightGrey
                            : AppColors.colorBlack,
                        title: "Card Name",
                        isEdit: true,
                        isTextField: true,
                        hint: widget.card.cardName!.cardName!.last.capitalizeFirst!,
                        isOptional: false,
                        isExpanded: true,
                        hasPrefix: true,
                        textController: name,
                        enabled: isEnabledTask,
                        enabledState: (value) {
                          setState(() {
                            isEnabledTask = value;
                          });
                        },
                        controllerState: (value) {
                          setState(() {
                            print('Name value ${value!}');
                          });
                        },
                        maxlength: 120,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      // Card Des
                      ColumnRequestData(
                        controllerfinishState: (value) {
                            log('description: ${description.text}');
                            if (widget.card.cardCreator!.cardCreator!.last ==
                                Get.find<MainCoreEmployeeController>()
                                    .employeeEntity!
                                    .email!) {
                              log('description2: ${description.text}');
                              hapticController.triggerHapticFeedback(
                                  vibration: VibrateType.heavyImpact,
                                  hapticFeedback: HapticFeedback.heavyImpact);

                              if (description.text.isNotEmpty &&
                                  controller.isFieldValid(
                                      description.text)) {
                                log('description3: ${description.text}');
                                controller.updateCard(
                                  cardModel: widget.card,
                                  board: widget.board,
                                  cardDescription: description.text,
                                );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SuccessDialog(
                                      title: "Successful".tr,
                                      subtitle:
                                      "Card Description Updated Successfully"
                                          .tr,
                                      lottieAsset: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                                    );
                                  },
                                );
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return const SuccessDialog(
                                    title: "Warning",
                                    subtitle:
                                    "Only Task Owner Can Edit Task Description",
                                    lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                                  );
                                },
                              );
                            }
                            log('error ${description.text}');
                          },
                          title: "Description",
                          isTextField: true,
                          showLengthCounter: true,
                          heightField: 142.h,
                          isEdit: true,
                          hint: widget.card.cardDescription!.cardDescription!.last
                              .capitalizeFirst!,
                          isOptional: false,
                          isExpanded: true,
                          fillColor:
                          themeController.currentTheme == AppColors.lightTheme
                              ? AppColors.moreLightGrey
                              : AppColors.colorBlack,
                          textController: description,
                          enabled: isEnabledTask,
                          maxlength: 500,
                          maxlines: 12,
                          enabledState: (value) {
                            setState(() {
                              isEnabledDesc = value;
                            });
                          },
                         )
                    ],
                  ),
                ),
              ],),
          ),
          SizedBox(
            height: orientation ? 0.02.h : 0.04.h,
          ),

          /// New indicators Section
          SectionTitle(title: 'Indicators'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding:
            EdgeInsets.symmetric(horizontal: 0.015.h, vertical: 0.015.h),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(
                children: [
                  isTablet ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ColumnRequestData(
                        title: "Priority",
                        isTextField: false,
                        prefixUrl: "",
                        hint: "Select The Priority",
                        buttonWidth: widthSize,
                        dropWidth: widthSize,
                        isOptional: false,
                        isExpanded: true,
                        hasSuffix: true,
                        isPriority:
                        widget.card.cardCreator!.cardCreator!.last ==
                            Get.find<MainCoreEmployeeController>()
                                .employeeEntity!
                                .email!
                            ? true
                            : false,
                        dropDownItems: [
                          "Urgent".tr,
                          "Important".tr,
                          "Medium".tr,
                          "Low".tr
                        ],
                        dropdownValue: priorityValue?.tr,
                        dropDownValueState: (value) async {
                          if (widget.card.cardCreator!.cardCreator!.last ==
                              Get.find<MainCoreEmployeeController>()
                                  .employeeEntity!
                                  .email!) {
                            priorityValue =
                            Get.locale.toString().contains('en')
                                ? value
                                : value == 'عاجل'
                                ? 'Urgent'
                                : value == 'متوسط'
                                ? 'Medium'
                                : value == 'منخفض'
                                ? 'Low'
                                : 'Important';
                            await controller.updateCard(
                              cardModel: widget.card,
                              board: widget.board,
                              priority: priorityValue!.toLowerCase(),
                            );
                          } else {
                            //priorityValue =priorityValue;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const SuccessDialog(
                                  title: "Warning",
                                  subtitle:
                                  "Only Task Owner Can Edit The Priority",
                                  lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                                );
                              },
                            );
                          }
                          setState(() {});
                        },
                        fillColor: themeController.currentTheme ==
                            AppColors.lightTheme
                            ? AppColors.colorLightGrey
                            : AppColors.colorBlack,
                        suffixUrl: "assets/icons_assets/main_icons_assets/closefield.svg",
                      ),
                      ProgressSection(
                        card: widget.card,
                        board: widget.board,
                      ),
                    ],
                  ) : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ColumnRequestData(
                        title: "Priority",
                        isTextField: false,
                        prefixUrl: "",
                        hint: "Select The Priority",
                        buttonWidth: widthSize,
                        dropWidth: widthSize,
                        isOptional: false,
                        isExpanded: true,
                        hasSuffix: true,
                        isPriority:
                        widget.card.cardCreator!.cardCreator!.last ==
                            Get.find<MainCoreEmployeeController>()
                                .employeeEntity!
                                .email!
                            ? true
                            : false,
                        dropDownItems: [
                          "Urgent".tr,
                          "Important".tr,
                          "Medium".tr,
                          "Low".tr
                        ],
                        dropdownValue: priorityValue?.tr,
                        dropDownValueState: (value) async {
                          if (widget.card.cardCreator!.cardCreator!.last ==
                              Get.find<MainCoreEmployeeController>()
                                  .employeeEntity!
                                  .email!) {
                            priorityValue =
                            Get.locale.toString().contains('en')
                                ? value
                                : value == 'عاجل'
                                ? 'Urgent'
                                : value == 'متوسط'
                                ? 'Medium'
                                : value == 'منخفض'
                                ? 'Low'
                                : 'Important';
                            await controller.updateCard(
                              cardModel: widget.card,
                              board: widget.board,
                              priority: priorityValue!.toLowerCase(),
                            );
                          } else {
                            //priorityValue =priorityValue;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const SuccessDialog(
                                  title: "Warning",
                                  subtitle:
                                  "Only Task Owner Can Edit The Priority",
                                  lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                                );
                              },
                            );
                          }
                          setState(() {});
                        },
                        fillColor: themeController.currentTheme ==
                            AppColors.lightTheme
                            ? AppColors.colorLightGrey
                            : AppColors.colorBlack,
                        suffixUrl: "assets/icons_assets/main_icons_assets/closefield.svg",
                      ),
                      ProgressSection(
                        card: widget.card,
                        board: widget.board,
                      ),
                    ],
                  ),
                  if (isTaskOwner == false)
                    Positioned(
                      child: GestureDetector(
                        onTap: () {
                          print("error");
                        },
                        child: Container(
                          width: double.infinity,
                          height: isTablet ? 0.085.h : 0.075.h,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ]),
          ),

          /// New indicators Section End Here
          SizedBox(
            height: 0.015.h,
          ),
        ],
      );
    });
  }
}
