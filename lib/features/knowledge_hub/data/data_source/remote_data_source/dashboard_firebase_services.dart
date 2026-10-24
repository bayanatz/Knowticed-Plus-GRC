/// Module: knowledge_hub/data/data_source/remote_data_source
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_firebase_services.dart
/// Description: Firestore reads for the Dashboard screen.
/// Author: Amr Mesbah
/// Created at: 28/10/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

/// Reads the company's knowledge documents and usage records. A failed read
/// is thrown to the caller; a single record that cannot be parsed is skipped
/// so one bad record does not hide the whole dashboard — but it is counted
/// and logged (KH-DASH-09), and the dashboard says how many were left out.
class DashboardFirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Knowledge documents the last [fetchAllKnowledgeDocuments] could not read.
  int unreadableDocuments = 0;

  /// Usage records the last [fetchAllDocumentUtilization] could not read.
  int unreadableUsageRecords = 0;

  Future<List<CreateKnowledgeModel>> fetchAllKnowledgeDocuments() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(getBaseUrl(FirebaseCollections.createKnowledge))
        .get();
    final List<CreateKnowledgeModel> documents = [];
    unreadableDocuments = 0;
    for (final doc in snapshot.docs) {
      final CreateKnowledgeModel? model = _parseKnowledge(doc);
      if (model != null) {
        documents.add(model);
      } else {
        unreadableDocuments++;
      }
    }
    return documents;
  }

  Future<List<DocumentUtilizationModel>> fetchAllDocumentUtilization() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(
          getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization),
        )
        .get();
    final List<DocumentUtilizationModel> records = [];
    unreadableUsageRecords = 0;
    for (final doc in snapshot.docs) {
      final DocumentUtilizationModel? model = _parseUtilization(doc);
      if (model != null) {
        records.add(model);
      } else {
        unreadableUsageRecords++;
      }
    }
    return records;
  }

  CreateKnowledgeModel? _parseKnowledge(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    try {
      return CreateKnowledgeModel.fromJson(doc.data(), doc.id);
    } catch (e) {
      khLog('Dashboard: unreadable document ${doc.id}: $e');
      return null;
    }
  }

  DocumentUtilizationModel? _parseUtilization(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    try {
      return DocumentUtilizationModel.fromJson(doc.data());
    } catch (e) {
      khLog('Dashboard: unreadable usage record ${doc.id}: $e');
      return null;
    }
  }
}
