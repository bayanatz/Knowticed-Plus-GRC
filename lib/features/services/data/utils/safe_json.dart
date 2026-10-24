/// Module: services / data / utils
///
///*************************** FILE INFO ****************************///
/// File Name: safe_json.dart
/// Purpose: Null-returning JSON decode helper so UI code does not need
///          try/catch around jsonDecode (§11.2).
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'dart:convert';

/// Decodes [source] as JSON, returning null instead of throwing on malformed
/// input. Keeps the try/catch in this utility (data layer) rather than in
/// widgets.
dynamic safeJsonDecode(String? source) {
  if (source == null || source.isEmpty) return null;
  try {
    return jsonDecode(source);
  } catch (_) {
    return null;
  }
}
