import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/pages/select_employee_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/features/inventory/helpers/constants/constant_lists.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/storage_location_form_kit.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class AddNewStorageLocation extends StatefulWidget {
  const AddNewStorageLocation({super.key});

  @override
  State<AddNewStorageLocation> createState() => _AddNewStorageLocationState();
}

class _AddNewStorageLocationState extends State<AddNewStorageLocation> {
  // Storage Location Form TextEditingControllers
  // Basic Location Information Controllers
  final TextEditingController storageLocationIdController =
      TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateOrProvinceController =
      TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController areaController = TextEditingController();

  // Storage Location Details Controllers
  final TextEditingController locationTypeController = TextEditingController();
  final TextEditingController assignedDepartmentController =
      TextEditingController();
  final TextEditingController storageCapacityController =
      TextEditingController();
  final TextEditingController accessLevelController = TextEditingController();
  final TextEditingController equipmentAvailableController =
      TextEditingController();
  final TextEditingController conditionOfStorageController =
      TextEditingController();
  final TextEditingController additionalNoteController =
      TextEditingController();

  // Image picker and storage
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  // Static counter for auto-generating sequential IDs
  static int _storageLocationCounter = 1;

  // Validation variables
  Map<String, String?> validationErrors = {};
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Auto-generate Storage Location ID when the widget initializes
    _generateStorageLocationId();
  }

  /// Generate sequential Storage Location ID in format SL001, SL002, etc.
  void _generateStorageLocationId() {
    final formattedId =
        'SL${_storageLocationCounter.toString().padLeft(3, '0')}';

    setState(() {
      storageLocationIdController.text = formattedId;
    });

    // Increment counter for next storage location
    _storageLocationCounter++;
  }

  /// Handle image selection when SVG is tapped
  Future<void> _selectImage() async {
    await _pickImageFromGallery();
  }

  /// Pick image from gallery only
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error selecting image: $e');
    }
  }

  /// Remove selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    storageLocationIdController.dispose();
    countryController.dispose();
    stateOrProvinceController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    branchNameController.dispose();
    areaController.dispose();
    locationTypeController.dispose();
    assignedDepartmentController.dispose();
    storageCapacityController.dispose();
    accessLevelController.dispose();
    equipmentAvailableController.dispose();
    conditionOfStorageController.dispose();
    additionalNoteController.dispose();
    super.dispose();
  }

  // Default storage location (shown alone first)
  String? selectSupplier;
  String? selectAccessLevel;
  String? selectConditionOfStorage;
  String? selectAssignedDepartment;
  List<String> selectedEquipmentList = []; // Multi-select equipment list
  String? selectLocationType;
  String? selectUnit;

  ///////////////////////////////////// validation /////////////////////////////////

  bool _validateRequiredFields() {
    validationErrors.clear();

    // Validate basic location information
    if (storageLocationIdController.text.trim().isEmpty) {
      validationErrors['storageLocationId'] =
          S.of(context).storageLocationIdRequired;
    }
    if (countryController.text.trim().isEmpty) {
      validationErrors['country'] = S.of(context).countryRequired;
    }
    if (cityController.text.trim().isEmpty) {
      validationErrors['city'] = S.of(context).cityRequired;
    }
    if (branchNameController.text.trim().isEmpty) {
      validationErrors['branchName'] = S.of(context).branchNameRequired;
    }
    if (areaController.text.trim().isEmpty) {
      validationErrors['area'] = S.of(context).areaRequired;
    }

    // Validate storage location details
    if (selectLocationType == null || selectLocationType!.isEmpty) {
      validationErrors['locationType'] = S.of(context).locationTypeRequired;
    }
    if (selectAssignedDepartment == null || selectAssignedDepartment!.isEmpty) {
      validationErrors['assignedDepartment'] =
          S.of(context).assignedDepartmentRequired;
    }
    if (storageCapacityController.text.trim().isEmpty) {
      validationErrors['storageCapacity'] =
          S.of(context).storageCapacityRequired;
    }
    if (selectUnit == null || selectUnit!.isEmpty) {
      validationErrors['unit'] = S.of(context).unitRequired;
    }
    if (selectAccessLevel == null || selectAccessLevel!.isEmpty) {
      validationErrors['accessLevel'] = S.of(context).accessLevelRequired;
    }
    if (selectedEquipmentList.isEmpty) {
      validationErrors['equipmentAvailable'] =
          S.of(context).equipmentAvailableRequired;
    }
    if (selectConditionOfStorage == null || selectConditionOfStorage!.isEmpty) {
      validationErrors['conditionOfStorage'] =
          S.of(context).conditionOfStorageRequired;
    }

    // Validate storage capacity is numeric
    if (storageCapacityController.text.trim().isNotEmpty) {
      final capacity = double.tryParse(storageCapacityController.text.trim());
      if (capacity == null || capacity <= 0) {
        validationErrors['storageCapacity'] =
            S.of(context).validStorageCapacityRequired;
      }
    }

    return validationErrors.isEmpty;
  }

  void _showValidationErrors() {
    var isMobile = context.isPhone;
    var isTablet = context.isTablet;
    String errorMessage = validationErrors.values.join('\n');
    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: isMobile
                ? 120.h
                : isTablet
                    ? 115.h
                    : 120.h,
            width: 411.w,
            child: Column(
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json',
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(height: 20.h),
                Text(
                  errorMessage,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleNextButton() {
    if (_validateRequiredFields()) {
      final storageLocationData = <String, dynamic>{
        // Keep as dynamic to handle different types
        'storageLocationId': storageLocationIdController.text,
        'country': countryController.text,
        'stateOrProvince': stateOrProvinceController.text,
        'city': cityController.text,
        'postalCode': postalCodeController.text,
        'branchName': branchNameController.text,
        'area': areaController.text,
        'locationType': selectLocationType ?? '',
        'assignedDepartment': selectAssignedDepartment ?? '',
        'storageCapacity': storageCapacityController.text,
        'unit': selectUnit ?? '',
        'accessLevel': selectAccessLevel ?? '',
        'equipmentAvailable': selectedEquipmentList.join(
          ',',
        ), // Convert to comma-separated string
        'conditionOfStorage': selectConditionOfStorage ?? '',
        'additionalNote': additionalNoteController.text,
        'selectedImage': _selectedImage, // Pass the selected image file
      };

      debugPrint(
          'Navigating to SelectEmployee with data: $storageLocationData');

      // Navigate to SelectEmployee with storage location data
      navigateTo(
        context,
        SelectEmployeeToggle(storageLocationData: storageLocationData),
      );
    } else {
      _showValidationErrors();
    }
  }

  ///////////////////////////////////// validation /////////////////////////////////

  /// True once every field the form asks for has an answer. Pure — it never
  /// touches [validationErrors] or calls setState, so it is safe in build().
  ///
  /// Everything is required except the photo and the Additional Note.
  bool get _isFormComplete {
    bool filled(TextEditingController c) => c.text.trim().isNotEmpty;
    bool picked(String? v) => v != null && v.isNotEmpty;
    final capacity = double.tryParse(storageCapacityController.text.trim());

    return filled(storageLocationIdController) &&
        filled(countryController) &&
        filled(stateOrProvinceController) &&
        filled(cityController) &&
        filled(postalCodeController) &&
        filled(branchNameController) &&
        filled(areaController) &&
        picked(selectLocationType) &&
        picked(selectAssignedDepartment) &&
        capacity != null &&
        capacity > 0 &&
        picked(selectUnit) &&
        picked(selectAccessLevel) &&
        selectedEquipmentList.isNotEmpty &&
        picked(selectConditionOfStorage);
  }

  /// Rebuilds so the Next button re-checks [_isFormComplete] on every edit.
  void _refresh([Object? _]) => setState(() {});

  /// Bumped by Clear / Fill so StorageLocationFields rebuilds from the
  /// controllers.
  int _formVersion = 0;

  /// Empties everything the user typed or picked. The auto-generated
  /// Storage Location ID is kept.
  void _clearForm() {
    for (final c in [
      countryController,
      stateOrProvinceController,
      cityController,
      postalCodeController,
      branchNameController,
      areaController,
      storageCapacityController,
      additionalNoteController,
    ]) {
      c.clear();
    }
    setState(() {
      _selectedImage = null;
      selectLocationType = null;
      selectAssignedDepartment = null;
      selectUnit = null;
      selectAccessLevel = null;
      selectConditionOfStorage = null;
      selectedEquipmentList = [];
      validationErrors.clear();
      _formVersion++;
    });
  }

  /// Realistic test values (debug builds only — see FormToolsBar).
  void _fillSampleData() {
    String firstKey(List<Map<String, String>> list) =>
        list.isEmpty ? '' : (list.first['key'] ?? '');
    final equipment = ConstantLists.listOfEquipmentAvailableList();
    countryController.text = 'Egypt';
    stateOrProvinceController.text = 'Cairo';
    cityController.text = 'Nasr City';
    postalCodeController.text = '11371';
    branchNameController.text = 'Nasr City Branch';
    areaController.text = 'Building 4, Floor 2';
    storageCapacityController.text = '250';
    additionalNoteController.text =
        'Main IT storage room — access card required after 6 PM.';
    setState(() {
      selectLocationType = firstKey(ConstantLists.locationTypeList());
      selectAssignedDepartment =
          firstKey(ConstantLists.departmentTranslationsCamel());
      selectUnit = firstKey(ConstantLists.storageCapacityList());
      selectAccessLevel = firstKey(ConstantLists.accessLevelList());
      selectConditionOfStorage =
          firstKey(ConstantLists.conditionOfStorageList());
      selectedEquipmentList = equipment.take(2).toList();
      validationErrors.clear();
      _formVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventory,
          onFirstTap: () {
            navigateTo(context, InventoryManagement());
          },
          secondTitle: S.of(context).addingNewStorageLocation,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clear All / Fill sample data (sample only in debug builds).
                FormToolsBar(onClear: _clearForm, onFill: _fillSampleData),
                SizedBox(height: 10.sp),

                // ── Location Details ──────────────────────────────────────
                StorageSection(
                  title: S.of(context).locationDetails,
                  collapsible: false,
                  startsWithLabel: false, // opens with the photo box
                  child: StorageFieldsColumn(
                    children: [
                      _buildImageUploadSection(lightMode),
                      StorageFieldsRow(
                        left: StorageTextField(
                          label: S.of(context).storageLocationId,
                          controller: storageLocationIdController,
                          readOnly: true,
                          textDirection: ui.TextDirection.ltr,
                        ),
                      ),
                      // Country → State → City dropdowns (+ Postal Code).
                      StorageLocationFields(
                        // New key after Clear / Fill so the dropdowns re-read
                        // the controllers.
                        key: ValueKey('location-$_formVersion'),
                        countryController: countryController,
                        stateController: stateOrProvinceController,
                        cityController: cityController,
                        onChanged: _refresh,
                        postalCode: StorageTextField(
                          label: S.of(context).postalCode,
                          controller: postalCodeController,
                          textDirection: ui.TextDirection.ltr,
                          onChanged: _refresh,
                        ),
                      ),
                      StorageFieldsRow(
                        left: StorageTextField(
                          label: S.of(context).branchName,
                          controller: branchNameController,
                          onChanged: _refresh,
                        ),
                        right: StorageTextField(
                          label: S.of(context).area,
                          controller: areaController,
                          onChanged: _refresh,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.sp),

                // ── Storage Location Details ─────────────────────────────
                StorageSection(
                  title: S.of(context).storageLocationDetails,
                  collapsible: false,
                  child: StorageFieldsColumn(
                    children: [
                      StorageFieldsRow(
                        left: StorageDropdown<String>(
                          label: S.of(context).locationType,
                          items: _items(ConstantLists.locationTypeList()),
                          value: selectLocationType,
                          onChanged: (val) =>
                              setState(() => selectLocationType = val),
                        ),
                        right: StorageDropdown<String>(
                          label: S.of(context).assignedDepartment,
                          items: _items(
                            ConstantLists.departmentTranslationsCamel(),
                          ),
                          value: selectAssignedDepartment,
                          onChanged: (val) =>
                              setState(() => selectAssignedDepartment = val),
                        ),
                      ),
                      StorageFieldsRow(
                        left: _buildCapacityWithUnit(),
                        right: StorageDropdown<String>(
                          label: S.of(context).accessLevel,
                          items: _items(ConstantLists.accessLevelList()),
                          value: selectAccessLevel,
                          onChanged: (val) =>
                              setState(() => selectAccessLevel = val),
                        ),
                      ),
                      StorageFieldsRow(
                        left: _buildEquipmentField(lightMode),
                        right: StorageDropdown<String>(
                          label: S.of(context).conditionOfStorage,
                          items: _items(ConstantLists.conditionOfStorageList()),
                          value: selectConditionOfStorage,
                          onChanged: (val) =>
                              setState(() => selectConditionOfStorage = val),
                        ),
                      ),
                      StorageTextField(
                        label: S.of(context).additionalNote,
                        controller: additionalNoteController,
                        multiline: true,
                        onChanged: _refresh,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.sp),

                // ── Discard / Next ───────────────────────────────────────
                _buildActionButtons(),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownItem<String>> _items(List<Map<String, String>> source) => source
      .map((e) => DropdownItem<String>(
            value: e['key'] ?? '',
            label: e['value'] ?? '',
          ))
      .toList();

  /// Storage Capacity (number) + Unit (100 wide), bottoms aligned so the
  /// unlabeled Unit box sits on the same line as the capacity box.
  Widget _buildCapacityWithUnit() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: StorageTextField(
            label: S.of(context).storageCapacity,
            controller: storageCapacityController,
            onlyDigits: true,
            textDirection: ui.TextDirection.ltr,
            onChanged: _refresh,
          ),
        ),
        SizedBox(width: 10.sp),
        SizedBox(
          width: storageUnitBoxWidth(context),
          child: CustomDropdown<String>(
            hint: S.of(context).unit,
            items: _items(ConstantLists.storageCapacityList()),
            value: selectUnit,
            onChanged: (val) => setState(() => selectUnit = val),
            height: StorageFieldSpec.height,
            triggerPadding: StorageFieldSpec.contentPadding,
            suffixIconPadding: StorageFieldSpec.suffixPadding,
            borderRadius: StorageFieldSpec.borderRadius,
          ),
        ),
      ],
    );
  }

  /// Equipment Available allows several answers, so it uses the multi-select
  /// sibling of 1-custom_dropdown.dart, held to the same box spec.
  Widget _buildEquipmentField(bool lightMode) {
    return StorageMultiDropdown<String>(
      label: S.of(context).equipmentAvailable,
      items: ConstantLists.listOfEquipmentAvailableList()
          .map((e) => MultiSelectDropdownItem<String>(value: e, label: e))
          .toList(),
      values: selectedEquipmentList,
      onChanged: (values) =>
          setState(() => selectedEquipmentList = List<String>.of(values)),
    );
  }

  /// Photo box: a 60×60 SQUARE (`.r` on both sides so it is never stretched
  /// into a rectangle on wide screens), with the camera badge on its corner.
  Widget _buildImageUploadSection(bool lightMode) {
    final double box = 60.r;
    final double badge = 20.r;
    return SizedBox(
      width: box + badge / 2,
      height: box + badge / 2,
      child: Stack(
        children: [
          GestureDetector(
            onTapDown: hapticDown(_selectImage, HapticLevel.low),
            onTap: _selectImage,
            child: Container(
              width: box,
              height: box,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color:
                    lightMode ? const Color(0xffD0D0D0) : AppColors.background,
                border: _selectedImage != null
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: Image.file(
                        _selectedImage!,
                        width: box,
                        height: box,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: CustomSvgImage(
                        assetPath: kStorageLocationPlaceholderIcon,
                        width: 40.r,
                        height: 40.r,
                        fit: BoxFit.contain,
                        color: AppColors.blackButton,
                      ),
                    ),
            ),
          ),
          PositionedDirectional(
            start: box - badge / 2,
            top: box - badge / 2,
            child: GestureDetector(
              onTap: withHaptic(
                  _selectedImage == null ? _selectImage : _removeImage,
                  HapticLevel.low),
              child: Container(
                width: badge,
                height: badge,
                decoration: BoxDecoration(
                  color:
                      _selectedImage == null ? AppColors.primary : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _selectedImage == null
                      ? CustomSvgImage(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_media_attach_square.svg",
                          width: 12.r,
                          height: 12.r,
                          fit: BoxFit.contain,
                          color: AppColors.textButton,
                        )
                      : Icon(Icons.remove, color: Colors.white, size: 12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Discard (grey) on the start edge, Next on the end edge. Next stays
  /// disabled — grey and unresponsive — until [_isFormComplete].
  Widget _buildActionButtons() {
    final bool ready = _isFormComplete;
    return Row(
      textDirection: TextDirection
          .ltr, // X-73: Cancel left, action right in both languages

      children: [
        customButton(
          title: S.of(context).discard,
          function: () => Navigator.pop(context),
          textStyle: storageDiscardTextStyle,
          width: 150.sp,
          color: storageDiscardColor,
        ),
        const Spacer(),
        IgnorePointer(
          ignoring: !ready,
          child: customButton(
            title: S.of(context).next,
            function: _handleNextButton,
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.textButton,
            ),
            width: 150.sp,
            color: storageButtonColor(enabled: ready),
          ),
        ),
      ],
    );
  }
}
