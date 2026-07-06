/// Module: Settings · Data · Model · Country
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
/// File Name: country_model.dart
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

class Country {
  static const String kCountry = 'Country';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? country;
  final List<Timestamp?>? timestamps;
  Country({
    this.country,
    this.timestamps,
  });

  Country copyWith({
    List<String?>? country,
    List<Timestamp?>? timestamps,
  }) {
    return Country(
      country: country ?? this.country,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kCountry: country,
      kTimestamp: timestamps,
    };
  }

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      country: map[kCountry] != null
          ? List<String?>.from(
              (map[kCountry]),
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

  factory Country.fromJson(String source) =>
      Country.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Country(Country: $country, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Country other) {
    if (identical(this, other)) return true;

    return _listEquals(other.country, country) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => country.hashCode ^ timestamps.hashCode;
}
