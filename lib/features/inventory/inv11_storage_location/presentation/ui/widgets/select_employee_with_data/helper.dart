import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/inventory/domain/models/storage_location_model.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

class StorageLocationService {
  /// 🔹 Returns the subcollection under the user where locations are stored:
  /// /Demo/`<companyId>`/Storage Location/user/`<userEmail>`
  static CollectionReference<Map<String, dynamic>> _locationsCol(
      String userEmail) {
    return FirebaseFirestore.instance
        .collection("Demo")
        .doc(InventoryPaths.companyId)
        .collection("Storage Location");
  }

  /// Create a document with a **specific ID** (e.g., SL001)
  static Future<void> setWithId({
    required String userEmail,
    required String docId,
    required StorageLocation model,
  }) async {
    final ref = _locationsCol(userEmail).doc(docId);
    await ref.set(model.toFirestoreJson());
  }

  /// Auto-generate a document ID under the user path
  static Future<String> createAutoId({
    required String userEmail,
    required StorageLocation model,
  }) async {
    final ref = _locationsCol(userEmail).doc();
    await ref.set(model.toFirestoreJson());
    return ref.id;
  }

  /// Update an existing document
  static Future<void> update({
    required String userEmail,
    required String docId,
    required StorageLocation model,
  }) async {
    final ref = _locationsCol(userEmail).doc(docId);
    await ref.set(model.toFirestoreJson(), SetOptions(merge: true));
  }

  /// 🔹 NEW: Update only the status field (immediate update)
  static Future<bool> updateStatus({
    required String userEmail,
    required String docId,
    required String newStatus,
  }) async {
    try {
      final ref = _locationsCol(userEmail).doc(docId);
      await ref.update({
        'status.value': newStatus,
        'status.timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  /// 🔹 NEW: Update status with confirmation and success callbacks
  static Future<bool> updateStatusWithDialogs({
    required String userEmail,
    required String docId,
    required String newStatus,
    required Future<bool> Function() showConfirmDialog,
    required Future<void> Function() showSuccessDialog,
  }) async {
    try {
      // Show confirmation dialog
      final confirmed = await showConfirmDialog();
      if (!confirmed) return false;

      // Update only the status field in Firestore
      final ref = _locationsCol(userEmail).doc(docId);
      await ref.update({
        'status.value': newStatus,
        'status.timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Show success dialog
      await showSuccessDialog();
      return true;
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  /// Fetch a specific document by ID
  static Future<StorageLocation?> getById({
    required String userEmail,
    required String docId,
  }) async {
    final snap = await _locationsCol(userEmail).doc(docId).get();
    if (!snap.exists) return null;
    return StorageLocation.fromJson(snap.data()!);
  }

  /// Fetch all documents under the user
  static Future<List<StorageLocation>> listAll({
    required String userEmail,
  }) async {
    final q = await _locationsCol(userEmail).get();
    return q.docs.map((d) => StorageLocation.fromJson(d.data())).toList();
  }

  /// Delete a document by ID
  static Future<void> delete({
    required String userEmail,
    required String docId,
  }) async {
    final ref = _locationsCol(userEmail).doc(docId);
    await ref.delete();
  }

  /// Check if a document exists
  static Future<bool> exists({
    required String userEmail,
    required String docId,
  }) async {
    final snap = await _locationsCol(userEmail).doc(docId).get();
    return snap.exists;
  }

  /// Get real-time stream of all storage locations
  static Stream<List<StorageLocation>> streamAll({
    required String userEmail,
  }) {
    return _locationsCol(userEmail).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StorageLocation.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get real-time stream of a specific storage location
  static Stream<StorageLocation?> streamById({
    required String userEmail,
    required String docId,
  }) {
    return _locationsCol(userEmail).doc(docId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return StorageLocation.fromJson(snapshot.data()!);
    });
  }
}
