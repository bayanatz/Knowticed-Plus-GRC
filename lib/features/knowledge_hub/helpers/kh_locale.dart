/// Module: knowledge_hub/data/utils
///
///*************************** FILE INFO ****************************///
/// File Name: kh_locale.dart
/// Description: `KhLocale` — the ONE place the Knowledge Hub decides between a
///              record's English and Arabic fields.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

/// Rule Bug 10 — "replace the manual isArabic / language-code checks".
///
/// Interface text comes from the translation files (S.of(context)). But some
/// text is DATA stored in both languages on the record itself (a document's
/// name, a department's name); the translation files cannot hold it, so the
/// app has to pick a field. That choice used to be re-written, slightly
/// differently, in 16 places (one even fell back to the wrong field). It is
/// now made only here.
class KhLocale {
  const KhLocale._();

  /// Whether the UI is currently in Arabic.
  static bool isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  static bool isEnglish(BuildContext context) => !isArabic(context);

  /// Runs [build] with the translation lookup pinned to the UI language.
  ///
  /// KH vertical report p.8. The generated `S` getters do
  /// not read the language from [context]: `Intl.message` uses the GLOBAL
  /// `Intl` locale, which whatever last called `S.load` (or ran inside
  /// `Intl.withLocale`) decides. Approving / rejecting sends a notification
  /// rendered in both languages, and afterwards the success dialog came out in
  /// English inside the Arabic UI. Building a widget's strings through this
  /// makes them follow the UI language whatever the global locale is.
  static T inUiLanguage<T>(BuildContext context, T Function() build) =>
      Intl.withLocale<T>(Localizations.localeOf(context).toString(), build)
          as T;

  /// Same as [isArabic], for code with no BuildContext (cubits, services).
  static bool get isArabicNow => Intl.getCurrentLocale().startsWith('ar');

  /// [en] and [ar] in reading order: the UI language's own version first
  /// (e.g. the two name fields of the create form).
  static List<T> uiLanguageFirst<T>(
    BuildContext context, {
    required T en,
    required T ar,
  }) => isArabic(context) ? <T>[ar, en] : <T>[en, ar];

  /// The field for the current language, falling back to English when the
  /// Arabic one is empty.
  static String pick(
    BuildContext context, {
    required String en,
    required String ar,
  }) => isArabic(context) && ar.isNotEmpty ? ar : en;

  /// [departmentName] (English or Arabic, as stored on a record) in the UI
  /// language, or the name as given when the department is not known.
  /// Plain map lookups — cannot throw, so callers need no try/catch.
  static String department(BuildContext context, String departmentName) {
    if (departmentName.isEmpty ||
        !Get.isRegistered<MainCoreDepartmentCubit>()) {
      return departmentName;
    }
    final MainCoreDepartmentCubit departments =
        Get.find<MainCoreDepartmentCubit>();
    final String? id = departments.getDepartmentIdFromDepartmentName(
      departmentName: departmentName,
    );
    if (id == null) return departmentName;
    final String? localized = isArabic(context)
        ? departments.getArabicDepartmentNameFromDepartmentId(departmentId: id)
        : departments.getEnglishDepartmentNameFromDepartmentId(
            departmentId: id,
          );
    return (localized == null || localized.isEmpty)
        ? departmentName
        : localized;
  }

  /// [date] formatted with [pattern] in the UI language — the locale gives
  /// the digits, month names and AM/PM marks, so no hand-made conversion.
  static String formatDate(
    BuildContext context,
    DateTime date,
    String pattern,
  ) => DateFormat(
    pattern,
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);

  /// Same as [formatDate], for code with no BuildContext.
  static String formatDateNow(DateTime date, String pattern) =>
      DateFormat(pattern, Intl.getCurrentLocale()).format(date);

  /// A stored time — ISO text or epoch millis — or null when it cannot be
  /// read. Older records were saved with Arabic-Indic digits, so those are
  /// read as their Western values first (this is reading old data, not
  /// formatting; new records are always saved with Western digits).
  static DateTime? parseStoredTime(String raw) {
    if (raw.trim().isEmpty) return null;
    final String text = String.fromCharCodes(
      raw.trim().runes.map((int r) {
        if (r >= 0x0660 && r <= 0x0669) return r - 0x0660 + 0x30; // ٠-٩
        if (r >= 0x06F0 && r <= 0x06F9) return r - 0x06F0 + 0x30; // ۰-۹
        return r;
      }),
    );
    final DateTime? parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed;
    final int? millis = int.tryParse(text);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// [value] with Western digits in both languages (D-145).
  static String digits(BuildContext context, Object value) =>
      localizeDigits('$value', isArabic(context));

  /// [value] with Western digits (D-145, 17/10/2026: numbers are always
  /// Western, in Arabic too). [arabic] is kept for the callers; any
  /// Arabic-Indic digit is turned Western.
  static String localizeDigits(String value, bool arabic) =>
      String.fromCharCodes(
        value.runes.map(
          (int r) => (r >= 0x0660 && r <= 0x0669) ? r - 0x0660 + 0x30 : r,
        ),
      );
}
