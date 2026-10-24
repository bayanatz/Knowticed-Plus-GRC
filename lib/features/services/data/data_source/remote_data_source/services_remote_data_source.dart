/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: services_remote_data_source.dart
/// Purpose: Remote (Firestore) data source for the services module. Holds the
///          heavier approval/provider/statistics/request Firestore operations
///          so the repository only delegates and maps (R02).
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/helper/current_user_context.dart';
import 'package:knowticed_plus/features/services/data/models/requested_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

import 'package:knowticed_plus/features/services/data/utils/approver_emails.dart';
import 'package:knowticed_plus/features/services/domain/entities/approval_decision.dart';
import 'package:knowticed_plus/features/services/data/utils/history_append.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

class ServicesRemoteDataSource {
  final FirebaseFirestore firestore;

  ServicesRemoteDataSource(this.firestore);

  // R01: current user's email from the data-layer context (no presentation dep).
  String get _email => CurrentUserContext.email ?? '';

  Future<List<ServicesHistoryModel>> getApprovalServices(String email) async {
    final String target = email.trim().toLowerCase();
    if (target.isEmpty) return [];

    final CollectionReference<Map<String, dynamic>> requestsCollection =
        firestore.collection(
      getBaseUrl(FirestoreCollections.requestServicesRoot),
    );

    // SVC-HOME-03: query only the requests that list me as an approver,
    // using the flat Approver_Emails field written with every approval cycle.
    final indexed = await requestsCollection
        .where(ApproverEmails.field, arrayContains: target)
        .get();

    final Map<String, ServicesHistoryModel> byId = {};
    for (final doc in indexed.docs) {
      final model = _parseRequest(doc);
      if (model != null) byId[doc.id] = model;
    }

    // TEMPORARY (remove once every request has Approver_Emails): requests
    // created before 18/10/2026 do not have the field yet. Scan this
    // company's requests, back-fill the field, and include matches. Once a
    // scan finds nothing left to back-fill, this device stops scanning.
    // Errors are thrown (SVC-HOME-05) so the screen shows an error instead
    // of "no approvals".
    final prefs = await SharedPreferences.getInstance();
    final doneKey = 'approverEmailsBackfilled_${ApiConstants.baseUri}';
    if (prefs.getBool(doneKey) == true) return byId.values.toList();

    // SVC-HOME-19: EVERY old request is checked for a match (the scan used
    // to stop after 450, so later requests never appeared), and the field is
    // saved in batches of up to 450 (Firestore allows 500 writes per batch).
    final legacy = await requestsCollection.get();
    final updates = <DocumentReference<Map<String, dynamic>>, List<String>>{};
    for (final doc in legacy.docs) {
      final data = doc.data();
      if (data.containsKey(ApproverEmails.field)) continue;
      final emails =
          ApproverEmails.fromCycle(data[ApproverEmails.cycleField]) ??
              const <String>[];
      updates[doc.reference] = emails;
      if (emails.contains(target) && !byId.containsKey(doc.id)) {
        final model = _parseRequest(doc);
        if (model != null) byId[doc.id] = model;
      }
    }

    var allSaved = true;
    final entries = updates.entries.toList();
    for (var start = 0; start < entries.length; start += 450) {
      final batch = firestore.batch();
      for (final entry in entries.skip(start).take(450)) {
        batch.update(entry.key, {ApproverEmails.field: entry.value});
      }
      try {
        await batch.commit();
      } catch (e) {
        // Back-fill is best effort; the list is still correct because
        // matches were found by decoding the cycle above.
        allSaved = false;
        svcLog('Approver_Emails back-fill failed: $e');
      }
    }
    // Stop scanning on this device only once every old request has the
    // field, so a failed save is retried on the next open.
    if (allSaved) await prefs.setBool(doneKey, true);

    return byId.values.toList();
  }

  /// Parses one request; a malformed document is skipped with a log line.
  ServicesHistoryModel? _parseRequest(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    try {
      return ServicesHistoryModel.fromJson(doc.data(), doc.id);
    } catch (e) {
      svcLog('Skipping malformed request ${doc.id}: $e');
      return null;
    }
  }

  /// SVC-REQ-05 / SVC-REQ-06: the ONE approve / reject implementation.
  ///
  /// In a transaction it re-reads the request and refuses unless the request
  /// is still pending, [approverEmail] is in the current cycle with a pending
  /// entry, and every earlier approver has approved. It appends (never
  /// replaces) the new cycle, the timestamp and — on rejection or the last
  /// approval — the new state.
  Future<ApprovalDecision> decideApproval({
    required String docId,
    required String approverEmail,
    required bool approve,
    required String comment,
  }) {
    final ref = firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(docId);
    final me = approverEmail.trim().toLowerCase();

    return firestore.runTransaction<ApprovalDecision>((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (!snap.exists || data == null) {
        throw const ApprovalNotAllowed(ApprovalRefusal.notFound);
      }

      final stateHist = data['state'];
      final currentState = _lastString(stateHist).toLowerCase().trim();
      if (currentState != 'pending') {
        throw const ApprovalNotAllowed(ApprovalRefusal.notPending);
      }

      final cycleHist = data[ApproverEmails.cycleField];
      final cycle = <Map<String, dynamic>>[];
      if (cycleHist is List &&
          cycleHist.isNotEmpty &&
          cycleHist.last is String) {
        final decoded = jsonDecode(cycleHist.last as String);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) cycle.add(Map<String, dynamic>.from(item));
          }
        }
      }

      String emailAt(int i) =>
          (cycle[i]['email'] ?? '').toString().trim().toLowerCase();
      String stateAt(int i) =>
          (cycle[i]['state'] ?? 'pending').toString().trim().toLowerCase();

      final myIndex = List.generate(cycle.length, emailAt).indexOf(me);
      if (myIndex == -1 || stateAt(myIndex) != 'pending') {
        throw const ApprovalNotAllowed(ApprovalRefusal.notYourTurn);
      }
      for (var i = 0; i < myIndex; i++) {
        if (stateAt(i) != 'approved') {
          throw const ApprovalNotAllowed(ApprovalRefusal.notYourTurn);
        }
      }

      cycle[myIndex]['state'] = approve ? 'approved' : 'rejected';
      final isLast = myIndex == cycle.length - 1;
      final encodedCycle = jsonEncode(cycle);

      List<dynamic> appended(Object? history, Object? value) {
        final list = history is List
            ? List<dynamic>.from(history)
            : <dynamic>[if (history != null) history];
        return list..add(value);
      }

      final update = <String, dynamic>{
        ApproverEmails.cycleField: appended(cycleHist, encodedCycle),
        'timestamps': appended(
          data['timestamps'],
          DateTime.now().millisecondsSinceEpoch,
        ),
        ApproverEmails.field:
            ApproverEmails.fromCycle([encodedCycle]) ?? const <String>[],
        approve ? 'approveComment' : 'rejectComment': comment,
      };
      if (!approve || isLast) {
        update['state'] = appended(
          stateHist,
          approve ? 'approved' : 'rejected',
        );
      }
      tx.update(ref, update);

      return ApprovalDecision(
        isFinalApproval: approve && isLast,
        nextApproverEmail: approve && !isLast ? emailAt(myIndex + 1) : '',
        providerEmail: _assignedProviderEmail(data),
        requesterEmail: _lastString(data['Email_Requester']),
      );
    });
  }

  static String _lastString(Object? value) {
    if (value is List) {
      return value.isEmpty ? '' : (value.last?.toString() ?? '');
    }
    return value?.toString() ?? '';
  }

  /// The provider a request is assigned to: Assigned_Provider_Email, else the
  /// first provider in Provider_Services.
  static String _assignedProviderEmail(Map<String, dynamic> data) {
    final assigned = _lastString(data['Assigned_Provider_Email']).trim();
    if (assigned.isNotEmpty) return assigned.toLowerCase();
    final providers = data['Provider_Services'];
    try {
      final raw = providers is List && providers.isNotEmpty
          ? providers.last
          : providers;
      final decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
        return (decoded.first['email'] ?? '').toString().toLowerCase();
      }
      if (decoded is Map) {
        return (decoded['email'] ?? '').toString().toLowerCase();
      }
    } on FormatException {
      return '';
    }
    return '';
  }

  Future<Map<String, Map<String, dynamic>>> getServiceProviderPerDoc() async {
    final Map<String, int> providerGlobalCount = {};
    final Map<String, Map<String, dynamic>> finalProviders = {};

    final allDocs = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where("Email_Requester", arrayContains: _email)
        .get();

    final docs = allDocs.docs;

    for (var doc in docs) {
      // ✅ UPDATED: Handle list format for providerServices
      final providerData = doc.data()['Provider_Services'];
      List<dynamic>? providerList;

      if (providerData is List && providerData.isNotEmpty) {
        // Get the last entry from history
        final lastEntry = providerData.last;
        if (lastEntry is String) {
          try {
            providerList = jsonDecode(lastEntry) as List;
          } catch (e) {
            svcLog('Ignored error: $e');
          }
        }
      }

      if (providerList != null) {
        final Set<String> uniqueEmailsInDoc = {};
        for (var provider in providerList) {
          final email = provider['email'];
          if (email != null) {
            uniqueEmailsInDoc.add(email);
          }
        }
        for (var email in uniqueEmailsInDoc) {
          providerGlobalCount[email] = (providerGlobalCount[email] ?? 0) + 1;
        }
      }
    }

    for (var doc in docs) {
      final docId = doc.id;
      final providerData = doc.data()['Provider_Services'];
      List<dynamic>? providerList;

      if (providerData is List && providerData.isNotEmpty) {
        final lastEntry = providerData.last;
        if (lastEntry is String) {
          try {
            providerList = jsonDecode(lastEntry) as List;
          } catch (e) {
            svcLog('Ignored error: $e');
          }
        }
      }

      if (providerList != null && providerList.isNotEmpty) {
        Map<String, dynamic>? selectedProvider;
        int minAppearances = 999999;

        for (var provider in providerList) {
          final email = provider['email'];
          if (email != null) {
            final count = providerGlobalCount[email] ?? 0;
            if (count < minAppearances) {
              selectedProvider = provider;
              minAppearances = count;
            }
          }
        }

        if (selectedProvider != null) {
          finalProviders[docId] = selectedProvider;
        }
      }
    }

    return finalProviders;
  }

  Future<void> updateApprovalState({
    required String docID,
    required String email,
    required String newState,
  }) async {
    final String tenantRoot = getBaseUrl(
      FirestoreCollections.requestServicesRoot,
    );
    final String target = email.toLowerCase().trim();

    String? keyEq(Map<String, dynamic> m, String wantLower) {
      for (final k in m.keys) {
        if (k.toLowerCase() == wantLower) return k;
      }
      return null;
    }

    // ✅ FIXED: Query the flat collection directly
    final docPath = '$tenantRoot/$docID';

    final docRef = firestore.doc(docPath);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception('Request "$docID" not found at $docPath');
    }

    final data = docSnapshot.data() as Map<String, dynamic>;

    final cycleKey =
        keyEq(data, 'Approval_Cycle') ?? keyEq(data, 'Approval_Cycle');

    String updatePath;
    List<dynamic> approvalList;

    if (cycleKey != null) {
      final cycleNode = data[cycleKey];
      // Handle list format
      if (cycleNode is List && cycleNode.isNotEmpty) {
        final lastEntry = cycleNode.last;
        if (lastEntry is String) {
          try {
            approvalList = List<Map<String, dynamic>>.from(
              jsonDecode(lastEntry) as List,
            );
            updatePath = cycleKey;
          } catch (e) {
            throw Exception('Failed to decode approval cycle: $e');
          }
        } else {
          approvalList = List<Map<String, dynamic>>.from(cycleNode);
          updatePath = cycleKey;
        }
      } else {
        throw Exception('Unsupported shape for "$cycleKey".');
      }
    } else if (data.containsKey('Approval_Cycle.value')) {
      final v = data['Approval_Cycle.value'];
      if (v is List) {
        approvalList = List<Map<String, dynamic>>.from(v);
        updatePath = 'Approval_Cycle.value';
      } else {
        throw Exception('Unsupported shape for "Approval_Cycle.value".');
      }
    } else {
      throw Exception('No approval cycle field found.');
    }

    final idx = approvalList.indexWhere((item) {
      if (item is Map) {
        final em = (item['email'] ?? '').toString().toLowerCase().trim();
        return em == target;
      }
      return false;
    });

    if (idx == -1) {
      throw Exception('Target email "$email" not found in approval list.');
    }

    (approvalList[idx] as Map<String, dynamic>)['state'] = newState;

    // SVC-HOME-02: append in a transaction (arrayUnion skipped a cycle that
    // matched an earlier one, e.g. approve → reset → approve).
    await updateWithHistory(firestore, docRef, {
      updatePath: HistoryAppend(jsonEncode(approvalList)),
      'timestamps': HistoryAppend(DateTime.now().millisecondsSinceEpoch),
      ApproverEmails.field:
          ApproverEmails.fromCycle([jsonEncode(approvalList)]) ??
              const <String>[],
    });
  }

  Future<void> addRequestedService({
    required String docId,
    required RequestedServices requestModel,
    required String uidUser,
  }) async {
    try {
      // Verify the parent service document exists.
      final parentDocRef = firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(docId);

      final parentDoc = await parentDocRef.get();

      // ✅ FIX ("Error occurred" on Request Service): the guard here was
      //   parentDoc.data()?['Email_Requester'] != _email
      // and it rejected EVERY request, for two independent reasons.
      //
      // 1. Type mismatch. `Email_Requester` is a history ARRAY on these
      //    documents (see ServicesHistoryModel — every field is a list of
      //    revisions, and getRequestedServices below queries it with
      //    `arrayContains`). Comparing a List to a String with `!=` is always
      //    true, so the exception fired even for the document's own owner.
      //
      // 2. Wrong ownership question. `docId` is the parent SERVICE, which is
      //    authored by whoever created the service. The person requesting it
      //    is by definition someone else. Requiring the two to match meant a
      //    user could only request services they had created themselves.
      //
      // The caller on the service card ignored the returned bool, so this
      // failure was invisible there — the request silently never reached the
      // requestServices sub-collection while the UI still showed success. The
      // details page does check it, which is where "Error occurred" surfaced.
      //
      // Existence of the service is the real precondition; per-user access is
      // enforced by the Firestore rules and by the visibility filters that
      // decide which services are listed in the first place.
      if (!parentDoc.exists) {
        throw Exception("Service not found: $docId");
      }

      // Add the requested service
      await parentDocRef.collection(FirestoreCollections.requestServices).add({
        "uidUser": uidUser,
        "Email_Requester": _email,
        ...requestModel.toJson(),
      });
    } catch (e) {
      throw Exception("Failed to add requested service: $e");
    }
  }

  Future<List<RequestedServices>> getRequestedServices({
    required String docId,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(docId)
          .collection(FirestoreCollections.requestServices)
          .where("Email_Requester", arrayContains: _email)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RequestedServices.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch requested services: $e");
    }
  }

  /// SVC-HOME-20: done requests per service. Only requests that have ever
  /// been "done" are read (state history arrayContains "done"), and a request
  /// counts when its CURRENT (last) status is done — the old code read the
  /// first status and downloaded every request of the company.
  Future<Map<String, int>> getDoneServicesCountByParent() async {
    final Map<String, int> doneCounts = {};
    final doneRequests = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where('state', arrayContains: 'done')
        .get();

    for (final doc in doneRequests.docs) {
      final data = doc.data();

      final parentId = _lastString(data['Parent_Service_Id']).trim();
      if (parentId.isEmpty) continue;

      final stateValue = _lastString(data['state']).toLowerCase().trim();
      if (stateValue == 'done') {
        doneCounts[parentId] = (doneCounts[parentId] ?? 0) + 1;
      }
    }
    return doneCounts;
  }

  Future<void> editService(
    String docId,
    ServicesHistoryModel updatedModel,
  ) async {
    final docRef = firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId);

    // ✅ Fetch existing document first
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception("Service not found: $docId");
    }

    // ✅ Parse existing model
    final existingModel = ServicesHistoryModel.fromJson(
      docSnapshot.data()!,
      docId,
    );

    // ✅ FIX (status switch): `status` was never forwarded here, so the
    // Active/Inactive toggle set on the create/edit screen was silently
    // dropped on save and the service stayed under the Active filter.
    // copyWith APPENDS a revision, so only pass it when it actually changed.
    final incomingStatus = updatedModel.currentStatus.trim();
    final statusChanged = incomingStatus.isNotEmpty &&
        incomingStatus.toLowerCase() !=
            existingModel.currentStatus.trim().toLowerCase();

    // ✅ FIX 30/8/2026 (same bug as `updateService` below): `imageUrl` was not
    // in this copyWith, so editing a service to ADD or CHANGE its picture
    // re-wrote whatever image the document already had — usually none. The
    // upload succeeded, the form showed it, and the save silently discarded
    // it. Like `status`, only pass it on a real change: copyWith APPENDS a
    // revision, so passing it every save would grow the history array forever.
    final incomingImageUrl = updatedModel.currentImageUrl.trim();
    final imageChanged =
        incomingImageUrl != existingModel.currentImageUrl.trim();

    // ✅ Create updated model using copyWith to preserve history
    final newModel = existingModel.copyWith(
      status: statusChanged ? incomingStatus : null,
      imageUrl: imageChanged ? incomingImageUrl : null,
      serviceNameEnglish: updatedModel.currentServiceNameEnglish,
      serviceNameArabic: updatedModel.currentServiceNameArabic,
      serviceDescriptionEnglish: updatedModel.currentServiceDescriptionEnglish,
      serviceDescriptionArabic: updatedModel.currentServiceDescriptionArabic,
      durationOfServices: updatedModel.currentDurationOfServices,
      selectedDurationUnit: updatedModel.currentSelectedDurationUnit,
      providerServices: updatedModel.currentProviderServices,
      approvalCycle: updatedModel.currentApprovalCycle,
      selectDepartment: updatedModel.currentSelectDepartment,
      limitAvailability: updatedModel.currentLimitAvailability,
      requireApproval: updatedModel.currentRequireApproval,
      slaOneControllerEnglish: updatedModel.currentSlaOneControllerEnglish,
      slaTwoControllerEnglish: updatedModel.currentSlaTwoControllerEnglish,
      notifyRequesterChecked: updatedModel.currentNotifyRequesterChecked,
      notifyProviderChecked: updatedModel.currentNotifyProviderChecked,
      notifyManagerChecked: updatedModel.currentNotifyManagerChecked,
      // Add other fields as needed
    );

    // ✅ Save with full data (not just create data)
    await docRef.set(
      newModel.toJson(), // ✅ Use full toJson() to preserve all fields
      SetOptions(merge: false), // ✅ Replace entire document
    );

    if (imageChanged) {
      await _deleteReplacedImage(existingModel.currentImageUrl);
    }
  }

  /// SVC-CREATE-05: the old picture is deleted only AFTER the edit that
  /// replaced or removed it has been saved. Best effort: a failed delete
  /// leaves an unused file, never a broken service.
  Future<void> _deleteReplacedImage(String oldUrl) async {
    final url = oldUrl.trim();
    if (url.isEmpty) return;
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (e) {
      svcLog('Could not delete replaced service image: $e');
    }
  }

  // ==========================================
  // ✅ COMPLETE FIXED updateService METHOD
  // ==========================================
  // Replace your ENTIRE updateService method with this code

  // ==========================================
  // ✅ COMPLETE FIXED updateService METHOD
  // ==========================================
  // Replace your ENTIRE updateService method with this code

  Future<void> updateService(String docId, ServicesHistoryModel model) async {
    // ✅ STEP 1: Fetch existing document from CreateServices
    final createServicesRef = firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId);

    final docSnapshot = await createServicesRef.get();

    if (!docSnapshot.exists) {
      throw Exception("Service document not found: $docId");
    }

    // ✅ STEP 2: Parse existing model to preserve ALL fields
    final existingModel = ServicesHistoryModel.fromJson(
      docSnapshot.data()!,
      docId,
    );

    // ✅ FIX (status switch): same bug as editService — `status` was not part
    // of this copyWith, so editing a service and flipping the Active/Inactive
    // switch re-wrote the OLD status read back from Firestore. The service
    // therefore never moved into the "Inactive" filter on the home page.
    // copyWith APPENDS to the status history, so only pass it on a real change.
    final incomingStatus = model.currentStatus.trim();
    final statusChanged = incomingStatus.isNotEmpty &&
        incomingStatus.toLowerCase() !=
            existingModel.currentStatus.trim().toLowerCase();

    // ✅ FIX 30/8/2026: `imageUrl` was missing from this copyWith too, so the
    // edit path re-wrote the document's OLD image and threw away the one the
    // user had just uploaded. Only passed on a real change — copyWith appends
    // a revision, so an unchanged URL would be re-appended on every save.
    final incomingImageUrl = model.currentImageUrl.trim();
    final imageChanged =
        incomingImageUrl != existingModel.currentImageUrl.trim();

    // ✅ STEP 3: Create updated model using copyWith (preserves history)
    final newModel = existingModel.copyWith(
      status: statusChanged ? incomingStatus : null,
      imageUrl: imageChanged ? incomingImageUrl : null,
      serviceNameEnglish: model.currentServiceNameEnglish,
      serviceNameArabic: model.currentServiceNameArabic,
      serviceDescriptionEnglish: model.currentServiceDescriptionEnglish,
      serviceDescriptionArabic: model.currentServiceDescriptionArabic,
      durationOfServices: model.currentDurationOfServices,
      selectedDurationUnit: model.currentSelectedDurationUnit,
      providerServices: model.currentProviderServices,
      approvalCycle: model.currentApprovalCycle,
      selectDepartment: model.currentSelectDepartment,
      limitAvailability: model.currentLimitAvailability,
      requireApproval: model.currentRequireApproval,
      slaOneControllerEnglish: model.currentSlaOneControllerEnglish,
      slaTwoControllerEnglish: model.currentSlaTwoControllerEnglish,
      // slaOneControllerArabic: model.currentSlaOneControllerArabic,
      // slaTwoControllerArabic: model.currentSlaTwoControllerArabic,
      notifyRequesterChecked: model.currentNotifyRequesterChecked,
      notifyProviderChecked: model.currentNotifyProviderChecked,
      notifyManagerChecked: model.currentNotifyManagerChecked,
      notifyRequesterSwitch0: model.currentNotifyRequesterSwitch0,
      notifyManagerSwitch1: model.currentNotifyManagerSwitch1,
    );

    // ✅ STEP 4: Convert to JSON using FULL toJson() (NOT toJsonForCreate!)
    final jsonData = newModel.toJson();

    // ✅ STEP 5: Update CreateServices
    await createServicesRef.set(
      jsonData,
      SetOptions(merge: false), // Complete replacement
    );

    if (imageChanged) {
      await _deleteReplacedImage(existingModel.currentImageUrl);
    }

    // ✅ STEP 6: Update myCreateRequests (allServices)
    final allServicesRef = firestore
        .collection(
          getBaseUrl(FirestoreCollections.createServicesRoot),
        ) // This is "myCreateRequests"
        .doc(docId);

    try {
      await allServicesRef.set(
        jsonData,
        SetOptions(merge: true), // Merge in case doc doesn't exist
      );
    } catch (e) {
      svcLog('Ignored error: $e');
    }
  }
}
