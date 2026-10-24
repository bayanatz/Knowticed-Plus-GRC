/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_widget_settings_cubit.dart
/// Purpose: Declares `HomeWidgetSettingsCubit` — the draft behind one open
///          widget-settings dialog: the values being edited, the check on
///          Save, and the map that is finally stored (D-242).
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// The cubit owns the rules so they are testable without a widget:
///   * every number is a whole number inside the field's limits;
///   * a multi-select keeps at least `minSelected` options;
///   * a custom period needs both dates, the end not before the start;
///   * the stored map holds ONLY what differs from the defaults — an untouched
///     widget saves an empty map and keeps behaving as it always did.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_widget_settings_schema.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HomeWidgetSettingsState {
  const HomeWidgetSettingsState({
    required this.values,
    this.errors = const <String, String>{},
  });

  /// Current draft. Numbers are kept as the raw text the user typed so a
  /// half-typed value is not rewritten under their finger.
  final Map<String, dynamic> values;

  /// Field key → message, filled by a failed Save and cleared field by field
  /// as the user fixes it.
  final Map<String, String> errors;

  HomeWidgetSettingsState copyWith({
    Map<String, dynamic>? values,
    Map<String, String>? errors,
  }) =>
      HomeWidgetSettingsState(
        values: values ?? this.values,
        errors: errors ?? this.errors,
      );
}

class HomeWidgetSettingsCubit extends Cubit<HomeWidgetSettingsState> {
  /// [stored] is what the placed copy saved earlier (may be empty).
  HomeWidgetSettingsCubit({
    required this.schema,
    required Map<String, dynamic> stored,
  }) : super(HomeWidgetSettingsState(values: _resolve(schema, stored)));

  final HomeWidgetSettingsSchema schema;

  /// Every field resolved against its default, numbers as text.
  static Map<String, dynamic> _resolve(
      HomeWidgetSettingsSchema schema, Map<String, dynamic> stored) {
    final HomeWidgetSettings reader = HomeWidgetSettings(stored);
    final Map<String, dynamic> out = <String, dynamic>{};
    for (final HomeSettingField f in schema.fields) {
      switch (f.kind) {
        case HomeSettingKind.choice:
          out[f.key] = reader.string(f.key, f.defaultString);
        case HomeSettingKind.period:
          out[f.key] = reader.string(f.key, f.defaultString);
          out[HomeSettingKey.periodFrom] =
              reader.string(HomeSettingKey.periodFrom, '');
          out[HomeSettingKey.periodTo] =
              reader.string(HomeSettingKey.periodTo, '');
        case HomeSettingKind.number:
          out[f.key] = '${reader.integer(f.key, f.defaultNumber)}';
        case HomeSettingKind.multi:
          out[f.key] = reader.list(f.key, f.defaultSelection);
        case HomeSettingKind.toggle:
          out[f.key] = reader.boolean(f.key, f.defaultBool);
        case HomeSettingKind.chartData:
          out[HomeSettingKey.chartModule] =
              reader.string(HomeSettingKey.chartModule, '');
          out[HomeSettingKey.chartValues] =
              reader.string(HomeSettingKey.chartValues, '');
          // '' = the chart's own default (6; 3 for stacked / grouped).
          out[HomeSettingKey.chartMonths] =
              reader.string(HomeSettingKey.chartMonths, '');
          out[HomeSettingKey.chartSeries] =
              reader.list(HomeSettingKey.chartSeries, const <String>[]);
      }
    }
    return out;
  }

  /// Sets a value and clears that field's error.
  void set(String key, Object? value) {
    final Map<String, dynamic> next = Map<String, dynamic>.of(state.values)
      ..[key] = value;
    final Map<String, String> errors = Map<String, String>.of(state.errors)
      ..remove(key);
    if (key == HomeSettingKey.periodFrom || key == HomeSettingKey.periodTo) {
      errors
        ..remove(HomeSettingKey.periodFrom)
        ..remove(HomeSettingKey.periodTo);
    }
    emit(state.copyWith(values: next, errors: errors));
  }

  /// Turns one option of a multi-select on or off.
  void toggleOption(String key, String option) {
    final List<String> current =
        List<String>.of((state.values[key] as List<dynamic>).cast<String>());
    if (current.contains(option)) {
      current.remove(option);
    } else {
      current.add(option);
    }
    set(key, current);
  }

  /// Function Name: [validate]
  ///
  /// Purpose: Check every field; returns true when all are valid. The
  /// messages land in [HomeWidgetSettingsState.errors].
  bool validate(S s) {
    final Map<String, String> errors = <String, String>{};
    for (final HomeSettingField f in schema.fields) {
      switch (f.kind) {
        case HomeSettingKind.number:
          final int? n = int.tryParse('${state.values[f.key]}'.trim());
          if (n == null || n < f.min || n > f.max) {
            errors[f.key] = s.hwsErrNumber('${f.min}', '${f.max}');
          }
        case HomeSettingKind.multi:
          final int picked = (state.values[f.key] as List<dynamic>).length;
          if (picked < f.minSelected) {
            errors[f.key] = s.hwsErrPickAtLeast('${f.minSelected}');
          } else if (f.maxSelected > 0 && picked > f.maxSelected) {
            errors[f.key] = s.hwsErrPickAtMost('${f.maxSelected}');
          }
        case HomeSettingKind.period:
          if (state.values[f.key] == HomeWidgetPeriod.custom.key) {
            final DateTime? from =
                DateTime.tryParse('${state.values[HomeSettingKey.periodFrom]}');
            final DateTime? to =
                DateTime.tryParse('${state.values[HomeSettingKey.periodTo]}');
            if (from == null) {
              errors[HomeSettingKey.periodFrom] = s.hwsErrPickDate;
            }
            if (to == null) {
              errors[HomeSettingKey.periodTo] = s.hwsErrPickDate;
            }
            if (from != null && to != null && to.isBefore(from)) {
              errors[HomeSettingKey.periodTo] = s.hwsErrEndBeforeStart;
            }
          }
        case HomeSettingKind.chartData:
          // A module without values cannot draw anything.
          if ('${state.values[HomeSettingKey.chartModule]}'.isNotEmpty &&
              '${state.values[HomeSettingKey.chartValues]}'.isEmpty) {
            errors[HomeSettingKey.chartValues] = s.hwsErrPickAtLeast('1');
          }
        case HomeSettingKind.choice:
        case HomeSettingKind.toggle:
          break;
      }
    }
    emit(state.copyWith(errors: errors));
    return errors.isEmpty;
  }

  /// Function Name: [result]
  ///
  /// Purpose: The map to store on the placed copy — only values that differ
  /// from the defaults. Call after [validate] returned true.
  Map<String, dynamic> result() {
    final Map<String, dynamic> out = <String, dynamic>{};
    for (final HomeSettingField f in schema.fields) {
      final Object? v = state.values[f.key];
      switch (f.kind) {
        case HomeSettingKind.choice:
          if (v != f.defaultString) out[f.key] = v;
        case HomeSettingKind.period:
          if (v != f.defaultString) out[f.key] = v;
          if (v == HomeWidgetPeriod.custom.key) {
            out[HomeSettingKey.periodFrom] =
                state.values[HomeSettingKey.periodFrom];
            out[HomeSettingKey.periodTo] =
                state.values[HomeSettingKey.periodTo];
          }
        case HomeSettingKind.number:
          final int n = int.parse('$v'.trim());
          if (n != f.defaultNumber) out[f.key] = n;
        case HomeSettingKind.multi:
          final List<String> picked = (v! as List<dynamic>).cast<String>();
          // Keep the schema's order so the stored list is canonical. Live
          // options (people, groups) are not in the schema: keep the pick
          // as made — filtering against the empty schema list dropped every
          // pick (21/10/2026).
          final List<String> ordered = f.source != HomeOptionSource.none
              ? picked
              : f.options
                  .map((HomeSettingOption o) => o.value)
                  .where(picked.contains)
                  .toList();
          final List<String> def = f.defaultSelection;
          final bool same =
              ordered.length == def.length && ordered.every(def.contains);
          if (!same) out[f.key] = ordered;
        case HomeSettingKind.toggle:
          if (v != f.defaultBool) out[f.key] = v;
        case HomeSettingKind.chartData:
          final String module = '${state.values[HomeSettingKey.chartModule]}';
          if (module.isNotEmpty) {
            out[HomeSettingKey.chartModule] = module;
            out[HomeSettingKey.chartValues] =
                state.values[HomeSettingKey.chartValues];
          }
          // The period is kept even with no module picked (it was dropped on
          // save, so the card never changed — Moataz 24/10/2026).
          final String months =
              '${state.values[HomeSettingKey.chartMonths] ?? ''}';
          if (months.isNotEmpty) out[HomeSettingKey.chartMonths] = months;
          final List<dynamic> shown =
              (state.values[HomeSettingKey.chartSeries] as List<dynamic>?) ??
                  const <dynamic>[];
          if (shown.isNotEmpty) out[HomeSettingKey.chartSeries] = shown;
      }
    }
    return out;
  }
}
