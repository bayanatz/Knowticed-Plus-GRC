/// Module: Settings · Data · Model · PrimaryColor
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
/// File Name: primary_color_model.dart
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

class PrimaryColor {
  static const String kPrimaryColor = 'Primary_Color';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? primaryColor;
  final List<Timestamp?>? timestamps;
  PrimaryColor({
    this.primaryColor,
    this.timestamps,
  });

  PrimaryColor copyWith({
    List<String?>? primaryColor,
    List<Timestamp?>? timestamps,
  }) {
    return PrimaryColor(
      primaryColor: primaryColor ?? this.primaryColor,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kPrimaryColor: primaryColor,
      kTimestamp: timestamps,
    };
  }

  factory PrimaryColor.fromMap(Map<String, dynamic> map) {
    return PrimaryColor(
      primaryColor: map[kPrimaryColor] != null
          ? List<String?>.from(
              (map[kPrimaryColor]),
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

  factory PrimaryColor.fromJson(String source) =>
      PrimaryColor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'PrimaryColor(Primary_Color: $primaryColor, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant PrimaryColor other) {
    if (identical(this, other)) return true;

    return _listEquals(other.primaryColor, primaryColor) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => primaryColor.hashCode ^ timestamps.hashCode;
}
