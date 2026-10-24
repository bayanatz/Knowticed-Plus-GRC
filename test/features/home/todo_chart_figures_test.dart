import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/services/todo_chart_figures.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_chart_live.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_chart_values.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';

TodoEntity _t(
  String id, {
  TodoPriority priority = TodoPriority.medium,
  bool done = false,
  DateTime? completed,
  bool deleted = false,
  DateTime? end,
  bool scheduled = false,
  DateTime? start,
}) =>
    TodoEntity(
      id: id,
      ownerEmail: 'a@b.c',
      name: id,
      priority: priority,
      isDone: done,
      completedAt: completed,
      isDeleted: deleted,
      endAt: end,
      isScheduled: scheduled,
      startAt: start,
    );

void main() {
  final DateTime now = DateTime(2026, 10, 24, 12);

  test('counts follow the To-Do tabs and ignore deleted to-dos', () {
    final Map<String, List<double>> f = todoChartFigures(<TodoEntity>[
      _t('done1', done: true, completed: DateTime(2026, 10, 2)),
      _t('done2', done: true, completed: DateTime(2026, 9, 5)),
      _t('late', end: DateTime(2026, 10, 1), priority: TodoPriority.high),
      _t('open', priority: TodoPriority.low),
      _t('soon',
          scheduled: true,
          start: DateTime(2026, 11, 1),
          priority: TodoPriority.high),
      _t('gone', deleted: true, priority: TodoPriority.high),
    ], now);
    expect(f['tasks_by_status'], <double>[2, 1, 1, 1]);
    expect(f['tasks_by_priority'], <double>[2, 2, 1]);
    // Oct = last slot, Sep = the one before it; oldest first.
    expect(f['tasks_done_per_month'], <double>[0, 0, 0, 0, 1, 1]);
  });

  test('the catalog hands out the live figures once published', () {
    HomeChartLive.instance.publish(
        'todo',
        todoChartFigures(<TodoEntity>[
          _t('a', done: true, completed: DateTime(2026, 10, 2)),
        ], now));
    final HomeChartValue v = HomeChartCatalog.find('todo', 'tasks_by_status')!;
    expect(v.series.map((HomeChartSeries s) => s.sample), <double>[1, 0, 0, 0]);
    HomeChartLive.instance.clear();
    final HomeChartValue sample =
        HomeChartCatalog.find('todo', 'tasks_by_status')!;
    expect(sample.series.first.sample, 20);
    expect(
        HomeChartCatalog.valuesFor('todo', HomeComponents.lineChart)
            .every((HomeChartValue x) => x.trend),
        isTrue);
  });
}
