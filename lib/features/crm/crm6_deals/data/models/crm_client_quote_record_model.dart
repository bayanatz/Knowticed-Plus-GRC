// ****************** FILE INFO ******************
// File Name: crm_client_quote_record_model.dart
// Purpose: Persisted immutable quote transaction owned by a client deal.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';

class CrmClientQuoteRecordModel {
  final String id;
  final String clientId;
  final String dealId;
  final String quoteNo;
  final String quoteFamilyId;
  final String? sourceQuoteId;
  final String status;
  final int version;
  final DateTime quoteDate;
  final DateTime validUntil;
  final String currency;
  final List<Map<String, dynamic>> productLines;
  final List<Map<String, dynamic>> serviceLines;
  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;
  final Map<String, dynamic> paymentTerm;
  final Map<String, dynamic> deliveryTerm;
  final String noteEn;
  final String noteAr;
  final List<Map<String, dynamic>> attachments;
  final DateTime createdAt;
  final String createdBy;
  final String decisionBy;
  final DateTime? decisionAt;
  final String rejectReason;

  const CrmClientQuoteRecordModel({
    required this.id,
    required this.clientId,
    required this.dealId,
    required this.quoteNo,
    required this.quoteFamilyId,
    this.sourceQuoteId,
    required this.status,
    required this.version,
    required this.quoteDate,
    required this.validUntil,
    required this.currency,
    required this.productLines,
    required this.serviceLines,
    required this.subtotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.grandTotal,
    required this.paymentTerm,
    required this.deliveryTerm,
    required this.noteEn,
    required this.noteAr,
    required this.attachments,
    required this.createdAt,
    required this.createdBy,
    this.decisionBy = '',
    this.decisionAt,
    this.rejectReason = '',
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'Id': id,
        'Client_Id': clientId,
        'Deal_Id': dealId,
        'Quote_No': quoteNo,
        'Quote_Family_Id': quoteFamilyId,
        if (sourceQuoteId != null) 'Source_Quote_Id': sourceQuoteId,
        'Status': status,
        'Version': version,
        'Quote_Date': Timestamp.fromDate(quoteDate),
        'Valid_Until': Timestamp.fromDate(validUntil),
        'Currency': currency,
        'Product_Lines': productLines,
        'Service_Lines': serviceLines,
        'Subtotal': subtotal,
        'Discount_Total': discountTotal,
        'Tax_Total': taxTotal,
        'Grand_Total': grandTotal,
        'Payment_Term': paymentTerm,
        'Delivery_Term': deliveryTerm,
        'Note_En': noteEn,
        'Note_Ar': noteAr,
        'Attachments': attachments,
        'Created_At': Timestamp.fromDate(createdAt),
        'Created_By': createdBy,
        if (decisionBy.isNotEmpty) 'Decision_By': decisionBy,
        if (decisionAt != null) 'Decision_At': Timestamp.fromDate(decisionAt!),
        if (rejectReason.isNotEmpty) 'Reject_Reason': rejectReason,
      };

  factory CrmClientQuoteRecordModel.fromMap(Map<String, dynamic> map) {
    DateTime date(String key) =>
        (map[key] as Timestamp?)?.toDate() ?? DateTime.now();
    DateTime? nullableDate(String key) => (map[key] as Timestamp?)?.toDate();
    double number(String key) => (map[key] as num?)?.toDouble() ?? 0;
    List<Map<String, dynamic>> maps(String key) =>
        (map[key] as List? ?? const <dynamic>[])
            .whereType<Map>()
            .map((dynamic item) => Map<String, dynamic>.from(item as Map))
            .toList();
    Map<String, dynamic> object(String key) => map[key] is Map
        ? Map<String, dynamic>.from(map[key] as Map)
        : <String, dynamic>{};
    return CrmClientQuoteRecordModel(
      id: '${map['Id'] ?? ''}',
      clientId: '${map['Client_Id'] ?? ''}',
      dealId: '${map['Deal_Id'] ?? ''}',
      quoteNo: '${map['Quote_No'] ?? ''}',
      quoteFamilyId: '${map['Quote_Family_Id'] ?? map['Id'] ?? ''}',
      sourceQuoteId: map['Source_Quote_Id'] as String?,
      status: '${map['Status'] ?? 'draft'}',
      version: (map['Version'] as num?)?.toInt() ?? 1,
      quoteDate: date('Quote_Date'),
      validUntil: date('Valid_Until'),
      currency: '${map['Currency'] ?? 'EGP'}',
      productLines: maps('Product_Lines'),
      serviceLines: maps('Service_Lines'),
      subtotal: number('Subtotal'),
      discountTotal: number('Discount_Total'),
      taxTotal: number('Tax_Total'),
      grandTotal: number('Grand_Total'),
      paymentTerm: object('Payment_Term'),
      deliveryTerm: object('Delivery_Term'),
      noteEn: '${map['Note_En'] ?? ''}',
      noteAr: '${map['Note_Ar'] ?? ''}',
      attachments: maps('Attachments'),
      createdAt: date('Created_At'),
      createdBy: '${map['Created_By'] ?? ''}',
      decisionBy: '${map['Decision_By'] ?? ''}',
      decisionAt: nullableDate('Decision_At'),
      rejectReason: '${map['Reject_Reason'] ?? ''}',
    );
  }
}
