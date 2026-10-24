/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_event_tap_test.dart
/// Purpose: Every calendar card leads somewhere, and to the right module /
///          section (`CalendarEventTap.targetOf`).
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/calendar_catalog.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/calendar_event_type.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/knowledge_hub_module/knowledge_hub_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/role_module/user_access_module/user_access_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/services_module/services_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/settings_module/settings_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/todo_module/todo_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/widgets/calendar_event_tap.dart';
import 'package:knowticed_plus/features/notification/domain/routing/notification_deep_link.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';

CalendarEventModel _card(CalendarEventType t, {String? id}) =>
    CalendarEventModel.fromType(t,
        sourceDate: DateTime(2026, 10, 22),
        isArabic: false,
        requestId: id,
        variables: {for (final v in t.variables) v: 'x'});

void main() {
  test('every catalog event type opens its own module', () {
    for (final CalendarEventType t in CalendarCatalog.allEvents) {
      final CalendarTapTarget? target = CalendarEventTap.targetOf(_card(t));
      expect(target, isNotNull, reason: t.id);
      expect(target!.link.module,
          NotificationRouting.moduleForStoredKey(t.module.key),
          reason: t.id);
    }
  });

  test('a Qiyas card (not on the enums yet) opens Qiyas', () {
    final CalendarTapTarget? target = CalendarEventTap.targetOf(
      CalendarEventModel(
        date: DateTime(2026, 10, 22),
        color: Colors.red,
        moduleName: 'Qiyas',
        taskName: 'Assignment',
        time: '',
        description: '',
        status: '',
      ),
    );
    expect(target?.link.module, Modules.qiyas);
  });

  test('sections', () {
    NotificationDeepLink link(CalendarEventType t) =>
        CalendarEventTap.targetOf(_card(t))!.link;
    expect(link(ServicesCalendarEvent.pendingApproval).servicesSection,
        NotificationServicesSection.approvals);
    expect(link(ServicesCalendarEvent.dueForProvider).servicesSection,
        NotificationServicesSection.providerDashboard);
    expect(link(ServicesCalendarEvent.slaBreachedRequester).servicesSection,
        NotificationServicesSection.requests);
    expect(link(ServicesCalendarEvent.doneForManagement).servicesSection,
        isNull);
    expect(link(KnowledgeHubCalendarEvent.approvalPending).knowledgeHubSection,
        NotificationKnowledgeHubSection.approvals);
    expect(
        link(KnowledgeHubCalendarEvent.documentScheduled).knowledgeHubSection,
        NotificationKnowledgeHubSection.submissions);
    expect(link(SettingsCalendarEvent.changeRequestApproved).settingsSection,
        NotificationSettingsSection.requests);
    expect(link(UserAccessCalendarEvent.accountLocked).rolesTab, 2);
  });

  test('a to-do card carries its id', () {
    expect(
        CalendarEventTap.targetOf(_card(TodoCalendarEvent.taskDue, id: 't1'))!
            .todoId,
        't1');
  });
}
