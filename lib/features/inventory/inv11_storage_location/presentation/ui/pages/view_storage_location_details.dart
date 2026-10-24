import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/inventory/domain/models/storage_location_model.dart';
import 'package:knowticed_plus/features/inventory/presentation/controller/product_cubit.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/pages/edit_storage_location_details_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/storage_location_form_kit.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

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

class StorageLocationDetails extends StatefulWidget {
  final Map<String, String> storageLocationData;
  final List<EmployeeEntityPro> selectedEmployees;
  final StorageLocation?
      storageLocation; // Add this parameter for existing storage location

  const StorageLocationDetails({
    super.key,
    this.storageLocationData = const {},
    this.selectedEmployees = const [],
    this.storageLocation, // Add this parameter
  });

  @override
  State<StorageLocationDetails> createState() => _StorageLocationDetailsState();
}

class _StorageLocationDetailsState extends State<StorageLocationDetails> {
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

    // Initialize filtered employees
    _filteredEmployees = _currentEmployees;

    // Add search listener
    _searchController.addListener(_filterEmployees);

    debugPrint('StorageLocationDetails received:');
    if (widget.storageLocation != null) {
      debugPrint(
          'Storage Location Model: ${widget.storageLocation!.name.value}');
    } else {
      debugPrint('Storage Location Data: ${widget.storageLocationData}');
    }
    debugPrint('Selected Employees: ${_currentEmployees.length}');
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
        'locationType': location
            .locationType.value, // Add this field to your model if needed
        'assignedDepartment': location.assignedDepartment.value,
        'storageCapacity': location.storageCapacity.value.toString(),
        'unit': location.capacityUnit.value,
        'accessLevel': location.accessLevel.value,
        'equipmentAvailable': location.equipmentAvailable.value,
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
      selectSupplier = data['assignedDepartment']?.isNotEmpty == true
          ? data['assignedDepartment']
          : null;
      selectUnit = data['unit']?.isNotEmpty == true ? data['unit'] : null;
      selectAccessLevel =
          data['accessLevel']?.isNotEmpty == true ? data['accessLevel'] : null;
      selectEquipmentAvailable = data['equipmentAvailable']?.isNotEmpty == true
          ? data['equipmentAvailable']
          : null;
      selectConditionOfStorage = data['conditionOfStorage']?.isNotEmpty == true
          ? data['conditionOfStorage']
          : null;
    });

    debugPrint(
        "🔍 Final employee count for display: ${_currentEmployees.length}");
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

  /// 0 = Storage Location Details, 1 = Stored Products.
  int _selectedTab = 0;

  /// Products whose storage allocations include this location.
  List<({ProductModel product, String quantity})> _storedProducts(
    List<ProductModel> products,
  ) {
    final String locationId = widget.storageLocation?.id.value ?? '';
    if (locationId.isEmpty) return const [];
    final result = <({ProductModel product, String quantity})>[];
    for (final p in products) {
      for (final a in p.getStorageAllocations()) {
        if ('${a['storageLocationId'] ?? ''}' == locationId) {
          result.add((product: p, quantity: '${a['quantity'] ?? ''}'));
          break;
        }
      }
    }
    return result;
  }

  Widget _buildStoredProducts(bool lightMode) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is! ProductLoaded) {
          if (state is! ProductLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.read<ProductCubit>().loadProducts();
            });
          }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.sp),
            child: const Center(child: CircleProgressMaster()),
          );
        }
        final items = _storedProducts(state.products);
        return StorageSection(
          title: S.of(context).storedProducts,
          child: items.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.sp),
                  child: Center(
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? 'لا توجد منتجات مخزنة في هذا الموقع'
                          : 'No products are stored in this location yet',
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
                            context),
                    crossAxisSpacing: 15.sp,
                    mainAxisSpacing: 15.sp,
                    mainAxisExtent: 80.sp,
                  ),
                  itemBuilder: (context, i) =>
                      _storedProductCard(items[i], lightMode),
                ),
        );
      },
    );
  }

  Widget _storedProductCard(
    ({ProductModel product, String quantity}) item,
    bool lightMode,
  ) {
    final Color primaryText = AppColors.blackButton;
    final Color secondaryText = AppColors.secondaryText;
    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: kStorageInnerFill,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg',
              width: 36.r,
              height: 36.r,
              fit: BoxFit.scaleDown,
              color: primaryText,
            ),
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.product.productName.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: primaryText, height: 1.25),
                ),
                Text(
                  item.product.category.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: secondaryText, height: 1.4),
                ),
                Text(
                  '${S.of(context).quantity}: ${item.quantity}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: secondaryText, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          secondTitle:
              "${widget.storageLocation?.branchName.value ?? ''} ${widget.storageLocation?.area.value ?? ''}"
                  .trim(),
          onSecondTap: () {
            navigateTo(context, InventoryManagement());
          },
          thirdTitle: S.of(context).storageLocationDetails,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs + Edit on one row (Figma 4068:28934 / 28935 / 28930).
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: StorageTabs(
                        labels: [
                          S.of(context).storageLocationDetails,
                          S.of(context).storedProducts,
                        ],
                        selected: _selectedTab,
                        onChanged: (i) => setState(() => _selectedTab = i),
                      ),
                    ),
                    if (_selectedTab == 0)
                      customButtonWithSvg(
                        title: S.of(context).edit,
                        function: () {
                          navigateTo(
                            context,
                            EditStorageLocationDetailsToggle(
                              storageLocation: widget.storageLocation,
                              storageLocationData:
                                  _collectCurrentStorageLocationData(),
                              selectedEmployees: _currentEmployees,
                            ),
                          );
                        },
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        fixedWidth: 135.sp,
                        svgColor: AppColors.textButton,
                        image:
                            "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
                        widthImage: 19.r,
                        heightImage: 19.r,
                        colorBorder: Colors.transparent,
                        color: AppColors.primary,
                        space: 8.sp,
                      ),
                  ],
                ),
                SizedBox(height: 20.sp),

                if (_selectedTab == 0) ...[
                  // ── Location details ─────────────────────────────────────
                  StorageSection(
                    title: S.of(context).locationDetails,
                    startsWithLabel: false, // opens with the photo + status
                    child: StorageFieldsColumn(
                      children: [
                        _buildImageDisplaySection(lightMode),
                        StorageFieldsRow(
                          left: StorageTextField(
                            label: S.of(context).storageLocationId,
                            controller: storageLocationIdController,
                            readOnly: true,
                            textDirection: ui.TextDirection.ltr,
                          ),
                          right: _readOnlyText(
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? 'اسم موقع التخزين'
                                : 'Storage Location Name',
                            widget.storageLocation?.name.value ??
                                branchNameController.text,
                          ),
                        ),
                        StorageFieldsRow(
                          left: StorageTextField(
                            label: S.of(context).country,
                            controller: countryController,
                            readOnly: true,
                          ),
                          right: StorageTextField(
                            label: S.of(context).stateOrProvince,
                            controller: stateOrProvinceController,
                            readOnly: true,
                          ),
                        ),
                        StorageFieldsRow(
                          left: StorageTextField(
                            label: S.of(context).city,
                            controller: cityController,
                            readOnly: true,
                          ),
                          right: StorageTextField(
                            label: S.of(context).postalCode,
                            controller: postalCodeController,
                            readOnly: true,
                          ),
                        ),
                        StorageFieldsRow(
                          left: StorageTextField(
                            label: S.of(context).branchName,
                            controller: branchNameController,
                            readOnly: true,
                          ),
                          right: StorageTextField(
                            label: S.of(context).area,
                            controller: areaController,
                            readOnly: true,
                          ),
                        ),
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
                  SizedBox(height: 20.sp),

                  // ── Storage location details ─────────────────────────────
                  StorageSection(
                    title: S.of(context).storageLocationDetails,
                    child: StorageFieldsColumn(
                      children: [
                        StorageFieldsRow(
                          left: StorageReadOnlyDropdown(
                            label: S.of(context).locationType,
                            text: selectLocationType ?? '',
                          ),
                          right: StorageReadOnlyDropdown(
                            label: S.of(context).assignedDepartment,
                            text: selectSupplier ?? '',
                          ),
                        ),
                        StorageFieldsRow(
                          left: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: StorageTextField(
                                  label: S.of(context).storageCapacity,
                                  controller: storageCapacityController,
                                  readOnly: true,
                                  textDirection: ui.TextDirection.ltr,
                                ),
                              ),
                              SizedBox(width: 10.sp),
                              SizedBox(
                                width: storageUnitBoxWidth(context),
                                child: CustomDropdown<String>(
                                  hint: selectUnit ?? S.of(context).unit,
                                  items: const [],
                                  enabled: false,
                                  height: StorageFieldSpec.height,
                                  triggerPadding:
                                      StorageFieldSpec.contentPadding,
                                  suffixIconPadding:
                                      StorageFieldSpec.suffixPadding,
                                  borderRadius: StorageFieldSpec.borderRadius,
                                ),
                              ),
                            ],
                          ),
                          right: StorageReadOnlyDropdown(
                            label: S.of(context).accessLevel,
                            text: selectAccessLevel ?? '',
                          ),
                        ),
                        StorageFieldsRow(
                          left: StorageReadOnlyDropdown(
                            label: S.of(context).equipmentAvailable,
                            text: selectEquipmentAvailable ?? '',
                          ),
                          right: StorageReadOnlyDropdown(
                            label: S.of(context).conditionOfStorage,
                            text: selectConditionOfStorage ?? '',
                          ),
                        ),
                        StorageTextField(
                          label: S.of(context).additionalNote,
                          controller: additionalNoteController,
                          readOnly: true,
                          multiline: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.sp),

                  // ── Employee assigned information ────────────────────────
                  StorageSection(
                    title: S.of(context).employeeAssignedInformation,
                    startsWithLabel: false, // opens with the search bar
                    child: _buildAssignedEmployeesSection(lightMode),
                  ),
                  SizedBox(height: 20.sp),
                ] else ...[
                  _buildStoredProducts(lightMode),
                  SizedBox(height: 20.sp),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Read-only text box for a value that has no controller of its own.
  Widget _readOnlyText(String label, String value) {
    return StorageTextField(
      label: label,
      controller: TextEditingController(text: value),
      readOnly: true,
    );
  }

  /// Build enhanced image display section that shows the stored image from Firestore
  Widget _buildImageDisplaySection(bool lightMode) {
    final String imageUrl = widget.storageLocation?.storageImage.value ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTapDown: (_) => HapticController.low(),
          onTap: () {
            // Show full-screen image preview when tapped
            if (imageUrl.isNotEmpty) {
              _showFullScreenImage(imageUrl);
            }
          },
          child: Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: lightMode ? Color(0xffF5F5F5) : AppColors.background,
              borderRadius: BorderRadius.circular(4.r),
              border: imageUrl.isNotEmpty
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: imageUrl.isNotEmpty
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.network(
                          imageUrl,
                          width: 60.r,
                          height: 60.r,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircleProgressMaster.inline(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Error loading image: $error');
                            return _buildDefaultImagePlaceholder(lightMode);
                          },
                        ),
                      ),
                      // Overlay indicator that image can be tapped
                      Positioned(
                        bottom: 2.h,
                        right: 2.w,
                        child: Container(
                          padding: EdgeInsets.all(2.sp),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildDefaultImagePlaceholder(lightMode),
          ),
        ),
        Spacer(),
        StorageStatusChip(
          status: widget.storageLocation?.status.value ?? '',
        ),
      ],
    );
  }

  /// Build default image placeholder when no image is available
  Widget _buildDefaultImagePlaceholder(bool lightMode) {
    return Center(
      child: CustomSvgImage(
        assetPath: kStorageLocationPlaceholderIcon,
        width: 40.r,
        height: 40.r,
        color: AppColors.blackButton,
        fit: BoxFit.scaleDown,
      ),
    );
  }

  /// Show full-screen image preview
  void _showFullScreenImage(String imageUrl) {
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
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircleProgressMaster.inline(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
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
              // Image info overlay
              Positioned(
                bottom: 20.sp,
                left: 20.sp,
                right: 20.sp,
                child: Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Storage Location Image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.sp),
                      Text(
                        '${widget.storageLocation!.branchName.value} - ${widget.storageLocation!.area.value}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      Text(
                        'Pinch to zoom • Drag to pan • Tap outside to close',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
            _buildSearchField(),
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
        // if (_searchController.text.isNotEmpty || selectedDepartment != null)
        //   Container(
        //     padding: EdgeInsets.all(8.sp),
        //     margin: EdgeInsets.only(bottom: 15.sp),
        //     decoration: BoxDecoration(
        //       color: Colors.blue.withOpacity(0.1),
        //       borderRadius: BorderRadius.circular(4.r),
        //       border: Border.all(color: Colors.blue.withOpacity(0.3)),
        //     ),
        //     child: Row(
        //       children: [
        //         Icon(Icons.info_outline, color: Colors.blue, size: 16.sp),
        //         SizedBox(width: 8.sp),
        //         Expanded(
        //           child: Text(
        //             _searchController.text.isNotEmpty
        //                 ? "Showing ${_filteredEmployees.length} employees matching '${_searchController.text}'"
        //                 : "Filtering by department: ${_getDepartmentDisplayName(selectedDepartment ?? '', Localizations.localeOf(context).languageCode == 'ar')}",
        //             style: TextStyle(color: Colors.blue[800], fontSize: 12.sp),
        //           ),
        //         ),
        //         if (_searchController.text.isNotEmpty || selectedDepartment != null)
        //           GestureDetector(
        //             onTap: () {
        //               setState(() {
        //                 _searchController.clear();
        //                 selectedDepartment = null;
        //                 _filteredEmployees = List.from(_currentEmployees);
        //               });
        //             },
        //             child: Container(
        //               padding: EdgeInsets.all(4.sp),
        //               decoration: BoxDecoration(
        //                 color: Colors.blue.withOpacity(0.2),
        //                 borderRadius: BorderRadius.circular(12.r),
        //               ),
        //               child: Icon(Icons.clear, color: Colors.blue, size: 14.sp),
        //             ),
        //           ),
        //       ],
        //     ),
        //   ),

        // Debug information - only show when no results found

        // Employee cards grid - use filtered employees
        _filteredEmployees.isEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomEmptyState(
                    lottiePath:
                        'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
                    size: 150,
                    verticalPadding: 0,
                  ),
                ],
              )
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
        mainAxisExtent: 70.h,
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

    return Container(
      decoration: BoxDecoration(
        color: kStorageInnerFill,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 10.h, right: 10.w, left: 10.w),
        child: Stack(
          children: [
            Row(
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
                Column(
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
                    SizedBox(height: 0.h),

                    // Department
                    Text(
                      departmentName,
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.h),

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
              ],
            ),
            // Show role/position as text instead of dropdown
            Positioned(
              bottom: 9.h,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: lightMode ? Color(0xffF5F5F5) : AppColors.background,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  employee.role?.isNotEmpty == true
                      ? employee.role!
                      : 'Employee',
                  style: StyleText.fontSize10Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
      'equipmentAvailable': selectEquipmentAvailable ?? '',
      'conditionOfStorage': selectConditionOfStorage ?? '',
      'additionalNote': additionalNoteController.text,
      'status': "active",
    };
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
