import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_range_fields.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/features/inventory/helpers/constants/constant_lists.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

// Filter Dialog Widget
class InventoryFilterDialog extends StatefulWidget {
  final String selectedCategory;
  final Function(Map<String, dynamic>) onApplyFilters;
  final Map<String, dynamic>? currentFilters;
  final List<ProductModel>? orders;
  final List<Map<String, String>> availableSuppliers; // Added this parameter

  const InventoryFilterDialog({
    super.key,
    required this.selectedCategory,
    required this.onApplyFilters,
    this.currentFilters,
    this.orders,
    this.availableSuppliers = const [], // Added this parameter
  });

  @override
  State<InventoryFilterDialog> createState() => _InventoryFilterDialogState();
}

class _InventoryFilterDialogState extends State<InventoryFilterDialog> {
  // Filter values
  String? selectedSupplierRank;
  String? selectedBusinessType;
  String? selectedProductStatus;
  String? selectedAssetStatus;
  String? selectedOrderStatus;
  String? selectedStorageLocation;
  DateTimeRange? selectedDateRange;
  String? selectedAssignedLocation;
  String? selectedAccessLevel;
  String? selectedEquipmentAvailability;
  String? selectedConditionStorage;
  String? selectedProductType;
  String? selectedSupplierName; // Added this variable

  // Add this static method for product types
  static List<Map<String, String>> productTypeList() => [
        {"key": "Assets", "value": "Assets"},
        {"key": "Consumables", "value": "Consumables"},
      ];

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    if (widget.currentFilters != null) {
      selectedSupplierRank = widget.currentFilters!['supplierRank'];
      selectedBusinessType = widget.currentFilters!['businessType'];
      selectedProductStatus = widget.currentFilters!['productStatus'];
      selectedAssetStatus = widget.currentFilters!['assetStatus'];
      selectedOrderStatus = widget.currentFilters!['orderStatus'];
      selectedStorageLocation = widget.currentFilters!['storageLocation'];
      selectedDateRange = widget.currentFilters!['dateRange'];

      // Order-specific and Product-specific filters
      selectedSupplierName = widget.currentFilters!['supplierName'];
      selectedProductType = widget.currentFilters!['productType'];

      // Storage location filters
      selectedAssignedLocation = widget.currentFilters!['assignedLocation'];
      selectedAccessLevel = widget.currentFilters!['accessLevel'];
      selectedEquipmentAvailability =
          widget.currentFilters!['equipmentAvailability'];
      selectedConditionStorage = widget.currentFilters!['conditionStorage'];
    }
  }

  // Static lists for filters
  static List<Map<String, String>> supplierRankList() => [
        {"key": "Preferred", "value": "Preferred"},
        {"key": "Approved", "value": "Approved"},
        {"key": "Qualified", "value": "Qualified"},
        {"key": "Monitored", "value": "Monitored"},
        {"key": "Usage", "value": "Usage"},
        {"key": "Occasional", "value": "Occasional"},
        {"key": "Inactive", "value": "Inactive"},
        {"key": "Risk/Compliance-based", "value": "Risk/Compliance-based"},
        {"key": "Suspended", "value": "Suspended"},
        {"key": "Investigations", "value": "Investigations"},
        {"key": "Blacklisted", "value": "Blacklisted"},
      ];

  static List<Map<String, String>> productStatusList() => [
        {"key": "In Stock", "value": "In Stock"},
        {"key": "Out Of Stock", "value": "Out Of Stock"},
        {"key": "Low Stock", "value": "Low Stock"},
      ];

  static List<Map<String, String>> assetStatusList() => [
        {"key": "Assigned", "value": "Assigned"},
        {"key": "Unassigned", "value": "Unassigned"},
        {"key": "Maintenance", "value": "Maintenance"},
        {"key": "Retired", "value": "Retired"},
      ];

  static List<Map<String, String>> orderStatusList() => [
        {"key": "Open", "value": "Open"},
        {"key": "Received", "value": "Received"},
        {"key": "Partially Received", "value": "Partially Received"},
        {"key": "Cancelled", "value": "Cancelled"},
        {"key": "Draft", "value": "Draft"},
      ];

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    var isMobile = context.isPhone;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? 350.w : 600.w, // Wider for tablet/desktop
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(15.sp),
              // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 30./30./12. row.
              child: CustomDialogHeader(
                  title: S.of(context).filter,
                  icon:
                      "assets/icons_assets/main_icons_assets/ic_action_filter.svg"),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(15.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterContent(lightMode, isArabic, isMobile),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: EdgeInsets.all(15.r),
              child: Row(
                children: [
                  customButton(
                    title: S.of(context).reset,
                    function: _clearAllFilters,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.blackButton,
                    ),
                    width: isMobile ? 135.w : 150.w,
                    height: 38.sp,
                    radius: 8.r,
                    color: AppColors.grey,
                  ),
                  Spacer(),
                  customButton(
                    title: S.of(context).submit,
                    function: _applyFilters,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton,
                    ),
                    width: isMobile ? 135.w : 150.w,
                    height: 38.sp,
                    radius: 8.r,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterContent(bool lightMode, bool isArabic, bool isMobile) {
    switch (widget.selectedCategory) {
      case 'Suppliers':
        return _buildSupplierFilters(lightMode, isMobile);
      case 'Products':
        return _buildProductFilters(lightMode, isMobile);
      case 'Assets':
      case 'Consumables':
        return _buildAssetFilters(lightMode, isMobile);
      case 'Orders':
        return _buildOrderFilters(lightMode, isMobile);
      case 'Storage Locations':
        return _buildStorageLocationFilters(lightMode, isMobile);
      default:
        return _buildGenericFilters(lightMode, isMobile);
    }
  }

  Widget _buildSupplierFilters(bool lightMode, bool isMobile) {
    List<Widget> filters = [
      // Suppliers
      _buildDropdownFilter(
        label: S.of(context).supplierRank,
        value: selectedSupplierRank,
        height: 36,
        items: supplierRankList(),
        onChanged: (v) => setState(() => selectedSupplierRank = v),
        lightMode: lightMode,
        isMobile: isMobile,
      ),
      _buildDropdownFilter(
        label: S.of(context).businessType,
        value: selectedBusinessType,
        height: 36,
        items: ConstantLists.businessTypeList(),
        onChanged: (v) => setState(() => selectedBusinessType = v),
        lightMode: lightMode,
        isMobile: isMobile,
      ),
      _buildDateRangeFilter(
        lightMode,
        S.of(context).contractDateRange,
        isMobile,
      ),
    ];

    return _buildResponsiveLayout(filters, isMobile);
  }

  Widget _buildProductFilters(bool lightMode, bool isMobile) {
    List<Widget> filters = [
      // Product Type Filter
      _buildDropdownFilter(
        label: 'Product Type',
        value: selectedProductType,
        height: 36,
        items: productTypeList(),
        onChanged: (value) => setState(() => selectedProductType = value),
        lightMode: lightMode,
        isMobile: isMobile,
      ),

      // Product Status Filter
      _buildDropdownFilter(
        label: 'Product Status',
        value: selectedProductStatus,
        height: 36,
        items: productStatusList(),
        onChanged: (value) => setState(() => selectedProductStatus = value),
        lightMode: lightMode,
        isMobile: isMobile,
      ),

      // Supplier Name Filter
      _buildDropdownFilter(
        label: 'Supplier Name',
        value: selectedSupplierName,
        height: 36,
        items: _getUniqueSupplierNames(),
        onChanged: (value) => setState(() => selectedSupplierName = value),
        lightMode: lightMode,
        isMobile: isMobile,
      ),

      // Date Range Filter
      _buildDateRangeFilter(lightMode, 'Last Update Date Range', isMobile),
    ];

    return _buildResponsiveLayout(filters, isMobile);
  }

  Widget _buildAssetFilters(bool lightMode, bool isMobile) {
    List<Widget> filters = [
      _buildDropdownFilter(
        label: 'Asset Status',
        value: selectedAssetStatus,
        height: 36,
        items: assetStatusList(),
        onChanged: (value) => setState(() => selectedAssetStatus = value),
        lightMode: lightMode,
        isMobile: isMobile,
      ),
      _buildDateRangeFilter(lightMode, 'Received Date Range', isMobile),
    ];

    return _buildResponsiveLayout(filters, isMobile);
  }

  Widget _buildOrderFilters(bool lightMode, bool isMobile) {
    List<Widget> filters = [
      // Order Status Filter
      _buildDropdownFilter(
        label: 'Order Status',
        value: selectedOrderStatus,
        height: 36,
        items: orderStatusList(),
        onChanged: (value) => setState(() => selectedOrderStatus = value),
        lightMode: lightMode,
        isMobile: isMobile,
      ),

      // Supplier Name Filter
      _buildDropdownFilter(
        label: 'Supplier Name',
        value: selectedSupplierName,
        height: 36,
        items: _getUniqueSupplierNames(),
        onChanged: (value) => setState(() => selectedSupplierName = value),
        lightMode: lightMode,
        isMobile: isMobile,
      ),

      // Order Date Range Filter
      _buildDateRangeFilter(lightMode, 'Order Date Range', isMobile),
    ];

    return _buildResponsiveLayout(filters, isMobile);
  }

  // Updated method to get unique supplier names
  List<Map<String, String>> _getUniqueSupplierNames() {
    // If availableSuppliers is provided, use it (preferred)
    if (widget.availableSuppliers.isNotEmpty) {
      return widget.availableSuppliers;
    }

    // Otherwise, extract from orders (fallback)
    if (widget.orders == null || widget.orders!.isEmpty) return [];

    Set<String> uniqueSuppliers = widget.orders!
        .map((order) => order.supplierName.value)
        .where((name) => name.isNotEmpty)
        .toSet();

    return uniqueSuppliers.map((name) => {"key": name, "value": name}).toList();
  }

  Widget _buildStorageLocationFilters(bool lightMode, bool isMobile) {
    List<Widget> filters = [
      // Assigned Location Filter
      _buildDropdownFilter(
        label: S.of(context).assignedDepartment,
        value: selectedAssignedLocation,
        height: 36,
        items: ConstantLists.departmentTranslationsCamel(),
        onChanged: (v) => setState(() => selectedAssignedLocation = v),
        lightMode: lightMode,
        isMobile: isMobile,
      ),

      // Access Level Filter
      _buildDropdownFilter(
        label: S.of(context).accessLevel,
        value: selectedAccessLevel,
        height: 36,
        items: ConstantLists.accessLevelList(),
        onChanged: (v) => setState(() => selectedAccessLevel = v),
        lightMode: lightMode,
        isMobile: isMobile,
      ),

      // Equipment Availability Filter
      _buildDropdownFilter(
        label: S.of(context).equipmentAvailable,
        value: selectedEquipmentAvailability,
        height: 36,
        items: ConstantLists.equipmentAvailableList(),
        onChanged: (v) => setState(() => selectedEquipmentAvailability = v),
        lightMode: lightMode,
        isMobile: isMobile,
      ),

      // Condition of Storage Filter
      _buildDropdownFilter(
        label: S.of(context).conditionOfStorage,
        value: selectedConditionStorage,
        height: 36,
        items: ConstantLists.conditionOfStorageList(),
        onChanged: (v) => setState(() => selectedConditionStorage = v),
        lightMode: lightMode,
        isMobile: isMobile,
      ),

      // Date Range Filter
      _buildDateRangeFilter(
        lightMode,
        S.of(context).createdDateRange,
        isMobile,
      ),
    ];

    return _buildResponsiveLayout(filters, isMobile);
  }

  Widget _buildGenericFilters(bool lightMode, bool isMobile) {
    List<Widget> filters = [
      _buildDateRangeFilter(lightMode, 'Date Range', isMobile),
    ];

    return _buildResponsiveLayout(filters, isMobile);
  }

  // New method to handle responsive layout
  Widget _buildResponsiveLayout(List<Widget> filters, bool isMobile) {
    if (isMobile) {
      // Mobile: All fields in column
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: filters
            .map(
              (filter) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: filter,
              ),
            )
            .toList(),
      );
    } else {
      // Tablet/Desktop: 2 fields per row
      List<Widget> rows = [];

      for (int i = 0; i < filters.length; i += 2) {
        if (i + 1 < filters.length) {
          // Two items in row
          rows.add(
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Expanded(child: filters[i]),
                  SizedBox(width: 16.w),
                  Expanded(child: filters[i + 1]),
                ],
              ),
            ),
          );
        } else {
          // Single item in row (odd number of filters)
          rows.add(
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Expanded(child: filters[i]),
                  SizedBox(width: 16.w),
                  Expanded(child: Container()), // Empty space
                ],
              ),
            ),
          );
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      );
    }
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
    required bool lightMode,
    required bool isMobile,
    double? width,
    double? height,
    Map<String, Color>? itemColors,
    bool includeAllOption = true,
  }) {
    const allKey = '__ALL__';

    final List<Map<String, String>> dropdownItems = [
      if (includeAllOption) {'key': allKey, 'value': S.of(context).all},
      ...items,
    ];

    return SizedBox(
      width: width ?? double.infinity,
      child: CustomDropdown<String>(
        items: (dropdownItems)
            .map((e) => DropdownItem<String>(
                value: e['key'] ?? '',
                label: e['value'] ?? '',
                leading:
                    ((itemColors)?[e['key']] ?? (itemColors)?[e['value']]) ==
                            null
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: (itemColors)?[e['key']] ??
                                    (itemColors)?[e['value']],
                                shape: BoxShape.circle))))
            .toList(),
        value: value,
        onChanged: (selectedValue) {
          if (selectedValue == allKey) {
            onChanged(null);
          } else {
            onChanged(selectedValue);
          }
        },
        label: null,
        hint: label,
        height: height ?? 38.0,
        labelGap: 8.0,
        fillColor: AppColors.background,
      ),
    );
  }

  // CHANGED 17/10/2026 (Moataz: "use the date range we did in the time
  // tracker"): From / To fields with "To not before From" instead of the
  // one-field range calendar.
  Widget _buildDateRangeFilter(bool lightMode, String label, bool isMobile) {
    final DateTimeRange? range = selectedDateRange;
    return CustomDateRangeFields(
      from: range?.start,
      to: range?.end,
      onFrom: (DateTime? d) => setState(() {
        if (d == null) {
          selectedDateRange = null;
          return;
        }
        final DateTime end = range?.end ?? d;
        selectedDateRange =
            DateTimeRange(start: d, end: end.isBefore(d) ? d : end);
      }),
      onTo: (DateTime? d) => setState(() {
        if (d == null) {
          selectedDateRange = null;
          return;
        }
        final DateTime start = range?.start ?? d;
        selectedDateRange =
            DateTimeRange(start: start.isAfter(d) ? d : start, end: d);
      }),
    );
  }

  void _clearAllFilters() {
    setState(() {
      selectedSupplierRank = null;
      selectedBusinessType = null;
      selectedProductStatus = null;
      selectedAssetStatus = null;
      selectedOrderStatus = null;
      selectedStorageLocation = null;
      selectedDateRange = null;

      // Order-specific and Product-specific filters
      selectedSupplierName = null;
      selectedProductType = null;

      // Storage location filters
      selectedAssignedLocation = null;
      selectedAccessLevel = null;
      selectedEquipmentAvailability = null;
      selectedConditionStorage = null;
    });

    // IMPORTANT: Apply the cleared filters to update the parent screen
    Map<String, dynamic> clearedFilters = {
      'supplierRank': null,
      'businessType': null,
      'productStatus': null,
      'assetStatus': null,
      'orderStatus': null,
      'storageLocation': null,
      'dateRange': null,
      'supplierName': null,
      'productType': null,
      'assignedLocation': null,
      'accessLevel': null,
      'equipmentAvailability': null,
      'conditionStorage': null,
    };

    // Call the parent's filter callback to actually clear the filters on the main screen
    widget.onApplyFilters(clearedFilters);

    // Force rebuild of the entire widget to ensure dropdowns show hint text
    if (mounted) {
      setState(() {});
    }
  }

  void _applyFilters() {
    Map<String, dynamic> filters = {
      'supplierRank': selectedSupplierRank,
      'businessType': selectedBusinessType,
      'productStatus': selectedProductStatus,
      'assetStatus': selectedAssetStatus,
      'orderStatus': selectedOrderStatus,
      'storageLocation': selectedStorageLocation,
      'dateRange': selectedDateRange,

      // Order-specific and Product-specific filters
      'supplierName': selectedSupplierName,
      'productType': selectedProductType,

      // Storage location filters
      'assignedLocation': selectedAssignedLocation,
      'accessLevel': selectedAccessLevel,
      'equipmentAvailability': selectedEquipmentAvailability,
      'conditionStorage': selectedConditionStorage,
    };

    widget.onApplyFilters(filters);
    Navigator.of(context).pop();
  }
}

// Extension for filtering suppliers
extension SupplierFiltering on List {
  List filterSuppliers(Map<String, dynamic> filters) {
    return where((supplier) {
      bool matchesRank = filters['supplierRank'] == null ||
          supplier.supplierRank == filters['supplierRank'];

      bool matchesBusinessType = filters['businessType'] == null ||
          supplier.businessType == filters['businessType'];

      bool matchesDateRange = filters['dateRange'] == null ||
          _isDateInRange(supplier.contractStartDate, filters['dateRange']);

      return matchesRank && matchesBusinessType && matchesDateRange;
    }).toList();
  }

  bool _isDateInRange(String dateString, DateTimeRange range) {
    try {
      // Handle the format "23-9-2025" (dd-M-yyyy)
      List<String> parts = dateString.split('-');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        DateTime date = DateTime(year, month, day);

        return date.isAfter(range.start.subtract(Duration(days: 1))) &&
            date.isBefore(range.end.add(Duration(days: 1)));
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
