// ****************** FILE INFO ******************
// File Name: crm_request_items_and_summary_sections.dart
// Purpose: Extracted Products/lines, Services, and Summary sections for Request Details page
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmRequestProductsSection extends StatelessWidget {
  const CrmRequestProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Products/lines',
        arabicName: 'المنتجات / البنود',
      ),
      showHideToggle: true,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double minWidth = 720;
          final Widget content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header row
              Row(
                children: <Widget>[
                  Expanded(flex: 3, child: _buildTableHeaderCell('Category')),
                  SizedBox(width: 10.sp),
                  Expanded(flex: 3, child: _buildTableHeaderCell('Product')),
                  SizedBox(width: 10.sp),
                  Expanded(flex: 1, child: _buildTableHeaderCell('Quantity')),
                  SizedBox(width: 10.sp),
                  Expanded(flex: 2, child: _buildTableHeaderCell('Unit Price')),
                  SizedBox(width: 10.sp),
                  Expanded(flex: 2, child: _buildTableHeaderCell('Discount')),
                  SizedBox(width: 10.sp),
                  Expanded(flex: 2, child: _buildTableHeaderCell('Tax')),
                  SizedBox(width: 10.sp),
                  Expanded(flex: 2, child: _buildTableHeaderCell('Total')),
                ],
              ),
              SizedBox(height: 8.sp),
              // Row 1
              _buildProductFlexRow('Category x', 'Product x', '7', '\$50',
                  '20%', '\$50', '\$50'),
              SizedBox(height: 10.sp),
              // Row 2
              _buildProductFlexRow('Category x', 'Product x', '7', '\$50',
                  '20%', '\$50', '\$50'),
            ],
          );

          if (constraints.maxWidth < minWidth) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(width: minWidth, child: content),
            );
          }
          return content;
        },
      ),
    );
  }

  Widget _buildProductFlexRow(
    String category,
    String product,
    String quantity,
    String unitPrice,
    String discount,
    String tax,
    String total,
  ) {
    return Row(
      children: <Widget>[
        Expanded(
            flex: 3,
            child: _buildTableValueBox(category, isStartAligned: true)),
        SizedBox(width: 10.sp),
        Expanded(
            flex: 3, child: _buildTableValueBox(product, isStartAligned: true)),
        SizedBox(width: 10.sp),
        Expanded(flex: 1, child: _buildTableValueBox(quantity)),
        SizedBox(width: 10.sp),
        Expanded(flex: 2, child: _buildTableValueBox(unitPrice)),
        SizedBox(width: 10.sp),
        Expanded(flex: 2, child: _buildTableValueBox(discount)),
        SizedBox(width: 10.sp),
        Expanded(flex: 2, child: _buildTableValueBox(tax)),
        SizedBox(width: 10.sp),
        Expanded(flex: 2, child: _buildTableValueBox(total)),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Text(
      text,
      style: StyleText.fontSize12Weight400.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTableValueBox(String value, {bool isStartAligned = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      alignment: isStartAligned ? Alignment.centerLeft : Alignment.center,
      child: Text(
        value,
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class CrmRequestServicesSection extends StatelessWidget {
  const CrmRequestServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Services',
        arabicName: 'الخدمات',
      ),
      showHideToggle: true,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double minWidth = 720;
          final Widget content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header row
              Row(
                children: <Widget>[
                  Expanded(flex: 3, child: _buildTableHeaderCell('Category')),
                  SizedBox(width: 10.sp),
                  Expanded(flex: 3, child: _buildTableHeaderCell('Service')),
                  SizedBox(width: 10.sp),
                  Expanded(flex: 2, child: _buildTableHeaderCell('Price')),
                  SizedBox(width: 10.sp),
                  Expanded(flex: 2, child: _buildTableHeaderCell('Discount')),
                  SizedBox(width: 10.sp),
                  Expanded(flex: 2, child: _buildTableHeaderCell('Tax')),
                  SizedBox(width: 10.sp),
                  Expanded(flex: 2, child: _buildTableHeaderCell('Total')),
                ],
              ),
              SizedBox(height: 8.sp),
              // Row 1
              _buildServiceFlexRow(
                  'Category x', 'Service x', '\$50', '20%', '\$50', '\$50'),
              SizedBox(height: 10.sp),
              // Row 2
              _buildServiceFlexRow(
                  'Category x', 'Service x', '\$50', '20%', '\$50', '\$50'),
            ],
          );

          if (constraints.maxWidth < minWidth) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(width: minWidth, child: content),
            );
          }
          return content;
        },
      ),
    );
  }

  Widget _buildServiceFlexRow(
    String category,
    String service,
    String price,
    String discount,
    String tax,
    String total,
  ) {
    return Row(
      children: <Widget>[
        Expanded(
            flex: 3,
            child: _buildTableValueBox(category, isStartAligned: true)),
        SizedBox(width: 10.sp),
        Expanded(
            flex: 3, child: _buildTableValueBox(service, isStartAligned: true)),
        SizedBox(width: 10.sp),
        Expanded(flex: 2, child: _buildTableValueBox(price)),
        SizedBox(width: 10.sp),
        Expanded(flex: 2, child: _buildTableValueBox(discount)),
        SizedBox(width: 10.sp),
        Expanded(flex: 2, child: _buildTableValueBox(tax)),
        SizedBox(width: 10.sp),
        Expanded(flex: 2, child: _buildTableValueBox(total)),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Text(
      text,
      style: StyleText.fontSize12Weight400.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTableValueBox(String value, {bool isStartAligned = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      alignment: isStartAligned ? Alignment.centerLeft : Alignment.center,
      child: Text(
        value,
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class CrmRequestSummarySection extends StatelessWidget {
  const CrmRequestSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Summary',
        arabicName: 'الملخص',
      ),
      showHideToggle: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSummaryRow(
            label: FormatHelper.localizedString(
              englishName: 'Subtotal Products (2 item)',
              arabicName: 'إجمالي المنتجات (2 عناصر)',
            ),
            value: '1400 GEP',
          ),
          SizedBox(height: 10.sp),
          _buildSummaryRow(
            label: FormatHelper.localizedString(
              englishName: 'Subtotal Services (2 services)',
              arabicName: 'إجمالي الخدمات (2 خدمات)',
            ),
            value: '1400 GEP',
          ),
          SizedBox(height: 10.sp),
          _buildSummaryRow(
            label: FormatHelper.localizedString(
              englishName: 'Taxes',
              arabicName: 'الضرائب',
            ),
            value: '100 EGP',
          ),
          SizedBox(height: 10.sp),
          _buildSummaryRow(
            label: FormatHelper.localizedString(
              englishName: 'Discount (20%)',
              arabicName: 'الخصم (20%)',
            ),
            value: '-200 EGP',
            valueColor: const Color(0xFFFF7A00),
          ),
          SizedBox(height: 14.sp),
          Divider(
            color: const Color(0xFFE5E7EB),
            thickness: 1.sp,
            height: 1.sp,
          ),
          SizedBox(height: 14.sp),
          _buildSummaryRow(
            label: FormatHelper.localizedString(
              englishName: 'Total',
              arabicName: 'الإجمالي النهائي',
            ),
            value: '1,000 EGP',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.black,
          ),
        ),
        Text(
          value,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 16.sp : 14.sp,
            color: valueColor ?? AppColors.black,
          ),
        ),
      ],
    );
  }
}
