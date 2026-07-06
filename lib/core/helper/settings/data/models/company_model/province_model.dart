/// Module: Settings · Data · Model · Province
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
/// File Name: province_model.dart
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

class Province {
  static const String kProvince = 'Province';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? province;
  final List<Timestamp?>? timestamps;
  Province({
    this.province,
    this.timestamps,
  });

  Province copyWith({
    List<String?>? province,
    List<Timestamp?>? timestamps,
  }) {
    return Province(
      province: province ?? this.province,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kProvince: province,
      kTimestamp: timestamps,
    };
  }

  factory Province.fromMap(Map<String, dynamic> map) {
    return Province(
      province: map[kProvince] != null
          ? List<String?>.from(
              (map[kProvince]),
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

  factory Province.fromJson(String source) =>
      Province.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Province(Province: $province, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Province other) {
    if (identical(this, other)) return true;

    return _listEquals(other.province, province) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => province.hashCode ^ timestamps.hashCode;
}
