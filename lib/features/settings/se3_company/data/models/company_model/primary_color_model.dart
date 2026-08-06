import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class PrimaryColor {
  List<String?>? primaryColor;
  List<Timestamp?>? timestamps;
  PrimaryColor({
    this.primaryColor,
    this.timestamps,
  });

  PrimaryColor copyWith({
    List<String?>? primaryColor,
    List<Timestamp?>? timestamps,
  }) {
    return PrimaryColor(
      primaryColor: primaryColor ?? this.primaryColor,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Primary_Color': primaryColor,
      'Timestamp': timestamps,
    };
  }

  factory PrimaryColor.fromMap(Map<String, dynamic> map) {
    return PrimaryColor(
      primaryColor: map['Primary_Color'] != null
          ? List<String?>.from(
              (map['Primary_Color']),
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

  factory PrimaryColor.fromJson(String source) =>
      PrimaryColor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'PrimaryColor(Primary_Color: $primaryColor, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant PrimaryColor other) {
    if (identical(this, other)) return true;

    return listEquals(other.primaryColor, primaryColor) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => primaryColor.hashCode ^ timestamps.hashCode;
}
