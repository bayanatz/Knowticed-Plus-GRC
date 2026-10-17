/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: group_chat_interface_parameters.dart
/// Purpose: Declares `GroupChatInterfaceParameters`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/features/messaging/helpers/messaging_bridge/interface/entity/base_messaging_interface_parameters.dart';
import 'package:grc_module/features/messaging/helpers/messaging_bridge/interface/entity/user_category.dart';

class GroupChatInterfaceParameters extends BaseMessagingInterfaceParameters {
  List<UserCategory>? categories;
  GroupChatInterfaceParameters(
      {required super.primaryLanguageName,
      required super.secondaryLanguageName,
      required super.primaryLanguageSubInfo,
      required super.secondaryLanguageSubInfo,
      required super.imageUri,
      required super.userId,
      required super.phone,
      required super.userCategory,
      required this.categories});
}
