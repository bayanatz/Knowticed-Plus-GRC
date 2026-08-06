import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class CompanyLogo {
  List<String?>? companyLogo;
  List<Timestamp?>? timestamps;
  CompanyLogo({
    this.companyLogo,
    this.timestamps,
  });

  CompanyLogo copyWith({
    List<String?>? companyLogo,
    List<Timestamp?>? timestamps,
  }) {
    return CompanyLogo(
      companyLogo: companyLogo ?? this.companyLogo,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Company_Logo': companyLogo,
      'Timestamp': timestamps,
    };
  }

  factory CompanyLogo.fromMap(Map<String, dynamic> map) {
    return CompanyLogo(
      companyLogo: map['Company_Logo'] != null
          ? List<String?>.from(
              (map['Company_Logo']),
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

  factory CompanyLogo.fromJson(String source) =>
      CompanyLogo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CompanyLogo(Company_Logo: $companyLogo, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant CompanyLogo other) {
    if (identical(this, other)) return true;

    return listEquals(other.companyLogo, companyLogo) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => companyLogo.hashCode ^ timestamps.hashCode;
}
