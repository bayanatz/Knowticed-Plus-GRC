/// Module: services / helpers
///
///*************************** FILE INFO ****************************///
/// File Name: services_text.dart
/// Purpose: The one place the services screens turn stored values into text
///          for the reader: bilingual data fields, duration units and
///          request statuses. Screens call these instead of checking the
///          language themselves.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/localized_number.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/domain/enums/service_duration_unit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Text helpers shared by every services screen.
extension ServicesText on BuildContext {
  /// Function Name: [svcIsArabic]
  ///
  /// Purpose: Whether the reader sees Arabic. Only for choosing between the
  /// two stored versions of a data field and for text direction — never to
  /// pick UI wording, which always comes from `S.of(context)`.
  ///
  /// Returns: `true` when the app is showing Arabic.
  bool get svcIsArabic =>
      Localizations.maybeLocaleOf(this)?.languageCode == 'ar';

  /// Function Name: [svcPick]
  ///
  /// Purpose: Picks the reader's version of a bilingual data field (service
  /// name, department, job title…), falling back to the other version when
  /// the reader's one is empty.
  ///
  /// Parameters:
  /// - [english]: the English value.
  /// - [arabic]: the Arabic value.
  ///
  /// Returns: the value to show, or '' when both are empty.
  String svcPick(String? english, String? arabic) {
    final en = (english ?? '').trim();
    final ar = (arabic ?? '').trim();
    if (svcIsArabic) return ar.isNotEmpty ? ar : en;
    return en.isNotEmpty ? en : ar;
  }

  /// Function Name: [svcNumber]
  ///
  /// Purpose: Writes [value] with the reader's digits.
  ///
  /// Parameters:
  /// - [value]: the number to show.
  ///
  /// Returns: the formatted number.
  String svcNumber(num value) => LocalizedNumber.of(this, value);

  /// Function Name: [svcDurationUnit]
  ///
  /// Purpose: The translated unit word for [count] items of [rawUnit], e.g.
  /// "days" / "يومين".
  ///
  /// Parameters:
  /// - [rawUnit]: the unit as stored on the service (English or Arabic).
  /// - [count]: how many units, used to choose singular, dual or plural.
  ///
  /// Returns: the unit word, or [rawUnit] unchanged when it is not a known
  /// unit.
  String svcDurationUnit(String? rawUnit, num count) {
    final unit = ServiceDurationUnit.parse(rawUnit);
    if (unit == null) return rawUnit ?? '';
    final s = S.of(this);
    final form = count == 1 ? 1 : (count == 2 ? 2 : 3);
    switch (unit) {
      case ServiceDurationUnit.second:
        return form == 1
            ? s.svcUnitSecondOne
            : (form == 2 ? s.svcUnitSecondTwo : s.svcUnitSecondMany);
      case ServiceDurationUnit.minute:
        return form == 1
            ? s.svcUnitMinuteOne
            : (form == 2 ? s.svcUnitMinuteTwo : s.svcUnitMinuteMany);
      case ServiceDurationUnit.hour:
        return form == 1
            ? s.svcUnitHourOne
            : (form == 2 ? s.svcUnitHourTwo : s.svcUnitHourMany);
      case ServiceDurationUnit.day:
        return form == 1
            ? s.svcUnitDayOne
            : (form == 2 ? s.svcUnitDayTwo : s.svcUnitDayMany);
      case ServiceDurationUnit.week:
        return form == 1
            ? s.svcUnitWeekOne
            : (form == 2 ? s.svcUnitWeekTwo : s.svcUnitWeekMany);
      case ServiceDurationUnit.month:
        return form == 1
            ? s.svcUnitMonthOne
            : (form == 2 ? s.svcUnitMonthTwo : s.svcUnitMonthMany);
      case ServiceDurationUnit.year:
        return form == 1
            ? s.svcUnitYearOne
            : (form == 2 ? s.svcUnitYearTwo : s.svcUnitYearMany);
    }
  }

  /// Function Name: [svcDuration]
  ///
  /// Purpose: A full duration such as "3 days" / "٣ أيام".
  ///
  /// Parameters:
  /// - [rawValue]: the stored number of units.
  /// - [rawUnit]: the stored unit.
  ///
  /// Returns: the duration text, or '' when there is no value.
  String svcDuration(String? rawValue, String? rawUnit) {
    final value = (rawValue ?? '').trim();
    if (value.isEmpty) return '';
    final count = num.tryParse(value);
    if (count == null) return '$value ${rawUnit ?? ''}'.trim();
    return '${svcNumber(count)} ${svcDurationUnit(rawUnit, count)}'.trim();
  }

  /// Function Name: [svcStatus]
  ///
  /// Purpose: The translated label of a stored request status
  /// (pending, approved, rejected, inprogress, done, cancel, branchsla…).
  ///
  /// Parameters:
  /// - [rawStatus]: the status as stored.
  ///
  /// Returns: the label, or [rawStatus] when it is not a known status.
  String svcStatus(String? rawStatus) {
    final s = S.of(this);
    switch ((rawStatus ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll(' ', '')) {
      case 'pending':
        return s.status_pending;
      case 'approved':
        return s.status_approved;
      case 'rejected':
        return s.status_rejected;
      case 'inprogress':
        return s.status_inprogress;
      case 'done':
      case 'completed':
        return s.status_done;
      case 'cancel':
      case 'canceled':
      case 'cancelled':
        return s.status_cancel;
      case 'branchsla':
      case 'breachedsla':
        return s.status_breached;
      case 'active':
        return s.active;
      case 'inactive':
        return s.inactive;
      default:
        return rawStatus ?? '';
    }
  }

  /// Function Name: [svcDepartmentName]
  ///
  /// Purpose: The reader's name of a department stored as an id or, on older
  /// records, as a name (either language).
  ///
  /// Parameters:
  /// - [idOrName]: the stored department.
  ///
  /// Returns: the department name, the stored value when it is unknown, or
  /// '-' when it is empty.
  String svcDepartmentName(String? idOrName) {
    final raw = (idOrName ?? '').trim();
    if (raw.isEmpty) return '-';
    final departments = this.read<MainCoreDepartmentCubit>();
    final id = departments.getEnglishDepartmentNameFromDepartmentId(
              departmentId: raw,
            ) !=
            null
        ? raw
        : departments.getDepartmentIdFromDepartmentName(departmentName: raw);
    if (id == null || id == 'none') return raw;
    final name = svcPick(
      departments.getEnglishDepartmentNameFromDepartmentId(departmentId: id),
      departments.getArabicDepartmentNameFromDepartmentId(departmentId: id),
    );
    return name.isEmpty ? raw : name;
  }

  /// Function Name: [svcMonthShort]
  ///
  /// Purpose: The short name of [month] (1–12) in the reader's language,
  /// from intl (Dashboards rule 7: no hand-written month tables).
  String svcMonthShort(int month) =>
      DateFormat.MMM(Localizations.maybeLocaleOf(this)?.languageCode)
          .format(DateTime(2000, month));

  /// Function Name: [svcMonthLong]
  ///
  /// Purpose: The full name of [month] (1–12) in the reader's language.
  String svcMonthLong(int month) =>
      DateFormat.MMMM(Localizations.maybeLocaleOf(this)?.languageCode)
          .format(DateTime(2000, month));

  /// Function Name: [svcOrdinal]
  ///
  /// Purpose: "First", "Second", … in the reader's language (rule C11/H24 —
  /// replaces the hardcoded ordinal tables that lived in the provider cubit).
  ///
  /// Parameters:
  /// - [n]: the 1-based position.
  ///
  /// Returns: the ordinal word for 1–10, otherwise "No. n" / "رقم n".
  String svcOrdinal(int n) {
    final s = S.of(this);
    switch (n) {
      case 1:
        return s.svcOrdinal1;
      case 2:
        return s.svcOrdinal2;
      case 3:
        return s.svcOrdinal3;
      case 4:
        return s.svcOrdinal4;
      case 5:
        return s.svcOrdinal5;
      case 6:
        return s.svcOrdinal6;
      case 7:
        return s.svcOrdinal7;
      case 8:
        return s.svcOrdinal8;
      case 9:
        return s.svcOrdinal9;
      case 10:
        return s.svcOrdinal10;
      default:
        return s.svcOrdinalNumber(svcNumber(n));
    }
  }
}
