import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';

/// Stub AppNotificationController — FCM notification module not included in demo_app.
class AppNotificationController extends GetxController {
  Future<void> subscribeToTopic(String topic) async {
    // No-op stub
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    // No-op stub
  }

  Future<void> sendNotification({
    required String type,
    required String topic,
    required String title,
    required String arabicTitle,
    required String body,
    required String arabicBody,
    String? surveyId,
    String? eventId,
    String? noteId,
    String? cardId,
    String? todoId,
    String? boardId,
    String? serviceId,
    String? serviceRequestId,
  }) async {
    // No-op stub
  }

  Future<void> sendNotificationToMultiple({
    required String type,
    required List<String> topics,
    required String title,
    required String arabicTitle,
    required String body,
    required String arabicBody,
    String? surveyId,
    String? eventId,
    String? noteId,
    String? cardId,
    String? todoId,
    String? boardId,
    String? serviceId,
    String? serviceRequestId,
  }) async {
    // No-op stub
  }

  /// Stream of unseen notifications for the currently logged-in employee.
  Stream<QuerySnapshot>? getUnseenNotificationsStream() {
    try {
      final email = employee?.email?.lastOrNull;
      if (email == null || email.isEmpty) return null;
      return FirebaseFirestore.instance
          .collection('Notifications')
          .doc(email)
          .collection('Notifications')
          .where('seen', isEqualTo: false)
          .snapshots();
    } catch (e) {
      return null;
    }
  }
}
