// ****************** FILE INFO ******************
// File Name: crm_deal_line_item_draft.dart
// Purpose: Draft line item models for Products and Services in Add Deal wizard & Deal Details
// Author: Mohand Adel
// Created At: 29/08/2026

class DealProductLineItem {
  String? category;
  String? product;
  String quantity;
  double unitPrice;
  double discount;
  double tax;

  DealProductLineItem({
    this.category,
    this.product,
    this.quantity = '',
    this.unitPrice = 50.0,
    this.discount = 20.0,
    this.tax = 50.0,
  });

  double get total {
    final int q = int.tryParse(quantity) ?? 1;
    final double sub = q * unitPrice;
    final double disc = sub * (discount / 100.0);
    return (sub - disc) + tax;
  }
}

class DealServiceLineItem {
  String? category;
  String? service;
  double price;
  String discount;
  double tax;

  DealServiceLineItem({
    this.category,
    this.service,
    this.price = 50.0,
    this.discount = '10',
    this.tax = 50.0,
  });

  double get total {
    final double discPercent =
        double.tryParse(discount.replaceAll('%', '')) ?? 0.0;
    final double disc = price * (discPercent / 100.0);
    return (price - disc) + tax;
  }
}
