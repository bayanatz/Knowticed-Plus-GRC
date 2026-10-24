/// Module: database / db2_database_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: database_date_format.dart
/// Description: Declares `DatabaseDateFormat`.
/// Author: Amr Mesbah
/// Created at: 24/10/2026
///
/// The one date format the database screens and their CSV exports use.
library;

import 'package:intl/intl.dart';

/// "28 Nov 2025" — the one date format this whole section uses.
///
/// The Figma writes dates that way everywhere it writes them: the info card's
/// Creation and Last Edit lines, both date columns of the Access table, and
/// the exported CSV. db1 has the same formatter twice already (in
/// `access_rule_fields.dart` and in the list card), which is exactly how three
/// screens end up disagreeing about whether the month is a number — so this
/// module keeps ONE, and the CSV shares it with the table it was exported
/// from.
abstract final class DatabaseDateFormat {
  /// [placeholder] is what an absent date renders as. An em dash on screen,
  /// where a column still has to occupy its width; an empty string in a CSV,
  /// where a dash would be read as data by whatever opens the file.
  static String short(
    DateTime? date, {
    required bool isArabic,
    String placeholder = '—',
  }) {
    if (date == null) return placeholder;
    // The month name comes from intl (rule 14), not a hand-written table. The
    // day and year stay Western digits, as the screens show them.
    final String month = DateFormat.MMM(isArabic ? 'ar' : 'en').format(date);
    return '${date.day} $month ${date.year}';
  }
}
