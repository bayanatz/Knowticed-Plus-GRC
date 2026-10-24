/// Module: services / data / utils
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_provider.dart
/// Purpose: The ONE rule for "who is the provider of this request" used by
///          every dashboard (Dashboards rule 6: it was copied four times with
///          small differences). Tries, in order: the stored provider map,
///          the provider history (Provider_Services, current = last entry),
///          the assigned provider e-mail (current = last entry), provider
///          e-mails inside the state history, then the approval cycle.
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'dart:convert';

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_keys.dart';

/// Class Name: [DashboardProvider]
///
/// Purpose: The provider of one request, with the fields the dashboards
/// show.
class DashboardProvider {
  const DashboardProvider({
    this.map = const {'gender': ''},
    this.firstName = '',
    this.lastName = '',
    this.firstNameArabic = '',
    this.lastNameArabic = '',
  });

  /// Nobody found.
  static const DashboardProvider none = DashboardProvider();

  /// The provider's details (firstName, lastName, email, gender, title,
  /// departmentId…); always has a 'gender' key.
  final Map<String, dynamic> map;
  final String firstName;
  final String lastName;
  final String firstNameArabic;
  final String lastNameArabic;

  /// English full name, or '' when there is no provider.
  String get name => '$firstName $lastName'.trim();

  /// The legacy map shape the dashboard rows used ('map', 'name', …).
  Map<String, dynamic> toRow() => {
        'map': map,
        'name': name,
        'firstName': firstName,
        'lastName': lastName,
        'firstNameArabic': firstNameArabic,
        'lastNameArabic': lastNameArabic,
      };

  static DashboardProvider _fromEmployee(EmployeeEntityPro emp) =>
      DashboardProvider(
        map: {
          'firstName': emp.firstName ?? '',
          'lastName': emp.lastName ?? '',
          'firstNameInArabic': emp.firstNameInArabic ?? '',
          'lastNameInArabic': emp.lastNameInArabic ?? '',
          'email': emp.email ?? '',
          'gender': emp.gender ?? '',
          'title': emp.title ?? '',
          'titleInArabic': emp.titleInArabic ?? '',
          'departmentId': emp.departmentId ?? '',
        },
        firstName: emp.firstName ?? '',
        lastName: emp.lastName ?? '',
        firstNameArabic: emp.firstNameInArabic ?? '',
        lastNameArabic: emp.lastNameInArabic ?? '',
      );

  static DashboardProvider _fromMap(Map<String, dynamic> map) =>
      DashboardProvider(
        map: {'gender': '', ...map},
        firstName: map['firstName']?.toString() ?? '',
        lastName: map['lastName']?.toString() ?? '',
        firstNameArabic: map['firstNameInArabic']?.toString() ?? '',
        lastNameArabic: map['lastNameInArabic']?.toString() ?? '',
      );

  /// The first JSON object found in a stored value (a map, a JSON string of
  /// a map or of a list of maps).
  static Map<String, dynamic>? _firstObject(Object? raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        return _firstObject(jsonDecode(raw));
      } on FormatException {
        return null;
      }
    }
    if (raw is List && raw.isNotEmpty) return _firstObject(raw.first);
    return null;
  }

  /// Function Name: [resolve]
  ///
  /// Purpose: The provider of the request [data].
  ///
  /// Parameters:
  /// - [data]: the raw RequestServices document.
  /// - [requesterEmail]: the requester (never returned as the provider).
  /// - [employees]: employees by e-mail.
  static DashboardProvider resolve({
    required Map<String, dynamic> data,
    required String requesterEmail,
    required Map<String, EmployeeEntityPro> employees,
  }) {
    DashboardProvider? byEmail(String? email) {
      final e = email?.trim() ?? '';
      if (e.isEmpty || e == requesterEmail) return null;
      final emp = employees[e];
      return emp == null ? null : _fromEmployee(emp);
    }

    // 1. The stored provider map.
    final stored = data['selectedServiceProvider'];
    if (stored is Map && stored.isNotEmpty) {
      return _fromMap(Map<String, dynamic>.from(stored));
    }

    // 2. The provider history: current = last entry.
    final history = data[ServicesHistoryKeys.kProviderServices];
    if (history is List && history.isNotEmpty) {
      final current = _firstObject(history.last);
      if (current != null && current.isNotEmpty) {
        final email = current['email']?.toString() ??
            current['providerEmail']?.toString();
        return byEmail(email) ?? _fromMap(current);
      }
    }

    // 3. The assigned provider e-mail: current = last entry.
    final assigned = data[ServicesHistoryKeys.kAssignedProviderEmail];
    final assignedEmail = assigned is List && assigned.isNotEmpty
        ? assigned.last?.toString()
        : (assigned is String ? assigned : null);
    final fromAssigned = byEmail(assignedEmail);
    if (fromAssigned != null) return fromAssigned;

    // 4. Provider e-mails inside the state history.
    final states = data[ServicesHistoryKeys.kState];
    if (states is List) {
      for (final s in states) {
        if (s is! Map) continue;
        final found = byEmail(
          (s['providerEmail'] ?? s['assignedTo'] ?? s['provider'])?.toString(),
        );
        if (found != null) return found;
      }
    }

    // 5. The approval cycle.
    final cycle = data['approvalCycle'];
    final entries = cycle is Map
        ? (cycle['value'] is List ? cycle['value'] as List : [cycle])
        : (cycle is List ? cycle : const []);
    for (final entry in entries) {
      if (entry is! Map) continue;
      final found = byEmail(
        (entry['email'] ?? entry['approverEmail'])?.toString(),
      );
      if (found != null) return found;
    }

    return none;
  }
}
