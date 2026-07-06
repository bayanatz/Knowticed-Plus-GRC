/// Module: Settings · Data · Model · ZipCode
/// Description: Versioned zip-code value (value history + timestamps) used inside
///              the company model.
/// Author: MohamedFouad
/// Date: 07/01/2024
/// Dependencies: cloud_firestore
/// Revision History:
///   - 07/01/2024 (MohamedFouad): Initial creation.
///   - 26/06/2026 (Amr Mesbah): Renamed file to *_model, final fields, const
///       key constants, removed Flutter foundation import, added headers.
library;

///*************************** FILE INFO ****************************///
/// File Name: zip_code_model.dart
/// Purpose: Versioned zip-code value object for the company model.
/// Author: MohamedFouad
/// Created At: 07/01/2024

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Pure-Dart list equality (keeps the data layer free of any Flutter import).
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Versioned zip-code value object (history of values + matching timestamps).
class ZipCode {
  static const String kZipCode = 'Zip_Code';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? zipCode;
  final List<Timestamp?>? timestamps;

  ZipCode({
    this.zipCode,
    this.timestamps,
  });

  ZipCode copyWith({
    List<String?>? zipCode,
    List<Timestamp?>? timestamps,
  }) {
    return ZipCode(
      zipCode: zipCode ?? this.zipCode,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kZipCode: zipCode,
      kTimestamp: timestamps,
    };
  }

  factory ZipCode.fromMap(Map<String, dynamic> map) {
    return ZipCode(
      zipCode:
          map[kZipCode] != null ? List<String?>.from((map[kZipCode])) : null,
      timestamps: map[kTimestamp] != null
          ? List<Timestamp?>.from((map[kTimestamp]))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ZipCode.fromJson(String source) =>
      ZipCode.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ZipCode(Zip_Code: $zipCode, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant ZipCode other) {
    if (identical(this, other)) return true;

    return _listEquals(other.zipCode, zipCode) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => zipCode.hashCode ^ timestamps.hashCode;
}
