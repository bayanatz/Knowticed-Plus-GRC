import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class ZipCode {
  List<String?>? zipCode;
  List<Timestamp?>? timestamps;
  ZipCode({
    this.zipCode,
    this.timestamps,
  });

  ZipCode copyWith({
    List<String?>? zipCode,
    List<Timestamp?>? timestamps,
  }) {
    return ZipCode(
      zipCode: zipCode ?? this.zipCode,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Zip_Code': zipCode,
      'Timestamp': timestamps,
    };
  }

  factory ZipCode.fromMap(Map<String, dynamic> map) {
    return ZipCode(
      zipCode: map['Zip_Code'] != null
          ? List<String?>.from(
              (map['Zip_Code']),
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

  factory ZipCode.fromJson(String source) =>
      ZipCode.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ZipCode(Zip_Code: $zipCode, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant ZipCode other) {
    if (identical(this, other)) return true;

    return listEquals(other.zipCode, zipCode) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => zipCode.hashCode ^ timestamps.hashCode;
}
