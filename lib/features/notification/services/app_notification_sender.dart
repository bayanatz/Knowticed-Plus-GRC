/// ************************* FILE INFO ************************* ///
/// File Name: app_notification_sender.dart
/// Purpose: ONE shared facade for sending notifications from any module.
///          Wraps the 3 steps every module was repeating:
///            1. Fetch bilingual template + replace {{variables}}
///            2. Save in-app notification to Firestore
///            3. Send FCM push
/// Usage: Modules should NOT call this directly from UI/cubits.
///        Each module has its own thin service (e.g.
///        ServicesNotificationService) with intent-named methods
///        that call this facade.

import 'package:flutter/foundation.dart';
import 'package:grc_module/features/notification/data/data_source/notification_page_confg.dart';
import 'package:grc_module/features/notification/data/models/notification_data_model.dart';
import 'package:grc_module/features/notification/data/repository/notification_services.dart';
import 'package:grc_module/features/notification/data/repository/notification_template_service.dart';

import 'package:grc_module/features/notification/domain/enums/notification_event.dart';
import 'package:grc_module/core/enums/app_module.dart';
import 'package:grc_module/core/enums/template_variable.dart';

class AppNotificationSender {
  AppNotificationSender._();

  static final FirestoreNotificationService _firestoreService =
      FirestoreNotificationService();
  static final NotificationTemplateService _templateService =
      NotificationTemplateService();

  /// LOW-LEVEL: save in-app notification + (optionally) send FCM push.
  /// Use when you already have a final title/body (no template).
  /// Returns the Firestore document id, or null on failure.
  static Future<String?> send({
    required AppModule module,
    required String pageKey,
    required String title,
    required String body,
    required String senderEmail,
    required String receiverEmail,
    bool isPinned = false,
    bool sendPush = true,
  }) async {
    if (receiverEmail.isEmpty) return null;
    try {
      final docId = await _firestoreService.uploadNotification(
        NotificationModelSystem(
          title: title,
          body: body,
          nameOfModule: module.key,
          senderEmail: senderEmail,
          receiverEmail: receiverEmail,
          nameOfPage: pageKey,
          isPinned: isPinned,
        ),
      );

      if (sendPush) {
        await NotificationServiceApp.sendNotification(
          title,
          body,
          receiverEmail,
        );
      }
      return docId;
    } catch (e) {
      debugPrint('❌ AppNotificationSender.send error: $e');
      return null;
    }
  }

  /// HIGH-LEVEL: fetch the bilingual template `<module>_<eventType>`,
  /// replace {{variables}}, then save + push.
  /// Returns true if the notification was sent.
  static Future<bool> sendFromTemplate({
    required AppModule module,
    required String eventType,
    required String pageKey,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    Map<String, String> variables = const {},
    bool isPinned = false,
    bool sendPush = true,
  }) async {
    if (receiverEmail.isEmpty) return false;
    try {
      final template = await _templateService.getTemplate(
        module: module.key,
        eventType: eventType,
      );

      // `isEnabled` is the master switch — off means this notification is
      // silenced completely.
      if (template == null || !template.isEnabled) return false;

      // The channel checkboxes only decide HOW it is delivered. Previously an
      // admin who unchecked "Push" but left "Email" on lost the in-app
      // notification as well, because push was treated as mandatory. The
      // in-app record is now always written; push fires only when selected.
      final pushAllowed = sendPush && template.hasPush;

      final title = _templateService.processTemplate(
        isArabic ? template.subjectArabic : template.subjectEnglish,
        variables,
      );
      final body = _templateService.processTemplate(
        isArabic ? template.bodyArabic : template.bodyEnglish,
        variables,
      );

      final docId = await send(
        module: module,
        pageKey: pageKey,
        title: title,
        body: body,
        senderEmail: senderEmail,
        receiverEmail: receiverEmail,
        isPinned: isPinned,
        sendPush: pushAllowed,
      );
      return docId != null;
    } catch (e) {
      debugPrint('❌ AppNotificationSender.sendFromTemplate error: $e');
      return false;
    }
  }

  /// PREFERRED: send a catalog event. No raw module / eventType / placeholder
  /// strings anywhere at the call site.
  ///
  ///   AppNotificationSender.sendEvent(
  ///     event: ServicesNotificationEvent.requestApproved,
  ///     pageKey: ServicesNotificationPage.approvalRequestCard.key,
  ///     senderEmail: me, receiverEmail: requester, isArabic: isAr,
  ///     variables: {TemplateVariable.serviceName: service.name},
  ///   );
  ///
  /// The Firestore template still wins — the enum text is only the fallback
  /// when no admin has customised `<module>_<key>` yet.
  static Future<bool> sendEvent({
    required NotificationEvent event,
    required String pageKey,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    Map<TemplateVariable, String> variables = const {},
    bool isPinned = false,
    bool sendPush = true,
  }) {
    assert(
      variables.keys.toSet().containsAll(event.variables),
      'Missing placeholders for ${event.templateId}: '
      '${event.variables.difference(variables.keys.toSet())}',
    );
    return sendFromTemplate(
      module: event.module,
      eventType: event.key,
      pageKey: pageKey,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      variables: variables.toTemplateVariables(),
      isPinned: isPinned,
      sendPush: sendPush,
    );
  }

  /// Same event, many recipients. Returns how many were sent.
  static Future<int> sendEventToAll({
    required NotificationEvent event,
    required String pageKey,
    required String senderEmail,
    required Iterable<String> receiverEmails,
    required bool isArabic,
    Map<TemplateVariable, String> variables = const {},
    bool isPinned = false,
    bool sendPush = true,
  }) async {
    var sent = 0;
    for (final email in receiverEmails.toSet()) {
      final ok = await sendEvent(
        event: event,
        pageKey: pageKey,
        senderEmail: senderEmail,
        receiverEmail: email,
        isArabic: isArabic,
        variables: variables,
        isPinned: isPinned,
        sendPush: sendPush,
      );
      if (ok) sent++;
    }
    return sent;
  }
}
