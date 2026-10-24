/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: todo_home_state.dart
/// Purpose: Declares `TodoHomeState` — the live to-dos behind the three
///          To-Do cards on the home page, plus the counts they show.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Every count goes through `TodoEntity.matchesTab` (and `priority`), the same
/// rule the To-Do list's tabs use, so a card can never disagree with the list
/// it opens.

part of 'todo_home_cubit.dart';

enum TodoHomeStatus { loading, loaded, failure, noAccess }

/// One-shot feedback for a failed checkbox tap.
enum TodoHomeActionError { noPermission, saveFailed }

@immutable
class TodoHomeState {
  const TodoHomeState({
    this.status = TodoHomeStatus.loading,
    this.todos = const <TodoEntity>[],
    required this.now,
    this.canEdit = false,
    this.actionError,
  });

  final TodoHomeStatus status;

  /// Every to-do the user owns, soft-deleted ones included.
  final List<TodoEntity> todos;

  /// The one clock all counts are taken against.
  final DateTime now;

  /// Whether the card-2 checkbox may write.
  final bool canEdit;

  /// Set after a failed toggle; cleared once the card has shown it.
  final TodoHomeActionError? actionError;

  /// Function Name: [countFor]
  ///
  /// Purpose: How many to-dos sit in [tab] — identical to the list tab count,
  /// except "All": the list's All tab now includes deleted to-dos (owner,
  /// 7/10/2026), but the home total stays "live (not deleted) to-dos".
  ///
  /// Parameters:
  ///   [TodoStatusTab] tab
  ///
  /// Return type: [int]
  int countFor(TodoStatusTab tab) => tab == TodoStatusTab.all
      ? todos.where((TodoEntity t) => t.isLive).length
      : todos.where((TodoEntity t) => t.matchesTab(tab, now)).length;

  /// Function Name: [countPriority]
  ///
  /// Purpose: How many live (not deleted) to-dos carry [priority].
  ///
  /// Parameters:
  ///   [TodoPriority] priority
  ///
  /// Return type: [int]
  int countPriority(TodoPriority priority) =>
      todos.where((TodoEntity t) => t.isLive && t.priority == priority).length;

  /// Function Name: [openTodos]
  ///
  /// Purpose: The first [limit] not-done, not-deleted to-dos, newest first —
  /// the list's default (unsorted) order.
  ///
  /// Parameters:
  ///   [int] limit
  ///
  /// Return type: [List<TodoEntity>]
  List<TodoEntity> openTodos(int limit) {
    final List<TodoEntity> open = todos
        .where((TodoEntity t) => t.isLive && !t.isDone)
        .toList()
      ..sort(_newestFirst);
    return open.take(limit).toList();
  }

  // ── Per-copy settings (D-242) ─────────────────────────────────────────────
  // Each placed card carries its own "Due" window, counts, priorities, rows,
  // filter and order; an empty settings map gives today's figures.

  /// The live to-dos whose due time falls in the card's "Due" window. A to-do
  /// without a due time only counts for "All time".
  List<TodoEntity> dueIn(HomeWidgetSettings settings) {
    final HomeDateWindow window = settings.window(now, key: HomeSettingKey.due);
    return todos
        .where(
            (TodoEntity t) => t.isLive && window.contains(t.endAt ?? t.startAt))
        .toList();
  }

  /// Total for the counts card: live to-dos due in the window.
  int totalFor(HomeWidgetSettings settings) => dueIn(settings).length;

  /// To-dos in [tab] among those due in the window.
  int countTabFor(TodoStatusTab tab, HomeWidgetSettings settings) =>
      dueIn(settings).where((TodoEntity t) => t.matchesTab(tab, now)).length;

  /// Priority counts card: "all tasks" or "open only", inside the window.
  int countPriorityFor(TodoPriority priority, HomeWidgetSettings settings) {
    final bool openOnly =
        settings.string(HomeSettingKey.countOnly, 'all') == 'open';
    return dueIn(settings)
        .where((TodoEntity t) =>
            t.priority == priority && (!openOnly || !t.isDone))
        .length;
  }

  /// The checklist card's rows: the chosen filter, the chosen order, at most
  /// the chosen number of tasks. Defaults reproduce today's list (open
  /// to-dos, newest first, 4 rows).
  List<TodoEntity> tasksFor(HomeWidgetSettings settings, int defaultRows) {
    final int rows = settings.integer(HomeSettingKey.rows, defaultRows);
    final String show = settings.string(HomeSettingKey.show, 'open');
    final String order = settings.string(HomeSettingKey.order, 'newest');
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime tomorrow = today.add(const Duration(days: 1));
    final DateTime monday =
        today.subtract(Duration(days: today.weekday - DateTime.monday));
    final DateTime nextMonday = monday.add(const Duration(days: 7));

    bool inRange(DateTime? d, DateTime from, DateTime to) =>
        d != null && !d.isBefore(from) && d.isBefore(to);

    final List<TodoEntity> list = todos.where((TodoEntity t) {
      if (!t.isLive || t.isDone) return false;
      switch (show) {
        case 'overdue':
          return t.isOverdue(now);
        case 'due_today':
          return inRange(t.endAt, today, tomorrow);
        case 'due_week':
          return inRange(t.endAt, monday, nextMonday);
        default:
          return true;
      }
    }).toList();

    switch (order) {
      case 'due_date':
        list.sort((TodoEntity a, TodoEntity b) {
          final DateTime? x = a.endAt;
          final DateTime? y = b.endAt;
          if (x == null && y == null) return _newestFirst(a, b);
          if (x == null) return 1;
          if (y == null) return -1;
          return x.compareTo(y);
        });
      case 'priority':
        list.sort((TodoEntity a, TodoEntity b) {
          final int byPriority = a.priority.index.compareTo(b.priority.index);
          return byPriority != 0 ? byPriority : _newestFirst(a, b);
        });
      default:
        list.sort(_newestFirst);
    }
    return list.take(rows).toList();
  }

  static int _newestFirst(TodoEntity a, TodoEntity b) {
    final DateTime? x = a.createdAt;
    final DateTime? y = b.createdAt;
    if (x == null && y == null) return 0;
    if (x == null) return 1;
    if (y == null) return -1;
    return y.compareTo(x);
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update; [clearActionError] drops [actionError].
  ///
  /// Return type: [TodoHomeState]
  TodoHomeState copyWith({
    TodoHomeStatus? status,
    List<TodoEntity>? todos,
    DateTime? now,
    bool? canEdit,
    TodoHomeActionError? actionError,
    bool clearActionError = false,
  }) =>
      TodoHomeState(
        status: status ?? this.status,
        todos: todos ?? this.todos,
        now: now ?? this.now,
        canEdit: canEdit ?? this.canEdit,
        actionError:
            clearActionError ? null : (actionError ?? this.actionError),
      );
}
