/// ************************* FILE INFO ************************* ///
/// File Name: calendar_event_source.dart
/// Purpose: Contract + registry that lets EACH MODULE own its calendar
///          events independently, instead of everything living inside
///          the 3000+ line CalendarDataService.
///
/// How it works:
///   1. Each module implements [CalendarEventSource] in its own folder
///      (e.g. lib/features/<module>/calendar/<module>_calendar_source.dart).
///   2. The module registers itself once at startup:
///        CalendarSourceRegistry.register(ServicesCalendarSource());
///   3. The calendar page calls CalendarSourceRegistry.getAllEvents(...)
///      and gets every module's events — without knowing any module.
///
/// Migration note: existing per-module methods inside CalendarDataService
/// (getServicesCalendarEvents, getTodoCalendarEvents, ...) can be moved
/// into their module's source one at a time — the adapter can simply
/// delegate to the old method until the code is moved.

import 'package:flutter/foundation.dart';
import 'package:grc_module/features/calender/c1_calendar/data/models/calendar_event_model.dart';

/// Implemented by each module that shows entries on the calendar.
abstract class CalendarEventSource {
  /// Module name shown on calendar entries (CalendarEventModel.moduleName).
  String get moduleName;

  /// Return this module's calendar events for the given user.
  Future<List<CalendarEventModel>> getEvents({
    required String currentUserEmail,
  });
}

/// Central registry. Modules register their source once (e.g. in main()
/// or the module's dependency injection setup).
class CalendarSourceRegistry {
  CalendarSourceRegistry._();

  static final List<CalendarEventSource> _sources = [];

  static void register(CalendarEventSource source) {
    if (_sources.any((s) => s.moduleName == source.moduleName)) return;
    _sources.add(source);
  }

  static List<CalendarEventSource> get sources => List.unmodifiable(_sources);

  /// Fetch events from every registered module. One failing module
  /// never blocks the others.
  static Future<List<CalendarEventModel>> getAllEvents({
    required String currentUserEmail,
  }) async {
    final results = await Future.wait(
      _sources.map((s) async {
        try {
          return await s.getEvents(currentUserEmail: currentUserEmail);
        } catch (e) {
          debugPrint('❌ Calendar source ${s.moduleName} failed: $e');
          return <CalendarEventModel>[];
        }
      }),
    );
    return results.expand((e) => e).toList();
  }
}
