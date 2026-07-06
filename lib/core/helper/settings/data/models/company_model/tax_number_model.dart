/// Module: Settings · Data · Model · TaxNumber
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
/// File Name: tax_number_model.dart
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

class TaxNumber {
  static const String kTaxNumber = 'Tax_Number';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? taxNumber;
  final List<Timestamp?>? timestamps;
  TaxNumber({
    this.taxNumber,
    this.timestamps,
  });

  TaxNumber copyWith({
    List<String?>? taxNumber,
    List<Timestamp?>? timestamps,
  }) {
    return TaxNumber(
      taxNumber: taxNumber ?? this.taxNumber,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kTaxNumber: taxNumber,
      kTimestamp: timestamps,
    };
  }

  factory TaxNumber.fromMap(Map<String, dynamic> map) {
    return TaxNumber(
      taxNumber: map[kTaxNumber] != null
          ? List<String?>.from(
              (map[kTaxNumber]),
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

  factory TaxNumber.fromJson(String source) =>
      TaxNumber.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TaxNumer(Tax_Numer: $taxNumber, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant TaxNumber other) {
    if (identical(this, other)) return true;

    return _listEquals(other.taxNumber, taxNumber) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => taxNumber.hashCode ^ timestamps.hashCode;
}
