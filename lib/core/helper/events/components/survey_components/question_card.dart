import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/events/core_widgets/main_widget/custom_drop_down_menu.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/events/components/survey_components/custom_textfield_container.dart';
import 'package:demo_app/core/helper/events/components/survey_components/delete_member_dialog.dart';
import 'package:demo_app/core/helper/events/components/survey_components/dialogue_switchers_row.dart';
import 'package:demo_app/core/helper/events/components/survey_components/drop_down_widget.dart';
import 'package:demo_app/core/helper/events/components/survey_components/image_selection_bottom_sheet.dart';
import 'package:demo_app/core/helper/events/components/survey_components/multiple_choice_widget.dart';
import 'package:demo_app/core/helper/events/components/survey_components/true_false_widget.dart';
import 'package:demo_app/core/helper/events/controllers/events_controllers/event_controller.dart';
import 'package:demo_app/core/helper/events/controllers/survey_controller.dart/survey_controller.dart';
import 'package:demo_app/features/onboarding/welcome_screen/views/mobile_view/nav_bar.dart';

class QuestionCard extends StatefulWidget {
  TextEditingController questionController;
  TextEditingController pointsController;
  final TextEditingController? shortAnswerController;
  final TextEditingController? paragaraphAnswerController;
  final List<TextEditingController> dropDownControllers;
  final List<TextEditingController> mcqControllers;
  String? selectedImagePath;
  final List<String> imagePaths;
  String? questionType;
  final bool switchValue;
  final void Function(String?)? onQuestionChanged;
  final ValueChanged<bool> onSwitchChanged;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  String onCorrectAnswerSelected;
  final void Function(String)? controllerState;
  bool isRequired;
  int? index;
  bool? isEdit;

  QuestionCard(
      {Key? key,
      required this.questionController,
      required this.pointsController,
      this.isEdit,
      this.shortAnswerController,
      required this.dropDownControllers,
      required this.mcqControllers,
      required this.selectedImagePath,
      required this.imagePaths,
      this.paragaraphAnswerController,
      this.questionType,
      required this.switchValue,
      required this.onQuestionChanged,
      required this.onSwitchChanged,
      required this.onDuplicate,
      required this.onDelete,
      required this.onCorrectAnswerSelected,
      required this.controllerState,
      required this.isRequired,
      this.index})
      : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  // Common dropdown style variables
  late final Color dropdownBackColor =
      Theme.of(context).colorScheme.inversePrimary;
  late final Color dropdownButtonColor =
      Theme.of(context).colorScheme.inversePrimary;

  late final double dropdownWidth = 0.45.w;

  SurveyController surveyController = Get.put(SurveyController());

  void _showImageSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child: ImageSelectionBottomSheet(
            imagePaths: widget.imagePaths,
            onImageSelected: (selectedImage) {
              setState(() {
                widget.selectedImagePath = selectedImage;
              });
              print('Selected Image: $selectedImage');
            },
          ),
        );
      },
    );
  }

  void updateAnswer(String newMcqAnswer) {
    setState(() {
      widget.onCorrectAnswerSelected = newMcqAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    late final double dropdownButtonHeight =
        isTablet ? (isPortrait ? 0.045.h : 0.065.h) : 0.045.h;
    late final double dropdownButtonWidth =
        isTablet ? (isPortrait ? 0.3.w : 0.2.w) : 0.45.w;
    late final double dropdownWidth =
        isTablet ? (isPortrait ? 0.3.w : 0.2.w) : 0.45.w;
    late final EdgeInsets dropdownButtonPadding = EdgeInsets.symmetric(
        horizontal: isTablet ? (isPortrait ? 0.013.w : 0.012.w) : 0.04.w);
    late final EdgeInsets dropdownPadding = EdgeInsets.symmetric(
        horizontal: isTablet ? (isPortrait ? 0.013.w : 0.012.w) : 0.04.w);
    double heightSpacer = isTablet ? 0.02.h : 0.01.h;
    double? textFieldHeight = isTablet ? (isPortrait ? 0.045.h : null) : null;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? (isPortrait ? 0.0.w : 0.0.w) : 0.04.w,
          vertical: isTablet ? 0.025.h : 0.02.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Question".tr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? (isPortrait
                            ? FontConstants.fontSize020.h
                            : FontConstants.fontSize025.h)
                        : FontConstants.fontSize022.h,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
                const Spacer(),
                CustomDropdownButton2(
               
                  dropdownPadding: dropdownPadding,
                  borded: false,
                  buttonHeight: dropdownButtonHeight,
                  buttonWidth: dropdownButtonWidth,
          
                  dropdownWidth: dropdownWidth,
                  buttonPadding: dropdownButtonPadding,
                  hint: "Question Type".tr,
                  value: widget.questionType != null
                      ? (Get.locale.toString().contains('en')
                          ? widget.questionType
                          : arabicQuestionsTypes[englishQuestionsTypes
                              .indexOf(widget.questionType!)])
                      : widget.questionType,
                  dropdownItems: Get.locale.toString().contains('en')
                      ? englishQuestionsTypes
                      : arabicQuestionsTypes,
                  onChanged: (value) {
                    setState(() {
                      widget.questionType =
                          (Get.locale.toString().contains('en')
                                  ? value
                                  : englishQuestionsTypes[
                                      arabicQuestionsTypes.indexOf(value!)]) ??
                              "Multiple Choice";
                    });
                    widget.onQuestionChanged?.call(widget.questionType);
                  },
                ),
              ],
            ),
            SizedBox(height: heightSpacer),
            CustomTextFieldContainer(
              hint: "Question".tr,
              textFieldHeight: textFieldHeight,
              isPayment: isTablet && isPortrait
                  ? true
                  : isTablet &&
                          !isPortrait &&
                          Get.locale.toString().contains('ar')
                      ? true
                      : null,
              textController: widget.questionController,
              controllerState: (value) {
                widget.controllerState
                    ?.call('question ${widget.questionController}');
              },

              //    isAssign: true,
            ),
            // SizedBox(height: heightSpacer),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     GestureDetector(
            //       onTap: _showImageSelectionBottomSheet,
            //       child: SvgPicture.asset(
            //         "assets/icons/uploadPhoto.svg",
            //         height: 0.04.h,
            //         color:
            //             themeController.currentTheme == AppColors.lightTheme
            //                 ? AppColors.colorBlack
            //                 : AppColors.colorWhiteDark,
            //       ),
            //     ),

            //   ],
            // ),
            // SizedBox(height: heightSpacer),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Container(
            //       width: 0.3.w,
            //       child: CustomTextFieldContainer(
            //         hint: "2233 ${"Points".tr}",
            //         //  isAssign: true,
            //         textFieldHeight: textFieldHeight,
            //         isPayment: isTablet && isPortrait ? true : isTablet && !isPortrait && Get.locale.toString().contains('ar') ? true: null,
            //         controllerState: (value) {
            //           widget.controllerState?.call('points');
            //         },
            //         textController: widget.pointsController,
            //       ),
            //     ),
            //   ],
            // ),
            // if (widget.selectedImagePath != null)
            //   Padding(
            //     padding: EdgeInsets.symmetric(vertical: 0.02.h),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(8.0),
            //       child: Image.asset(
            //         widget.selectedImagePath!,
            //         height: 0.25.h,
            //         width: double.infinity,
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),
            if (widget.questionType == "Multiple Choice")
              MultipleChoiceWidget(
                controllers: widget.mcqControllers,
                onCorrectAnswerSelected: widget.onCorrectAnswerSelected,
                onAnswerChanged: updateAnswer,
              ),
            if (widget.questionType == "Drop Menu")
              DropDownWidget(
                controllers: widget.dropDownControllers,
                onCorrectAnswerSelected: widget.onCorrectAnswerSelected,
                onAnswerChanged: updateAnswer,
              ),
            if (widget.questionType == "Short Answer")
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.02.h),
                child: CustomTextFieldContainer(
                  hint: "Short Answer Text".tr,
                  isPayment: isTablet && isPortrait ? true : null,
                  textFieldHeight: textFieldHeight,
                  textController: widget.shortAnswerController,
                  controllerState: (value) {
                    widget.controllerState?.call('Short Answer Text');
                  },
                ),
              ),
            if (widget.questionType == "Long Answer")
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.02.h),
                child: CustomTextFieldContainer(
                  hint: "Paragraph Answer Text".tr,
                  textFieldHeight: isTablet
                      ? (isPortrait ? null : textFieldHeight)
                      : textFieldHeight,
                  isPayment: isTablet && isPortrait ? true : null,
                  textController: widget.paragaraphAnswerController,
                  controllerState: (value) {
                    widget.controllerState?.call('Paragraph Answer Text');
                  },
                  maxLines: 10,
                ),
              ),
            if (widget.questionType == "True Or False")
              TrueFalseWidget(
                onSelection: widget.onCorrectAnswerSelected,
                onAnswerChanged: updateAnswer,
              ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.01.h),
              child: Divider(
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorDarkGrey
                    : AppColors.colorGreydark,
                thickness: 1,
              ),
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DeleteMemberDialog(
                          lottieUrl: "assets/images/duplicate.json",
                          onPressed: () {
                            if (widget.isEdit == true) {
                              widget.onDuplicate();
                            } else {
                              widget.onDuplicate();
                              surveyController.duplicateQuestion(widget.index!);
                            }

                            Navigator.of(context).pop();
                          },
                          subtitle:
                              "This Question Will Be Duplicated With The Same Details",
                          title: "Do you Want To Duplicate This Question?",
                          yesText: "Yes, Duplicate",
                        );
                      },
                    );
                  },
                  child: Container(
                    width: isTablet ? (isPortrait ? 0.075.w : 0.05.w) : 0.1.w,
                    height: 0.05.h,
                    padding: EdgeInsets.all(0.011.h),
                    child: SvgPicture.asset(
                      color:
                          themeController.currentTheme == AppColors.lightTheme
                              ? AppColors.colorDarkGrey
                              : AppColors.colorGreydark,
                      "assets/icons/duplicate_icon.svg",
                    ),
                  ),
                ),
                SizedBox(width: 0.02.w),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DeleteMemberDialog(
                          lottieUrl: "assets/images/delete.json",
                          onPressed: () {
                            if (widget.isEdit == true) {
                              widget.onDelete();
                            } else {
                              widget.onDelete();
                              surveyController.deleteQuestion(widget.index!);
                            }

                            Navigator.of(context).pop();
                          },
                          subtitle:
                              "This Question Will Be Deleted From This Survey",
                          title: "Are You Sure To Delete This Question?",
                          yesText: "Yes, Delete",
                        );
                      },
                    );
                  },
                  child: Container(
                    //  color: Colors.amber,
                    width: isTablet ? (isPortrait ? 0.075.w : 0.05.w) : 0.1.w,
                    height: 0.05.h,
                    padding: EdgeInsets.all(0.011.h),
                    child: SvgPicture.asset(
                      "assets/icons/redTrash.svg",
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: isTablet ? (isPortrait ? 0.2.w : 0.125.w) : 0.4.w,
                  child: DialogueSwitchersRow(
                    title: 'Required',
                    switchValue: widget.isRequired,
                    switchValueState: (value) {
                      setState(() {
                        widget.onSwitchChanged(value);
                        widget.isRequired = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
