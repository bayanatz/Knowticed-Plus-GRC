/// ************************* FILE INFO *************************
/// File Name: calendar_catalog.dart
/// Purpose:   THE calendar registry — the counterpart of
///            NotificationCatalog. One place that knows which calendar
///            entries exist for which module.
///
/// `calendar_data_service.dart` is being migrated onto this one module at
/// a time: a builder that has been converted looks up its title, colour
/// and reminder offset here instead of hardcoding them, so the spec and
/// the code cannot drift.
///
/// Adding a calendar entry:
///   1. add the value to `<module>_module/<module>_calendar_events.dart`
///   2. use it in that module's builder — nothing else to register.

import './calendar_event_type.dart';
import './grc_module/grc_calendar_events.dart';
import './knowledge_hub_module/knowledge_hub_calendar_events.dart';
import './qiyas_module/qiyas_calendar_events.dart';
import './role_module/role_management_module/role_management_calendar_events.dart';
import './services_module/services_calendar_events.dart';
import './settings_module/settings_calendar_events.dart';
import './todo_module/todo_calendar_events.dart';
import './role_module/user_access_module/user_access_calendar_events.dart';
import 'package:grc_module/core/enums/app_module.dart';

abstract final class CalendarCatalog {
  static const Map<AppModule, List<CalendarEventType>> _registry = {
    AppModule.knowledgeHub: KnowledgeHubCalendarEvent.values,
    AppModule.services: ServicesCalendarEvent.values,
    AppModule.todo: TodoCalendarEvent.values,
    AppModule.qiyas: QiyasCalendarEvent.values,
    AppModule.grc: GrcCalendarEvent.values,
    AppModule.settings: SettingsCalendarEvent.values,
    AppModule.roleManagement: RoleManagementCalendarEvent.values,
    AppModule.userAccess: UserAccessCalendarEvent.values,
  };

  /// Modules that place entries on the calendar.
  static List<AppModule> get modules => _registry.keys.toList();

  static List<CalendarEventType> eventsOf(AppModule module) =>
      _registry[module] ?? const [];

  static List<CalendarEventType> get allEvents =>
      _registry.values.expand((e) => e).toList();

  /// Entries of one module bucketed by sub-area (`scope`).
  static Map<String, List<CalendarEventType>> scopedEventsOf(
    AppModule module,
  ) {
    final scoped = <String, List<CalendarEventType>>{};
    for (final event in eventsOf(module)) {
      scoped.putIfAbsent(event.scope, () => []).add(event);
    }
    return scoped;
  }

  /// Only the advance reminders (offset != 0) — useful for the job that
  /// materialises the 14-day-ahead entries.
  static List<CalendarEventType> get reminders =>
      allEvents.where((e) => e.reminderOffsetDays != 0).toList();

  static CalendarEventType? find({
    required AppModule module,
    required String key,
  }) {
    for (final event in eventsOf(module)) {
      if (event.key == key) return event;
    }
    return null;
  }

  static CalendarEventType? findById(String id) {
    for (final event in allEvents) {
      if (event.id == id) return event;
    }
    return null;
  }
}
