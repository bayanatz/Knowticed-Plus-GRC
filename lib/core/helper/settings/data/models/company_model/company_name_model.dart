/// Module: Settings · Data · Model · CompanyName
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
/// File Name: company_name_model.dart
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

class CompanyName {
  static const String kCompanyName = 'Company_Name';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? companyName;
  final List<Timestamp?>? timestamps;
  CompanyName({
    this.companyName,
    this.timestamps,
  });

  CompanyName copyWith({
    List<String?>? companyName,
    List<Timestamp?>? timestamps,
  }) {
    return CompanyName(
      companyName: companyName ?? this.companyName,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kCompanyName: companyName,
      kTimestamp: timestamps,
    };
  }

  factory CompanyName.fromMap(Map<String, dynamic> map) {
    return CompanyName(
      companyName: map[kCompanyName] != null
          ? List<String?>.from(
              (map[kCompanyName]),
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

  factory CompanyName.fromJson(String source) =>
      CompanyName.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanyName(Company_Name: $companyName, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanyName other) {
    if (identical(this, other)) return true;

    return _listEquals(other.companyName, companyName) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companyName.hashCode ^ timestamps.hashCode;
}
