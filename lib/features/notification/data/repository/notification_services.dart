/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_services.dart
/// Description: Firestore reads and writes for user notifications.
/// Author: Amr Mesbah
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-NOTIF-N17: the `Notifications` collection literal now comes from
///          `FirebaseCollections`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';

class FirestoreNotificationService {
  static final FirestoreNotificationService _instance =
      FirestoreNotificationService._internal();

  factory FirestoreNotificationService() => _instance;

  FirestoreNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the notifications collection path
  /// Path: /Demo/70843020/Modules/Notifications
  String _getNotificationsPath() {
    // Was the literal `'Notifications'`; the constant already existed
    // (§15, CR-SKEL-NOTIF-N17).
    final tenantRoot = getBaseUrl(FirebaseCollections.notifications);
    return tenantRoot;
  }

  // Add this method to your FirestoreNotificationService class

  /// Update notification clean status
  Future<bool> updateCleanStatus(String notificationId, bool isClean) async {
    try {
      final notificationsPath = _getNotificationsPath();
      await _firestore.collection(notificationsPath).doc(notificationId).update(
        {'isClean': isClean},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Upload a notification to Firestore
  /// Returns the document ID of the created notification
  Future<String?> uploadNotification(
    NotificationModelSystem notification,
  ) async {
    final String notificationsPath = _getNotificationsPath();
    try {
      final docRef = await _firestore
          .collection(notificationsPath)
          .add(notification.toMap());

      if (kDebugMode) {}
      return docRef.id;
    } catch (e) {
      // This catch returned null with NOTHING logged — no message, no stack.
      // It is the single point where a notification the code believes it sent
      // silently never existed: a denied security rule, an offline write, a
      // bad collection path. From the inbox it is indistinguishable from "the
      // sender never ran", which is exactly the dead end the GRC tab hit.
      return null;
    }
  }

  /// Get all notifications for a specific receiver
  Future<List<NotificationModelSystem>> getNotificationsForUser(
    String receiverEmail,
  ) async {
    try {
      final notificationsPath = _getNotificationsPath();
      final querySnapshot = await _firestore
          .collection(notificationsPath)
          .where('Reciver_Email', isEqualTo: receiverEmail.toLowerCase())
          .get();

      // Sort manually after fetching
      final notifications = querySnapshot.docs
          .map((doc) => NotificationModelSystem.fromFirestore(doc))
          .toList();

      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return notifications;
    } catch (e) {
      return [];
    }
  }

  /// Get notifications for a user filtered by module
  Future<List<NotificationModelSystem>> getNotificationsByModule(
    String receiverEmail,
    String moduleName,
  ) async {
    try {
      final notificationsPath = _getNotificationsPath();
      final querySnapshot = await _firestore
          .collection(notificationsPath)
          .where('Reciver_Email', isEqualTo: receiverEmail.toLowerCase())
          .where('Name_of_module', isEqualTo: moduleName)
          .get();

      // Sort manually after fetching
      final notifications = querySnapshot.docs
          .map((doc) => NotificationModelSystem.fromFirestore(doc))
          .toList();

      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return notifications;
    } catch (e) {
      return [];
    }
  }

  /// Get pinned notifications for a user
  Future<List<NotificationModelSystem>> getPinnedNotifications(
    String receiverEmail,
  ) async {
    try {
      final notificationsPath = _getNotificationsPath();
      final querySnapshot = await _firestore
          .collection(notificationsPath)
          .where('Reciver_Email', isEqualTo: receiverEmail.toLowerCase())
          .where('Pin', isEqualTo: true)
          .get();

      // Sort manually after fetching
      final notifications = querySnapshot.docs
          .map((doc) => NotificationModelSystem.fromFirestore(doc))
          .toList();

      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return notifications;
    } catch (e) {
      return [];
    }
  }

  /// Get unread notifications for a user
  Future<List<NotificationModelSystem>> getUnreadNotifications(
    String receiverEmail,
  ) async {
    try {
      final notificationsPath = _getNotificationsPath();
      final querySnapshot = await _firestore
          .collection(notificationsPath)
          .where('Reciver_Email', isEqualTo: receiverEmail.toLowerCase())
          .where('isRead', isEqualTo: false)
          .get();

      // Sort manually after fetching
      final notifications = querySnapshot.docs
          .map((doc) => NotificationModelSystem.fromFirestore(doc))
          .toList();

      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return notifications;
    } catch (e) {
      return [];
    }
  }

  /// Stream notifications for a user in real-time
  /// NOTE: Sorts manually to avoid composite index requirement
  Stream<List<NotificationModelSystem>> streamNotificationsForUser(
    String receiverEmail,
  ) {
    try {
      final notificationsPath = _getNotificationsPath();
      return _firestore
          .collection(notificationsPath)
          .where('Reciver_Email', isEqualTo: receiverEmail.toLowerCase())
          .snapshots()
          .map((snapshot) {
        // Convert to list and sort manually (to avoid composite index requirement)
        List<NotificationModelSystem> notifications = snapshot.docs
            .map((doc) => NotificationModelSystem.fromFirestore(doc))
            .toList();

        // Sort by timestamp descending (newest first)
        notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return notifications;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Update notification pin status
  Future<bool> updatePinStatus(String notificationId, bool isPinned) async {
    try {
      final notificationsPath = _getNotificationsPath();
      await _firestore.collection(notificationsPath).doc(notificationId).update(
        {'Pin': isPinned},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final notificationsPath = _getNotificationsPath();
      await _firestore.collection(notificationsPath).doc(notificationId).update(
        {'isRead': true},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark all notifications as read for a user
  Future<bool> markAllAsRead(String receiverEmail) async {
    try {
      final notificationsPath = _getNotificationsPath();
      final querySnapshot = await _firestore
          .collection(notificationsPath)
          .where('Reciver_Email', isEqualTo: receiverEmail.toLowerCase())
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark all notifications as cleaned for a user
  Future<bool> markAllAsCleaned(String receiverEmail) async {
    try {
      final notificationsPath = _getNotificationsPath();
      final querySnapshot = await _firestore
          .collection(notificationsPath)
          .where('Reciver_Email', isEqualTo: receiverEmail.toLowerCase())
          .where('isClean', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isClean': true});
      }
      await batch.commit();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Function Name: [markCleaned]
  ///
  /// Purpose: Clear exactly these notifications. 22/10/2026 — Owner: Clean
  /// All clears what the page is SHOWING (the module chip, filters and
  /// search); on "All" with nothing filtered that is every notification.
  ///
  /// Returns: `true` when every batch committed, `false` on failure.
  Future<bool> markCleaned(List<String> notificationIds) => _writeInBatches(
      notificationIds,
      (WriteBatch batch, DocumentReference<Map<String, dynamic>> ref) =>
          batch.update(ref, <String, dynamic>{'isClean': true}));

  /// Function Name: [deleteNotifications]
  ///
  /// Purpose: Permanently delete exactly these notifications (the Cleared
  /// page's Delete All, scoped to what it is showing — 22/10/2026).
  ///
  /// Returns: `true` when every batch committed, `false` on failure.
  Future<bool> deleteNotifications(
          List<String> notificationIds) =>
      _writeInBatches(
          notificationIds,
          (WriteBatch batch, DocumentReference<Map<String, dynamic>> ref) =>
              batch.delete(ref));

  /// One write per id, committed 500 at a time (Firestore's batch cap).
  Future<bool> _writeInBatches(
    List<String> ids,
    void Function(WriteBatch, DocumentReference<Map<String, dynamic>>) write,
  ) async {
    try {
      final CollectionReference<Map<String, dynamic>> col =
          _firestore.collection(_getNotificationsPath());
      const int batchLimit = 500;
      for (int start = 0; start < ids.length; start += batchLimit) {
        final WriteBatch batch = _firestore.batch();
        final int end =
            start + batchLimit > ids.length ? ids.length : start + batchLimit;
        for (final String id in ids.sublist(start, end)) {
          write(batch, col.doc(id));
        }
        await batch.commit();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Function Name: [deleteAllCleaned]
  ///
  /// Purpose: Permanently delete every cleared notification for a user.
  ///
  /// The Cleared page's "Delete All" — the counterpart to [markAllAsCleaned],
  /// which only flips `isClean`. Batched like the other bulk writes, and it
  /// scopes to `isClean: true` so nothing in the live inbox or the pinned list
  /// is touched.
  ///
  /// Returns: `true` when the batch committed, `false` on failure — the caller
  /// is a dialog flow that skips its success step on `false`.
  Future<bool> deleteAllCleaned(String receiverEmail) async {
    try {
      final notificationsPath = _getNotificationsPath();
      final querySnapshot = await _firestore
          .collection(notificationsPath)
          .where('Reciver_Email', isEqualTo: receiverEmail.toLowerCase())
          .where('isClean', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) return true;

      // Firestore caps a batch at 500 writes, and a long-lived inbox can hold
      // more than that — commit in chunks rather than throwing on doc 501.
      const int batchLimit = 500;
      for (int start = 0;
          start < querySnapshot.docs.length;
          start += batchLimit) {
        final batch = _firestore.batch();
        final end = (start + batchLimit) > querySnapshot.docs.length
            ? querySnapshot.docs.length
            : start + batchLimit;
        for (final doc in querySnapshot.docs.sublist(start, end)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final notificationsPath = _getNotificationsPath();
      await _firestore
          .collection(notificationsPath)
          .doc(notificationId)
          .delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get notification count for a user
  Future<int> getNotificationCount(
    String receiverEmail, {
    bool unreadOnly = false,
  }) async {
    try {
      final notificationsPath = _getNotificationsPath();
      var query = _firestore
          .collection(notificationsPath)
          .where('Reciver_Email', isEqualTo: receiverEmail.toLowerCase());

      if (unreadOnly) {
        query = query.where('isRead', isEqualTo: false);
      }

      final snapshot = await query.count().get();
      final count = snapshot.count ?? 0;

      return count;
    } catch (e) {
      return 0;
    }
  }
}
