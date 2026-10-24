/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: text_in_language.dart
/// Description: Reads a translation key in a FIXED language, for form chrome
///              that follows the form's content language, not the app's.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/generated/intl/messages_all.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [textInLanguage]
///
/// Purpose: Some form chrome is deliberately in one language whatever the
/// app language is — the Arabic-title field is always labelled in Arabic,
/// the English one in English. That text still lives in the translation
/// files; this reads it in [languageCode] instead of the app language.
///
/// Parameters:
/// - [languageCode]: 'ar' or 'en'.
/// - [pick]: which key to read, e.g. `(s) => s.textHere`.
///
/// Returns: the text of that key in [languageCode].
String textInLanguage(String languageCode, String Function(S s) pick) {
  // Synchronous for this app (the generated loaders are SynchronousFutures):
  // makes sure that language's table is registered before it is read.
  initializeMessages(languageCode);
  return Intl.withLocale(languageCode, () => pick(S.current));
}

/// [textInLanguage] for 'ar' when [arabic] is true, else for 'en'.
String textInFormLanguage(bool arabic, String Function(S s) pick) =>
    textInLanguage(arabic ? 'ar' : 'en', pick);
