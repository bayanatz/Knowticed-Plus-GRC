import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class TaxNumber {
  List<String?>? taxNumber;
  List<Timestamp?>? timestamps;
  TaxNumber({
    this.taxNumber,
    this.timestamps,
  });

  TaxNumber copyWith({
    List<String?>? taxNumber,
    List<Timestamp?>? timestamps,
  }) {
    return TaxNumber(
      taxNumber: taxNumber ?? this.taxNumber,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Tax_Number': taxNumber,
      'Timestamp': timestamps,
    };
  }

  factory TaxNumber.fromMap(Map<String, dynamic> map) {
    return TaxNumber(
      taxNumber: map['Tax_Number'] != null
          ? List<String?>.from(
              (map['Tax_Number']),
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

  factory TaxNumber.fromJson(String source) =>
      TaxNumber.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TaxNumer(Tax_Numer: $taxNumber, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant TaxNumber other) {
    if (identical(this, other)) return true;

    return listEquals(other.taxNumber, taxNumber) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => taxNumber.hashCode ^ timestamps.hashCode;
}
