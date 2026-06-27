import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/app_drawer/presentation/controller/drawer_controller.dart';

// REMOVED_MODULE: messaging_package was removed from demo_app.
// When adding the messaging module, restore the full implementation from demo_app_plus.

class MessageInterfaceConsumer {
  static Future<void> openSingleChat(
      String otherUserId, BuildContext context) async {
    // TODO: Implement when messaging module is added
    debugPrint('MessageInterfaceConsumer.openSingleChat: messaging module not present in demo_app');
  }

  static Future<void> openGroupChat(
      String groupId, BuildContext context) async {
    // TODO: Implement when messaging module is added
    debugPrint('MessageInterfaceConsumer.openGroupChat: messaging module not present in demo_app');
  }
}
