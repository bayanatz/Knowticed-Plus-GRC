/// Module: core / helper
/// File Name: content_language_scope.dart
/// Purpose: `ContentLanguageScope` — the language of the CONTENT a widget sits
///          in (a form written in Arabic inside the English app, or the
///          reverse), so shared widgets (date field, pickers) speak the
///          content's language. Moved here from Form Builder on 17/10/2026:
///          core must not import a module (module split, K-25). Form Builder
///          keeps `ContentLanguageScope` as an alias plus its own detectors.
library;

import 'package:flutter/material.dart';

class ContentLanguageScope extends InheritedWidget {
  ContentLanguageScope({
    super.key,
    required this.isArabic,
    required Widget child,
  }) : super(
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: child,
          ),
        );

  /// True when the form's content is Arabic.
  final bool isArabic;

  /// The form language when inside a [ContentLanguageScope], else null.
  static bool? maybeIsArabicOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ContentLanguageScope>()
      ?.isArabic;

  /// The form language inside a scope, the APP language outside one — so a
  /// widget can call this unconditionally and still behave as before when it
  /// is used outside a form (e.g. on a settings screen).
  static bool isArabicOf(BuildContext context) =>
      maybeIsArabicOf(context) ??
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  /// Picks the [en] or [ar] wording for the form's language.
  static String text(
    BuildContext context, {
    required String en,
    required String ar,
  }) =>
      isArabicOf(context) ? ar : en;

  static final RegExp _arabicLetter = RegExp(r'[؀-ۿ]');
  static final RegExp _latinLetter = RegExp(r'[A-Za-z]');

  /// Arabic when the texts hold more Arabic letters than Latin ones; null
  /// when they hold no letters at all (caller falls back to the app).
  static bool? detect(Iterable<String?> texts) {
    int arabic = 0;
    int latin = 0;
    for (final String? t in texts) {
      if (t == null || t.isEmpty) continue;
      arabic += _arabicLetter.allMatches(t).length;
      latin += _latinLetter.allMatches(t).length;
    }
    if (arabic == 0 && latin == 0) return null;
    return arabic > latin;
  }

  @override
  bool updateShouldNotify(ContentLanguageScope oldWidget) =>
      oldWidget.isArabic != isArabic;
}
