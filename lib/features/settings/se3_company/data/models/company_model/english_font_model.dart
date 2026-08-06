import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:January/7/2024
class EnglishFont {
  List<String?>? englishFont;
  List<Timestamp?>? timestamps;
  EnglishFont({
    this.englishFont,
    this.timestamps,
  });

  EnglishFont copyWith({
    List<String?>? englishFont,
    List<Timestamp?>? timestamps,
  }) {
    return EnglishFont(
      englishFont: englishFont ?? this.englishFont,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'English_Font': englishFont,
      'Timestamp': timestamps,
    };
  }

  factory EnglishFont.fromMap(Map<String, dynamic> map) {
    return EnglishFont(
      englishFont: map['English_Font'] != null
          ? List<String?>.from(
              (map['English_Font']),
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

  factory EnglishFont.fromJson(String source) =>
      EnglishFont.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'EnglishFont(English_Font: $englishFont, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant EnglishFont other) {
    if (identical(this, other)) return true;

    return listEquals(other.englishFont, englishFont) &&
        listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => englishFont.hashCode ^ timestamps.hashCode;
}
