/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_calendar.dart
/// Purpose: Puts ONE calendar card of every module that has calendar events
///          on a single day (six days from today) for the signed-in user, so
///          the busiest possible day can be checked — the dot layout, the
///          day strip and the day list.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Written to the same `Seeded_Events` collection the "Apply all modules"
/// tool uses, so the calendar already knows how to read it. Fixed ids
/// (`showcase_cal_<module>`) — running it again overwrites, nothing piles up.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/calendar/data/data_source/calendar_data_service.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/calendar_catalog.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/calendar_event_type.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';

abstract final class ShowcaseCalendar {
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required bool isArabic,
    required DateTime now,
  }) async {
    final CollectionReference<Map<String, dynamic>> col =
        firestore.collection(getBaseUrl(CalendarDataService.seededEventsPath));

    // The first event type of each module that has any.
    final Map<String, CalendarEventType> firstOf =
        <String, CalendarEventType>{};
    for (final CalendarEventType type in CalendarCatalog.allEvents) {
      firstOf.putIfAbsent(type.module.key, () => type);
    }

    final DateTime day = DateTime(now.year, now.month, now.day + 6, 10);
    final WriteBatch batch = firestore.batch();
    for (final MapEntry<String, CalendarEventType> e in firstOf.entries) {
      final CalendarEventType type = e.value;
      // Back the reminder offset out so the card lands on [day].
      final DateTime sourceDate =
          day.subtract(Duration(days: type.reminderOffsetDays));
      batch.set(
          col.doc('${ShowcaseCommon.idPrefix}cal_${e.key}'), <String, dynamic>{
        'receiverEmail': me.email.trim().toLowerCase(),
        'typeId': type.id,
        'module': type.module.key,
        'sourceDate': Timestamp.fromDate(sourceDate),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return firstOf.length;
  }
}
