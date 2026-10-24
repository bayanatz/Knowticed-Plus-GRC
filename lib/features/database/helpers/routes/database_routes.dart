/// Module: database / helpers / routes
///
///*************************** FILE INFO ****************************///
/// File Name: database_routes.dart
/// Description: Declares `DatabaseRoutes` and `DatabaseRouter`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// Every screen of the Database module is opened through [DatabaseRouter]
/// with a name from [DatabaseRoutes] (rule 17). The pages keep their typed
/// `open(...)` helpers, so a caller still gets a typed result back; only the
/// route itself is built here.
///
/// WHY `push(DatabaseRouter.route(...))` AND NOT `pushNamed`: the module's
/// screens are pushed onto whichever navigator is nearest — the module's own
/// pane navigator on a tablet, the root or a nav-bar tab navigator on a
/// phone, or a wizard's nested navigator. `pushNamed` only works on a
/// navigator whose `onGenerateRoute` knows these names, and the tab
/// navigators are not ours to change. Building the route here gives each one
/// a name (visible to observers, analytics and `popUntil`) without making
/// navigation depend on which navigator happens to be nearest.
library;

import 'package:flutter/material.dart';

/// The names of the Database module's routes.
abstract final class DatabaseRoutes {
  // ── db1: databases ────────────────────────────────────────────────────────
  static const String landing = '/database';
  static const String create = '/database/create';
  static const String createDetails = '/database/create/details';
  static const String createAccess = '/database/create/access';
  static const String createReview = '/database/create/review';

  // ── db2: database details ────────────────────────────────────────────────
  static const String details = '/database/details';
  static const String edit = '/database/edit';
  static const String access = '/database/access';
  static const String editAccess = '/database/access/edit';
  static const String editAccessPeople = '/database/access/edit/people';
  static const String editAccessReview = '/database/access/edit/review';

  // ── db3: tables ──────────────────────────────────────────────────────────
  static const String createTable = '/database/table/create';
  static const String tableDetails = '/database/table/details';
  static const String tableData = '/database/table/data';
  static const String editTableData = '/database/table/data/edit';
  static const String tableDataPreview = '/database/table/data/preview';
  static const String tableComments = '/database/table/comments';
  static const String tableAccess = '/database/table/access';
  static const String tableAccessPeople = '/database/table/access/people';
  static const String tableAccessReview = '/database/table/access/review';
}

/// Builds the Database module's routes.
abstract final class DatabaseRouter {
  /// Function Name: [route]
  ///
  /// Purpose: The one place the module creates a page route.
  ///
  /// Parameters: [name] a [DatabaseRoutes] constant; [builder] the screen.
  ///
  /// Returns: [Route<T>] that resolves with what the screen pops.
  static Route<T> route<T>(String name, {required WidgetBuilder builder}) =>
      MaterialPageRoute<T>(
        settings: RouteSettings(name: name),
        builder: builder,
      );
}
