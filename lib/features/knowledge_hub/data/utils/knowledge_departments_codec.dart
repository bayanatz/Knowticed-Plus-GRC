/// Module: knowledge_hub/data/utils
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_departments_codec.dart
/// Description: Reads the stored "limited departments" of a knowledge
///              document in both of its stored forms.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'dart:convert';

class KnowledgeDepartmentsCodec {
  const KnowledgeDepartmentsCodec._();

  /// `[]` for a public document, the department list for a restricted one,
  /// or null when the value cannot be read (KH-CREATE-02: the caller must
  /// then treat the document as restricted).
  ///
  /// Two stored forms: a history of JSON array strings (the last one wins),
  /// or the plain department names.
  static List<String>? decode(List<String> raw) {
    if (raw.isEmpty) return const [];
    final List<String> jsonEntries = raw
        .where((e) => e.trim().startsWith('['))
        .toList(growable: false);
    if (jsonEntries.isEmpty) {
      return raw.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    final Object? decoded = _tryDecode(jsonEntries.last.trim());
    if (decoded is! List) return null;
    return decoded
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static String encode(List<String> departments) => jsonEncode(departments);

  static Object? _tryDecode(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }
}
