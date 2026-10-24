/// Module: calendar / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_module_lookup.dart
/// Purpose: ONE place that turns an event's `moduleName` into the drawer
///          [Modules] value, so the month/list card and the day-timeline card
///          always show the same icon for the same module.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Moved out of `EventCard._moduleFor` (22/10/2026, Moataz: the "Personal
/// Information" card showed the Services headset instead of Settings). The
/// day timeline kept an older hand-written switch with no Settings, User
/// Access or Org Chart case, so those cards fell back to the Services glyph.
library;

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';

/// Resolve the module behind [moduleName] — see the notes on each case.
Modules calendarModuleFor(String moduleName) {
  final String key = moduleName.trim().toLowerCase().replaceAll(' ', '_');
  if (key.isEmpty) return Modules.services;

  switch (key) {
    case 'approval':
    case 'approvals':
    case 'service':
      return Modules.services;
    case 'form':
    case 'services_app':
      return Modules.formBuilder;
    case 'event':
    case 'events':
      return Modules.qiyas;
    case 'time_tracker':
      return Modules.tracking;
    // AppModule.timeTracker.labelEn ('Time Tracker & Attendance') — what
    // CalendarEventModel.fromType writes. ADDED 9/10/2026 (phase 6).
    case 'time_tracker_&_attendance':
      return Modules.timeTracker;
    case 'hr':
    case 'org_chart':
    case 'organization_chart':
      return Modules.employees;
    case 'task':
      return Modules.tasks;
    // AppModule.todo.labelEn ('To-Do List') — neither the enum id ('todo')
    // nor its display name ('Todo') matches it. ADDED 7/10/2026.
    case 'to-do_list':
    case 'to_do_list':
    case 'to_do':
      return Modules.todo;
    case 'risk_register':
      return Modules.grc;
    // The three role-area vocabularies all live under one drawer module.
    case 'user_access':
    case 'user_management':
    case 'role_management':
      return Modules.roles;
    // Owner 21/10/2026 13:53 ("why is the icon Service?"): a Settings
    // change-request card showed the Services headset because this switch
    // had no Settings case and fell back to Services.
    case 'setting':
    case 'settings':
      return Modules.settings;
  }

  // The enum's own identifier. Underscores are stripped from the key so
  // 'form_builder' meets `Modules.formBuilder`.
  final String squashed = key.replaceAll('_', '');
  for (final Modules module in Modules.values) {
    if (module.name.toLowerCase() == squashed) return module;
  }

  // The enum's display name, which is what most builders pass. It is
  // locale-dependent, so this can miss in an Arabic session; the alias table
  // above is what catches the ones that matter.
  for (final Modules module in Modules.values) {
    if (module.getModuleName.trim().toLowerCase().replaceAll(' ', '_') == key) {
      return module;
    }
  }

  return Modules.services;
}
