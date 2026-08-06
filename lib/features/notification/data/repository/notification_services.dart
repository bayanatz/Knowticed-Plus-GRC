import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:grc_module/core/network/get_base_url.dart';
import '../models/notification_data_model.dart';

class FirestoreNotificationService {
  static final FirestoreNotificationService _instance =
  FirestoreNotificationService._internal();

  factory FirestoreNotificationService() => _instance;

  FirestoreNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the notifications collection path
  /// Path: /Demo/70843020/Modules/Notifications
  String _getNotificationsPath() {
    final tenantRoot = getBaseUrl('Notifications');
    return tenantRoot;
  }



  // Add this method to your FirestoreNotificationService class

  /// Update notification clean status
  Future<bool> updateCleanStatus(String notificationId, bool isClean) async {
    try {
      debugPrint('🧹 Updating clean status for notification: $notificationId');
      debugPrint('   New clean status: $isClean');

      final notificationsPath = _getNotificationsPath();
      await _firestore
          .collection(notificationsPath)
          .doc(notificationId)
          .update({'isClean': isClean});

      debugPrint('   ✅ Clean status updated successfully');
      return true;
    } catch (e, st) {
      debugPrint('   ❌ ERROR updating clean status: $e');
      debugPrint('   Stack trace: $st');
      return false;
    }
  }

  /// Upload a notification to Firestore
  /// Returns the document ID of the created notification
  Future<String?> uploadNotification(NotificationModelSystem notification) async {
    try {
      debugPrint('📤 Uploading notification to Firestore...');
      debugPrint('   Title: ${notification.title}');
      debugPrint('   Module: ${notification.nameOfModule}');
      debugPrint('   Sender: ${notification.senderEmail}');
      debugPrint('   Receiver: ${notification.receiverEmail}');
      debugPrint('   Page: ${notification.nameOfPage}');
      debugPrint('   Pinned: ${notification.isPinned}');

      final notificationsPath = _getNotificationsPath();
      debugPrint('   Path: $notificationsPath');

      final docRef = await _firestore
          .collection(notificationsPath)
          .add(notification.toMap());

      debugPrint('   ✅ Notification uploaded successfully!');
      debugPrint('   Document ID: ${docRef.id}');

      return docRef.id;
    } catch (e, st) {
      debugPrint('   ❌ ERROR uploading notification: $e');
      debugPrint('   Stack trace: $st');
      return null;
    }
  }

  /// Get all notifications for a specific receiver
  Future<List<NotificationModelSystem>> getNotificationsForUser(
      String receiverEmail) async {
    try {
      debugPrint('📥 Fetching notifications for user: $receiverEmail');

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

      debugPrint('   ✅ Found ${notifications.length} notifications');
      return notifications;
    } catch (e, st) {
      debugPrint('   ❌ ERROR fetching notifications: $e');
      debugPrint('   Stack trace: $st');
      return [];
    }
  }

  /// Get notifications for a user filtered by module
  Future<List<NotificationModelSystem>> getNotificationsByModule(
      String receiverEmail,
      String moduleName,
      ) async {
    try {
      debugPrint(
          '📥 Fetching notifications for user: $receiverEmail, module: $moduleName');

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

      debugPrint('   ✅ Found ${notifications.length} notifications');
      return notifications;
    } catch (e, st) {
      debugPrint('   ❌ ERROR fetching notifications by module: $e');
      debugPrint('   Stack trace: $st');
      return [];
    }
  }

  /// Get pinned notifications for a user
  Future<List<NotificationModelSystem>> getPinnedNotifications(
      String receiverEmail) async {
    try {
      debugPrint('📌 Fetching pinned notifications for user: $receiverEmail');

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

      debugPrint('   ✅ Found ${notifications.length} pinned notifications');
      return notifications;
    } catch (e, st) {
      debugPrint('   ❌ ERROR fetching pinned notifications: $e');
      debugPrint('   Stack trace: $st');
      return [];
    }
  }

  /// Get unread notifications for a user
  Future<List<NotificationModelSystem>> getUnreadNotifications(
      String receiverEmail) async {
    try {
      debugPrint('📬 Fetching unread notifications for user: $receiverEmail');

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

      debugPrint('   ✅ Found ${notifications.length} unread notifications');
      return notifications;
    } catch (e, st) {
      debugPrint('   ❌ ERROR fetching unread notifications: $e');
      debugPrint('   Stack trace: $st');
      return [];
    }
  }

  /// Stream notifications for a user in real-time
  /// NOTE: Sorts manually to avoid composite index requirement
  Stream<List<NotificationModelSystem>> streamNotificationsForUser(
      String receiverEmail) {
    try {
      debugPrint('🔴 Starting notification stream for user: $receiverEmail');

      final notificationsPath = _getNotificationsPath();
      return _firestore
          .collection(notificationsPath)
          .where('Reciver_Email', isEqualTo: receiverEmail.toLowerCase())
          .snapshots()
          .map((snapshot) {
        debugPrint('   📡 Stream update: ${snapshot.docs.length} notifications');

        // Convert to list and sort manually (to avoid composite index requirement)
        List<NotificationModelSystem> notifications = snapshot.docs
            .map((doc) => NotificationModelSystem.fromFirestore(doc))
            .toList();

        // Sort by timestamp descending (newest first)
        notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return notifications;
      });
    } catch (e, st) {
      debugPrint('   ❌ ERROR creating notification stream: $e');
      debugPrint('   Stack trace: $st');
      return Stream.value([]);
    }
  }

  /// Update notification pin status
  Future<bool> updatePinStatus(String notificationId, bool isPinned) async {
    try {
      debugPrint('📌 Updating pin status for notification: $notificationId');
      debugPrint('   New pin status: $isPinned');

      final notificationsPath = _getNotificationsPath();
      await _firestore
          .collection(notificationsPath)
          .doc(notificationId)
          .update({'Pin': isPinned});

      debugPrint('   ✅ Pin status updated successfully');
      return true;
    } catch (e, st) {
      debugPrint('   ❌ ERROR updating pin status: $e');
      debugPrint('   Stack trace: $st');
      return false;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      debugPrint('✅ Marking notification as read: $notificationId');

      final notificationsPath = _getNotificationsPath();
      await _firestore
          .collection(notificationsPath)
          .doc(notificationId)
          .update({'isRead': true});

      debugPrint('   ✅ Notification marked as read');
      return true;
    } catch (e, st) {
      debugPrint('   ❌ ERROR marking notification as read: $e');
      debugPrint('   Stack trace: $st');
      return false;
    }
  }

  /// Mark all notifications as read for a user
  Future<bool> markAllAsRead(String receiverEmail) async {
    try {
      debugPrint('✅ Marking all notifications as read for: $receiverEmail');

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

      debugPrint('   ✅ Marked ${querySnapshot.docs.length} notifications as read');
      return true;
    } catch (e, st) {
      debugPrint('   ❌ ERROR marking all notifications as read: $e');
      debugPrint('   Stack trace: $st');
      return false;
    }
  }

  /// Mark all notifications as cleaned for a user
  Future<bool> markAllAsCleaned(String receiverEmail) async {
    try {
      debugPrint('🧹 Marking all notifications as cleaned for: $receiverEmail');

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

      debugPrint('   ✅ Marked ${querySnapshot.docs.length} notifications as cleaned');
      return true;
    } catch (e, st) {
      debugPrint('   ❌ ERROR marking all notifications as cleaned: $e');
      debugPrint('   Stack trace: $st');
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      debugPrint('🗑️ Deleting notification: $notificationId');

      final notificationsPath = _getNotificationsPath();
      await _firestore
          .collection(notificationsPath)
          .doc(notificationId)
          .delete();

      debugPrint('   ✅ Notification deleted successfully');
      return true;
    } catch (e, st) {
      debugPrint('   ❌ ERROR deleting notification: $e');
      debugPrint('   Stack trace: $st');
      return false;
    }
  }

  /// Get notification count for a user
  Future<int> getNotificationCount(String receiverEmail,
      {bool unreadOnly = false}) async {
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

      debugPrint(
          '🔢 Notification count for $receiverEmail: $count ${unreadOnly ? "(unread)" : ""}');
      return count;
    } catch (e, st) {
      debugPrint('   ❌ ERROR getting notification count: $e');
      debugPrint('   Stack trace: $st');
      return 0;
    }
  }
}