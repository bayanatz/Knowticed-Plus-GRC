import 'dart:ui';

class CalendarEvent {
  final DateTime date;
  final Color color;
  final String? taskId;
  final String? time; // e.g., "08:00"
  final String? title;
  final String? description;

  CalendarEvent({
    required this.date,
    required this.color,
    this.taskId,
    this.time,
    this.title,
    this.description,
  });
}