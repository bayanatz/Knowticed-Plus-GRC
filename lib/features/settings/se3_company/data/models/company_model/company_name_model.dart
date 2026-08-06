import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class CompanyName {
  List<String?>? companyName;
  List<Timestamp?>? timestamps;
  CompanyName({
    this.companyName,
    this.timestamps,
  });

  CompanyName copyWith({
    List<String?>? companyName,
    List<Timestamp?>? timestamps,
  }) {
    return CompanyName(
      companyName: companyName ?? this.companyName,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Company_Name': companyName,
      'Timestamp': timestamps,
    };
  }

  factory CompanyName.fromMap(Map<String, dynamic> map) {
    return CompanyName(
      companyName: map['Company_Name'] != null
          ? List<String?>.from(
              (map['Company_Name']),
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

  factory CompanyName.fromJson(String source) =>
      CompanyName.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanyName(Company_Name: $companyName, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanyName other) {
    if (identical(this, other)) return true;

    return listEquals(other.companyName, companyName) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companyName.hashCode ^ timestamps.hashCode;
}
