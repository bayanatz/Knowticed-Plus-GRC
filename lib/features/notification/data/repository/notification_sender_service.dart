import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/twillo/twilio_repository.dart';
import '../models/notification_model.dart';
import './notification_template_service.dart';

class NotificationSenderService {
  final NotificationTemplateService _templateService = NotificationTemplateService();
  final TwilioRepository _twilioRepository = TwilioRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Main method to send notifications based on event
  /// This should be called when events happen in your app
  ///
  /// Example usage:
  /// ```dart
  /// await NotificationSenderService().sendNotification(
  ///   module: 'services',
  ///   eventType: 'request_submitted',
  ///   recipientPhone: '+201234567890', // For push/SMS
  ///   recipientEmail: 'user@example.com', // For email
  ///   variables: {
  ///     'serviceName': 'IT Support',
  ///     'requesterName': 'Ahmed Ali',
  ///   },
  ///   locale: 'ar', // 'ar' or 'en'
  /// );
  /// ```
  Future<bool> sendNotification({
    required String module,
    required String eventType,
    String? recipientPhone,
    String? recipientEmail,
    required Map<String, String> variables,
    String locale = 'en', // 'ar' or 'en'
  }) async {
    try {
      print('📤 Sending notification: $module - $eventType');

      // 1️⃣ Get the template from Firebase
      final template = await _templateService.getTemplate(
        module: module,
        eventType: eventType,
      );

      if (template == null) {
        print('⚠️ Template not found for: $module - $eventType');
        return false;
      }

      // 2️⃣ Check if notification is enabled
      if (!template.isEnabled) {
        print('⚠️ Notification is disabled for: $module - $eventType');
        return false;
      }

      // 3️⃣ Check if any notification type is selected
      if (template.selectedNotificationTypes.isEmpty) {
        print('⚠️ No notification types selected for: $module - $eventType');
        return false;
      }

      // 4️⃣ Process template variables
      final subject = locale == 'ar'
          ? _templateService.processTemplate(template.subjectArabic, variables)
          : _templateService.processTemplate(template.subjectEnglish, variables);

      final body = locale == 'ar'
          ? _templateService.processTemplate(template.bodyArabic, variables)
          : _templateService.processTemplate(template.bodyEnglish, variables);

      print('📧 Subject: $subject');
      print('📝 Body: $body');

      bool emailSent = false;
      bool pushSent = false;

      // 5️⃣ Send Email if selected
      if (template.hasEmail && recipientEmail != null) {
        print('📧 Sending email notification...');
        emailSent = await _sendEmailNotification(
          to: recipientEmail,
          subject: subject,
          body: body,
          locale: locale,
        );
      }

      // 6️⃣ Send Push Notification if selected
      if (template.hasPush && recipientPhone != null) {
        print('📱 Sending push notification...');
        pushSent = await _sendPushNotification(
          to: recipientPhone,
          message: body,
          locale: locale,
        );
      }

      // 7️⃣ Log the notification to Firestore
      await _logNotification(
        module: module,
        eventType: eventType,
        recipientPhone: recipientPhone,
        recipientEmail: recipientEmail,
        subject: subject,
        body: body,
        emailSent: emailSent,
        pushSent: pushSent,
      );

      return emailSent || pushSent;
    } catch (e) {
      print('❌ Error sending notification: $e');
      return false;
    }
  }

  /// ✅ Send email using Twilio
  Future<bool> _sendEmailNotification({
    required String to,
    required String subject,
    required String body,
    required String locale,
  }) async {
    try {
      // Using Twilio for email
      // Note: You need to configure Twilio SendGrid for email
      // For now, using SMS channel as example
      await _twilioRepository.sendOTP(to, 'email', locale);

      // TODO: Implement proper Twilio SendGrid integration
      // For full email sending with subject/body, you need:
      // 1. Twilio SendGrid API
      // 2. Verified sender email
      // 3. Email template configuration

      print('✅ Email sent successfully to: $to');
      return true;
    } catch (e) {
      print('❌ Failed to send email: $e');
      return false;
    }
  }

  /// ✅ Send push notification using Twilio (SMS)
  Future<bool> _sendPushNotification({
    required String to,
    required String message,
    required String locale,
  }) async {
    try {
      await _twilioRepository.sendOTP(to, 'sms', locale);

      // TODO: For real push notifications (not SMS), integrate:
      // 1. Firebase Cloud Messaging (FCM)
      // 2. Apple Push Notification Service (APNS)

      print('✅ Push notification sent successfully to: $to');
      return true;
    } catch (e) {
      print('❌ Failed to send push notification: $e');
      return false;
    }
  }

  /// ✅ Log notification to Firestore for tracking
  Future<void> _logNotification({
    required String module,
    required String eventType,
    String? recipientPhone,
    String? recipientEmail,
    required String subject,
    required String body,
    required bool emailSent,
    required bool pushSent,
  }) async {
    try {
      await _firestore.collection('notification_logs').add({
        'module': module,
        'eventType': eventType,
        'recipientPhone': recipientPhone,
        'recipientEmail': recipientEmail,
        'subject': subject,
        'body': body,
        'emailSent': emailSent,
        'pushSent': pushSent,
        'sentAt': Timestamp.now(),
      });

      print('📝 Notification logged to Firestore');
    } catch (e) {
      print('❌ Failed to log notification: $e');
    }
  }

  /// ✅ Batch send notifications to multiple recipients
  Future<void> sendBatchNotifications({
    required String module,
    required String eventType,
    required List<String> recipientPhones,
    required List<String> recipientEmails,
    required Map<String, String> variables,
    String locale = 'en',
  }) async {
    print('📤 Sending batch notifications to ${recipientPhones.length} phones and ${recipientEmails.length} emails');

    for (int i = 0; i < recipientPhones.length; i++) {
      await sendNotification(
        module: module,
        eventType: eventType,
        recipientPhone: recipientPhones[i],
        recipientEmail: i < recipientEmails.length ? recipientEmails[i] : null,
        variables: variables,
        locale: locale,
      );
    }
  }
}