/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_bulk_visions.dart
/// Purpose: Screen for handling bulk upload of Qiyas data,
///          including file selection, status display, and user interaction.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This screen provides the ui and logic for uploading
///              bulk Qiyas vision files, managing upload status, filters,
///              and user input focus. Designed to simplify data import
///              workflows in a user-friendly interface.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/page_screen_toplevel.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_validation_controller.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/core/enums/csv_status.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_visions_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/ui/widgets/tablet/qiyas_bulk_buttons.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class QiyasBulkVisions extends StatefulWidget {
  const QiyasBulkVisions({
    super.key,
    required this.status,
  });

  final CsvStatus status;

  @override
  State<QiyasBulkVisions> createState() => _QiyasBulkVisionsState();
}

class _QiyasBulkVisionsState extends State<QiyasBulkVisions> {
  int selectedFilterIndex = 0;
  bool isEmpty = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {}); // Rebuilds when focus changes
    });
  }

  Future<void> scrollToErrorField(FocusNode focusNode) async {
    await Future.delayed(const Duration(milliseconds: 100));
    Scrollable.ensureVisible(
      focusNode.context!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Clean up focus node
    super.dispose();
  }

  bool isChecked = false;

  /// Commits a cell edit back into the controller and re-runs validation.
  /// Replaces the old CustomTextFieldContainer.controllerfinishState callback.
  void _commitCell(
    QiyasBulkVisionsController controller,
    int rowIndex,
    int columnIndex,
    String value,
  ) {
    controller.visionData[rowIndex][columnIndex] = value;
    controller.errors.clear();
    controller.makeAllValidations(controller.visionData, widget.status);
    controller.textFormFieldData[rowIndex - 1][columnIndex]
        .textFormFieldControllers.text = value;
    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = !kpIsPhoneLayout(context);
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return GetBuilder<QiyasBulkVisionsController>(
      init: QiyasBulkVisionsController(),
      builder: (controller) => Directionality(
        textDirection: TextDirection.rtl,
        child: PageScreenTopLevel(
          title: "الرفع الجماعي",
          hasBackArrow: true,
          scrum: true,
          hasScroll: true,
          isQiyasMode: true,
          titles: const ["قياس التحول الرقمي", "الرفع الجماعي"],
          functions: [
            () {
              Navigator.pop(context);
            },
            () {}
          ],
          children: [
            // todo delete file name
            // Text(
            //   "اسم الملف",
            //   style: TextStyle(
            //     fontSize: 28,
            //     fontWeight: FontWeight.w600,
            //     fontFamily: StyleText.englishFontFamily,
            //     color: AppColors.red,
            //   ),
            // ),
            // SizedBox(height: 0.02.h),
            SizedBox(height: 0.01.h),
            Container(
              height: 0.5.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              padding: EdgeInsets.only(
                top: isTablet ? (orientation ? 0.015.h : 0.015.w) : 0.04.w,
                bottom: isTablet ? (orientation ? 0.015.h : 0.015.w) : 0.04.w,
                right: isTablet ? (orientation ? 0.015.h : 0.015.w) : 0.04.w,
                left: isTablet ? (orientation ? 0.015.h : 0.015.w) : 0.04.w,
              ),
              child: GetBuilder<QiyasBulkVisionsController>(
                init: QiyasBulkVisionsController(),
                builder: (controller) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    height: isPortrait ? 0.25.h : 0.45.h,
                    width: MediaQuery.of(context).size.width * 3.02,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: false,
                      itemCount: controller.visionData.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return index == 0
                            ? Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  child: SizedBox(
                                    height: 50,
                                    child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          controller.visionData[0].length,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemBuilder: (context, x) {
                                        // ✅ REVERSE THE HEADER INDEX
                                        int reversedX =
                                            controller.visionData[0].length -
                                                1 -
                                                x;

                                        return Focus(
                                          focusNode: controller
                                              .textHeaderData[reversedX]
                                              .focusNode,
                                          child: SizedBox(
                                            width: 0.3.w,
                                            child: Row(
                                              children: [
                                                Text(
                                                  controller
                                                      .textHeaderData[reversedX]
                                                      .columnName,
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: StyleText
                                                        .englishFontFamily,
                                                    color: controller
                                                                .textHeaderData[
                                                                    reversedX]
                                                                .hasErrorIcon ==
                                                            true
                                                        ? AppColors.red
                                                        : AppColors.text,
                                                  ),
                                                ),
                                                controller
                                                            .textHeaderData[
                                                                reversedX]
                                                            .hasErrorIcon ==
                                                        true
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 5),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            HapticController
                                                                .low(); // list row: on the tap (X-117)
                                                            CustomDialogManager
                                                                .showMessage(
                                                              context: context,
                                                              lottiePath:
                                                                  "assets/lottie_assets/main_lottie_assets/lot_status_error.json",
                                                              title: controller
                                                                      .textHeaderData[
                                                                          reversedX]
                                                                      .errorTitle ??
                                                                  '',
                                                              subtitle: controller
                                                                      .textHeaderData[
                                                                          reversedX]
                                                                      .errorSubTitle ??
                                                                  '',
                                                            );
                                                          },
                                                          child: SvgPicture.asset(
                                                              "assets/icons_assets/main_icons_assets/ic_warning_exclamation_circle.svg"),
                                                        ),
                                                      )
                                                    : const SizedBox.shrink()
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 150,
                                        child: ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          padding:
                                              EdgeInsets.only(left: 0.02.w),
                                          itemCount:
                                              controller.visionData[0].length,
                                          itemBuilder: (context, j) {
                                            // ✅ REVERSE THE COLUMN INDEX
                                            int reversedJ = controller
                                                    .visionData[0].length -
                                                1 -
                                                j;

                                            if (controller.errors.isNotEmpty) {
                                              for (int i = 0;
                                                  i < controller.errors.length;
                                                  i++) {
                                                controller
                                                    .textFormFieldData[
                                                        controller
                                                            .errors[i].rowIndex]
                                                        [controller.errors[i]
                                                            .columnIndex]
                                                    .border = AppColors.block;
                                              }
                                            }
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: controller
                                                              .textFormFieldData[
                                                                  index - 1]
                                                                  [reversedJ]
                                                              .hasErrorIcon ==
                                                          true
                                                      ? 0.28.w
                                                      : 0.3.w,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 7),
                                                    child: CustomTextField(
                                                      focusNode: controller
                                                          .textFormFieldData[
                                                              index - 1]
                                                              [reversedJ]
                                                          .focusNode,
                                                      key: controller
                                                          .textFormFieldData[
                                                              index - 1]
                                                              [reversedJ]
                                                          .fieldKeys,
                                                      controller: controller
                                                          .textFormFieldData[
                                                              index - 1]
                                                              [reversedJ]
                                                          .textFormFieldControllers,
                                                      onSubmitted: (value) =>
                                                          _commitCell(
                                                              controller,
                                                              index,
                                                              reversedJ,
                                                              value),
                                                      onFocusChanged:
                                                          (hasFocus) {
                                                        if (hasFocus) return;
                                                        _commitCell(
                                                            controller,
                                                            index,
                                                            reversedJ,
                                                            controller
                                                                .textFormFieldData[
                                                                    index - 1]
                                                                    [reversedJ]
                                                                .textFormFieldControllers
                                                                .text);
                                                      },
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value
                                                                .trim()
                                                                .isEmpty) {
                                                          return "Field cannot be empty";
                                                        }
                                                        return null;
                                                      },
                                                      errorText: controller
                                                                  .textFormFieldData[
                                                                      index - 1]
                                                                      [
                                                                      reversedJ]
                                                                  .hasErrorIcon ==
                                                              true
                                                          ? controller
                                                              .textFormFieldData[
                                                                  index - 1]
                                                                  [reversedJ]
                                                              .errorTitle
                                                          : null,
                                                      maxLines: 6,
                                                      hint: '',
                                                      valueStyle: TextStyle(
                                                          color:
                                                              AppColors.text),
                                                    ),
                                                  ),
                                                ),
                                                controller
                                                            .textFormFieldData[
                                                                index - 1]
                                                                [reversedJ]
                                                            .hasErrorIcon ==
                                                        true
                                                    ? SizedBox(
                                                        width: 0.02.w,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            HapticController
                                                                .low(); // list row: on the tap (X-117)
                                                            CustomDialogManager
                                                                .showMessage(
                                                              context: context,
                                                              lottiePath:
                                                                  "assets/lottie_assets/main_lottie_assets/lot_status_error.json",
                                                              title: controller
                                                                      .textFormFieldData[
                                                                          index -
                                                                              1]
                                                                          [
                                                                          reversedJ]
                                                                      .errorTitle ??
                                                                  '',
                                                              subtitle: controller
                                                                      .textFormFieldData[
                                                                          index -
                                                                              1]
                                                                          [
                                                                          reversedJ]
                                                                      .errorSubTitle ??
                                                                  '',
                                                            );
                                                          },
                                                          child: SvgPicture.asset(
                                                              "assets/icons_assets/main_icons_assets/ic_warning_exclamation_circle.svg"),
                                                        ),
                                                      )
                                                    : const SizedBox.shrink()
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                      },
                    ),
                  ),
                ),
              ),
            ),
            QiyasBulkButtons(controller: controller)
          ],
        ),
      ),
    );
  }
}
