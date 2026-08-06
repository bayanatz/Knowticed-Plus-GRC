import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class CompanySize {
  List<String?>? companySize;
  List<Timestamp?>? timestamps;
  CompanySize({
    this.companySize,
    this.timestamps,
  });

  CompanySize copyWith({
    List<String?>? companySize,
    List<Timestamp?>? timestamps,
  }) {
    return CompanySize(
      companySize: companySize ?? this.companySize,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Company_Size': companySize,
      'Timestamp': timestamps,
    };
  }

  factory CompanySize.fromMap(Map<String, dynamic> map) {
    return CompanySize(
      companySize: map['Company_Size'] != null
          ? List<String?>.from(
              (map['Company_Size']),
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

  factory CompanySize.fromJson(String source) =>
      CompanySize.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanySize(Company_Size: $companySize, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanySize other) {
    if (identical(this, other)) return true;

    return listEquals(other.companySize, companySize) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companySize.hashCode ^ timestamps.hashCode;
}
