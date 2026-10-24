/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_data_service_methods_4.dart
/// Description: Methods of `CalendarDataService` — split out of `calendar_data_service.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../calendar_data_service.dart';

// Split from calendar_data_service.dart to keep every file under 700 lines.

extension CalendarDataServiceMethods4 on CalendarDataService {
  /// Function Name: [getTimeTrackerCalendarEvents]
  ///
  /// Purpose: The signed-in user's Time Tracker calendar entries. ADDED
  /// 9/10/2026 (Time Tracker phase 6) — delegates to
  /// `TimeTrackerCalendarSource.load`, which reads the module's own
  /// repositories (approved leaves, pending requests, transactions, late /
  /// absent days, and for an approver the requests waiting for them). A
  /// failed read throws; `CalendarCubit._collect` records the source.
  ///
  /// Parameters:
  /// - [currentUserEmail]: the signed-in user.
  ///
  /// Returns: [Future<List<CalendarEventModel>>]
  // [module:time_tracker]
  Future<List<CalendarEventModel>> getTimeTrackerCalendarEvents({
    required String currentUserEmail,
  }) =>
      const TimeTrackerCalendarSource().load(
        currentUserEmail: currentUserEmail,
        isArabic: languageCode() == 'ar',
      );
  // [/module:time_tracker]

  /// Function Name: [getTodoCalendarEvents]
  ///
  /// Purpose: The signed-in user's To-Do calendar entries, built from the
  /// user's own To-Do folder `Modules/todo/{email}` (the
  /// module is personal; per-email layout owner-approved 7/10/2026). REWRITTEN 7/10/2026: this used to read the legacy
  /// `Creating_Task` collection, which the new module no longer writes, and
  /// built every card from literal EN/AR strings with the Knowledge Hub
  /// colour and module name 'Todo' (which no module chip matched).
  ///
  /// Every card comes from `TodoCalendarEvent` via
  /// `CalendarEventModel.fromType` — see [todoCalendarEntries] for the rules
  /// (Scheduled before the due date, Due / Overdue on it, Recurring on later
  /// occurrences). Each card's `requestId` is the to-do id, which the
  /// calendar cards use to open that to-do's details.
  ///
  /// A failed query is left to throw: `CalendarCubit._collect` records the
  /// source as failed without affecting the others.
  ///
  /// Parameters:
  /// - [currentUserEmail]: the owner whose to-dos are shown.
  ///
  /// Returns: [Future<List<CalendarEventModel>>]
  Future<List<CalendarEventModel>> getTodoCalendarEvents({
    required String currentUserEmail,
  }) async {
    final List<CalendarEventModel> events = <CalendarEventModel>[];
    final String email = currentUserEmail.trim().toLowerCase();
    // No company signed in: the base path would collapse to a top-level
    // collection, so there is nothing to read.
    if (email.isEmpty || ApiConstants.baseUri.trim().isEmpty) return events;

    // Every document in the user's own folder is theirs — no owner filter.
    final QuerySnapshot<Map<String, dynamic>> todoSnapshot = await _firestore
        .collection(getBaseUrl(TodoFirestorePaths.todosOf(email)))
        .get()
        .timeout(const Duration(seconds: 15));

    final bool isArabic = languageCode() == 'ar';
    final DateTime now = DateTime.now();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in todoSnapshot.docs) {
      final TodoEntity todo;
      try {
        todo = TodoModel.fromSnapshot(doc, ownerEmail: email);
      } on Object catch (_) {
        // One malformed document must not hide the rest of the calendar.
        continue;
      }
      events.addAll(CalendarDataService.todoCalendarEntries(
        todo,
        now: now,
        isArabic: isArabic,
        userEmail: email,
      ));
    }

    return events;
  }
}
