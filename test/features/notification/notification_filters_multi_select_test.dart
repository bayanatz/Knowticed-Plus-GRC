/// Module: notification / test
///
///*************************** FILE INFO ****************************///
/// File Name: notification_filters_multi_select_test.dart
/// Purpose: Pins the multi-select inbox filters (22/10/2026 — Owner): empty =
///          no filtering, OR inside one filter, AND across filters, and Time
///          as a union of ranges (Week / Month / Custom).
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_filter_row.dart';

/// Only [isKnownEmployee] is reached (no department lookups are selected),
/// so nothing touches Firebase.
class _FakeEmployees implements MainCoreEmployeeController {
  _FakeEmployees(this.known);
  final Set<String> known;

  @override
  bool isKnownEmployee(String email) => known.contains(email);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final DateTime _now = DateTime(2026, 10, 22, 12);

NotificationModelSystem _n(
  String id, {
  required String module,
  required String sender,
  required int daysAgo,
}) =>
    NotificationModelSystem.fromMap(
      <String, dynamic>{
        'title': id,
        'body': id,
        'Name_of_module': module,
        'name_of_page': '',
        'Sender_Email': sender,
        'Reciver_Email': 'me@x.com',
        'Pin': false,
        'isRead': true,
        'isClean': false,
        'timestamp':
            _now.subtract(Duration(days: daysAgo)).millisecondsSinceEpoch,
      },
      id: id,
    );

void main() {
  final _FakeEmployees employees = _FakeEmployees(<String>{'amr@x.com'});
  final List<NotificationModelSystem> all = <NotificationModelSystem>[
    _n('todo-person-2d', module: 'todo', sender: 'amr@x.com', daysAgo: 2),
    _n('todo-system-20d', module: 'todo', sender: 'system', daysAgo: 20),
    _n('grc-system-3d', module: 'grc', sender: 'system', daysAgo: 3),
    _n('kh-person-90d',
        module: 'knowledge_hub', sender: 'amr@x.com', daysAgo: 90),
  ];

  List<String> ids(NotificationFilterSelection s) => NotificationFilters.apply(
        source: all,
        employeeController: employees,
        selection: s,
        now: _now,
      ).map((NotificationModelSystem n) => n.id!).toList();

  test('nothing ticked filters nothing', () {
    expect(ids(const NotificationFilterSelection.cleared()), hasLength(4));
    expect(const NotificationFilterSelection.cleared().isFiltering, isFalse);
  });

  test('several values in one filter combine with OR', () {
    expect(
      ids(const NotificationFilterSelection(
          byType: <String>{'task_updates', 'compliance_alerts'})),
      <String>['todo-person-2d', 'todo-system-20d', 'grc-system-3d'],
    );
    expect(
      ids(const NotificationFilterSelection(
        senderType: <String>{'employee', 'system'},
      )),
      hasLength(4),
    );
  });

  test('different filters combine with AND', () {
    expect(
      ids(const NotificationFilterSelection(
        byType: <String>{'task_updates'},
        senderType: <String>{'system'},
      )),
      <String>['todo-system-20d'],
    );
  });

  test('Time is a union of ranges', () {
    expect(
      ids(const NotificationFilterSelection(time: <String>{'week'})),
      <String>['todo-person-2d', 'grc-system-3d'],
    );
    expect(
      ids(const NotificationFilterSelection(time: <String>{'week', 'month'})),
      <String>['todo-person-2d', 'todo-system-20d', 'grc-system-3d'],
    );
    // Week OR a custom range that only holds the 90-day-old one.
    expect(
      ids(NotificationFilterSelection(
        time: const <String>{'week', 'custom'},
        customFrom: _now.subtract(const Duration(days: 91)),
        customTo: _now.subtract(const Duration(days: 89)),
      )),
      <String>['todo-person-2d', 'grc-system-3d', 'kh-person-90d'],
    );
  });

  test('Custom with no range picked filters nothing', () {
    expect(
      ids(const NotificationFilterSelection(time: <String>{'custom'})),
      hasLength(4),
    );
  });
}
