/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: base_messaging_interface_parameters.dart
/// Purpose: Declares `BaseMessagingInterfaceParameters`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/features/messaging/helpers/messaging_bridge/main_helper/localized_text_helper.dart';
import 'package:grc_module/features/messaging/helpers/messaging_bridge/interface/entity/user_category.dart';

class BaseMessagingInterfaceParameters {
  String primaryLanguageName;
  String? secondaryLanguageName;
  String? primaryLanguageSubInfo;
  String? secondaryLanguageSubInfo;
  String
      imageUri; // image may be link for user or user avatar or user profile image
  String userId;
  String? phone;
  UserCategory? userCategory;

  BaseMessagingInterfaceParameters(
      {required this.primaryLanguageName,
      required this.secondaryLanguageName,
      required this.primaryLanguageSubInfo,
      required this.secondaryLanguageSubInfo,
      required this.imageUri,
      required this.userId,
      required this.phone,
      required this.userCategory});

  String get fullName {
    return LocalizedTextHelper.formatString(
        secondaryLanguageText: secondaryLanguageName,
        primaryLanguageText: primaryLanguageName);
  }

  String get subInfo {
    return LocalizedTextHelper.formatString(
      secondaryLanguageText: secondaryLanguageSubInfo,
      primaryLanguageText: primaryLanguageSubInfo ?? '',
    );
  }

  String get departmentName {
    return LocalizedTextHelper.formatString(
      secondaryLanguageText: userCategory!.primaryLanguageName,
      primaryLanguageText: userCategory!.secondaryLanguageName ?? '',
    );
  }
}
