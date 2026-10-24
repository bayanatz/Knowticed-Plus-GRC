// ****************** FILE INFO ******************
// File Name: crm_add_deal_summary_card.dart
// Purpose: Live calculated summary card for Add Deal Products & Services step
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/entities/crm_deal_line_item_draft.dart';

class CrmAddDealSummaryCard extends StatelessWidget {
  final bool productsEnabled;
  final bool servicesEnabled;
  final List<DealProductLineItem> productLines;
  final List<DealServiceLineItem> serviceLines;
  final String currency;

  const CrmAddDealSummaryCard({
    super.key,
    required this.productsEnabled,
    required this.servicesEnabled,
    required this.productLines,
    required this.serviceLines,
    this.currency = 'EGP',
  });

  @override
  Widget build(BuildContext context) {
    final List<DealProductLineItem> selectedProducts = productLines
        .where((DealProductLineItem line) => line.product != null)
        .toList();
    final List<DealServiceLineItem> selectedServices = serviceLines
        .where((DealServiceLineItem line) => line.service != null)
        .toList();
    final double productsSubtotal = productsEnabled
        ? selectedProducts.fold<double>(
            0.0,
            (double sum, DealProductLineItem p) =>
                sum + ((int.tryParse(p.quantity) ?? 1) * p.unitPrice),
          )
        : 0.0;

    final double servicesSubtotal = servicesEnabled
        ? selectedServices.fold<double>(
            0.0,
            (double sum, DealServiceLineItem s) => sum + s.price,
          )
        : 0.0;

    final double productsDiscount = productsEnabled
        ? selectedProducts.fold<double>(
            0.0,
            (double sum, DealProductLineItem p) =>
                sum +
                (((int.tryParse(p.quantity) ?? 1) * p.unitPrice) *
                    (p.discount / 100.0)),
          )
        : 0.0;

    final double servicesDiscount = servicesEnabled
        ? selectedServices.fold<double>(
            0.0,
            (double sum, DealServiceLineItem s) {
              final double discPercent =
                  double.tryParse(s.discount.replaceAll('%', '')) ?? 0.0;
              return sum + (s.price * (discPercent / 100.0));
            },
          )
        : 0.0;

    final double totalDiscount = productsDiscount + servicesDiscount;

    final double productsTax = productsEnabled
        ? selectedProducts.fold<double>(
            0.0,
            (double sum, DealProductLineItem p) => sum + p.tax,
          )
        : 0.0;

    final double servicesTax = servicesEnabled
        ? selectedServices.fold<double>(
            0.0,
            (double sum, DealServiceLineItem s) => sum + s.tax,
          )
        : 0.0;

    final double totalTaxes = productsTax + servicesTax;

    final double grandTotal =
        (productsSubtotal + servicesSubtotal - totalDiscount) + totalTaxes;

    final int prodCount = productsEnabled ? selectedProducts.length : 0;
    final int servCount = servicesEnabled ? selectedServices.length : 0;

    return Column(
      children: <Widget>[
        _buildSummaryRow(
          title: 'Subtotal Products ($prodCount item)',
          value: '${productsSubtotal.toStringAsFixed(0)} $currency',
        ),
        SizedBox(height: 12.sp),
        _buildSummaryRow(
          title: 'Subtotal Services ($servCount services)',
          value: '${servicesSubtotal.toStringAsFixed(0)} $currency',
        ),
        SizedBox(height: 12.sp),
        _buildSummaryRow(
          title: 'Taxes',
          value: '${totalTaxes.toStringAsFixed(0)} $currency',
        ),
        SizedBox(height: 12.sp),
        _buildSummaryRow(
          title: 'Discount',
          value: '-${totalDiscount.toStringAsFixed(0)} $currency',
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
              '${grandTotal.toStringAsFixed(0)} $currency',
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
