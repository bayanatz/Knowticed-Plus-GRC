/// Module: Settings · Data · Model · CompanySize
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
/// File Name: company_size_model.dart
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

class CompanySize {
  static const String kCompanySize = 'Company_Size';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? companySize;
  final List<Timestamp?>? timestamps;
  CompanySize({
    this.companySize,
    this.timestamps,
  });

  CompanySize copyWith({
    List<String?>? companySize,
    List<Timestamp?>? timestamps,
  }) {
    return CompanySize(
      companySize: companySize ?? this.companySize,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kCompanySize: companySize,
      kTimestamp: timestamps,
    };
  }

  factory CompanySize.fromMap(Map<String, dynamic> map) {
    return CompanySize(
      companySize: map[kCompanySize] != null
          ? List<String?>.from(
              (map[kCompanySize]),
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

  factory CompanySize.fromJson(String source) =>
      CompanySize.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanySize(Company_Size: $companySize, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanySize other) {
    if (identical(this, other)) return true;

    return _listEquals(other.companySize, companySize) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companySize.hashCode ^ timestamps.hashCode;
}
