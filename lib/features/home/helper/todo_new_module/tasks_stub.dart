// ============================================================================
// Tasks module stub
// ----------------------------------------------------------------------------
// The real "tasks_module" was removed from this (demo) copy of the app.
// This file re-declares ONLY the classes/members that the kept home widgets
// (my_todo.dart, todo_status.dart, to_check_box.dart) still reference, so the
// project compiles WITHOUT copying the real module from the master app.
//
// All data is empty and all actions are no-ops:
//   - getAllTasks() returns an empty stream, so the To-Do cards show 0 / no
//     items instead of crashing,
//   - ToDoListScreen shows the neutral "not available" placeholder.
//
// `current` fields are typed `dynamic` on purpose: the kept code compares them
// against both enum values (TaskStatus.done) and plain strings ('done'), so a
// single dynamic type satisfies every call site.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:demo_app/features/home/core_widgets/removed_module_placeholder.dart';

enum TaskStatus { deleted, done, scheduled, none }

enum TaskPriority { high, medium, low, none }

// A removed "field with history" wrapper. Only `.current` is read.
class TaskFieldHistory {
  final dynamic current;
  const TaskFieldHistory({this.current});
}

// Scheduling info; only `.taskStartDate` is read (guarded by a null check).
class TaskScheduled {
  final DateTime taskStartDate;
  TaskScheduled({DateTime? taskStartDate})
      : taskStartDate = taskStartDate ?? DateTime.now();
}

// A checklist item; only `.itemStatus` is read.
class TaskChecklistItem {
  final dynamic itemStatus;
  const TaskChecklistItem({this.itemStatus});
}

// Stub: TaskModel — every member the home widgets touch, all empty/null.
class TaskModel {
  final TaskFieldHistory taskStatus = const TaskFieldHistory();
  final TaskFieldHistory priority = const TaskFieldHistory();
  final TaskFieldHistory name = const TaskFieldHistory();
  final TaskScheduled? currentScheduled = null;
  final List<TaskChecklistItem>? currentItems = null;

  TaskModel();
}

// Stub: TaskFirebaseService — empty stream, inert actions.
class TaskFirebaseService {
  Stream<List<TaskModel>> getAllTasks() =>
      Stream<List<TaskModel>>.value(<TaskModel>[]);

  bool isTaskOverdue(TaskModel task, DateTime now) => false;

  void updateTaskStatusUi(TaskModel task) {}
}

// Stub: ToDoListScreen — opened from the To-Do "View" button.
class ToDoListScreen extends StatelessWidget {
  const ToDoListScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      RemovedModulePage(moduleName: 'To-Do List'.tr);
}

// Stub: TaskDetailsTabletScreen — opened from a board card (tablet).
class TaskDetailsTabletScreen extends StatelessWidget {
  final dynamic currentCard;
  final dynamic cards;
  final dynamic boardModel;
  final dynamic projectName;
  final dynamic listName;
  final dynamic department;

  const TaskDetailsTabletScreen({
    super.key,
    this.currentCard,
    this.cards,
    this.boardModel,
    this.projectName,
    this.listName,
    this.department,
  });

  @override
  Widget build(BuildContext context) =>
      RemovedModulePage(moduleName: 'Tasks'.tr);
}

// Stub: TaskDetailsMobile — opened from a board card (mobile).
class TaskDetailsMobile extends StatelessWidget {
  final dynamic department;
  final dynamic board;
  final dynamic cardModel;
  final dynamic boardModel;
  final dynamic cards;

  const TaskDetailsMobile({
    super.key,
    this.department,
    this.board,
    this.cardModel,
    this.boardModel,
    this.cards,
  });

  @override
  Widget build(BuildContext context) =>
      RemovedModulePage(moduleName: 'Tasks'.tr);
}
