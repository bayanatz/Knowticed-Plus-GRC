// ****************** FILE INFO ******************
// File Name: crm_deal_pricing_calculator.dart
// Purpose: Pure calculator for product and service deal snapshots.
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:knowticed_plus/features/crm/crm6_deals/domain/entities/crm_deal_pricing.dart';

class CrmDealPricingCalculator {
  const CrmDealPricingCalculator();

  CrmDealLineTotals calculateLine(CrmDealLineDraft line) {
    final double subtotal = _round(line.quantity * line.unitPrice);
    final double discount = _round(line.discountType.toLowerCase() == 'fixed'
        ? line.discountValue.clamp(0, subtotal)
        : subtotal * (line.discountValue.clamp(0, 100) / 100));
    final double taxableAmount = _round(subtotal - discount);
    final double tax =
        _round(taxableAmount * (line.taxRate.clamp(0, 100) / 100));
    return CrmDealLineTotals(
        subtotal: subtotal,
        discount: discount,
        tax: tax,
        total: _round(taxableAmount + tax));
  }

  CrmDealPricingSummary calculate(Iterable<CrmDealLineDraft> lines) {
    double subtotal = 0;
    double discount = 0;
    double tax = 0;
    for (final CrmDealLineDraft line in lines) {
      final CrmDealLineTotals totals = calculateLine(line);
      subtotal += totals.subtotal;
      discount += totals.discount;
      tax += totals.tax;
    }
    return CrmDealPricingSummary(
        subtotal: _round(subtotal),
        discountTotal: _round(discount),
        taxTotal: _round(tax),
        grandTotal: _round(subtotal - discount + tax));
  }

  double _round(double value) => (value * 100).roundToDouble() / 100;
}
