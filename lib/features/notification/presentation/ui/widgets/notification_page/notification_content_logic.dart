/// Module: notification/notification_page
///
///*************************** FILE INFO ****************************///
/// File Name: notification_content_logic.dart
/// Description: Logic and event handlers of `_NotificationContentState` — split out of `notification_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/notification_page.dart';

// Split from notification_page.dart to keep every file under 700 lines.

extension _NotificationContentStateLogic on _NotificationContentState {
  List<NotificationModelSystem> _getFilteredNotifications() {
    List<NotificationModelSystem> filtered = widget.allNotifications;

    // ✅ DEBUG: Print all notifications before filtering

    // Filter out pinned and cleaned
    filtered = filtered.where((n) => n.isPinned == false).toList();

    filtered = filtered.where((n) => n.isClean == false).toList();

    // Module filter.
    //
    // FIXED: this compared the stored `Name_of_module` string straight against
    // the chip's key, so only notifications whose module key happened to equal
    // a drawer module name were ever counted. Everything the role area sends —
    // `user_access`, `user_management`, `role_management` — matched no chip at
    // all and was reachable only through "All". Resolving through
    // NotificationRouting.moduleForStoredKey files all three under Roles, the
    // same mapping that decides where tapping the card navigates.
    //
    // The "All" test also accepts the localized label: the chips set
    // selectStatus to S.of(context).all, so in Arabic the literal "All" never
    // matched and the page filtered itself empty.
    if (selectStatus != "All" && selectStatus != S.of(context).all) {
      final String moduleFilter = _getModuleKeyFromName(selectStatus);

      filtered = filtered
          .where((n) => _moduleKeyOf(n.nameOfModule) == moduleFilter)
          .toList();
    }

    // Search filter
    if (searchController.text.isNotEmpty) {
      String query = searchController.text.toLowerCase();
      filtered = filtered.where((n) {
        // displayBody, not body: search matches what the card actually shows.
        // Matching the raw text would surface cards whose only hit is inside
        // the stripped "Reason:" clause, which the reader cannot see.
        // Both languages: a notification is stored in English AND Arabic
        // (30/8/2026), so searching only the English half would miss a card
        // the user is currently looking at in Arabic. See the model.
        return n.searchText.contains(query);
      }).toList();
    }

    // ── Toolbar filters ─────────────────────────────────────────────────
    // Sender Type / By Type / Department / Time. The predicate lives beside
    // the row that drives it, in notification_filter_row.dart, so the three
    // inboxes cannot disagree about what a selection means. This page used to
    // carry its own copy of all four tests.
    filtered = NotificationFilters.apply(
      source: filtered,
      employeeController: widget.employeeController,
      senderType: senderTypeFilter,
      byType: byTypeFilter,
      department: departmentFilter,
      time: timeFilter,
    );

    // Sort by timestamp
    filtered.sort((a, b) {
      if (sortOrder == "newest") {
        return (b.timestamp).compareTo(a.timestamp);
      } else {
        return (a.timestamp).compareTo(b.timestamp);
      }
    });

    return filtered;
  }

  /// Function Name: [_chipLabel]
  ///
  /// Purpose: The text a module's filter chip shows. ADDED 26/8/2026.
  ///
  /// [Modules.getModuleName] is the app-wide name — "Roles", "Services" — and
  /// the sidebar, the drawer and every module screen keep using it. This inbox
  /// spells those two out instead, so the override lives here rather than in
  /// the enum, where it would rename them across the whole app.
  ///
  /// Anything that compares against a chip label must go through this method
  /// too: [_getModuleKeyFromName] does, because `selectStatus` stores the
  /// LABEL rather than the enum, and a label the lookup can't resolve silently
  /// filters the list down to nothing.
  String _chipLabel(Modules module) {
    final bool isArabic = Get.locale.toString().contains('ar');
    switch (module) {
      case Modules.roles:
        return isArabic ? 'إدارة الأدوار' : 'Role Management';
      case Modules.services:
        return isArabic ? 'إدارة الخدمات' : 'Service Management';
      default:
        return module.getModuleName;
    }
  }

  // ✅ FIXED: Ensure exact match with Firebase naming
  String _moduleEnumToKey(Modules module) {
    switch (module) {
      case Modules.services:
        return 'services';
      case Modules.roles:
        return 'roles';
      case Modules.tasks:
        return 'tasks';
      case Modules.employees:
        return 'employees';
      case Modules.inventory:
        return 'inventory';
      case Modules.messages:
        return 'messages';
      case Modules.knowledgeHub:
        return 'knowledgeHub'; // ✅ Matches Firebase exactly
      case Modules.qiyas:
        return 'qiyas';
      case Modules.formBuilder:
        return 'formBuilder'; // ✅ Changed from 'services_app'
      case Modules.timeTracker: // CHANGED 9/10/2026 (was Modules.tracking)
        return 'tracking';
      case Modules.todo:
        return 'todo';
      case Modules.grc:
        return 'grc';
      case Modules.database:
        return 'database';
      default:
        return module.name.toLowerCase();
    }
  }

  Map<String, int> _getNotificationCountsByModule() {
    Map<String, int> counts = {'all': 0};

    for (Modules module in widget.allowedModules) {
      String key = _moduleEnumToKey(module);
      counts[key] = 0;
    }

    for (var notification in widget.allNotifications) {
      if (notification.isPinned || notification.isClean) continue;

      counts['all'] = (counts['all'] ?? 0) + 1;

      // Resolved, not string-matched — see [_moduleKeyOf]. This is why the
      // chips used to sum to less than "All": every user-access and
      // user-management alert fell through.
      final String? key = _moduleKeyOf(notification.nameOfModule);
      if (key != null && counts.containsKey(key)) {
        counts[key] = counts[key]! + 1;
      }
    }

    return counts;
  }
}
