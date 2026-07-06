/// Module: Settings · Data · Model · CompanyModules
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
/// File Name: modules_model.dart
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

class CompanyModules {
  static const String kModules = 'Modules';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? modules;
  final List<Timestamp?>? timestamps;
  CompanyModules({
    this.modules,
    this.timestamps,
  });

  CompanyModules copyWith({
    List<String?>? modules,
    List<Timestamp?>? timestamps,
  }) {
    return CompanyModules(
      modules: modules ?? this.modules,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kModules: modules,
      kTimestamp: timestamps,
    };
  }

  factory CompanyModules.fromMap(Map<String, dynamic> map) {
    return CompanyModules(
      modules: map[kModules] != null
          ? List<String?>.from(
              (map[kModules]),
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

  factory CompanyModules.fromJson(String source) =>
      CompanyModules.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Modules(Modules: $modules, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanyModules other) {
    if (identical(this, other)) return true;

    return _listEquals(other.modules, modules) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => modules.hashCode ^ timestamps.hashCode;
}
