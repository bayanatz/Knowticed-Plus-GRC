import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/domain/models/storage_location_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart'
    show ProductModel;
import 'package:path_provider/path_provider.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_response_dialog.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

// Inventory Export Dialog
class InventoryExportDialog extends StatefulWidget {
  final String selectedCategory;
  final List<ProductModel>? products;
  final List<ProductModel>? orders;
  final List<SupplierModel>? suppliers;
  final List<StorageLocation>? storageLocations;

  const InventoryExportDialog({
    super.key,
    required this.selectedCategory,
    this.products,
    this.orders,
    this.suppliers,
    this.storageLocations,
  });

  @override
  State<InventoryExportDialog> createState() => _InventoryExportDialogState();
}

class _InventoryExportDialogState extends State<InventoryExportDialog> {
  final TextEditingController controller = TextEditingController();
  OverlayEntry? _overlayEntry;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // Set default filename based on category
    controller.text = _getDefaultFileName();
  }

  String _getDefaultFileName() {
    final now = DateTime.now();

    // Month names array
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    // Format date as "20 Sep 2025"
    final dateStr = "${now.day} ${months[now.month - 1]} ${now.year}";

    // Capitalize the category name
    final categoryName = widget.selectedCategory.toLowerCase();
    final capitalizedCategory =
        categoryName[0].toUpperCase() + categoryName.substring(1);

    return "${capitalizedCategory}_export_$dateStr";
  }

  Future<void> _showLoadingIndicator(BuildContext context) async {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(alpha: 0.3),
          ),
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const CircleProgressMaster.inline(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(_overlayEntry!);
  }

  void _hideLoadingIndicator() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _exportData(BuildContext context) async {
    if (_isExporting) return;

    final fileName = controller.text.trim();
    if (fileName.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a file name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      await _showLoadingIndicator(context);

      // Check if there's data to export
      if (!_hasDataToExport()) {
        _hideLoadingIndicator();
        setState(() {
          _isExporting = false;
        });
        Get.snackbar(
          'No Data',
          'No ${widget.selectedCategory.toLowerCase()} to export',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();

      // Ensure filename has .csv extension
      String finalFileName =
          fileName.toLowerCase().endsWith('.csv') ? fileName : '$fileName.csv';

      final filePath = '${directory.path}/$finalFileName';
      final file = File(filePath);

      // Generate CSV based on category
      String csvContent = _generateCSVContent();

      // Write file
      await file.writeAsString(csvContent);

      _hideLoadingIndicator();
      setState(() {
        _isExporting = false;
      });

      // Close dialog
      if (!context.mounted) return;
      if (Navigator.canPop(context)) {
        if (!context.mounted) return;
        Navigator.pop(context);
      }

      if (!context.mounted) return;
      showAppDialog(
        context: context,
        builder: (dialogContext) => ResponseDialog(
          title: S.of(context).success,
          subtitle: S.of(context).successDownloadFile,
          lottieAsset:
              'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
        ),
      );
    } catch (e) {
      debugPrint("Export Error: $e");
      _hideLoadingIndicator();
      setState(() {
        _isExporting = false;
      });

      Get.snackbar(
        '❌ Export Failed',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  bool _hasDataToExport() {
    switch (widget.selectedCategory) {
      case 'Products':
      case 'Assets':
      case 'Consumables':
        return widget.products?.isNotEmpty ?? false;
      case 'Orders':
        return widget.orders?.isNotEmpty ?? false;
      case 'Suppliers':
        return widget.suppliers?.isNotEmpty ?? false;
      case 'Storage Locations':
        return widget.storageLocations?.isNotEmpty ?? false;
      default:
        return false;
    }
  }

  String _generateCSVContent() {
    switch (widget.selectedCategory) {
      case 'Products':
      case 'Assets':
      case 'Consumables':
        return _generateProductsCSV();
      case 'Orders':
        return _generateOrdersCSV();
      case 'Suppliers':
        return _generateSuppliersCSV();
      case 'Storage Locations':
        return _generateStorageLocationsCSV();
      default:
        return '';
    }
  }

  String _generateProductsCSV() {
    if (widget.products == null || widget.products!.isEmpty) return '';

    List<List<dynamic>> rows = [
      [
        'No',
        'Product ID',
        'Product Name',
        'Type',
        'Supplier',
        'Quantity',
        'Status',
        'Storage Location',
        'Reorder Level',
        'Last Update',
      ],
    ];

    for (int i = 0; i < widget.products!.length; i++) {
      final product = widget.products![i];
      final quantity = int.tryParse(product.quantity.value) ?? 0;
      final reorderLevel = int.tryParse(product.reorderLevel.value) ?? 0;

      String status = 'In Stock';
      if (quantity == 0) {
        status = 'Out of Stock';
      } else if (quantity <= reorderLevel) {
        status = 'Low Stock';
      }

      rows.add([
        i + 1,
        _safeString(product.productId.value),
        _safeString(product.productName.value),
        _safeString(product.status.value),
        _safeString(product.supplierName.value),
        quantity,
        status,
        _safeString(product.storageLocation.value),
        reorderLevel,
        _formatDate(product.orderDate.timestamp),
      ]);
    }

    return _convertToCSV(rows);
  }

  String _generateOrdersCSV() {
    if (widget.orders == null || widget.orders!.isEmpty) return '';

    List<List<dynamic>> rows = [
      [
        'Order ID',
        'Order Type',
        'Order Date',
        'Order Note',
        'Status',
        'Last Update',
        'Expected Delivery',
        'Received Date',
        'Received By',
        'Delivery Method',
        'Product ID',
        'Category',
        'Subcategory',
        'Brand Model',
        'Quantity Ordered',
        'Quantity Received',
        'Supplier Name',
        'Storage Location',
        'Invoice ID',
        'Currency',
        'Unit Cost',
        'Payment Type',
        'Advanced Deposits',
      ],
    ];

    for (int i = 0; i < widget.orders!.length; i++) {
      final order = widget.orders![i];
      final brandModel = '${order.brand.value} ${order.model.value}'.trim();

      rows.add([
        _safeString(order.orderId.value),
        _safeString(order.orderType.value),
        _formatDate(order.orderDate.timestamp),
        _safeString(order.orderNote.value),
        _safeString(order.status.value),
        _formatDate(
          order.orderDate.timestamp,
        ), // Last Update - adjust field as needed
        _formatDate(order.expectedDelivery.timestamp),
        _formatDate(order.receivingDate.timestamp),
        _safeString(
          order.firstNameCreator.value,
        ), // Received By - adjust field as needed
        _safeString(order.deliveryMethod.value),
        _safeString(order.productId.value),
        _safeString(order.category.value),
        _safeString(order.subCategory.value),
        brandModel.isEmpty ? '-' : _safeString(brandModel),
        _safeString(order.quantity.value),
        '-', // Quantity Received - add actual field when available
        _safeString(order.supplierName.value),
        _safeString(order.storageLocation.value),
        _safeString(order.orderId.value), // Invoice ID - adjust field as needed
        _safeString(order.currency.value),
        _safeString(order.unitCost.value),
        _safeString(order.paymentMethod.value),
        '-', // Advanced Deposits - add actual field when available
      ]);
    }

    return _convertToCSV(rows);
  }

  // COMPLETE Suppliers CSV Export with ALL 57 fields
  String _generateSuppliersCSV() {
    if (widget.suppliers == null || widget.suppliers!.isEmpty) return '';

    List<List<dynamic>> rows = [
      [
        'Supplier ID',
        'Supplier Name',
        'Business Type',
        'Tax Number',
        'Business Registration Number',
        'Supplier Rank',
        'Created By',
        'Date Added',
        'Point Of Contact',
        'First Name',
        'Middle Name',
        'Last Name',
        'Title',
        'Phone Number',
        'Email',
        'Preferred Language',
        'Beneficiary Name',
        'Beneficiary Bank Name',
        'Beneficiary Bank Account Number / IBAN',
        'Bank SWIFT/BIC Code',
        'Bank Address',
        'Supplier Name',
        'Storage Location Address',
        'Country',
        'State or Province',
        'City',
        'Postal Code',
        'Street Name',
        'Warehouse Country',
        'State or Province',
        'City',
        'Postal Code',
        'Street Name',
        'Contract Start Date',
        'Contract End Date',
        'Contract Document',
        'Tax Certificate',
        'Registration Document',
      ],
    ];

    for (int i = 0; i < widget.suppliers!.length; i++) {
      final supplier = widget.suppliers![i];

      rows.add([
        _safeString(supplier.supplierID),
        _safeString(supplier.supplierName),
        _safeString(supplier.businessType),
        _safeString(supplier.taxNumber),
        _safeString(supplier.businessRegistrationNumber),
        _safeString(supplier.supplierRank),
        _safeString(supplier.createdBy),
        _formatSupplierDate(supplier.dateAdded),
        _safeString(supplier.contactBy), // Point Of Contact
        _safeString(supplier.firstName),
        _safeString(supplier.middleName),
        _safeString(supplier.lastName),
        _safeString(supplier.title),
        _safeString(supplier.phoneNumber),
        _safeString(supplier.email),
        _safeString(supplier.preferredLanguage),
        _safeString(supplier.beneficiaryName),
        _safeString(supplier.beneficiaryBankName),
        _safeString(supplier.beneficiaryBankAccountNumberIBAN),
        _safeString(supplier.bankSWIFTBICCode),
        _safeString(supplier.bankAddress),
        _safeString(
          supplier.supplierName,
        ), // Supplier Name (repeated as per your order)
        _safeString(supplier.warehouseAddress), // Storage Location Address
        _safeString(supplier.country),
        _safeString(supplier.stateOrProvince),
        _safeString(supplier.city),
        _safeString(supplier.postalCode),
        _safeString(supplier.streetName),
        _safeString(supplier.warehouseCountry), // Warehouse Country
        _safeString(
          supplier.warehouseStateOrProvince,
        ), // Warehouse State or Province
        _safeString(supplier.warehouseCity), // Warehouse City
        _safeString(supplier.warehousePostalCode), // Warehouse Postal Code
        _safeString(supplier.warehouseStreetName), // Warehouse Street Name
        _formatSupplierDate(supplier.contractStartDate),
        _formatSupplierDate(supplier.contractEndDate),
        _safeString(supplier.contractStatus), // Contract Document
        _safeString(supplier.taxCertificateFileName), // Tax Certificate
        _safeString(
          supplier.registrationDocumentFileName,
        ), // Registration Document
      ]);
    }

    return _convertToCSV(rows);
  }

  // Add this method to your _InventoryExportDialogState class

  String _formatSupplierDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      // Parse the date string - adjust format based on your actual date format
      DateTime date;

      // If the date is already in "12 Aug 2023" format, return as-is
      if (RegExp(r'^\d{1,2}\s\w{3}\s\d{4}$').hasMatch(dateString.trim())) {
        return dateString.trim();
      }

      // Try to parse common date formats
      if (dateString.contains('/')) {
        // Handle formats like "12/08/2023" or "2023/08/12"
        List<String> parts = dateString.split('/');
        if (parts.length == 3) {
          // Assume DD/MM/YYYY format
          date = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        } else {
          return dateString; // Return original if can't parse
        }
      } else if (dateString.contains('-')) {
        // Handle formats like "2023-08-12" or "12-08-2023"
        List<String> parts = dateString.split('-');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            // YYYY-MM-DD format
            date = DateTime(
              int.parse(parts[0]), // year
              int.parse(parts[1]), // month
              int.parse(parts[2]), // day
            );
          } else {
            // DD-MM-YYYY format
            date = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          }
        } else {
          return dateString; // Return original if can't parse
        }
      } else {
        // Try to parse as DateTime directly
        date = DateTime.parse(dateString);
      }

      // Format to "12 Aug 2023"
      return _formatDateToMonthName(date);
    } catch (e) {
      debugPrint("Error parsing supplier date: $dateString, Error: $e");
      return dateString; // Return original string if parsing fails
    }
  }

  String _formatDateToMonthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _generateStorageLocationsCSV() {
    if (widget.storageLocations == null || widget.storageLocations!.isEmpty) {
      return '';
    }

    List<List<dynamic>> rows = [
      [
        'No',
        'Location ID',
        'Location Name',
        'Country',
        'State/Province',
        'City',
        'Postal Code',
        'Branch Name',
        'Status',
        'Area',
        'Created By',
        'Date Added',
        'Assigned Department',
        'Access Level',
        'Storage Capacity',
        'Capacity Unit',
        'Storage Condition',
        'Equipment Available',
        'Additional Note',
        'Employees',
      ],
    ];

    for (int i = 0; i < widget.storageLocations!.length; i++) {
      final location = widget.storageLocations![i];

      // Format employee names
      String employeeNames = location.employee.value
          .map((emp) => emp.firstName ?? 'Unknown')
          .join(', ');

      rows.add([
        i + 1,
        _safeString(location.id.value),
        _safeString(location.name.value),
        _safeString(location.country.value),
        _safeString(location.stateOrProvince.value),
        _safeString(location.city.value),
        _safeString(location.postalCode.value),
        _safeString(location.branchName.value),
        _safeString(location.status.value),
        _safeString(location.area.value),
        _safeString(location.createdBy.value),
        _formatDate(location.dateAdded.value),
        _safeString(location.assignedDepartment.value),
        _safeString(location.accessLevel.value),
        _safeString(location.storageCapacity.value.toString()),
        _safeString(location.capacityUnit.value),
        _safeString(location.conditionOfStorage.value),
        _safeString(location.equipmentAvailable.value),
        _safeString(location.additionalNote.value),
        employeeNames.isEmpty ? '-' : employeeNames,
      ]);
    }

    return _convertToCSV(rows);
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    String str = value.toString();
    // Escape quotes and commas for CSV
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      str = '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _convertToCSV(List<List<dynamic>> rows) {
    StringBuffer csvBuffer = StringBuffer();
    for (List<dynamic> row in rows) {
      csvBuffer.writeln(row.join(','));
    }
    return csvBuffer.toString();
  }

  @override
  void dispose() {
    _hideLoadingIndicator();
    controller.dispose();
    super.dispose();
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 900 && isLandscape;
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        width: 411.sp,
        height: isMobile
            ? 215.h
            : !isTabletLandscape(context)
                ? 185.h
                : 230.h,
        child: Padding(
          padding: EdgeInsets.only(
            top: 20.sp,
            left: 20.sp,
            right: 20.sp,
            bottom: 15.sp,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 30.sp,
                    height: 30.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: Center(
                      child: CustomSvgImage.natural(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                        width: 16.sp,
                        height: 16.sp,
                        color: AppColors.textButton,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    ' ${S.of(context).export} ${widget.selectedCategory}',
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.blackButton,
                    ),
                  ),
                ],
              ),
              // SizedBox(height: 15.sp),

              // // Info text
              // Text(
              //   '"${S.of(context).export}" ${_getDataCount()} ${widget.selectedCategory.toLowerCase()} to CSV file',
              //   style: StyleText.fontSize14Weight400.copyWith(
              //     color: AppColors.secondaryText,
              //   ),
              // ),
              SizedBox(height: 15.sp),

              // Filename input
              CustomValidatedTextFieldMaster(
                label: S.of(context).fileName,
                hint: S.of(context).textHere,
                controller: controller,
                height: 36,
                onChanged: (_) => setState(() {}),
              ),

              SizedBox(height: 20.sp),

              // Buttons
              Row(
                textDirection: TextDirection
                    .ltr, // X-73: Cancel left, action right in both languages

                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customButton(
                    title: S.of(context).discard,
                    width: isMobile ? 100.w : 135.w,
                    color: _isExporting ? Colors.grey : const Color(0xcccccccc),
                    height: 38.sp,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: _isExporting
                          ? Colors.grey[600]
                          : const Color(0xff2D2D2D),
                    ),
                    radius: 8.r,
                    function: () {
                      if (!_isExporting) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  customButton(
                    title: _isExporting ? "Exporting..." : 'Export CSV',
                    width: isMobile ? 100.w : 135.w,
                    color: _isExporting ? Colors.grey : AppColors.primary,
                    height: 38.sp,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton,
                    ),
                    radius: 8.r,
                    function: () {
                      if (!_isExporting) {
                        _exportData(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
