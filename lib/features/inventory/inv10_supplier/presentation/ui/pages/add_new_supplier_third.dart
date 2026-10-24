import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/storage_location_form_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/widgets/add_new_supplier_third/draft.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class AddNewSupplierThird extends StatefulWidget {
  const AddNewSupplierThird({super.key});

  @override
  State<AddNewSupplierThird> createState() => _AddNewSupplierThirdState();
}

class _AddNewSupplierThirdState extends State<AddNewSupplierThird> {
  List<WarehouseFormData> warehouses = [
    WarehouseFormData(),
  ]; // Start with one warehouse
  bool warehouseDetails = true;
  bool warehouseSwitch = false;
  bool showContractDetails = true;

  String? selectStartDate;
  String? selectEndDate;

  Map<String, String?> validationErrors = {};
  bool isFormValid = false;

  final ImagePicker _picker = ImagePicker();

  // You have these separate variables:
  File? contractDocument1; // عقد - الصف الأول
  File? taxCertificate1; // شهادة ضريبية - الصف الأول
  File? contractDocument2; // عقد - الصف الثاني
  File? attachmentFile; // المرفقات
  List<File> attachmentFiles = []; // Multiple attachments

  // Plus these unused ones:
  File? contractDocument;
  File? taxCertificate;
  File? attachmentImage;

  // حقول (قديمة من كودك)
  TextEditingController countryController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController streetNameController = TextEditingController();
  TextEditingController stateOrProvinceController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  ///////////////////////// Warehouse Management ////////////////////////////////

  @override
  void initState() {
    super.initState();
  }

  void _addNewWarehouse() {
    setState(() {
      warehouses.add(WarehouseFormData());
    });
  }

  void _removeWarehouse(int index) {
    if (warehouses.length > 1) {
      setState(() {
        warehouses[index].dispose();
        warehouses.removeAt(index);
      });
    }
  }
  ///////////////////////// Warehouse Management ////////////////////////////////

  // دالة عامة لاختيار صورة وتخزينها في المتغير المناسب
  Future<void> _pickImage(void Function(File file) setter) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      setState(() {
        setter(file);
      });
    }
  }

  String _getCurrentUserEmail() {
    try {
      final controller = Get.find<MainCoreEmployeeController>();
      final employeeEntity = controller.employeeEntity;

      if (employeeEntity?.email != null && employeeEntity!.email!.isNotEmpty) {
        debugPrint('✅ Found user email: ${employeeEntity.email}');
        return employeeEntity.email!;
      } else {
        debugPrint('⚠️ Employee entity exists but email is null or empty');
        return '';
      }
    } catch (e) {
      debugPrint('❌ Error getting employee email: $e');
      debugPrint(
        '❌ This usually means MainCoreEmployeeController is not initialized',
      );
      return '';
    }
  }

  Future<void> _submitSupplier() async {
    try {
      _showLoadingDialog();

      // 1. First, validate that we have a user email
      final currentUserEmail = _getCurrentUserEmail();
      if (currentUserEmail.isEmpty) {
        _hideLoadingDialog();
        _showErrorDialog(
          'User email not available. Please ensure you are logged in properly.',
        );
        return;
      }

      debugPrint('📧 Using email: $currentUserEmail');

      // 2. Collect warehouses data from the form (only if switch is on)
      List<WarehouseDraft> warehousesData = [];

      if (warehouseSwitch) {
        warehousesData = _collectWarehouses();
      } else {
        debugPrint('Warehouse switch is OFF - sending empty warehouse list');
        warehousesData = [];
      }

      debugPrint('--- PAGE 3 DATA ---');
      debugPrint('Current User Email: $currentUserEmail');
      debugPrint('Warehouse Switch: $warehouseSwitch');
      debugPrint('Warehouses count: ${warehousesData.length}');
      debugPrint(
        'Contract Document 1: ${contractDocument1 != null ? "Selected" : "Not selected"}',
      );
      debugPrint(
        'Contract Document 2: ${contractDocument2 != null ? "Selected" : "Not selected"}',
      );
      debugPrint(
        'Tax Certificate: ${taxCertificate1 != null ? "Selected" : "Not selected"}',
      );
      debugPrint('Attachments count: ${attachmentFiles.length}');

      // 3. Save page 3 data with ALL files
      SupplierDraftStore.instance.setFromPage3(
        warehouses: warehousesData,
        contractStartDate: selectStartDate ?? '',
        contractEndDate: selectEndDate ?? '',
        taxCertificateFile: taxCertificate1,
        contractDocument1File: contractDocument1,
        contractDocument2File: contractDocument2,
        attachmentFiles: attachmentFiles,
        warehouseEnabled: warehouseSwitch,
      );

      debugPrint('📤 Starting upload to Firebase...');

      // 4. Upload to Firebase (the method now gets email internally)
      await SupplierDraftStore.instance.uploadAllToFirebase();

      debugPrint('✅ Upload completed successfully');

      // 5. Clear the draft store
      SupplierDraftStore.instance.clear();

      _hideLoadingDialog();
    } catch (e) {
      debugPrint('❌ Error submitting supplier: $e');
      _hideLoadingDialog();
      _showErrorDialog('Failed to upload supplier: ${e.toString()}');
      rethrow;
    }
  }

  // Helper method to parse date string
  DateTime? _parseDate(String dateString) {
    try {
      List<String> parts = dateString.split('-');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // 3. Update your Submit button function
  void _handleSubmitButton() async {
    if (_validateRequiredFields()) {
      await _showConfirmDialog();
    }
    // No need for validation error dialog anymore - errors will show under fields
  }

  Future<void> _pickAttachmentImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      setState(() {
        attachmentFiles.add(file);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      attachmentFiles.removeAt(index);
    });
  }

  // 3. Update your validation method to handle multiple attachments
  String? _getFieldError(String fieldKey) {
    return validationErrors[fieldKey];
  }

  // 2. Update _validateRequiredFields method to trigger setState for UI updates
  bool _validateRequiredFields() {
    validationErrors.clear();

    // Validate contract dates (always required)
    if (selectStartDate == null || selectStartDate!.isEmpty) {
      validationErrors['contractStartDate'] =
          S.of(context).contractStartDateRequired;
    }
    if (selectEndDate == null || selectEndDate!.isEmpty) {
      validationErrors['contractEndDate'] =
          S.of(context).contractEndDateRequired;
    }

    // Validate date logic (end date should be after start date)
    if (selectStartDate != null &&
        selectEndDate != null &&
        selectStartDate!.isNotEmpty &&
        selectEndDate!.isNotEmpty) {
      DateTime? startDate = _parseDate(selectStartDate!);
      DateTime? endDate = _parseDate(selectEndDate!);

      if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
        validationErrors['contractEndDate'] =
            S.of(context).endDateMustBeAfterStartDate;
      }
    }

    // Only validate warehouse fields if warehouse switch is ON
    if (warehouseSwitch) {
      for (int i = 0; i < warehouses.length; i++) {
        WarehouseFormData warehouse = warehouses[i];
        String warehousePrefix = i == 0 ? '' : 'warehouse${i + 1}_';

        if (warehouse.countryController.text.trim().isEmpty) {
          if (i == 0) {
            validationErrors['${warehousePrefix}country'] =
                S.of(context).countryRequired;
          } else {
            validationErrors['${warehousePrefix}country'] =
                S.of(context).warehouseNumberCountry;
          }
        }

        if (warehouse.cityController.text.trim().isEmpty) {
          if (i == 0) {
            validationErrors['${warehousePrefix}city'] =
                S.of(context).cityRequired;
          } else {
            validationErrors['${warehousePrefix}city'] =
                S.of(context).warehouseNumberCity;
          }
        }

        if (warehouse.streetNameController.text.trim().isEmpty) {
          if (i == 0) {
            validationErrors['${warehousePrefix}streetName'] =
                S.of(context).streetNameRequired;
          } else {
            validationErrors['${warehousePrefix}streetName'] =
                S.of(context).warehouseNumberStreetName;
          }
        }

        if (warehouse.stateOrProvinceController.text.trim().isEmpty) {
          validationErrors['${warehousePrefix}stateOrProvince'] = i == 0
              ? S.of(context).stateRequired
              : (S
                  .of(context)
                  .stateOrProvince); // fallback if you don’t have a numbered string
        }

        if (warehouse.postalCodeController.text.trim().isEmpty) {
          if (i == 0) {
            validationErrors['${warehousePrefix}postalCode'] =
                S.of(context).postalCodeRequired;
          } else {
            validationErrors['${warehousePrefix}postalCode'] =
                S.of(context).warehouseNumberPostalCode;
          }
        }
      }
    }

    // Trigger UI rebuild to show validation errors
    setState(() {});

    return validationErrors.isEmpty;
  }

  /// Empties step 3 (warehouses, contract dates and every picked file).
  void _clearForm() {
    for (final w in warehouses) {
      for (final c in [
        w.countryController,
        w.stateOrProvinceController,
        w.cityController,
        w.postalCodeController,
        w.streetNameController,
      ]) {
        c.clear();
      }
    }
    setState(() {
      selectStartDate = null;
      selectEndDate = null;
      contractDocument1 = null;
      taxCertificate1 = null;
      contractDocument2 = null;
      attachmentFile = null;
      attachmentFiles = [];
      validationErrors.clear();
    });
  }

  /// Realistic test values (debug builds only — see FormToolsBar).
  /// Files are not faked: pick real documents to test uploads.
  void _fillSampleData() {
    final now = DateTime.now();
    final end = DateTime(now.year + 1, now.month, now.day);
    final w = warehouses.first;
    w.countryController.text = 'Egypt';
    w.stateOrProvinceController.text = 'Giza';
    w.cityController.text = '6th of October';
    w.postalCodeController.text = '12573';
    w.streetNameController.text =
        'Industrial Zone 3, Plot 45, 6th of October City';
    setState(() {
      selectStartDate = '${now.day}-${now.month}-${now.year}';
      selectEndDate = '${end.day}-${end.month}-${end.year}';
      validationErrors.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventory,
          onFirstTap: () {
            navigateTo(context, InventoryManagement());
          },
          secondTitle: S.of(context).addingNewSupplier,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                // Clear All / Fill sample data (sample only in debug builds).
                FormToolsBar(onClear: _clearForm, onFill: _fillSampleData),
                SizedBox(height: 10.sp),

                // Warehouse Details Header
                Row(
                  children: [
                    Text(
                      S.of(context).warehousesDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    const Spacer(),
                    Transform(
                      alignment: Alignment.center,
                      transform: isArabic
                          ? Matrix4.rotationY(3.14159)
                          : Matrix4.identity(),
                      child: FlutterSwitch(
                        activeColor: AppColors.secondaryPrimary,
                        height: 22.sp,
                        width: 38.sp,
                        padding: 3.sp,
                        borderRadius: 20.sp,
                        toggleSize: 16.sp,
                        toggleColor: Colors.white,
                        inactiveColor: const Color(
                          0xFF787880,
                        ).withValues(alpha: 0.16),
                        value: warehouseSwitch,
                        onToggle: (val) {
                          return setState(() {
                            warehouseSwitch = val;

                            // Clear warehouse validation errors when switch is turned off
                            if (!val) {
                              validationErrors.removeWhere(
                                (key, value) =>
                                    key.contains('country') ||
                                    key.contains('city') ||
                                    key.contains('streetName') ||
                                    key.contains('postalCode') ||
                                    key.contains('warehouse'),
                              );
                            }
                          });
                        },
                      ),
                    ),
                    // SizedBox(width: 8.sp),
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       warehouseDetails = !warehouseDetails;
                    //     });
                    //   },
                    //   child: Text(
                    //     warehouseDetails
                    //         ? S.of(context).hide
                    //         : S.of(context).expand,
                    //     style: StyleText.fontSize14Weight500
                    //         .copyWith(color: const Color(0xff1877F2)),
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 8.sp),

                // First Warehouse (Main Warehouse)
                // Warehouses section
                if (warehouseDetails && warehouseSwitch) ...[
                  Column(
                    children: List.generate(
                      warehouses.length,
                      (i) => _warehouseCard(warehouses[i], i),
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Row(
                    children: [
                      customButtonWithSvg(
                        width: 120.w,
                        height: 30.h,
                        title: S.of(context).warehouses,
                        function: _addNewWarehouse,
                        svgColor: AppTheme.readableOn(AppColors.blackButton),
                        color: AppColors.blackButton,
                        radius: 4.r,
                        textStyle: StyleText.fontSize14Weight500.copyWith(
                          color: AppTheme.readableOn(AppColors.blackButton),
                        ),
                        image:
                            'assets/icons_assets/main_icons_assets/ic_action_plus.svg',
                        widthImage: 12.w,
                        heightImage: 12.h,
                        colorBorder: Colors.transparent,
                        space: 8.w,
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 20.sp),

                // Contract Details Header
                Row(
                  children: [
                    Text(
                      S.of(context).contractDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    // const Spacer(),
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       showContractDetails = !showContractDetails;
                    //     });
                    //   },
                    //   child: Text(
                    //     showContractDetails
                    //         ? S.of(context).hide
                    //         : S.of(context).expand,
                    //     style: StyleText.fontSize14Weight500
                    //         .copyWith(color: const Color(0xff1877F2)),
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 8.sp),

                // Contract Details Body
                if (showContractDetails)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      // Card colour in both themes (was white in dark mode).
                      color: AppColors.card,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contract dates row
                          buildResponsiveFields(
                            left: contractStartDateDropdown(),
                            right: contractEndDateDropdown(),
                            leftFieldKey: 'contractStartDate',
                            rightFieldKey: 'contractEndDate',
                            context: context,
                          ),

                          SizedBox(height: 15.sp),

                          // ALL UPLOADS IN GRID - Contract Documents, Tax Certificate, Attachments
                          buildAllUploadsGrid(),
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
                    customButton(
                      title: S.of(context).submit,
                      function:
                          _handleSubmitButton, // Use the new validation function
                      textStyle: StyleText.fontSize16Weight400.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: _validateRequiredFields()
                          ? AppColors.primary
                          : Colors.grey[500],
                    ),
                  ],
                ),

                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _warehouseCard(WarehouseFormData warehouse, int index) {
    final prefix = index == 0 ? '' : 'warehouse${index + 1}_';

    return Column(
      children: [
        if (index > 0) SizedBox(height: 20.sp),
        if (index > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${index + 1}${index == 0 ? 'st' : index == 1 ? 'nd' : index == 2 ? 'rd' : 'th'} ${S.of(context).warehouses} Details",
                style: StyleText.fontSize16Weight600.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTapDown: (_) => HapticController.high(),
                onTap: () => _removeWarehouse(index),
                child: Container(
                  width: 15.w,
                  height: 15.h,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
            ],
          ),
        if (index > 0) SizedBox(height: 8.sp),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(15.sp),
            child: Column(
              children: [
                buildResponsiveFields(
                  left: countryField(warehouse),
                  right: stateOrProvinceField(warehouse),
                  leftFieldKey: '${prefix}country',
                  rightFieldKey: '${prefix}stateOrProvince',
                  context: context,
                ),
                SizedBox(height: 15.sp),
                buildResponsiveFields(
                  left: cityField(warehouse),
                  right: postalCodeField(warehouse),
                  leftFieldKey: '${prefix}city',
                  rightFieldKey: '${prefix}postalCode',
                  context: context,
                ),
                SizedBox(height: 15.sp),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StorageTextField(
                            label: S.of(context).streetName,
                            controller: warehouse.streetNameController,
                            multiline: true,
                            textDirection: ui.TextDirection.ltr,
                            onlyDigits: false,
                            onChanged: (_) => setState(() {
                              validationErrors.remove('${prefix}streetName');
                            }),
                          ),
                          if ((_getFieldError('${prefix}streetName')) != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                (_getFieldError('${prefix}streetName'))!,
                                style: StyleText.fontSize12Weight400
                                    .copyWith(color: AppColors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAllUploadsGrid() {
    var isMobile = context.isPhone;

    // Create list of all upload items
    List<Widget> uploadItems = [];

    // Contract Document 1 - with remove functionality
    uploadItems.add(
      buildUploadGridItem(
        title: "${S.of(context).contractDocument} 1",
        file: contractDocument1,
        onUpload: () => _pickImage((f) => contractDocument1 = f),
        onRemove: contractDocument1 != null
            ? () {
                setState(() {
                  contractDocument1 = null;
                });
              }
            : null,
      ),
    );

    // Tax Certificate - with remove functionality
    uploadItems.add(
      buildUploadGridItem(
        title: S.of(context).taxCertificate,
        file: taxCertificate1,
        onUpload: () => _pickImage((f) => taxCertificate1 = f),
        onRemove: taxCertificate1 != null
            ? () {
                setState(() {
                  taxCertificate1 = null;
                });
              }
            : null,
      ),
    );

    // Contract Document 2 - with remove functionality
    uploadItems.add(
      buildUploadGridItem(
        title: "${S.of(context).contractDocument} 2",
        file: contractDocument2,
        onUpload: () => _pickImage((f) => contractDocument2 = f),
        onRemove: contractDocument2 != null
            ? () {
                setState(() {
                  contractDocument2 = null;
                });
              }
            : null,
      ),
    );

    // All attachment files - existing remove functionality
    for (int i = 0; i < attachmentFiles.length; i++) {
      uploadItems.add(
        buildUploadGridItem(
          title: "Attachment ${i + 1}",
          file: attachmentFiles[i],
          onUpload: () => _pickImage((f) => attachmentFiles[i] = f),
          isAttachment: true,
          attachmentIndex: i,
          onRemove: () => _removeAttachment(i),
        ),
      );
    }

    // Add new attachment upload button
    uploadItems.add(
      buildUploadGridItem(
        title: S.of(context).attachments,
        file: null,
        onUpload: _pickAttachmentImage,
        isNewAttachment: true,
      ),
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 15.sp,
        mainAxisSpacing: 10.sp,
        mainAxisExtent: 80.sp,
      ),
      itemCount: uploadItems.length,
      itemBuilder: (context, index) => uploadItems[index],
    );
  }

  // Universal upload grid item widget
  Widget buildUploadGridItem({
    required String title,
    required File? file,
    required VoidCallback onUpload,
    bool isAttachment = false,
    int? attachmentIndex,
    VoidCallback? onRemove,
    bool isNewAttachment = false,
  }) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: StyleText.fontSize12Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),

        SizedBox(height: 8.sp),

        // Container with border
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: file != null
                  ? Border.all(
                      color: lightMode
                          ? const Color(0xffB5B4B4)
                          : Colors.transparent,
                      width: 1,
                    )
                  : Border.all(
                      color: Colors.transparent,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
            ),
            child: file != null
                ? Padding(
                    padding: EdgeInsets.all(0.sp),
                    child: buildUploadedFileContent(
                      file,
                      onUpload,
                      onRemove: onRemove,
                    ),
                  )
                : buildEmptyUploadContent(onUpload, isNewAttachment),
          ),
        ),
      ],
    );
  }

  Widget buildUploadedFileContent(
    File file,
    VoidCallback onUpload, {
    VoidCallback? onRemove,
  }) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    String fileName = file.path.split(Platform.pathSeparator).last;
    String fileSize = "62 KB";
    final bytes = file.lengthSync();
    if (bytes < 1024) {
      fileSize = "$bytes B";
    } else if (bytes < 1024 * 1024) {
      fileSize = "${(bytes / 1024).toStringAsFixed(0)} KB";
    } else {
      fileSize = "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    }

    return GestureDetector(
      onTapDown: hapticDown(onUpload, HapticLevel.medium),
      onTap: onUpload,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(8.sp),
            child: Row(
              children: [
                // Image container with proper sizing
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: lightMode
                          ? Colors.grey.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Image.file(
                      file,
                      width: 40.w,
                      height: 40.h,
                      fit: BoxFit
                          .cover, // Changed from scaleDown to cover for better appearance
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // File info section with proper constraints
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // File name with proper overflow handling
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          right: onRemove != null ? 25.w : 0,
                        ), // Add padding if remove button exists
                        child: Text(
                          fileName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: StyleText.fontSize12Weight500.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // File size
                      Text(
                        fileSize,
                        style: StyleText.fontSize10Weight400.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Remove button positioned properly to avoid overlap
          if (onRemove != null)
            Positioned(
              top: 4.h,
              right: 4.w,
              child: GestureDetector(
                onTapDown: hapticDown(onRemove, HapticLevel.high),
                onTap: onRemove,
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(Icons.remove, size: 12.sp, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// True while the "Uploading Supplier" dialog is on screen.
  bool _loaderOpen = false;

  void _showLoadingDialog() {
    _loaderOpen = true;
    showAppDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              EdgeInsets.zero, // optional: removes default side padding
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 411.w,
              height: 180.h,
              child: Container(
                padding: EdgeInsets.all(15.sp),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // center nicely
                  children: [
                    CircleProgressMaster(),
                    SizedBox(height: 20.sp),
                    Text(
                      S.of(context).uploadingSupplier,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      S.of(context).pleaseWait,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Closes ONLY the loading dialog. The dialog lives on the ROOT navigator,
  /// so it must be popped there: the old `Navigator.pop(context)` popped this
  /// page off the nested Inventory navigator instead (the screen jumped back
  /// to step 2) and left the loader on top forever.
  void _hideLoadingDialog() {
    if (!_loaderOpen) return;
    _loaderOpen = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Updated buildEmptyUploadContent without title parameter
  Widget buildEmptyUploadContent(VoidCallback onUpload, bool isNewAttachment) {
    var isMobile = context.isPhone;
    return GestureDetector(
      onTapDown: hapticDown(onUpload, HapticLevel.medium),
      onTap: onUpload,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customButtonWithSvg(
            title: S.of(context).upload,
            function: onUpload,
            textStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.textButton,
            ),
            width: isMobile ? MediaQuery.sizeOf(context).width * .9 : 170.w,
            height: 35.sp,
            space: 16.sp,
            radius: 4.r,
            color: AppColors.primary,
            svgColor: AppColors.textButton,
            image: "assets/icons_assets/main_icons_assets/ic_upload.svg",
            widthImage: 16.sp,
            heightImage: 16.sp,
            colorBorder: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget buildAttachmentsSection() {
    var isMobile = context.isPhone;

    // Calculate how many items to show (uploaded files + 1 upload button)
    int totalItems = attachmentFiles.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).attachments,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 8.sp),

        // Grid view for attachments + upload button
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 10.sp,
            mainAxisSpacing: 10.sp,
            mainAxisExtent: 50.sp,
          ),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            if (index < attachmentFiles.length) {
              // Show uploaded file
              return buildAttachmentPreview(
                file: attachmentFiles[index],
                index: index,
                onRemove: () => _removeAttachment(index),
              );
            } else {
              // Show upload button as last item
              return buildUploadButton();
            }
          },
        ),
      ],
    );
  }

  Widget buildUploadButton() {
    return GestureDetector(
      onTapDown: hapticDown(_pickAttachmentImage, HapticLevel.medium),
      onTap: _pickAttachmentImage,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.primary,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 32.sp,
              color: AppColors.primary,
            ),
            SizedBox(height: 8.sp),
            Text(
              S.of(context).upload,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.primary,
              ),
            ),
            Text(
              "Click to add file",
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAttachmentPreview({
    required File file,
    required int index,
    required VoidCallback onRemove,
  }) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    String fileName = file.path.split(Platform.pathSeparator).last;
    String fileSize = "62 KB";
    final bytes = file.lengthSync();
    if (bytes < 1024) {
      fileSize = "$bytes B";
    } else if (bytes < 1024 * 1024) {
      fileSize = "${(bytes / 1024).toStringAsFixed(0)} KB";
    } else {
      fileSize = "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
    const String dateStr = "28 Dec 2023";

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: lightMode ? const Color(0xffB5B4B4) : AppColors.grey,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          children: [
            // Header row with title and remove button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Attachment ${index + 1}",
                  style: StyleText.fontSize12Weight600.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                // GestureDetector(
                //   onTap: onRemove,
                //   child: Container(
                //     width: 20.w,
                //     height: 20.h,
                //     decoration: BoxDecoration(
                //       color: Colors.red.withOpacity(0.1),
                //       borderRadius: BorderRadius.circular(10.r),
                //       border: Border.all(color: Colors.red, width: 1),
                //     ),
                //     child: Icon(
                //       Icons.close,
                //       size: 12.sp,
                //       color: Colors.red,
                //     ),
                //   ),
                // ),
              ],
            ),

            SizedBox(height: 8.sp),

            // File content row
            Row(
              children: [
                // Image thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Image.file(
                    file,
                    width: 36.sp,
                    height: 36.sp,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10.sp),

                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      SizedBox(height: 2.sp),
                      Text(
                        fileSize,
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.sp),

            // Date info at bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${S.of(context).date}: ",
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  dateStr,
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResponsiveFields({
    required BuildContext context,
    required Widget left,
    required Widget right,
    String? leftFieldKey,
    String? rightFieldKey,
  }) {
    final isMobile = kpIsPhoneLayout(context);

    // Check if any field in this row has an error
    bool hasRowError = false;
    if (leftFieldKey != null && validationErrors.containsKey(leftFieldKey)) {
      hasRowError = true;
    }
    if (rightFieldKey != null && validationErrors.containsKey(rightFieldKey)) {
      hasRowError = true;
    }

    // Wrap each field with consistent height container when there's a row error
    Widget wrappedLeft = hasRowError
        ? SizedBox(
            height: 76.h, // TextField height + error text height + spacing
            child: left,
          )
        : left;

    Widget wrappedRight = hasRowError && right is! SizedBox
        ? SizedBox(
            height: 76.h, // TextField height + error text height + spacing
            child: right,
          )
        : right;

    if (isMobile) {
      return Column(
        children: [wrappedLeft, SizedBox(height: 10.sp), wrappedRight],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: wrappedLeft),
          SizedBox(width: 15.sp),
          Expanded(child: wrappedRight),
        ],
      );
    }
  }

  // Warehouse fields
  Widget countryField(WarehouseFormData warehouse) {
    int warehouseIndex = warehouses.indexOf(warehouse);
    String warehousePrefix =
        warehouseIndex == 0 ? '' : 'warehouse${warehouseIndex + 1}_';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).country,
          controller: warehouse.countryController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              if (validationErrors.containsKey('${warehousePrefix}country')) {
                validationErrors.remove('${warehousePrefix}country');
              }
            });
          },
        ),
        if ((_getFieldError('${warehousePrefix}country')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError('${warehousePrefix}country'))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget stateOrProvinceField(WarehouseFormData warehouse) {
    final i = warehouses.indexOf(warehouse);
    final prefix = i == 0 ? '' : 'warehouse${i + 1}_';
    final key = '${prefix}stateOrProvince';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).state,
          controller: warehouse.stateOrProvinceController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) => setState(() {
            validationErrors.remove(key);
          }),
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget cityField(WarehouseFormData warehouse) {
    int warehouseIndex = warehouses.indexOf(warehouse);
    String warehousePrefix =
        warehouseIndex == 0 ? '' : 'warehouse${warehouseIndex + 1}_';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).city,
          controller: warehouse.cityController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              if (validationErrors.containsKey('${warehousePrefix}city')) {
                validationErrors.remove('${warehousePrefix}city');
              }
            });
          },
        ),
        if ((_getFieldError('${warehousePrefix}city')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError('${warehousePrefix}city'))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget postalCodeField(WarehouseFormData warehouse) {
    int warehouseIndex = warehouses.indexOf(warehouse);
    String warehousePrefix =
        warehouseIndex == 0 ? '' : 'warehouse${warehouseIndex + 1}_';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).postalCode,
          controller: warehouse.postalCodeController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              if (validationErrors
                  .containsKey('${warehousePrefix}postalCode')) {
                validationErrors.remove('${warehousePrefix}postalCode');
              }
            });
          },
        ),
        if ((_getFieldError('${warehousePrefix}postalCode')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError('${warehousePrefix}postalCode'))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  // 6. Create attachment preview widget with remove functionality

  // Contract date dropdowns
  Widget contractStartDateDropdown() {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  onSurface: lightMode ? Colors.black : Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            selectStartDate = "${picked.day}-${picked.month}-${picked.year}";
            // Clear validation errors when date is selected
            if (validationErrors.containsKey('contractStartDate')) {
              validationErrors.remove('contractStartDate');
            }
            if (validationErrors.containsKey('contractEndDate')) {
              validationErrors.remove('contractEndDate');
            }
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          StorageTextField(
            label: S.of(context).contractStartDate,
            controller: TextEditingController(text: selectStartDate ?? ""),
            readOnly: true,
            textDirection: ui.TextDirection.ltr,
          ),
          if ((_getFieldError('contractStartDate')) != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                (_getFieldError('contractStartDate'))!,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.red),
              ),
            ),
        ],
      ),
    );
  }

  // Replace your contractEndDateDropdown() method with this:

  Widget contractEndDateDropdown() {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  onSurface: lightMode ? Colors.black : Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            selectEndDate = "${picked.day}-${picked.month}-${picked.year}";
            // Clear validation errors when date is selected
            if (validationErrors.containsKey('contractEndDate')) {
              validationErrors.remove('contractEndDate');
            }
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          StorageTextField(
            label: S.of(context).contractEndDate,
            controller: TextEditingController(text: selectEndDate ?? ""),
            readOnly: true,
            textDirection: ui.TextDirection.ltr,
          ),
          if ((_getFieldError('contractEndDate')) != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                (_getFieldError('contractEndDate'))!,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.red),
              ),
            ),
        ],
      ),
    );
  }

  // Container المعاينة (عرض فقط – بدون onTap)
  Widget buildImagePreview({required File? file, VoidCallback? onTap}) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    String fileName = file != null
        ? file.path.split(Platform.pathSeparator).last
        : "Watermark.png";
    String fileSize = "62 KB";
    if (file != null) {
      final bytes = file.lengthSync();
      if (bytes < 1024) {
        fileSize = "$bytes B";
      } else if (bytes < 1024 * 1024) {
        fileSize = "${(bytes / 1024).toStringAsFixed(0)} KB";
      } else {
        fileSize = "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
      }
    }
    const String dateStr = "28 Dec 2023";

    final preview = Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: lightMode ? const Color(0xffB5B4B4) : AppColors.grey,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Stack(
          children: [
            Row(
              children: [
                // Image/Icon
                if (file != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Image.file(
                      file,
                      width: 36.sp,
                      height: 36.sp,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  CustomSvgImage(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                    width: 36.sp,
                    height: 36.sp,
                    color: AppColors.blackButton,
                    fit: BoxFit.scaleDown,
                  ),
                SizedBox(width: 10.sp),

                // File info with proper constraints
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        overflow: TextOverflow.ellipsis, // Add ellipsis
                        maxLines: 1, // Limit to one line
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      SizedBox(height: 2.sp),
                      Text(
                        fileSize,
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Date info
            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${S.of(context).date}:",
                    style: StyleText.fontSize10Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: StyleText.fontSize10Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Make the preview tappable if onTap is provided
    return onTap != null
        ? GestureDetector(
            onTapDown: hapticDown(onTap, HapticLevel.low),
            onTap: onTap,
            child: preview)
        : preview;
  }

  ////////////////////////////// Dialog Verify //////////////////////////////
  // Replace your entire _showConfirmDialog method with this:

  void _showErrorDialog(String error) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
      title: S.of(context).uploadFailed,
      subtitle: error,
      closeAfter: const Duration(seconds: 5),
    );
  }

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
          padding: EdgeInsets.all(15.sp),
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
                S.of(context).addingNewSupplier,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                S.of(context).areYouSureAddSupplier,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 15.sp),
              Row(
                children: [
                  // No Button
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => HapticController.low(),
                      onTap: () => Navigator.pop(context, false),
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

                  // Yes Button
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => HapticController.low(),
                      onTap: () {
                        Navigator.pop(context, true);
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

    // Handle the result after dialog closes
    if (result == true) {
      try {
        await _submitSupplier(); // This now includes the loading dialog
        if (!mounted) return true;
        // Success message closes itself after 3 seconds...
        final NavigatorState root = Navigator.of(context, rootNavigator: true);
        bool open = true;
        final Future<void> shown =
            _showSuccessDialog(context).whenComplete(() => open = false);
        await Future.any<void>([
          shown,
          Future<void>.delayed(const Duration(seconds: 3)),
        ]);
        if (open) root.pop();
        await shown;
        // ...then back to Inventory Management on the Suppliers list.
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => InventoryManagement(initialFilter: 'Suppliers'),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        debugPrint('Error submitting supplier: $e');
        // Error dialog is already shown in _submitSupplier
      }
    }

    return result ?? false;
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    await showAppDialog(
      context: context,
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
                  S.of(context).newSupplierAdded,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).supplierAddedSuccessfully,
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
  ////////////////////////////// Dialog Verify //////////////////////////////

  ///////////////////////////// upload data to firebase /////////////////////////

  Future<String> uploadFile(File? file, String path) async {
    if (file == null) return '';

    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return '';
    }
  }

  List<WarehouseDraft> _collectWarehouses() {
    return warehouses.map((w) {
      final x = WarehouseDraft()
        ..country = w.countryController.text
        ..stateOrProvince = w.stateOrProvinceController.text
        ..city = w.cityController.text
        ..postalCode = w.postalCodeController.text
        ..streetName = w.streetNameController.text;
      return x;
    }).toList();
  }

  ///////////////////////////// upload data to firebase /////////////////////////

  void handleAddSupplier() async {
    final confirmed = await _showConfirmDialog();
    if (confirmed) {
      // من هنا تقدر تحفظ أو تنقل
      // print("Supplier added successfully!");
    } else {
      // print("Supplier addition cancelled");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var warehouse in warehouses) {
      warehouse.dispose();
    }
    super.dispose();
  }
}

// Helper class to manage warehouse form data
class WarehouseFormData {
  final TextEditingController countryController;
  final TextEditingController cityController;
  final TextEditingController streetNameController;
  final TextEditingController stateOrProvinceController;
  final TextEditingController postalCodeController;

  WarehouseFormData()
      : countryController = TextEditingController(),
        cityController = TextEditingController(),
        streetNameController = TextEditingController(),
        stateOrProvinceController = TextEditingController(),
        postalCodeController = TextEditingController();

  void dispose() {
    countryController.dispose();
    cityController.dispose();
    streetNameController.dispose();
    stateOrProvinceController.dispose();
    postalCodeController.dispose();
  }
}
