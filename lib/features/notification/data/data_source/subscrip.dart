import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/presentation/controller/settings_controller.dart';

class FCMSubscriptionService {

  /// Subscribe current logged-in user to their personal notification channel
  /// ✅ UPDATED: Handle platform-specific token requirements
  static Future<void> subscribeToPersonalChannel({String? userEmail}) async {
    try {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  subscribeToPersonalChannel() STARTED                     ║');
      print('╚════════════════════════════════════════════════════════════╝');

      String? email;

      // ✅ Option 1: Use provided email
      if (userEmail != null && userEmail.isNotEmpty) {
        email = userEmail;
        print('📧 Using provided email: $email');
      }
      // ✅ Option 2: Try to get from SettingsController
      else {
        try {
          SettingsController settingsController = Get.find<SettingsController>();

          if (settingsController.employee == null) {
            print('⚠️ No employee found in SettingsController');
            return;
          }

          if (settingsController.employee!.email == null ||
              settingsController.employee!.email!.isEmpty ||
              settingsController.employee!.email!.last == null) {
            print('⚠️ No email found for employee');
            return;
          }

          email = settingsController.employee!.email!.last!;
          print('📧 Using email from SettingsController: $email');
        } catch (e) {
          print('⚠️ SettingsController not found: $e');
          return;
        }
      }

      if (email == null || email.isEmpty) {
        print('⚠️ No email available - cannot subscribe');
        return;
      }

      // ✅ PLATFORM-SPECIFIC: Wait for APNS token on iOS/macOS
      // ✅ PLATFORM-SPECIFIC: Wait for APNS token on iOS/macOS with retries
      if (Platform.isIOS || Platform.isMacOS) {
        // print('🍎 Apple platform detected - waiting for APNS token...');
        //
        // String? apnsToken;
        // int retries = 0;
        // const maxRetries = 5;
        //
        // while (apnsToken == null && retries < maxRetries) {
        //   try {
        //     apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        //
        //     if (apnsToken == null) {
        //       retries++;
        //       if (retries < maxRetries) {
        //         final delay = Duration(seconds: retries * 2); // Exponential backoff
        //         print('⏳ Retry $retries/$maxRetries - waiting ${delay.inSeconds}s for APNS token...');
        //         await Future.delayed(delay);
        //       }
        //     } else {
        //       print('✅ APNS token acquired after $retries retries: ${apnsToken.substring(0, 10)}...');
        //     }
        //   } catch (e) {
        //     retries++;
        //     if (retries < maxRetries) {
        //       print('⚠️ Error getting APNS token (attempt $retries/$maxRetries): $e');
        //       await Future.delayed(Duration(seconds: retries * 2));
        //     }
        //   }
        // }
        //
        // if (apnsToken == null) {
        //   print('⚠️ APNS token not available after $maxRetries retries');
        //   print('💡 Subscription will be attempted anyway, but may fail on macOS');
        // }
      }

      // Generate topic name (same format as in CSV upload)
      String topicName = email
          .trim()
          .toLowerCase()
          .replaceAll('@', '_at_')
          .replaceAll('.', '_dot_')
          .replaceAll('+', '_plus_')
          .replaceAll(' ', '_');

      print('📧 User email: $email');
      print('📢 Topic name: $topicName');
      print('🔄 Subscribing to topic...');

      // Subscribe to personal notification channel
      await FirebaseMessaging.instance.subscribeToTopic(topicName);

      print('✅ Successfully subscribed to personal channel!');
      print('   Topic: $topicName');
      print('   Email: $email');
      print('╚════════════════════════════════════════════════════════════╝\n');

    } catch (e, stackTrace) {
      print('\n❌ Failed to subscribe to personal channel');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('╚════════════════════════════════════════════════════════════╝\n');
      // Don't throw - subscription failure shouldn't crash the app
    }
  }

  /// Subscribe to the general "App" broadcast channel
  static Future<void> subscribeToAppChannel() async {
    try {
      print('📢 Subscribing to App broadcast channel...');

      // ✅ PLATFORM-SPECIFIC: Wait for APNS token on iOS/macOS
      if (Platform.isIOS || Platform.isMacOS) {
        print('🍎 Waiting for APNS token before subscribing to App...');
        await Future.delayed(const Duration(seconds: 1));
      }

      await FirebaseMessaging.instance.subscribeToTopic('App');
      print('✅ Subscribed to App channel');
    } catch (e) {
      print('⚠️ Failed to subscribe to App channel: $e');
    }
  }

  /// Unsubscribe from personal channel (call this on logout)
  static Future<void> unsubscribeFromPersonalChannel({String? userEmail}) async {
    try {
      String? email;

      if (userEmail != null && userEmail.isNotEmpty) {
        email = userEmail;
      } else {
        try {
          SettingsController settingsController = Get.find<SettingsController>();

          if (settingsController.employee == null ||
              settingsController.employee!.email == null ||
              settingsController.employee!.email!.isEmpty) {
            return;
          }

          email = settingsController.employee!.email!.last!;
        } catch (e) {
          return;
        }
      }

      if (email == null || email.isEmpty) {
        return;
      }

      String topicName = email
          .trim()
          .toLowerCase()
          .replaceAll('@', '_at_')
          .replaceAll('.', '_dot_')
          .replaceAll('+', '_plus_')
          .replaceAll(' ', '_');

      await FirebaseMessaging.instance.unsubscribeFromTopic(topicName);

      print('✅ Unsubscribed from personal channel: $topicName');

    } catch (e) {
      print('⚠️ Failed to unsubscribe: $e');
    }
  }

  /// Unsubscribe from App channel
  static Future<void> unsubscribeFromAppChannel() async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('App');
      print('✅ Unsubscribed from App channel');
    } catch (e) {
      print('⚠️ Failed to unsubscribe from App channel: $e');
    }
  }
}
