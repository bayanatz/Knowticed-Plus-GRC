// ****************** FILE INFO ******************
// File Name: crm_deal_products_tab.dart
// Purpose: Read-only Products tab for Deal Details displaying products selected during deal creation
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/entities/crm_deal_line_item_draft.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmDealProductsTab extends StatefulWidget {
  final CrmClientDealModel deal;

  const CrmDealProductsTab({
    super.key,
    required this.deal,
  });

  @override
  State<CrmDealProductsTab> createState() => _CrmDealProductsTabState();
}

class _CrmDealProductsTabState extends State<CrmDealProductsTab> {
  late final List<DealProductLineItem> _items;

  @override
  void initState() {
    super.initState();
    if (widget.deal.products.isNotEmpty) {
      _items = widget.deal.products
          .map((CrmDealProductItem p) => DealProductLineItem(
                category: p.category,
                product: p.productName,
                quantity: p.qty > 0 ? p.qty.toString() : '1',
                unitPrice: p.price,
                discount: p.discount,
                tax: p.tax,
              ))
          .toList();
    } else if (widget.deal.rawProductLines.isNotEmpty) {
      _items = widget.deal.rawProductLines
          .map((Map<String, dynamic> line) => DealProductLineItem(
                category:
                    '${line['Category_Name_En'] ?? line['Category_Name_Ar'] ?? ''}',
                product: _lineProductName(line),
                quantity: '${line['Quantity'] ?? 1}',
                unitPrice: (line['Unit_Price'] as num?)?.toDouble() ?? 0.0,
                discount: (line['Discount'] as num?)?.toDouble() ??
                    (line['Discount_Value'] as num?)?.toDouble() ??
                    0.0,
                tax: (line['Tax'] as num?)?.toDouble() ??
                    (line['Tax_Rate'] as num?)?.toDouble() ??
                    0.0,
              ))
          .toList();
    } else {
      _items = <DealProductLineItem>[];
    }
  }

  String _lineProductName(Map<String, dynamic> line) {
    final String itemId = '${line['Item_Id'] ?? line['itemId'] ?? ''}'.trim();
    const List<String> keys = <String>[
      'Product_Name_En',
      'Product_Name_Ar',
      'Item_Name_En',
      'Item_Name_Ar',
      'Name_En',
      'Name_Ar',
      'nameEn',
      'nameAr',
      'Name',
    ];
    for (final String key in keys) {
      final String value = '${line[key] ?? ''}'.trim();
      if (value.isNotEmpty && value != itemId) return value;
    }
    return '';
  }

  double get _subtotal => _items.fold<double>(
        0,
        (double sum, DealProductLineItem i) =>
            sum + (int.tryParse(i.quantity) ?? 1) * i.unitPrice,
      );

  double get _taxTotal => _items.fold<double>(
        0,
        (double sum, DealProductLineItem i) => sum + i.tax,
      );

  double get _discountTotal => _items.fold<double>(
        0,
        (double sum, DealProductLineItem i) =>
            sum +
            ((int.tryParse(i.quantity) ?? 1) *
                i.unitPrice *
                (i.discount / 100.0)),
      );

  double get _grandTotal => (_subtotal - _discountTotal) + _taxTotal;

  int get _discountPercentage =>
      _subtotal > 0 ? ((_discountTotal / _subtotal) * 100).round() : 0;

  @override
  Widget build(BuildContext context) {
    final String currency =
        widget.deal.currency.isNotEmpty ? widget.deal.currency : 'EGP';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Section 1: Products Table ─────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Products',
            arabicName: 'المنتجات',
          ),
          child: _items.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.sp),
                  child: Center(
                    child: Text(
                      FormatHelper.localizedString(
                        englishName: 'No products added to this deal.',
                        arabicName: 'لا توجد منتجات مضافة لهذه الصفقة.',
                      ),
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (int i = 0; i < _items.length; i++) ...<Widget>[
                        if (i > 0) SizedBox(height: 16.sp),
                        _buildProductRow(i, _items[i]),
                      ],
                    ],
                  ),
                ),
        ),

        SizedBox(height: 24.sp),

        // ── Section 2: Summary Card ───────────────────────────────────────────
        if (_items.isNotEmpty)
          CrmSectionCard(
            title: FormatHelper.localizedString(
              englishName: 'Summary',
              arabicName: 'الملخص',
            ),
            child: Column(
              children: <Widget>[
                _buildSummaryRow(
                  title:
                      'Subtotal (${_items.length} item${_items.length > 1 ? 's' : ''})',
                  value: '${_subtotal.toInt()} $currency',
                ),
                SizedBox(height: 12.sp),
                _buildSummaryRow(
                  title: 'Taxes',
                  value: '${_taxTotal.toInt()} $currency',
                ),
                SizedBox(height: 12.sp),
                _buildSummaryRow(
                  title: 'Discount ($_discountPercentage%)',
                  value: '-${_discountTotal.toInt()} $currency',
                  valueColor: const Color(0xFFFF7A00),
                ),
                SizedBox(height: 16.sp),
                const Divider(color: Color(0xFFE5E7EB)),
                SizedBox(height: 12.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total',
                      style: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.fullBlack)
                          .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${_grandTotal.toInt()} $currency',
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
            ),
          ),
      ],
    );
  }

  Widget _buildProductRow(int index, DealProductLineItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Category
        SizedBox(
          width: 180.sp,
          child: CustomTextField(
            label: 'Category',
            initialValue: item.category ?? '',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Product
        SizedBox(
          width: 180.sp,
          child: CustomTextField(
            label: 'Product',
            initialValue: item.product ?? '',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Quantity
        SizedBox(
          width: 100.sp,
          child: CustomTextField(
            label: 'Quantity',
            initialValue: item.quantity.isNotEmpty ? item.quantity : '1',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Unit Price
        SizedBox(
          width: 100.sp,
          child: CustomTextField(
            label: 'Unit Price',
            initialValue: '\$${item.unitPrice.toInt()}',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Discount
        SizedBox(
          width: 100.sp,
          child: CustomTextField(
            label: 'Discount',
            initialValue: '${item.discount.toInt()}%',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Tax
        SizedBox(
          width: 100.sp,
          child: CustomTextField(
            label: 'Tax',
            initialValue: '\$${item.tax.toInt()}',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Total
        SizedBox(
          width: 100.sp,
          child: CustomTextField(
            label: 'Total',
            initialValue: '\$${item.total.toInt()}',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        Text(
          value,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.text,
          ),
        ),
      ],
    );
  }
}
