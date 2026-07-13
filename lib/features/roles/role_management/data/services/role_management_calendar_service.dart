/// ************************* FILE INFO ************************* ///
/// File Name: role_management_calendar_service.dart
/// Purpose: Calendar event service for Role Management module.
///          Generates calendar entries for scheduled access changes
///          (account activation, deactivation, access change scheduled).
/// Module: Role Management
/// Pattern: Matches CalendarDataService in calendar_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/network/api_constants.dart';
import 'package:demo_app/features/calender/data/data_source/calendar_event_model.dart';
import 'package:demo_app/core/network/get_base_url.dart';

class RoleManagementCalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────
  // COLORS  (match the calendar palette used across modules)
  // ─────────────────────────────────────────────────────────
  static const Color _colorActivationScheduled = Color(0xFF4CAF50);   // green
  static const Color _colorDeactivationScheduled = Color(0xFFF44336); // red
  static const Color _colorAccessChangeScheduled = Color(0xFF2196F3); // blue
  static const Color _colorScheduledApplied = Color(0xFF9C27B0);      // purple
  static const Color _colorScheduledCancelled = Color(0xFF9E9E9E);    // grey

  // ─────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────────────────

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    try {
      if (raw is Timestamp) return raw.toDate();
      if (raw is String && raw.isNotEmpty) {
        // Try common formats
        for (final fmt in [
          "d MMMM yyyy, hh:mm a",
          "yyyy-MM-dd",
          "MM/dd/yyyy",
          "d/M/yyyy",
        ]) {
          try {
            return DateFormat(fmt, 'en').parse(raw);
          } catch (_) {}
        }
        return DateTime.tryParse(raw);
      }
    } catch (_) {}
    return null;
  }

  String _formatTime(DateTime date) =>
      DateFormat('hh:mm a', 'en').format(date);

  String _latestValue(dynamic field) {
    if (field == null) return '';
    if (field is List && field.isNotEmpty) return field.last.toString();
    return field.toString();
  }

  // ─────────────────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────────────────

  /// Fetch all role-management-related calendar events for [currentUserEmail].
  ///
  /// Events generated:
  ///  • Activation Scheduled    (Section 1.4)
  ///  • Deactivation Scheduled  (Section 1.4)
  ///  • Access Change Scheduled (Section 1.5)
  ///  • Scheduled Access Applied
  ///  • Scheduled Access Cancelled
  Future<List<CalendarEventModel>> getRoleManagementCalendarEvents({
    required String currentUserEmail,
  }) async {

    if (currentUserEmail.isEmpty) {
      return [];
    }

    final List<CalendarEventModel> events = [];

    try {
      final companyId = ApiConstants.baseUri.split("/").last;

      // ── 1. Users_Access collection ────────────────────────────────────
      await _loadUsersAccessEvents(
        companyId: companyId,
        currentUserEmail: currentUserEmail,
        events: events,
      );

      // ── 2. Employees_Info collection (account-level scheduled dates) ──
      await _loadEmployeeScheduledEvents(
        companyId: companyId,
        currentUserEmail: currentUserEmail,
        events: events,
      );

      return events;
    } catch (e, st) {
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────
  // PRIVATE: Users_Access events
  // ─────────────────────────────────────────────────────────

  Future<void> _loadUsersAccessEvents({
    required String companyId,
    required String currentUserEmail,
    required List<CalendarEventModel> events,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('Demo/$companyId/Users_Access')
          .get();


      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final employeeId = data['Employee_Id']?.toString() ?? doc.id;

          // Get the employee email associated with this access record
          final employeeEmail = await _getEmailForEmployee(companyId, employeeId);
          final bool isOwnRecord =
              employeeEmail.toLowerCase().trim() == currentUserEmail.toLowerCase().trim();

          // Admins see all; regular users see their own
          final bool isMasterAdmin = await _isMasterAdmin(currentUserEmail, companyId);
          if (!isOwnRecord && !isMasterAdmin) continue;

          final rawFrom = _latestValue(data['From_Date']);
          final rawTo   = _latestValue(data['To_Date']);
          final rawRole = _latestValue(data['Role']);
          final editBy  = _latestValue(data['Edit_By']);

          // Access Change Scheduled — entry on the From_Date
          final fromDate = _parseDate(rawFrom);
          if (fromDate != null && fromDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
            events.add(CalendarEventModel(
              date: fromDate,
              color: _colorAccessChangeScheduled,
              moduleName: 'Role Management',
              taskName: isOwnRecord
                  ? 'System Access Change Scheduled'
                  : 'Access Change Scheduled — ${employeeEmail.isNotEmpty ? employeeEmail : employeeId}',
              time: _formatTime(fromDate),
              description: isOwnRecord
                  ? 'A modification to your system access rights has been scheduled '
                    'and will take effect on ${DateFormat("MMMM d, yyyy").format(fromDate)}. '
                    'Please review your permissions following this date.'
                  : 'Scheduled access change for $employeeId '
                    '(Role: $rawRole) effective ${DateFormat("MMMM d, yyyy").format(fromDate)}.',
              status: 'Scheduled',
              requestId: doc.id,
              userEmail: employeeEmail,
            ));
          }

          // Access Change End — entry on the To_Date if set
          final toDate = _parseDate(rawTo);
          if (toDate != null && toDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
            events.add(CalendarEventModel(
              date: toDate,
              color: _colorScheduledApplied,
              moduleName: 'Role Management',
              taskName: isOwnRecord
                  ? 'Access Period Ends'
                  : 'Access Period Ends — ${employeeEmail.isNotEmpty ? employeeEmail : employeeId}',
              time: _formatTime(toDate),
              description: isOwnRecord
                  ? 'Your assigned access period expires on ${DateFormat("MMMM d, yyyy").format(toDate)}.'
                  : 'Access period for $employeeId (Role: $rawRole) expires on '
                    '${DateFormat("MMMM d, yyyy").format(toDate)}.',
              status: 'Upcoming',
              requestId: doc.id,
              userEmail: employeeEmail,
            ));
          }
        } catch (e) {
        }
      }
    } catch (e) {
    }
  }

  // ─────────────────────────────────────────────────────────
  // PRIVATE: Employees_Info scheduled activation/deactivation
  // ─────────────────────────────────────────────────────────

  Future<void> _loadEmployeeScheduledEvents({
    required String companyId,
    required String currentUserEmail,
    required List<CalendarEventModel> events,
  }) async {
    try {
      final isMasterAdmin = await _isMasterAdmin(currentUserEmail, companyId);

      QuerySnapshot snapshot;
      if (isMasterAdmin) {
        // Admins see all employees that have a scheduled activation/deactivation
        snapshot = await _firestore
            .collection(getBaseUrl('Employees_Info'))
            .get();
      } else {
        // Users see only their own record
        snapshot = await _firestore
            .collection(getBaseUrl('Employees_Info'))
            .where('Email', arrayContains: currentUserEmail)
            .get();
      }


      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final empEmail = _latestValue(data['Email']);
          final empName  = '${_latestValue(data['First_Name'])} ${_latestValue(data['Last_Name'])}'.trim();
          final isOwn    = empEmail.toLowerCase().trim() == currentUserEmail.toLowerCase().trim();

          // ── Activation Scheduled ──────────────────────────────────────
          final activationDate = _parseDate(data['Scheduled_Activation_Date']);
          if (activationDate != null) {
            events.add(CalendarEventModel(
              date: activationDate,
              color: _colorActivationScheduled,
              moduleName: 'Role Management',
              taskName: isOwn
                  ? 'Account Activation Scheduled'
                  : 'Account Activation Scheduled — ${empName.isNotEmpty ? empName : empEmail}',
              time: _formatTime(activationDate),
              description: isOwn
                  ? 'Your account activation has been scheduled and will take effect on '
                    '${DateFormat("MMMM d, yyyy").format(activationDate)}. '
                    'You will receive a confirmation notification once access has been granted.'
                  : 'Account activation for ${empName.isNotEmpty ? empName : empEmail} '
                    'scheduled on ${DateFormat("MMMM d, yyyy").format(activationDate)}.',
              status: 'Scheduled',
              requestId: doc.id,
              userEmail: empEmail,
            ));
          }

          // ── Deactivation Scheduled ────────────────────────────────────
          final deactivationDate = _parseDate(data['Scheduled_Deactivation_Date']);
          if (deactivationDate != null) {
            events.add(CalendarEventModel(
              date: deactivationDate,
              color: _colorDeactivationScheduled,
              moduleName: 'Role Management',
              taskName: isOwn
                  ? 'Account Deactivation Scheduled'
                  : 'Account Deactivation Scheduled — ${empName.isNotEmpty ? empName : empEmail}',
              time: _formatTime(deactivationDate),
              description: isOwn
                  ? 'Your account is scheduled for deactivation on '
                    '${DateFormat("MMMM d, yyyy").format(deactivationDate)}. '
                    'Following this date, access to the system will no longer be available. '
                    'Please contact your administrator if you have any concerns.'
                  : 'Account deactivation for ${empName.isNotEmpty ? empName : empEmail} '
                    'scheduled on ${DateFormat("MMMM d, yyyy").format(deactivationDate)}.',
              status: 'Scheduled',
              requestId: doc.id,
              userEmail: empEmail,
            ));
          }

          // ── Access Schedule Updated ───────────────────────────────────
          final accessScheduleDate = _parseDate(data['Scheduled_Access_Change_Date']);
          if (accessScheduleDate != null &&
              accessScheduleDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
            events.add(CalendarEventModel(
              date: accessScheduleDate,
              color: _colorAccessChangeScheduled,
              moduleName: 'Role Management',
              taskName: isOwn
                  ? 'Account Access Schedule Updated'
                  : 'Access Schedule Updated — ${empName.isNotEmpty ? empName : empEmail}',
              time: _formatTime(accessScheduleDate),
              description: isOwn
                  ? 'The access schedule associated with your account has been revised. '
                    'Your access rights will be adjusted effective '
                    '${DateFormat("MMMM d, yyyy").format(accessScheduleDate)}.'
                  : 'Access schedule for ${empName.isNotEmpty ? empName : empEmail} '
                    'will be applied on ${DateFormat("MMMM d, yyyy").format(accessScheduleDate)}.',
              status: 'Scheduled',
              requestId: doc.id,
              userEmail: empEmail,
            ));
          }
        } catch (e) {
        }
      }
    } catch (e) {
    }
  }

  // ─────────────────────────────────────────────────────────
  // PRIVATE UTILITIES
  // ─────────────────────────────────────────────────────────

  Future<bool> _isMasterAdmin(String email, String companyId) async {
    try {
      final snap = await _firestore
          .collection(getBaseUrl('Employees_Info'))
          .where('Email', arrayContains: email)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return false;
      final data = snap.docs.first.data();
      if (data['Role'] is List) {
        final roles = data['Role'] as List;
        return roles.isNotEmpty &&
            roles.last.toString().toLowerCase() == 'master admin';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<String> _getEmailForEmployee(String companyId, String employeeId) async {
    try {
      final snap = await _firestore
          .collection(getBaseUrl('Employees_Info'))
          .where('Employee_Id', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return '';
      final data = snap.docs.first.data();
      return _latestValue(data['Email']);
    } catch (_) {
      return '';
    }
  }
}
