import 'package:get/get.dart';

import 'package:grc_module/core/helper/message_module/interface/controller/messaging_init_controller.dart';

class ApiConstants {
  static String get baseUri {return Get.find<MessagingInitController>().messagingConfigurations.baseUri.call();}
  static String get usersConnections => "$baseUri/Connections";
  static String get lastMessage => "Last Message";
  static String get singleChatMessages => "$baseUri/Single Chat Message";
  static String get messages => "Messages";

  static String get images => "Images";

  static String get groups => "$baseUri/Messaging Groups";
  static String get memberGroups => "$baseUri/Member Groups";

  static String get groupsChat => "$baseUri/Groups Chat";
}
