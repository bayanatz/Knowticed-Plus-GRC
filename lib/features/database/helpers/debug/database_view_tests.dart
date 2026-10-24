/// Module: database / helpers / debug
///
///*************************** FILE INFO ****************************///
/// File Name: database_view_tests.dart
/// Purpose: DEBUG ONLY — sends the signed-in user one Database notification
///          per View landing, each pointing at a REAL database / table, so
///          "View opens the record" can be tried by hand.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Owner, 22/10/2026: approved test notifications in the demo accounts. Reads
/// records only; writes nothing but notification documents. Goes through
/// `DatabaseNotificationService` itself, so template, `pageKey` and the
/// `Request_Id` encoding (`<dbId>` / `<dbId>/<tableId>`) are the real ones.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/create_database_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_session_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_page.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/repository/create_table_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_service.dart';

/// Function Name: [sendDatabaseViewTests]
///
/// Purpose: One notification per Database View landing, to [receiverEmail]:
///   Database Created          → Database list
///   Table Created             → that database's details
///   Access Updated (database) → the database's access list
///   Access Updated (table)    → that table's access list
///   Viewable Fields Updated   → that table's access list (TableAccessPage)
///
/// The table kinds are skipped (with a debugPrint) when no visible database
/// has a table. Never throws.
///
/// Return type: [Future<int>] — how many were stored.
Future<int> sendDatabaseViewTests({
  required String receiverEmail,
  required bool isArabic,
}) async {
  try {
    final String to = receiverEmail.trim();
    if (to.isEmpty) {
      debugPrint('[DatabaseViewTests] no receiver — nothing sent');
      return 0;
    }

    final String? viewerId =
        const DatabaseSessionRepository().signedInEmployeeId;
    if (viewerId == null || viewerId.isEmpty) {
      debugPrint('[DatabaseViewTests] no signed-in employee — nothing sent');
      return 0;
    }

    final Either<Failure, DatabasePage> listed =
        await CreateDatabaseRepository().listDatabasesPage(
      viewerId: viewerId,
      query: const DatabaseListQuery(
        statuses: <DatabaseStatus>[DatabaseStatus.active],
      ),
      limit: 10,
    );
    final List<DatabaseEntity> databases = listed.fold((Failure f) {
      debugPrint('[DatabaseViewTests] list failed: ${f.message}');
      return const <DatabaseEntity>[];
    }, (DatabasePage page) => page.items);
    if (databases.isEmpty) {
      debugPrint(
        '[DatabaseViewTests] no active database visible — '
        'nothing sent',
      );
      return 0;
    }

    // Prefer a database that has a table, so every kind can be sent.
    final CreateTableRepository tablesRepo = CreateTableRepository();
    DatabaseEntity database = databases.first;
    DatabaseTableEntity? table;
    for (final DatabaseEntity d in databases) {
      final List<DatabaseTableEntity> tables =
          (await tablesRepo.fetchTables(d.id)).fold(
        (_) => const <DatabaseTableEntity>[],
        (List<DatabaseTableEntity> t) => t,
      );
      if (tables.isNotEmpty) {
        database = d;
        table = tables.first;
        break;
      }
    }

    const String actor = DatabaseNotificationService.systemSender;
    const LocalizedName actorName = (en: 'View test', ar: 'اختبار العرض');
    final LocalizedName dbName = (en: database.titleEn, ar: database.titleAr);
    final List<String> recipients = <String>[to];
    int sent = 0;

    sent += await DatabaseNotificationService.databaseCreated(
      databaseId: database.id,
      actorEmail: actor,
      actorName: actorName,
      databaseName: dbName,
      recipients: recipients,
    );

    if (await DatabaseNotificationService.accessUpdated(
      databaseId: database.id,
      actorEmail: actor,
      recipientEmail: to,
      databaseName: dbName,
      tableName: DatabaseNotificationService.allTables,
    )) {
      sent++;
    }

    if (table == null) {
      debugPrint(
        '[DatabaseViewTests] no database with a table — skipped '
        'Table Created, table Access Updated, Viewable Fields Updated',
      );
      return sent;
    }

    final LocalizedName tableName = (en: table.nameEn, ar: table.nameAr);

    sent += await DatabaseNotificationService.tableCreated(
      databaseId: database.id,
      actorEmail: actor,
      actorName: actorName,
      databaseName: dbName,
      tableName: tableName,
      recipients: recipients,
    );

    if (await DatabaseNotificationService.accessUpdated(
      databaseId: database.id,
      tableId: table.id,
      actorEmail: actor,
      recipientEmail: to,
      databaseName: dbName,
      tableName: tableName,
    )) {
      sent++;
    }

    sent += await DatabaseNotificationService.viewableFieldsUpdated(
      databaseId: database.id,
      tableId: table.id,
      actorEmail: actor,
      tableName: tableName,
      recipients: recipients,
    );

    debugPrint(
      '[DatabaseViewTests] sent $sent for "${database.titleEn}" '
      '(${database.id}) / "${table.nameEn}" (${table.id})',
    );
    return sent;
  } catch (e) {
    debugPrint('[DatabaseViewTests] failed: $e');
    return 0;
  }
}
