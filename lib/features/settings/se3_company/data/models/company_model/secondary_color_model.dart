import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class SecondaryColor {
  List<String?>? secondaryColor;
  List<Timestamp?>? timestamps;
  SecondaryColor({
    this.secondaryColor,
    this.timestamps,
  });

  SecondaryColor copyWith({
    List<String?>? secondaryColor,
    List<Timestamp?>? timestamps,
  }) {
    return SecondaryColor(
      secondaryColor: secondaryColor ?? this.secondaryColor,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Secondary_Color': secondaryColor,
      'Timestamp': timestamps,
    };
  }

  factory SecondaryColor.fromMap(Map<String, dynamic> map) {
    return SecondaryColor(
      secondaryColor: map['Secondary_Color'] != null
          ? List<String?>.from(
              (map['Secondary_Color']),
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

  factory SecondaryColor.fromJson(String source) =>
      SecondaryColor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SecondaryColor(Secondary_Color: $secondaryColor, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant SecondaryColor other) {
    if (identical(this, other)) return true;

    return listEquals(other.secondaryColor, secondaryColor) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => secondaryColor.hashCode ^ timestamps.hashCode;
}
