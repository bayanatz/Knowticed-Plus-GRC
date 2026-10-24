import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class FilterDialog extends StatefulWidget {
  final Function(Map<String, String>) onApplyFilter;
  final Map<String, String> initialFilters;
  final List<Map<String, String>> availableSuppliers; // ADD THIS

  const FilterDialog({
    super.key,
    required this.onApplyFilter,
    this.initialFilters = const {},
    this.availableSuppliers = const [], // ADD THIS
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  // Filter selections
  String? selectedProductType;
  String? selectedCategory;
  String? selectedSubcategory;
  String? selectedSupplier; // ADD THIS LINE

  // Controllers for date fields
  late TextEditingController orderDateController;
  late TextEditingController receivingDateController;

  // Selected dates
  DateTime? selectedOrderDate;
  DateTime? selectedReceivingDate;

  // Product Types
  final List<Map<String, String>> productTypes = [
    {'key': 'Assets', 'value': 'Assets'},
    {'key': 'Consumable', 'value': 'Consumable'},
    {'key': 'Hybrid', 'value': 'Hybrid'},
  ];

  // Category-Subcategory mapping
  final Map<String, List<String>> categorySubcategoryMap = {
    'IT & Technology Assets': [
      'Computers (Desktops, Laptops, Tablets)',
      'Servers & Networking (Routers, Switches, Firewalls, Data Storage)',
      'Mobile Devices (Smartphones, Accessories)',
      'Printers & Scanners',
      'Software Licenses',
    ],
    'Office & Furniture Assets': [
      'Desks',
      'Chairs',
      'Workstations / Cubicles',
      'Filing Cabinets',
      'Storage Units',
      'Conference Room Equipment',
      'HVAC / Air Conditioning Units',
    ],
    'Machinery & Equipment': [
      'Production Machines',
      'Power Tools',
      'Heavy Equipment (Forklifts, Cranes, Excavators)',
      'Medical Equipment',
    ],
    'Vehicles & Transportation': [
      'Cars',
      'Trucks / Vans',
      'Motorcycles',
      'Marine Assets (Boats, Jet Skis)',
    ],
    'Building & Facilities': [
      'Land',
      'Buildings',
      'Leasehold Improvements',
      'Security Systems (CCTV, Alarms)',
      'Generators',
      'Elevators',
    ],
    'Intangible Assets': [
      'Patents',
      'Trademarks',
      'Copyrights',
      'Intellectual Property',
      'Digital Subscriptions',
    ],
    'Office Consumables': [
      'Stationery (Pens, Notebooks, Paper)',
      'Printing Supplies (Ink Cartridges, Toner, Printing Paper)',
      'Packaging Materials',
    ],
    'IT Consumables': [
      'Cables',
      'Adapters',
      'Mouse / Keyboard Replacements',
      'Batteries',
      'Chargers',
      'USBs & Memory Cards',
    ],
    'Cleaning & Maintenance Supplies': [
      'Detergents',
      'Chemicals',
      'Gloves',
      'Masks',
      'Mop Heads & Cleaning Cloths',
      'Disinfectants',
    ],
    'Industrial / Manufacturing Consumables': [
      'Raw Materials (Metals, Plastics, Wood)',
      'Welding Rods & Gases',
      'Lubricants & Oils',
      'Disposable Safety Gear',
    ],
    'Healthcare / Lab Consumables': [
      'Syringes & Needles',
      'Gloves',
      'Test Kits',
      'Reagents',
      'Bandages & Dressings',
      'Disposable Masks & Gowns',
    ],
    'Food & Hospitality Consumables': [
      'Coffee / Tea',
      'Water Bottles',
      'Disposable Cups',
      'Plates & Cutlery',
      'Cleaning Wipes',
      'Towels & Napkins',
    ],
  };

  // Get categories based on product type
  List<Map<String, String>> get availableCategories {
    if (selectedProductType == null) return [];

    List<String> categories = [];
    if (selectedProductType == 'Assets') {
      categories = [
        'IT & Technology Assets',
        'Office & Furniture Assets',
        'Machinery & Equipment',
        'Vehicles & Transportation',
        'Building & Facilities',
        'Intangible Assets',
      ];
    } else if (selectedProductType == 'Consumable') {
      categories = [
        'Office Consumables',
        'IT Consumables',
        'Cleaning & Maintenance Supplies',
        'Industrial / Manufacturing Consumables',
        'Healthcare / Lab Consumables',
        'Food & Hospitality Consumables',
      ];
    } else if (selectedProductType == 'Hybrid') {
      // Hybrid can have both Assets and Consumables categories
      categories = [
        'IT & Technology Assets',
        'Office & Furniture Assets',
        'Machinery & Equipment',
        'Vehicles & Transportation',
        'Building & Facilities',
        'Intangible Assets',
        'Office Consumables',
        'IT Consumables',
        'Cleaning & Maintenance Supplies',
        'Industrial / Manufacturing Consumables',
        'Healthcare / Lab Consumables',
        'Food & Hospitality Consumables',
      ];
    }

    return categories
        .map((category) => {'key': category, 'value': category})
        .toList();
  }

  // Get subcategories based on selected category
  List<Map<String, String>> get availableSubcategories {
    if (selectedCategory == null ||
        !categorySubcategoryMap.containsKey(selectedCategory)) {
      return [];
    }

    return categorySubcategoryMap[selectedCategory]!
        .map((subcategory) => {'key': subcategory, 'value': subcategory})
        .toList();
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    orderDateController = TextEditingController();
    receivingDateController = TextEditingController();

    // Initialize with existing filters
    _initializeFilters();
  }

  void _initializeFilters() {
    // Set dropdown values
    selectedProductType = widget.initialFilters['productType'];
    selectedCategory = widget.initialFilters['category'];
    selectedSubcategory = widget.initialFilters['subcategory'];
    selectedSupplier = widget.initialFilters['supplier']; // ADD THIS LINE

    // Parse and set order date
    if (widget.initialFilters['orderDate'] != null &&
        widget.initialFilters['orderDate']!.isNotEmpty) {
      try {
        selectedOrderDate = DateTime.parse(widget.initialFilters['orderDate']!);
        orderDateController.text = _formatDate(selectedOrderDate!);
      } catch (e) {
        debugPrint('Error parsing order date: $e');
        selectedOrderDate = null;
      }
    }

    // Parse and set receiving date
    if (widget.initialFilters['receivingDate'] != null &&
        widget.initialFilters['receivingDate']!.isNotEmpty) {
      try {
        selectedReceivingDate = DateTime.parse(
          widget.initialFilters['receivingDate']!,
        );
        receivingDateController.text = _formatDate(selectedReceivingDate!);
      } catch (e) {
        debugPrint('Error parsing receiving date: $e');
        selectedReceivingDate = null;
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    // Properly dispose controllers
    orderDateController.dispose();
    receivingDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 700.w,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: lightMode ? Colors.white : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(lightMode),

            SizedBox(height: 20.sp),

            // Product Type and Supplier Row - UPDATED
            _buildProductTypeSupplierRow(),

            SizedBox(height: 16.sp),

            // Category and Subcategory Row
            _buildCategorySubcategoryRow(),

            SizedBox(height: 16.sp),

            // Date Fields Row
            _buildDateFieldsRow(),

            SizedBox(height: 24.sp),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool lightMode) {
    // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 30./30./16. row.
    return CustomDialogHeader(
        title: S.of(context).filter,
        icon: "assets/icons_assets/main_icons_assets/ic_action_filter.svg");
  }

  // REPLACE _buildProductTypeRow with this new method
  Widget _buildProductTypeSupplierRow() {
    return Row(
      children: [
        Expanded(
          child: CustomDropdown<String>(
            items: (productTypes)
                .map((e) => DropdownItem<String>(
                    value: e['key'] ?? '', label: e['value'] ?? ''))
                .toList(),
            value: selectedProductType,
            onChanged: (value) {
              setState(() {
                selectedProductType = value;
                selectedCategory = null;
                selectedSubcategory = null;
              });
            },
            label: 'Product Type',
            hint: 'Select Product Type',
            height: 36,
            labelGap: 4.sp,
          ),
        ),
        SizedBox(width: 15.w),
        // ADD SUPPLIER DROPDOWN
        Expanded(
          child: CustomDropdown<String>(
            items: (widget.availableSuppliers)
                .map((e) => DropdownItem<String>(
                    value: e['key'] ?? '', label: e['value'] ?? ''))
                .toList(),
            value: selectedSupplier,
            onChanged: (value) {
              setState(() {
                selectedSupplier = value;
              });
            },
            label: S.of(context).supplier,
            hint: 'Select Supplier',
            height: 36,
            labelGap: 4.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySubcategoryRow() {
    return Row(
      children: [
        Expanded(
          child: CustomDropdown<String>(
            items: (availableCategories)
                .map((e) => DropdownItem<String>(
                    value: e['key'] ?? '', label: e['value'] ?? ''))
                .toList(),
            value: selectedCategory,
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
                selectedSubcategory = null;
              });
            },
            label: S.of(context).category,
            hint: S.of(context).selectCategory,
            height: 36,
            labelGap: 4.sp,
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: CustomDropdown<String>(
            items: (availableSubcategories)
                .map((e) => DropdownItem<String>(
                    value: e['key'] ?? '', label: e['value'] ?? ''))
                .toList(),
            value: selectedSubcategory,
            onChanged: (value) {
              setState(() {
                selectedSubcategory = value;
              });
            },
            label: S.of(context).subcategory,
            hint: S.of(context).selectSubcategory,
            height: 36,
            labelGap: 4.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildDateFieldsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            controller: orderDateController,
            label: S.of(context).orderDate,
            hint: 'Select Order Date',
            isOrderDate: true,
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: _buildDateField(
            controller: receivingDateController,
            label: S.of(context).receivingDate,
            hint: S.of(context).selectReceivingDate,
            isOrderDate: false,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isOrderDate,
  }) {
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () => _selectDate(context, isOrderDate),
      child: AbsorbPointer(
        child: CustomValidatedTextFieldMaster(
          enabled: true,
          label: label,
          height: 36,
          hint: hint,
          controller: controller,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        customButton(
          title: S.of(context).reset,
          function: _resetFilters,
          color: AppColors.grey,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.blackButton,
          ),
          radius: 8.r,
          width: 135.w,
          height: 38.h,
        ),
        const Spacer(),
        customButton(
          title: S.of(context).apply,
          function: _applyFilters,
          color: AppColors.primary,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
          radius: 8.r,
          width: 135.w,
          height: 38.h,
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isOrderDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isOrderDate ? selectedOrderDate : selectedReceivingDate) ??
          DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOrderDate) {
          selectedOrderDate = picked;
          orderDateController.text = _formatDate(picked);
        } else {
          selectedReceivingDate = picked;
          receivingDateController.text = _formatDate(picked);
        }
      });
    }
  }

  // UPDATE _resetFilters method
  void _resetFilters() {
    setState(() {
      selectedProductType = null;
      selectedCategory = null;
      selectedSubcategory = null;
      selectedSupplier = null; // ADD THIS LINE
      selectedOrderDate = null;
      selectedReceivingDate = null;
      orderDateController.clear();
      receivingDateController.clear();
    });
  }

  // UPDATE _applyFilters method
  void _applyFilters() {
    final filters = <String, String>{};

    if (selectedProductType != null && selectedProductType!.isNotEmpty) {
      filters['productType'] = selectedProductType!;
    }
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      filters['category'] = selectedCategory!;
    }
    if (selectedSubcategory != null && selectedSubcategory!.isNotEmpty) {
      filters['subcategory'] = selectedSubcategory!;
    }
    if (selectedSupplier != null && selectedSupplier!.isNotEmpty) {
      filters['supplier'] = selectedSupplier!; // ADD THIS
    }
    if (selectedOrderDate != null) {
      filters['orderDate'] = selectedOrderDate!.toIso8601String();
    }
    if (selectedReceivingDate != null) {
      filters['receivingDate'] = selectedReceivingDate!.toIso8601String();
    }

    // Call the callback function
    widget.onApplyFilter(filters);

    // Close the dialog
    Navigator.of(context).pop();
  }
}
