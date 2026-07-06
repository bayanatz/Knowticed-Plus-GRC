/// Module: Core · Helper · Main Helper · Locale Helper
/// Description: Shared helper for reading the active UI locale from
///              BuildContext instead of computing it inline with
///              Get.locale.toString().contains('en') (§13 anti-pattern).
/// Author: Knowticed Team
/// Date: 01/07/2026
/// Dependencies: flutter/widgets.dart
/// Revision History:
///   - 01/07/2026: Initial creation to replace inline isEnglish computations
///       across the settings feature.
library;

import 'package:flutter/widgets.dart';

///*************************** FILE INFO ****************************///
/// File Name: locale_helper.dart
/// Purpose: bool helper reading the resolved locale from BuildContext.
/// Author: Knowticed Team
/// Created At: 01/07/2026

/// Returns true when the widget tree's resolved locale is English.
/// Prefer this over `Get.locale.toString().contains('en')`, which reads a
/// global instead of the localization actually applied to [context].
bool isEnglishLocale(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'en';
