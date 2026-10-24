/// Module: knowledge_hub/data/utils
///
///*************************** FILE INFO ****************************///
/// File Name: kh_log.dart
/// Description: `khLog` — the Knowledge Hub's debug-only logger.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Rule Bug 6 — "no print / debugPrint". The approvals code had ~260 log
/// calls, many printing user e-mails and supervisor relationships, and all of
/// them ran in release builds. Every call now goes through here and does
/// NOTHING outside debug mode.
void khLog(
  String message, {
  String name = 'KnowledgeHub',
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) return;
  developer.log(message, name: name, error: error, stackTrace: stackTrace);
}
