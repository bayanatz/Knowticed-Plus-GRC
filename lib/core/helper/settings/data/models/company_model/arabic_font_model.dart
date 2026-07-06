/// Module: Settings · Data · Model · ArabicFont
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
/// File Name: arabic_font_model.dart
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

class ArabicFont {
  static const String kArabicFont = 'Arabic_Font';
  static const String kTimestamp = 'Timestamp';

  final List<String?>? arabicFont;
  final List<Timestamp?>? timestamps;
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
      kArabicFont: arabicFont,
      kTimestamp: timestamps,
    };
  }

  factory ArabicFont.fromMap(Map<String, dynamic> map) {
    return ArabicFont(
      arabicFont: map[kArabicFont] != null
          ? List<String?>.from(
              (map[kArabicFont]),
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

  factory ArabicFont.fromJson(String source) =>
      ArabicFont.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ArabicFont(Arabic_Font: $arabicFont, Timestamp: $timestamps)';

  @override
  bool operator ==(covariant ArabicFont other) {
    if (identical(this, other)) return true;

    return _listEquals(other.arabicFont, arabicFont) &&
        _listEquals(other.timestamps, timestamps);
  }

  @override
  int get hashCode => arabicFont.hashCode ^ timestamps.hashCode;
}
