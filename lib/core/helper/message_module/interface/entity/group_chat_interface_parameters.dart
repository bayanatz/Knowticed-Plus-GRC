
import './base_messaging_interface_parameters.dart';
import './user_category.dart';

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
      required this.categories
      });
}