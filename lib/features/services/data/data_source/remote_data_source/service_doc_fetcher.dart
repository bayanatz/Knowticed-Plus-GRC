/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: service_doc_fetcher.dart
/// Purpose: Firestore reads for fetching a service document to edit. Extracted
///          from ServicesManagerCubit.
/// Revision History:
///   18/10/2026 (Amr Mesbah): SVC-HOME-09 — removed
///   debugCreateServicesStructure (read every CreateServices document on each
///   Edit tap). SVC-HOME-13 — every method reads the ONE document by id
///   instead of downloading all of the creator's services to find it.
///   SVC-HOME-05 — failures are logged, never silently turned into "missing".
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

/// Result of a fetch-to-edit operation. [error] is null on success.
class FetchedServiceDoc {
  final Map<String, dynamic>? rawJson;
  final ServicesHistoryModel? model;
  final String? error;

  const FetchedServiceDoc({this.rawJson, this.model, this.error});

  bool get isSuccess => error == null && model != null;
}

class ServiceDocFetcher {
  ServiceDocFetcher({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Reads CreateServices/{serviceId}. Returns an error result when the
  /// document is missing or the read fails.
  Future<FetchedServiceDoc> _read(String serviceId) async {
    try {
      final doc = await _firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(serviceId)
          .get();

      final data = doc.data();
      if (!doc.exists || data == null) {
        return const FetchedServiceDoc(error: 'Service not found');
      }
      final model = ServicesHistoryModel.fromJson(data, doc.id);
      return FetchedServiceDoc(rawJson: data, model: model);
    } catch (e) {
      svcLog('ServiceDocFetcher: reading $serviceId failed: $e');
      return FetchedServiceDoc(error: 'Error fetching document: $e');
    }
  }

  /// Loads the editable service document.
  Future<FetchedServiceDoc> fetchDocToEdit(String serviceId) =>
      _read(serviceId);

  /// Same as [fetchDocToEdit] but returns null on any failure (logged).
  Future<FetchedServiceDoc?> fetchDocToEditSilent(String serviceId) async {
    final result = await _read(serviceId);
    return result.isSuccess ? result : null;
  }

  /// Loads a service document directly, null on failure (logged).
  Future<FetchedServiceDoc?> fetchDocAllToEditSilent(String serviceId) =>
      fetchDocToEditSilent(serviceId);

  /// Loads a service document directly, returning an error string on failure.
  Future<FetchedServiceDoc> fetchDocAllToEdit(String serviceId) =>
      _read(serviceId);
}
