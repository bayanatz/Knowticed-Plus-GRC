// The `Request_Id` a Database notification stores — what its View opens
// (owner 22/10/2026). The Database module root splits it back on '/'.
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_service.dart';

void main() {
  group('DatabaseNotificationService.recordId', () {
    test('a database on its own is just its id', () {
      expect(DatabaseNotificationService.recordId('db1'), 'db1');
      expect(DatabaseNotificationService.recordId(' db1 ', ''), 'db1');
    });

    test('a table is <databaseId>/<tableId>', () {
      expect(DatabaseNotificationService.recordId('db1', 't9'), 'db1/t9');
    });

    test('no database → empty, so View stays on the list', () {
      expect(DatabaseNotificationService.recordId(''), '');
      expect(DatabaseNotificationService.recordId('  ', 't9'), '');
    });
  });
}
