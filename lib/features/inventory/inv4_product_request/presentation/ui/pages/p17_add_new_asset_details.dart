import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/cards/custom_approval_shape.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class AddNewAssetsDetailsDesktopScreen extends StatefulWidget {
  const AddNewAssetsDetailsDesktopScreen({super.key});

  @override
  State<AddNewAssetsDetailsDesktopScreen> createState() =>
      _AddNewAssetsDetailsDesktopScreenState();
}

class _AddNewAssetsDetailsDesktopScreenState
    extends State<AddNewAssetsDetailsDesktopScreen> {
  late ApprovalSection section;

  @override
  void initState() {
    super.initState();

    section = ApprovalSection(
      selectedApprovers: [
        EmployeeEntity(
          id: '1',
          firstName: "Ahmed",
          lastName: "Abd el Rahman",
          firstNameInArabic: "أحمد",
          lastNameInArabic: "عبد الرحمن",
          title: "HR",
          titleInArabic: "الموارد البشرية",
          gender: "male",
        ),
        EmployeeEntity(
          id: '2',
          firstName: "Sara",
          lastName: "Ali",
          firstNameInArabic: "سارة",
          lastNameInArabic: "علي",
          title: "Finance",
          titleInArabic: "المالية",
          gender: "female",
        ),
        EmployeeEntity(
          id: '3',
          firstName: "Mohamed",
          lastName: "Youssef",
          firstNameInArabic: "محمد",
          lastNameInArabic: "يوسف",
          title: "IT",
          titleInArabic: "تكنولوجيا المعلومات",
          gender: "male",
        ),
        EmployeeEntity(
          id: '4',
          firstName: "Laila",
          lastName: "Ibrahim",
          firstNameInArabic: "ليلى",
          lastNameInArabic: "إبراهيم",
          title: "Legal",
          titleInArabic: "القانونية",
          gender: "female",
        ),
        EmployeeEntity(
          id: '5',
          firstName: "Omar",
          lastName: "Salem",
          firstNameInArabic: "عمر",
          lastNameInArabic: "سالم",
          title: "Operations",
          titleInArabic: "العمليات",
          gender: "male",
        ),
      ],
    );
  }

  /////////////////////// Controller //////////////////////////////

  TextEditingController requestIdController = TextEditingController();
  TextEditingController assetsNameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController subCategoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priorityController = TextEditingController();
  TextEditingController expectedReturnController = TextEditingController();
  TextEditingController expectedDeliveryController = TextEditingController();
  TextEditingController additionalNoteController = TextEditingController();
  TextEditingController maintenanceFrequencyController =
      TextEditingController();
  TextEditingController reasonForRequestController = TextEditingController();
  TextEditingController officeCoordinatesController = TextEditingController();

  /////////////////////// Controller //////////////////////////////
  /////////////////////// DropDown ////////////////////////////////
  String? selectedPriority;
  String? selectedTypeOfAssets;
  String? selectedDeliveryMethod;
  String? selectedReceivingMethod;
  String? selectedLocationDelivery;

  /////////////////////// DropDown ////////////////////////////////

  /////////////////////// Upload ////////////////////////////////
  PlatformFile? uploadAttachmentFile;

  Future<void> pickFile() async {
    if (uploadAttachmentFile != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("You can upload only one file.")));
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        uploadAttachmentFile = result.files.first;
      });
    }
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    return '${(bytes / 1024).ceil()} KB';
  }
  /////////////////////// Upload ////////////////////////////////

  bool requireApproval = false;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> selectedPriorityList = [
      {"key": "Urgent", "value": S.of(context).priorityUrgent},
      {"key": "High", "value": S.of(context).priorityHigh},
      {"key": "Medium", "value": S.of(context).priorityMedium},
      {"key": "Low", "value": S.of(context).priorityLow},
    ];
    final durationUnits = [
      {"key": "HandDelivery", "value": S.of(context).handDelivery},
      {"key": "PickUp", "value": S.of(context).pickup},
    ];
    Localizations.localeOf(context).languageCode == 'ar';
    Localizations.localeOf(context).languageCode == 'en';
    final isMobile = context.isPhone;
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).addingNewProduct,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Asset Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).assetDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                // space
                SizedBox(height: 8.sp),

                // Content Page
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.card,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 15.sp,
                      left: 15.sp,
                      right: 15.sp,
                      bottom: 15.sp,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Switch
                        /*
                          Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              S.of(context).automaticIDs,
                              style: StyleText.fontSize14Weight400.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                            SizedBox(width: 15.sp),
                            FlutterSwitch(
                              height: 22.0.sp,
                              width: 38.0.sp,
                              toggleSize: 18.0,
                              value: requireApproval,
                              borderRadius: 20.0,
                              padding: 1.5,
                              activeColor: AppColors.secondaryPrimary,
                              onToggle: (val) {
                                setState(() {
                                  requireApproval = val;
                                });
                              },
                            ),
                          ],
                        ),
                         */

                        //  Request ID & Asset Id
                        buildResponsiveFields(
                          left: requestIdField(),
                          right: assetIdField(),
                          context: context,
                        ),
                        // space
                        SizedBox(height: 10.sp),
                        //  Category & Subcategory
                        buildResponsiveFields(
                          left: categoryField(),
                          right: subcategoryField(),
                          context: context,
                        ),
                        // space
                        SizedBox(height: 10.sp),
                        //  Brand & Model
                        buildResponsiveFields(
                          left: brandField(),
                          right: modelField(),
                          context: context,
                        ),
                        // space
                        SizedBox(height: 10.sp),
                        // Maintenance Frequency & Type of Asset Request
                        buildResponsiveFields(
                          left: maintenanceFrequencyField(),
                          right: typeOfAssetDropdown(selectedPriorityList),
                          context: context,
                        ),

                        // space
                        SizedBox(height: 10.sp),
                        //  quantity & Priority
                        buildResponsiveFields(
                          left: quantityField(),
                          right: priorityDropdown(selectedPriorityList),
                          context: context,
                        ),
                        // space
                        SizedBox(height: 10.sp),
                        // Receiving Method & Location Delivery
                        buildResponsiveFields(
                          left: receivingMethodDropdown(selectedPriorityList),
                          right: locationDeliveryDropdown(selectedPriorityList),
                          context: context,
                        ),
                        // space
                        SizedBox(height: 10.sp),
                        //  Expected Delivery & Expected Return
                        buildResponsiveFields(
                          left: expectedDeliveryDateDropdown(durationUnits),
                          right: expectedReturnDateDropdown(
                            selectedPriorityList,
                          ),
                          context: context,
                        ),
                        // space
                        SizedBox(height: 10.sp),
                        // Office Coordinates  &  Reason For Request
                        buildResponsiveFields(
                          left: officeCoordinatesField(),
                          right: reasonForRequestField(),
                          context: context,
                        ),
                        // space
                        SizedBox(height: 37.sp),

                        // Product Specification
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).attachments,
                                  style: StyleText.fontSize14Weight400.copyWith(
                                    color: AppColors.blackButton,
                                  ),
                                ),
                                SizedBox(height: 8.sp),
                                uploadAttachmentFile == null
                                    ? customButtonWithSvg(
                                        title: S.of(context).upload,
                                        function: () => pickFile(),
                                        textStyle: StyleText.fontSize14Weight500
                                            .copyWith(
                                          color: AppColors.textButton,
                                        ),
                                        width: isMobile
                                            ? MediaQuery.sizeOf(
                                                  context,
                                                ).width *
                                                .84
                                            : 170.sp,
                                        height: 35.sp,
                                        space: 16.sp,
                                        radius: 4.r,
                                        color: AppColors.primary,
                                        svgColor: AppColors.textButton,
                                        image:
                                            "assets/icons_assets/main_icons_assets/ic_upload.svg",
                                        widthImage: 16.sp,
                                        heightImage: 16.sp,
                                        colorBorder: Colors.transparent,
                                      )
                                    : buildFilePreview(
                                        uploadAttachmentFile!,
                                        DateTime.now(),
                                        () {
                                          setState(() {
                                            uploadAttachmentFile = null;
                                          });
                                        },
                                      ),
                              ],
                            ),
                          ],
                        ),
                        // space
                        SizedBox(height: 25.sp),

                        // Approval Cycle
                        Row(
                          children: [
                            Text(
                              "${S.of(context).approvalCycle}: ",
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),

                        // space
                        SizedBox(height: 13.sp),

                        // Approval Cycle item
                        isMobile
                            ? _buildApprovalCycle(section)
                            : buildApprovalCycleRow(section),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.sp),

                // Discard & submitForApproval
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
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.grey,
                    ),

                    // submitForApproval
                    customButton(
                      title: S.of(context).submitForApproval,
                      function: _showConfirmDialog,
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: 160.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.primary,
                    ),
                  ],
                ),

                SizedBox(height: 10.sp),
              ],
            ),
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
  /////////////////////////// Custom Filed /////////////////////////////

  Widget requestIdField() => CustomValidatedTextFieldMaster(
        label: S.of(context).requestID,
        hint: S.of(context).requestID,
        enabled: false,
        controller: requestIdController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget assetIdField() => CustomValidatedTextFieldMaster(
        label: S.of(context).assetId,
        hint: S.of(context).assetId,
        enabled: false,
        controller: assetsNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget categoryField() => CustomValidatedTextFieldMaster(
        label: S.of(context).category,
        hint: S.of(context).category,
        enabled: false,
        controller: categoryController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget subcategoryField() => CustomValidatedTextFieldMaster(
        label: S.of(context).subcategory,
        hint: S.of(context).subcategory,
        enabled: false,
        controller: subCategoryController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget brandField() => CustomValidatedTextFieldMaster(
        label: S.of(context).brand,
        hint: S.of(context).brand,
        enabled: false,
        controller: brandController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget modelField() => CustomValidatedTextFieldMaster(
        label: S.of(context).model,
        hint: S.of(context).model,
        enabled: false,
        controller: modelController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget maintenanceFrequencyField() => CustomValidatedTextFieldMaster(
        label: S.of(context).maintenanceFrequency,
        hint: S.of(context).maintenanceFrequency,
        enabled: false,
        controller: maintenanceFrequencyController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget typeOfAssetDropdown(List<Map<String, String>> selectedPriorityList) =>
      CustomDropdown<String>(
        items: (selectedPriorityList)
            .map((e) => DropdownItem<String>(
                value: e['key'] ?? '', label: e['value'] ?? ''))
            .toList(),
        value: selectedTypeOfAssets,
        onChanged: (value) {
          setState(() {
            selectedTypeOfAssets = value;
          });
        },
        label: S.of(context).typeOfAssetRequest,
        hint: S.of(context).priority,
        height: 36.sp,
      );

  Widget quantityField() => CustomValidatedTextFieldMaster(
        label: S.of(context).quantity,
        hint: S.of(context).quantity,
        enabled: false,
        controller: quantityController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget priorityDropdown(List<Map<String, String>> selectedPriorityList) =>
      CustomDropdown<String>(
        items: (selectedPriorityList)
            .map((e) => DropdownItem<String>(
                value: e['key'] ?? '', label: e['value'] ?? ''))
            .toList(),
        value: selectedPriority,
        onChanged: (value) {
          setState(() {
            selectedPriority = value;
          });
        },
        label: S.of(context).priority,
        hint: S.of(context).priority,
        height: 36.sp,
      );

  Widget receivingMethodDropdown(
    List<Map<String, String>> selectedPriorityList,
  ) =>
      CustomDropdown<String>(
        items: (selectedPriorityList)
            .map((e) => DropdownItem<String>(
                value: e['key'] ?? '', label: e['value'] ?? ''))
            .toList(),
        value: selectedReceivingMethod,
        onChanged: (value) {
          setState(() {
            selectedReceivingMethod = value;
          });
        },
        label: S.of(context).receivingMethod,
        hint: S.of(context).priority,
        height: 36.sp,
      );

  Widget locationDeliveryDropdown(
    List<Map<String, String>> selectedPriorityList,
  ) =>
      CustomDropdown<String>(
        items: (selectedPriorityList)
            .map((e) => DropdownItem<String>(
                value: e['key'] ?? '', label: e['value'] ?? ''))
            .toList(),
        value: selectedLocationDelivery,
        onChanged: (value) {
          setState(() {
            selectedLocationDelivery = value;
          });
        },
        label: S.of(context).locationDelivery,
        hint: S.of(context).priority,
        height: 36.sp,
      );

  Widget expectedDeliveryDateDropdown(List<Map<String, String>> durationUnits) {
    return CustomDateField(
      value: DateFormat('d/M/yyyy').tryParse((selectedDeliveryMethod) ?? ''),
      onChanged: (date) {
        if (date == null) return;
        ((value) {
          if (value != null) {
            setState(() {
              selectedDeliveryMethod = value;
            });
          }
        })(DateFormat('d/M/yyyy').format(date));
      },
      label: S.of(context).expectedDeliveryDate,
      hint: "24 Nov 2018",
      height: 36.sp,
    );
  }

  Widget expectedReturnDateDropdown(List<Map<String, String>> durationUnits) {
    return CustomDateField(
      value: DateFormat('d/M/yyyy').tryParse((selectedDeliveryMethod) ?? ''),
      onChanged: (date) {
        if (date == null) return;
        ((value) {
          if (value != null) {
            setState(() {
              selectedDeliveryMethod = value;
            });
          }
        })(DateFormat('d/M/yyyy').format(date));
      },
      label: S.of(context).expectedReturnDate,
      hint: "24 Nov 2018",
      height: 36.sp,
    );
  }

  Widget officeCoordinatesField() => CustomValidatedTextFieldMaster(
        label: S.of(context).officeCoordinates,
        hint: S.of(context).textHere,
        enabled: false,
        height: 73.sp,
        controller: officeCoordinatesController,
        maxLines: 3,
        showCharCount: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget reasonForRequestField() => CustomValidatedTextFieldMaster(
        label: S.of(context).reasonForRequest,
        hint: S.of(context).textHere,
        enabled: false,
        height: 73.sp,
        controller: reasonForRequestController,
        maxLines: 3,
        showCharCount: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  /////////////////////////// Custom Filed /////////////////////////////

  /////////////////////////////// Approval Cycle  Mobile //////////////////////////////
  Widget _buildApprovalCycle(ApprovalSection section) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(section.selectedApprovers.length, (index) {
        final employee = section.selectedApprovers[index];

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20.sp,
                      right: 15.sp,
                      bottom: 0.sp,
                    ),
                    child: CustomPaint(
                      size: Size(0, 80),
                      painter: CurvedArrowPainter(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.blackButton
                            : AppColors.whiteShadow,
                        isArabic: isArabic,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: 2.sp,
                  ), // Reserve equal width to align with arrow size
                Padding(
                  padding: EdgeInsets.only(top: 14.sp),
                  child: Container(
                    width: 32.sp,
                    height: 32.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.transparent, width: 2.w),
                    ),
                    child: ClipOval(
                      child: CustomSvgImage.natural(
                        assetPath: employee.gender == "male"
                            ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                            : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
                        fit: BoxFit.scaleDown,
                        width: 28.sp,
                        height: 28.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),
                Padding(
                  padding: EdgeInsets.only(top: 12.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FormatHelper.capitalize(
                          isArabic
                              ? "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}"
                              : "${employee.firstName ?? ''} ${employee.lastName ?? ''}",
                        ),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackButton,
                        ),
                      ),
                      Text(
                        FormatHelper.capitalize(
                          isArabic
                              ? employee.titleInArabic ?? ''
                              : employee.title ?? '',
                        ),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        );
      }),
    );
  }

  //////////////////////////////// Approval Cycle  Mobile //////////////////////////////

  ////////////////////////////// preview image //////////////////////////////
  Widget buildFilePreview(
    PlatformFile file,
    DateTime uploadDate,
    VoidCallback onRemove,
  ) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    String size = formatBytes(file.size);
    String formattedDate = "${uploadDate.day.toString().padLeft(2, '0')}/"
        "${uploadDate.month.toString().padLeft(2, '0')}/"
        "${uploadDate.year}";

    return Container(
      width: 283.sp,
      height: 60.sp,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.secondaryText,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // image
          Padding(
            padding: EdgeInsets.all(6.sp),
            child: kIsWeb
                ? Image.memory(
                    file.bytes!,
                    width: 36.sp,
                    height: 36.sp,
                    fit: BoxFit.cover,
                  )
                : (file.path != null
                    ? Image.file(
                        File(file.path!),
                        width: 36.sp,
                        height: 36.sp,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox()),
          ),

          // space
          SizedBox(width: 10.sp),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // file name
                Text(
                  FormatHelper.capitalize(file.name),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // space
                SizedBox(height: 5.sp),
                Text(
                  size,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // Remove button & Date
          Padding(
            padding: EdgeInsets.all(10.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTapDown: hapticDown(onRemove, HapticLevel.high),
                  onTap: onRemove,
                  child: CustomSvgImage.natural(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_editor_decrease.svg",
                    width: 12.sp,
                    height: 12.sp,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                Spacer(),
                Text(
                  "Date: $formattedDate",
                  style: StyleText.fontSize10Weight400.copyWith(
                    color:
                        lightMode ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  ////////////////////////////// preview image //////////////////////////////

  //////////////////////////////// Approval Cycle //////////////////////////////
  Widget buildApprovalCycleRow(ApprovalSection section) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final theme = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: Wrap(
        runAlignment: WrapAlignment.start,
        alignment: WrapAlignment.start,
        spacing: 5.sp,
        runSpacing: 0.sp,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(section.selectedApprovers.length * 2 - 1, (i) {
          if (i.isEven) {
            final index = i ~/ 2;
            final employee = section.selectedApprovers[index];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: CustomSvgImage.natural(
                      assetPath: employee.gender == "male"
                          ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                          : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
                      semanticsLabel: 'Gender Icon',
                      fit: BoxFit.cover,
                      width: 40.sp,
                      height: 40.sp,
                    ),
                  ),
                ),
                SizedBox(width: 6.sp),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.capitalize(
                        isEnglish
                            ? "${employee.firstName} ${employee.lastName}"
                            : "${employee.firstNameInArabic} ${employee.lastNameInArabic}",
                      ),
                      style: StyleText.fontSize10Weight500.copyWith(
                        color: theme ? AppColors.blackButton : AppColors.white,
                      ),
                    ),
                    Text(
                      FormatHelper.capitalize(
                        isEnglish
                            ? employee.title ?? ''
                            : employee.titleInArabic ?? '',
                      ),
                      style: StyleText.fontSize10Weight500.copyWith(
                        color: theme ? AppColors.secondaryText : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Transform.rotate(
              angle: isEnglish ? 0 : 3.1416,
              child: CustomSvgImage.natural(
                assetPath:
                    "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                width: 25.sp,
                color: theme ? AppColors.text : AppColors.whiteShadow,
              ),
            );
          }
        }),
      ),
    );
  }

  //////////////////////////////// Approval Cycle //////////////////////////////

  ////////////////////////////// Dialog Verify  //////////////////////////////

  void _showConfirmDialog() {
    showAppDialog(
      context: context,
      barrierDismissible: true,
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
                S.of(context).requestingAsset,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                S.of(context).areYouSureToRequestAsset,
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
                  S.of(context).assetRequested,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).successfullyRequestedAsset,
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

class ApprovalSection {
  final GlobalKey iconKey = GlobalKey();
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;
  String? selectedRequestType;
  TextEditingController searchController = TextEditingController();
  GlobalKey tooltipIconKey = GlobalKey();

  List<EmployeeEntity> selectedApprovers;

  ApprovalSection({
    this.selectedRequestType,
    this.selectedApprovers = const [],
  });
}
