/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_test_screen_logic.dart
/// Description: Logic and event handlers of `_CalendarTestScreenState` — split out of `calendar_screen.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/calendar_screen.dart';

// Split from calendar_screen.dart to keep every file under 700 lines.

extension _CalendarTestScreenStateLogic on _CalendarTestScreenState {
  List<Map<String, String>> getUniqueModulesWithMapping() {
    final isArabic = _currentLocale?.languageCode == 'ar';

    final allowedModules = _drawerController.allowedDrawerModules;

    eventDetails.map((e) => e.moduleName.toLowerCase()).toSet();

    List<Map<String, String>> modulesList = [
      {'display': isArabic ? 'الكل' : 'All', 'english': 'All'},
    ];

    final allModulesMap = {
      // 'english' MUST equal AppModule.services.labelEn — see [_chipModuleNames].
      'services': {
        'display': isArabic ? 'إدارة الخدمات' : 'Service Management',
        'english': 'Service Management',
      },
      'services_app': {
        'display': isArabic ? 'منشئ النماذج' : 'Form Builder',
        'english': 'Form Builder',
      },
      'formbuilder': {
        'display': isArabic ? 'منشئ النماذج' : 'Form Builder',
        'english': 'Form Builder',
      },
      'inventory': {
        'display': isArabic ? 'المخزون' : 'Inventory',
        'english': 'Inventory',
      },
      'database': {
        'display': isArabic ? 'قاعدة البيانات' : 'Database',
        'english': 'Database Management',
      },
      'events': {
        'display': isArabic ? 'الأحداث' : 'Events',
        'english': 'Events',
      },
      'tracking': {
        'display': isArabic ? 'التتبع' : 'Tracking',
        'english': 'Tracking',
      },
      // ADDED 9/10/2026 — Time Tracker phase 6 (`Modules.timeTracker`, which
      // took the legacy tracking slot). 'english' MUST equal
      // AppModule.timeTracker.labelEn — the filter compares it with
      // `event.moduleName`, which `CalendarEventModel.fromType` fills from it.
      'timetracker': {
        'display':
            isArabic ? 'تتبع الوقت والحضور' : 'Time Tracker & Attendance',
        'english': 'Time Tracker & Attendance',
      },
      'employees': {
        'display': isArabic ? 'الموظفين' : 'Org Chart',
        'english': 'HR',
      },
      'knowledgehub': {
        'display': isArabic ? 'مركز المعرفة' : 'Knowledge Hub',
        'english': 'Knowledge Hub',
      },
      'tasks': {'display': isArabic ? 'المهام' : 'Tasks', 'english': 'Tasks'},
      'todo': {
        'display': isArabic ? 'قائمة المهام' : 'To-Do List',
        'english': 'To-Do List',
      },
      'grc': {
        'display': isArabic ? ' الحوكمة و المخاطر و الآلتزام' : 'GRC',
        'english': 'GRC',
      },
      'qiyas': {'display': isArabic ? 'قياس' : 'Qiyas', 'english': 'Qiyas'},
      'messages': {
        'display': isArabic ? 'الرسائل' : 'Messages',
        'english': 'Messages',
      },
      // One chip, three AppModules — [_chipModuleNames] widens it to all three.
      'roles': {
        'display': isArabic ? 'إدارة الأدوار' : 'Role Management',
        'english': 'Role Management',
      },
      // ADDED 25/8/2026. `english` must equal `AppModule.settings.labelEn`,
      // because the filter below compares it against `event.moduleName`, which
      // `CalendarEventModel.fromType` fills from exactly that.
      'settings': {
        'display': isArabic ? 'الإعدادات' : 'Settings',
        'english': 'Settings',
      },
    };

    for (var module in allowedModules) {
      // Home is a drawer destination, not an event source, so it never gets a
      // chip.
      //
      // CHANGED 25/8/2026: Settings used to be skipped alongside it, for the
      // same reason — it raised no calendar entries. It does now (change
      // requests awaiting review, and the requester's own lifecycle), so
      // excluding it left those cards visible under "All" with no way to
      // filter to them.
      //
      // REMOVED 26/8/2026: Modules.employees — the "Org Chart" chip — for the
      // reason Settings used to be skipped. Dropping it here is enough: the
      // chip and the filter it drives are built from this one list. Any Org
      // Chart entry still shows under "All"; it just has no chip of its own.
      if (module == Modules.home || module == Modules.employees) {
        continue;
      }

      String moduleName = module.name.toLowerCase();

      if (allModulesMap.containsKey(moduleName)) {
        modulesList.add(allModulesMap[moduleName]!);
      } else {}
    }

    return modulesList;
  }
}
