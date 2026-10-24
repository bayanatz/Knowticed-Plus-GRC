/// Module: knowledge_hub_module / core/knowledge_hub_firebase_services.dart
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_hub_firebase_services.dart
/// Description: Knowledge hub firebase services — knowledge_hub_module core/widgets.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/kh_firestore_keys.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data_json.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_system_log.dart';

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

part 'knowledge_hub_firebase_services.part.1.dart';
part 'knowledge_hub_firebase_services.part.2.dart';

/// Outcome of a knowledge-removal request, so the UI can react without
/// touching Firestore or knowing collection paths (CR-KP-KH §3 / §15).
enum RemoveKnowledgeResult { success, notFound, alreadyRemoved, error }

/// Result of a reason-based knowledge removal — carries the creator info the
/// UI needs to send notifications, without exposing Firestore (CR-KH-S5-04).
class RemoveKnowledgeReasonResult {
  final String creatorEmail;
  final String documentNameEnglish;
  final String documentNameArabic;

  const RemoveKnowledgeReasonResult({
    required this.creatorEmail,
    required this.documentNameEnglish,
    required this.documentNameArabic,
  });
}

/// Firestore and Storage access for the Knowledge Hub documents. The methods
/// live in the two mixins of the part files; the shared fields live here.
class KnowledgeHubFirebaseServices extends KnowledgeHubFirebaseServicesBase
    with KnowledgeHubServicesPart1, KnowledgeHubServicesPart2 {}

abstract class KnowledgeHubFirebaseServicesBase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// How many documents the last [fetchVisibleKnowledge] could not read
  /// (KH-CREATE-21 — "count skipped documents instead of hiding them").
  int lastUnreadableCount = 0;
}
