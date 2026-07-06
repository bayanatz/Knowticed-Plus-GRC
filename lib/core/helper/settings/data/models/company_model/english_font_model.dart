/// Module: Settings · Data · Model · EnglishFont
/// Description: Versioned value object (value history + timestamps) used as a
///              field of the company model.
/// Author: MohamedFouad
/// Date: 07/01/2024
/// Dependencies: cloud_firestore
/// Revision History:
///   - 07/01/2024 (MohamedFouad): Initial creation.
///   - 26/06/2026 (Amr Mesbah): final fields, const key constants, removed
///       Flutter foundation import, added Module header.
///
/// ************************ FILE INFO ********************************///
/// File Name: english_font_model.dart
/// Purpose: Company sub-model value object.
/// Author: MohamedFouad
/// Created At: 07/01/2024
/// Dependencies: cloud_firestore
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';


/// Pure-Dart list equality (keeps the data layer Flutter-free).
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class EnglishFont {
  static const String kEnglishFont = 'English_Font';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? englishFont;
  final List<Timestamp?>? timestamps;
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
      kEnglishFont: englishFont,
      kTimestamp: timestamps,
    };
  }

  factory EnglishFont.fromMap(Map<String, dynamic> map) {
    return EnglishFont(
      englishFont: map[kEnglishFont] != null
          ? List<String?>.from(
              (map[kEnglishFont]),
            )
          : null,
      timestamps: map[kTimestamp] != null
          ? List<Timestamp?>.from(
              (map[kTimestamp]),
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

    return _listEquals(other.englishFont, englishFont) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => englishFont.hashCode ^ timestamps.hashCode;
}
