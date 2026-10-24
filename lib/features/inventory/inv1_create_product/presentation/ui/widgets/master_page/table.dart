// Products Table Widget
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:knowticed_plus/core/custom/layout/fill_width_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/domain/models/storage_location_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/supplier_view_details.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/pages/view_storage_location_details_toggle.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ProductsTableWidget extends StatelessWidget {
  final List<ProductModel> products;
  final String locale;

  const ProductsTableWidget({
    super.key,
    required this.products,
    required this.locale,
  });

  bool get _isArabic => locale.toLowerCase().startsWith('ar');

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight600.copyWith(color: Colors.white);

  TextStyle _cellStyle(BuildContext context) => TextStyle(
        fontSize: 13.sp,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black87
            : AppColors.white,
      );

  // Individual width calculation methods for each column

  double _calculateOrderIDWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.orderId.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          product.orderId.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 10.sp) + 20.w, 180.w);
    double minWidth = context.isPortrait ? 80.w : 90.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateProductIDWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.productId.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          product.productId.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 10.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 100.w : 100.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateCategoryWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.category.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          product.category.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 150.w);
    double minWidth = context.isPortrait ? 90.w : 110.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateSubcategoryWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.subCategory.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          product.subCategory.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 150.w);
    double minWidth = context.isPortrait ? 90.w : 110.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateModelWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.model.value.isNotEmpty) {
        maxLength = math.max(maxLength, product.model.value.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 150.w);
    double minWidth = context.isPortrait ? 80.w : 100.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateBrandWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.brand.value.isNotEmpty) {
        maxLength = math.max(maxLength, product.brand.value.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 150.w);
    double minWidth = context.isPortrait ? 80.w : 100.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateMaintenanceFrequencyWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.maintenanceFrequency.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          product.maintenanceFrequency.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 180.w : 180.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 180.w : 180.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateUsageFrequencyWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.usageFrequency.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          product.usageFrequency.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 140.w : 150.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateUnitOfMeasurementWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.unitOfMeasurement.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          product.unitOfMeasurement.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 180.w : 180.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 180.w : 180.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateQuantityWidth(BuildContext context) {
    return context.isPortrait ? 80.w : 90.w;
  }

  double _calculateUnitCostWidth(BuildContext context) {
    return context.isPortrait ? 100.w : 120.w;
  }

  double _calculateCurrencyWidth(BuildContext context) {
    return context.isPortrait ? 80.w : 90.w;
  }

  double _calculateSupplierNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.supplierName.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          product.supplierName.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 140.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 200.w);
    double minWidth = context.isPortrait ? 100.w : 120.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateStorageRequirementWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.storageRequirement.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          product.storageRequirement.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 140.w : 150.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateExpectedLifetimeWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.expectedLifetime.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          product.expectedLifetime.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 140.w : 150.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateReorderLevelWidth(BuildContext context) {
    return context.isPortrait ? 120.w : 130.w;
  }

  double _calculateReorderQuantityWidth(BuildContext context) {
    return context.isPortrait ? 140.w : 150.w;
  }

  double _calculateAdditionalNoteWidth(BuildContext context) {
    return context.isPortrait ? 150.w : 200.w;
  }

  double _calculateStorageLocationWidth(BuildContext context) {
    double maxLength = 0;
    for (var product in products) {
      if (product.storageLocation.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          product.storageLocation.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 100.w : 130.w;
    return math.max(calculatedWidth, minWidth);
  }

  Widget _cell(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(style: _cellStyle(context), child: child),
    );
  }

  Widget _textCell(BuildContext context, String text, {int maxLines = 2}) {
    return _cell(
      context,
      Text(
        text.isEmpty ? '-' : text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final headers = <String>[
      _isArabic ? 'رقم الطلب' : 'Order ID',
      _isArabic ? 'رقم المنتج' : 'Product ID',
      _isArabic ? 'الفئة' : 'Category',
      _isArabic ? 'الفئة الفرعية' : 'Subcategory',
      _isArabic ? 'الموديل' : 'Model',
      _isArabic ? 'العلامة التجارية' : 'Brand',
      _isArabic ? 'تكرار الصيانة' : 'Maintenance Frequency',
      _isArabic ? 'تكرار الاستخدام' : 'Usage Frequency',
      _isArabic ? 'وحدة القياس' : 'Unit Of Measurement',
      _isArabic ? 'الكمية' : 'Quantity',
      _isArabic ? 'تكلفة الوحدة' : 'Unit Cost',
      _isArabic ? 'العملة' : 'Currency',
      _isArabic ? 'اسم المورد' : 'Supplier Name',
      _isArabic ? 'متطلبات التخزين' : 'Storage Requirement',
      _isArabic ? 'العمر المتوقع' : 'Expected Lifetime',
      _isArabic ? 'مستوى إعادة الطلب' : 'Reorder Level',
      _isArabic ? 'كمية إعادة الطلب' : 'Reorder Quantity',
      _isArabic ? 'ملاحظة إضافية' : 'Additional Note',
      _isArabic ? 'موقع التخزين' : 'Storage Location',
    ];

    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(_calculateOrderIDWidth(context)),
      1: FixedColumnWidth(_calculateProductIDWidth(context)),
      2: FixedColumnWidth(_calculateCategoryWidth(context)),
      3: FixedColumnWidth(_calculateSubcategoryWidth(context)),
      4: FixedColumnWidth(_calculateModelWidth(context)),
      5: FixedColumnWidth(_calculateBrandWidth(context)),
      6: FixedColumnWidth(_calculateMaintenanceFrequencyWidth(context)),
      7: FixedColumnWidth(_calculateUsageFrequencyWidth(context)),
      8: FixedColumnWidth(_calculateUnitOfMeasurementWidth(context)),
      9: FixedColumnWidth(_calculateQuantityWidth(context)),
      10: FixedColumnWidth(_calculateUnitCostWidth(context)),
      11: FixedColumnWidth(_calculateCurrencyWidth(context)),
      12: FixedColumnWidth(_calculateSupplierNameWidth(context)),
      13: FixedColumnWidth(_calculateStorageRequirementWidth(context)),
      14: FixedColumnWidth(_calculateExpectedLifetimeWidth(context)),
      16: FixedColumnWidth(_calculateReorderLevelWidth(context)),
      17: FixedColumnWidth(_calculateReorderQuantityWidth(context)),
      18: FixedColumnWidth(_calculateAdditionalNoteWidth(context)),
      19: FixedColumnWidth(_calculateStorageLocationWidth(context)),
    };

    return AnimatedSizeWrap(
      // Tables animate their size (rows added / removed / filtered).
      child: Directionality(
        textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        // Owner 21/10/2026: full width, equal column shares (No stays narrow); scrolls when the columns cannot fit.
        child: FillWidthHorizontalScroll(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: Table(
              border: TableBorder.all(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.sp),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: fillColumnWidths(columnWidths),
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(
                    color: lightMode ? Colors.black : Colors.black45,
                  ),
                  children: headers
                      .map(
                        (name) => Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Text(
                            name,
                            style: _headerStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      )
                      .toList(),
                ),

                // Data Rows
                ...List.generate(products.length, (index) {
                  final product = products[index];
                  final isEven = index.isEven;
                  final rowColor = lightMode
                      ? (isEven ? const Color(0xFFF7F8FA) : Colors.white)
                      : (isEven ? const Color(0xFF1E1F24) : Colors.black);

                  return TableRow(
                    decoration: BoxDecoration(color: rowColor),
                    children: [
                      _textCell(context, product.orderId.value, maxLines: 1),
                      _textCell(context, product.productId.value, maxLines: 1),
                      _textCell(context, product.category.value),
                      _textCell(context, product.subCategory.value),
                      _textCell(context, product.model.value),
                      _textCell(context, product.brand.value),
                      _textCell(context, product.maintenanceFrequency.value),
                      _textCell(context, product.usageFrequency.value),
                      _textCell(
                        context,
                        product.unitOfMeasurement.value,
                        maxLines: 1,
                      ),
                      _textCell(context, product.quantity.value, maxLines: 1),
                      _textCell(context, product.unitCost.value, maxLines: 1),
                      _textCell(context, product.currency.value, maxLines: 1),
                      _textCell(context, product.supplierName.value),
                      _textCell(context, product.storageRequirement.value),
                      _textCell(context, product.expectedLifetime.value),
                      _textCell(context, product.reorderLevel.value,
                          maxLines: 1),
                      _textCell(
                        context,
                        product.reorderQuantity.value,
                        maxLines: 1,
                      ),
                      _textCell(
                        context,
                        product.additionalNote.value,
                        maxLines: 3,
                      ),
                      _textCell(context, product.storageLocation.value),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Orders Table Widget
// Order Preview Table Widget - Comprehensive display of all order data
class OrderPreviewTableWidget extends StatelessWidget {
  final List<ProductModel> orders;
  final String locale;

  const OrderPreviewTableWidget({
    super.key,
    required this.orders,
    required this.locale,
  });

  bool get _isArabic => locale.toLowerCase().startsWith('ar');

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight600.copyWith(color: Colors.white);

  TextStyle _cellStyle(BuildContext context) {
    return StyleText.fontSize13Weight400.copyWith(
      color: AppColors.blackButton,
    );
  }

  // Individual width calculation methods for each field in the new order

  double _calculateOrderIDWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      if (order.orderId.value.isNotEmpty) {
        maxLength = math.max(maxLength, order.orderId.value.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 10.sp) + 20.w, 180.w);
    double minWidth = context.isPortrait ? 50.w : 50.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateOrderTypeWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      if (order.orderType.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          order.orderType.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 30.w, 150.w);
    double minWidth = context.isPortrait ? 90.w : 100.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateOrderDateWidth(BuildContext context) {
    return context.isPortrait ? 120.w : 120.w;
  }

  double _calculateOrderNoteWidth(BuildContext context) {
    return context.isPortrait ? 150.w : 200.w;
  }

  double _calculateStatusWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      if (order.status.value.isNotEmpty) {
        maxLength = math.max(maxLength, order.status.value.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 150.w);
    double minWidth = context.isPortrait ? 100.sp : 100.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateLastUpdateWidth(BuildContext context) {
    return context.isPortrait ? 120.w : 120.w;
  }

  double _calculateExpectedDeliveryWidth(BuildContext context) {
    return context.isPortrait ? 140.w : 140.w;
  }

  double _calculateReceivedDateWidth(BuildContext context) {
    return context.isPortrait ? 140.w : 140.w;
  }

  double _calculateReceivedByWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      // Assuming this would be a field like receivedBy or similar
      String receivedBy =
          order.firstNameCreator.value; // Adjust based on actual field
      if (receivedBy.isNotEmpty) {
        maxLength = math.max(maxLength, receivedBy.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 120.w : 120.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateDeliveryMethodWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      if (order.deliveryMethod.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          order.deliveryMethod.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 130.w : 130.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateProductIDWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      if (order.productId.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          order.productId.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 10.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 100.w : 100.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateCategoryWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      if (order.category.value.isNotEmpty) {
        maxLength = math.max(maxLength, order.category.value.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 150.w);
    double minWidth = context.isPortrait ? 90.w : 110.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateSubcategoryWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      if (order.subCategory.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          order.subCategory.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 150.w);
    double minWidth = context.isPortrait ? 90.w : 110.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateBrandModelWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      String brandModel = '${order.brand.value} ${order.model.value}'.trim();
      if (brandModel.isNotEmpty) {
        maxLength = math.max(maxLength, brandModel.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 200.w);
    double minWidth = context.isPortrait ? 120.w : 120.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateQuantityOrderedWidth(BuildContext context) {
    return context.isPortrait ? 140.w : 140.w;
  }

  double _calculateQuantityReceivedWidth(BuildContext context) {
    return context.isPortrait ? 140.w : 140.w;
  }

  double _calculateSupplierNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      if (order.supplierName.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          order.supplierName.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 140.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 200.w);
    double minWidth = context.isPortrait ? 100.w : 120.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateStorageLocationWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      if (order.storageLocation.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          order.storageLocation.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 100.w : 130.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateInvoiceIDWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      // Assuming there's an invoiceId field or similar
      String invoiceId = order.orderId.value; // Adjust based on actual field
      if (invoiceId.isNotEmpty) {
        maxLength = math.max(maxLength, invoiceId.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 10.sp) + 20.w, 180.w);
    double minWidth = context.isPortrait ? 80.w : 80.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateCurrencyWidth(BuildContext context) {
    return context.isPortrait ? 80.w : 90.w;
  }

  double _calculateUnitCostWidth(BuildContext context) {
    return context.isPortrait ? 100.w : 120.w;
  }

  double _calculatePaymentTypeWidth(BuildContext context) {
    double maxLength = 0;
    for (var order in orders) {
      if (order.paymentMethod.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          order.paymentMethod.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 180.w : 180.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 200.w);
    double minWidth = context.isPortrait ? 140.w : 140.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateAdvancedDepositsWidth(BuildContext context) {
    return context.isPortrait ? 160.w : 160.w;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "open":
        return Color(0xffE5B800);
      case "received":
        return Color(0xff4BB609);
      case "partially received":
      case "partially_received":
        return Color(0xffFF814A);
      case "cancelled":
      case "cancel":
        return Color(0xffDF1C1C);
      case "draft":
        return Color(0xff797979);
      default:
        return Colors.grey;
    }
  }

  Widget _cell(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(style: _cellStyle(context), child: child),
    );
  }

  Widget _textCell(BuildContext context, String text, {int maxLines = 2}) {
    return _cell(
      context,
      Text(
        text.isEmpty ? '-' : text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty || dateString == "N/A") return '-';
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // Headers in the new specified order
    final headers = <String>[
      _isArabic ? 'رقم الطلب' : 'Order ID',
      _isArabic ? 'نوع الطلب' : 'Order Type',
      _isArabic ? 'تاريخ الطلب' : 'Order Date',
      _isArabic ? 'ملاحظة الطلب' : 'Order Note',
      _isArabic ? 'الحالة' : 'Status',
      _isArabic ? 'آخر تحديث' : 'Last Update',
      _isArabic ? 'تاريخ الاستلام المتوقع' : 'Expected Delivery',
      _isArabic ? 'تاريخ الاستلام' : 'Received Date',
      _isArabic ? 'استلمت من قبل' : 'Received By',
      _isArabic ? 'طريقة التسليم' : 'Delivery Method',
      _isArabic ? 'رقم المنتج' : 'Product ID',
      _isArabic ? 'الفئة' : 'Category',
      _isArabic ? 'الفئة الفرعية' : 'Subcategory',
      _isArabic ? 'العلامة التجارية/النموذج' : 'Brand Model',
      _isArabic ? 'الكمية المطلوبة' : 'Quantity Ordered',
      _isArabic ? 'الكمية المستلمة' : 'Quantity Received',
      _isArabic ? 'اسم المورد' : 'Supplier Name',
      _isArabic ? 'موقع التخزين' : 'Storage Location',
      _isArabic ? 'رقم الفاتورة' : 'Invoice ID',
      _isArabic ? 'العملة' : 'Currency',
      _isArabic ? 'تكلفة الوحدة' : 'Unit Cost',
      _isArabic ? 'نوع الدفع' : 'Payment Type',
      _isArabic ? 'الدفعات المقدمة' : 'Advanced Deposits',
    ];

    // Column widths in the new order
    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(_calculateOrderIDWidth(context)),
      1: FixedColumnWidth(_calculateOrderTypeWidth(context)),
      2: FixedColumnWidth(_calculateOrderDateWidth(context)),
      3: FixedColumnWidth(_calculateOrderNoteWidth(context)),
      4: FixedColumnWidth(_calculateStatusWidth(context)),
      5: FixedColumnWidth(_calculateLastUpdateWidth(context)),
      6: FixedColumnWidth(_calculateExpectedDeliveryWidth(context)),
      7: FixedColumnWidth(_calculateReceivedDateWidth(context)),
      8: FixedColumnWidth(_calculateReceivedByWidth(context)),
      9: FixedColumnWidth(_calculateDeliveryMethodWidth(context)),
      10: FixedColumnWidth(_calculateProductIDWidth(context)),
      11: FixedColumnWidth(_calculateCategoryWidth(context)),
      12: FixedColumnWidth(_calculateSubcategoryWidth(context)),
      13: FixedColumnWidth(_calculateBrandModelWidth(context)),
      14: FixedColumnWidth(_calculateQuantityOrderedWidth(context)),
      15: FixedColumnWidth(_calculateQuantityReceivedWidth(context)),
      16: FixedColumnWidth(_calculateSupplierNameWidth(context)),
      17: FixedColumnWidth(_calculateStorageLocationWidth(context)),
      18: FixedColumnWidth(_calculateInvoiceIDWidth(context)),
      19: FixedColumnWidth(_calculateCurrencyWidth(context)),
      20: FixedColumnWidth(_calculateUnitCostWidth(context)),
      21: FixedColumnWidth(_calculatePaymentTypeWidth(context)),
      22: FixedColumnWidth(_calculateAdvancedDepositsWidth(context)),
    };

    return AnimatedSizeWrap(
      // Tables animate their size (rows added / removed / filtered).
      child: Directionality(
        textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        // Owner 21/10/2026: full width, equal column shares (No stays narrow); scrolls when the columns cannot fit.
        child: FillWidthHorizontalScroll(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: Table(
              border: TableBorder.all(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.sp),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: fillColumnWidths(columnWidths),
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(
                    color: lightMode ? Colors.black : Colors.black45,
                  ),
                  children: headers
                      .map(
                        (name) => Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Text(
                            name,
                            style: _headerStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      )
                      .toList(),
                ),

                // Data Rows
                ...List.generate(orders.length, (index) {
                  final order = orders[index];
                  final isEven = index.isEven;
                  final rowColor = lightMode
                      ? (isEven ? const Color(0xFFF7F8FA) : Colors.white)
                      : (isEven ? const Color(0xFF1E1F24) : Colors.black);

                  final statusColor = _getStatusColor(order.status.value);
                  final brandModel =
                      '${order.brand.value} ${order.model.value}'.trim();

                  return TableRow(
                    decoration: BoxDecoration(color: rowColor),
                    children: [
                      _textCell(context, order.orderId.value, maxLines: 1),
                      _textCell(context, order.orderType.value),
                      _textCell(
                        context,
                        _formatDate(order.orderDate.value),
                        maxLines: 1,
                      ),
                      _textCell(context, order.orderNote.value, maxLines: 3),
                      _cell(
                        context,
                        Text(
                          order.status.value,
                          style: _cellStyle(context).copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _textCell(
                        context,
                        _formatDate(order.orderDate.value),
                        maxLines: 1,
                      ), // Last Update - adjust field as needed
                      _textCell(
                        context,
                        _formatDate(order.expectedDelivery.value),
                        maxLines: 1,
                      ),
                      _textCell(
                        context,
                        _formatDate(order.receivingDate.value),
                        maxLines: 1,
                      ),
                      _textCell(
                        context,
                        order.firstNameCreator.value,
                      ), // Received By - adjust field as needed
                      _textCell(context, order.deliveryMethod.value),
                      _textCell(context, order.productId.value, maxLines: 1),
                      _textCell(context, order.category.value),
                      _textCell(context, order.subCategory.value),
                      _textCell(context, brandModel.isEmpty ? '-' : brandModel),
                      _textCell(context, order.quantity.value, maxLines: 1),
                      _textCell(
                        context,
                        '-',
                        maxLines: 1,
                      ), // Quantity Received - add actual field
                      _textCell(context, order.supplierName.value),
                      _textCell(context, order.storageLocation.value),
                      _textCell(
                        context,
                        order.orderId.value,
                        maxLines: 1,
                      ), // Invoice ID - adjust field as needed
                      _textCell(context, order.currency.value, maxLines: 1),
                      _textCell(context, order.unitCost.value, maxLines: 1),
                      _textCell(context, order.paymentMethod.value),
                      _textCell(
                        context,
                        '-',
                        maxLines: 1,
                      ), // Advanced Deposits - add actual field
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuppliersTableWidget extends StatelessWidget {
  final List<SupplierModel> suppliers;
  final String locale;

  const SuppliersTableWidget({
    super.key,
    required this.suppliers,
    required this.locale,
  });

  bool get _isArabic => locale.toLowerCase().startsWith('ar');

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight600.copyWith(color: Colors.white);

  TextStyle _cellStyle(BuildContext context) {
    return StyleText.fontSize13Weight400.copyWith(
      color: AppColors.blackButton,
    );
  }

  // Dynamic width calculation functions for each field
  double _calculateSupplierIDWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.supplierID.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.supplierID.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 10.sp) + 40.sp, 200.w);
    double minWidth = context.isPortrait ? 80.sp : 80.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateSupplierNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.supplierName.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.supplierName.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 250.w);
    double minWidth = context.isPortrait ? 120.sp : 140.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateBusinessTypeWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.businessType.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.businessType.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 20.sp, 230.w);
    double minWidth = context.isPortrait ? 120.sp : 120.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateTaxNumberWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.taxNumber.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.taxNumber.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 9.sp) + 40.sp, 180.w);
    double minWidth = context.isPortrait ? 130.sp : 130.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateBusinessRegNumberWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.businessRegistrationNumber.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.businessRegistrationNumber.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 220.w);
    double minWidth = context.isPortrait ? 220.sp : 220.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateSupplierRankWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.supplierRank.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.supplierRank.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 9.sp) + 40.sp, 150.w);
    double minWidth = context.isPortrait ? 120.sp : 120.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateCreatedByWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.createdBy.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.createdBy.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 13.sp) + 120.sp, 250.w);
    double minWidth = context.isPortrait ? 140.sp : 140.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateDateWidth(BuildContext context) {
    // Dates have consistent format, so we can use a fixed reasonable width
    return context.isPortrait ? 160.w : 160.w;
  }

  double _calculateContractEndDateWidth(BuildContext context) {
    // Dates have consistent format, so we can use a fixed reasonable width
    return context.isPortrait ? 160.w : 160.w;
  }

  double _calculateContractStartDateWidth(BuildContext context) {
    // Dates have consistent format, so we can use a fixed reasonable width
    return context.isPortrait ? 140.w : 160.w;
  }

  double _calculateContactByWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.contactBy.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.contactBy.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 240.w);
    double minWidth = context.isPortrait ? 240.sp : 240.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.firstName.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.firstName.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 80.w : 100.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 40.sp, 150.w);
    double minWidth = context.isPortrait ? 120.sp : 120.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateMiddleNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.middleName.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.middleName.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 80.w : 100.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 40.sp, 150.w);
    double minWidth = context.isPortrait ? 120.sp : 120.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateLastNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.lastName.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.lastName.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 80.w : 100.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 40.sp, 150.w);
    double minWidth = context.isPortrait ? 100.sp : 100.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateTitleWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.title.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.title.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 80.w : 100.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 40.sp, 150.w);
    double minWidth = context.isPortrait ? 70.sp : 80.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateRegistrationDocumentWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.registrationDocumentFileName.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.registrationDocumentFileName.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 60.sp, 220.w);
    double minWidth = context.isPortrait ? 220.sp : 220.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateTaxCertificateWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.taxCertificateFileName.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.taxCertificateFileName.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 140.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 40.sp, 200.w);
    double minWidth = context.isPortrait ? 180.sp : 180.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateContractDocumentWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.contractStatus.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.contractStatus.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 140.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 40.sp, 150.w);
    double minWidth = context.isPortrait ? 150.sp : 140.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateEmailWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.email.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.email.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 40.sp, 250.w);
    double minWidth = context.isPortrait ? 100.sp : 130.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculatePhoneWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.phoneNumber.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.phoneNumber.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 180.w);
    double minWidth = context.isPortrait ? 130.sp : 130.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateAddressWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.country.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.country.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 6.sp) + 40.sp, 200.w);
    double minWidth = context.isPortrait ? 100.sp : 130.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateBankAddressWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.bankAddress.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.bankAddress.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 6.sp) + 40.sp, 200.w);
    double minWidth = context.isPortrait ? 140.sp : 140.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateStreetNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.streetName.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.streetName.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 6.sp) + 40.sp, 200.w);
    double minWidth = context.isPortrait ? 100.sp : 100.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateLocationWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      String location = '';
      // Check city, state, country fields
      if (supplier.city.isNotEmpty) {
        location = supplier.city;
      } else if (supplier.stateOrProvince.isNotEmpty) {
        location = supplier.stateOrProvince;
      } else if (supplier.country.isNotEmpty) {
        location = supplier.country;
      }
      if (location.isNotEmpty) {
        maxLength = math.max(maxLength, location.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 90.w : 110.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 160.w);
    double minWidth = context.isPortrait ? 150.sp : 150.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculatePostalCodeWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.postalCode.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.postalCode.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 90.w : 110.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 160.w);
    double minWidth = context.isPortrait ? 100.sp : 100.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateCityWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.city.isNotEmpty) {
        maxLength = math.max(maxLength, supplier.city.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 90.w : 110.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 160.w);
    double minWidth = context.isPortrait ? 60.sp : 60.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateStateOrProvinceWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.stateOrProvince.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.stateOrProvince.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 90.w : 110.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 100.w);
    double minWidth = context.isPortrait ? 100.sp : 100.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateWareHouseWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.warehouseCountry.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.warehouseCountry.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 90.w : 110.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 1000.w);
    double minWidth = context.isPortrait ? 1000.sp : 140.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateBankingPreferredWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.preferredLanguage.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.preferredLanguage.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 40.sp, 220.w);
    double minWidth = context.isPortrait ? 100.sp : 150.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateBankingBeneficiaryNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.beneficiaryName.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.beneficiaryName.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 40.sp, 220.w);
    double minWidth = context.isPortrait ? 150.sp : 150.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateBankingBankNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.beneficiaryBankName.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.beneficiaryBankName.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 40.sp, 220.w);
    double minWidth = context.isPortrait ? 180.sp : 180.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateBankingIbanWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.beneficiaryBankAccountNumberIBAN.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.beneficiaryBankAccountNumberIBAN.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 40.sp, 300.w);
    double minWidth = context.isPortrait ? 280.sp : 280.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateBankingSwiftWidth(BuildContext context) {
    double maxLength = 0;
    for (var supplier in suppliers) {
      if (supplier.bankSWIFTBICCode.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          supplier.bankSWIFTBICCode.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 180.w);
    double minWidth = context.isPortrait ? 170.sp : 170.sp;
    return math.max(calculatedWidth, minWidth);
  }

  Widget _cell(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(style: _cellStyle(context), child: child),
    );
  }

  Widget _textCell(BuildContext context, String text, {int maxLines = 2}) {
    return _cell(
      context,
      Text(
        text.isEmpty ? '-' : text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _clickableCell(
    BuildContext context,
    Widget child,
    SupplierModel supplier,
  ) {
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSupplierDetails(supplierModel: supplier),
          ),
        );
      },
      child: child,
    );
  }

  String _formatStringDate(String dateString) {
    if (dateString.isEmpty) return '-';
    try {
      // Handle different date formats
      DateTime date;
      if (dateString.contains('-') && dateString.split('-').length == 3) {
        // Handle formats like "9-9-2025" or "17-9-2025"
        List<String> parts = dateString.split('-');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          date = DateTime(year, month, day);
        } else {
          date = DateTime.parse(dateString);
        }
      } else {
        date = DateTime.parse(dateString);
      }
      return "${date.day} ${_getMonthName(date.month)} ${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // Headers arranged in your specified order
    final headers = <String>[
      _isArabic ? 'رقم المورد' : 'Supplier ID',
      _isArabic ? 'اسم المورد' : 'Supplier Name',
      _isArabic ? 'نوع العمل' : 'Business Type',
      _isArabic ? 'الرقم الضريبي' : 'Tax Number',
      _isArabic ? 'رقم تسجيل العمل' : 'Business Registration Number',
      _isArabic ? 'تصنيف المورد' : 'Supplier Rank',
      _isArabic ? 'أنشئ بواسطة' : 'Created By',
      _isArabic ? 'تاريخ الإضافة' : 'Date Added',
      _isArabic ? 'تم الاتصال بواسطة' : 'Point Of Contact',
      _isArabic ? 'الاسم الأول' : 'First Name',
      _isArabic ? 'الاسم الأوسط' : 'Middle Name',
      _isArabic ? 'اسم العائلة' : 'Last Name',
      _isArabic ? 'اللقب' : 'Title',
      _isArabic ? 'رقم الهاتف' : 'Phone Number',
      _isArabic ? 'البريد الإلكتروني' : 'Email',
      _isArabic ? 'اللغة المفضلة' : 'Preferred Language',
      _isArabic ? 'اسم المستفيد' : 'Beneficiary Name',
      _isArabic ? 'اسم البنك' : 'Beneficiary Bank Name',
      _isArabic ? 'رقم حساب IBAN' : 'Beneficiary Bank Account Number / IBAN',
      _isArabic ? 'رمز SWIFT/BIC' : 'Bank SWIFT/BIC Code',
      _isArabic ? 'عنوان البنك' : 'Bank Address',
      _isArabic ? 'البلد' : 'Country',
      _isArabic ? 'الولاية/المحافظة' : 'State or Province',
      _isArabic ? 'المدينة' : 'City',
      _isArabic ? 'الرمز البريدي' : 'Postal Code',
      _isArabic ? 'اسم الشارع' : 'Street Name',
      _isArabic ? 'بلد المستودع' : 'Warehouse Country',
      _isArabic ? 'ولاية المستودع' : 'State or Province',
      _isArabic ? 'مدينة المستودع' : 'City',
      _isArabic ? 'رمز بريدي المستودع' : 'Postal Code',
      _isArabic ? 'شارع المستودع' : 'Street Name',
      _isArabic ? 'بداية العقد' : 'Contract Start Date',
      _isArabic ? 'نهاية العقد' : 'Contract End Date',
      _isArabic ? 'حالة العقد' : 'Contract Document',
      _isArabic ? 'ملف الشهادة الضريبية' : 'Tax Certificate',
      _isArabic ? 'ملف وثيقة التسجيل' : 'Registration Document',
    ];

    // Dynamic column widths based on content
    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(_calculateSupplierIDWidth(context)),
      1: FixedColumnWidth(_calculateSupplierNameWidth(context)),
      2: FixedColumnWidth(_calculateBusinessTypeWidth(context)),
      3: FixedColumnWidth(_calculateTaxNumberWidth(context)),
      4: FixedColumnWidth(_calculateBusinessRegNumberWidth(context)),
      5: FixedColumnWidth(_calculateSupplierRankWidth(context)),
      6: FixedColumnWidth(_calculateCreatedByWidth(context)),
      7: FixedColumnWidth(_calculateDateWidth(context)),
      8: FixedColumnWidth(_calculateContactByWidth(context)),
      9: FixedColumnWidth(_calculateNameWidth(context)),
      10: FixedColumnWidth(_calculateMiddleNameWidth(context)),
      11: FixedColumnWidth(_calculateLastNameWidth(context)),
      12: FixedColumnWidth(_calculateTitleWidth(context)),
      13: FixedColumnWidth(_calculatePhoneWidth(context)),
      14: FixedColumnWidth(_calculateEmailWidth(context)),
      15: FixedColumnWidth(_calculateBankingPreferredWidth(context)),
      16: FixedColumnWidth(_calculateBankingBeneficiaryNameWidth(context)),
      17: FixedColumnWidth(_calculateBankingBankNameWidth(context)),
      18: FixedColumnWidth(_calculateBankingIbanWidth(context)),
      19: FixedColumnWidth(_calculateBankingSwiftWidth(context)),
      20: FixedColumnWidth(_calculateBankAddressWidth(context)),
      21: FixedColumnWidth(_calculateAddressWidth(context)),
      22: FixedColumnWidth(_calculateLocationWidth(context)),
      23: FixedColumnWidth(_calculateLocationWidth(context)),
      24: FixedColumnWidth(_calculateLocationWidth(context)),
      25: FixedColumnWidth(_calculateLocationWidth(context)),
      26: FixedColumnWidth(_calculateAddressWidth(context)),
      27: FixedColumnWidth(_calculateWareHouseWidth(context)),
      28: FixedColumnWidth(_calculateStateOrProvinceWidth(context)),
      29: FixedColumnWidth(_calculateCityWidth(context)),
      30: FixedColumnWidth(_calculatePostalCodeWidth(context)),
      31: FixedColumnWidth(_calculateStreetNameWidth(context)),
      32: FixedColumnWidth(_calculateContractStartDateWidth(context)),
      33: FixedColumnWidth(_calculateContractEndDateWidth(context)),
      34: FixedColumnWidth(_calculateContractDocumentWidth(context)),
      35: FixedColumnWidth(_calculateTaxCertificateWidth(context)),
      36: FixedColumnWidth(_calculateRegistrationDocumentWidth(context)),
    };

    return AnimatedSizeWrap(
      // Tables animate their size (rows added / removed / filtered).
      child: Directionality(
        textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        // Owner 21/10/2026: full width, equal column shares (No stays narrow); scrolls when the columns cannot fit.
        child: FillWidthHorizontalScroll(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: Table(
              border: TableBorder.all(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.sp),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: fillColumnWidths(columnWidths),
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(
                    color: lightMode ? Colors.black : Colors.black45,
                  ),
                  children: headers
                      .map(
                        (name) => Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Text(
                            name,
                            style: _headerStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      )
                      .toList(),
                ),

                // Data Rows - arranged in the same order as headers
                ...List.generate(suppliers.length, (index) {
                  final supplier = suppliers[index];
                  final isEven = index.isEven;
                  final rowColor = lightMode
                      ? (isEven ? const Color(0xFFF7F8FA) : Colors.white)
                      : (isEven ? const Color(0xFF1E1F24) : Colors.black);

                  return TableRow(
                    decoration: BoxDecoration(color: rowColor),
                    children: [
                      _clickableCell(
                        context,
                        _textCell(context, supplier.supplierID, maxLines: 1),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.supplierName),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.businessType),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.taxNumber),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.businessRegistrationNumber),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.supplierRank),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.createdBy),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(
                          context,
                          _formatStringDate(supplier.dateAdded),
                          maxLines: 1,
                        ),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.contactBy),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.firstName),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.middleName),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.lastName),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.title),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.phoneNumber),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.email),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.preferredLanguage),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.beneficiaryName),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.beneficiaryBankName),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(
                          context,
                          supplier.beneficiaryBankAccountNumberIBAN,
                        ),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.bankSWIFTBICCode),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.bankAddress),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.country),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.stateOrProvince),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.city),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.postalCode),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.streetName),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.warehouseCountry),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.warehouseStateOrProvince),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.warehouseCity),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.warehousePostalCode),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.warehouseStreetName),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(
                          context,
                          _formatStringDate(supplier.contractStartDate),
                          maxLines: 1,
                        ),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(
                          context,
                          _formatStringDate(supplier.contractEndDate),
                          maxLines: 1,
                        ),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.contractStatus),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, supplier.taxCertificateFileName),
                        supplier,
                      ),
                      _clickableCell(
                        context,
                        _textCell(
                            context, supplier.registrationDocumentFileName),
                        supplier,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Storage Locations Table Widget
class StorageLocationsTableWidget extends StatelessWidget {
  final List<StorageLocation> storageLocations;
  final String locale;

  const StorageLocationsTableWidget({
    super.key,
    required this.storageLocations,
    required this.locale,
  });

  bool get _isArabic => locale.toLowerCase().startsWith('ar');

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight600.copyWith(color: Colors.white);

  TextStyle _cellStyle(BuildContext context) => TextStyle(
        fontSize: 13.sp,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black87
            : AppColors.white,
      );

  // Dynamic width calculation methods
  double _calculateLocationIDWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.id.value.isNotEmpty) {
        maxLength = math.max(maxLength, location.id.value.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 10.w) + 40.w, 200.w);
    double minWidth = context.isPortrait ? 150.w : 150.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateLocationNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.name.value.isNotEmpty) {
        maxLength = math.max(maxLength, location.name.value.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = math.min((maxLength * 8.w) + 60.w, 250.w);
    double minWidth = context.isPortrait ? 170.w : 170.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateCountryWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.country.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          location.country.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 90.w : 100.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 60.w, 150.w);
    double minWidth = context.isPortrait ? 80.w : 90.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateStateProvinceWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.stateOrProvince.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          location.stateOrProvince.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 120.w : 120.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateCityWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.city.value.isNotEmpty) {
        maxLength = math.max(maxLength, location.city.value.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 90.w : 100.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 150.w);
    double minWidth = context.isPortrait ? 80.w : 90.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculatePostalCodeWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.postalCode.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          location.postalCode.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 80.w : 100.w;
    double calculatedWidth = math.min((maxLength * 9.sp) + 40.w, 130.w);
    double minWidth = context.isPortrait ? 110.w : 110.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateCreatedByWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.createdBy.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          location.createdBy.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 60.w, 200.w);
    double minWidth = context.isPortrait ? 90.w : 130.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateDateWidth(BuildContext context) {
    // Dates have consistent format, so we can use a fixed reasonable width
    return context.isPortrait ? 120.w : 120.w;
  }

  double _calculateLocationTypeWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      // Assuming you have a locationType field, if not replace with appropriate field
      String locationType =
          location.area.value; // Using area as location type for now
      if (locationType.isNotEmpty) {
        maxLength = math.max(maxLength, locationType.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 150.w);
    double minWidth = context.isPortrait ? 120.w : 120.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateDepartmentWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.assignedDepartment.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          location.assignedDepartment.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.w) + 40.w, 200.w);
    double minWidth = context.isPortrait ? 170.w : 170.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateStorageCapacityWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      String capacity = location.storageCapacity.value.toString();
      if (capacity.isNotEmpty) {
        maxLength = math.max(maxLength, capacity.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 9.sp) + 40.w, 150.w);
    double minWidth = context.isPortrait ? 130.w : 130.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateCapacityUnitWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.capacityUnit.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          location.capacityUnit.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 80.w : 100.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 130.w);
    double minWidth = context.isPortrait ? 160.w : 160.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateAccessLevelWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.accessLevel.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          location.accessLevel.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.w, 180.w);
    double minWidth = context.isPortrait ? 110.w : 110.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateEquipmentWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.equipmentAvailable.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          location.equipmentAvailable.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 7.sp) + 60.w, 240.w);
    double minWidth = context.isPortrait ? 180.w : 180.w;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateStorageConditionWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.conditionOfStorage.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          location.conditionOfStorage.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 200.w);
    double minWidth = context.isPortrait ? 130.sp : 130.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateAdditionalNoteWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      if (location.additionalNote.value.isNotEmpty) {
        maxLength = math.max(
          maxLength,
          location.additionalNote.value.length.toDouble(),
        );
      }
    }
    if (maxLength == 0) return context.isPortrait ? 150.w : 200.w;
    double calculatedWidth = math.min((maxLength * 6.sp) + 40.sp, 300.w);
    double minWidth = context.isPortrait ? 140.sp : 140.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateEmployeesWidth(BuildContext context) {
    double maxLength = 0;
    for (var location in storageLocations) {
      String employeeNames = location.employee.value
          .map((emp) => '${emp.firstName ?? ''} ${emp.lastName ?? ''}'.trim())
          .join(', ');
      if (employeeNames.isNotEmpty) {
        maxLength = math.max(maxLength, employeeNames.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 150.w : 200.w;
    double calculatedWidth = math.min((maxLength * 6.sp) + 40.sp, 400.w);
    double minWidth = context.isPortrait ? 120.sp : 180.sp;
    return math.max(calculatedWidth, minWidth);
  }

  Widget _cell(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(style: _cellStyle(context), child: child),
    );
  }

  Widget _textCell(BuildContext context, String text, {int maxLines = 2}) {
    return _cell(
      context,
      Text(
        text.isEmpty ? '-' : text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _employeeCell(
    BuildContext context,
    List<EmployeeEntityModel> employees,
  ) {
    String employeeNames = employees
        .map((emp) => '${emp.firstName ?? ''} ${emp.lastName ?? ''}'.trim())
        .join(', ');
    return _textCell(context, employeeNames.isEmpty ? '-' : employeeNames);
  }

  // Add clickable cell wrapper
  Widget _clickableCell(
    BuildContext context,
    Widget child,
    StorageLocation location,
  ) {
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StorageLocationDetailsToggle(storageLocation: location),
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final headers = <String>[
      _isArabic ? 'رقم الموقع' : 'Storage Location ID',
      _isArabic ? 'اسم موقع التخزين' : 'Storage Location Name',
      _isArabic ? 'البلد' : 'Country',
      _isArabic ? 'الولاية/المحافظة' : 'State or Province',
      _isArabic ? 'المدينة' : 'City',
      _isArabic ? 'الرمز البريدي' : 'Postal Code',
      _isArabic ? 'أنشئ بواسطة' : 'Created By',
      _isArabic ? 'تاريخ الإضافة' : 'Date Added',
      _isArabic ? 'نوع الموقع' : 'Location Type',
      _isArabic ? 'القسم المخصص' : 'Assigned Department',
      _isArabic ? 'سعة التخزين' : 'Storage Capacity',
      _isArabic ? 'وحدة القياس' : 'Unit Of Measurement',
      _isArabic ? 'مستوى الوصول' : 'Access Level',
      _isArabic ? 'المعدات المتاحة' : 'Equipment Available',
      _isArabic ? 'حالة التخزين' : 'Condition Of Storage',
      _isArabic ? 'ملاحظة إضافية' : 'Additional Note',
      _isArabic ? 'الموظف المخصص' : 'Assigned Employee',
    ];

    // Dynamic column widths based on content
    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(_calculateLocationIDWidth(context)),
      1: FixedColumnWidth(_calculateLocationNameWidth(context)),
      2: FixedColumnWidth(_calculateCountryWidth(context)),
      3: FixedColumnWidth(_calculateStateProvinceWidth(context)),
      4: FixedColumnWidth(_calculateCityWidth(context)),
      5: FixedColumnWidth(_calculatePostalCodeWidth(context)),
      6: FixedColumnWidth(_calculateCreatedByWidth(context)),
      7: FixedColumnWidth(_calculateDateWidth(context)),
      8: FixedColumnWidth(_calculateLocationTypeWidth(context)),
      9: FixedColumnWidth(_calculateDepartmentWidth(context)),
      10: FixedColumnWidth(_calculateStorageCapacityWidth(context)),
      11: FixedColumnWidth(_calculateCapacityUnitWidth(context)),
      12: FixedColumnWidth(_calculateAccessLevelWidth(context)),
      13: FixedColumnWidth(_calculateEquipmentWidth(context)),
      14: FixedColumnWidth(_calculateStorageConditionWidth(context)),
      15: FixedColumnWidth(_calculateAdditionalNoteWidth(context)),
      16: FixedColumnWidth(_calculateEmployeesWidth(context)),
    };

    return AnimatedSizeWrap(
      // Tables animate their size (rows added / removed / filtered).
      child: Directionality(
        textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        // Owner 21/10/2026: full width, equal column shares (No stays narrow); scrolls when the columns cannot fit.
        child: FillWidthHorizontalScroll(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: Table(
              border: TableBorder.all(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.sp),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: fillColumnWidths(columnWidths),
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(
                    color: lightMode ? Colors.black : Colors.black45,
                  ),
                  children: headers
                      .map(
                        (name) => Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Text(
                            name,
                            style: _headerStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      )
                      .toList(),
                ),

                // Data Rows - ALL CELLS CLICKABLE
                ...List.generate(storageLocations.length, (index) {
                  final location = storageLocations[index];
                  final isEven = index.isEven;
                  final rowColor = lightMode
                      ? (isEven ? const Color(0xFFF7F8FA) : Colors.white)
                      : (isEven ? const Color(0xFF1E1F24) : Colors.black);

                  //     final accessLevelColor = _getAccessLevelColor(location.accessLevel.value);

                  return TableRow(
                    decoration: BoxDecoration(color: rowColor),
                    children: [
                      _clickableCell(
                        context,
                        _textCell(context, location.id.value, maxLines: 1),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(
                          context,
                          "${location.branchName.value} ${location.area.value}",
                        ),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, location.country.value),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, location.stateOrProvince.value),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, location.city.value),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, location.postalCode.value),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, location.createdBy.value),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(
                          context,
                          _formatDate(location.dateAdded.value),
                          maxLines: 1,
                        ),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, location.area.value),
                        location,
                      ), // Using area as location type
                      _clickableCell(
                        context,
                        _textCell(context, location.assignedDepartment.value),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(
                          context,
                          location.storageCapacity.value.toString(),
                        ),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, location.capacityUnit.value),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _cell(
                          context,
                          Text(
                            location.accessLevel.value,
                            style: _cellStyle(context),
                          ),
                        ),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, location.equipmentAvailable.value),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(context, location.conditionOfStorage.value),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _textCell(
                          context,
                          location.additionalNote.value,
                          maxLines: 3,
                        ),
                        location,
                      ),
                      _clickableCell(
                        context,
                        _employeeCell(context, location.employee.value),
                        location,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }
}

// Assets Table Widget
class AssetsTableWidget extends StatelessWidget {
  final List<ProductModel> assets;
  final String locale;

  const AssetsTableWidget({
    super.key,
    required this.assets,
    required this.locale,
  });

  bool get _isArabic => locale.toLowerCase().startsWith('ar');

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight600.copyWith(color: Colors.white);

  TextStyle _cellStyle(BuildContext context) => TextStyle(
        fontSize: 13.sp,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black87
            : AppColors.white,
      );

  Widget _cell(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(style: _cellStyle(context), child: child),
    );
  }

  Widget _textCell(BuildContext context, String text, {int maxLines = 2}) {
    return _cell(
      context,
      Text(
        text.isEmpty ? '-' : text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final headers = <String>[
      _isArabic ? 'رقم' : 'No',
      _isArabic ? 'رقم الأصل' : 'Asset ID',
      _isArabic ? 'اسم الأصل' : 'Asset Name',
      _isArabic ? 'الموقع' : 'Location',
      _isArabic ? 'الحالة' : 'Status',
      _isArabic ? 'تاريخ الاستلام' : 'Received Date',
      _isArabic ? 'المُسند إليه' : 'Assigned To',
    ];

    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(40.sp),
      1: FixedColumnWidth(120.sp),
      2: FixedColumnWidth(150.sp),
      3: FixedColumnWidth(120.sp),
      4: FixedColumnWidth(100.sp),
      5: FixedColumnWidth(120.sp),
      6: FixedColumnWidth(150.sp),
    };

    return AnimatedSizeWrap(
      // Tables animate their size (rows added / removed / filtered).
      child: Directionality(
        textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        // Owner 21/10/2026: full width, equal column shares (No stays narrow); scrolls when the columns cannot fit.
        child: FillWidthHorizontalScroll(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: Table(
              border: TableBorder.all(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.sp),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: fillColumnWidths(columnWidths),
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(
                    color: lightMode ? Colors.black : Colors.black45,
                  ),
                  children: headers
                      .map(
                        (name) => Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Text(
                            name,
                            style: _headerStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      )
                      .toList(),
                ),

                // Data Rows
                ...List.generate(assets.length, (index) {
                  final asset = assets[index];
                  final isEven = index.isEven;
                  final rowColor = lightMode
                      ? (isEven ? const Color(0xFFF7F8FA) : Colors.white)
                      : (isEven ? const Color(0xFF1E1F24) : Colors.black);

                  // Simulate assigned status (you can modify this based on your data structure)
                  final isAssigned = index % 2 == 0;
                  final assignedTo = isAssigned ? "Employee Name" : "-";
                  final statusColor = isAssigned ? Colors.green : Colors.orange;

                  return TableRow(
                    decoration: BoxDecoration(color: rowColor),
                    children: [
                      _textCell(context, (index + 1).toString(), maxLines: 1),
                      _textCell(context, asset.productId.value, maxLines: 1),
                      _textCell(context, asset.productName.value),
                      _textCell(
                        context,
                        asset.storageLocation.value.isNotEmpty
                            ? asset.storageLocation.value
                            : "N/A",
                      ),
                      _cell(
                        context,
                        Text(
                          isAssigned
                              ? (_isArabic ? 'مُسند' : 'Assigned')
                              : (_isArabic ? 'غير مُسند' : 'Unassigned'),
                          style: _cellStyle(context).copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _textCell(
                        context,
                        _formatDate(asset.receivingDate.timestamp),
                        maxLines: 1,
                      ),
                      _textCell(context, assignedTo),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }
}
