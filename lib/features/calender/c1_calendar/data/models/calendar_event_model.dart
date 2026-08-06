import 'dart:ui';
import '../../domain/enums/calendar_event_type.dart';
import 'package:grc_module/core/enums/template_variable.dart';

/// Consolidated here from data/data_source/calendar_event_model.dart, which was
/// a near-duplicate of this file. The data_source copy was the live one (4
/// importers) and carried two extra optional fields ([requestId], [userEmail])
/// that this copy lacked, so that richer version was kept and moved into the
/// models layer where it belongs.
///
/// One *occurrence* on the calendar. The *kind* of occurrence is
/// [CalendarEventType] (see domain/enums/) — set [type] via
/// [CalendarEventModel.fromType] so the title, module and reminder offset
/// come from the spec enums instead of literals. [type] is nullable while
/// calendar_data_service is migrated module by module.

class CalendarEventModel {
  final DateTime date;
  final Color color;
  final String moduleName;
  final String taskName;
  final String time;
  final String description;
  final String status;
  final String? requestId;
  final String? userEmail;

  /// Which catalog entry produced this occurrence. Null for builders that
  /// have not been migrated onto the enums yet.
  final CalendarEventType? type;

  CalendarEventModel({
    required this.date,
    required this.color,
    required this.moduleName,
    required this.taskName,
    required this.time,
    required this.description,
    required this.status,
    this.requestId,
    this.userEmail,
    this.type,
  });

  /// Build an occurrence from a catalog entry. [sourceDate] is the date the
  /// spec hangs the entry off (publish date, SLA deadline, access start
  /// date, ...); the reminder offset is applied automatically, so the
  /// 14-day-ahead reminders need no date arithmetic at the call site.
  ///
  /// Title, description, status code and colour all come from the enum —
  /// a builder should not pass literals for any of them. [taskName] is the
  /// one thing the enum cannot know: the name of the specific record (the
  /// service, document or task), so it is passed in and falls back to the
  /// entry title.
  ///
  /// [variables] fills the `{{placeholders}}` in the description.
  factory CalendarEventModel.fromType(
    CalendarEventType type, {
    required DateTime sourceDate,
    required bool isArabic,
    String? taskName,
    Map<TemplateVariable, String> variables = const {},
    String time = '',
    Color? color,
    String? moduleName,
    String? requestId,
    String? userEmail,
  }) {
    assert(
      variables.keys.toSet().containsAll(type.variables),
      'Missing placeholders for ${type.id}: '
      '${type.variables.difference(variables.keys.toSet())}',
    );
    return CalendarEventModel(
      date: type.dateFor(sourceDate),
      color: color ?? type.color,
      moduleName: moduleName ?? type.module.labelEn,
      taskName: taskName ?? type.title(isArabic: isArabic),
      time: time,
      description: type.description(isArabic: isArabic, variables: variables),
      status: type.status,
      requestId: requestId,
      userEmail: userEmail,
      type: type,
    );
  }

  /// Stable id of the underlying catalog entry, used to find and reschedule
  /// an existing calendar entry instead of creating a duplicate.
  String? get typeId => type?.id;

  // Convert to map for calendar widget
  Map<String, dynamic> toCalendarEvent() {
    return {
      'date': date,
      'color': color,
    };
  }
}
