import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p15_product_request_toogel.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class RequestDetailsFinalDesktopScreen extends StatefulWidget {
  const RequestDetailsFinalDesktopScreen({super.key});

  @override
  State<RequestDetailsFinalDesktopScreen> createState() =>
      _RequestDetailsFinalDesktopScreenState();
}

class _RequestDetailsFinalDesktopScreenState
    extends State<RequestDetailsFinalDesktopScreen> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController reasonOfReturnController =
      TextEditingController();

  ///////////////////////// Controller /////////////////////////////

  String selectedType = "Asset Return";
  String? selectedPickupDate;
  String? selectedReason;
  TextEditingController requestIdController = TextEditingController();

  ///////////////////////////// For PicImage /////////////////////////////////////////
  List<PlatformFile> attachmentFiles = [];
  PlatformFile? productSpecificationFile;
  PlatformFile? productWarrantyFile;
  PlatformFile? attachmentFile;

  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Accept images, pdfs, videos, etc.
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (type == 'attachment') {
          attachmentFiles.add(result.files.first);
        }
      });
    }
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    return '${(bytes / 1024).ceil()} KB';
  }

  ///////////////////////////// For PicImage /////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> selectTypeList = [
      {"key": "Asset Return", "value": S.of(context).assetReturn},
      {"key": "Asset Repair", "value": S.of(context).assetRepair},
      {"key": "Routine Maintenance", "value": S.of(context).routineMaintenance},
      {"key": "Asset Missing", "value": S.of(context).assetMissing},
    ];
    final List<Map<String, String>> selectedReasonList = [
      {"key": "Due Date Of Return", "value": S.of(context).dueDateOfReturn},
      {
        "key": "Expected Lifetime Ended",
        "value": S.of(context).expectedLifetimeEnded,
      },
      {"key": "Damaged", "value": S.of(context).damaged},
    ];
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';
    Localizations.localeOf(context).languageCode == 'en';
    final isTablet = context.isTablet;
    final isMobile = context.isPhone;
    final isLandscape = context.isLandscape;
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).productRequests,
          onSecondTap: () {
            navigateTo(context, ProductRequest());
          },
          thirdTitle: S.of(context).myRequest,
          onThirdTap: () {},
          fourthTitle: S.of(context).createNewRequest,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Request Details
                Row(
                  children: [
                    Text(
                      S.of(context).requestDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                // space
                SizedBox(height: 8.sp),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.card,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 15.sp,
                      right: 15.sp,
                      left: 15.sp,
                      bottom: 15.sp,
                    ),
                    child: Column(
                      children: [
                        // Request ID & Selected Type
                        buildResponsiveFields(
                          context: context,
                          left: requestIdField(lightMode),
                          right: requestTypeDropdown(selectTypeList),
                        ),

                        SizedBox(height: 15.sp),
                        // Category & Subcategory
                        buildResponsiveFields(
                          context: context,
                          left: categoryField(lightMode),
                          right: subCategoryField(lightMode),
                        ),

                        SizedBox(height: 15.sp),
                        // Brand & Model
                        buildResponsiveFields(
                          context: context,
                          left: brandField(lightMode),
                          right: modelField(lightMode),
                        ),

                        SizedBox(height: 15.sp),
                        // Quantity &  Pick Up Date
                        buildResponsiveFields(
                          context: context,
                          left: quantityField(lightMode),
                          right: pickupDateDropdown(selectedReasonList),
                        ),

                        SizedBox(height: 15.sp),
                        // Reason Of Return
                        Row(
                          children: [
                            // Reason Of Return
                            Expanded(
                              child: SizedBox(
                                width: isMobile
                                    ? MediaQuery.sizeOf(context).width
                                    : isTablet && !isLandscape
                                        ? MediaQuery.sizeOf(context).width *
                                            .375
                                        : MediaQuery.sizeOf(context).width *
                                            .41,
                                child: CustomDropdown<String>(
                                  items: (selectedReasonList)
                                      .map((e) => DropdownItem<String>(
                                          value: e['key'] ?? '',
                                          label: e['value'] ?? ''))
                                      .toList(),
                                  value: selectedReason,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedReason = value;
                                    });
                                  },
                                  label: S.of(context).reasonOfReturn,
                                  hint: "Due Date Of Return",
                                  height: 36.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // space
                        SizedBox(height: 15.sp),
                        // Reason Of Return Text
                        Row(
                          children: [
                            // Reason Of Return
                            Expanded(
                              child: CustomValidatedTextFieldMaster(
                                label: S.of(context).reasonOfReturn,
                                textStyle:
                                    StyleText.fontSize14Weight400.copyWith(
                                  color: AppColors.blackButton,
                                ),
                                hint: S.of(context).reasonOfReturn,
                                height: 72.sp,
                                maxLines: 3,
                                controller: reasonOfReturnController,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),

                        // space
                        SizedBox(height: 34.sp),
                        Row(
                          children: [
                            Text(
                              S.of(context).attachments,
                              style: StyleText.fontSize14Weight400.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.sp),

                        Row(
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10.sp,
                              runSpacing: 10.sp,
                              children: [
                                ...attachmentFiles.map((file) {
                                  return Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        width: 80.sp,
                                        height: 80.sp,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                          color: lightMode
                                              ? AppColors.grey
                                              : AppColors.background,
                                        ),
                                        child: CustomSvgImage(
                                          assetPath:
                                              "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                          width: 40.sp,
                                          height: 40.sp,
                                          color: AppColors.blackButton,
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: GestureDetector(
                                          onTapDown: (_) =>
                                              HapticController.high(),
                                          onTap: () {
                                            setState(() {
                                              attachmentFiles.remove(file);
                                            });
                                          },
                                          child: CustomSvgImage(
                                            assetPath:
                                                "assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg",
                                            width: 20.sp,
                                            height: 20.sp,
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                GestureDetector(
                                  onTapDown: hapticDown(
                                      showAttachmentUploadDialog,
                                      HapticLevel.medium),
                                  onTap: showAttachmentUploadDialog,
                                  child: Container(
                                    width: 40.sp,
                                    height: 40.sp,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryPrimary,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: CustomSvgImage(
                                      assetPath:
                                          "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                                      width: 19.sp,
                                      height: 19.sp,
                                      color: AppColors.white,
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.sp),

                Row(
                  textDirection: TextDirection
                      .ltr, // X-73: Cancel left, action right in both languages

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ Discard
                    customButton(
                      title: S.of(context).discard,
                      function: () {
                        Navigator.pop(context);
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.grey,
                    ),

                    // ✅ Next
                    customButton(
                      title: S.of(context).submit,
                      function: _showConfirmDialog,
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showAttachmentUploadDialog() {
    int step = 1; // Currently only step 1 UI shown
    final themeMode = Theme.of(context).brightness == Brightness.light;

    showAppDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor:
              themeMode ? AppColors.white : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: SizedBox(
            width: 600.sp,
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 30./30./16. row.
                      CustomDialogHeader(
                          title: S.of(context).addingAttachment,
                          icon:
                              "assets/icons_assets/main_icons_assets/ic_upload.svg"),

                      SizedBox(height: 23.sp),

                      if (step == 1) ...[
                        Center(
                          child: Column(
                            children: [
                              CustomSvgImage(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_cloud_upload.svg",
                                width: 100.sp,
                                height: 100.sp,
                                color:
                                    themeMode ? AppColors.grey : AppColors.grey,
                                fit: BoxFit.scaleDown,
                              ),
                              SizedBox(height: 27.sp),
                              Text(
                                S.of(context).dragDropHere,
                                style: StyleText.fontSize20Weight500.copyWith(
                                  color: themeMode
                                      ? AppColors.blackButton
                                      : AppColors.white,
                                ),
                              ),
                              Text(S.of(context).or),
                              SizedBox(height: 20.sp),
                              Row(
                                textDirection: TextDirection
                                    .ltr, // X-73: Cancel left, action right in both languages

                                children: [
                                  customButton(
                                    title: S.of(context).discard,
                                    function: () {
                                      Navigator.pop(context);
                                    },
                                    color: const Color(0xffcccccc),
                                    radius: 8.r,
                                    textStyle: StyleText.fontSize16Weight600
                                        .copyWith(color: AppColors.blackButton),
                                    width: 150.sp,
                                    height: 38.sp,
                                  ),
                                  const Spacer(),
                                  customButton(
                                    title: S.of(context).browseFiles,
                                    function: () async {
                                      Navigator.pop(
                                        context,
                                      ); // Close dialog first
                                      await pickFile(
                                        'attachment',
                                      ); // Call your file picker
                                    },
                                    color: AppColors.primary,
                                    radius: 8.r,
                                    textStyle:
                                        StyleText.fontSize16Weight600.copyWith(
                                      color: AppColors.textButton,
                                    ),
                                    width: 150.sp,
                                    height: 38.sp,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
  ////////////////////////////// Dialog Verify  //////////////////////////////

  ////////////////////////////// customInputField /////////////////////////////

  Widget requestIdField(bool lightMode) => CustomValidatedTextFieldMaster(
        label: S.of(context).requestID,
        height: 36.sp,
        hint: S.of(context).requestID,
        controller: requestIdController,
        textStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.blackButton,
        ),
        onChanged: (_) => setState(() {}),
      );

  Widget requestTypeDropdown(List<Map<String, String>> selectTypeList) {
    return CustomDropdown<String>(
      items: (selectTypeList)
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedType,
      onChanged: (value) {
        setState(() {
          selectedType = value;
        });
      },
      label: S.of(context).requestType,
      height: 36.sp,
    );
  }

  Widget categoryField(bool lightMode) => CustomValidatedTextFieldMaster(
        label: S.of(context).category,
        height: 36.sp,
        hint: S.of(context).category,
        controller: categoryController,
        textStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.blackButton,
        ),
        onChanged: (_) => setState(() {}),
      );

  Widget subCategoryField(bool lightMode) => CustomValidatedTextFieldMaster(
        label: S.of(context).subcategory,
        height: 36.sp,
        hint: S.of(context).subcategory,
        controller: subCategoryController,
        textStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.blackButton,
        ),
        onChanged: (_) => setState(() {}),
      );

  Widget brandField(bool lightMode) => CustomValidatedTextFieldMaster(
        label: S.of(context).brand,
        height: 36.sp,
        hint: S.of(context).brand,
        controller: brandController,
        textStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.blackButton,
        ),
        onChanged: (_) => setState(() {}),
      );

  Widget modelField(bool lightMode) => CustomValidatedTextFieldMaster(
        label: S.of(context).model,
        height: 36.sp,
        hint: S.of(context).model,
        controller: modelController,
        textStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.blackButton,
        ),
        onChanged: (_) => setState(() {}),
      );

  Widget quantityField(bool lightMode) => CustomValidatedTextFieldMaster(
        label: S.of(context).quantity,
        height: 36.sp,
        hint: S.of(context).quantity,
        controller: quantityController,
        textStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.blackButton,
        ),
        onChanged: (_) => setState(() {}),
      );

  Widget pickupDateDropdown(List<Map<String, String>> selectTypeList) {
    return CustomDateField(
      value: DateFormat('d/M/yyyy').tryParse((selectedPickupDate) ?? ''),
      onChanged: (date) {
        if (date == null) return;
        ((value) {
          if (value != null) {
            setState(() {
              selectedPickupDate = value;
            });
          }
        })(DateFormat('d/M/yyyy').format(date));
      },
      label: S.of(context).pickUpDate,
      hint: "24 Nov 2018",
      height: 36.sp,
    );
  }

  Widget reasonOfReturnDropdown(
    bool isTablet,
    bool isLandscape,
    List<Map<String, String>> selectedReasonList,
  ) {
    return SizedBox(
      width: isTablet && !isLandscape
          ? MediaQuery.sizeOf(context).width * 0.375
          : MediaQuery.sizeOf(context).width * 0.41,
      child: CustomDropdown<String>(
        items: (selectedReasonList)
            .map((e) => DropdownItem<String>(
                value: e['key'] ?? '', label: e['value'] ?? ''))
            .toList(),
        value: selectedReason,
        onChanged: (value) {
          setState(() {
            selectedReason = value;
          });
        },
        label: S.of(context).reasonOfReturn,
        hint: "Due Date Of Return",
        height: 36.sp,
      ),
    );
  }

  ////////////////////////////// customInputField /////////////////////////////

  void _showConfirmDialog() {
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Container(
          width: 411.sp,
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json',
                width: 70.w,
                height: 70.h,
                fit: BoxFit.scaleDown,
                repeat: true, // Set to false if you don't want it to loop
                animate: true, // Set to false to pause the animation
              ),
              SizedBox(height: 20.sp),
              Text(
                S.of(context).newRequest,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                S.of(context).confirmCreateRequest,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 15.sp),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => HapticController.low(),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 38.sp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? AppColors.secondaryButton
                                  : AppColors.whiteShadow,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          S.of(context).no,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 28.sp),
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => HapticController.low(),
                      onTap: () {
                        Navigator.pop(context);
                        _showSuccessDialog(context);
                      },
                      child: Container(
                        height: 38.sp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          S.of(context).yes,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResponsiveFields({
    required BuildContext context,
    required Widget left,
    required Widget right,
  }) {
    final isMobile = kpIsPhoneLayout(context);

    if (isMobile) {
      return Column(children: [left, SizedBox(height: 10.sp), right]);
    } else {
      return Row(
        children: [
          Expanded(child: left),
          SizedBox(width: 15.sp),
          Expanded(child: right),
        ],
      );
    }
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    final rootContext = context;
    await showAppDialog(
      context: rootContext,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: SizedBox(
            width: 410.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  S.of(context).newRequest,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).successCreateRequest,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////// Dialog Verify  //////////////////////////////
}
