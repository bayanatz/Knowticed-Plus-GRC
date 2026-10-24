/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: specific_group_chat_interface_parameters.dart
/// Purpose: Declares `SpecificGroupChatInterfaceParameters`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/base_messaging_interface_parameters.dart';

class SpecificGroupChatInterfaceParameters
    extends BaseMessagingInterfaceParameters {
  String groupId;

  SpecificGroupChatInterfaceParameters(
      {required super.primaryLanguageName,
      required super.secondaryLanguageName,
      required super.primaryLanguageSubInfo,
      required super.secondaryLanguageSubInfo,
      required super.imageUri,
      required super.userId,
      required super.phone,
      required super.userCategory,
      required this.groupId});
}
