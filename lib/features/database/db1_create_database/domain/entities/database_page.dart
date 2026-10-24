/// Module: database / db1_create_database / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: database_page.dart
/// Description: Declares `DatabaseListQuery`, `DatabasePageCursor` and
///              `DatabasePage`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// The Database Builder list reads one tab at a time, a page at a time, and
/// counts each tab on the server (DB-CREATE-08). It used to read the newest
/// 200 records of everything and filter on the device, so deleted records and
/// drafts pushed live ones out of the list and every tab count was wrong.
library;

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';

/// Which records one tab shows. Always narrowed further to what the viewer
/// created or is named in.
class DatabaseListQuery {
  const DatabaseListQuery({
    required this.statuses,
    this.accessType,
    this.creatorOnly = false,
  });

  final List<DatabaseStatus> statuses;
  final DatabaseAccessType? accessType;

  /// Only the viewer's own records: Personal databases and drafts.
  final bool creatorOnly;
}

/// Where the next page starts: just after this record in newest-first order.
class DatabasePageCursor {
  const DatabasePageCursor({required this.createdAt, required this.id});

  final DateTime createdAt;
  final String id;
}

/// One page of the list.
class DatabasePage {
  const DatabasePage({required this.items, this.next});

  final List<DatabaseEntity> items;

  /// Null on the last page.
  final DatabasePageCursor? next;

  bool get hasMore => next != null;
}
