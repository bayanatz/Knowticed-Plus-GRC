// ****************** FILE INFO ******************
// File Name: crm_add_quote_step2_preview_products.dart
// Purpose: Step 2 Preview Products and Services form for Add Quote wizard matching Figma screenshot exactly
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class QuoteProductPreviewItem {
  final String category;
  final String product;
  final String quantity;
  final String unitPrice;
  final String discount;
  final String tax;
  final String total;

  const QuoteProductPreviewItem({
    required this.category,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.tax,
    required this.total,
  });
}

class QuoteServicePreviewItem {
  final String category;
  final String service;
  final String price;
  final String discount;
  final String tax;
  final String total;

  const QuoteServicePreviewItem({
    required this.category,
    required this.service,
    required this.price,
    required this.discount,
    required this.tax,
    required this.total,
  });
}

class CrmAddQuoteStep2PreviewProducts extends StatelessWidget {
  final List<QuoteProductPreviewItem> products;
  final List<QuoteServicePreviewItem> services;
  final String subtotalProducts;
  final String subtotalServices;
  final String taxes;
  final String discount;
  final String grandTotal;

  const CrmAddQuoteStep2PreviewProducts({
    super.key,
    this.products = const <QuoteProductPreviewItem>[
      QuoteProductPreviewItem(
        category: 'Category x',
        product: 'Product x',
        quantity: '7',
        unitPrice: '\$50',
        discount: '20%',
        tax: '\$50',
        total: '\$50',
      ),
      QuoteProductPreviewItem(
        category: 'Category x',
        product: 'Product x',
        quantity: '7',
        unitPrice: '\$50',
        discount: '20%',
        tax: '\$50',
        total: '\$50',
      ),
    ],
    this.services = const <QuoteServicePreviewItem>[
      QuoteServicePreviewItem(
        category: 'Category x',
        service: 'Service x',
        price: '\$50',
        discount: '20%',
        tax: '\$50',
        total: '\$50',
      ),
      QuoteServicePreviewItem(
        category: 'Category x',
        service: 'Service x',
        price: '\$50',
        discount: '20%',
        tax: '\$50',
        total: '\$50',
      ),
    ],
    this.subtotalProducts = '1400 GEP',
    this.subtotalServices = '1400 GEP',
    this.taxes = '100 EGP',
    this.discount = '-200 EGP',
    this.grandTotal = '1,000 EGP',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. Products/lines Section ─────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Products/lines',
            arabicName: 'المنتجات والبنود',
          ),
          showHideToggle: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildPermissionWarningBanner(
                context,
                FormatHelper.localizedString(
                  englishName: "You don't have permission to edit product",
                  arabicName: 'ليس لديك صلاحية لتعديل المنتج',
                ),
              ),
              SizedBox(height: 16.sp),
              _buildProductsTable(context),
            ],
          ),
        ),

        SizedBox(height: 16.sp),

        // ── 2. Services Section ───────────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Services',
            arabicName: 'الخدمات',
          ),
          showHideToggle: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildPermissionWarningBanner(
                context,
                FormatHelper.localizedString(
                  englishName: "You don't have permission to edit service",
                  arabicName: 'ليس لديك صلاحية لتعديل الخدمة',
                ),
              ),
              SizedBox(height: 16.sp),
              _buildServicesTable(context),
            ],
          ),
        ),

        SizedBox(height: 16.sp),

        // ── 3. Summary Section ────────────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Summary',
            arabicName: 'الملخص',
          ),
          showHideToggle: true,
          child: _buildSummaryCard(context),
        ),
      ],
    );
  }

  Widget _buildPermissionWarningBanner(BuildContext context, String message) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(6.sp),
        border: Border.all(color: const Color(0xFFFEF08A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.lock_outline_rounded,
            size: 16.sp,
            color: const Color(0xFF854D0E),
          ),
          SizedBox(width: 8.sp),
          Text(
            message,
            style: StyleText.fontSize12Weight400.copyWith(
              color: const Color(0xFF854D0E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double minWidth = 720.sp;
        final Widget tableContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header Row
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Category',
                      arabicName: 'الفئة',
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  flex: 3,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Product',
                      arabicName: 'المنتج',
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  flex: 1,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Quantity',
                      arabicName: 'الكمية',
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  flex: 2,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Unit Price',
                      arabicName: 'سعر الوحدة',
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  flex: 2,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Discount',
                      arabicName: 'الخصم',
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  flex: 2,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Tax',
                      arabicName: 'الضريبة',
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  flex: 2,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Total',
                      arabicName: 'الإجمالي',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.sp),
            // Item Rows
            for (int i = 0; i < products.length; i++) ...<Widget>[
              if (i > 0) SizedBox(height: 10.sp),
              _buildProductRow(products[i]),
            ],
          ],
        );

        if (constraints.maxWidth < minWidth) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: minWidth,
              child: tableContent,
            ),
          );
        }

        return tableContent;
      },
    );
  }

  Widget _buildProductRow(QuoteProductPreviewItem item) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: _buildValueBox(item.category, isStartAligned: true),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          flex: 3,
          child: _buildValueBox(item.product, isStartAligned: true),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          flex: 1,
          child: _buildValueBox(item.quantity),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          flex: 2,
          child: _buildValueBox(item.unitPrice),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          flex: 2,
          child: _buildValueBox(item.discount),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          flex: 2,
          child: _buildValueBox(item.tax),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          flex: 2,
          child: _buildValueBox(item.total),
        ),
      ],
    );
  }

  Widget _buildServicesTable(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double minWidth = 650.sp;
        final Widget tableContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header Row
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Category',
                      arabicName: 'الفئة',
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  flex: 3,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Service',
                      arabicName: 'الخدمة',
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  flex: 2,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Price',
                      arabicName: 'السعر',
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  flex: 2,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Discount',
                      arabicName: 'الخصم',
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  flex: 2,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Tax',
                      arabicName: 'الضريبة',
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  flex: 2,
                  child: _buildHeaderCell(
                    FormatHelper.localizedString(
                      englishName: 'Total',
                      arabicName: 'الإجمالي',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.sp),
            // Item Rows
            for (int i = 0; i < services.length; i++) ...<Widget>[
              if (i > 0) SizedBox(height: 10.sp),
              _buildServiceRow(services[i]),
            ],
          ],
        );

        if (constraints.maxWidth < minWidth) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: minWidth,
              child: tableContent,
            ),
          );
        }

        return tableContent;
      },
    );
  }

  Widget _buildServiceRow(QuoteServicePreviewItem item) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: _buildValueBox(item.category, isStartAligned: true),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          flex: 3,
          child: _buildValueBox(item.service, isStartAligned: true),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          flex: 2,
          child: _buildValueBox(item.price),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          flex: 2,
          child: _buildValueBox(item.discount),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          flex: 2,
          child: _buildValueBox(item.tax),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          flex: 2,
          child: _buildValueBox(item.total),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String title) {
    return Text(
      title,
      style: StyleText.fontSize12Weight400.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildValueBox(String value, {bool isStartAligned = false}) {
    return Container(
      height: 40.sp,
      alignment:
          isStartAligned ? AlignmentDirectional.centerStart : Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        value,
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.text,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSummaryRow(
          label: FormatHelper.localizedString(
            englishName: 'Subtotal Products (${products.length} item)',
            arabicName: 'إجمالي المنتجات (${products.length} عناصر)',
          ),
          value: subtotalProducts,
        ),
        SizedBox(height: 8.sp),
        _buildSummaryRow(
          label: FormatHelper.localizedString(
            englishName: 'Subtotal Services (${services.length} services)',
            arabicName: 'إجمالي الخدمات (${services.length} خدمات)',
          ),
          value: subtotalServices,
        ),
        SizedBox(height: 8.sp),
        _buildSummaryRow(
          label: FormatHelper.localizedString(
            englishName: 'Taxes',
            arabicName: 'الضرائب',
          ),
          value: taxes,
        ),
        SizedBox(height: 8.sp),
        _buildSummaryRow(
          label: FormatHelper.localizedString(
            englishName: 'Discount (20%)',
            arabicName: 'الخصم (20%)',
          ),
          value: discount,
          valueColor: const Color(0xFFFF7A00),
        ),
        SizedBox(height: 12.sp),
        const Divider(color: Color(0xFFE5E7EB)),
        SizedBox(height: 8.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              FormatHelper.localizedString(
                englishName: 'Total',
                arabicName: 'الإجمالي',
              ),
              style: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.fullBlack)
                  .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              grandTotal,
              style: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.fullBlack)
                  .copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        Text(
          value,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.text,
          ),
        ),
      ],
    );
  }
}
