import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class NewPatchScreen extends StatefulWidget {
  const NewPatchScreen({super.key});

  @override
  State<NewPatchScreen> createState() => _NewPatchScreenState();
}

class _NewPatchScreenState extends State<NewPatchScreen> {
  /////////////////////////// Variable //////////////////////////////////////

  String selectedDurationUnit = "hours";

  /////////////////////////// Controller ////////////////////////////////////

  TextEditingController orderIDController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController unitCostController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController batchIdController = TextEditingController();
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController expectedLifetimeController = TextEditingController();

  /////////////////////////// Controller ////////////////////////////////////

  /////////////////////////////////////// storage location //////////////////////
  // Default storage location (shown alone first)
  String? defaultStorageLocation;
  final List<Map<String, String>> storageLocations = [
    {"key": "roomA", "value": "Room A"},
    {"key": "roomB", "value": "Room B"},
    {"key": "roomC", "value": "Room C"},
  ];
  /////////////////////////////////////// storage location //////////////////////

  ////////////////////////////////////// Pick File //////////////////////////////

  PlatformFile? invoiceNewFile;
  PlatformFile? warrantyFile;

  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (type == 'invoice') {
          invoiceNewFile = result.files.first;
        } else if (type == 'warranty') {
          warrantyFile = result.files.first;
        }
      });
    }
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    return '${(bytes / 1024).ceil()} KB';
  }

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

  ////////////////////////////////////// Pick File //////////////////////////////
  bool requireApproval = false;

  TextEditingController defaultStorageQuantityController =
      TextEditingController();
  final List<Map<String, dynamic>> additionalStorageEntries = [];

  @override
  Widget build(BuildContext context) {
    [
      {"key": "week", "value": S.of(context).week},
      {"key": "hours", "value": S.of(context).hours},
      {"key": "minutes", "value": S.of(context).minutes},
      {"key": "seconds", "value": S.of(context).seconds},
    ];
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).addingNewProduct,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ Let height be dynamic
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.card,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: Column(
                      children: [
                        CustomValidatedTextFieldMaster(
                          label: S.of(context).orderID,
                          hint: S.of(context).orderID,
                          height: 36.sp,
                          controller: orderIDController,
                          onlyDigits: false,
                          textDirection: ui.TextDirection.ltr,
                          onChanged: (_) => setState(() {}),
                        ),

                        SizedBox(height: 15.sp),

                        CustomValidatedTextFieldMaster(
                          label: S.of(context).batchId,
                          hint: S.of(context).batchId,
                          height: 36.sp,
                          controller: batchIdController,
                          textDirection: ui.TextDirection.ltr,
                          onlyDigits: false,
                          onChanged: (_) => setState(() {}),
                        ),

                        //space
                        SizedBox(height: 15.sp),

                        CustomValidatedTextFieldMaster(
                          label: S.of(context).quantity,
                          hint: S.of(context).quantity,
                          controller: quantityController,
                          height: 36.sp,
                          onlyDigits: false,
                          textDirection: ui.TextDirection.ltr,
                          onChanged: (_) => setState(() {}),
                        ),

                        SizedBox(height: 15.sp),

                        CustomValidatedTextFieldMaster(
                          label: S.of(context).unitCost,
                          hint: S.of(context).unitCost,
                          controller: unitCostController,
                          height: 36.sp,
                          textDirection: ui.TextDirection.ltr,
                          onlyDigits: false,
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 15.sp),

                        CustomValidatedTextFieldMaster(
                          label: S.of(context).currency,
                          hint: S.of(context).currency,
                          height: 36.sp,
                          controller: currencyController,
                          onlyDigits: false,
                          textDirection: ui.TextDirection.ltr,
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 15.sp),

                        CustomValidatedTextFieldMaster(
                          label: S.of(context).supplier,
                          hint: S.of(context).supplier,
                          controller: supplierNameController,
                          textDirection: ui.TextDirection.ltr,
                          height: 36.sp,
                          onlyDigits: false,
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 15.sp),

                        Row(
                          children: [
                            Expanded(
                              child: CustomValidatedTextFieldMaster(
                                label: S.of(context).expectedLifetime,
                                height: 36.sp,
                                hint: S.of(context).enterThePeriod,
                                controller: expectedLifetimeController,
                                onlyDigits: false,
                                textDirection: ui.TextDirection.ltr,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            SizedBox(width: 10.sp),
                            SizedBox(
                              width: 100.sp,
                              child: CustomDropdown<String>(
                                items: (storageLocations)
                                    .map((e) => DropdownItem<String>(
                                        value: e['key'] ?? '',
                                        label: e['value'] ?? ''))
                                    .toList(),
                                value: defaultStorageLocation,
                                onChanged: (val) {
                                  setState(() {
                                    defaultStorageLocation = val;
                                  });
                                },
                                label: "",
                                hint: "",
                                height: 36.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.sp),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // storage Location
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width,
                              child: CustomDropdown<String>(
                                items: (storageLocations)
                                    .map((e) => DropdownItem<String>(
                                        value: e['key'] ?? '',
                                        label: e['value'] ?? ''))
                                    .toList(),
                                value: defaultStorageLocation,
                                onChanged: (val) {
                                  setState(() {
                                    defaultStorageLocation = val;
                                  });
                                },
                                label: S.of(context).storageLocation,
                                hint: S.of(context).selectStorageLocation,
                                height: 36.sp,
                              ),
                            ),
                            additionalStorageEntries.length == 1
                                ? SizedBox(height: 8.sp)
                                : SizedBox(),
                            // 👇 This part should only show if user added another storage row
                            if (additionalStorageEntries.isNotEmpty) ...[
                              CustomValidatedTextFieldMaster(
                                label: S.of(context).quantity,
                                hint: S.of(context).textHere,
                                height: 36.sp,
                                controller: defaultStorageQuantityController,
                                textDirection: ui.TextDirection.ltr,
                                onChanged: (_) => setState(() {}),
                                onlyDigits: true,
                              ),
                            ],
                          ],
                        ),
                        additionalStorageEntries.length == 1
                            ? SizedBox(height: 8.sp)
                            : SizedBox(),
                        // Additional Rows with Dropdown + Quantity
                        ...additionalStorageEntries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 0.sp),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        S.of(context).storageLocation,
                                        style: StyleText.fontSize14Weight400
                                            .copyWith(
                                          color: AppColors.blackButton,
                                        ),
                                      ),
                                      SizedBox(height: 8.sp),
                                      CustomDropdown<String>(
                                        items: (storageLocations)
                                            .map((e) => DropdownItem<String>(
                                                value: e['key'] ?? '',
                                                label: e['value'] ?? ''))
                                            .toList(),
                                        value: null,
                                        onChanged: (val) {
                                          setState(() {
                                            entry['selectedValue'] = val;
                                          });
                                        },
                                        hint:
                                            S.of(context).selectStorageLocation,
                                        height: 36.sp,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 8.sp),

                                // Quantity
                                CustomValidatedTextFieldMaster(
                                  label: S.of(context).quantity,
                                  hint: S.of(context).textHere,
                                  height: 36.sp,
                                  controller: entry['quantityController'],
                                  textDirection: ui.TextDirection.ltr,
                                  onChanged: (_) => setState(() {}),
                                  onlyDigits: true,
                                ),
                              ],
                            ),
                          );
                        }),
                        SizedBox(height: 8.sp),
                        // + Storage Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            customButtonWithSvg(
                              title: S.of(context).storage,
                              function: () {
                                setState(() {
                                  additionalStorageEntries.add({
                                    'selectedValue': null,
                                    'quantityController':
                                        TextEditingController(),
                                  });
                                });
                              },
                              textStyle: StyleText.fontSize14Weight500.copyWith(
                                color:
                                    AppTheme.readableOn(AppColors.blackButton),
                              ),
                              width: 100.sp,
                              height: 30.sp,
                              space: 8.sp,
                              radius: 4.r,
                              color: AppColors.blackButton,
                              svgColor:
                                  AppTheme.readableOn(AppColors.blackButton),
                              image:
                                  "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                              widthImage: 12.sp,
                              heightImage: 12.sp,
                              colorBorder: Colors.transparent,
                            ),
                          ],
                        ),

                        SizedBox(height: 22.sp),

                        // Invoice
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).invoice,
                              style: StyleText.fontSize14Weight400.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                            SizedBox(height: 8.sp),
                            invoiceNewFile == null
                                ? customButtonWithSvg(
                                    title: S.of(context).upload,
                                    function: () => pickFile('invoice'),
                                    textStyle:
                                        StyleText.fontSize14Weight500.copyWith(
                                      color: AppColors.textButton,
                                    ),
                                    width: MediaQuery.sizeOf(context).width,
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
                                    invoiceNewFile!,
                                    DateTime.now(),
                                    () {
                                      setState(() {
                                        invoiceNewFile = null;
                                      });
                                    },
                                  ),
                          ],
                        ),

                        SizedBox(height: 22.sp),

                        // Warranty
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).warranty,
                              style: StyleText.fontSize14Weight400.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                            SizedBox(height: 8.sp),
                            warrantyFile == null // ✅ CORRECT THIS LINE
                                ? customButtonWithSvg(
                                    title: S.of(context).upload,
                                    function: () => pickFile('warranty'),
                                    textStyle:
                                        StyleText.fontSize14Weight500.copyWith(
                                      color: AppColors.textButton,
                                    ),
                                    width: MediaQuery.sizeOf(context).width,
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
                                    warrantyFile!,
                                    DateTime.now(),
                                    () {
                                      setState(() {
                                        warrantyFile = null;
                                      });
                                    },
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.sp),
                // Discard & Submit
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
                      width: 135.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.grey,
                    ),

                    // ✅ submit
                    customButton(
                      title: S.of(context).submit,
                      function: () async {
                        final confirmed =
                            await _showConfirmDialog(); // show confirm dialog
                        if (confirmed) {
                          if (!context.mounted) return;
                          await _showSuccessDialog(
                            context,
                          ); // show success dialog if Yes
                          if (!context.mounted) return;
                          Navigator.pop(
                            context,
                          ); // then close the original Restock dialog
                        }
                      },
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textButton,
                      ),
                      width: 135.sp,
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
  ////////////////////////////// Dialog Verify  //////////////////////////////

  Future<bool> _showConfirmDialog() async {
    final result = await showAppDialog<bool>(
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
              ),
              SizedBox(height: 20.sp),
              Text(
                S.of(context).addAsset,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                S.of(context).confirmAddAsset,
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
                      onTap: () => Navigator.pop(context, false), // ⬅ No
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
                      onTap: () => Navigator.pop(context, true), // ⬅ Yes
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

    return result ?? false; // return true if yes, false if no
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
                  S.of(context).addAsset,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).successAddAsset,
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
