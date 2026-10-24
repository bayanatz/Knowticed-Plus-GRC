/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: services_docs_data_source.dart
/// Purpose: Plain reads and writes of single RequestServices, Services and
///          CreateServices documents. Split out of GetServiceRepositoryImpl
///          (rule H14: the repository was over 800 lines); the repository
///          delegates to it.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/approver_emails.dart';
import 'package:knowticed_plus/features/services/data/utils/history_append.dart';
import 'package:knowticed_plus/features/services/domain/entities/status_change_refused.dart';

/// Class Name: [ServicesDocsDataSource]
///
/// Purpose: Document-level Firestore access for the services collections.
class ServicesDocsDataSource {
  ServicesDocsDataSource(this.firestore);

  final FirebaseFirestore firestore;

  Future<void> setRequestServiceDoc(
    String docId,
    Map<String, dynamic> data,
  ) async {
    await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(docId)
        .set(withApproverEmails(data));
  }

  /// SVC-HOME-03: keeps the flat Approver_Emails list in step with the
  /// Approval_Cycle being written, so approvers can be found with a query.
  Map<String, dynamic> withApproverEmails(Map<String, dynamic> data) {
    if (!data.containsKey(ApproverEmails.cycleField)) return data;
    var cycle = data[ApproverEmails.cycleField];
    if (cycle is HistoryAppend) cycle = [cycle.value];
    final emails = ApproverEmails.fromCycle(cycle);
    if (emails == null) return data;
    return {...data, ApproverEmails.field: emails};
  }

  Future<Map<String, dynamic>?> getRequestServiceDocById(String docId) async {
    final doc = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(docId)
        .get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateRequestServiceDoc(
    String docId,
    Map<String, dynamic> data,
  ) async {
    // SVC-HOME-02: HistoryAppend values are appended in a transaction.
    await updateWithHistory(
      firestore,
      firestore
          .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
          .doc(docId),
      withApproverEmails(data),
    );
  }

  Future<void> updateAssignedProvider({
    required String docId,
    required String providerEmail,
    required String providerJson,
  }) async {
    await updateWithHistory(
      firestore,
      firestore
          .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
          .doc(docId),
      {
        // SVC-HOME-25: append, so earlier assignments stay in the history
        // and the lists keep lining up with the timestamps.
        ServicesHistoryKeys.kAssignedProviderEmail: HistoryAppend(
          providerEmail,
        ),
        ServicesHistoryKeys.kProviderServices: HistoryAppend(providerJson),
        ServicesHistoryKeys.kTimestamps: HistoryAppend(
          DateTime.now().millisecondsSinceEpoch,
        ),
      },
    );
  }

  /// SVC-PROV-22: only the requests whose provider history contains
  /// [providerEmail] (as typed or lower-cased), instead of every request of
  /// the company. The caller keeps those where the provider is the LAST
  /// entry (the current assignment).
  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getRequestServiceDocsForProvider(String providerEmail) async {
    final typed = providerEmail.trim();
    final emails = {typed, typed.toLowerCase()}.toList();
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where(
          ServicesHistoryKeys.kAssignedProviderEmail,
          arrayContainsAny: emails,
        )
        .get();
    return snapshot.docs.map((d) => MapEntry(d.id, d.data())).toList();
  }

  /// Function Name: [advanceRequestState]
  ///
  /// Purpose: SVC-PROV-06 — moves request [requestId] to [newState] inside a
  /// transaction. Only approved → inprogress → done is allowed (a pending
  /// request counts as approved when every approver approved); anything
  /// else throws [StatusChangeRefused] and nothing is written.
  ///
  /// Parameters:
  /// - [requestId]: the RequestServices document id.
  /// - [newState]: 'inprogress' or 'done'.
  Future<void> advanceRequestState({
    required String requestId,
    required String newState,
  }) async {
    final target = newState.toLowerCase();
    final ref = firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(requestId);
    await firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (!snap.exists || data == null) {
        throw const StatusChangeRefused('not found');
      }
      final stateField = data[ServicesHistoryKeys.kState];
      final current = (stateField is List && stateField.isNotEmpty
              ? stateField.last
              : stateField ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final from =
          current == 'pending' && _allApproved(data) ? 'approved' : current;
      final allowed = (from == 'approved' && target == 'inprogress') ||
          (from == 'inprogress' && target == 'done');
      if (!allowed) throw StatusChangeRefused('$current → $target');

      final states = stateField is List
          ? List<dynamic>.from(stateField)
          : <dynamic>[if (stateField != null) stateField];
      final tsField = data[ServicesHistoryKeys.kTimestamps];
      final timestamps =
          tsField is List ? List<dynamic>.from(tsField) : <dynamic>[];
      states.add(target);
      timestamps.add(DateTime.now().millisecondsSinceEpoch);
      tx.update(ref, {
        ServicesHistoryKeys.kState: states,
        ServicesHistoryKeys.kTimestamps: timestamps,
      });
    });
  }

  /// Every approver of the current approval cycle approved (and there is at
  /// least one).
  static bool _allApproved(Map<String, dynamic> data) {
    final cycle = data[ServicesHistoryKeys.kApprovalCycle];
    if (cycle is! List || cycle.isEmpty || cycle.last is! String) return false;
    try {
      final decoded = jsonDecode(cycle.last as String);
      if (decoded is! List || decoded.isEmpty) return false;
      return decoded.every(
        (a) =>
            a is Map &&
            (a['state'] ?? '').toString().toLowerCase() == 'approved',
      );
    } on FormatException {
      return false;
    }
  }

  /// All RequestServices docs as (id -> data) entries.
  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getAllRequestServiceDocs() async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .get();
    return snapshot.docs.map((d) => MapEntry(d.id, d.data())).toList();
  }

  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getRecentRequestServiceDocs({required int limit}) async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .orderBy('timestamps', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((d) => MapEntry(d.id, d.data())).toList();
  }

  Future<Map<String, dynamic>?> getServicesDoc(String docId) async {
    final doc = await firestore
        .collection(getBaseUrl(FirestoreCollections.servicesRoot))
        .doc(docId)
        .get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> setServicesDoc(
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    await firestore
        .collection(getBaseUrl(FirestoreCollections.servicesRoot))
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  Future<Map<String, dynamic>?> getCreateServiceDoc(String docId) async {
    final doc = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId)
        .get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> setCreateServiceDoc(
    String docId,
    Map<String, dynamic> data,
  ) async {
    await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId)
        .set(data);
  }

  Future<void> updateCreateServiceDoc(
    String docId,
    Map<String, dynamic> data,
  ) async {
    await updateWithHistory(
      firestore,
      firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(docId),
      data,
    );
  }

  Future<void> deleteCreateServiceDoc(String docId) async {
    await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId)
        .delete();
  }

  /// Function Name: [getCreateServiceDocEntries]
  ///
  /// Purpose: Every CreateServices document as (id -> data) entries, for the
  /// dashboards that group requests by service id.
  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getCreateServiceDocEntries() async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .get();
    return snapshot.docs.map((d) => MapEntry(d.id, d.data())).toList();
  }

  /// Function Name: [getAllCreateServiceDocs]
  ///
  /// Purpose: Every CreateServices document's data.
  Future<List<Map<String, dynamic>>> getAllCreateServiceDocs() async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  /// Function Name: [getUserByEmail]
  ///
  /// Purpose: The users document of [email], or `null`.
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final doc = await firestore
        .collection(FirestoreCollections.users)
        .doc(email.toLowerCase())
        .get();
    return doc.exists ? doc.data() : null;
  }
}
