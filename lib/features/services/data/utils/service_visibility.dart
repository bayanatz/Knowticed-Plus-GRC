/// Module: services / data / utils
///
///*************************** FILE INFO ****************************///
/// File Name: service_visibility.dart
/// Purpose: Flat, queryable copy of who may see a service (SVC-HOME-01).
///          `Limit_Availability` and `Select_Department` are history lists
///          (the departments are a JSON string per revision), so Firestore
///          cannot filter on them. Every service save also writes
///          `Visible_To`: ["*"] for a service open to everyone, otherwise the
///          allowed department entries (lower case). The home page and the
///          Request Services page then query only what the user may see
///          instead of downloading every service.
/// Author: Amr Mesbah
/// Created at: 22/10/2026
library;

import 'dart:convert';

/// Class Name: [ServiceVisibility]
///
/// Purpose: Builds the `Visible_To` field and the keys a user queries with.
class ServiceVisibility {
  const ServiceVisibility._();

  /// Flat field on every CreateServices document.
  static const String field = 'Visible_To';

  /// Marker meaning "every department may see this service".
  static const String everyone = '*';

  /// Firestore allows at most 30 values in one arrayContainsAny.
  static const int maxQueryKeys = 30;

  static String _normalize(Object? value) =>
      (value ?? '').toString().trim().toLowerCase();

  /// Function Name: [keysFor]
  ///
  /// Purpose: The `Visible_To` value for a service, from its history lists.
  ///
  /// Parameters:
  /// - [limitAvailability]: the Limit_Availability history (last = current).
  /// - [selectDepartment]: the Select_Department history (last = current,
  ///   a JSON list of department ids or names).
  static List<String> keysFor({
    required List<bool> limitAvailability,
    required List<String> selectDepartment,
  }) {
    final limited = limitAvailability.isNotEmpty && limitAvailability.last;
    if (!limited) return const [everyone];
    return departmentKeys(
      selectDepartment.isEmpty ? const [] : _decode(selectDepartment.last),
    );
  }

  /// Function Name: [keysForCurrent]
  ///
  /// Purpose: Same as [keysFor] for the current values only (bulk upload
  /// writes raw maps).
  static List<String> keysForCurrent({
    required bool limitAvailability,
    required List<dynamic> selectDepartment,
  }) {
    if (!limitAvailability) return const [everyone];
    return departmentKeys(selectDepartment);
  }

  /// Function Name: [departmentKeys]
  ///
  /// Purpose: Lower-case, de-duplicated department entries.
  static List<String> departmentKeys(Iterable<dynamic> entries) {
    final out = <String>{};
    for (final entry in entries) {
      final key = _normalize(entry);
      if (key.isNotEmpty) out.add(key);
    }
    return out.toList();
  }

  /// Function Name: [userKeys]
  ///
  /// Purpose: The keys a user queries with: "everyone" plus their department
  /// id and its names (services store the department id or its name).
  static List<String> userKeys({
    String? departmentId,
    String? englishName,
    String? arabicName,
  }) {
    final keys = <String>{everyone};
    keys.addAll(
      departmentKeys([departmentId ?? '', englishName ?? '', arabicName ?? '']),
    );
    return keys.take(maxQueryKeys).toList();
  }

  static List<dynamic> _decode(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return const [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) return decoded;
      return [decoded];
    } on FormatException {
      return [value];
    }
  }
}
