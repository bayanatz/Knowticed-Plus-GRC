import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class Department {
  List<String?>? department;
  List<Timestamp?>? timestamps;
  Department({
    this.department,
    this.timestamps,
  });

  Department copyWith({
    List<String?>? department,
    List<Timestamp?>? timestamps,
  }) {
    return Department(
      department: department ?? this.department,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Department': department,
      'Timestamp': timestamps,
    };
  }

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      department: map['Department'] != null
          ? List<String?>.from(
              (map['Department']),
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

  factory Department.fromJson(String source) =>
      Department.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Department(Department: $department, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant Department other) {
    if (identical(this, other)) return true;

    return listEquals(other.department, department) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => department.hashCode ^ timestamps.hashCode;
}
