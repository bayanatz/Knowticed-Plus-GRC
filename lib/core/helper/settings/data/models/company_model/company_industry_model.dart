/// Module: Settings · Data · Model · CompanyIndustry
/// Description: Versioned value object (value history + timestamps) used as a
///              field of the company model.
/// Author: MohamedFouad
/// Date: 07/01/2024
/// Dependencies: cloud_firestore
/// Revision History:
///   - 07/01/2024 (MohamedFouad): Initial creation.
///   - 26/06/2026 (Amr Mesbah): final fields, const key constants, removed
///       Flutter foundation import, added Module header.
///
/// ************************ FILE INFO ********************************///
/// File Name: company_industry_model.dart
/// Purpose: Company sub-model value object.
/// Author: MohamedFouad
/// Created At: 07/01/2024
/// Dependencies: cloud_firestore
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';


/// Pure-Dart list equality (keeps the data layer Flutter-free).
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class CompanyIndustry {
  static const String kCompanyIndustry = 'Company_Industry';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? companyIndustry;
  final List<Timestamp?>? timestamps;
  CompanyIndustry({
    this.companyIndustry,
    this.timestamps,
  });

  CompanyIndustry copyWith({
    List<String?>? companyIndustry,
    List<Timestamp?>? timestamps,
  }) {
    return CompanyIndustry(
      companyIndustry: companyIndustry ?? this.companyIndustry,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kCompanyIndustry: companyIndustry,
      kTimestamp: timestamps,
    };
  }

  factory CompanyIndustry.fromMap(Map<String, dynamic> map) {
    return CompanyIndustry(
      companyIndustry: map[kCompanyIndustry] != null
          ? List<String?>.from(
              (map[kCompanyIndustry]),
            )
          : null,
      timestamps: map[kTimestamp] != null
          ? List<Timestamp?>.from(
              (map[kTimestamp]),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CompanyIndustry.fromJson(String source) =>
      CompanyIndustry.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanyIndustry(Company_Industry: $companyIndustry, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanyIndustry other) {
    if (identical(this, other)) return true;

    return _listEquals(other.companyIndustry, companyIndustry) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companyIndustry.hashCode ^ timestamps.hashCode;
}
