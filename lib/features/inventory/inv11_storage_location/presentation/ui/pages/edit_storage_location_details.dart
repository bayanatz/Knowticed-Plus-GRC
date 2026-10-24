import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
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

class EditStorageLocationDetails extends StatefulWidget {
  final StorageLocation? storageLocation;
  final Map<String, String> storageLocationData;
  final List<EmployeeEntityPro> selectedEmployees;

  const EditStorageLocationDetails({
    super.key,
    this.storageLocation,
    this.storageLocationData = const {},
    this.selectedEmployees = const [],
  });

  @override
  State<EditStorageLocationDetails> createState() =>
      _EditStorageLocationDetailsState();
}

class _EditStorageLocationDetailsState
    extends State<EditStorageLocationDetails> {
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
  List<EmployeeEntityPro> _filteredEmployees =
      []; // For displaying filtered results
  // Track employees from storage location model
  List<EmployeeEntityPro> _currentEmployees = [];

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage; // New selected image file
  String? _currentImageUrl; // Current image URL from Firestore
  bool _imageChanged = false; // Track if image was changed

  // Add these variables to your _EditStorageLocationDetailsState class
  List<String> selectedEquipmentList = []; // For multi-select equipment
  Map<String, String> validationErrors = {}; // For validation
  // Flag to determine if this is editing an existing location
  bool get isEditMode => widget.storageLocation != null;

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

  // Dropdown selections
  String? selectSupplier;
  String? selectAccessLevel;
  String? selectConditionOfStorage;
  String? selectAssignedDepartment;
  String? selectEquipmentAvailable;
  String? selectLocationType;
  String? selectUnit;

  // Add these variables to your _StorageLocationDetailsState class

  @override
  void initState() {
    super.initState();
    _populateStorageLocationData();
    _initBlocListener();

    // Initialize current image URL from storage location
    if (widget.storageLocation != null) {
      _currentImageUrl = widget.storageLocation!.storageImage.value;
      if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
        debugPrint("🔍 Current image URL: $_currentImageUrl");
      }
    }

    // Initialize filtered employees
    _filteredEmployees = _currentEmployees;

    // Add search listener
    _searchController.addListener(_filterEmployees);

    debugPrint(
      'EditStorageLocationDetails initialized with image: $_currentImageUrl',
    );
  }

  Future<void> _selectImage() async {
    await _pickImageFromGallery();
  }

  /// Pick image from gallery
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
          _imageChanged = true;
        });

        debugPrint("🔍 New image selected: ${pickedFile.path}");
      }
    } catch (e) {
      debugPrint('Error selecting image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Remove selected image (sets to null, will delete from storage when saved)
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _currentImageUrl = null;
      _imageChanged = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image will be removed when you save changes'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        // If search is empty, show all employees
        _filteredEmployees = List.from(_currentEmployees);
      } else {
        // Filter employees by name (both Arabic and English)
        _filteredEmployees = _currentEmployees.where((employee) {
          // Get English name
          final nameEn = [employee.firstName, employee.lastName]
              .where((x) => (x ?? '').trim().isNotEmpty)
              .join(' ')
              .trim()
              .toLowerCase();

          // Get Arabic name
          final nameAr = [employee.firstNameInArabic, employee.lastNameInArabic]
              .where((x) => (x ?? '').trim().isNotEmpty)
              .join(' ')
              .trim()
              .toLowerCase();

          // Check if query matches English name, Arabic name, or email
          return nameEn.contains(query) ||
              nameAr.contains(query) ||
              (employee.email ?? '').toLowerCase().contains(query) ||
              (employee.firstName ?? '').toLowerCase().contains(query) ||
              (employee.lastName ?? '').toLowerCase().contains(query) ||
              (employee.firstNameInArabic ?? '').toLowerCase().contains(
                    query,
                  ) ||
              (employee.lastNameInArabic ?? '').toLowerCase().contains(
                    query,
                  );
        }).toList();
      }
    });

    debugPrint("🔍 Search query: '$query'");
    debugPrint("🔍 Filtered employees: ${_filteredEmployees.length}");
  }

  void _filterEmployeesByDepartment() {
    setState(() {
      if (selectedDepartment == null || selectedDepartment!.isEmpty) {
        // If no department selected, show search results
        _filterEmployees();
      } else {
        // Filter by both search query and department
        final query = _searchController.text.toLowerCase().trim();

        _filteredEmployees = _currentEmployees.where((employee) {
          // Check department match
          bool departmentMatch = employee.departmentId == selectedDepartment;

          // If there's no search query, just filter by department
          if (query.isEmpty) {
            return departmentMatch;
          }

          // If there's a search query, filter by both department and name
          final nameEn = [employee.firstName, employee.lastName]
              .where((x) => (x ?? '').trim().isNotEmpty)
              .join(' ')
              .trim()
              .toLowerCase();

          final nameAr = [employee.firstNameInArabic, employee.lastNameInArabic]
              .where((x) => (x ?? '').trim().isNotEmpty)
              .join(' ')
              .trim()
              .toLowerCase();

          bool nameMatch = nameEn.contains(query) ||
              nameAr.contains(query) ||
              (employee.email ?? '').toLowerCase().contains(query) ||
              (employee.firstName ?? '').toLowerCase().contains(query) ||
              (employee.lastName ?? '').toLowerCase().contains(query) ||
              (employee.firstNameInArabic ?? '').toLowerCase().contains(
                    query,
                  ) ||
              (employee.lastNameInArabic ?? '').toLowerCase().contains(
                    query,
                  );

          return departmentMatch && nameMatch;
        }).toList();
      }
    });
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

  /// Populate form fields with storage location data from previous screen or model
  void _populateStorageLocationData() {
    Map<String, String> data;

    // If storageLocation model is provided, convert it to the expected format
    if (widget.storageLocation != null) {
      final location = widget.storageLocation!;
      debugPrint(
          "🔍 Populating data from storage location: ${location.name.value}");
      debugPrint("🔍 Employee data in location: ${location.employee.value}");

      data = {
        'storageLocationId': location.id.value,
        'country': location.country.value,
        'stateOrProvince': location.stateOrProvince.value,
        'city': location.city.value,
        'postalCode': location.postalCode.value,
        'branchName': location.branchName.value,
        'area': location.area.value,
        'locationType':
            location.locationType.value, // Use actual value from model
        'assignedDepartment': location.assignedDepartment.value,
        'storageCapacity': location.storageCapacity.value.toString(),
        'unit': location.capacityUnit.value,
        'accessLevel': location.accessLevel.value,
        'equipmentAvailable': location
            .equipmentAvailable.value, // This is a String from your model
        'conditionOfStorage': location.conditionOfStorage.value,
        'additionalNote': location.additionalNote.value,
        'status': location.status.value,
      };

      // Convert employee data from storage location model
      _convertEmployeeDataFromModel(location);
      debugPrint(
        "🔍 Current employees after conversion: ${_currentEmployees.length}",
      );
    } else {
      // Use the existing storageLocationData if no model is provided
      data = widget.storageLocationData;
      // Use selected employees from widget
      _currentEmployees = List.from(widget.selectedEmployees);
    }

    // Populate form fields with the data
    storageLocationIdController.text = data['storageLocationId'] ?? '';
    countryController.text = data['country'] ?? '';
    stateOrProvinceController.text = data['stateOrProvince'] ?? '';
    cityController.text = data['city'] ?? '';
    postalCodeController.text = data['postalCode'] ?? '';
    branchNameController.text = data['branchName'] ?? '';
    areaController.text = data['area'] ?? '';
    storageCapacityController.text = data['storageCapacity'] ?? '';
    additionalNoteController.text = data['additionalNote'] ?? '';

    // Set dropdown values
    setState(() {
      selectLocationType = data['locationType']?.isNotEmpty == true
          ? data['locationType']
          : null;
      selectAssignedDepartment = data['assignedDepartment']?.isNotEmpty == true
          ? data['assignedDepartment']
          : null;
      selectUnit = data['unit']?.isNotEmpty == true ? data['unit'] : null;
      selectAccessLevel =
          data['accessLevel']?.isNotEmpty == true ? data['accessLevel'] : null;
      selectConditionOfStorage = data['conditionOfStorage']?.isNotEmpty == true
          ? data['conditionOfStorage']
          : null;
      status = (data['status']?.toLowerCase() == 'active');

      // Handle equipment - since equipmentAvailable is always a String in your model
      final equipmentData = data['equipmentAvailable'];
      if (equipmentData != null && equipmentData.isNotEmpty) {
        // Split comma-separated string into list
        selectedEquipmentList = equipmentData
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else {
        selectedEquipmentList = [];
      }
    });

    debugPrint(
        "🔍 Final employee count for display: ${_currentEmployees.length}");
    debugPrint("🔍 Status initialized to: $status (from: ${data['status']})");
    debugPrint("🔍 Equipment initialized: $selectedEquipmentList");
  }

  void _handleStatusToggle(bool newValue) async {
    // Only show confirmation dialog, don't update Firestore yet
    await showConfirmationDialog(
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json',
      title: 'Change Status',
      message:
          'Are you sure you want to change the status to ${newValue ? 'active' : 'inactive'}?',
      onConfirm: () async {
        // Only update local state, NOT Firestore
        setState(() {
          status = newValue;
        });

        showSuccessDialog(
          lottiePath:
              "assets/lottie_assets/main_lottie_assets/lot_status_approved.json",
          title: "Storage Location Edited",
          subtitle: "You Successfully Edited This Storage",
        );
      },
    );
  }

  /// Convert employee data from storage location model to EmployeeEntityPro list
  void _convertEmployeeDataFromModel(StorageLocation location) {
    try {
      debugPrint("🔍 Converting employee data from storage location");
      debugPrint(
          "🔍 Employee data type: ${location.employee.value.runtimeType}");
      debugPrint("🔍 Employee data: ${location.employee.value}");

      final List<dynamic> employeeDataList = location.employee.value;
      debugPrint("🔍 Employee list length: ${employeeDataList.length}");

      _currentEmployees = employeeDataList.map<EmployeeEntityPro>((empData) {
        debugPrint("🔍 Processing employee: $empData");

        if (empData is EmployeeEntityModel) {
          // If it's already an EmployeeEntityModel, convert to EmployeeEntityPro
          return EmployeeEntityPro(
            id: empData.id,
            email: empData.email,
            firstName: empData.firstName,
            lastName: empData.lastName,
            firstNameInArabic: empData.firstNameInArabic,
            lastNameInArabic: empData.lastNameInArabic,
            departmentId: empData.departmentId,
            title: empData.title,
            role: empData.role,
            gender: empData.gender,
          );
        } else if (empData is Map<String, dynamic>) {
          // If it's a Map, parse it
          return EmployeeEntityPro(
            id: empData['id'] ?? '',
            email: empData['email'] ?? '',
            firstName: empData['firstName'] ?? '',
            lastName: empData['lastName'] ?? '',
            firstNameInArabic: empData['firstNameInArabic'] ?? '',
            lastNameInArabic: empData['lastNameInArabic'] ?? '',
            departmentId: empData['departmentId'] ?? '',
            title: empData['title'] ?? '',
            role: empData['role'] ?? '',
            gender: empData['gender'] ?? '',
          );
        }
        return EmployeeEntityPro(); // fallback empty employee
      }).toList();

      debugPrint("🔍 Converted ${_currentEmployees.length} employees");
    } catch (e) {
      debugPrint('❌ Error converting employee data: $e');
      _currentEmployees = []; // fallback to empty list
    }
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
    _searchController.dispose();
    _searchController.removeListener(_filterEmployees);
    _searchController.dispose();
    super.dispose();
  }

  bool status = false;

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
          secondTitle:
              "${widget.storageLocation!.branchName.value} ${widget.storageLocation!.area.value}",
          onSecondTap: () {
            navigateTo(context, InventoryManagement());
          },
          thirdTitle: isEditMode
              ? S.of(context).storageLocationDetails
              : S.of(context).addingNewStorageLocation,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Details Section Header
                Row(
                  children: [
                    _buildSectionHeader(
                      S.of(context).locationDetails,
                      lightMode,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        // "Status" + toggle (Figma 4068:29225 / 4068:29396).
                        Text(
                          S.of(context).status,
                          style: StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        FlutterSwitch(
                          height: 22.0.sp,
                          width: 38.0.sp,
                          toggleSize: 17.sp,
                          value: status,
                          borderRadius: 20.0,
                          padding: 2.0,
                          activeColor: const Color(0xFFE5B800),
                          onToggle: (val) {
                            _handleStatusToggle(val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Padding(
                    padding:
                        StorageFieldSpec.cardPadding(startsWithLabel: false),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image section with tap to view full screen
                                GestureDetector(
                                  onTap: () {
                                    HapticController
                                        .low(); // list row: on the tap (X-117)
                                    // Show full-screen image if there's an image to show
                                    if (_selectedImage != null ||
                                        (_currentImageUrl?.isNotEmpty ==
                                            true)) {
                                      _showFullScreenImage();
                                    }
                                  },
                                  child: _buildImageEditSection(lightMode),
                                ),
                                const Spacer(),
                                // Follows the toggle above (Figma 4068:29205).
                                StorageStatusChip(
                                  status: status ? 'active' : 'inactive',
                                ),
                              ],
                            ),
                            _buildImageActionButton(lightMode),
                          ],
                        ),
                        SizedBox(height: StorageFieldSpec.rowGap.sp),
                        StorageFieldsRow(
                          left: _buildStorageLocationIdField(),
                          right: _readOnlyText(
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? 'اسم موقع التخزين'
                                : 'Storage Location Name',
                            widget.storageLocation?.name.value ?? '',
                          ),
                        ),
                        SizedBox(height: StorageFieldSpec.rowGap.sp),
                        _buildCountryAndStateRow(),
                        SizedBox(height: StorageFieldSpec.rowGap.sp),
                        _buildBranchNameAndAreaRow(),
                        SizedBox(height: StorageFieldSpec.rowGap.sp),
                        StorageFieldsRow(
                          left: _readOnlyText(
                            S.of(context).createdBy,
                            widget.storageLocation?.createdBy.value ?? '',
                          ),
                          right: StorageDateField(
                            label: S.of(context).dateAdded,
                            value: widget.storageLocation?.dateAdded.value,
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

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

  /// Build section header widget with consistent styling
  Widget _buildSectionHeader(String title, bool lightMode) {
    return Text(
      title,
      style: StyleText.fontSize16Weight600.copyWith(
        color: AppColors.blackButton,
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
        picked(selectAssignedDepartment) &&
        capacity != null &&
        capacity > 0 &&
        picked(selectUnit) &&
        picked(selectAccessLevel) &&
        selectedEquipmentList.isNotEmpty &&
        picked(selectConditionOfStorage);
  }

  /// Read-only text box for a value that has no controller of its own.
  Widget _readOnlyText(String label, String value) {
    return StorageTextField(
      label: label,
      controller: TextEditingController(text: value),
      readOnly: true,
    );
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
        value: selectAssignedDepartment,
        onChanged: (val) => setState(() => selectAssignedDepartment = val),
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

  Widget _buildSearchField() {
    Localizations.localeOf(context).languageCode == 'ar';

    return AppSearchTextField(
      controller: _searchController,
      fillColor: kStorageInnerFill,
      onChanged: (value) {
        // The filtering is handled by the listener, but you can add immediate feedback here
        _filterEmployees();
      },
    );
  }

  /// Build Assigned Employees Section
  Widget _buildAssignedEmployeesSection(bool lightMode) {
    debugPrint(
      "🔍 Building employee section with ${_currentEmployees.length} total employees",
    );
    debugPrint("🔍 Showing ${_filteredEmployees.length} filtered employees");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search and DropDown Department
        Row(
          children: [
            _buildSearchField(), // Use the custom search field
            SizedBox(width: 15.sp),
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
                    _filterEmployeesByDepartment();
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

        // Show search results info
        if (_searchController.text.isNotEmpty || selectedDepartment != null)
          Container(
            padding: EdgeInsets.all(8.sp),
            margin: EdgeInsets.only(bottom: 15.sp),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.blue, size: 16.sp),
                SizedBox(width: 8.sp),
                Expanded(
                  child: Text(
                    _searchController.text.isNotEmpty
                        ? "Showing ${_filteredEmployees.length} employees matching '${_searchController.text}'"
                        : "Filtering by department: ${_getDepartmentDisplayName(selectedDepartment ?? '', Localizations.localeOf(context).languageCode == 'ar')}",
                    style: TextStyle(color: Colors.blue[800], fontSize: 12.sp),
                  ),
                ),
                if (_searchController.text.isNotEmpty ||
                    selectedDepartment != null)
                  GestureDetector(
                    onTapDown: (_) => HapticController.high(),
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        selectedDepartment = null;
                        _filteredEmployees = List.from(_currentEmployees);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.sp),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child:
                          Icon(Icons.clear, color: AppColors.blue, size: 14.sp),
                    ),
                  ),
              ],
            ),
          ),

        // Debug information - only show when no results found
        if (_filteredEmployees.isEmpty && _currentEmployees.isNotEmpty)
          Container(
            padding: EdgeInsets.all(8.sp),
            margin: EdgeInsets.only(bottom: 15.sp),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Colors.orange),
            ),
            child: Text(
              "🔍 No employees found matching your search criteria.",
              style: TextStyle(color: Colors.orange[800], fontSize: 12.sp),
            ),
          ),

        // Debug information - only show when no employees at all
        if (_currentEmployees.isEmpty)
          Container(
            padding: EdgeInsets.all(8.sp),
            margin: EdgeInsets.only(bottom: 15.sp),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Colors.orange),
            ),
            child: Text(
              "🔍 Debug: No employees found. Check if employee data is properly loaded from storage location.",
              style: TextStyle(color: Colors.orange[800], fontSize: 12.sp),
            ),
          ),

        // Employee cards grid - use filtered employees
        _filteredEmployees.isEmpty
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
      itemCount: _filteredEmployees.length, // Use filtered employees
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
          context,
        ),
        crossAxisSpacing: 15.sp,
        mainAxisSpacing: 15.sp,
        mainAxisExtent: 84.h,
      ),
      itemBuilder: (context, index) {
        final employee = _filteredEmployees[index]; // Use filtered employees
        final originalIndex = _currentEmployees.indexOf(
          employee,
        ); // Get original index for removal
        return _buildEnhancedEmployeeCard(employee, lightMode, originalIndex);
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

    // Department name lookup
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
              top: 15.h,
              right: 8.w,
              left: 8.w,
              bottom: 10.h,
            ),
            child: Row(
              children: [
                // Avatar
                Padding(
                  padding: EdgeInsets.only(bottom: 15.h),
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
                Expanded(
                  // Add Expanded to prevent overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        displayName.isNotEmpty ? displayName : 'Employee',
                        style: StyleText.fontSize12Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),

                      // Department
                      Text(
                        departmentName,
                        style: StyleText.fontSize10Weight400.copyWith(
                          color: AppColors.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),

                      // Role/Title
                      Text(
                        displayTitle.isNotEmpty ? displayTitle : 'Employee',
                        style: StyleText.fontSize10Weight400.copyWith(
                          color: AppColors.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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

  String _getDepartmentDisplayName(String departmentId, bool isArabic) {
    // Create a simple map that converts department IDs/numbers to names
    final Map<String, Map<String, String>> departmentMapping = {
      '1': {'en': 'Marketing', 'ar': 'التسويق'},
      '2': {'en': 'Sales', 'ar': 'المبيعات'},
      '3': {'en': 'HR', 'ar': 'شؤون الموظفين'},
      '4': {'en': 'Executive', 'ar': 'الإدارة التنفيذية'},
      '5': {'en': 'Customer Support', 'ar': 'دعم العملاء'},
      '6': {'en': 'Operations', 'ar': 'العمليات'},
      '7': {'en': 'Finance', 'ar': 'المالية'},
      '8': {'en': 'Information Technology', 'ar': 'تقنية المعلومات'},
      '9': {'en': 'Human Resources', 'ar': 'الموارد البشرية'},
      '10': {'en': 'Data Management', 'ar': 'إدارة البيانات'},
      '11': {'en': 'Compliance & Legal', 'ar': 'الامتثال والقانون'},
      '12': {'en': 'Software', 'ar': 'البرمجيات'},

      // Also handle string-based department IDs
      'marketing': {'en': 'Marketing', 'ar': 'التسويق'},
      'sales': {'en': 'Sales', 'ar': 'المبيعات'},
      'hr': {'en': 'HR', 'ar': 'شؤون الموظفين'},
      'executive': {'en': 'Executive', 'ar': 'الإدارة التنفيذية'},
      'customerSupport': {'en': 'Customer Support', 'ar': 'دعم العملاء'},
      'operations': {'en': 'Operations', 'ar': 'العمليات'},
      'finance': {'en': 'Finance', 'ar': 'المالية'},
      'informationTechnology': {
        'en': 'Information Technology',
        'ar': 'تقنية المعلومات',
      },
      'humanResources': {'en': 'Human Resources', 'ar': 'الموارد البشرية'},
      'dataManagement': {'en': 'Data Management', 'ar': 'إدارة البيانات'},
      'complianceAndLegal': {
        'en': 'Compliance & Legal',
        'ar': 'الامتثال والقانون',
      },
      'software': {'en': 'Software', 'ar': 'البرمجيات'},
    };

    // Look up the department
    final department = departmentMapping[departmentId.toString().toLowerCase()];

    if (department != null) {
      return department[isArabic ? 'ar' : 'en'] ?? 'Unknown Department';
    }

    // Fallback for unknown departments
    return isArabic ? 'قسم غير محدد' : 'Unknown Department';
  }

  /// Get department display name

  /// Remove employee from the list
  void _removeEmployee(int originalIndex) {
    setState(() {
      final employeeToRemove = _currentEmployees[originalIndex];
      _currentEmployees.removeAt(originalIndex);

      // Also remove from filtered list if it exists there
      _filteredEmployees.removeWhere((emp) => emp == employeeToRemove);
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
  void _updateEmployeeRole(int originalIndex, String newRole) {
    debugPrint(
      'Updated employee ${_currentEmployees[originalIndex].firstName} role to: $newRole',
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
          function: () => Navigator.pop(context),
          textStyle: storageDiscardTextStyle,
          width: 150.sp,
          color: storageDiscardColor,
        ),
        const Spacer(),
        IgnorePointer(
          ignoring: !_isFormComplete,
          child: customButton(
            title: S.of(context).save,
            function: _updateStorageLocation,
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
      'assignedDepartment': selectAssignedDepartment ?? '',
      'storageCapacity': storageCapacityController.text,
      'unit': selectUnit ?? '',
      'accessLevel': selectAccessLevel ?? '',
      'equipmentAvailable': selectedEquipmentList.join(
        ',',
      ), // Convert List to comma-separated string
      'conditionOfStorage': selectConditionOfStorage ?? '',
      'additionalNote': additionalNoteController.text,
      'status': status == true ? "active" : "inactive",
    };
  }

  Widget _buildImageEditSection(bool lightMode) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTapDown: hapticDown(_selectImage, HapticLevel.low),
              onTap: _selectImage, // Always allow tap to select/change image
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: lightMode ? Color(0xffF5F5F5) : AppColors.background,
                  border: (_selectedImage != null ||
                          (_currentImageUrl?.isNotEmpty == true))
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: _buildImageContent(lightMode),
              ),
            ),
          ],
        ),

        // Camera/Remove button overlay
      ],
    );
  }

  /// Build image content based on current state
  /// Build image content based on current state
  Widget _buildImageContent(bool lightMode) {
    debugPrint(
      "🖼️ Building image content - Selected: ${_selectedImage != null}, Current URL: $_currentImageUrl",
    );

    // Priority: New selected image > Current URL > Placeholder
    if (_selectedImage != null) {
      // Show newly selected image
      return ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Image.file(
          _selectedImage!,
          width: 60.w,
          height: 60.h,
          fit: BoxFit.cover,
        ),
      );
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      debugPrint("🖼️ Loading network image: $_currentImageUrl");
      // Show current image from Firestore using regular Image.network
      return ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Image.network(
          _currentImageUrl!,
          width: 60.w,
          height: 60.h,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: lightMode ? Color(0xffF5F5F5) : AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: CircleProgressMaster.inline(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ Error loading image: $error');
            return _buildDefaultImagePlaceholder(lightMode);
          },
          // Add headers to handle caching and CORS issues
          headers: const {'Cache-Control': 'no-cache'},
        ),
      );
    } else {
      // Show placeholder
      debugPrint("🖼️ Showing placeholder");
      return _buildDefaultImagePlaceholder(lightMode);
    }
  }

  /// Build default image placeholder
  Widget _buildDefaultImagePlaceholder(bool lightMode) {
    return Center(
      child: CustomSvgImage(
        assetPath:
            "assets/icons_assets/main_icons_assets/ic_building_office.svg",
        width: 30.w,
        height: 30.h,
        color: AppColors.blackButton,
      ),
    );
  }

  /// Build camera/remove action button
  Widget _buildImageActionButton(bool lightMode) {
    final hasImage =
        _selectedImage != null || (_currentImageUrl?.isNotEmpty == true);

    return Positioned(
      left: 50.w,
      top: hasImage ? 40.h : 40.h,
      child: GestureDetector(
        onTap: withHaptic(
            hasImage ? _removeImage : _selectImage, HapticLevel.high),
        child: Container(
          width: 20.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: hasImage ? Colors.red : AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: hasImage
                ? Icon(Icons.remove, color: Colors.white, size: 12.sp)
                : CustomSvgImage(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_media_attach_square.svg",
                    width: 12.w,
                    height: 12.h,
                    fit: BoxFit.scaleDown,
                    color: AppColors.textButton,
                  ),
          ),
        ),
      ),
    );
  }

  /// Updated full screen image method
  void _showFullScreenImage() {
    if (_selectedImage == null &&
        (_currentImageUrl == null || _currentImageUrl!.isEmpty)) {
      return; // No image to show
    }

    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black87,
          insetPadding: EdgeInsets.all(20.sp),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.contain)
                      : Image.network(
                          _currentImageUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircleProgressMaster.inline(
                                color: Colors.white,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 48.sp,
                                  ),
                                  SizedBox(height: 16.sp),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          headers: const {'Cache-Control': 'no-cache'},
                        ),
                ),
              ),
              // Close button
              Positioned(
                top: 20.sp,
                right: 20.sp,
                child: GestureDetector(
                  onTapDown: (_) => HapticController.high(),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8.sp),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Update existing storage location
  void _updateStorageLocation() async {
    if (widget.storageLocation == null) return;

    await showConfirmationDialog(
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json',
      title: 'Update Storage Location',
      message:
          'Are you sure you want to update this storage location with all changes?',
      onConfirm: () async {
        final String userEmail = InventoryPaths.userEmail;

        try {
          // The app's own loader (66-circle_progress.dart). It sits on the
          // ROOT navigator, so it is closed with _closeLoader() — never with
          // Navigator.of(context).pop(), which pops THIS PAGE off the inventory
          // module's nested navigator.
          showLoadingIndicator();

          String imageUrl = widget.storageLocation!.storageImage
              .value; // Keep existing URL by default

          // Handle image changes
          if (_imageChanged) {
            if (_selectedImage != null) {
              // Upload new image
              debugPrint('Uploading new image to Firebase Storage...');

              final uploadedImageUrl =
                  await StorageImageService.uploadStorageLocationImage(
                imageFile: _selectedImage!,
                userEmail: userEmail,
                storageLocationId: widget.storageLocation!.id.value,
              );

              if (uploadedImageUrl != null) {
                // Delete old image if it exists
                if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
                  await StorageImageService.deleteStorageLocationImage(
                    _currentImageUrl!,
                  );
                }
                imageUrl = uploadedImageUrl;
                debugPrint('New image uploaded successfully: $imageUrl');
              } else {
                throw Exception('Failed to upload new image');
              }
            } else {
              // User removed image - delete from storage and clear URL
              if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
                await StorageImageService.deleteStorageLocationImage(
                  _currentImageUrl!,
                );
              }
              imageUrl = ''; // Clear image URL
              debugPrint('Image removed successfully');
            }
          }

          final form = _collectCurrentStorageLocationData();

          // Query Firestore to find the actual document ID by storage location ID
          final querySnapshot = await FirebaseFirestore.instance
              .collection("Demo")
              .doc(InventoryPaths.companyId)
              .collection("Storage Location")
              .where(
                'id.value',
                isEqualTo: widget.storageLocation!.id.value,
              )
              .limit(1)
              .get();

          if (querySnapshot.docs.isEmpty) {
            throw Exception(
              'Could not find storage location document in Firestore',
            );
          }

          final firestoreDocId = querySnapshot.docs.first.id;
          debugPrint('🔍 Using Firestore document ID: $firestoreDocId');
          debugPrint(
            '🔍 Storage location ID from form: ${widget.storageLocation!.id.value}',
          );

          // Update the existing storage location with new data
          final updatedStorage = StorageLocation.fromJson({
            'id': {
              'value': widget.storageLocation!.id.value,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'name': {
              'value': form['branchName'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            'storageImage': {
              'value': imageUrl,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
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
              'value': widget.storageLocation!.createdBy.value,
              'timestamp': widget.storageLocation!.createdBy.timestamp,
            },
            'dateAdded': {
              'value': widget.storageLocation!.dateAdded.value,
              'timestamp': widget.storageLocation!.dateAdded.timestamp,
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
              'value':
                  _currentEmployees.map((e) => mapToModel(e).toJson()).toList(),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
          });

          // Use your existing update method with the Firestore document ID
          await StorageLocationService.update(
            userEmail: userEmail,
            docId: firestoreDocId, // Use the actual Firestore document ID
            model: updatedStorage,
          );

          _closeLoader();

          // Show success dialog
          await showSuccessDialog(
            lottiePath:
                'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
            title: 'Storage Location Updated',
            subtitle: 'Storage location has been updated successfully!',
          );

          // Navigate back
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    InventoryManagement(initialFilter: 'Storage Locations'),
              ),
              (route) => false,
            );
          }
        } catch (e) {
          _closeLoader();

          debugPrint('❌ Update error: $e');

          if (!mounted) return;
          await CustomDialogManager.showMessage(
            context: context,
            lottiePath:
                'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
            title: S.of(context).error,
            subtitle: S.of(context).failedToUpdateStorageLocation,
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
                  lottiePath,
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
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
