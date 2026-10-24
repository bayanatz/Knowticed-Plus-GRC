/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: app_notification_cubit.dart
/// Purpose: The live notification cubit — unread counts and the inbox stream.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).
library;

/// ***************************** FILE INFO ***************************** ///
/// File Name: app_notification_cubit.dart
/// Purpose: Stub notification sender — the FCM notification module is not
///          included in knowticed.
/// Description: Converted from AppNotificationController (GetxController).
///              The send/subscribe methods stay no-ops; the unseen-notification
///              stream is unchanged. State is emitted so widgets can rebuild
///              with BlocBuilder instead of GetBuilder.
/// ********************************************************************* ///

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

part 'app_notification_state.dart';

class AppNotificationCubit extends Cubit<AppNotificationState> {
  AppNotificationCubit() : super(const AppNotificationInitial());

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

  /// Stream of unread notifications for the currently logged-in employee.
  /// Reads the same flat tenant collection the inbox and every sender use
  /// (`<baseUri>/Notifications`, filtered by `Reciver_Email` / `isRead`).
  Stream<QuerySnapshot>? getUnseenNotificationsStream() {
    try {
      final email = employee?.email.lastOrNull;
      if (email == null || email.isEmpty) return null;
      return FirebaseFirestore.instance
          .collection(getBaseUrl(FirebaseCollections.notifications))
          .where('Reciver_Email', isEqualTo: email.trim().toLowerCase())
          .where('isRead', isEqualTo: false)
          .snapshots();
    } catch (e) {
      return null;
    }
  }
}
