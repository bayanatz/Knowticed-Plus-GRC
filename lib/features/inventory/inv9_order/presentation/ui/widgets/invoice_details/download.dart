import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';

class PdfService {
  static Future<Uint8List> generateInvoicePdf({
    required List<ProductModel> products,
    SupplierModel? supplier,
    required bool isArabic,
  }) async {
    try {
      debugPrint('🔄 Starting PDF generation...');

      if (products.isEmpty) {
        throw Exception('No products available for PDF generation');
      }

      final pdf = pw.Document();
      final product = products.first;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              // Header with Order Request title and buttons area
              _buildHeader(isArabic),
              pw.SizedBox(height: 20),

              // Main container matching your UI
              _buildMainContainer(product, products, supplier, isArabic),
            ];
          },
        ),
      );

      debugPrint('✅ PDF generation completed');
      return await pdf.save();
    } catch (e) {
      debugPrint('❌ Error in PDF generation: $e');
      rethrow;
    }
  }

  static pw.Widget _buildHeader(bool isArabic) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          isArabic ? 'طلب الطلب' : 'Order Request',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.Row(
          children: [
            pw.Container(
              padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                isArabic ? 'مشاركة' : 'Share',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Container(
              padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                isArabic ? 'تحميل' : 'Download',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildMainContainer(ProductModel product,
      List<ProductModel> products, SupplierModel? supplier, bool isArabic) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      padding: pw.EdgeInsets.all(15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // First Section - Brand image, Order info, and PO number with total
          _buildFirstSection(product, isArabic),
          pw.SizedBox(height: 10),

          // Order Info User section
          _buildOrderInfoUser(product, isArabic),
          pw.SizedBox(height: 10),

          // Border Container with order details and supplier info
          _buildBorderContainer(product, products, supplier, isArabic),
        ],
      ),
    );
  }

  static pw.Widget _buildFirstSection(ProductModel product, bool isArabic) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Brand Image placeholder
        pw.Container(
          height: 75,
          width: 96,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Center(
            child: pw.Text(
              'LOGO',
              style: pw.TextStyle(color: PdfColors.grey),
            ),
          ),
        ),

        // PO number and Total Amount
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            // PO Number
            pw.Container(
              width: 106,
              height: 32,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  product.orderId.value.isNotEmpty
                      ? product.orderId.value
                      : 'N/A',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.SizedBox(height: 19),

            // Total Amount label
            pw.Text(
              isArabic ? 'المبلغ الإجمالي' : 'Total Amount',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 8),

            // Currency and amount
            pw.Text(
              '${product.orderValue.value.isNotEmpty ? product.orderValue.value : "0"} ${product.currency.value.isNotEmpty ? product.currency.value : "USD"}',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildOrderInfoUser(ProductModel product, bool isArabic) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Order Created By
        pw.Text(
          isArabic ? 'تم إنشاء الطلب بواسطة' : 'Order Created By',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),

        // Name
        pw.Text(
          isArabic
              ? '${product.firstNameArCreator.value} ${product.lastNameArCreator.value}'
              : '${product.firstNameCreator.value} ${product.lastNameCreator.value}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),

        // Job Title
        _buildInfoLine(
          isArabic ? 'المسمى الوظيفي:' : 'Job Title:',
          isArabic
              ? product.jobTitleArCreator.value
              : product.jobTitleCreator.value,
        ),

        // Department
        _buildInfoLine(
          isArabic ? 'القسم:' : 'Department:',
          isArabic
              ? product.departmentArCreator.value
              : product.departmentCreator.value,
        ),

        // Phone Number
        _buildInfoLine(
          isArabic ? 'رقم الهاتف:' : 'Phone Number:',
          product.phoneCreator.value,
        ),

        // Email
        _buildInfoLine(
          isArabic ? 'البريد الإلكتروني:' : 'Email:',
          product.emailCreator.value,
        ),
      ],
    );
  }

  static pw.Widget _buildBorderContainer(ProductModel product,
      List<ProductModel> products, SupplierModel? supplier, bool isArabic) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: [
          // Order details and supplier info side by side
          pw.Padding(
            padding: pw.EdgeInsets.all(15),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Order Info Section
                pw.Expanded(child: _buildSideInfoSection(product, isArabic)),
                pw.SizedBox(width: 28),
                // Supplier Info Section
                pw.Expanded(child: _buildSupplierSection(supplier, isArabic)),
              ],
            ),
          ),

          // Products Table
          _buildProductsTable(products, isArabic),

          // Payment Summary
          pw.Padding(
            padding: pw.EdgeInsets.all(15),
            child: _buildPaymentSummary(product, isArabic),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSideInfoSection(ProductModel product, bool isArabic) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      padding: pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoLine(
            isArabic ? 'رقم الطلب:' : 'Order ID:',
            product.orderId.value,
          ),
          pw.SizedBox(height: 9),
          _buildInfoLine(
            isArabic ? 'نوع الطلب:' : 'Order Type:',
            product.orderType.value,
          ),
          pw.SizedBox(height: 9),
          _buildInfoLine(
            isArabic ? 'حالة الطلب:' : 'Order Status:',
            product.status.value,
          ),
          pw.SizedBox(height: 9),
          _buildInfoLine(
            isArabic ? 'تاريخ الطلب:' : 'Order Date:',
            DateFormat('dd MMM yyyy').format(product.orderId.timestamp),
          ),
          pw.SizedBox(height: 9),
          _buildInfoLine(
            isArabic ? 'طريقة التسليم:' : 'Delivery Method:',
            product.deliveryMethod.value,
          ),
          pw.SizedBox(height: 9),
          _buildInfoLine(
            isArabic ? 'استلمها:' : 'Received By:',
            'Yahya Yasin',
          ),
          pw.SizedBox(height: 9),
          _buildInfoLine(
            isArabic ? 'تاريخ التسليم المتوقع:' : 'Expected Delivery Date:',
            product.expectedDelivery.value,
          ),
          pw.SizedBox(height: 9),
          _buildInfoLine(
            isArabic ? 'تاريخ الاستلام:' : 'Received Date:',
            '03/05/2020',
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSupplierSection(
      SupplierModel? supplier, bool isArabic) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Supplier ID
        pw.Text(
          '${isArabic ? "معرف المورد:" : "Supplier ID:"} ${supplier?.supplierID ?? "001"}',
          style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 8),

        // Supplier details in containers
        if (supplier != null) ...[
          _buildContainerInfo(supplier.supplierName.isNotEmpty
              ? supplier.supplierName
              : (isArabic ? 'اسم المورد' : 'Supplier Name')),
          pw.SizedBox(height: 8),
          _buildContainerInfo(
              '${supplier.country} ${supplier.city} ${supplier.postalCode}'),
          pw.SizedBox(height: 8),
          _buildContainerInfo(
              '${supplier.title} ${supplier.phoneNumber} ${supplier.email}'),
          pw.SizedBox(height: 8),
          _buildContainerInfo(supplier.businessType.isNotEmpty
              ? supplier.businessType
              : (isArabic ? 'نوع العمل' : 'Business Type')),
          pw.SizedBox(height: 8),
          _buildContainerInfo(supplier.taxNumber.isNotEmpty
              ? supplier.taxNumber
              : (isArabic ? 'الرقم الضريبي' : 'Tax Number')),
        ] else ...[
          _buildContainerInfo(isArabic ? 'اسم المورد' : 'Supplier Name'),
          pw.SizedBox(height: 8),
          _buildContainerInfo(isArabic
              ? 'البلد المدينة الرمز البريدي'
              : 'Country City Postal Code'),
          pw.SizedBox(height: 8),
          _buildContainerInfo(isArabic
              ? 'تفاصيل جهة الاتصال رقم الهاتف البريد الإلكتروني'
              : 'Contact Details Phone Email'),
          pw.SizedBox(height: 8),
          _buildContainerInfo(isArabic ? 'نوع العمل' : 'Business Type'),
          pw.SizedBox(height: 8),
          _buildContainerInfo(isArabic ? 'الرقم الضريبي' : 'Tax Number'),
        ],

        pw.SizedBox(height: 8),

        // Order Note
        pw.Text(
          isArabic ? 'ملاحظة الطلب' : 'Order Note',
          style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          isArabic ? 'معلومات الطلب...' : 'Order information...',
          style: pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildProductsTable(
      List<ProductModel> products, bool isArabic) {
    // For mobile view, we'll show a simplified version
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 15),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        padding: pw.EdgeInsets.all(10),
        child: pw.Column(
          children: products
              .map((product) => pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: _buildInfoLine(
                              '${isArabic ? "اسم المنتج:" : "Product Name:"} ',
                              '${product.brand.value} ${product.model.value}',
                            ),
                          ),
                          _buildInfoLine(
                            '${isArabic ? "رقم:" : "No:"} ',
                            '1',
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      _buildInfoLine(
                        isArabic
                            ? 'الفئة/الفئة الفرعية'
                            : 'Category/Subcategory',
                        '${product.category.value}/${product.subCategory.value}',
                      ),
                      pw.SizedBox(height: 4),
                      _buildInfoLine(
                        '${isArabic ? "الكمية:" : "Quantity:"} ',
                        product.quantity.value,
                      ),
                      pw.SizedBox(height: 4),
                      _buildInfoLine(
                        '${isArabic ? "سعر الوحدة:" : "Unit Price:"} ',
                        product.unitCost.value,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: _buildInfoLine(
                              '${isArabic ? "ضريبة القيمة المضافة:" : "VAT:"} ',
                              product.vat.value,
                            ),
                          ),
                          _buildInfoLine(
                            '${isArabic ? "المبلغ النهائي:" : "Final Amount:"} ',
                            product.orderValue.value,
                          ),
                        ],
                      ),
                      if (product != products.last) pw.SizedBox(height: 10),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  static pw.Widget _buildPaymentSummary(ProductModel product, bool isArabic) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(isArabic ? 'نوع الدفع' : 'Payment Type',
                    style:
                        pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                pw.SizedBox(height: 7),
                pw.Text(isArabic ? 'العملة' : 'Currency',
                    style:
                        pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                pw.SizedBox(height: 7),
                pw.Text(isArabic ? 'الوديعة المقدمة' : 'Advanced Deposit',
                    style:
                        pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                pw.SizedBox(height: 7),
                pw.Text(isArabic ? 'المجموع بدون ضريبة' : 'Total HT',
                    style:
                        pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                pw.SizedBox(height: 7),
                pw.Text(isArabic ? 'مجموع الضريبة' : 'Total VAT',
                    style:
                        pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
              ],
            ),
            pw.SizedBox(width: 50),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(product.paymentMethod.value,
                    style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 7),
                pw.Text(product.currency.value,
                    style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 7),
                pw.Text('€3,000', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 7),
                pw.Text('€3,000', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 7),
                pw.Text(product.vat.value, style: pw.TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),

        // Divider
        pw.Container(
          margin: pw.EdgeInsets.symmetric(vertical: 10),
          height: 1,
          color: PdfColors.grey300,
        ),

        // Total Price
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              isArabic ? 'السعر الإجمالي' : 'Total Price',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(width: 50),
            pw.Text(
              product.orderValue.value,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildContainerInfo(String label) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: double.infinity,
      child: pw.Center(
        child: pw.Text(
          label,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );
  }

  static pw.Widget _buildInfoLine(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  static Future<void> downloadPdf(Uint8List pdfBytes, String fileName) async {
    try {
      debugPrint('💾 Starting PDF download/share...');

      if (Platform.isAndroid || Platform.isIOS) {
        debugPrint('📱 Mobile platform detected - using share dialog');
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: fileName,
        );
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        debugPrint('🖥️ Desktop platform detected - saving to documents');
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(pdfBytes);
        debugPrint('✅ PDF saved to: ${file.path}');
      } else {
        debugPrint('🔄 Unknown platform - using share fallback');
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: fileName,
        );
      }

      debugPrint('✅ PDF download/share completed successfully');
    } catch (e) {
      debugPrint('❌ Error in downloadPdf: $e');
      rethrow;
    }
  }

  static Future<void> previewPdf(Uint8List pdfBytes) async {
    try {
      debugPrint('👁️ Opening PDF preview...');
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      debugPrint('❌ Error in previewPdf: $e');
      rethrow;
    }
  }
}
