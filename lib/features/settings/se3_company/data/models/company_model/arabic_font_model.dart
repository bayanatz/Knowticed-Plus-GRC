import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class ArabicFont {
  List<String?>? arabicFont;
  List<Timestamp?>? timestamps;
  ArabicFont({
    this.arabicFont,
    this.timestamps,
  });

  ArabicFont copyWith({
    List<String?>? arabicFont,
    List<Timestamp?>? timestamps,
  }) {
    return ArabicFont(
      arabicFont: arabicFont ?? this.arabicFont,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Arabic_Font': arabicFont,
      'Timestamp': timestamps,
    };
  }

  factory ArabicFont.fromMap(Map<String, dynamic> map) {
    return ArabicFont(
      arabicFont: map['Arabic_Font'] != null
          ? List<String?>.from(
              (map['Arabic_Font']),
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

  factory ArabicFont.fromJson(String source) =>
      ArabicFont.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ArabicFont(Arabic_Font: $arabicFont, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant ArabicFont other) {
    if (identical(this, other)) return true;

    return listEquals(other.arabicFont, arabicFont) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => arabicFont.hashCode ^ timestamps.hashCode;
}
