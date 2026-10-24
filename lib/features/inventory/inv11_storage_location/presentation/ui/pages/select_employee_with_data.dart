import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/select_employee_with_data/helper.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/inventory/domain/models/storage_location_model.dart';
import 'package:knowticed_plus/features/inventory/presentation/controller/product_cubit.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/add_storage_location/image.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/storage_location_form_kit.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/features/inventory/helpers/constants/constant_lists.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

EmployeeEntityModel mapToModel(EmployeeEntityPro e) {
  return EmployeeEntityModel(
    id: e.id ?? '',
    email: e.email ?? '',
    firstName: e.firstName ?? '',
    lastName: e.lastName ?? '',
    firstNameInArabic: e.firstNameInArabic ?? '',
    lastNameInArabic: e.lastNameInArabic ?? '',
    departmentId: e.departmentId ?? '',
    title: e.title ?? '',
    role: e.role ?? '',
    gender: e.gender ?? '',
    // add any other fields your EmployeeEntityModel requires
  );
}

class SelectEmployeeWithData extends StatefulWidget {
  final Map<String, dynamic> storageLocationData;
  final List<EmployeeEntityPro> selectedEmployees;

  const SelectEmployeeWithData({
    super.key,
    required this.storageLocationData,
    required this.selectedEmployees,
  });

  @override
  State<SelectEmployeeWithData> createState() => _SelectEmployeeWithDataState();
}

class _SelectEmployeeWithDataState extends State<SelectEmployeeWithData> {
  // Storage Location Form TextEditingControllers
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
  final TextEditingController _searchController = TextEditingController();
  String? selectedDepartment;
  String selectedLabel = "allocated"; // Default selected chip
  // Generate departments list from the translation map
  List<Map<String, String>> get departments {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return departmentTranslationsCamel.entries.map((entry) {
      return {
        "key": entry.key,
        "value":
            isArabic ? entry.value : _formatEnglishDepartmentName(entry.key),
      };
    }).toList();
  }

  static const Map<String, String> departmentTranslationsCamel = {
    "marketing": "التسويق",
    "sales": "المبيعات",
    "hr": "شؤون الموظفين",
    "executive": "الإدارة التنفيذية",
    "customerSupport": "دعم العملاء",
    "operations": "العمليات",
    "finance": "المالية",
    "informationTechnology": "تقنية المعلومات",
    "humanResources": "الموارد البشرية",
    "dataManagement": "إدارة البيانات",
    "complianceAndLegal": "الامتثال والقانون",
    "software": "البرمجيات",
  };
  // Helper method to format English department names
  String _formatEnglishDepartmentName(String camelCase) {
    // Convert camelCase to readable format
    return camelCase
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : word,
        )
        .join(' ')
        .trim();
  }

  Map<String, String> validationErrors = {}; // Add this if not present

  // Dropdown selections
  String? selectSupplier;
  String? selectAccessLevel;
  String? selectConditionOfStorage;
  String? selectAssignedDepartment;
  String? selectEquipmentAvailable;
  String? selectLocationType;
  String? selectUnit;

  @override
  void initState() {
    super.initState();
    _populateStorageLocationData();
    _initBlocListener();

    debugPrint('SelectEmployeeWithData received:');
    debugPrint('Storage Location Data: ${widget.storageLocationData}');
    debugPrint('Selected Employees: ${widget.selectedEmployees.length}');
  }

  void _initBlocListener() {
    // Listen to ProductCubit state changes
    context.read<ProductCubit>().stream.listen((state) {
      if (state is StorageLocationSuccess) {
        debugPrint("Storage location operation completed successfully");
      } else if (state is StorageLocationError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    });
  }

  /// Populate form fields with storage location data from previous screen
  List<String> selectedEquipmentList = []; // For multi-select equipment

  void _populateStorageLocationData() {
    final data = widget.storageLocationData;

    storageLocationIdController.text =
        data['storageLocationId']?.toString() ?? '';
    countryController.text = data['country']?.toString() ?? '';
    stateOrProvinceController.text = data['stateOrProvince']?.toString() ?? '';
    cityController.text = data['city']?.toString() ?? '';
    postalCodeController.text = data['postalCode']?.toString() ?? '';
    branchNameController.text = data['branchName']?.toString() ?? '';
    areaController.text = data['area']?.toString() ?? '';
    storageCapacityController.text = data['storageCapacity']?.toString() ?? '';
    additionalNoteController.text = data['additionalNote']?.toString() ?? '';

    // Set dropdown values with safe casting
    setState(() {
      selectLocationType = _safeStringValue(data['locationType']);
      selectSupplier = _safeStringValue(data['assignedDepartment']);
      selectUnit = _safeStringValue(data['unit']);
      selectAccessLevel = _safeStringValue(data['accessLevel']);
      selectConditionOfStorage = _safeStringValue(data['conditionOfStorage']);

      // Handle equipment - check if it's a String (comma-separated) or List
      final equipmentData = data['equipmentAvailable'];
      if (equipmentData != null) {
        if (equipmentData is List<String>) {
          // If it's already a List (shouldn't happen with current flow, but safety check)
          selectedEquipmentList = List<String>.from(equipmentData);
        } else if (equipmentData is String && equipmentData.isNotEmpty) {
          // If it's a comma-separated string
          selectedEquipmentList =
              equipmentData.split(',').map((e) => e.trim()).toList();
        } else {
          selectedEquipmentList = [];
        }
      } else {
        selectedEquipmentList = [];
      }
    });
  }

  String? _safeStringValue(dynamic value) {
    if (value == null) return null;
    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? null : stringValue;
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
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Location details ─────────────────────────────────────
                StorageSection(
                  title: S.of(context).locationDetails,
                  collapsible: false,
                  child: StorageFieldsColumn(
                    children: [
                      StorageFieldsRow(left: _buildStorageLocationIdField()),
                      _buildCountryAndStateRow(),
                      _buildBranchNameAndAreaRow(),
                    ],
                  ),
                ),
                SizedBox(height: 20.sp),

                // ── Storage location details ─────────────────────────────
                StorageSection(
                  title: S.of(context).storageLocationDetails,
                  collapsible: false,
                  child: StorageFieldsColumn(
                    children: [
                      _buildLocationTypeAndDepartmentRow(),
                      _buildStorageCapacityAndAccessLevelRow(),
                      _buildEquipmentAndConditionRow(),
                      _buildAdditionalNoteField(),
                    ],
                  ),
                ),
                SizedBox(height: 20.sp),

                // Assigned Employees Section
                StorageSection(
                  title: S.of(context).employeeAssignedInformation,
                  startsWithLabel: false, // opens with the search bar
                  child: _buildAssignedEmployeesSection(lightMode),
                ),
                SizedBox(height: 20.sp),

                // Action buttons
                _buildActionButtons(),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _refresh([Object? _]) => setState(() {});

  List<DropdownItem<String>> _items(List<Map<String, String>> source) => source
      .map((e) => DropdownItem<String>(
            value: e['key'] ?? '',
            label: e['value'] ?? '',
          ))
      .toList();

  /// True once every required field has an answer (photo and note optional).
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
        picked(selectSupplier) &&
        capacity != null &&
        capacity > 0 &&
        picked(selectUnit) &&
        picked(selectAccessLevel) &&
        selectedEquipmentList.isNotEmpty &&
        picked(selectConditionOfStorage);
  }

  Widget _buildStorageLocationIdField() {
    return StorageTextField(
      label: S.of(context).storageLocationId,
      controller: storageLocationIdController,
      readOnly: true,
      textDirection: ui.TextDirection.ltr,
    );
  }

  /// Country → State → City dropdowns, with Postal Code beside City.
  Widget _buildCountryAndStateRow() {
    return StorageLocationFields(
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
    );
  }

  Widget _buildBranchNameAndAreaRow() {
    return StorageFieldsRow(
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
    );
  }

  Widget _buildLocationTypeAndDepartmentRow() {
    return StorageFieldsRow(
      left: StorageDropdown<String>(
        label: S.of(context).locationType,
        items: _items(ConstantLists.locationTypeList()),
        value: selectLocationType,
        onChanged: (val) => setState(() => selectLocationType = val),
      ),
      right: StorageDropdown<String>(
        label: S.of(context).assignedDepartment,
        items: _items(ConstantLists.departmentTranslationsCamel()),
        value: selectSupplier,
        onChanged: (val) => setState(() => selectSupplier = val),
      ),
    );
  }

  /// Storage Capacity + an unlabeled 100-wide Unit box, bottoms aligned, so
  /// the row is exactly label + 36 like every other row.
  Widget _buildStorageCapacityAndAccessLevelRow() {
    return StorageFieldsRow(
      left: Row(
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
      ),
      right: StorageDropdown<String>(
        label: S.of(context).accessLevel,
        items: _items(ConstantLists.accessLevelList()),
        value: selectAccessLevel,
        onChanged: (val) => setState(() => selectAccessLevel = val),
      ),
    );
  }

  Widget _buildEquipmentAndConditionRow() {
    return StorageFieldsRow(
      left: StorageMultiDropdown<String>(
        label: S.of(context).equipmentAvailable,
        items: ConstantLists.listOfEquipmentAvailableList()
            .map((e) => MultiSelectDropdownItem<String>(value: e, label: e))
            .toList(),
        values: selectedEquipmentList,
        onChanged: (values) =>
            setState(() => selectedEquipmentList = List<String>.of(values)),
      ),
      right: StorageDropdown<String>(
        label: S.of(context).conditionOfStorage,
        items: _items(ConstantLists.conditionOfStorageList()),
        value: selectConditionOfStorage,
        onChanged: (val) => setState(() => selectConditionOfStorage = val),
      ),
    );
  }

  Widget _buildAdditionalNoteField() {
    return StorageTextField(
      label: S.of(context).additionalNote,
      controller: additionalNoteController,
      multiline: true,
      onChanged: _refresh,
    );
  }

  /// Build Assigned Employees Section
  Widget _buildAssignedEmployeesSection(bool lightMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search and DropDown Department
        Row(
          children: [
            AppSearchTextField(
              controller: _searchController,
              fillColor: kStorageInnerFill,
              onChanged: (_) {},
            ),
            // space
            SizedBox(width: ButtonSizing.toolbarGap(context)),
            // Department
            SizedBox(
              width: 135.w,
              child: CustomDropdown<String>(
                items: (departments)
                    .map((e) => DropdownItem<String>(
                        value: e['key'] ?? '', label: e['value'] ?? ''))
                    .toList(),
                value: selectedDepartment,
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                  });
                },
                hint: S.of(context).department,
                height: 38,
                triggerPadding: StorageFieldSpec.contentPadding,
                suffixIconPadding: StorageFieldSpec.suffixPadding,
                borderRadius: BorderRadius.circular(8.r),
                fillColor: kStorageInnerFill,
              ),
            ),
          ],
        ),

        SizedBox(height: 15.sp),

        // Employee cards grid
        widget.selectedEmployees.isEmpty
            ? _buildEmptyEmployeeState(lightMode)
            : _buildEmployeeCardsGrid(lightMode),
      ],
    );
  }

  /// Build employee cards in a grid layout
  Widget _buildEmployeeCardsGrid(bool lightMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: widget.selectedEmployees.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
          context,
        ),
        crossAxisSpacing: 10.sp,
        mainAxisSpacing: 10.sp,
        mainAxisExtent: 72.h, // Height of each card
      ),
      itemBuilder: (context, index) {
        final employee = widget.selectedEmployees[index];
        return _buildEnhancedEmployeeCard(employee, lightMode, index);
      },
    );
  }

  /// Role per employee on this storage location (employee / manager),
  /// seeded from what was picked on the Assigning Employees step.
  final Map<String, String> _employeeRoles = {};

  String _roleKey(EmployeeEntityPro e) =>
      (e.id?.isNotEmpty ?? false) ? e.id! : (e.email ?? '');

  String _roleFor(EmployeeEntityPro e) {
    final key = _roleKey(e);
    final Object? seeded = widget.storageLocationData['employeeRoles'];
    return _employeeRoles[key] ??
        (seeded is Map ? seeded[key]?.toString() : null) ??
        'employee';
  }

  Widget _buildEnhancedEmployeeCard(
    EmployeeEntityPro employee,
    bool lightMode,
    int index,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Name handling
    final nameEn = [
      employee.firstName,
      employee.lastName,
    ].where((x) => (x ?? '').trim().isNotEmpty).join(' ').trim();
    final nameAr = [
      employee.firstNameInArabic,
      employee.lastNameInArabic,
    ].where((x) => (x ?? '').trim().isNotEmpty).join(' ').trim();
    final displayName = isArabic
        ? (nameAr.isNotEmpty ? nameAr : nameEn)
        : (nameEn.isNotEmpty ? FormatHelper.capitalize(nameEn) : nameAr);

    // Role/Department handling
    final roleEn = (employee.role ?? '').trim();
    final titleEn = (employee.title ?? '').trim();
    final displayTitle = FormatHelper.capitalize(
      roleEn.isNotEmpty ? roleEn : titleEn,
    );

    // Mock department name (you can replace this with actual department lookup)
    final departmentName = _getDepartmentDisplayName(
      employee.departmentId ?? '',
      isArabic,
    );

    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          decoration: BoxDecoration(
            color: kStorageInnerFill,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 10.h,
              right: 10.w,
              left: 10.w,
              bottom: 7.h,
            ),
            child: Row(
              children: [
                // Avatar
                Padding(
                  padding: EdgeInsets.only(bottom: 13.h),
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: CustomSvgImage.natural(
                        assetPath: employee.gender == "male"
                            ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                            : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
                        semanticsLabel: 'Gender Icon',
                        fit: BoxFit.cover,
                        width: 36.w,
                        height: 36.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      displayName,
                      style: StyleText.fontSize12Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Department
                    Text(
                      departmentName,
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Role/Title
                    Text(
                      displayTitle.isNotEmpty ? displayTitle : 'Employee',
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Action dropdown section
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTapDown: (_) => HapticController.high(),
                onTap: () => _removeEmployee(index),
                child: Container(
                  width: 15.w,
                  height: 15.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Icon(Icons.remove, size: 12.sp, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 15.sp),
              StorageRoleChip(
                value: _roleFor(employee),
                onChanged: (v) {
                  setState(() => _employeeRoles[_roleKey(employee)] = v);
                  _updateEmployeeRole(index, v);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get department display name
  String _getDepartmentDisplayName(String departmentId, bool isArabic) {
    // This is a mock implementation - replace with your actual department lookup
    final departmentMap = {
      'marketing': isArabic ? 'التسويق' : 'Marketing',
      'sales': isArabic ? 'المبيعات' : 'Sales',
      'hr': isArabic ? 'الموارد البشرية' : 'HR',
      'it': isArabic ? 'تقنية المعلومات' : 'IT',
    };

    return departmentMap[departmentId.toLowerCase()] ??
        (isArabic
            ? 'قسم غير محدد'
            : 'Marketing'); // Default to Marketing as shown in image
  }

  /// Remove employee from the list
  void _removeEmployee(int index) {
    setState(() {
      widget.selectedEmployees.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Employee removed from storage location'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Update employee role/designation
  void _updateEmployeeRole(int index, String newRole) {
    // You can implement role assignment logic here
    debugPrint(
      'Updated employee ${widget.selectedEmployees[index].firstName} role to: $newRole',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Employee role updated to $newRole'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Build empty state when no employees are assigned
  Widget _buildEmptyEmployeeState(bool lightMode) {
    return Container(
      padding: EdgeInsets.all(40.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.grey,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48.sp,
              color: AppColors.secondaryText,
            ),
            SizedBox(height: 15.sp),
            Text(
              'No employees assigned yet',
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(height: 8.sp),
            Text(
              'Add employees to manage this storage location',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Row(
      textDirection: TextDirection
          .ltr, // X-73: Cancel left, action right in both languages

      children: [
        customButton(
          title: S.of(context).discard,
          function: () {
            Navigator.pop(context);
          },
          textStyle: storageDiscardTextStyle,
          width: 150.sp,
          height: 38.sp,
          radius: 8.r,
          color: storageDiscardColor,
        ),
        Spacer(),
        // customButton(
        //   title: 'Edit Employees',
        //   function: () {
        //     // Navigate back to SelectEmployee with current data
        //     navigateTo(context, SelectEmployeeToggle(
        //       storageLocationData: _collectCurrentStorageLocationData(),
        //     ));
        //   },
        //   textStyle: StyleText.fontSize16Weight500.copyWith(
        //     color: AppColors.blackButton,
        //   ),
        //   width: 150.sp,
        //   height: 38.sp,
        //   radius: 8.r,
        //   color: AppColors.grey,
        // ),
        // SizedBox(width: 10.sp),
        IgnorePointer(
          ignoring: !_isFormComplete,
          child: customButton(
            title: S.of(context).submit,
            function: () {
              if (selectLocationType == null || selectLocationType!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a location type')),
                );
                return;
              }
              _saveAllData();
            },
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.textButton,
            ),
            width: 150.sp,
            color: storageButtonColor(enabled: _isFormComplete),
          ),
        ),
      ],
    );
  }

  /// Collect current storage location data
  Map<String, String> _collectCurrentStorageLocationData() {
    return {
      'storageLocationId': storageLocationIdController.text,
      'country': countryController.text,
      'stateOrProvince': stateOrProvinceController.text,
      'city': cityController.text,
      'postalCode': postalCodeController.text,
      'branchName': branchNameController.text,
      'area': areaController.text,
      'locationType': selectLocationType ?? '',
      'assignedDepartment': selectSupplier ?? '',
      'storageCapacity': storageCapacityController.text,
      'unit': selectUnit ?? '',
      'accessLevel': selectAccessLevel ?? '',
      'equipmentAvailable': selectedEquipmentList.join(
        ',',
      ), // Convert List back to comma-separated string
      'conditionOfStorage': selectConditionOfStorage ?? '',
      'additionalNote': additionalNoteController.text,
      'status': "active",
    };
  }

  /// Save all data (storage location + employees)
  /// Save all data (storage location + employees) with image upload
  void _saveAllData() async {
    // Show confirmation dialog first
    await showConfirmationDialog(
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json',
      title: S.of(context).addingNewLocation,
      message: S.of(context).confirmAddLocation,
      onConfirm: () async {
        final String userEmail = InventoryPaths.userEmail;

        try {
          // The app's own loader (66-circle_progress.dart). It sits on the
          // ROOT navigator, so it is closed with _closeLoader() — never with
          // Navigator.of(context).pop(), which pops THIS PAGE off the inventory
          // module's nested navigator.
          showLoadingIndicator();

          final form = _collectCurrentStorageLocationData();
          String imageUrl = ''; // Default empty string

          // Upload image if selected
          final selectedImage =
              widget.storageLocationData['selectedImage'] as File?;
          if (selectedImage != null) {
            debugPrint('Uploading image to Firebase Storage...');

            final uploadedImageUrl =
                await StorageImageService.uploadStorageLocationImage(
              imageFile: selectedImage,
              userEmail: userEmail,
              storageLocationId: form['storageLocationId'] ?? 'default_id',
            );

            if (uploadedImageUrl != null) {
              imageUrl = uploadedImageUrl;
              debugPrint('Image uploaded successfully: $imageUrl');
            } else {
              debugPrint('Failed to upload image, continuing without image');
              // You can choose to show an error or continue without image
              // For now, we continue without image
            }
          }

          // Build model from your existing JSON shape using your existing fromJson:
          final storage = StorageLocation.fromJson({
            'id': {
              'value': form['storageLocationId'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'name': {
              'value': form['branchName'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'storageImage': {
              'value': imageUrl,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }, // Add image URL here
            'country': {
              'value': form['country'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'stateOrProvince': {
              'value': form['stateOrProvince'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'city': {
              'value': form['city'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'postalCode': {
              'value': form['postalCode'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'branchName': {
              'value': form['branchName'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'area': {
              'value': form['area'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'status': {
              'value': form['status'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'createdBy': {
              'value': userEmail,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'dateAdded': {
              'value': Timestamp.now(),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'locationType': {
              'value': form['locationType'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'assignedDepartment': {
              'value': form['assignedDepartment'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'accessLevel': {
              'value': form['accessLevel'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'storageCapacity': {
              'value': int.tryParse(form['storageCapacity'] ?? '0') ?? 0,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'capacityUnit': {
              'value': form['unit'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'conditionOfStorage': {
              'value': form['conditionOfStorage'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'equipmentAvailable': {
              'value': form['equipmentAvailable'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'additionalNote': {
              'value': form['additionalNote'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'employee': {
              'value': widget.selectedEmployees
                  .map((e) => mapToModel(e).toJson())
                  .toList(),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
          });

          // Create storage location in Firestore
          await StorageLocationService.createAutoId(
            userEmail: userEmail,
            model: storage,
          );

          _closeLoader();

          // Show success dialog
          if (!mounted) return;
          await showSuccessDialog(
            lottiePath:
                'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
            title: S.of(context).newStorageLocationAdded,
            subtitle: S.of(context).locationAddedSuccess,
          );

          // Navigate to InventoryManagement with Storage Locations filter
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    InventoryManagement(initialFilter: 'Storage Locations'),
              ),
              (route) => false, // Remove all previous routes
            );
          }
        } catch (e) {
          _closeLoader();

          if (!mounted) return;
          await CustomDialogManager.showMessage(
            context: context,
            lottiePath:
                'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
            title: S.of(context).error,
            subtitle: S.of(context).failedToCreateStorageLocation,
            closeAfter: const Duration(seconds: 5),
          );
        }
      },
    );
  }

  /// Build responsive layout for form fields (mobile vs desktop)
  Widget buildResponsiveFields({
    required BuildContext context,
    required Widget left,
    required Widget right,
  }) {
    final isMobile = kpIsPhoneLayout(context);

    if (isMobile) {
      // Stack fields vertically on mobile devices
      return Column(children: [left, SizedBox(height: 10.sp), right]);
    } else {
      // Place fields side by side on desktop/tablet
      return Row(
        children: [
          Expanded(child: left),
          SizedBox(width: 15.sp),
          Expanded(child: right),
        ],
      );
    }
  }

  /// Closes the loader opened by [showLoadingIndicator], and nothing else.
  /// Guarded, so a call when no loader is open cannot pop a page instead.
  void _closeLoader() {
    if (Get.isDialogOpen == true) hideLoadingIndicator();
  }

  Future<void> showConfirmationDialog({
    required String lottiePath,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: 405.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath, // Replace with your Lottie URL
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true, // Set to false if you don't want it to loop
                  animate: true, // Set to false to pause the animation
                ),
                SizedBox(height: 20.sp),
                Text(
                  title,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 15.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 56.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      customButton(
                        title: S.of(context).no,
                        function: () => Navigator.pop(context),
                        textStyle: StyleText.fontSize15Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                        width: 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.secondaryButton,
                      ),
                      SizedBox(width: 20.sp),
                      customButton(
                        title: S.of(context).yes,
                        function: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        textStyle: StyleText.fontSize18Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Success message that closes ITSELF after 3 seconds — no tap needed —
  /// so the flow moves on (to Inventory Management) automatically. A tap
  /// outside still closes it early.
  Future<void> showSuccessDialog({
    required String lottiePath,
    required String title,
    required String subtitle,
  }) async {
    final NavigatorState root = Navigator.of(context, rootNavigator: true);
    bool open = true;
    final Future<void> shown = _showSuccessDialogUntimed(
      lottiePath: lottiePath,
      title: title,
      subtitle: subtitle,
    ).whenComplete(() => open = false);
    await Future.any<void>([
      shown,
      Future<void>.delayed(const Duration(seconds: 3)),
    ]);
    if (open) root.pop();
    await shown;
  }

  Future<void> _showSuccessDialogUntimed({
    required String lottiePath,
    required String title,
    required String subtitle,
  }) async {
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: 405.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath,
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(height: 20.sp),
                Text(
                  title,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  subtitle,
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
}
