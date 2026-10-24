/// Module: services / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: service_repository_impl.dart
/// Purpose: Concrete repository implementation for the services module.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'dart:convert';

// cloud_firestore 6 exports its own Constant (pipeline API); ours is the user context.
import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/current_user_context.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/parent_service_details_fetcher.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/request_provider_resolver.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/data_source/local_data_source/services_local_data_source.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_docs_data_source.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_remote_data_source.dart';
import 'package:knowticed_plus/features/services/data/utils/history_append.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/domain/entities/approval_decision.dart';
import 'package:knowticed_plus/features/services/domain/entities/parent_service_details.dart';
import 'package:knowticed_plus/features/services/data/models/sla_data_model.dart';
import 'package:knowticed_plus/features/services/data/models/requested_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/service_visibility.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

class GetServiceRepositoryImpl implements CreateServicesRepository {
  final FirebaseFirestore firestore;

  /// H2: the data sources and helpers can be passed in (tests, other
  /// back-ends); by default they are built on [firestore].
  GetServiceRepositoryImpl({
    required this.firestore,
    ParentServiceDetailsFetcher? parentDetailsFetcher,
    RequestProviderResolver? providerResolver,
    ServicesLocalDataSource? local,
    ServicesRemoteDataSource? remote,
    ServicesDocsDataSource? docs,
  })  : _docs = docs ?? ServicesDocsDataSource(firestore),
        _parentDetailsFetcher =
            parentDetailsFetcher ?? ParentServiceDetailsFetcher(firestore),
        _providerResolver =
            providerResolver ?? RequestProviderResolver(firestore),
        _local = local ?? ServicesLocalDataSource(),
        _remote = remote ?? ServicesRemoteDataSource(firestore);

  // R01: read the current user's email from the data-layer context instead of
  // importing a presentation controller.
  // Falls back to Constant.emailUser: CurrentUserContext is populated when the
  // employee loads, and a repository call can fire before that lands.
  String get _currentEmail {
    final ctx = CurrentUserContext.email;
    if (ctx != null && ctx.isNotEmpty) return ctx;
    return Constant.emailUser ?? '';
  }

  // R01/R02: parent-service lookup extracted into a data-layer helper.
  final ParentServiceDetailsFetcher _parentDetailsFetcher;

  final RequestProviderResolver _providerResolver;

  // R02: SharedPreferences/draft/SLA persistence lives in the local data source.
  final ServicesLocalDataSource _local;

  // R02: heavier Firestore operations live in the remote data source.
  final ServicesRemoteDataSource _remote;

  // H14: single-document reads and writes.
  final ServicesDocsDataSource _docs;

  @override
  Future<List<ServicesHistoryModel>> getAllServices() async {
    List<ServicesHistoryModel> servicesList = [];

    try {
      // R01: the current email comes from the data-layer context. No fixed
      // wait: callers load the services after the employee is known.
      final userEmail = _currentEmail;
      if (userEmail.isEmpty) {
        return servicesList;
      }

      final querySnapshot = await firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          // B4 FIX: was `.where('Email_Requester', isEqualTo: "Email_Requester")`
          // — compared the field to the literal column name (never matched) and
          // used isEqualTo against a field written as an array. Email_Requester
          // is stored as an array, so match the current user's email with
          // arrayContains (consistent with every other query in this file).
          .where('Email_Requester', arrayContains: userEmail)
          .get();

      // SVC-HOME-10: no longer writes the requester profile to
      // SharedPreferences for every service read. Those keys were filled from
      // whichever service loaded last, so new requests could be stamped with
      // another person's name / e-mail / department.
      for (var doc in querySnapshot.docs) {
        servicesList.add(ServicesHistoryModel.fromJson(doc.data(), doc.id));
      }
    } catch (e, stack) {
      // Never swallow silently (§11): surface the failure so the cubit can emit
      // an error state instead of an empty "loaded" list.
      if (kDebugMode) svcLog('getAllServices failed: $e\n$stack');
      rethrow;
    }

    return servicesList;
  }

  @override
  Future<List<ServicesHistoryModel>> getAllRequestServices() async {
    final List<ServicesHistoryModel> servicesList = [];

    try {
      final String tenantRoot = getBaseUrl(
        FirestoreCollections.createServicesRoot,
      );

      // The full list is for people who manage services and the dashboards.
      // Everyone else goes through getVisibleRequestServices (SVC-HOME-01).
      final querySnapshot = await firestore.collection(tenantRoot).get();

      final missingVisibility =
          <DocumentReference<Map<String, dynamic>>, List<String>>{};
      for (var doc in querySnapshot.docs) {
        try {
          final model = ServicesHistoryModel.fromJson(doc.data(), doc.id);
          servicesList.add(model);
          if (!doc.data().containsKey(ServiceVisibility.field)) {
            missingVisibility[doc.reference] = model.visibleTo;
          }
        } catch (e) {
          // Tolerate a single malformed document, but do not fail silently.
          svcLog('Skipping malformed service doc ${doc.id}: $e');
        }
      }

      await _backfillVisibility(missingVisibility);
    } catch (e, stack) {
      if (kDebugMode) svcLog('getAllRequestServices failed: $e\n$stack');
      rethrow;
    }

    return servicesList;
  }

  /// SVC-HOME-01 (TEMPORARY — remove once every service has Visible_To):
  /// services saved before 22/10/2026 have no Visible_To field. A full list
  /// load (people who manage services, dashboards) writes it in batches of
  /// 450 and, once nothing is missing, sets a company marker. Until the
  /// marker exists, getVisibleRequestServices falls back to the full list so
  /// old services never disappear. Best effort: a failed write is logged.
  Future<void> _backfillVisibility(
    Map<DocumentReference<Map<String, dynamic>>, List<String>> missing,
  ) async {
    if (missing.isEmpty && _visibilityMarked) return;
    final markerRef = firestore.doc(getBaseUrl(_visibilityMarkerPath));
    try {
      final entries = missing.entries.toList();
      for (var start = 0; start < entries.length; start += 450) {
        final batch = firestore.batch();
        for (final entry in entries.skip(start).take(450)) {
          batch.update(entry.key, {ServiceVisibility.field: entry.value});
        }
        await batch.commit();
      }
      await markerRef.set({_visibilityMarkerField: true});
      _visibilityMarked = true;
    } catch (e) {
      svcLog('Visible_To back-fill failed: $e');
    }
  }

  static const String _visibilityMarkerPath =
      'Modules/services/Services_Meta/visibility';
  static const String _visibilityMarkerField = 'backfilled';
  static bool _visibilityMarked = false;

  @override
  Future<List<ServicesHistoryModel>> getVisibleRequestServices(
    List<String> departmentKeys,
  ) async {
    final marker = await firestore.doc(getBaseUrl(_visibilityMarkerPath)).get();
    if (marker.data()?[_visibilityMarkerField] != true) {
      // Old services are not marked yet; the list filter still applies.
      return getAllRequestServices();
    }

    final collection = firestore.collection(
      getBaseUrl(FirestoreCollections.createServicesRoot),
    );
    final keys = {
      ServiceVisibility.everyone,
      ...departmentKeys,
    }.take(ServiceVisibility.maxQueryKeys).toList();

    final results = await Future.wait([
      collection.where(ServiceVisibility.field, arrayContainsAny: keys).get(),
      if (_currentEmail.isNotEmpty)
        collection
            .where(
              ServicesHistoryKeys.kEmailRequester,
              arrayContains: _currentEmail,
            )
            .get(),
    ]);

    final byId = <String, ServicesHistoryModel>{};
    for (final snapshot in results) {
      for (final doc in snapshot.docs) {
        try {
          byId[doc.id] = ServicesHistoryModel.fromJson(doc.data(), doc.id);
        } catch (e) {
          svcLog('Skipping malformed service doc ${doc.id}: $e');
        }
      }
    }
    return byId.values.toList();
  }

  @override
  Future<void> deleteService(String innerDocId) async {
    // EDIT 25/9/2026: SOFT delete. The document stays so every request made
    // before the delete still shows the service name, duration and image
    // (Approvals, My Requests, dashboards). The service lists filter it out
    // via ServicesHistoryModel.isDeleted.
    await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(innerDocId)
        .update({
      ServicesHistoryKeys.kIsDeleted: true,
      ServicesHistoryKeys.kDeletedAt: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<ServicesHistoryModel?> getServiceById(
    String departmentId,
    String serviceId,
  ) async {
    try {
      final doc = await firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(serviceId)
          .get();

      //Document_Utilization
      if (doc.exists) {
        return ServicesHistoryModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e, stack) {
      // SVC-HOME-05: a failed read is not "service not found".
      if (kDebugMode) svcLog('getServiceById failed: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<List<ServicesHistoryModel>> getMyRequestServices() async {
    List<ServicesHistoryModel> servicesList = [];

    try {
      // §11.5: never log user email in release builds.
      if (kDebugMode) {
        svcLog(
          '🔎 getMyRequestServices → email="$_currentEmail" '
          '(CurrentUserContext="${CurrentUserContext.email}", '
          'Constant.emailUser="${Constant.emailUser}") '
          'path=${getBaseUrl(FirestoreCollections.requestServicesRoot)}',
        );
      }

      final querySnapshot = await firestore
          .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
          .where("Email_Requester", arrayContains: _currentEmail)
          .get();

      if (kDebugMode) {
        svcLog('🔎 getMyRequestServices → ${querySnapshot.docs.length} docs');
      }

      // ✅ Process each document and enrich with service names
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        // B6 FIX: guard the per-doc parse so one legacy/cross-platform doc with
        // a mixed int/Timestamp field can't throw and drop the whole screen.
        ServicesHistoryModel service;
        try {
          service = ServicesHistoryModel.fromJson(data, doc.id);
        } catch (e) {
          if (kDebugMode) {
            svcLog('Skipping malformed request doc ${doc.id}: $e');
          }
          continue;
        }

        // ✅ If service names are empty, fetch from parent CreateServices
        if ((service.currentServiceNameEnglish.isEmpty ||
                service.currentServiceNameArabic.isEmpty) &&
            service.currentParentServiceId.isNotEmpty) {
          try {
            final serviceDetails = await _parentDetailsFetcher.fetch(
              service.currentParentServiceId,
            );

            // ✅ Update the service with fetched names using copyWith
            //
            // ✅ FIX: bumpTimestamp: false. This is a read-time display repair,
            // not an edit of the request. copyWith used to append DateTime.now()
            // to `timestamps` unconditionally, and because
            // ServicesHistoryModel.createMinimalRequest never sets a service
            // name, EVERY request took this branch on EVERY load of this list —
            // inside one loop, so every doc's `timestamps.last` became the same
            // millisecond. my_request.dart renders that as "Last Update", which
            // is why creating one request appeared to re-date all the others.
            service = service.copyWith(
              serviceNameEnglish: serviceDetails.nameEnglish,
              serviceNameArabic: serviceDetails.nameArabic,
              serviceDescriptionEnglish: serviceDetails.descriptionEnglish,
              serviceDescriptionArabic: serviceDetails.descriptionArabic,
              durationOfServices: serviceDetails.duration,
              selectedDurationUnit: serviceDetails.unit,
              bumpTimestamp: false,
            );
          } catch (e) {
            // Keep the request with an empty service name (the card shows
            // "service removed"), but do not hide the failure.
            if (kDebugMode) {
              svcLog('Parent service fetch failed for ${doc.id}: $e');
            }
          }
        }

        servicesList.add(service);
      }
    } catch (e, s) {
      // B8 FIX: was swallowed + returned [] (MyRequestError could never fire,
      // so failures looked like an empty list and users re-submitted → dupes).
      // Surface the failure so MyRequestCubit can emit its error state.
      if (kDebugMode) {
        svcLog('❌ getMyRequestServices FAILED: $e');
        svcLog('stack', stackTrace: s);
      }
      rethrow;
    }

    return servicesList;
  }

  @override
  Future<void> deleteMyRequest(String departmentId, String innerDocId) async {
    // SVC-HOME-13: read the one document by id and fail if it is missing,
    // instead of downloading all my requests and reporting "deleted" when
    // nothing matched.
    final ref = firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(innerDocId);
    final snap = await ref.get();
    if (!snap.exists) {
      throw StateError('Request not found: $innerDocId');
    }
    await ref.delete();
  }

  @override
  Future<List<ServicesHistoryModel>> getApprovalServices(String email) =>
      _remote.getApprovalServices(email);

  @override
  Future<Map<String, Map<String, dynamic>>> getServiceProviderPerDoc() =>
      _remote.getServiceProviderPerDoc();

  @override
  Future<void> updateApprovalState({
    required String docID,
    required String email,
    required String newState,
  }) =>
      _remote.updateApprovalState(
        docID: docID,
        email: email,
        newState: newState,
      );

  @override
  Future<void> addRequestedService({
    required String docId,
    required RequestedServices requestModel,
    required String uidUser,
  }) =>
      _remote.addRequestedService(
        docId: docId,
        requestModel: requestModel,
        uidUser: uidUser,
      );

  @override
  Future<List<RequestedServices>> getRequestedServices({
    required String docId,
  }) =>
      _remote.getRequestedServices(docId: docId);

  @override
  Future<List<ServicesHistoryModel>> getFirebaseServices() async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .where("Email_Requester", arrayContains: _currentEmail)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ServicesHistoryModel.fromJson(data, doc.id);
    }).toList();
  }

  @override
  Future<List<ServicesHistoryModel>> getLocalDrafts() =>
      _local.getLocalDrafts();

  @override
  Future<Map<String, Map<String, dynamic>>> getSelectedProviders(
    List<ServicesHistoryModel> services,
  ) async {
    Map<String, Map<String, dynamic>> result = {};
    for (var service in services) {
      // ✅ UPDATED: Use current getter
      final serviceId = service.currentId;
      if (serviceId.isNotEmpty) {
        final provider = await selectServiceProvider(serviceId);
        if (provider != null) {
          result[serviceId] = provider;
        }
      }
    }
    return result;
  }

  @override
  Future<bool> checkDuplicateServiceName(String name) async {
    // SVC-CREATE-07: every service of the company, not only my own.
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .get();

    return snapshot.docs.any((doc) {
      final data = doc.data();
      if (data[ServicesHistoryKeys.kIsDeleted] == true) return false;
      // ✅ UPDATED: Handle list format
      final nameData = data['Service_Name_English'];
      if (nameData is List && nameData.isNotEmpty) {
        return nameData.last.toString().toLowerCase() == name.toLowerCase();
      } else if (nameData is String) {
        return nameData.toLowerCase() == name.toLowerCase();
      }
      return false;
    });
  }

  @override
  Future<void> saveServiceToPrefs(ServicesHistoryModel model) =>
      _local.saveServiceToPrefs(model);

  @override
  Future<void> loadServiceToFormControllers(ServicesHistoryModel model) =>
      _local.loadServiceToFormControllers(model);

  @override
  Future<void> updateServiceStatus(String docId, bool isActive) async {
    // SVC-HOME-13: one document by id (throws if missing).
    // SVC-HOME-02: append inside a transaction so switching back to an
    // earlier value (active → inactive → active) is saved.
    final ref = firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId);
    await updateWithHistory(firestore, ref, {
      "status": HistoryAppend(isActive ? "active" : "inactive"),
      "timestamps": HistoryAppend(DateTime.now().millisecondsSinceEpoch),
    });
  }

  @override
  Future<String?> getServiceStatus(String docId) async {
    // SVC-HOME-13: read the one document by id; throw if it is missing so a
    // read failure is distinguishable from "no status found".
    final doc = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId)
        .get();
    if (!doc.exists) {
      throw StateError('Service not found: $docId');
    }
    final statusData = doc.data()?["status"];
    if (statusData is List && statusData.isNotEmpty) {
      return statusData.last as String?;
    } else if (statusData is String) {
      return statusData;
    }
    return null;
  }

  Future<void> saveToSharedPrefs({
    required String slaOne,
    required String slaTwo,
    required bool notifyRequesterChecked,
    required bool notifyProviderChecked,
    required bool notifyManagerChecked,
    required bool notifyRequesterSwitch0,
    required bool notifyManagerSwitch1,
    required Map<String, Map<int, bool>> notificationSwitches,
    required List<String> extraSlaValues,
    required List<String> extraSlaTwoValues,
  }) =>
      _local.saveToSharedPrefs(
        slaOne: slaOne,
        slaTwo: slaTwo,
        notifyRequesterChecked: notifyRequesterChecked,
        notifyProviderChecked: notifyProviderChecked,
        notifyManagerChecked: notifyManagerChecked,
        notifyRequesterSwitch0: notifyRequesterSwitch0,
        notifyManagerSwitch1: notifyManagerSwitch1,
        notificationSwitches: notificationSwitches,
        extraSlaValues: extraSlaValues,
        extraSlaTwoValues: extraSlaTwoValues,
      );

  @override
  Future<SlaDataModel> loadFromSharedPrefs() => _local.loadFromSharedPrefs();

  @override
  Future<void> saveDraft(ServicesHistoryModel model) => _local.saveDraft(model);

  @override
  Future<void> updateDraft(
    ServicesHistoryModel oldModel,
    ServicesHistoryModel newModel,
  ) =>
      _local.updateDraft(oldModel, newModel);

  @override
  Future<void> removeDraftById(String id) => _local.removeDraftById(id);

  @override
  Future<void> saveService(String docId, ServicesHistoryModel model) async {
    final docRef = firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId);

    // ✅ Use set with merge to create or update
    await docRef.set(
      model.toJsonForCreate(),
      SetOptions(merge: true), // ✅ This will merge with existing data
    );
  }

  @override
  Future<void> createService(String docId, ServicesHistoryModel model) async {
    final docRef = firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId);
    // SVC-CREATE-03 / SVC-PROV-03: a write that fails if the document is
    // already there (saveService merges, which silently overwrote).
    await firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (snap.exists) {
        throw StateError('Service id already exists: $docId');
      }
      tx.set(docRef, model.toJsonForCreate());
    });
  }

  @override
  Future<void> createRequest({
    required String parentServiceId,
    required String requestDocId,
    required Map<String, dynamic> requestData,
    required Map<String, dynamic> serviceRecord,
  }) async {
    final parentRef = firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(parentServiceId);
    final parent = await parentRef.get();
    if (!parent.exists) {
      throw StateError('Service not found: $parentServiceId');
    }
    // SVC-REQ-09: both writes succeed or neither does.
    final batch = firestore.batch();
    batch.set(
      parentRef.collection(FirestoreCollections.requestServices).doc(),
      serviceRecord,
    );
    batch.set(
      firestore
          .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
          .doc(requestDocId),
      _docs.withApproverEmails(requestData),
    );
    await batch.commit();
  }

  @override
  Future<void> setRequestServiceDoc(String docId, Map<String, dynamic> data) =>
      _docs.setRequestServiceDoc(docId, data);

  @override
  Future<Map<String, dynamic>?> getRequestServiceDocById(String docId) =>
      _docs.getRequestServiceDocById(docId);

  @override
  Future<void> updateRequestServiceDoc(
    String docId,
    Map<String, dynamic> data,
  ) =>
      _docs.updateRequestServiceDoc(docId, data);

  @override
  Future<void> updateAssignedProvider({
    required String docId,
    required String providerEmail,
    required String providerJson,
  }) =>
      _docs.updateAssignedProvider(
        docId: docId,
        providerEmail: providerEmail,
        providerJson: providerJson,
      );

  @override
  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getAllRequestServiceDocs() => _docs.getAllRequestServiceDocs();

  @override
  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getRequestServiceDocsForProvider(String providerEmail) =>
          _docs.getRequestServiceDocsForProvider(providerEmail);

  @override
  Future<void> advanceRequestState({
    required String requestId,
    required String newState,
  }) =>
      _docs.advanceRequestState(requestId: requestId, newState: newState);

  @override
  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getRecentRequestServiceDocs({required int limit}) =>
          _docs.getRecentRequestServiceDocs(limit: limit);

  @override
  Future<Map<String, dynamic>?> getServicesDoc(String docId) =>
      _docs.getServicesDoc(docId);

  @override
  Future<void> setServicesDoc(
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) =>
      _docs.setServicesDoc(docId, data, merge: merge);

  @override
  Future<Map<String, dynamic>?> getCreateServiceDoc(String docId) =>
      _docs.getCreateServiceDoc(docId);

  @override
  Future<void> setCreateServiceDoc(String docId, Map<String, dynamic> data) =>
      _docs.setCreateServiceDoc(docId, data);

  @override
  Future<void> updateCreateServiceDoc(
    String docId,
    Map<String, dynamic> data,
  ) =>
      _docs.updateCreateServiceDoc(docId, data);

  @override
  Future<void> deleteCreateServiceDoc(String docId) =>
      _docs.deleteCreateServiceDoc(docId);

  @override
  Future<ApprovalDecision> decideApproval({
    required String docId,
    required String approverEmail,
    required bool approve,
    required String comment,
  }) =>
      _remote.decideApproval(
        docId: docId,
        approverEmail: approverEmail,
        approve: approve,
        comment: comment,
      );

  @override
  String newRequestServiceId() => firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
      .doc()
      .id;

  @override
  String newCreateServiceId() => firestore
      .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
      .doc()
      .id;

  @override
  Future<List<ServicesHistoryModel>> getServicesByRequesterEmail(
    String email,
  ) async {
    final querySnapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .where("Email_Requester", arrayContains: email)
        .get();
    return querySnapshot.docs
        .map((doc) => ServicesHistoryModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Map<String, int>> getDoneServicesCountByParent() =>
      _remote.getDoneServicesCountByParent();

  @override
  Future<void> editService(String docId, ServicesHistoryModel updatedModel) =>
      _remote.editService(docId, updatedModel);

  @override
  Future<void> updateService(String docId, ServicesHistoryModel model) =>
      _remote.updateService(docId, model);
  @override
  Future<void> saveSlaToPrefs({
    required String slaOne,
    required String slaTwo,
    required bool notifyRequesterChecked,
    required bool notifyProviderChecked,
    required bool notifyManagerChecked,
    required bool notifyRequesterSwitch0,
    required bool notifyManagerSwitch1,
    required List<String> extraSlaList,
    required List<String> extraSlaTwoList,
    required Map<String, Map<int, bool>> notificationSwitches,
  }) =>
      _local.saveSlaToPrefs(
        slaOne: slaOne,
        slaTwo: slaTwo,
        notifyRequesterChecked: notifyRequesterChecked,
        notifyProviderChecked: notifyProviderChecked,
        notifyManagerChecked: notifyManagerChecked,
        notifyRequesterSwitch0: notifyRequesterSwitch0,
        notifyManagerSwitch1: notifyManagerSwitch1,
        extraSlaList: extraSlaList,
        extraSlaTwoList: extraSlaTwoList,
        notificationSwitches: notificationSwitches,
      );

  @override
  Future<Map<String, dynamic>?> selectServiceProvider(String serviceId) async {
    // SVC-HOME-04: [serviceId] is a CreateServices id, so the provider list
    // lives on the service itself (it was looked up in RequestServices, where
    // that id never exists, so every card showed "-").
    final doc = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(serviceId)
        .get();
    if (doc.exists && doc.data() != null) {
      final providerData = doc.data()!['Provider_Services'];

      // ✅ UPDATED: Handle list format
      if (providerData is List && providerData.isNotEmpty) {
        final lastEntry = providerData.last;
        if (lastEntry is String) {
          try {
            final decoded = jsonDecode(lastEntry) as List;
            if (decoded.isNotEmpty) {
              return decoded[0] as Map<String, dynamic>;
            }
          } catch (e) {
            // Malformed provider JSON on this one service: no provider.
            if (kDebugMode) svcLog('Bad Provider_Services on $serviceId: $e');
          }
        }
      }
    }

    return null;
  }

  @override
  Future<Map<String, dynamic>?> getServiceDocById(String serviceId) async {
    if (serviceId.isEmpty) return null;
    return _docs.getCreateServiceDoc(serviceId);
  }

  @override
  Future<List<ServicesHistoryModel>> getMyRequestServicesByRequester(
    String? email,
  ) async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where('Email_Requester', arrayContains: email)
        .get();
    return snapshot.docs
        .map((doc) => ServicesHistoryModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> appendRequestState({
    required String serviceId,
    required String? requesterEmail,
    required String newState,
  }) async {
    // SVC-HOME-13: one document by id. SVC-HOME-02: real append.
    await updateWithHistory(
      firestore,
      firestore
          .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
          .doc(serviceId),
      {
        'state': HistoryAppend(newState),
        'timestamps': HistoryAppend(DateTime.now().millisecondsSinceEpoch),
      },
    );
  }

  @override
  Future<Map<String, dynamic>?> getUserByEmail(String email) =>
      _docs.getUserByEmail(email);

  @override
  Future<ServiceEmployeeModel?> resolveRequestProvider(
    ServicesHistoryModel request,
  ) =>
      _providerResolver.resolve(request);

  @override
  Future<ParentServiceDetails> getParentServiceDetails(
    String parentServiceId,
  ) =>
      _parentDetailsFetcher.fetch(parentServiceId);

  @override
  Future<Map<String, dynamic>?> getCreateServiceDocById(
    String serviceId,
  ) async {
    if (serviceId.isEmpty) return null;
    return _docs.getCreateServiceDoc(serviceId);
  }

  @override
  Future<List<MapEntry<String, Map<String, dynamic>>>>
      getCreateServiceDocEntries() => _docs.getCreateServiceDocEntries();

  @override
  Future<List<Map<String, dynamic>>> getAllCreateServiceDocs() =>
      _docs.getAllCreateServiceDocs();

  @override
  Future<Map<String, dynamic>?> getCreateServiceDocByIdUnderTenantRoot(
    String parentId,
  ) =>
      _docs.getCreateServiceDoc(parentId);
}
