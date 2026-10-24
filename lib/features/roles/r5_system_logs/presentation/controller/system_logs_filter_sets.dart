/// Module: roles / r5_system_logs / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: system_logs_filter_sets.dart
/// Description: The multi-select filter of the tablet Filter dialog — module,
///              action, role, country, city, employee and a date range
///              (X-40 every filter is multi-select, X-119 choices come from
///              the logs shown). Split out of system_logs_controller.dart to
///              keep it under the size limit.
/// Author: Moataz Handousa
/// Created at: 21/10/2026
part of 'system_logs_controller.dart';

extension SystemLogsFilterSets on SystemLogsController {
  /// Whether any multi-select filter is set.
  bool get hasFilterSets =>
      moduleFilters.isNotEmpty ||
      actionFilters.isNotEmpty ||
      roleFilters.isNotEmpty ||
      countryFilters.isNotEmpty ||
      cityFilters.isNotEmpty ||
      employeeFilters.isNotEmpty;

  /// [log] passes every multi-select filter (an empty set lets all through).
  bool matchesFilterSets(SystemLogsModel log) {
    bool inSet(Set<String> set, String? value) =>
        set.isEmpty ||
        // Owner 21/10/2026: trim both sides — the picker offers trimmed values (distinctInLogs).
        set.any((String v) =>
            v.trim().toLowerCase() == (value ?? '').trim().toLowerCase());
    return inSet(moduleFilters, log.module?.name) &&
        inSet(actionFilters, log.action) &&
        inSet(roleFilters, log.role) &&
        inSet(countryFilters, log.country) &&
        inSet(cityFilters, log.city) &&
        inSet(employeeFilters, log.userEmail);
  }

  void clearFilterSets() {
    moduleFilters = <String>{};
    actionFilters = <String>{};
    roleFilters = <String>{};
    countryFilters = <String>{};
    cityFilters = <String>{};
    employeeFilters = <String>{};
  }

  /// Function Name: [applyFilterSets]
  ///
  /// Purpose: Apply what the Filter dialog picked, on top of the search.
  ///
  /// Return type: [void]
  void applyFilterSets({
    required Set<String> modules,
    required Set<String> actions,
    required Set<String> roles,
    required Set<String> countries,
    required Set<String> cities,
    required Set<String> employees,
    required DateTime? from,
    required DateTime? to,
  }) {
    moduleFilters = modules;
    actionFilters = actions;
    roleFilters = roles;
    countryFilters = countries;
    cityFilters = cities;
    employeeFilters = employees;
    fromDate = from == null ? null : DateTime(from.year, from.month, from.day);
    toDate = to == null ? null : DateTime(to.year, to.month, to.day);
    isFilter = isThereFilter();
    searchLogs();
    if (isFilter) _applyFilter();
    emitSafely(SystemLogsUpdated());
  }

  /// The distinct non-empty values of [pick] in the loaded logs, sorted.
  List<String> distinctInLogs(String? Function(SystemLogsModel) pick) {
    final Set<String> seen = <String>{
      for (final SystemLogsModel log in systemLogsData)
        if ((pick(log) ?? '').trim().isNotEmpty) pick(log)!.trim(),
    };
    return seen.toList()..sort();
  }

  /// Employee email → full name, for the people who appear in the logs.
  Map<String, String> employeesInLogs(bool arabic) {
    final Map<String, String> people = <String, String>{};
    for (final SystemLogsModel log in systemLogsData) {
      final String email = (log.userEmail ?? '').trim();
      if (email.isEmpty || people.containsKey(email)) continue;
      final String name = (arabic
              ? '${log.firstNameInArabic ?? ''} ${log.lastNameInArabic ?? ''}'
              : '${log.firstName ?? ''} ${log.lastName ?? ''}')
          .trim();
      people[email] = name.isEmpty ? email : name;
    }
    return people;
  }
}
