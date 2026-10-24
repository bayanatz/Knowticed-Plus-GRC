// ****************** FILE INFO ******************
// File Name: crm_deal_pricing.dart
// Purpose: Immutable deal line drafts and calculated pricing totals.
// Author: Mohand Adel
// Created At: 29/08/2026

class CrmDealLineDraft {
  final String itemId;
  final String itemNameEn;
  final String itemNameAr;
  final String categoryId;
  final String categoryNameEn;
  final String categoryNameAr;
  final double quantity;
  final double unitPrice;
  final double taxRate;
  final double discountValue;
  final String discountType;
  final String discountRuleId;

  const CrmDealLineDraft({
    required this.itemId,
    required this.itemNameEn,
    required this.itemNameAr,
    required this.categoryId,
    required this.categoryNameEn,
    required this.categoryNameAr,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
    this.discountValue = 0,
    this.discountType = 'percentage',
    this.discountRuleId = '',
  });

  CrmDealLineDraft copyWith(
          {double? quantity,
          double? unitPrice,
          double? taxRate,
          double? discountValue,
          String? discountType,
          String? discountRuleId}) =>
      CrmDealLineDraft(
        itemId: itemId,
        itemNameEn: itemNameEn,
        itemNameAr: itemNameAr,
        categoryId: categoryId,
        categoryNameEn: categoryNameEn,
        categoryNameAr: categoryNameAr,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        taxRate: taxRate ?? this.taxRate,
        discountValue: discountValue ?? this.discountValue,
        discountType: discountType ?? this.discountType,
        discountRuleId: discountRuleId ?? this.discountRuleId,
      );
}

class CrmDealLineTotals {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  const CrmDealLineTotals(
      {required this.subtotal,
      required this.discount,
      required this.tax,
      required this.total});
}

class CrmDealPricingSummary {
  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;
  const CrmDealPricingSummary(
      {this.subtotal = 0,
      this.discountTotal = 0,
      this.taxTotal = 0,
      this.grandTotal = 0});
}
