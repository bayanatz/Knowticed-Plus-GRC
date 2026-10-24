/// Module: database / db1_create_database / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: database_module_entry.dart
/// Description: Declares `DatabaseModuleEntry`.
/// Author: Amr Mesbah
/// Created at: 15/8/2026
/// Updated: 15/8/2026 - Hosts the module's own Navigator so the nav rail and
///          the header stay visible while the create wizard is open.
/// Updated: 22/10/2026 - Takes the notification's pending record (owner: View
///          opens the record, not the list) and hands it to the landing page.
///
/// WHERE THE DRAWER AND THE HEADER COME FROM
/// -----------------------------------------
/// `features/home/h3_app_drawer/.../custom_drawer.dart` builds:
///
///     Row(
///       [ the nav rail  ]          <- the module icons
///       Expanded(
///         Column(
///           CustomAppBar(),        <- the header: bell + avatar + name/role
///           Expanded(
///             IndexedStack(        <- the active module renders HERE
///               index: controller.selectedIndex,
///               children: screens,
///             )
///
/// So a module screen is a LEAF inside that IndexedStack, and the rail and
/// header are its siblings, not its children.
///
/// WHY THIS FILE HOSTS A NAVIGATOR
/// -------------------------------
/// A module that pushes routes must push them into a Navigator that lives
/// INSIDE its IndexedStack pane. `Navigator.of(context)` walks up the tree,
/// so without one here the nearest Navigator is `GetMaterialApp`'s root — and
/// a route pushed there covers the whole window, rail and header included.
/// That is exactly what happened when "Create Database" opened the wizard:
/// the page was correct, it was just drawn on top of the shell instead of
/// inside it.
///
/// Every other module that navigates internally solves it the same way:
///
///   home_responsive_page.dart   Navigator(key: homeNavKey,     …)
///   settings_screen.dart        Navigator(key: settingsKey,    …)
///   custom_tab_view.dart        Navigator(key: …navigatorKey,  …)
///
/// This module's Navigator has no key (Owner 21/10/2026, see below).
///
/// TWO LEVELS OF NAVIGATOR, ON PURPOSE
/// -----------------------------------
///   this one          list  <->  wizard        (survives for the module's life)
///   CreateDatabaseFlow's    details -> access -> review   (one draft's life)
///
/// The inner one is what lets the wizard's cubit be created and disposed with
/// the wizard rather than living as long as the module is open — a half-filled
/// draft should not outlive the flow that made it.
///
/// HOW TO MOUNT IT
/// ---------------
///   1. Add a `Modules.database` case to the drawer's enum, with icon + label.
///   2. In `AppDrawerCubit`, map that case to `const DatabaseModuleEntry()`
///      so it lands in `drawerItems` / the IndexedStack.
///   3. Grant the module in role management so it appears in
///      `allowedDrawerModules` for the signed-in user.
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/layout/app_scroll_behavior.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/pages/database_builder_page.dart';
import 'package:knowticed_plus/features/database/helpers/routes/database_routes.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';

// Owner 21/10/2026: no GlobalKey on the nested Navigator (same as TimeTrackerModuleEntry) — the module can be built twice at once, and a shared key throws "Duplicate GlobalKey".

class DatabaseModuleEntry extends StatefulWidget {
  const DatabaseModuleEntry({super.key});

  @override
  State<DatabaseModuleEntry> createState() => _DatabaseModuleEntryState();
}

class _DatabaseModuleEntryState extends State<DatabaseModuleEntry> {
  /// The record a notification's View asked for (owner 22/10/2026). Taken
  /// once, here, because the routing remounts the module for every View; the
  /// landing page opens it over the list so Back lands on the list.
  final PendingNotificationRecord? _notified = PendingNotificationRecord.take(
    Modules.database,
  );

  @override
  Widget build(BuildContext context) {
    // Who is signed in is NOT passed from here. Every cubit that stamps a
    // person reads `DatabaseSessionBaseRepository` at write time (DB-CREATE-02).
    final Widget landing = DatabaseBuilderPage(notified: _notified);

    // ONE SCROLL STYLE FOR THE WHOLE MODULE.
    //
    // `ScrollConfiguration` is inherited, so wrapping the module root settles
    // it for every list, grid and scroll view under it — db1, db2, db3, and
    // whatever is added next — instead of each page repeating the same
    // `copyWith(scrollbars: false)` and the next one forgetting to.
    //
    // It goes OUTSIDE the Navigator on purpose: routes pushed into
    // this module's Navigator build below it, so the wizard inherits this too.

    // On a phone the drawer is an overlay rather than a persistent rail, so
    // there is no pane to stay inside — pushing to the root navigator is the
    // correct behaviour there. Same guard as HomeResponsivePage.
    //
    // Which is also why this is not the only place the rule is applied: a
    // route pushed to the ROOT navigator is not a descendant of this widget.
    // `CreateDatabaseMetrics.pageScroll` carries it too, per page.
    if (ContextExtension(context).isPhone) return NoScrollbar(child: landing);

    return NoScrollbar(
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) => DatabaseRouter.route<void>(
          DatabaseRoutes.landing,
          builder: (_) => landing,
        ),
      ),
    );
  }
}
