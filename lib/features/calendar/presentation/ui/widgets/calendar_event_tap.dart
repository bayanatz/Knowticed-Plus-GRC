/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_event_tap.dart
/// Purpose: Makes a calendar event card tappable — every module's card opens
///          that module (and the section / record the card is about), the
///          same way a notification's View does.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
/// Updated: 9/10/2026 - Time Tracker phase 6: `TimeTrackerCalendarEvent`
///          cards open `TimeTrackerModuleEntry` — the request's details (the
///          approver's details for "Awaiting Your Approval"), or, for a late
///          / absent card, the Attendance tab filtered to that day.
/// Updated: 22/10/2026 - Owner: "check that all the calendars navigate to
///          where they're supposed to", and "the selected module in the
///          navigation is Home, it's supposed to be the Time Tracker". Only
///          To-Do and Time Tracker cards did anything, and they PUSHED the
///          module over Home, so the sidebar kept Home selected. Every module
///          now routes through `NotificationRouting.openFromCalendar`: on the
///          tablet / desktop shell the module is selected in the sidebar
///          (Home keeps the calendar open underneath); on a phone it is
///          pushed over the calendar, so Back returns to it.
///
/// WHY ONE SHARED WRAPPER
/// ----------------------
/// The calendar draws event cards in two widgets:
///   * `EventCard`       — the day's list under the MONTH grid (full calendar
///                         screen, phone and tablet). The screen OPENS in month
///                         view, so this is the card the user sees first;
///   * `DayTimelineView` — the DAY view of the full screen (phone + tablet) and
///                         the home calendar card's timeline.
/// Both cards go through this wrapper, so every view routes the same way.
///
/// WHERE EACH MODULE LANDS ([targetOf])
/// ------------------------------------
///   To-Do            → that to-do's details (no id → the list).
///   Time Tracker     → the request (approver's details for an approval);
///                      late / absent → Attendance on that day.
///   Settings         → Requests (own submissions + the reviewer's queue).
///   Role Management  → Roles, Role Management tab.
///   User Access      → Roles, User Access tab.
///   Service Mgmt     → Approvals / Provider dashboard / My requests, by the
///                      card's scope; Management cards → the module.
///   Knowledge Hub    → Approvals for a pending approval, Submissions for a
///                      scheduled document, else the published list.
///   GRC, Messages, Form Builder, Qiyas → the module's main page (none of
///                      them can open a record from an id yet).
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/knowledge_hub_module/knowledge_hub_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/services_module/services_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/time_tracker_module/time_tracker_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/todo_module/todo_calendar_events.dart';
import 'package:knowticed_plus/features/notification/domain/routing/notification_deep_link.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';

/// Where one calendar card leads: the module + section, and the record when
/// the module can open one.
class CalendarTapTarget {
  const CalendarTapTarget(
    this.link, {
    this.todoId,
    this.request,
    this.attendanceDay,
  });

  final NotificationDeepLink link;
  final String? todoId;
  final TimeTrackerNotificationLink? request;
  final DateTime? attendanceDay;
}

class CalendarEventTap extends StatelessWidget {
  const CalendarEventTap({
    super.key,
    required this.event,
    required this.child,
  });

  /// The event the card shows.
  final CalendarEventModel event;

  /// The card itself.
  final Widget child;

  /// Function Name: [targetOf]
  ///
  /// Purpose: Where a tap on [event] leads (null = a module this app does not
  /// know, so the card is not tappable). See the file header for the table.
  ///
  /// Parameters:
  ///   [CalendarEventModel] event
  ///
  /// Return type: [CalendarTapTarget?]
  static CalendarTapTarget? targetOf(CalendarEventModel event) {
    final Object? type = event.type;
    // Qiyas cards are not on the catalog enums yet: their module is the
    // stored name ('Qiyas').
    final String moduleKey =
        event.type?.module.key ?? event.moduleName.trim().toLowerCase();
    final Modules? module = NotificationRouting.moduleForStoredKey(moduleKey);
    if (module == null) return null;
    final String id = (event.requestId ?? '').trim();

    if (type is TodoCalendarEvent) {
      return CalendarTapTarget(NotificationDeepLink.section(module),
          todoId: id.isEmpty ? null : id);
    }
    if (type is TimeTrackerCalendarEvent) {
      if (type.opensAttendanceDay) {
        return CalendarTapTarget(NotificationDeepLink.section(module),
            attendanceDay: event.date);
      }
      return CalendarTapTarget(
        NotificationDeepLink.section(module),
        request: id.isEmpty
            ? null
            : TimeTrackerNotificationLink(
                requestId: id,
                asApproval: type == TimeTrackerCalendarEvent.approvalPending,
              ),
      );
    }
    if (type is ServicesCalendarEvent) {
      return CalendarTapTarget(NotificationDeepLink.section(module,
          servicesSection: _servicesSectionOf(type)));
    }
    if (type is KnowledgeHubCalendarEvent) {
      return CalendarTapTarget(NotificationDeepLink.section(module,
          knowledgeHubSection: switch (type) {
            KnowledgeHubCalendarEvent.approvalPending =>
              NotificationKnowledgeHubSection.approvals,
            // Not published yet — it is still in its author's submissions.
            KnowledgeHubCalendarEvent.documentScheduled =>
              NotificationKnowledgeHubSection.submissions,
            _ => null,
          }));
    }
    switch (module) {
      // Every Settings card is a change request.
      case Modules.settings:
        return CalendarTapTarget(NotificationDeepLink.section(module,
            settingsSection: NotificationSettingsSection.requests));
      // Role Management → its tab, User Access → its tab.
      case Modules.roles:
        return CalendarTapTarget(NotificationDeepLink.section(module,
            rolesTab: NotificationDeepLink.rolesTabFor(moduleKey)));
      default:
        return CalendarTapTarget(NotificationDeepLink.section(module));
    }
  }

  /// The Services screen for a card, from its scope: the approver's cards →
  /// Approvals, the provider's → the provider dashboard, the requester's →
  /// My requests. A manager's card opens the module.
  static NotificationServicesSection? _servicesSectionOf(
      ServicesCalendarEvent type) {
    switch (type.scope) {
      case 'Approvals':
        return NotificationServicesSection.approvals;
      case 'Provider':
        return NotificationServicesSection.providerDashboard;
      case 'Requester':
        return NotificationServicesSection.requests;
      default:
        return null;
    }
  }

  /// Function Name: [_open]
  ///
  /// Purpose: Open [targetOf] the way a notification's View does.
  ///
  /// Parameters:
  ///   [BuildContext] context
  ///   [CalendarTapTarget] target
  ///
  /// Return type: [void]
  void _open(BuildContext context, CalendarTapTarget target) {
    HapticController.low();
    NotificationRouting.openFromCalendar(
      context,
      target.link,
      todoId: target.todoId,
      request: target.request,
      attendanceDay: target.attendanceDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    final CalendarTapTarget? target = targetOf(event);
    if (target == null) return child;
    return GestureDetector(
      // Opaque: the card's padding and gaps are hit too, not only its text.
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => HapticController.low(),
      onTap: () => _open(context, target),
      child: child,
    );
  }
}
