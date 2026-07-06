/// Module: Settings · Data · Model · SecondaryColor
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
/// File Name: secondary_color_model.dart
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

class SecondaryColor {
  static const String kSecondaryColor = 'Secondary_Color';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? secondaryColor;
  final List<Timestamp?>? timestamps;
  SecondaryColor({
    this.secondaryColor,
    this.timestamps,
  });

  SecondaryColor copyWith({
    List<String?>? secondaryColor,
    List<Timestamp?>? timestamps,
  }) {
    return SecondaryColor(
      secondaryColor: secondaryColor ?? this.secondaryColor,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kSecondaryColor: secondaryColor,
      kTimestamp: timestamps,
    };
  }

  factory SecondaryColor.fromMap(Map<String, dynamic> map) {
    return SecondaryColor(
      secondaryColor: map[kSecondaryColor] != null
          ? List<String?>.from(
              (map[kSecondaryColor]),
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

  factory SecondaryColor.fromJson(String source) =>
      SecondaryColor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SecondaryColor(Secondary_Color: $secondaryColor, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant SecondaryColor other) {
    if (identical(this, other)) return true;

    return _listEquals(other.secondaryColor, secondaryColor) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => secondaryColor.hashCode ^ timestamps.hashCode;
}
