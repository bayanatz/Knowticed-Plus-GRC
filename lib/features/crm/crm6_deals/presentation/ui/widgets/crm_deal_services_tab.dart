// ****************** FILE INFO ******************
// File Name: crm_deal_services_tab.dart
// Purpose: Read-only Services tab for Deal Details displaying services selected during deal creation
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

class CrmDealServicesTab extends StatefulWidget {
  final CrmClientDealModel deal;

  const CrmDealServicesTab({
    super.key,
    required this.deal,
  });

  @override
  State<CrmDealServicesTab> createState() => _CrmDealServicesTabState();
}

class _CrmDealServicesTabState extends State<CrmDealServicesTab> {
  late final List<DealServiceLineItem> _items;

  @override
  void initState() {
    super.initState();
    if (widget.deal.services.isNotEmpty) {
      _items = widget.deal.services
          .map((CrmDealServiceItem s) => DealServiceLineItem(
                category: s.category,
                service: s.serviceName,
                price: s.price,
                discount: s.discount.toInt().toString(),
                tax: s.tax,
              ))
          .toList();
    } else if (widget.deal.rawServiceLines.isNotEmpty) {
      _items = widget.deal.rawServiceLines
          .map((Map<String, dynamic> line) => DealServiceLineItem(
                category:
                    '${line['Category_Name_En'] ?? line['Category_Name_Ar'] ?? ''}',
                service: _lineServiceName(line),
                price: (line['Unit_Price'] as num?)?.toDouble() ?? 0.0,
                discount:
                    '${((line['Discount'] as num?)?.toDouble() ?? (line['Discount_Value'] as num?)?.toDouble() ?? 0.0).toInt()}',
                tax: (line['Tax'] as num?)?.toDouble() ??
                    (line['Tax_Rate'] as num?)?.toDouble() ??
                    0.0,
              ))
          .toList();
    } else {
      _items = <DealServiceLineItem>[];
    }
  }

  String _lineServiceName(Map<String, dynamic> line) {
    final String itemId = '${line['Item_Id'] ?? line['itemId'] ?? ''}'.trim();
    const List<String> keys = <String>[
      'Service_Name_En',
      'Service_Name_Ar',
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
        (double sum, DealServiceLineItem i) => sum + i.price,
      );

  double get _taxTotal => _items.fold<double>(
        0,
        (double sum, DealServiceLineItem i) => sum + i.tax,
      );

  double get _discountTotal => _items.fold<double>(
        0,
        (double sum, DealServiceLineItem i) {
          final double discPercent =
              double.tryParse(i.discount.replaceAll('%', '')) ?? 0.0;
          return sum + (i.price * (discPercent / 100.0));
        },
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
        // ── Section 1: Services Table ─────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Services',
            arabicName: 'الخدمات',
          ),
          child: _items.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.sp),
                  child: Center(
                    child: Text(
                      FormatHelper.localizedString(
                        englishName: 'No services added to this deal.',
                        arabicName: 'لا توجد خدمات مضافة لهذه الصفقة.',
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
                        _buildServiceRow(i, _items[i]),
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
                      'Subtotal (${_items.length} service${_items.length > 1 ? 's' : ''})',
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

  Widget _buildServiceRow(int index, DealServiceLineItem item) {
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

        // Service
        SizedBox(
          width: 180.sp,
          child: CustomTextField(
            label: 'Service',
            initialValue: item.service ?? '',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Price
        SizedBox(
          width: 120.sp,
          child: CustomTextField(
            label: 'Price',
            initialValue: '\$${item.price.toInt()}',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Discount
        SizedBox(
          width: 120.sp,
          child: CustomTextField(
            label: 'Discount',
            initialValue: '${item.discount}%',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Tax
        SizedBox(
          width: 120.sp,
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
          width: 120.sp,
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
