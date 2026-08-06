import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class CompanyIndustry {
  List<String?>? companyIndustry;
  List<Timestamp?>? timestamps;
  CompanyIndustry({
    this.companyIndustry,
    this.timestamps,
  });

  CompanyIndustry copyWith({
    List<String?>? companyIndustry,
    List<Timestamp?>? timestamps,
  }) {
    return CompanyIndustry(
      companyIndustry: companyIndustry ?? this.companyIndustry,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Company_Industry': companyIndustry,
      'Timestamp': timestamps,
    };
  }

  factory CompanyIndustry.fromMap(Map<String, dynamic> map) {
    return CompanyIndustry(
      companyIndustry: map['Company_Industry'] != null
          ? List<String?>.from(
              (map['Company_Industry']),
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

  factory CompanyIndustry.fromJson(String source) =>
      CompanyIndustry.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanyIndustry(Company_Industry: $companyIndustry, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanyIndustry other) {
    if (identical(this, other)) return true;

    return listEquals(other.companyIndustry, companyIndustry) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companyIndustry.hashCode ^ timestamps.hashCode;
}
