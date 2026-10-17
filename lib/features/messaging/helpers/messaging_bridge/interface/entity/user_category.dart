/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: user_category.dart
/// Purpose: Declares `UserCategory`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/features/messaging/helpers/messaging_bridge/main_helper/localized_text_helper.dart';

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
