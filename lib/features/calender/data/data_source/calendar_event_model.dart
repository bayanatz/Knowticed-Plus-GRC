import 'dart:ui';

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
  });

  // Convert to map for calendar widget
  Map<String, dynamic> toCalendarEvent() {
    return {
      'date': date,
      'color': color,
    };
  }
}