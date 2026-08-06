
import './base_messaging_interface_parameters.dart';
import './user_category.dart';

class SingleChatInterfaceParameters extends BaseMessagingInterfaceParameters {
  List<UserCategory>? categories;
  SingleChatInterfaceParameters(
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
