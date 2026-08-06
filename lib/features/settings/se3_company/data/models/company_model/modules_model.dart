import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class CompanyModules {
  List<String?>? modules;
  List<Timestamp?>? timestamps;
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
      'Modules': modules,
      'Timestamp': timestamps,
    };
  }

  factory CompanyModules.fromMap(Map<String, dynamic> map) {
    return CompanyModules(
      modules: map['Modules'] != null
          ? List<String?>.from(
              (map['Modules']),
            )
          : null,
      timestamps: map['Timestamp'] != null
          ? List<Timestamp?>.from(
              (map['Timestamp']),
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

    return listEquals(other.modules, modules) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => modules.hashCode ^ timestamps.hashCode;
}
