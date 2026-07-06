/// Module: Settings · Data · Model · CompanyLogo
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
/// File Name: company_logo_model.dart
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

class CompanyLogo {
  static const String kCompanyLogo = 'Company_Logo';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? companyLogo;
  final List<Timestamp?>? timestamps;
  CompanyLogo({
    this.companyLogo,
    this.timestamps,
  });

  CompanyLogo copyWith({
    List<String?>? companyLogo,
    List<Timestamp?>? timestamps,
  }) {
    return CompanyLogo(
      companyLogo: companyLogo ?? this.companyLogo,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kCompanyLogo: companyLogo,
      kTimestamp: timestamps,
    };
  }

  factory CompanyLogo.fromMap(Map<String, dynamic> map) {
    return CompanyLogo(
      companyLogo: map[kCompanyLogo] != null
          ? List<String?>.from(
              (map[kCompanyLogo]),
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

  factory CompanyLogo.fromJson(String source) =>
      CompanyLogo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanyLogo(Company_Logo: $companyLogo, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanyLogo other) {
    if (identical(this, other)) return true;

    return _listEquals(other.companyLogo, companyLogo) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companyLogo.hashCode ^ timestamps.hashCode;
}
