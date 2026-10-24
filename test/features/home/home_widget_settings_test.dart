/// Module: test / home / h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_widget_settings_test.dart
/// Purpose: D-242 — the rules behind the home widget settings gear:
///          settings travel with the placed copy (model round-trip), only
///          changed values are stored, Save validates units and limits, the
///          period windows are right, and the To-Do cards read their settings.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
library;

import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_widget_settings_schema.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_widget_settings_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/todo_home_cubit.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/generated/l10n.dart';

HomeWidgetSettingsCubit _cubit(HomeComponents c,
        [Map<String, dynamic> stored = const <String, dynamic>{}]) =>
    HomeWidgetSettingsCubit(
        schema: HomeWidgetSettingsSchema.of(c)!, stored: stored);

TodoEntity _todo(String id,
        {TodoPriority priority = TodoPriority.medium,
        bool done = false,
        DateTime? end,
        DateTime? created}) =>
    TodoEntity(
      id: id,
      ownerEmail: 'a@b.c',
      name: id,
      priority: priority,
      isDone: done,
      endAt: end,
      createdAt: created,
    );

void main() {
  late S en;
  setUpAll(() async {
    en = await S.load(const Locale('en'));
  });

  group('HomeComponentModel keeps settings with the placed copy', () {
    test('round-trips through the Firestore map', () {
      const HomeComponentModel model = HomeComponentModel(
        component: HomeComponents.serviceStatus,
        rowNumber: 2,
        columnNumber: 3,
        settings: <String, dynamic>{'Period': 'this_month', 'Scope': 'mine'},
      );
      final HomeComponentModel back = HomeComponentModel.fromMap(model.toMap());
      expect(back.settings, model.settings);
      expect(back.rowNumber, 2);
      expect(back.columnNumber, 3);
    });

    test('an untouched widget stores nothing extra', () {
      final Map<String, dynamic> map = const HomeComponentModel(
        component: HomeComponents.myServices,
        rowNumber: 1,
        columnNumber: 1,
      ).toMap();
      expect(map.containsKey(HomeComponentModel.settingsKey), isFalse);
    });

    test('a layout saved before settings existed still loads', () {
      final HomeComponentModel old =
          HomeComponentModel.fromMap(<String, dynamic>{
        'Component': 'My_Services',
        'Row_Number': 1,
        'Column_Number': 2
      });
      expect(old.settings, isEmpty);
    });

    test('copyWith keeps the settings when a widget moves', () {
      const HomeComponentModel model = HomeComponentModel(
        component: HomeComponents.myServices,
        rowNumber: 1,
        columnNumber: 1,
        settings: <String, dynamic>{'Scope': 'mine'},
      );
      final HomeComponentModel moved =
          model.copyWith(rowNumber: 2, columnNumber: 4);
      expect(moved.settings, model.settings);
    });
  });

  group('Save checks units and limits', () {
    test('warn percent outside 1–100 is refused with the field named', () {
      final HomeWidgetSettingsCubit cubit =
          _cubit(HomeComponents.nearBreachedSLA);
      cubit.set(HomeSettingKey.warnPercent, '140');
      expect(cubit.validate(en), isFalse);
      expect(cubit.state.errors[HomeSettingKey.warnPercent],
          'Enter a number from 1 to 100.');
    });

    test('empty and non-numeric text are refused', () {
      final HomeWidgetSettingsCubit cubit =
          _cubit(HomeComponents.nearBreachedSLA);
      cubit.set(HomeSettingKey.warnPercent, '');
      expect(cubit.validate(en), isFalse);
      cubit.set(HomeSettingKey.warnPercent, '8x');
      expect(cubit.validate(en), isFalse);
    });

    test('rows outside the card limit are refused', () {
      final HomeWidgetSettingsCubit cubit = _cubit(HomeComponents.myTodoBox);
      cubit.set(HomeSettingKey.rows, '7');
      expect(cubit.validate(en), isFalse);
      cubit.set(HomeSettingKey.rows, '6');
      expect(cubit.validate(en), isTrue);
    });

    test('at least one button stays on', () {
      final HomeWidgetSettingsCubit cubit =
          _cubit(HomeComponents.serviceActions);
      for (final String b in <String>[
        'create_service',
        'my_requests',
        'view_approval'
      ]) {
        cubit.toggleOption(HomeSettingKey.buttons, b);
      }
      expect(cubit.validate(en), isFalse);
      expect(cubit.state.errors[HomeSettingKey.buttons], 'Pick at least 1.');
    });

    test('Services Status keeps at least two statuses', () {
      final HomeWidgetSettingsCubit cubit =
          _cubit(HomeComponents.serviceStatus);
      cubit.set(HomeSettingKey.statuses, <String>['done']);
      expect(cubit.validate(en), isFalse);
      cubit.set(HomeSettingKey.statuses, <String>['done', 'cancel']);
      expect(cubit.validate(en), isTrue);
    });

    test('custom period needs both dates, the end not before the start', () {
      final HomeWidgetSettingsCubit cubit = _cubit(HomeComponents.myServices);
      cubit.set(HomeSettingKey.period, 'custom');
      expect(cubit.validate(en), isFalse);
      expect(cubit.state.errors.keys,
          containsAll(<String>['Period_From', 'Period_To']));
      cubit.set(
          HomeSettingKey.periodFrom, DateTime(2026, 10, 10).toIso8601String());
      cubit.set(
          HomeSettingKey.periodTo, DateTime(2026, 10, 1).toIso8601String());
      expect(cubit.validate(en), isFalse);
      expect(cubit.state.errors['Period_To'],
          'The end date must be after the start date.');
      cubit.set(
          HomeSettingKey.periodTo, DateTime(2026, 10, 20).toIso8601String());
      expect(cubit.validate(en), isTrue);
    });
  });

  group('Only changed values are stored', () {
    test('untouched dialog saves an empty map', () {
      final HomeWidgetSettingsCubit cubit =
          _cubit(HomeComponents.serviceStatus);
      expect(cubit.validate(en), isTrue);
      expect(cubit.result(), isEmpty);
    });

    test('a changed value is stored, a reverted one is dropped', () {
      final HomeWidgetSettingsCubit cubit = _cubit(HomeComponents.myServices);
      cubit.set(HomeSettingKey.scope, 'mine');
      expect(cubit.result(), <String, dynamic>{'Scope': 'mine'});
      cubit.set(HomeSettingKey.scope, 'all');
      expect(cubit.result(), isEmpty);
    });

    test('Near Breached SLA defaults are 80 %, breached included, 2 rows', () {
      final HomeWidgetSettingsCubit cubit =
          _cubit(HomeComponents.nearBreachedSLA);
      expect(cubit.state.values[HomeSettingKey.warnPercent], '80');
      expect(cubit.state.values[HomeSettingKey.includeBreached], true);
      expect(cubit.state.values[HomeSettingKey.rows], '2');
    });

    test('stored values come back into the dialog', () {
      final HomeWidgetSettingsCubit cubit = _cubit(
          HomeComponents.nearBreachedSLA,
          <String, dynamic>{'Warn_Percent': 60, 'Include_Breached': false});
      expect(cubit.state.values[HomeSettingKey.warnPercent], '60');
      expect(cubit.state.values[HomeSettingKey.includeBreached], false);
      cubit.set(HomeSettingKey.warnPercent, '60');
      expect(cubit.result(),
          <String, dynamic>{'Warn_Percent': 60, 'Include_Breached': false});
    });
  });

  group('Period windows', () {
    final DateTime wed = DateTime(2026, 10, 21, 15, 30); // a Wednesday

    HomeDateWindow w(String period) =>
        HomeWidgetSettings(<String, dynamic>{'Period': period}).window(wed);

    test('all time has no limit', () {
      expect(HomeWidgetSettings.empty.window(wed).contains(DateTime(2001)),
          isTrue);
    });

    test('today / this week (Monday start) / this month / this year', () {
      expect(w('today').contains(DateTime(2026, 10, 21, 0, 1)), isTrue);
      expect(w('today').contains(DateTime(2026, 10, 20, 23, 59)), isFalse);
      expect(w('this_week').contains(DateTime(2026, 10, 19)), isTrue);
      expect(w('this_week').contains(DateTime(2026, 10, 18, 23)), isFalse);
      expect(w('this_month').contains(DateTime(2026, 10, 1)), isTrue);
      expect(w('this_month').contains(DateTime(2026, 9, 30)), isFalse);
      expect(w('this_year').contains(DateTime(2026, 1, 1)), isTrue);
      expect(w('this_year').contains(DateTime(2025, 12, 31)), isFalse);
    });

    test('last 30 days includes today and 29 days back', () {
      expect(w('last_30_days').contains(DateTime(2026, 9, 22)), isTrue);
      expect(w('last_30_days').contains(DateTime(2026, 9, 21)), isFalse);
    });

    test('custom range covers the whole end day', () {
      final HomeDateWindow range = HomeWidgetSettings(<String, dynamic>{
        'Period': 'custom',
        'Period_From': DateTime(2026, 10, 5).toIso8601String(),
        'Period_To': DateTime(2026, 10, 7).toIso8601String(),
      }).window(wed);
      expect(range.contains(DateTime(2026, 10, 7, 23, 59)), isTrue);
      expect(range.contains(DateTime(2026, 10, 8)), isFalse);
      expect(range.contains(DateTime(2026, 10, 4, 23, 59)), isFalse);
    });
  });

  group('To-Do cards read their settings', () {
    final DateTime now = DateTime(2026, 10, 21, 12); // Wednesday noon
    final TodoHomeState state = TodoHomeState(
      now: now,
      status: TodoHomeStatus.loaded,
      todos: <TodoEntity>[
        _todo('a',
            priority: TodoPriority.high,
            end: DateTime(2026, 10, 21, 18),
            created: DateTime(2026, 10, 1)),
        _todo('b',
            priority: TodoPriority.low,
            end: DateTime(2026, 10, 25),
            created: DateTime(2026, 10, 3)),
        _todo('c',
            priority: TodoPriority.high,
            done: true,
            end: DateTime(2026, 10, 21, 9),
            created: DateTime(2026, 10, 2)),
        _todo('d',
            priority: TodoPriority.medium, created: DateTime(2026, 10, 4)),
        _todo('e',
            priority: TodoPriority.medium,
            end: DateTime(2026, 10, 10),
            created: DateTime(2026, 10, 5)),
      ],
    );

    test('empty settings reproduce today\'s figures', () {
      expect(state.totalFor(HomeWidgetSettings.empty), 5);
      expect(
          state.countPriorityFor(TodoPriority.high, HomeWidgetSettings.empty),
          2);
      final List<TodoEntity> tasks =
          state.tasksFor(HomeWidgetSettings.empty, 4);
      expect(tasks.map((TodoEntity t) => t.id), <String>['e', 'd', 'b', 'a']);
    });

    test('the Due window narrows the counts', () {
      const HomeWidgetSettings today =
          HomeWidgetSettings(<String, dynamic>{'Due': 'today'});
      expect(state.totalFor(today), 2); // a and c are due today
      const HomeWidgetSettings week =
          HomeWidgetSettings(<String, dynamic>{'Due': 'this_week'});
      expect(state.totalFor(week), 3); // a, b (Sun 25th), c
    });

    test('open tasks only drops done ones from the priority count', () {
      const HomeWidgetSettings open =
          HomeWidgetSettings(<String, dynamic>{'Count_Only': 'open'});
      expect(state.countPriorityFor(TodoPriority.high, open), 1);
    });

    test('tasks: filter, order and row limit', () {
      List<String> ids(Map<String, dynamic> s, [int rows = 4]) => state
          .tasksFor(HomeWidgetSettings(s), rows)
          .map((TodoEntity t) => t.id)
          .toList();

      expect(ids(<String, dynamic>{'Show': 'overdue'}), <String>['e']);
      expect(ids(<String, dynamic>{'Show': 'due_today'}), <String>['a']);
      expect(ids(<String, dynamic>{'Order': 'due_date'}),
          <String>['e', 'a', 'b', 'd']);
      expect(ids(<String, dynamic>{'Order': 'priority'}),
          <String>['a', 'e', 'd', 'b']);
      expect(ids(<String, dynamic>{'Rows': 2}), hasLength(2));
    });
  });
}
