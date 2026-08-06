
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/custom_appbar_mobile.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';

import 'package:grc_module/core/theme/app_font_size.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/custom_button_widget.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/50_custom_side_frame_master.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/settings/se7_app_info/domain/enums/languages.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_check_box.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import '../../../../../external/knowledge_hub_module/core/custom_validated_text_field_master.dart';
import 'package:grc_module/core/custom/23-custom_check_box.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class CommentsAndFeedbackScreen extends StatefulWidget {
  const CommentsAndFeedbackScreen({super.key});

  @override
  _CommentsAndFeedbackScreenState createState() => _CommentsAndFeedbackScreenState();
}

class _CommentsAndFeedbackScreenState extends State<CommentsAndFeedbackScreen> {
  Languages? selectedLanguage = Languages.english;
  final textControllerReport = TextEditingController();
  final textControllerComments = TextEditingController();
  final textControllerRequest = TextEditingController();

  // Checkbox states - START UNCHECKED (false)
  bool isReportBugsSelected = false;
  bool isCommentsSelected = false;
  bool isRequestFeatureSelected = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to rebuild when text changes
    textControllerReport.addListener(() => setState(() {}));
    textControllerComments.addListener(() => setState(() {}));
    textControllerRequest.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    textControllerReport.dispose();
    textControllerComments.dispose();
    textControllerRequest.dispose();
    super.dispose();
  }

  // Check if any checkbox is selected AND has data
  bool get hasAnyData {
    bool reportHasData = isReportBugsSelected && textControllerReport.text.trim().isNotEmpty;
    bool commentsHasData = isCommentsSelected && textControllerComments.text.trim().isNotEmpty;
    bool requestHasData = isRequestFeatureSelected && textControllerRequest.text.trim().isNotEmpty;

    return reportHasData || commentsHasData || requestHasData;
  }

  // Get button color based on data
  Color get buttonColor => hasAnyData ? AppColors.signOut : const Color(0xFFD9D9D9);

  // Build checkbox with label
  Widget buildCheckboxRow(String title, bool isSelected, Function(bool) onChanged) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return InkWell(
      onTap: () => onChanged(!isSelected),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h,horizontal: 0.w),
        child: Row(
          children: [
            CustomCheckBox(
              borderColor: Colors.grey,
              isSelected: isSelected,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    var lightMode = Theme.of(context).brightness == Brightness.light;
    final orientation = MediaQuery.of(context).orientation;
    final HapticController hapticController = Get.put(HapticController());

    return MediaQuery.of(context).size.shortestSide > 600
        ? Expanded(
      child: Column(
        children: [
          Expanded(
            child: Container(

              width: double.infinity,
              decoration: BoxDecoration(
                color:  isMobile ? AppColors.background : AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  // Fixed Title Header
                  Padding(
                    padding: EdgeInsets.only(
                      top: 15.h,
                      right: 15.w,
                      left: 15.w,
                    ),
                    child: Row(
                      children: [
                        Center(
                          child: CustomSvgImage(
                            assetPath: "assets/icons_assets/settings_assets/feedback_stamp.svg",
                            width: 25.w,
                            height: 25.h,
                            fit: BoxFit.fill,
                          ),
                        ),
                        SizedBox(width: 10.sp),
                        Text(
                          S.of(context).commentsAndFeedbacks,
                          style: StyleText.fontSize20Weight600.copyWith(
                            color: AppColors.text
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.shortestSide > 600
                        ? (orientation == Orientation.portrait ? 0.02.h : 0.04.h)
                        : 0,
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        right: 15.w,
                        left: 15.w,
                        bottom: 15.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ============ REPORT BUGS SECTION ============
                          buildCheckboxRow(
                            'Report Bugs',
                            isReportBugsSelected,
                                (value) {
                              setState(() {
                                isReportBugsSelected = value;
                                if (!value) {
                                  textControllerReport.clear();
                                }
                              });
                            },
                          ),

                          // Show TextField only if checkbox is selected
                          if (isReportBugsSelected) ...[
                            SizedBox(height: 8.h),
                            CustomTextField(
                              hint: S.of(context).textHere,
                              controller: textControllerReport,
                              maxLines: 3,
                              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                              onChanged: (value) => setState(() {}),
                            ),
                          ],

                          SizedBox(height: 15.h),

                          // ============ COMMENTS AND FEEDBACK SECTION ============
                          buildCheckboxRow(
                            'Comments And Feedback',
                            isCommentsSelected,
                                (value) {
                              setState(() {
                                isCommentsSelected = value;
                                if (!value) {
                                  textControllerComments.clear();
                                }
                              });
                            },
                          ),

                          // Show TextField only if checkbox is selected
                          if (isCommentsSelected) ...[
                            SizedBox(height: 8.h),
                            CustomTextField(
                              hint: S.of(context).textHere,
                              controller: textControllerComments,
                              maxLines: 3,
                              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                              onChanged: (value) => setState(() {}),
                            ),
                          ],

                          SizedBox(height: 15.h),

                          // ============ REQUEST NEW FEATURE SECTION ============
                          buildCheckboxRow(
                            'Request New Feature',
                            isRequestFeatureSelected,
                                (value) {
                              setState(() {
                                isRequestFeatureSelected = value;
                                if (!value) {
                                  textControllerRequest.clear();
                                }
                              });
                            },
                          ),

                          // Show TextField only if checkbox is selected
                          if (isRequestFeatureSelected) ...[
                            SizedBox(height: 8.h),
                            CustomTextField(
                              hint: S.of(context).textHere,
                              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                              controller: textControllerRequest,
                              maxLines: 3,
                              onChanged: (value) => setState(() {}),
                            ),
                          ],

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // space
          SizedBox(height: 15.sp),

          // submit button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customButton(
                title: S.of(context).confirm,
                function: hasAnyData
                    ? () {
                  hapticController.triggerHapticFeedback(
                    vibration: VibrateType.mediumImpact,
                    hapticFeedback: HapticFeedback.mediumImpact,
                  );
                }
                    : () {}, // Empty function instead of null
                textStyle: StyleText.fontSize16Weight500.copyWith(
                  color: hasAnyData ? AppColors.textButton : lightMode ? Colors.black : Colors.white,
                ),
                color: hasAnyData ? AppColors.primary : lightMode ? Colors.grey[400] : Colors.grey[700],
                width: 300.w,
                radius: 4.r,
                height: 36.h,
              ),
            ],
          ),

          // space
          SizedBox(height: 15.sp),
        ],
      ),
    )
        : Scaffold(
      body: SideFrameMasterServices(
          titleText: S.of(context).settings,
          secondTitle: S.of(context).commentAndFeedback,
        onFirstTap: (){
          Navigator.pop(context);
        },
        onSecondTap: (){
            Navigator.pop(context);
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 15.h,

              ),
              child: Row(
                children: [
                  Center(
                    child: CustomSvgImage(
                      assetPath: "assets/icons_assets/settings_assets/feedback_stamp.svg",
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(width: 10.sp),
                  Text(
                    S.of(context).commentsAndFeedbacks,
                    style: StyleText.fontSize20Weight600.copyWith(
                      color: AppColors.text
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.sp),
            Container(

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: AppColors.card
              ),

              child: Padding(
                padding: EdgeInsets.only(top: 15.sp,right: 15.sp,left: 15.sp),
                child: Column(
                  children: [
                    // CustomAppBarMobile(
                    //   showIcon: true,
                    //   showMoreIcon: false,
                    //   title: "Comments And Feedbacks",
                    // ),
                    Column(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ============ REPORT BUGS SECTION ============
                        buildCheckboxRow(

                          'Report Bugs',
                          isReportBugsSelected,
                              (value) {
                            setState(() {
                              isReportBugsSelected = value;
                              if (!value) {
                                textControllerReport.clear();
                              }
                            });
                          },
                        ),

                        // Show TextField only if checkbox is selected
                        if (isReportBugsSelected) ...[
                          SizedBox(height: 8.h),
                          CustomTextField(
                            label: S.of(context).reportBugs,
                            textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                            hint: S.of(context).enter_bug_details,
                            controller: textControllerReport,
                            maxLines: 3,
                            onChanged: (value) => setState(() {}),
                          ),
                        ],

                        SizedBox(height: 15.h),

                        // ============ COMMENTS AND FEEDBACK SECTION ============
                        buildCheckboxRow(
                          'Comments And Feedback',
                          isCommentsSelected,
                              (value) {
                            setState(() {
                              isCommentsSelected = value;
                              if (!value) {
                                textControllerComments.clear();
                              }
                            });
                          },
                        ),

                        // Show TextField only if checkbox is selected
                        if (isCommentsSelected) ...[
                          SizedBox(height: 8.h),
                          CustomTextField(
                            label: S.of(context).commentsAndFeedback,
                            hint: S.of(context).enter_your_comments,
                            controller: textControllerComments,
                            textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                            maxLines: 3,
                            onChanged: (value) => setState(() {}),
                          ),
                        ],

                        SizedBox(height: 15.h),

                        // ============ REQUEST NEW FEATURE SECTION ============
                        buildCheckboxRow(
                          'Request New Feature',
                          isRequestFeatureSelected,
                              (value) {
                            setState(() {
                              isRequestFeatureSelected = value;
                              if (!value) {
                                textControllerRequest.clear();
                              }
                            });
                          },
                        ),

                        // Show TextField only if checkbox is selected
                        if (isRequestFeatureSelected) ...[
                          SizedBox(height: 8.h),
                          CustomTextField(
                            label: S.of(context).requestNewFeature,
                            hint: S.of(context).describe_the_feature,
                            controller: textControllerRequest,
                            maxLines: 3,
                            textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                            onChanged: (value) => setState(() {}),
                          ),
                        ],

                        const SizedBox(height: 10),
                      ],
                    ),

                  ],
                ),
              ),
            ),

            SizedBox(height: 15.sp),
            customButton(
                title: S.of(context).submit,
                function: (){
                  hasAnyData
                      ? () async {

                    hapticController.triggerHapticFeedback(
                      vibration: VibrateType.mediumImpact,
                      hapticFeedback: HapticFeedback.mediumImpact,
                    );

                    // Was CustomDialogBox (showButtons: false) — a plain
                    // acknowledgement. Now the shared success dialog.
                    await CustomDialogManager.showSuccess(
                      context: context,
                      lottiePath:
                          'assets/lottie_assets/main_lottie_assets/lottie_successful.json',
                      title: S.of(context).thanksForSharingYourFeedback,
                      subtitle: S
                          .of(context)
                          .weValueOurCustomersAndStriveToExceedTheirExpecta,
                    );

                    setState(() {
                      Get.back();
                    });
                  }
                      : (){};
                },
                width: isMobile ? 340.w :  300.w,
                height: 38.h,
                color: hasAnyData ? AppColors.primary : lightMode ?  Colors.grey[400] : Colors.grey[700],
                textStyle: StyleText.fontSize16Weight500.copyWith(
                  color: hasAnyData ? AppColors.textButton:lightMode ?  Colors.black : Colors.white,
                )
            ),
            isMobile ?   SizedBox(height: 15.sp) : SizedBox()
          ],
        ),
      )
    );
  }
}