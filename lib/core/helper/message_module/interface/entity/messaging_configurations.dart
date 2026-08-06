import 'package:grc_module/core/helper/message_module/interface/entity/user_preferred_color.dart';
import 'dart:ui';

import 'package:grc_module/core/theme/app_theme.dart';

class MessagingConfigurations {
  UserPreferredColor scaffoldBackgroundColor;
  UserPreferredColor primaryColor;
  UserPreferredColor secondaryColor;
  bool Function() isSecondaryLanguage;
  void Function(Color primaryColor, Color secondaryColor, bool isDarkMode)
      initTheme = AppTheme.interfaceInitTheme;
  void Function() toggleTheme = AppTheme.interfaceToggleTheme;
  void Function(Color primaryColor, Color secondaryColor) updateBrandingColors =
      AppTheme.interfaceUpdateBrandingColors;
  String Function() baseUri;
  bool createGroup;
  bool seenAndUnseen;
  bool editMessage;
  bool deleteMessage;
  bool reactions;
  bool forwardMessages;
  bool contact;
  bool location;
  bool photo;
  bool documents;
  bool poll;
  bool muteNotifications;
  bool disappearingMessages;
  bool scheduleMessages;
  Function({
    required List<String> targetAudienceIds,
    required String englishBody,
    required String englishTitle,
    required String arabicBody,
    required String arabicTitle,
    required Map<String, String> payload,
  }) sendNotification;
  MessagingConfigurations(
      {required this.scaffoldBackgroundColor,
        required this.primaryColor,
        required this.secondaryColor,
        required this.isSecondaryLanguage,
        required this.sendNotification,
        required this.baseUri,
        this.createGroup = true,
        this.seenAndUnseen = true,
        this.editMessage = true,
        this.deleteMessage = true,
        this.reactions = true,
        this.forwardMessages = true,
        this.contact = true,
        this.location = true,
        this.photo = true,
        this.documents = true,
        this.poll = true,
        this.muteNotifications = true,
        this.disappearingMessages = true,
        this.scheduleMessages = true}) {
    // ✅ This will print the FULL stack trace showing exactly
    // where MessagingConfigurations is being created
    print("🔧 MessagingConfigurations created");
    print("🔧 photo: $photo | documents: $documents");
    try {
      throw Exception("stack trace finder");
    } catch (e, s) {
      print("📍 Created from:\n$s");
    }
  }
}
