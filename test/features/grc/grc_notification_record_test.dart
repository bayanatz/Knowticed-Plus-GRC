/// Module: GRC
///
///*************************** FILE INFO ****************************///
/// File Name: grc_notification_record_test.dart
/// Purpose: A GRC notification's View opens its record (Owner, 22/10/2026):
///          the record path written into `Request_Id` reads back the same,
///          and every GRC send stores one.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/grc/helpers/grc_notification_record.dart';

void main() {
  group('GrcNotificationRecord', () {
    test('module round-trips', () {
      final r =
          GrcNotificationRecord.parse(GrcNotificationRecord.module('m1'))!;
      expect(r.kind, GrcRecordKind.module);
      expect(r.moduleId, 'm1');
    });

    test('policy round-trips', () {
      final r = GrcNotificationRecord.parse(
          GrcNotificationRecord.policy('m1', 'p1'))!;
      expect(r.kind, GrcRecordKind.policy);
      expect((r.moduleId, r.policyId), ('m1', 'p1'));
    });

    test('control round-trips', () {
      final r = GrcNotificationRecord.parse(
          GrcNotificationRecord.control('m1', 'p1', 'c1'))!;
      expect(r.kind, GrcRecordKind.control);
      expect((r.moduleId, r.policyId, r.controlId), ('m1', 'p1', 'c1'));
    });

    test('request round-trips', () {
      final r = GrcNotificationRecord.parse(
          GrcNotificationRecord.request('m1', 'r1'))!;
      expect(r.kind, GrcRecordKind.request);
      expect((r.moduleId, r.requestId), ('m1', 'r1'));
    });

    test('a missing part writes nothing, so View keeps the module list', () {
      expect(GrcNotificationRecord.policy('m1', ''), '');
      expect(GrcNotificationRecord.control('', 'p1', 'c1'), '');
      expect(GrcNotificationRecord.request('m1', '  '), '');
    });

    test('ids it did not write are ignored', () {
      for (final String raw in <String>[
        '',
        'abc123',
        'policy:m1',
        'control:m1/p1',
        'module:m1/extra',
        'request:/r1',
        'unknown:m1',
      ]) {
        expect(GrcNotificationRecord.parse(raw), isNull, reason: raw);
      }
    });
  });

  // Every GRC notification must carry its record, or its View falls back to
  // the module list. Each send in these services goes through
  // `sendEventToAll` (with `requestId:`) or the file's `_send` (with
  // `recordId:`), so count them against each other.
  group('every GRC send stores a record', () {
    const List<String> senders = <String>[
      'lib/features/grc/grc11_module/data/services/grc_module_notification_service.dart',
      'lib/features/grc/grc13_policy/data/services/grc_policy_notification_service.dart',
      'lib/features/grc/grc5_control/data/services/grc_control_notification_service.dart',
      'lib/features/grc/grc4_assignment_control/data/services/grc_evidence_notification_service.dart',
      'lib/features/grc/data/services/grc_assignee_notification_service.dart',
    ];
    for (final String path in senders) {
      test(path.split('/').last, () {
        final String src = File(path).readAsStringSync();
        final int sends = '      _send('.allMatches(src).length +
            'AppNotificationSender.sendEventToAll('.allMatches(src).length;
        final int withRecord =
            'recordId: GrcNotificationRecord.'.allMatches(src).length +
                'requestId: GrcNotificationRecord.'.allMatches(src).length +
                'requestId: recordId,'.allMatches(src).length;
        expect(sends, greaterThan(0));
        expect(withRecord, sends);
      });
    }
  });
}
