/// Module: knowledge_hub_module / helpers/debug/knowledge_hub_view_tests.dart
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_view_tests.dart
/// Description: DEBUG ONLY — sends the signed-in user one Knowledge Hub
///          notification per View landing, each about a REAL document, so
///          "View opens the record" can be checked on a device.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Reads `Create_Knowledge`; writes nothing but notification documents. Goes
/// through `AppNotificationSender.sendEvent`, exactly as
/// `KnowledgeHubNotificationService` does (same template, `name_of_page` and
/// `Request_Id` = knowledgeId), but skips its methods, which also write
/// System Logs.
///
///   Review Request Received  → ApprovalsDetails   (a pending document)
///   Document Submitted       → SubmissionDetails  (the user's own, if any)
///   Document Published       → ViewKnowledgeDetails (a published document)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/notification/domain/enums/knowledge_hub/knowledge_hub_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/knowledge_hub/knowledge_hub_notification_pages.dart';
import 'package:knowticed_plus/features/notification/helpers/services/app_notification_sender.dart';

/// Sends up to three test notifications to [receiverEmail]; returns how many
/// went out. Never throws.
Future<int> sendKnowledgeHubViewTests({
  required String receiverEmail,
  required bool isArabic,
}) async {
  if (!kDebugMode) return 0;
  final String me = receiverEmail.trim();
  if (me.isEmpty) return 0;
  try {
    final QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
        .instance
        .collection(getBaseUrl(FirebaseCollections.createKnowledge))
        .limit(300)
        .get();
    final List<CreateKnowledgeModel> docs = <CreateKnowledgeModel>[
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs)
        if (_parse(d) case final CreateKnowledgeModel m
            when m.currentKnowledgeId.isNotEmpty)
          m,
    ];

    bool isMine(CreateKnowledgeModel d) =>
        d.currentCreatedByEmail.trim().toLowerCase() == me.toLowerCase();
    String status(CreateKnowledgeModel d) =>
        d.currentStatus.trim().toLowerCase();

    final List<CreateKnowledgeModel> pending = docs
        .where((d) => status(d) == 'pending_approval' || status(d) == 'pending')
        .toList()
      // Someone else's first: Approve / Reject only work on your team's queue.
      ..sort((a, b) => (isMine(a) ? 1 : 0).compareTo(isMine(b) ? 1 : 0));
    final List<CreateKnowledgeModel> mine = docs.where(isMine).toList();
    final List<CreateKnowledgeModel> published =
        docs.where((d) => status(d) == 'published').toList();

    int sent = 0;
    sent += await _sendOne(
      kind: 'approval',
      document: pending.firstOrNull,
      event: KnowledgeHubNotificationEvent.reviewRequestReceived,
      page: KnowledgeHubNotificationPage.approvalsDetails,
      receiverEmail: me,
      isArabic: isArabic,
    );
    if (mine.isEmpty) {
      debugPrint('[kh-view-test] submission: $me has no documents of their '
          'own — using someone else\'s');
    }
    sent += await _sendOne(
      kind: 'submission',
      document: mine.firstOrNull ?? docs.firstOrNull,
      event: KnowledgeHubNotificationEvent.documentSubmitted,
      page: KnowledgeHubNotificationPage.submissionDetails,
      receiverEmail: me,
      isArabic: isArabic,
    );
    sent += await _sendOne(
      kind: 'published',
      document: published.firstOrNull,
      event: KnowledgeHubNotificationEvent.documentPublished,
      page: KnowledgeHubNotificationPage.viewKnowledgeDetails,
      receiverEmail: me,
      isArabic: isArabic,
    );
    return sent;
  } catch (e) {
    debugPrint('[kh-view-test] failed: $e');
    return 0;
  }
}

CreateKnowledgeModel? _parse(QueryDocumentSnapshot<Map<String, dynamic>> d) {
  try {
    return CreateKnowledgeModel.fromJson(d.data(), d.id);
  } catch (_) {
    return null;
  }
}

Future<int> _sendOne({
  required String kind,
  required CreateKnowledgeModel? document,
  required KnowledgeHubNotificationEvent event,
  required KnowledgeHubNotificationPage page,
  required String receiverEmail,
  required bool isArabic,
}) async {
  if (document == null) {
    debugPrint('[kh-view-test] $kind: skipped — no suitable document');
    return 0;
  }
  final String nameEn = document.currentNameEnglish;
  final String nameAr =
      document.currentNameArabic.isEmpty ? nameEn : document.currentNameArabic;
  try {
    final bool ok = await AppNotificationSender.sendEvent(
      event: event,
      pageKey: page.key,
      senderEmail: receiverEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      variables: <TemplateVariable, String>{
        for (final TemplateVariable v in event.variables) v: 'Test',
        TemplateVariable.documentName: nameEn,
      },
      variablesAr: <TemplateVariable, String>{
        TemplateVariable.documentName: nameAr,
      },
      requestId: document.currentKnowledgeId,
    );
    debugPrint('[kh-view-test] $kind → ${page.key} '
        '(${document.currentKnowledgeId}): ${ok ? 'sent' : 'NOT sent'}');
    return ok ? 1 : 0;
  } catch (e) {
    debugPrint('[kh-view-test] $kind failed: $e');
    return 0;
  }
}
