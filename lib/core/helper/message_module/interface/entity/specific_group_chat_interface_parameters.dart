import './base_messaging_interface_parameters.dart';

class SpecificGroupChatInterfaceParameters extends BaseMessagingInterfaceParameters {
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
      required this.groupId
      });
}
