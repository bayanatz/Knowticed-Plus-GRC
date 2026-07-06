/// Module: Settings · Data · Model · City
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
/// File Name: city_model.dart
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

class City {
  static const String kCity = 'City';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? city;
  final List<Timestamp?>? timestamps;
  City({
    this.city,
    this.timestamps,
  });

  City copyWith({
    List<String?>? city,
    List<Timestamp?>? timestamps,
  }) {
    return City(
      city: city ?? this.city,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kCity: city,
      kTimestamp: timestamps,
    };
  }

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      city: map[kCity] != null
          ? List<String?>.from(
              (map[kCity]),
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

  factory City.fromJson(String source) =>
      City.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'City(City: $city, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant City other) {
    if (identical(this, other)) return true;

    return _listEquals(other.city, city) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => city.hashCode ^ timestamps.hashCode;
}
