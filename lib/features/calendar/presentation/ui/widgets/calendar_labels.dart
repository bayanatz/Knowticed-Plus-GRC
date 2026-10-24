/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_labels.dart
/// Purpose: Turns the English status and 12-hour time strings the calendar
///          data sources produce into the active language.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The data sources stamp every event with an English status ("Due",
/// "Overdue", "SLA") and a time like "12:41 AM". The event card printed both
/// as they came, so an Arabic calendar showed English tags and a mix of "ص" and
/// "AM". English is returned untouched; Arabic goes through the translation
/// files. An unknown status is shown as it is rather than hidden.
abstract class CalendarLabels {
  static String status(BuildContext context, String status) {
    if (Localizations.localeOf(context).languageCode != 'ar') return status;
    final S s = S.of(context);
    switch (status.trim().toLowerCase()) {
      case 'scheduled':
        return s.scheduled;
      case 'milestone':
        return s.calStatusMilestone;
      case 'reminder':
        return s.reminder;
      case 'reminders':
        return s.calStatusReminders;
      case 'pending approval':
        return s.calStatusPendingApproval;
      case 'expiring':
        return s.calStatusExpiring;
      case 'expiring soon':
        return s.expiringSoon;
      case 'expired':
        return s.expired;
      case 'updated':
        return s.calStatusUpdated;
      case 'active':
        return s.active;
      case 'rejected':
        return s.rejected;
      case 'overdue':
        return s.overdue;
      case 'done':
        return s.done;
      case 'pending':
        return s.pending;
      case 'due':
        return s.calStatusDue;
      case 'due today':
        return s.hwsDueToday;
      case 'approved by supervisor':
        return s.calStatusApprovedBySupervisor;
      case 'approved':
        return s.approved;
      case 'submitted':
        return s.submitted;
      case 'inprogress':
      case 'in progress':
        return s.calStatusInProgress;
      case 'release':
        return s.calStatusRelease;
      case 'frequency':
        return s.frequency;
      case 'duration':
        return s.calStatusDuration;
      case 'assigned':
        return s.assigned;
      default:
        // "SLA" and anything unmapped.
        return status;
    }
  }

  /// "12:41 AM" -> "12:41 ص" in Arabic. Digits stay Western (D-145).
  static String time(BuildContext context, String time) {
    if (Localizations.localeOf(context).languageCode != 'ar') return time;
    final S s = S.of(context);
    return time.replaceAllMapped(
      RegExp(r'\b(AM|PM)\b', caseSensitive: false),
      (Match m) => m.group(1)!.toUpperCase() == 'AM' ? s.am : s.pm,
    );
  }

  /// The section a Settings change request is about ("Personal Information",
  /// "Health Insurance", "Emergency Contact"…). The request stores it in
  /// English and the calendar printed it raw as the card title, so an Arabic
  /// card said "Personal Information" over an Arabic sentence. Any other
  /// title (a to-do the user typed, a policy name) is returned untouched.
  static String sectionTitle(BuildContext context, String title) {
    if (Localizations.localeOf(context).languageCode != 'ar') return title;
    final S s = S.of(context);
    switch (title.trim().toLowerCase()) {
      case 'personal information':
        return s.personalInformation;
      case 'health insurance':
        return s.healthInsurance;
      case 'emergency contact':
        return s.emergencyContact;
      case 'social information':
        return s.socialInformation;
      case 'contact information':
        return s.contactInformation;
      default:
        return title;
    }
  }
}
