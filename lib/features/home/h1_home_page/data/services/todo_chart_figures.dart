/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: todo_chart_figures.dart
/// Purpose: Declares `todoChartFigures` — the real counters behind the To-Do
///          entries of the Chart & Graph catalog, counted from the employee's
///          own to-dos with the same rules as the To-Do list's status tabs —
///          and `TodoChartLive`, which keeps them current.
/// Author: Knowticed Plus team
/// Created at: 24/10/2026
library;

import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_chart_live.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';

/// Function Name: [todoChartFigures]
///
/// Purpose: One list per catalog value, in the catalog's series order.
///   - `tasks_by_status`: Done · To Do · Overdue · Scheduled — the To-Do
///     list's own tabs ([TodoEntity.matchesTab]); deleted to-dos never count.
///   - `tasks_by_priority`: High · Medium · Low of the live to-dos.
///   - `tasks_done_per_month`: to-dos completed in each of the last six
///     months, oldest first.
Map<String, List<double>> todoChartFigures(
    List<TodoEntity> todos, DateTime now) {
  final List<TodoEntity> live =
      todos.where((TodoEntity t) => t.isLive).toList();
  double count(TodoStatusTab tab) =>
      live.where((TodoEntity t) => t.matchesTab(tab, now)).length.toDouble();
  double priority(TodoPriority p) =>
      live.where((TodoEntity t) => t.priority == p).length.toDouble();

  final List<double> perMonth = <double>[
    for (int back = 5; back >= 0; back--)
      live
          .where((TodoEntity t) {
            final DateTime? at = t.completedAt;
            if (!t.isDone || at == null) return false;
            final DateTime month = DateTime(now.year, now.month - back);
            return at.year == month.year && at.month == month.month;
          })
          .length
          .toDouble(),
  ];

  return <String, List<double>>{
    'tasks_by_status': <double>[
      count(TodoStatusTab.done),
      count(TodoStatusTab.toDo),
      count(TodoStatusTab.overdue),
      count(TodoStatusTab.scheduled),
    ],
    'tasks_by_priority': <double>[
      priority(TodoPriority.high),
      priority(TodoPriority.medium),
      priority(TodoPriority.low),
    ],
    'tasks_done_per_month': perMonth,
  };
}

/// Keeps the To-Do figures of [HomeChartLive] current while Home is open.
class TodoChartLive {
  TodoChartLive._();

  static StreamSubscription<List<TodoEntity>>? _sub;
  static String _owner = '';

  /// Start listening (once per signed-in employee). Does nothing when To-Do is
  /// not set up or the employee cannot view it.
  static void ensureStarted() {
    final GetIt sl = GetIt.instance;
    if (!sl.isRegistered<TodoBaseRepository>() ||
        !sl.isRegistered<TodoAccess>()) {
      return;
    }
    final TodoAccess access = sl<TodoAccess>();
    final String owner = access.currentUserEmail;
    if (owner.isEmpty || !access.canView) return;
    if (_sub != null && _owner == owner) return;
    _sub?.cancel();
    _owner = owner;
    _sub = sl<TodoBaseRepository>().watchTodos(ownerEmail: owner).listen(
          (List<TodoEntity> todos) => HomeChartLive.instance
              .publish('todo', todoChartFigures(todos, DateTime.now())),
          onError: (Object _) {},
        );
  }
}
