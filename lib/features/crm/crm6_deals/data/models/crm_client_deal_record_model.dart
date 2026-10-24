// ****************** FILE INFO ******************
// File Name: crm_client_deal_record_model.dart
// Purpose: Persisted client-deal transaction with immutable master snapshots.
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';

class CrmClientDealRecordModel {
  final String id;
  final String clientId;
  final String categoryId;
  final String categoryNameEn;
  final String categoryNameAr;
  final String currentStageId;
  final String stageNameEn;
  final String stageNameAr;
  final String assignedEmployeeId;
  final String assignedEmployeeName;
  final String nameEn;
  final String nameAr;
  final String noteEn;
  final String noteAr;
  final String currency;
  final double expectedValue;
  final double likelihood;
  final DateTime startDate;
  final DateTime closeDate;
  final String status;
  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;
  final List<Map<String, dynamic>> productLines;
  final List<Map<String, dynamic>> serviceLines;
  final List<Map<String, dynamic>> checklist;
  final DateTime createdAt;
  final String createdBy;

  const CrmClientDealRecordModel({
    required this.id,
    required this.clientId,
    required this.categoryId,
    required this.categoryNameEn,
    required this.categoryNameAr,
    required this.currentStageId,
    required this.stageNameEn,
    required this.stageNameAr,
    required this.assignedEmployeeId,
    required this.assignedEmployeeName,
    required this.nameEn,
    required this.nameAr,
    required this.noteEn,
    required this.noteAr,
    required this.currency,
    required this.expectedValue,
    required this.likelihood,
    required this.startDate,
    required this.closeDate,
    required this.status,
    required this.subtotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.grandTotal,
    required this.productLines,
    required this.serviceLines,
    required this.checklist,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'Id': id,
        'Client_Id': clientId,
        'Category_Id': categoryId,
        'Category_Name_En': categoryNameEn,
        'Category_Name_Ar': categoryNameAr,
        'Current_Stage_Id': currentStageId,
        'Stage_Name_En': stageNameEn,
        'Stage_Name_Ar': stageNameAr,
        'Assigned_Employee_Id': assignedEmployeeId,
        'Assigned_Employee_Name': assignedEmployeeName,
        'Name_En': nameEn,
        'Name_Ar': nameAr,
        'Note_En': noteEn,
        'Note_Ar': noteAr,
        'Currency': currency,
        'Expected_Value': expectedValue,
        'Likelihood': likelihood,
        'Start_Date': Timestamp.fromDate(startDate),
        'Close_Date': Timestamp.fromDate(closeDate),
        'Status': status,
        'Subtotal': subtotal,
        'Discount_Total': discountTotal,
        'Tax_Total': taxTotal,
        'Grand_Total': grandTotal,
        'Product_Lines': productLines,
        'Service_Lines': serviceLines,
        'Stage_Checklist': checklist,
        'Created_At': Timestamp.fromDate(createdAt),
        'Created_By': createdBy,
      };

  factory CrmClientDealRecordModel.fromMap(Map<String, dynamic> map) {
    DateTime date(String key) =>
        (map[key] as Timestamp?)?.toDate() ?? DateTime.now();
    double number(String key) => (map[key] as num?)?.toDouble() ?? 0;
    List<Map<String, dynamic>> maps(String key) =>
        (map[key] as List? ?? const <dynamic>[])
            .whereType<Map>()
            .map((dynamic value) => Map<String, dynamic>.from(value as Map))
            .toList();
    return CrmClientDealRecordModel(
      id: '${map['Id'] ?? ''}',
      clientId: '${map['Client_Id'] ?? ''}',
      categoryId: '${map['Category_Id'] ?? ''}',
      categoryNameEn: '${map['Category_Name_En'] ?? ''}',
      categoryNameAr: '${map['Category_Name_Ar'] ?? ''}',
      currentStageId: '${map['Current_Stage_Id'] ?? ''}',
      stageNameEn: '${map['Stage_Name_En'] ?? ''}',
      stageNameAr: '${map['Stage_Name_Ar'] ?? ''}',
      assignedEmployeeId: '${map['Assigned_Employee_Id'] ?? ''}',
      assignedEmployeeName: '${map['Assigned_Employee_Name'] ?? ''}',
      nameEn: '${map['Name_En'] ?? ''}',
      nameAr: '${map['Name_Ar'] ?? ''}',
      noteEn: '${map['Note_En'] ?? ''}',
      noteAr: '${map['Note_Ar'] ?? ''}',
      currency: '${map['Currency'] ?? 'EGP'}',
      expectedValue: number('Expected_Value'),
      likelihood: number('Likelihood'),
      startDate: date('Start_Date'),
      closeDate: date('Close_Date'),
      status: '${map['Status'] ?? 'active'}',
      subtotal: number('Subtotal'),
      discountTotal: number('Discount_Total'),
      taxTotal: number('Tax_Total'),
      grandTotal: number('Grand_Total'),
      productLines: maps('Product_Lines'),
      serviceLines: maps('Service_Lines'),
      checklist: maps('Stage_Checklist'),
      createdAt: date('Created_At'),
      createdBy: '${map['Created_By'] ?? ''}',
    );
  }
}
