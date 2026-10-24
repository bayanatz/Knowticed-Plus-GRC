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

  /// ✅ NEW: Get storage locations for dropdown (active only)
  /// This method fetches only active storage locations and returns them in a format
  /// suitable for dropdown widgets
  static Future<List<StorageLocation>> getStorageLocations(
      {String? userEmail}) async {
    try {
      final email = userEmail ?? "default@user.com";

      final querySnapshot = await _locationsCol(email)
          .where('status.value', isEqualTo: 'active')
          .orderBy('name.value')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();

        // Create StorageLocation with Firebase document ID as the unique identifier
        return StorageLocation.fromJson({
          ...data,
          'id': {
            'value': doc.id, // Use Firebase document ID (guaranteed unique)
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          }
        });
      }).toList();
    } catch (e) {
      debugPrint('Error fetching storage locations: $e');
      return [];
    }
  }

  /// ✅ NEW: Convert StorageLocation list to dropdown format
  /// Converts the StorageLocation objects to the Map`<String, String>` format
  /// expected by dropdown widgets
  static List<Map<String, String>> convertToDropdownItems(
      List<StorageLocation> locations) {
    return locations
        .map((location) => {
              'key': location.id.value,
              'value': location.name.value,
            })
        .toList();
  }

  /// ✅ NEW: Get storage location by ID
  /// Useful for finding storage location details when you have the ID
  static Future<StorageLocation?> getStorageLocationById({
    required String locationId,
    String? userEmail,
  }) async {
    try {
      final email = userEmail ?? "default@user.com";

      final querySnapshot = await _locationsCol(email)
          .where('id.value', isEqualTo: locationId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return StorageLocation.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching storage location by ID: $e');
      return null;
    }
  }

  /// ✅ NEW: Get storage location name by ID
  /// Quick method to get just the name when you have the ID
  static Future<String?> getStorageLocationName({
    required String locationId,
    String? userEmail,
  }) async {
    final location = await getStorageLocationById(
      locationId: locationId,
      userEmail: userEmail,
    );
    return location?.name.value;
  }

  /// ✅ NEW: Search storage locations by name
  /// Useful for implementing search functionality
  static Future<List<StorageLocation>> searchStorageLocationsByName({
    required String searchTerm,
    String? userEmail,
  }) async {
    try {
      final email = userEmail ?? "default@user.com";

      // Note: Firestore doesn't support case-insensitive search natively
      // This is a basic implementation - for better search, consider using
      // Algolia or implementing a more sophisticated search strategy
      final querySnapshot = await _locationsCol(email)
          .where('status.value', isEqualTo: 'active')
          .orderBy('name.value')
          .startAt([searchTerm]).endAt(['$searchTerm\uf8ff']).get();

      return querySnapshot.docs
          .map((doc) => StorageLocation.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error searching storage locations: $e');
      return [];
    }
  }

  /// ✅ NEW: Get storage locations stream for real-time updates in dropdown
  static Stream<List<StorageLocation>> getStorageLocationsStream(
      {String? userEmail}) {
    try {
      final email = userEmail ?? "default@user.com";

      return _locationsCol(email)
          .where('status.value', isEqualTo: 'active')
          .orderBy('name.value')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => StorageLocation.fromJson(doc.data()))
              .toList());
    } catch (e) {
      debugPrint('Error creating storage locations stream: $e');
      return Stream.value([]);
    }
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

  /// ✅ FIXED: Update an existing document by its actual Firestore document ID
  static Future<void> update({
    required String userEmail,
    required String
        docId, // This should be the Firestore document ID, not storageLocationId
    required StorageLocation model,
  }) async {
    final ref = _locationsCol(userEmail).doc(docId);

    // Use update() instead of set() to ensure we're updating, not creating
    final data = model.toFirestoreJson();
    await ref.update(data);
  }

  /// ✅ SAFER UPDATE: Update existing document with merge option as fallback
  static Future<void> updateSafe({
    required String userEmail,
    required String docId,
    required StorageLocation model,
  }) async {
    final ref = _locationsCol(userEmail).doc(docId);

    // First check if document exists
    final docSnapshot = await ref.get();
    if (!docSnapshot.exists) {
      throw Exception('Storage location with ID $docId not found');
    }

    // Update the document
    final data = model.toFirestoreJson();
    await ref.update(data);
  }

  /// 🔹 Update only the status field (immediate update)
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

  /// 🔹 Update status with confirmation and success callbacks
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

  /// ✅ NEW: Get the actual Firestore document ID by storage location ID
  static Future<String?> getFirestoreDocIdByStorageLocationId({
    required String userEmail,
    required String storageLocationId,
  }) async {
    try {
      final querySnapshot = await _locationsCol(userEmail)
          .where('id.value', isEqualTo: storageLocationId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      debugPrint('Error finding document by storage location ID: $e');
      return null;
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

  /// ✅ NEW: Validate storage location exists and is active
  static Future<bool> isValidActiveLocation({
    required String locationId,
    String? userEmail,
  }) async {
    try {
      final location = await getStorageLocationById(
        locationId: locationId,
        userEmail: userEmail,
      );
      return location != null && location.status.value == 'active';
    } catch (e) {
      debugPrint('Error validating storage location: $e');
      return false;
    }
  }

  /// ✅ NEW: Get multiple storage locations by IDs
  /// Useful when you need to get details for multiple locations at once
  static Future<List<StorageLocation>> getStorageLocationsByIds({
    required List<String> locationIds,
    String? userEmail,
  }) async {
    try {
      final email = userEmail ?? "default@user.com";

      if (locationIds.isEmpty) return [];

      // Firestore 'in' query supports up to 10 items
      // If more than 10, split into multiple queries
      final List<StorageLocation> allLocations = [];

      for (int i = 0; i < locationIds.length; i += 10) {
        final batch = locationIds.skip(i).take(10).toList();

        final querySnapshot =
            await _locationsCol(email).where('id.value', whereIn: batch).get();

        final batchLocations = querySnapshot.docs
            .map((doc) => StorageLocation.fromJson(doc.data()))
            .toList();

        allLocations.addAll(batchLocations);
      }

      return allLocations;
    } catch (e) {
      debugPrint('Error fetching multiple storage locations: $e');
      return [];
    }
  }
}
