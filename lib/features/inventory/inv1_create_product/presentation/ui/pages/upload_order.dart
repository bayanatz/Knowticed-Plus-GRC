import 'dart:ui' as ui;
import 'dart:developer';
import 'dart:io'; // ✅ Keep this for mobile/desktop

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/widgets/upload_order_data/validation.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/domain/models/storage_location_model.dart';
import 'package:knowticed_plus/features/inventory/presentation/controller/product_cubit.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/edit_storage_location_details/helper.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class ProductDetailsAssetsDesktopScreen extends StatefulWidget {
  final ProductModel productModel;
  final List<ProductModel> productModels;
  final int currentProductIndex;
  final bool isMultiProduct;
  final bool isConsumable; // ✅ ADD THIS LINE
  final Map<String, dynamic> orderData;
  final bool isEditMode; // Add this parameter

  const ProductDetailsAssetsDesktopScreen({
    super.key,
    required this.productModel,
    required this.productModels,
    required this.currentProductIndex,
    required this.isMultiProduct,
    required this.isConsumable, // ✅ ADD THIS PARAMETER
    required this.orderData,
    required this.isEditMode,
  });

  @override
  State<ProductDetailsAssetsDesktopScreen> createState() =>
      _ProductDetailsAssetsDesktopScreenState();
}

class _ProductDetailsAssetsDesktopScreenState
    extends State<ProductDetailsAssetsDesktopScreen> {
  List<StorageLocation> storageLocationModels = [];
  bool isLoadingStorageLocations = false;

  TextEditingController expectedLifetimeController = TextEditingController();
  TextEditingController reorderLevelController = TextEditingController();
  TextEditingController reorderQuantityController = TextEditingController();
  TextEditingController additionalNoteController = TextEditingController();
  TextEditingController productQuantityController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController orderDateController = TextEditingController();
  TextEditingController receivingDateController = TextEditingController();

  List<PlatformFile> attachmentFiles = []; // Changed from single file to list
  List<String> attachmentFileUrls = []; // Changed from single URL to list
  List<String> attachmentTitles = []; // Store custom titles for attachments

  @override
  void initState() {
    super.initState();

    debugPrint('🔍 INIT STATE DEBUG:');
    debugPrint('widget.isEditMode: ${widget.isEditMode}');
    debugPrint('widget.currentProductIndex: ${widget.currentProductIndex}');
    debugPrint('widget.productModels.length: ${widget.productModels.length}');

    final ProductModel currentProduct = widget.isEditMode
        ? widget.productModel
        : widget.productModels[widget.currentProductIndex];

    debugPrint('🔍 CURRENT PRODUCT DATA:');
    debugPrint('productName: ${currentProduct.productName.value}');
    debugPrint('expectedLifetime: ${currentProduct.expectedLifetime.value}');
    debugPrint('reorderLevel: ${currentProduct.reorderLevel.value}');
    debugPrint('reorderQuantity: ${currentProduct.reorderQuantity.value}');
    debugPrint('additionalNote: ${currentProduct.additionalNote.value}');
    debugPrint('productQuantity: ${currentProduct.productQuantity.value}');
    debugPrint('orderDate: ${currentProduct.orderDate.value}');
    debugPrint('receivingDate: ${currentProduct.receivingDate.value}');
    debugPrint(
        'storageRequirement: ${currentProduct.storageRequirement.value}');
    debugPrint('storageLocation: ${currentProduct.storageLocation.value}');
    debugPrint(
      'productSpecificationImage: ${currentProduct.productSpecificationImage.value}',
    );
    debugPrint(
        'productWarrantyImage: ${currentProduct.productWarrantyImage.value}');
    debugPrint('attachmentsImage: ${currentProduct.attachmentsImage.value}');

    _loadDataFromModel(currentProduct);
    _searchController.addListener(_onSearchChanged);

    if (widget.isEditMode &&
        widget.productModel.attachmentsImage.value.isNotEmpty) {
      // Split multiple URLs if they're stored as comma-separated
      attachmentFileUrls = widget.productModel.attachmentsImage.value
          .split(',')
          .where((url) => url.trim().isNotEmpty)
          .toList();

      // Initialize titles for existing attachments (you might want to store titles separately)
      for (int i = 0; i < attachmentFileUrls.length; i++) {
        attachmentTitles.add(
          _fileNameFromUrl(attachmentFileUrls[i]),
        ); // Use filename as default
      }
    }
    _loadStorageLocations();
  }

  Future<void> _loadStorageLocations() async {
    setState(() {
      isLoadingStorageLocations = true;
    });

    try {
      // Add userEmail parameter - you'll need to get the actual user email
      // Replace "user@example.com" with actual user email from your auth system
      final locations = await StorageLocationService.getStorageLocations(
        userEmail: InventoryPaths
            .userEmail, // Use the email from your Firebase screenshot
      );

      setState(() {
        storageLocationModels = locations;
        storageLocations = StorageLocationService.convertToDropdownItems(
          locations,
        );
        isLoadingStorageLocations = false;
      });

      // Debug: Print all loaded data
      debugPrint('🔍 Raw locations from Firebase: ${locations.length}');
      for (int i = 0; i < locations.length; i++) {
        debugPrint(
          'Location $i: id=${locations[i].id.value}, name=${locations[i].name.value}',
        );
      }

      debugPrint('🔍 Converted dropdown items: ${storageLocations.length}');
      for (int i = 0; i < storageLocations.length; i++) {
        debugPrint(
          'Item $i: key=${storageLocations[i]['key']}, value=${storageLocations[i]['value']}',
        );
      }

      // Check for actual duplicates
      final keyCount = <String, int>{};
      for (final item in storageLocations) {
        final key = item['key']!;
        keyCount[key] = (keyCount[key] ?? 0) + 1;
      }
      final duplicates = keyCount.entries.where((entry) => entry.value > 1);
      if (duplicates.isNotEmpty) {
        debugPrint(
          '❌ Duplicate keys found: ${duplicates.map((e) => '${e.key} (${e.value} times)').toList()}',
        );
      }

      debugPrint(
          '🔍 Loaded ${locations.length} storage locations from Firebase');

      if (widget.isEditMode) {
        final ProductModel currentProduct = widget.productModel;
        _loadStorageLocationsFromModel(currentProduct);
      }
    } catch (e) {
      setState(() {
        isLoadingStorageLocations = false;
        storageLocations = [];
      });

      debugPrint('❌ Failed to load storage locations: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load storage locations: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadDataFromModel(ProductModel model) {
    debugPrint('🔍 _loadDataFromModel CALLED:');
    debugPrint('Input model expectedLifetime: ${model.expectedLifetime.value}');
    debugPrint('Input model reorderLevel: ${model.reorderLevel.value}');

    // expectedLifetime comes as "12 hours" or "30 minutes"
    final rawLifetime = model.expectedLifetime.value.trim();
    debugPrint('Raw lifetime: "$rawLifetime"');

    if (rawLifetime.isNotEmpty) {
      final parts = rawLifetime.split(RegExp(r'\s+'));
      debugPrint('Lifetime parts: $parts');
      if (parts.isNotEmpty) {
        expectedLifetimeController.text = parts.first; // "12"
        debugPrint('Set expectedLifetimeController.text to: ${parts.first}');
        if (parts.length > 1) {
          selectedDurationUnit = parts[1]; // "hours"
          debugPrint('Set selectedDurationUnit to: ${parts[1]}');
        }
      }
    } else {
      expectedLifetimeController.clear();
      debugPrint('Cleared expectedLifetimeController (empty rawLifetime)');
    }

    reorderLevelController.text = model.reorderLevel.value;
    reorderQuantityController.text = model.reorderQuantity.value;
    additionalNoteController.text = model.additionalNote.value;
    productQuantityController.text = model.productQuantity.value;
    productNameController.text = model.productName.value;
    orderDateController.text = model.orderDate.value;
    receivingDateController.text = model.receivingDate.value;

    debugPrint('🔍 AFTER LOADING:');
    debugPrint(
      'expectedLifetimeController.text: "${expectedLifetimeController.text}"',
    );
    debugPrint('reorderLevelController.text: "${reorderLevelController.text}"');
    debugPrint(
      'reorderQuantityController.text: "${reorderQuantityController.text}"',
    );
    debugPrint(
        'additionalNoteController.text: "${additionalNoteController.text}"');
    debugPrint(
      'productQuantityController.text: "${productQuantityController.text}"',
    );
    debugPrint('productNameController.text: "${productNameController.text}"');
    debugPrint('orderDateController.text: "${orderDateController.text}"');
    debugPrint(
        'receivingDateController.text: "${receivingDateController.text}"');
  }

  bool _didDepsInit = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    debugPrint('🔍 didChangeDependencies CALLED');
    debugPrint('_didDepsInit: $_didDepsInit');

    if (_didDepsInit) {
      debugPrint('Already initialized, returning early');
      return;
    }

    _initStorageRequirementMappings();

    final ProductModel currentProduct = widget.isEditMode
        ? widget.productModel
        : widget.productModels[widget.currentProductIndex];

    debugPrint('🔍 didChangeDependencies - isEditMode: ${widget.isEditMode}');

    if (widget.isEditMode) {
      debugPrint('🔍 EDIT MODE - Loading storage requirements and locations');
      _loadStorageRequirementsFromModel(currentProduct);
      _loadStorageLocationsFromModel(currentProduct);

      // Show existing uploaded file URLs in edit mode
      specFileUrl = currentProduct.productSpecificationImage.value;
      warrantyFileUrl = currentProduct.productWarrantyImage.value;
      attachmentFileUrl = currentProduct.attachmentsImage.value;

      debugPrint('🔍 EDIT MODE - File URLs:');
      debugPrint('specFileUrl: $specFileUrl');
      debugPrint('warrantyFileUrl: $warrantyFileUrl');
      debugPrint('attachmentFileUrl: $attachmentFileUrl');
    }

    _didDepsInit = true;
  }

  void _loadStorageRequirementsFromModel(ProductModel model) {
    debugPrint('🔍 _loadStorageRequirementsFromModel CALLED');
    debugPrint(
        'Storage requirement value: "${model.storageRequirement.value}"');

    _selectedStorageRequirementKeys.clear();
    _selectedStorageRequirementLabels.clear();

    final raw = model.storageRequirement.value.trim();
    if (raw.isEmpty) {
      debugPrint('Storage requirement is empty, returning');
      return;
    }

    for (final key in raw.split(',')) {
      final k = key.trim();
      if (k.isEmpty) continue;
      _selectedStorageRequirementKeys.add(k);
      _selectedStorageRequirementLabels.add(_reqLabelByKey[k] ?? k);
      debugPrint(
        'Added storage requirement key: $k, label: ${_reqLabelByKey[k] ?? k}',
      );
    }

    debugPrint('Final selected keys: $_selectedStorageRequirementKeys');
    debugPrint('Final selected labels: $_selectedStorageRequirementLabels');
  }

  void _loadStorageLocationsFromModel(ProductModel model) {
    debugPrint('🔍 _loadStorageLocationsFromModel CALLED');
    debugPrint('Storage location value: "${model.storageLocation.value}"');

    if (model.storageLocation.value.isNotEmpty &&
        storageLocationModels.isNotEmpty) {
      final locations = model.storageLocation.value.split(';');
      debugPrint('Split locations: $locations');

      if (locations.isNotEmpty) {
        final firstLocation = locations.first.split(':');
        debugPrint('First location parts: $firstLocation');

        if (firstLocation.length == 2) {
          final locationName = firstLocation[0];

          // Find storage location by name and get its ID
          StorageLocation? storageLocationModel;
          try {
            storageLocationModel = storageLocationModels.firstWhere(
              (loc) => loc.name.value == locationName,
            );
          } catch (e) {
            storageLocationModel = null;
            debugPrint('Storage location not found: $locationName');
          }

          if (storageLocationModel != null) {
            defaultStorageLocation = storageLocationModel.id.value;
            defaultStorageQuantityController.text = firstLocation[1];

            debugPrint('Set default storage location: $defaultStorageLocation');
            debugPrint('Set default storage quantity: ${firstLocation[1]}');
          }
        }

        // Load additional locations
        for (int i = 1; i < locations.length; i++) {
          final locationParts = locations[i].split(':');
          debugPrint('Additional location $i parts: $locationParts');

          if (locationParts.length == 2) {
            final locationName = locationParts[0];
            StorageLocation? storageLocationModel;
            try {
              storageLocationModel = storageLocationModels.firstWhere(
                (loc) => loc.name.value == locationName,
              );
            } catch (e) {
              storageLocationModel = null;
            }

            if (storageLocationModel != null) {
              additionalStorageEntries.add({
                'selectedValue': storageLocationModel.id.value,
                'quantityController': TextEditingController(
                  text: locationParts[1],
                ),
              });

              debugPrint(
                'Added additional storage: key=${storageLocationModel.id.value}, quantity=${locationParts[1]}',
              );
            }
          }
        }
      }
    }
  }

  void _initStorageRequirementMappings() {
    final storageRequirementList = [
      {"key": "standard", "value": S.of(context).standardStorage},
      {
        "key": "temperatureControlled",
        "value": S.of(context).temperatureControlled,
      },
      {"key": "humidityControlled", "value": S.of(context).humidityControlled},
      {"key": "dry", "value": S.of(context).dryStorage},
      {"key": "flammable", "value": S.of(context).flammableStorage},
      {"key": "hazardous", "value": S.of(context).hazardousMaterialStorage},
      {"key": "secureAccess", "value": S.of(context).secureRestrictedAccess},
      {"key": "fragile", "value": S.of(context).fragileHandleWithCare},
      {"key": "outdoor", "value": S.of(context).outdoorStorage},
      {"key": "heavyDuty", "value": S.of(context).heavyDutyStorage},
      {
        "key": "radiationProtected",
        "value": S.of(context).radiationProtectedStorage,
      },
      {"key": "coldChain", "value": S.of(context).coldChainLogistics},
    ];

    _reqKeyByLabel = {
      for (final m in storageRequirementList) m['value']!: m['key']!,
    };
    _reqLabelByKey = {
      for (final m in storageRequirementList) m['key']!: m['value']!,
    };

    // If keys already loaded (from model) but labels empty, rebuild labels now:
    if (_selectedStorageRequirementLabels.isEmpty &&
        _selectedStorageRequirementKeys.isNotEmpty) {
      _selectedStorageRequirementLabels
        ..clear()
        ..addAll(
          _selectedStorageRequirementKeys.map((k) => _reqLabelByKey[k] ?? k),
        );
    }
  }

  ////////////////////////////// Controller ///////////////////////////////////////
  TextEditingController defaultStorageQuantityController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  ////////////////////////////// Controller /////////////////////////////////////

  ////////////////////////////// DropDown Var /////////////////////////////////////
  String selectedDurationUnit = "hours";
  String selectedStorageRequirement = "standard";

  ////////////////////////////// DropDown Var /////////////////////////////////////

  ////////////////////////////// Storage Content /////////////////////////////////////

  ValidationResult _performCompleteValidation() {
    final missingFields = <String>[];
    String? storageError;

    // Required field validations
    if (expectedLifetimeController.text.trim().isEmpty) {
      missingFields.add(S.of(context).expectedLifetime);
    }

    if (reorderLevelController.text.trim().isEmpty) {
      missingFields.add(S.of(context).reorderLevel);
    }

    if (reorderQuantityController.text.trim().isEmpty) {
      missingFields.add(S.of(context).reorderQuantity);
    }

    if (attachmentFiles.isEmpty && attachmentFileUrls.isEmpty) {}

    // if (orderDateController.text.trim().isEmpty) {
    //   missingFields.add(S.of(context).orderDate ?? "Order Date");
    // }
    //
    // if (receivingDateController.text.trim().isEmpty) {
    //   missingFields.add(S.of(context).receivingDate ?? "Receiving Date");
    // }

    if (specFileUrl == null || specFileUrl!.isEmpty) {
      missingFields.add(S.of(context).productSpecification);
    }

    // Storage requirements validation
    if (_selectedStorageRequirementKeys.isEmpty) {
      missingFields.add(S.of(context).storageRequirement);
    }

    // Storage location validation (conditional)
    storageError = _validateStorageLocations();
    if (storageError != null) {
      missingFields.add("Storage Location: $storageError");
    }

    return ValidationResult(
      isValid: missingFields.isEmpty,
      missingFields: missingFields,
      storageError: storageError,
    );
  }

  void _handleNextButtonPressed() async {
    final validationResult = _performCompleteValidation();

    if (!validationResult.isValid) {
      // Show custom validation dialog
      await showAppDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => ValidationDialog(
          title: S.of(context).incompleteForm,
          subtitle: S.of(context).completeRequiredFields,
          missingFields: validationResult.missingFields,
        ),
      );
      return;
    }

    // If validation passes, proceed with navigation
    final updatedModel = updatedProductModel();
    final updatedList = [...widget.productModels];

    if (widget.currentProductIndex < updatedList.length) {
      updatedList[widget.currentProductIndex] = updatedModel;
    } else {
      updatedList.add(updatedModel);
    }

    // Navigate to next screen
    navigateTo(
      context,
      UploadProductDetailsAssets(
        productModel: updatedModel,
        isEditMode: widget.isEditMode,
        productModels: updatedList,
        currentProductIndex: widget.currentProductIndex,
        isMultiProduct: widget.isMultiProduct,
        isConsumable: widget.isConsumable,
        orderData: widget.orderData,
      ),
    );
  }

  // 4. Enhanced storage validation method
  String? _validateStorageLocations() {
    final hasDefaultLocation =
        (defaultStorageLocation != null && defaultStorageLocation!.isNotEmpty);
    final hasAdditionalRows = additionalStorageEntries.isNotEmpty;

    // If no storage location is selected at all, it's allowed (nullable)
    if (!hasDefaultLocation && !hasAdditionalRows) {
      return null; // Valid - no storage specified
    }

    // If default location is selected
    if (hasDefaultLocation) {
      // If there are additional rows, default quantity is required
      if (hasAdditionalRows) {
        if (!_isPositiveInt(defaultStorageQuantityController.text)) {
          return "Default storage location requires a positive quantity";
        }
      }
      // If no additional rows, default quantity is optional (will be set to 1)
    }

    // Validate additional rows
    final locationsSeen = <String>{};

    // Add default location to seen set if it exists
    if (hasDefaultLocation) {
      locationsSeen.add(defaultStorageLocation!);
    }

    for (int i = 0; i < additionalStorageEntries.length; i++) {
      final entry = additionalStorageEntries[i];
      final selectedValue = entry['selectedValue'] as String?;
      final quantityController =
          entry['quantityController'] as TextEditingController?;
      final quantity = quantityController?.text.trim() ?? '';

      final hasLocation = selectedValue != null && selectedValue.isNotEmpty;
      final hasQuantity = quantity.isNotEmpty;

      // Skip completely empty rows
      if (!hasLocation && !hasQuantity) continue;

      // If row has content, both location and quantity are required
      if (!hasLocation) {
        return "Row ${i + 1}: Storage location is required";
      }

      if (!_isPositiveInt(quantity)) {
        return "Row ${i + 1}: Valid positive quantity is required";
      }

      // Check for duplicates
      if (locationsSeen.contains(selectedValue)) {
        final locationName = storageLocations.firstWhere(
          (loc) => loc['key'] == selectedValue,
          orElse: () => {'value': selectedValue},
        )['value']!;
        return "Duplicate location not allowed: $locationName";
      }

      locationsSeen.add(selectedValue);
    }

    return null; // All validations passed
  }

  // Default storage location (shown alone first)
  String? defaultStorageLocation;

  // Additional rows with quantity
  final List<Map<String, dynamic>> additionalStorageEntries = [];
  List<Map<String, String>> storageLocations =
      []; // Will be populated from Firebase

  ////////////////////////////// Storage Content /////////////////////////////////////

  ///////////////////////////// For PicImage /////////////////////////////////////////

  PlatformFile? productSpecificationFile;
  PlatformFile? productWarrantyFile;
  PlatformFile? attachmentFile;

  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      // Store locally for preview
      setState(() {
        if (type == 'spec') productSpecificationFile = file;
        if (type == 'warranty') productWarrantyFile = file;
        if (type == 'attachment') attachmentFile = file;
      });

      // Upload to Firebase through Cubit
      if (!mounted) return;
      context.read<ProductCubit>().uploadFile(file, type);
    }
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    return '${(bytes / 1024).ceil()} KB';
  }

  ///////////////////////////// For PicImage /////////////////////////////////////////
  ///////////////////////////// For PicImage /////////////////////////////////////////

  /////////////////////////////// Approval Cycle /////////////////////////////////////

  bool requireApproval = false;
  List<EmployeeEntity> filteredEmployees = [];
  List<EmployeeEntity> selectedEmployees = [];
  List<EmployeeEntity> allEmployees = []; // 🔥 This fixes your undefined error
  void toggleSelection(EmployeeEntity employee) {
    setState(() {
      if (selectedEmployees.contains(employee)) {
        selectedEmployees.remove(employee);
      } else {
        selectedEmployees.add(employee);
      }
    });
  }

  bool isSelected(EmployeeEntity employee) {
    return selectedEmployees.any((e) => e.id == employee.id);
  }

  String getDepartmentName(String departmentId, bool isEnglish) {
    final departmentsEn = {'dept1': 'HR', 'dept2': 'Engineering'};
    final departmentsAr = {'dept1': 'الموارد البشرية', 'dept2': 'الهندسة'};
    return isEnglish
        ? departmentsEn[departmentId] ?? ''
        : departmentsAr[departmentId] ?? '';
  }

  void _onSearchChanged() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      final selected = allEmployees
          .where((e) => selectedEmployees.any((s) => s.id == e.id))
          .toList();

      if (query.isEmpty) {
        filteredEmployees = selected;
      } else {
        final matches = allEmployees
            .where((employee) {
              final firstName = isArabic
                  ? (employee.firstNameInArabic ?? '')
                  : (employee.firstName ?? '');
              final lastName = isArabic
                  ? (employee.lastNameInArabic ?? '')
                  : (employee.lastName ?? '');
              final fullName = '$firstName $lastName';
              return fullName.toLowerCase().contains(query);
            })
            .where((e) => !selected.contains(e))
            .toList();

        filteredEmployees = [...selected, ...matches];
      }
    });
  }

  /////////////////////////////// Approval Cycle /////////////////////////////////////

  ////////////////////////////// Info Icon ///////////////////////////////////////////

  ////////////////////////////// Info Icon ///////////////////////////////////////////

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  ProductModel updatedProductModel() {
    final now = DateTime.now();

    // ✅ COMBINE EXPECTED LIFETIME + DURATION UNIT IN EXISTING expectedLifetime FIELD
    String lifetimeWithUnit = "";
    if (expectedLifetimeController.text.trim().isNotEmpty) {
      lifetimeWithUnit =
          "${expectedLifetimeController.text.trim()} $selectedDurationUnit";
    }

    // ✅ COMBINE EXPECTED LIFETIME + DURATION UNIT IN EXISTING expectedLifetime FIELD
    String expectedDelivery = "";
    if (expectedLifetimeController.text.trim().isNotEmpty) {
      expectedDelivery =
          "${expectedLifetimeController.text.trim()} $selectedDurationUnit";
    }

    List<String> allAttachmentUrls = [
      ...attachmentFileUrls, // URLs from server
    ];

    // ✅ HANDLE STORAGE LOCATIONS - Store as comma-separated in storageLocation field
    List<String> storageLocationEntries = [];

    // Add default location
    // Add default location

    if (defaultStorageLocation != null && defaultStorageLocation!.isNotEmpty) {
      String quantity = additionalStorageEntries.isNotEmpty
          ? defaultStorageQuantityController.text.trim()
          : "1";

      // Find the storage location name by ID from Firebase data
      // Find the storage location name by ID from Firebase data
      StorageLocation? storageLocationModel;
      try {
        storageLocationModel = storageLocationModels.firstWhere(
          (loc) => loc.id.value == defaultStorageLocation,
        );
      } catch (e) {
        storageLocationModel = null;
        debugPrint(
            'Storage location not found for ID: $defaultStorageLocation');
      }

      if (storageLocationModel != null) {
        storageLocationEntries.add(
          "${storageLocationModel.name.value}:$quantity",
        );
      }
    }

    // Add additional locations
    // Add additional locations
    for (final entry in additionalStorageEntries) {
      final selectedValue = entry['selectedValue'] as String?;
      final quantityController =
          entry['quantityController'] as TextEditingController?;

      if (selectedValue != null &&
          selectedValue.isNotEmpty &&
          quantityController != null &&
          quantityController.text.trim().isNotEmpty) {
        // Find the storage location name by ID from Firebase data
        StorageLocation? storageLocationModel;
        try {
          storageLocationModel = storageLocationModels.firstWhere(
            (loc) => loc.id.value == selectedValue,
          );
        } catch (e) {
          storageLocationModel = null;
          debugPrint('Storage location not found for ID: $selectedValue');
        }

        if (storageLocationModel != null) {
          storageLocationEntries.add(
            "${storageLocationModel.name.value}:${quantityController.text.trim()}",
          );
        } else {
          // Fallback: use the selectedValue as name if storage location not found
          debugPrint(
            'Warning: Using ID as name for missing storage location: $selectedValue',
          );
          storageLocationEntries.add(
            "$selectedValue:${quantityController.text.trim()}",
          );
        }
      }
    }

    // Add additional locations
    for (final entry in additionalStorageEntries) {
      final selectedValue = entry['selectedValue'] as String?;
      final quantityController =
          entry['quantityController'] as TextEditingController?;

      if (selectedValue != null &&
          selectedValue.isNotEmpty &&
          quantityController != null &&
          quantityController.text.trim().isNotEmpty) {
        String locationName = storageLocations.firstWhere(
          (loc) => loc['key'] == selectedValue,
          orElse: () => {'value': selectedValue},
        )['value']!;

        storageLocationEntries.add(
          "$locationName:${quantityController.text.trim()}",
        );
      }
    }

    // ✅ HANDLE STORAGE REQUIREMENTS - Store as comma-separated in storageRequirement field
    String storageRequirementsString = _selectedStorageRequirementKeys.join(
      ',',
    );

    return widget.productModel.copyWith(
      // ✅ SAVE EXPECTED LIFETIME + DURATION UNIT COMBINED
      expectedLifetime: FieldWithTimestamp(
        value: lifetimeWithUnit,
        timestamp: now,
      ),

      expectedDelivery: FieldWithTimestamp(
        value: expectedDelivery,
        timestamp: now,
      ),

      orderType: FieldWithTimestamp(value: lifetimeWithUnit, timestamp: now),

      reorderLevel: FieldWithTimestamp(
        value: reorderLevelController.text.trim(),
        timestamp: now,
      ),

      reorderQuantity: FieldWithTimestamp(
        value: reorderQuantityController.text.trim(),
        timestamp: now,
      ),

      // ✅ SAVE ADDITIONAL NOTE
      additionalNote: FieldWithTimestamp(
        value: additionalNoteController.text.trim(),
        timestamp: now,
      ),

      // ✅ SAVE PRODUCT QUANTITY FROM DEFAULT STORAGE
      productQuantity: FieldWithTimestamp(
        value: defaultStorageQuantityController.text.trim(),
        timestamp: now,
      ),

      // ✅ SAVE STORAGE REQUIREMENTS AS COMMA-SEPARATED
      storageRequirement: DropdownFieldWithTimestamp(
        value: storageRequirementsString,
        options: _selectedStorageRequirementKeys,
        timestamp: now,
      ),

      // ✅ SAVE STORAGE LOCATIONS AS COMMA-SEPARATED "location:quantity"
      storageLocation: DropdownFieldWithTimestamp(
        value: storageLocationEntries.join(
          ';',
        ), // Use semicolon to separate multiple locations
        options: storageLocationEntries,
        timestamp: now,
      ),

      // ✅ SAVE FILE URLS
      productSpecificationImage: FieldWithTimestamp<String>(
        value:
            specFileUrl ?? widget.productModel.productSpecificationImage.value,
        timestamp: now,
      ),
      productWarrantyImage: FieldWithTimestamp<String>(
        value:
            warrantyFileUrl ?? widget.productModel.productWarrantyImage.value,
        timestamp: now,
      ),
      attachmentsImage: FieldWithTimestamp<String>(
        value: allAttachmentUrls.join(','),
        timestamp: now,
      ),

      // Keep existing data
      orderDate: FieldWithTimestamp(
        value: orderDateController.text.trim(),
        timestamp: now,
      ),
      receivingDate: FieldWithTimestamp(
        value: receivingDateController.text.trim(),
        timestamp: now,
      ),
    );
  }

  bool isFormValid() {
    return expectedLifetimeController.text.trim().isNotEmpty &&
        reorderLevelController.text.trim().isNotEmpty &&
        reorderQuantityController.text.trim().isNotEmpty &&
        (specFileUrl != null && specFileUrl!.isNotEmpty) &&
        orderDateController.text.trim().isNotEmpty &&
        receivingDateController.text.trim().isNotEmpty;
  }

  String? specFileUrl;
  String? warrantyFileUrl;
  String? attachmentFileUrl;

  // --- STORAGE: helpers & validation ---

  void _removeAdditionalRow(int index) {
    setState(() {
      additionalStorageEntries.removeAt(index);
      // If no extra rows remain, clear & hide the default quantity field
      if (additionalStorageEntries.isEmpty) {
        defaultStorageQuantityController.clear();
      }
    });
  }

  bool _isPositiveInt(String? s) {
    if (s == null || s.trim().isEmpty) return false;
    final v = int.tryParse(s.trim());
    return v != null && v > 0;
  }

  ///////////////////////////////// storage location ////////////////////

  ////////////////////////////// storage requirement /////////////////////////

  // --- Storage requirement (multi-select) state ---
  final List<String> _selectedStorageRequirementKeys =
      []; // store KEYS (e.g., "standard")
  final List<String> _selectedStorageRequirementLabels =
      []; // store visible LABELS (localized)

  late Map<String, String> _reqKeyByLabel; // label -> key
  late Map<String, String> _reqLabelByKey; // key -> label

  ////////////////////////////// storage requirement /////////////////////////

  @override
  Widget build(BuildContext context) {
    ////////////////////////////// DropDown Var /////////////////////////////////////
    final durationList = [
      {"key": "week", "value": S.of(context).week},
      {"key": "hours", "value": S.of(context).hours},
      {"key": "minutes", "value": S.of(context).minutes},
      {"key": "seconds", "value": S.of(context).seconds},
    ];

    final storageRequirementList = [
      {"key": "standard", "value": S.of(context).standardStorage},
      {
        "key": "temperatureControlled",
        "value": S.of(context).temperatureControlled,
      },
      {"key": "humidityControlled", "value": S.of(context).humidityControlled},
      {"key": "dry", "value": S.of(context).dryStorage},
      {"key": "flammable", "value": S.of(context).flammableStorage},
      {"key": "hazardous", "value": S.of(context).hazardousMaterialStorage},
      {"key": "secureAccess", "value": S.of(context).secureRestrictedAccess},
      {"key": "fragile", "value": S.of(context).fragileHandleWithCare},
      {"key": "outdoor", "value": S.of(context).outdoorStorage},
      {"key": "heavyDuty", "value": S.of(context).heavyDutyStorage},
      {
        "key": "radiationProtected",
        "value": S.of(context).radiationProtectedStorage,
      },
      {"key": "coldChain", "value": S.of(context).coldChainLogistics},
    ];

    // Build-time mapping (safe & cheap)
    _reqKeyByLabel = {
      for (final m in storageRequirementList) m['value']!: m['key']!,
    };
    _reqLabelByKey = {
      for (final m in storageRequirementList) m['key']!: m['value']!,
    };

    ////////////////////////////// DropDown Var /////////////////////////////////////
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'en';
    Localizations.localeOf(context).languageCode == 'ar';
    final isMobile = ContextExtension(context).isPhone;
    return BlocListener<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is ProductFileUploaded) {
          setState(() {
            if (state.fileType == 'spec') {
              specFileUrl = state.downloadUrl;
            } else if (state.fileType == 'warranty') {
              warrantyFileUrl = state.downloadUrl;
            } else if (state.fileType == 'attachment') {
              // Remove the local file that was just uploaded
              if (attachmentFiles.isNotEmpty) {
                attachmentFiles.removeLast();
              }
              // Add the uploaded URL
              attachmentFileUrls.add(state.downloadUrl);
              // Note: Title should already be added when the dialog was closed
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ File uploaded successfully')),
          );
        } else if (state is ProductUploadError) {
          log('🔥 Upload error: ${state.message}');
          // Remove the failed attachment and its title
          setState(() {
            if (attachmentFiles.isNotEmpty) {
              attachmentFiles.removeLast();
              if (attachmentTitles.isNotEmpty) {
                attachmentTitles.removeLast();
              }
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Upload failed: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SideFrameMasterServices(
            titleText: S.of(context).inventoryManagement,
            onFirstTap: () {
              Navigator.pop(context);
            },
            secondTitle: widget.isEditMode
                ? widget
                    .productModels[widget.currentProductIndex].productName.value
                : S.of(context).addingNewProduct,
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  // product Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 1.sp),
                      Text(
                        S.of(context).productDetails,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                    ],
                  ),
                  // space
                  SizedBox(height: 8.sp),
                  // All Content Page
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Row
                          isMobile
                              ? Column(
                                  children: [
                                    // Storage Requirement
                                    storageRequirement(storageRequirementList),
                                    // space
                                    SizedBox(height: 26.sp),

                                    Row(
                                      children: [
                                        // Expected Lifetime
                                        expectedLifeTime(),

                                        SizedBox(width: 10.sp),

                                        // Day & Year & Week Dropdown
                                        durationDop(durationList),
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Storage Requirement
                                    storageRequirement(storageRequirementList),

                                    SizedBox(width: 15.sp),

                                    // Expected Lifetime
                                    expectedLifeTime(),

                                    SizedBox(width: 15.sp),

                                    // Day & Year & Week Dropdown
                                    durationDop(durationList),
                                  ],
                                ),

                          // space
                          SizedBox(height: 15.sp),

                          // Second Row ( Reorder Level & Reorder Quantity )
                          buildResponsiveFields(
                            left: CustomValidatedTextFieldMaster(
                              label: S.of(context).reorderLevel,
                              height: 36,
                              hint: S.of(context).textHere,
                              controller: reorderLevelController,
                              textDirection: ui.TextDirection.ltr,
                              onChanged: (_) => setState(() {}),
                            ),
                            right: CustomValidatedTextFieldMaster(
                              label: S.of(context).reorderQuantity,
                              height: 36,
                              hint: S.of(context).textHere,
                              controller: reorderQuantityController,
                              textDirection: ui.TextDirection.ltr,
                              onChanged: (_) => setState(() {}),
                            ),
                            context: context,
                          ),

                          SizedBox(height: 15.sp),

                          // Third Row ( Additional Note )
                          Row(
                            children: [
                              // Reorder Level
                              Expanded(
                                child: CustomValidatedTextFieldMaster(
                                  label: S.of(context).additionalNote,
                                  hint: S.of(context).textHere,
                                  controller: additionalNoteController,
                                  maxLines: 3,
                                  showCharCount: true,
                                  textDirection: ui.TextDirection.ltr,
                                  onChanged: (_) => setState(() {}),
                                  height: 72,
                                ),
                              ),
                            ],
                          ),

                          // space
                          SizedBox(height: 15.sp),

                          // Storage Location Section
                          isMobile
                              ? // storage Location
                              buildStorageLocationDropdown(
                                  selectedValue: defaultStorageLocation,
                                  onChanged: (val) {
                                    setState(() {
                                      defaultStorageLocation = val;
                                    });
                                  },
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // First Row
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 12.sp),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.41,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // storage Location
                                                buildStorageLocationDropdown(
                                                  selectedValue:
                                                      defaultStorageLocation,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      defaultStorageLocation =
                                                          val;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),

                                          // 👇 This part should only show if user added another storage row
                                          if (additionalStorageEntries
                                              .isNotEmpty) ...[
                                            SizedBox(width: 15.sp),
                                            Expanded(
                                              child:
                                                  CustomValidatedTextFieldMaster(
                                                height: 36,
                                                label: S.of(context).quantity,
                                                hint: S.of(context).textHere,
                                                controller:
                                                    defaultStorageQuantityController,
                                                textDirection:
                                                    ui.TextDirection.ltr,
                                                onChanged: (_) =>
                                                    setState(() {}),
                                                onlyDigits: true,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Additional Rows with Dropdown + Quantity
                                    // Additional Rows with Dropdown + Quantity (+ remove circle)
                                    ...additionalStorageEntries
                                        .asMap()
                                        .entries
                                        .map((
                                      row,
                                    ) {
                                      final index = row.key;
                                      final entry = row.value;

                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 12.sp),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Location dropdown
                                            SizedBox(
                                              width: MediaQuery.sizeOf(
                                                    context,
                                                  ).width *
                                                  0.41,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    S
                                                        .of(context)
                                                        .storageLocation,
                                                    style: StyleText
                                                        .fontSize14Weight400
                                                        .copyWith(
                                                      color: lightMode
                                                          ? AppColors
                                                              .blackButton
                                                          : AppColors.white,
                                                    ),
                                                  ),
                                                  SizedBox(height: 0.sp),
                                                  CustomDropdown<String>(
                                                    items: (storageLocations)
                                                        .map((e) => DropdownItem<
                                                                String>(
                                                            value:
                                                                e['key'] ?? '',
                                                            label: e['value'] ??
                                                                ''))
                                                        .toList(),
                                                    value:
                                                        entry['selectedValue'],
                                                    onChanged: (val) {
                                                      setState(() {
                                                        entry['selectedValue'] =
                                                            val;
                                                      });
                                                    },
                                                    hint: S
                                                        .of(context)
                                                        .selectStorageLocation,
                                                  ),
                                                ],
                                              ),
                                            ),

                                            SizedBox(width: 15.sp),

                                            // Quantity
                                            Expanded(
                                              child:
                                                  CustomValidatedTextFieldMaster(
                                                label: S.of(context).quantity,
                                                height: 36,
                                                hint: S.of(context).textHere,
                                                controller:
                                                    entry['quantityController'],
                                                textDirection:
                                                    ui.TextDirection.ltr,
                                                onChanged: (_) =>
                                                    setState(() {}),
                                                onlyDigits: true,
                                              ),
                                            ),

                                            SizedBox(width: 10.sp),

                                            // Round remove icon
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 20.sp,
                                              ),
                                              child: GestureDetector(
                                                onTapDown: (_) =>
                                                    HapticController.high(),
                                                onTap: () =>
                                                    _removeAdditionalRow(
                                                  index,
                                                ),
                                                child: CircleAvatar(
                                                  radius: 10.r,
                                                  backgroundColor:
                                                      AppColors.red,
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: AppColors.white,
                                                    size: 15.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                    // + Storage Button
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                          textStyle: StyleText
                                              .fontSize14Weight500
                                              .copyWith(
                                            color: AppTheme.readableOn(
                                                AppColors.blackButton),
                                          ),
                                          width: 100.sp,
                                          height: 30.sp,
                                          space: 8.sp,
                                          radius: 4.r,
                                          color: AppColors.blackButton,
                                          svgColor: AppTheme.readableOn(
                                              AppColors.blackButton),
                                          image:
                                              "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                                          widthImage: 12.sp,
                                          heightImage: 12.sp,
                                          colorBorder: Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                          // space
                          SizedBox(height: 30.sp),

                          // Product Specification & Product Warranty  &  Attachments
                          isMobile
                              ? Column(
                                  children: [
                                    productSpecification(),
                                    SizedBox(height: 26),
                                    productWarranty(),
                                    SizedBox(height: 26),
                                    attachment(),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Left side - Product Specification
                                        Expanded(child: productSpecification()),
                                        SizedBox(width: 20.sp),
                                        // Right side - Product Warranty
                                        Expanded(child: productWarranty()),
                                      ],
                                    ),

                                    SizedBox(height: 45.sp),

                                    // Attachments section - full width
                                    attachment(),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  // space
                  SizedBox(height: 20.sp),
                  // ✅ Discard & ✅ Next
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ Discard
                      customButton(
                        title: S.of(context).back,
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
                        title: S.of(context).next,
                        function:
                            _handleNextButtonPressed, // Use the new method
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
                  // space
                  SizedBox(height: 20.sp),

                  Row(
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
                    ],
                  ),
                  SizedBox(height: 20.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStorageLocationDropdown({
    String? selectedValue,
    Function(String?)? onChanged,
    String? label,
  }) {
    if (isLoadingStorageLocations) {
      return Container(
        height: 36.sp,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.secondaryText,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SizedBox(
            width: 20.sp,
            height: 20.sp,
            child: CircleProgressMaster.inline(strokeWidth: 2),
          ),
        ),
      );
    }

    if (storageLocations.isEmpty) {
      return Container(
        height: 36.sp,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.red, size: 16.sp),
              SizedBox(width: 8.sp),
              Text(
                'No storage locations',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.red,
                ),
              ),
              SizedBox(width: 8.sp),
              GestureDetector(
                onTapDown: hapticDown(_loadStorageLocations, HapticLevel.low),
                onTap: _loadStorageLocations,
                child: Icon(Icons.refresh, color: AppColors.blue, size: 16.sp),
              ),
            ],
          ),
        ),
      );
    }

    return CustomDropdown<String>(
      items: (storageLocations)
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedValue,
      onChanged: onChanged ?? (String? value) {},
      label: label ?? S.of(context).storageLocation,
      hint: S.of(context).selectStorageLocation,
      height: 36,
    );
  }

  Widget productSpecification() {
    final isMobile = ContextExtension(context).isPhone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).productSpecification,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 8.sp),

        // Priority: local picked file → existing URL → upload button
        if (productSpecificationFile != null)
          buildFilePreview(
            productSpecificationFile!,
            widget.productModel.productSpecificationImage.timestamp,
            () {
              setState(() {
                productSpecificationFile = null;
              });
            },
          )
        else if (specFileUrl != null && specFileUrl!.isNotEmpty)
          buildUrlPreview(
            specFileUrl!,
            widget.productModel.productSpecificationImage.timestamp,
            () {
              setState(() {
                specFileUrl =
                    null; // you can also handle clearing in Cubit later
              });
            },
          )
        else
          customButtonWithSvg(
            title: S.of(context).upload,
            function: () => pickFile('spec'),
            textStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.textButton,
            ),
            width: isMobile ? double.infinity : 170.sp,
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
    );
  }

  Widget productWarranty() {
    final isMobile = ContextExtension(context).isPhone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).productWarranty,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 8.sp),
        if (productWarrantyFile != null)
          buildFilePreview(
            productWarrantyFile!,
            widget.productModel.productWarrantyImage.timestamp,
            () {
              setState(() {
                productWarrantyFile = null;
              });
            },
          )
        else if (warrantyFileUrl != null && warrantyFileUrl!.isNotEmpty)
          buildUrlPreview(
            warrantyFileUrl!,
            widget.productModel.productWarrantyImage.timestamp,
            () {
              setState(() {
                warrantyFileUrl = null;
              });
            },
          )
        else
          customButtonWithSvg(
            title: S.of(context).upload,
            function: () => pickFile('warranty'),
            textStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.textButton,
            ),
            width: isMobile ? double.infinity : 170.sp,
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
    );
  }

  Widget attachment() {
    final isMobile = ContextExtension(context).isPhone;

    // Create list of all attachment items for grid
    List<Widget> attachmentItems = [];

    // Add all existing attachment files
    for (int i = 0; i < attachmentFiles.length; i++) {
      attachmentItems.add(
        buildAttachmentGridItem(
          title: i < attachmentTitles.length
              ? attachmentTitles[i]
              : "Attachment ${i + 1}", // Use custom title
          file: attachmentFiles[i],
          onUpload: () async {
            final result = await showAppDialog(
              context: context,
              builder: (_) => const AttachmentDialog(),
            );
            if (result != null && result is Map) {
              setState(() {
                attachmentFiles[i] = result['file']; // Replace existing file
                // Update the title for this attachment
                if (i < attachmentTitles.length) {
                  attachmentTitles[i] = result['title'] ??
                      result['name'] ??
                      "Attachment ${i + 1}";
                }
              });
              if (!mounted) return;
              context.read<ProductCubit>().uploadFile(
                    result['file'],
                    'attachment',
                  );
            }
          },
          onRemove: () {
            setState(() {
              attachmentFiles.removeAt(i);
              // Remove corresponding title
              if (i < attachmentTitles.length) {
                attachmentTitles.removeAt(i);
              }
            });
          },
          isExistingFile: true,
        ),
      );
    }

    // Add all attachment URLs from server
    for (int i = 0; i < attachmentFileUrls.length; i++) {
      final titleIndex = attachmentFiles.length + i;
      attachmentItems.add(
        buildAttachmentGridItem(
          title: titleIndex < attachmentTitles.length
              ? attachmentTitles[titleIndex]
              : "Attachment ${titleIndex + 1}",
          fileUrl: attachmentFileUrls[i],
          onUpload: () async {
            final result = await showAppDialog(
              context: context,
              builder: (_) => const AttachmentDialog(),
            );
            if (result != null && result is Map) {
              setState(() {
                attachmentFiles.add(result['file']); // Add new file
                attachmentFileUrls.removeAt(i); // Remove old URL
                // Add title for new file
                attachmentTitles.add(
                  result['title'] ??
                      result['name'] ??
                      "Attachment ${attachmentFiles.length}",
                );
                // Remove old title if exists
                if (titleIndex < attachmentTitles.length) {
                  attachmentTitles.removeAt(titleIndex);
                }
              });
              if (!mounted) return;
              context.read<ProductCubit>().uploadFile(
                    result['file'],
                    'attachment',
                  );
            }
          },
          onRemove: () {
            setState(() {
              attachmentFileUrls.removeAt(i);
              // Remove corresponding title
              if (titleIndex < attachmentTitles.length) {
                attachmentTitles.removeAt(titleIndex);
              }
            });
          },
          isExistingFile: true,
        ),
      );
    }

    // Add new attachment upload button
    attachmentItems.add(
      buildAttachmentGridItem(
        title: S.of(context).attachments,
        file: null,
        onUpload: () async {
          final result = await showAppDialog(
            context: context,
            builder: (_) => const AttachmentDialog(),
          );
          if (result != null && result is Map) {
            setState(() {
              attachmentFiles.add(result['file']);
              // Store the custom title
              attachmentTitles.add(
                result['title'] ??
                    result['name'] ??
                    "Attachment ${attachmentFiles.length}",
              );
            });
            if (!mounted) return;
            context.read<ProductCubit>().uploadFile(
                  result['file'],
                  'attachment',
                );
          }
        },
        isNewAttachment: true,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid layout for all attachments
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 15.sp,
            mainAxisSpacing: 10.sp,
            mainAxisExtent: 80.sp,
          ),
          itemCount: attachmentItems.length,
          itemBuilder: (context, index) => attachmentItems[index],
        ),
      ],
    );
  }

  Widget buildAttachmentGridItem({
    required String title,
    PlatformFile? file,
    String? fileUrl,
    required VoidCallback onUpload,
    VoidCallback? onRemove,
    bool isNewAttachment = false,
    bool isExistingFile = false,
  }) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FormatHelper.capitalize(title),
              style: StyleText.fontSize12Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.sp),

        // Content container
        Expanded(
          child: Container(
            width: 285.w,
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: (file != null || fileUrl != null)
                  ? Border.all(
                      color: lightMode
                          ? const Color(0xffB5B4B4)
                          : Colors.transparent,
                      width: 1,
                    )
                  : Border.all(color: Colors.transparent, width: 1),
            ),
            child: (file != null || fileUrl != null)
                ? buildUploadedAttachmentContent(
                    file: file,
                    fileUrl: fileUrl,
                    onUpload: onUpload,
                    onRemove: onRemove,
                  )
                : buildEmptyAttachmentContent(onUpload),
          ),
        ),
      ],
    );
  }

  // Content for uploaded attachments
  Widget buildUploadedAttachmentContent({
    PlatformFile? file,
    String? fileUrl,
    required VoidCallback onUpload,
    VoidCallback? onRemove,
  }) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    String fileName;
    String fileSize;

    if (file != null) {
      fileName = file.name;
      fileSize = formatBytes(file.size);
    } else if (fileUrl != null) {
      fileName = _fileNameFromUrl(fileUrl);
      fileSize = "—"; // Unknown size for URLs
    } else {
      fileName = "Unknown";
      fileSize = "—";
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
                // Image preview
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
                    child: file != null
                        ? (kIsWeb
                            ? Image.memory(file.bytes!, fit: BoxFit.cover)
                            : Image.file(
                                File(file.path!),
                                fit: BoxFit.cover,
                              ))
                        : (fileUrl != null
                            ? Image.network(fileUrl, fit: BoxFit.cover)
                            : Icon(Icons.image, color: AppColors.grey)),
                  ),
                ),
                SizedBox(width: 12.w),

                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          right: onRemove != null ? 25.w : 0,
                        ),
                        child: Text(
                          FormatHelper.capitalize(fileName),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: StyleText.fontSize12Weight500.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
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

          // Remove button
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

  // Content for empty upload slot
  Widget buildEmptyAttachmentContent(VoidCallback onUpload) {
    final isMobile = ContextExtension(context).isPhone;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customButtonWithSvg(
          title: S.of(context).upload,
          function: onUpload,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.textButton,
          ),
          width: isMobile ? double.infinity : 170.sp,
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
    );
  }

  // Helper method for file name from URL
  String _fileNameFromUrl(String url) {
    try {
      final seg = Uri.parse(url).pathSegments;
      if (seg.isNotEmpty) return seg.last;
    } catch (_) {}
    return url.split('/').last.split('?').first;
  }

  Widget buildUrlPreview(
    String url,
    DateTime uploadDate,
    VoidCallback onRemove,
  ) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    String formattedDate = "${uploadDate.day.toString().padLeft(2, '0')}/"
        "${uploadDate.month.toString().padLeft(2, '0')}/"
        "${uploadDate.year}";

    return Container(
      width: isMobile ? MediaQuery.sizeOf(context).width : 283.sp,
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
            child: Image.network(
              url,
              width: 36.sp,
              height: 36.sp,
              fit: BoxFit.cover,
            ),
          ),

          SizedBox(width: 10.sp),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // file name (derived from URL)
                Text(
                  FormatHelper.capitalize(_fileNameFromUrl(url)),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.sp),
                // size placeholder to keep layout identical
                Text(
                  "—",
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
                const Spacer(),
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

  // Import your multi-select: adjust path if different
  // import 'path/to/app_multi_select_dropdown.dart';

  Widget storageRequirement(List<Map<String, String>> storageRequirementList) {
    final isTablet = ContextExtension(context).isTablet;
    final isMobile = ContextExtension(context).isPhone;
    final isLandscape = ContextExtension(context).isLandscape;

    // 1) Build items = VISIBLE labels
    final List<String> labels =
        storageRequirementList.map((e) => e['value']!).toList();

    // 2) Compose a compact summary text for the closed button
    String summaryText() {
      if (_selectedStorageRequirementLabels.isEmpty) {
        return S
            .of(context)
            .storageRequirement; // acts like a label/placeholder
      }
      if (_selectedStorageRequirementLabels.length <= 2) {
        return _selectedStorageRequirementLabels.join(', ');
      }
      return '${_selectedStorageRequirementLabels.take(2).join(', ')} +${_selectedStorageRequirementLabels.length - 2}';
    }

    // 3) Compute width like your old widget
    final double width = isMobile
        ? MediaQuery.of(context).size.width
        : (isTablet && !isLandscape)
            ? MediaQuery.of(context).size.width * 0.398
            : MediaQuery.of(context).size.width * 0.425;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).storageRequirement,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.blackButton,
            ),
          ),

          // SizedBox(height: 8.sp),
          CustomMultiSelectFilter<String>(
            items: (labels)
                .map((e) => MultiSelectDropdownItem<String>(value: e, label: e))
                .toList(),
            values: _selectedStorageRequirementLabels,
            onChanged: (values) {
              final previous =
                  List<String>.of(_selectedStorageRequirementLabels);
              for (final item in [
                ...values.where((v) => !previous.contains(v)),
                ...previous.where((v) => !values.contains(v)),
              ]) {
                ((dynamic itemLabel) {
                  if (itemLabel is! String) return;
                  final key = _reqKeyByLabel[itemLabel];
                  if (key == null) return;

                  setState(() {
                    if (_selectedStorageRequirementKeys.contains(key)) {
                      _selectedStorageRequirementKeys.remove(key);
                      _selectedStorageRequirementLabels.remove(itemLabel);
                    } else {
                      _selectedStorageRequirementKeys.add(key);
                      _selectedStorageRequirementLabels.add(itemLabel);
                    }
                  });
                })(item);
              }
            },
            selectedTextBuilder: (_) => summaryText(),
            hint: S.of(context).selectStorageLocation,
            height: 36,
            fillColor: AppColors.background,
            valueStyle: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.blackButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget expectedLifeTime() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomValidatedTextFieldMaster(
            label: S.of(context).expectedLifetime,
            textStyle: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.blackButton,
            ),
            hint: S.of(context).textHere,
            controller: expectedLifetimeController,
            maxLines: 1,
            textDirection: ui.TextDirection.ltr,
            height: 36,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget durationDop(List<Map<String, String>> durationList) {
    return SizedBox(
      width: 85.sp,
      child: CustomDropdown<String>(
        items: (durationList)
            .map((e) => DropdownItem<String>(
                value: e['key'] ?? '', label: e['value'] ?? ''))
            .toList(),
        value: selectedDurationUnit,
        onChanged: (value) {
          setState(() {
            selectedDurationUnit = value;
          });
        },
        label: "",
        height: 36,
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

  Widget employeeCard(EmployeeEntity employee, VoidCallback onTap) {
    final isEnglish = !context.isArabic;

    final fullName = isEnglish
        ? "${employee.firstName ?? ''} ${employee.lastName ?? ''}"
        : "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}";

    final title =
        isEnglish ? employee.title ?? '' : employee.titleInArabic ?? '';

    return Container(
      width: 310.sp,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
      child: Row(
        children: [
          // image
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
                width: 40.w,
                height: 40.h,
              ),
            ),
          ),
          SizedBox(width: 10.sp),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                FormatHelper.capitalize(fullName),
                style: StyleText.fontSize15Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                FormatHelper.capitalize(title),
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                FormatHelper.capitalize(title),
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 35.sp),
            child: GestureDetector(
              onTapDown: hapticDown(onTap, HapticLevel.low),
              onTap: onTap,
              child: CustomSvgImage.natural(
                assetPath: isSelected(employee)
                    ? 'assets/icons_assets/main_icons_assets/ic_form_checkbox_checked.svg'
                    : 'assets/icons_assets/main_icons_assets/ic_form_checkbox_empty.svg',
                width: 22.w,
                height: 22.h,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget remoteFileChip({
    required String url,
    required String label,
    required DateTime? ts,
    required VoidCallback onRemove, // optional if you support removing remote
  }) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: isMobile ? MediaQuery.sizeOf(context).width : 283.sp,
      height: 60.sp,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.secondaryText,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(6.sp),
            child: Image.network(
              url,
              width: 36.sp,
              height: 36.sp,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 5.sp),
                Text(
                  'URL',
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
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
                const Spacer(),
                Text(
                  ts != null
                      ? "Date: ${ts.day.toString().padLeft(2, '0')}/${ts.month.toString().padLeft(2, '0')}/${ts.year}"
                      : '',
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

  Widget buildFilePreview(
    PlatformFile file,
    DateTime uploadDate,
    VoidCallback onRemove,
  ) {
    final isMobile = ContextExtension(context).isPhone;

    String size = formatBytes(file.size);
    "${uploadDate.day.toString().padLeft(2, '0')}/"
        "${uploadDate.month.toString().padLeft(2, '0')}/"
        "${uploadDate.year}";

    return Container(
      width: isMobile ? MediaQuery.sizeOf(context).width : 283.sp,
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
                // Spacer(),
                // Text(
                //   "Date: $formattedDate",
                //   style: StyleText.fontSize10Weight400.copyWith(
                //     color:
                //         lightMode ? Colors.grey.shade600 : Colors.grey.shade400,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeEntity {
  final String id; // ✅ Required for selection logic
  final String? firstName;
  final String? lastName;
  final String? firstNameInArabic;
  final String? lastNameInArabic;
  final String? title;
  final String? titleInArabic;
  final String? departmentId;
  final String gender;

  EmployeeEntity({
    required this.id, // ✅ Make sure it's passed
    this.firstName,
    this.lastName,
    this.firstNameInArabic,
    this.lastNameInArabic,
    this.title,
    this.titleInArabic,
    this.departmentId,
    required this.gender,
  });
}

class AttachmentDialog extends StatefulWidget {
  const AttachmentDialog({super.key});

  @override
  State<AttachmentDialog> createState() => _AttachmentDialogState();
}

class _AttachmentDialogState extends State<AttachmentDialog> {
  int step = 1;
  PlatformFile? pickedFile;
  TextEditingController titleController = TextEditingController();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'], // ✅ only fully supported formats
      allowMultiple: false,
      withData: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFile = PlatformFile(
          name: result.files.first.name,
          size: result.files.first.size,
          path: result.files.first.path,
          bytes: null, // ✅ ensure bytes are removed
        );
        titleController.text = pickedFile!.name;
        step = 2;
      });
    }
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    var themeMode = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        decoration: BoxDecoration(
          color: themeMode ? AppColors.white : AppColors.chatBackground,
        ),
        width: 575.sp,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 30./30./16. row.
            CustomDialogHeader(
                title: S.of(context).addingAttachment,
                icon: "assets/icons_assets/main_icons_assets/ic_upload.svg"),

            // Space
            SizedBox(height: 23.sp),

            // Step 1: Drag & Drop / Browse
            if (step == 1) ...[
              Center(
                child: Column(
                  children: [
                    // image of upload file
                    CustomSvgImage(
                      assetPath:
                          "assets/icons_assets/main_icons_assets/ic_cloud_upload.svg",
                      width: 100.sp,
                      height: 100.sp,
                      color: themeMode ? AppColors.grey : AppColors.grey,
                      fit: BoxFit.scaleDown,
                    ),
                    // space
                    SizedBox(height: 27.sp),
                    // Drag Or Drop Here
                    Text(
                      S.of(context).dragDropHere,
                      style: StyleText.fontSize20Weight500.copyWith(
                        color:
                            themeMode ? AppColors.blackButton : AppColors.white,
                      ),
                    ),
                    // Or
                    Text(S.of(context).or),
                    // Space
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
                          color: Color(0xcccccccc),
                          radius: 8.r,
                          textStyle: StyleText.fontSize16Weight600.copyWith(
                            color: AppColors.blackButton,
                          ),
                          width: 150.sp,
                          height: 38.sp,
                        ),
                        Spacer(),
                        customButton(
                          title: S.of(context).browseFiles,
                          function: _pickFile,
                          color: AppColors.primary,
                          radius: 8.r,
                          textStyle: StyleText.fontSize16Weight600.copyWith(
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

            // Step 2/3: File Preview + Title Input
            if (step == 2 || step == 3) ...[
              Text(
                S.of(context).file,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: themeMode ? AppColors.blackButton : AppColors.white,
                ),
              ),
              SizedBox(height: 8.sp),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: themeMode ? AppColors.grey : AppColors.grey,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.all(12.sp),
                child: Row(
                  children: [
                    // image
                    Container(
                      width: 36.sp,
                      height: 36.sp,
                      decoration: BoxDecoration(
                        color:
                            themeMode ? AppColors.grey : AppColors.background,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.image, color: AppColors.grey),
                    ),
                    // space
                    SizedBox(width: 10.sp),
                    // name of image and Size
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FormatHelper.capitalize(
                              titleController.text.isEmpty
                                  ? pickedFile?.name ?? ''
                                  : titleController.text,
                            ),
                            style: StyleText.fontSize14Weight500.copyWith(
                              color: themeMode
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${(pickedFile!.size / 1024).ceil()} KB",
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: themeMode
                                  ? AppColors.secondaryText
                                  : AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // remove image
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTapDown: (_) => HapticController.high(),
                          onTap: () {
                            setState(() {
                              pickedFile = null;
                              step = 1;
                              titleController.clear();
                            });
                          },
                          child: CustomSvgImage(
                            assetPath:
                                "assets/icons_assets/main_icons_assets/ic_editor_decrease.svg",
                            height: 15.sp,
                            width: 15.sp,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        SizedBox(height: 20.sp),
                        Row(
                          children: [
                            Text(
                              '${S.of(context).date}: ',
                              style: StyleText.fontSize10Weight400.copyWith(
                                color: themeMode
                                    ? AppColors.secondaryText
                                    : AppColors.grey,
                              ),
                            ),
                            Text(
                              _getFormattedDate(DateTime.now()),
                              style: StyleText.fontSize10Weight400.copyWith(
                                color: themeMode
                                    ? AppColors.blackButton
                                    : AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.sp),
              CustomValidatedTextFieldMaster(
                label: S.of(context).titleName,
                hint: S.of(context).textHere,
                controller: titleController,
                maxLines: 1,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: themeMode ? AppColors.blackButton : AppColors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                textDirection: TextDirection
                    .ltr, // X-73: Cancel left, action right in both languages

                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //  Discard
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

                  Spacer(),

                  //  Submit
                  customButton(
                    title: S.of(context).submit,
                    function: () {
                      if (pickedFile != null &&
                          titleController.text.isNotEmpty) {
                        Navigator.of(context).pop({
                          'file': pickedFile,
                          'title':
                              titleController.text, // ✅ Return the edited title
                          'name': titleController
                              .text, // optional alias if you need
                        });
                      }
                    },
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
          ],
        ),
      ),
    );
  }
}
