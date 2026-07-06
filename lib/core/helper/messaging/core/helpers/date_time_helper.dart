// Date: 28/8/2024
// By: Nada Mohammed, Youssef Ashraf
// Last update: 28/8/2024
// Objectives: This file is responsible for providing a date time helper class that is used to format date time in the app.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:demo_app/core/helper/messaging/old_files/messaging/chat/data/models/chat_enums.dart';

abstract class DateTimeHelper {
  static DateTime formatTimeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  static String formatInt(int number) {
    return NumberFormat('0', Get.locale.toString()).format(number);
  }

  static String formatTimeOfDayToString(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// ── Used in chat bubbles for WhatsApp-style date separators ──
  /// Returns: "Today", "Yesterday", or "19 Feb 2026"
  static String formatChatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(date.year, date.month, date.day);

    if (msgDay == today) return 'Today'.tr;
    if (msgDay == yesterday) return 'Yesterday'.tr;

    // ✅ Always show actual date (no "This Week" — just "19 Feb 2026")
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// ── Used in message list / conversation list sorting ──
  /// Returns: "Today", "Last Week", "March", "Last Year", etc.
  static String sortDate(DateTime dateTime) {
    // If last year
    if (dateTime.year < DateTime.now().year) {
      return DateTime.now().year - dateTime.year < 1
          ? SortedDate.lastYear.getName().tr
          : SortedDate.year
          .getName(
        year: DateFormat.y().format(dateTime),
      )
          .tr;
    }
    // More than 1 month ago → return month name
    if (DateTime.now().month - dateTime.month > 1) {
      return SortedDate.month.getName(
        month: DateFormat.MMMM().format(dateTime),
      );
    }
    // Last month
    if (DateTime.now().month - dateTime.month == 1) {
      return SortedDate.lastMonth.getName().tr;
    }
    // Less than one month → return week sort
    final diff = DateTime.now().difference(dateTime);
    return diff.inDays < 7
        ? diff.inDays == 0
        ? SortedDate.today.getName().tr
        : SortedDate.thisWeek.getName().tr
        : SortedDate.weekAgo
        .getName(number: (diff.inDays / 7).floor().toString())
        .tr;
  }

  /// Formats Date with localization
  static String formatDate(DateTime dateTime) {
    return DateFormat('d/M/yyyy', Get.locale.toString()).format(dateTime);
  }

  /// Formats Time with localization
  static String formatTime(DateTime dateTime) {
    if (DateTime.now().difference(dateTime).inDays == 0) {
      return DateFormat('h:mm a', Get.locale.toString()).format(dateTime);
    } else if (DateTime.now().difference(dateTime).inDays == 1) {
      return 'Yesterday'.tr;
    } else {
      return DateFormat('d/M/yyyy', Get.locale.toString()).format(dateTime);
    }
  }

  // Helper function to extract the hour from the time string and convert it to 24-hour format
  static String extractHour(String time) {
    List<String> parts = time.split(' ');
    List<String> timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0].trim());
    String period = parts[1].trim().toUpperCase();
    if (period == "PM" && hour != 12) {
      hour += 12;
    } else if (period == "AM" && hour == 12) {
      hour = 0;
    }
    return hour.toString();
  }

  static String extractMinutes(String time) {
    List<String> parts = time.split(' ');
    List<String> timeParts = parts[0].split(':');
    return timeParts[1].trim();
  }
}