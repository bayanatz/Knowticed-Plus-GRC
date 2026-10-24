import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/inventory/domain/models/storage_location_model.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

class StorageLocationService {
  /// 🔹 Returns the subcollection under the user where locations are stored:
  /// /Demo/`<companyId>`/supplier/user/`<userEmail>`
  static CollectionReference<Map<String, dynamic>> _locationsCol(
      String userEmail) {
    return FirebaseFirestore.instance
        .collection("Demo")
        .doc(InventoryPaths.companyId)
        .collection("Storage Location")
        .doc("user")
        .collection(userEmail);
  }

  /// Create a document with a **specific ID** (e.g., SUP002)
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
  static Future<List<StorageLocation>> listAll(
      {required String userEmail}) async {
    final q = await _locationsCol(userEmail).get();
    return q.docs.map((d) => StorageLocation.fromJson(d.data())).toList();
  }
}
