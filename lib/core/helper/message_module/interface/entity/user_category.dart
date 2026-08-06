import 'package:grc_module/core/helper/message_module/main_helper/localized_text_helper.dart';

class UserCategory {
  String primaryLanguageName;
  String? secondaryLanguageName;
  String categoryId;

  UserCategory(
      {required this.primaryLanguageName,
      required this.secondaryLanguageName,
      required this.categoryId});

  String get name {
    return LocalizedTextHelper.formatString(
        secondaryLanguageText: secondaryLanguageName,
        primaryLanguageText: primaryLanguageName);
  }
}
