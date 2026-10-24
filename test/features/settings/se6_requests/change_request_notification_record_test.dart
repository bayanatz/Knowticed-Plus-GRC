/// Module: test / settings / se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: change_request_notification_record_test.dart
/// Purpose: Owner 22/10/2026 — a change-request notification's View opens the
///          request itself. Submitted / approved / rejected each save the
///          request's id (`Request_Id`) — the submitted one gets the id
///          Firestore minted in the same batch — and the stored page key picks
///          the reviewer's screen or the requester's.
/// Created at: 22/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/notification/data/repository/settings_notification_service.dart';
import 'package:knowticed_plus/features/notification/domain/enums/settings/settings_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/settings/settings_notification_pages.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/user_management_details_request.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/settings_notification_record.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/data_source/remote_data_source/requests_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/repository/requests_repository.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/details_request.dart';

class _UnusedFirestore extends Fake implements FirebaseFirestore {}

/// Every Firestore call the repository makes on these paths, faked.
class _FakeRemote extends RequestsRemoteDataSource {
  _FakeRemote({this.stored}) : super(firestore: _UnusedFirestore());

  final ChangeRequest? stored;
  int _next = 0;

  @override
  Future<bool> employeeExists(String employeeId) async => true;

  @override
  Future<List<String>> createAll(List<ChangeRequest> requests) async =>
      <String>[for (final ChangeRequest _ in requests) 'new-${++_next}'];

  @override
  Future<ChangeRequest?> read(String requestId) async => stored;

  @override
  Future<List<String>> approveAtomically({
    required String requestId,
    required String employeeId,
    required List<FieldChange> changes,
    String reason = '',
  }) async =>
      <String>[];

  @override
  Future<void> updateStatus(String requestId, RequestStatus status,
      {String reason = ''}) async {}
}

class _Sent {
  const _Sent(this.event, this.pageKey, this.requestId);
  final SettingsNotificationEvent event;
  final String pageKey;
  final String requestId;
}

const ChangeRequest _stored = ChangeRequest(
  id: 'req-77',
  section: 'Personal Information',
  employeeId: 'emp-7',
  employeeEmail: 'mona@knowticed.com',
  employeeName: 'Mona',
  changes: <FieldChange>[
    FieldChange(fieldName: 'phone', oldValue: '1', newValue: '2'),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<_Sent> sent = <_Sent>[];

  setUp(() {
    sent.clear();
    SettingsNotificationService.debugReviewersOverride =
        (String _) async => <String>['amr@knowticed.com'];
    SettingsNotificationService.debugSendOverride = ({
      required SettingsNotificationEvent event,
      required String pageKey,
      required List<String> receiverEmails,
      required String requestId,
    }) async {
      sent.add(_Sent(event, pageKey, requestId));
      return receiverEmails.length;
    };
  });
  tearDown(() {
    SettingsNotificationService.debugSendOverride = null;
    SettingsNotificationService.debugReviewersOverride = null;
  });

  group('the change request id travels with every notification', () {
    test('submitted: each request in the batch carries its own new id',
        () async {
      final RequestsCubit cubit = RequestsCubit(
        repository: RequestsRepository(remoteDataSource: _FakeRemote()),
      );
      final bool ok = await cubit.submitMany(
        parts: <({String section, List<FieldChange> changes})>[
          (section: 'Health Insurance', changes: _stored.changes),
          (section: 'Emergency Contact', changes: _stored.changes),
        ],
        employeeId: 'emp-7',
        employeeName: 'Mona',
        employeeEmail: 'mona@knowticed.com',
        requestNote: '',
      );

      expect(ok, isTrue);
      expect(sent.map((_Sent s) => s.requestId), <String>['new-1', 'new-2']);
      expect(
        sent.map(
            (_Sent s) => SettingsNotificationRecord.isReviewPage(s.pageKey)),
        <bool>[true, true],
      );
      await cubit.close();
    });

    test('approved and rejected carry the decided request\'s id', () async {
      final RequestsCubit cubit = RequestsCubit(
        repository:
            RequestsRepository(remoteDataSource: _FakeRemote(stored: _stored)),
      );
      await cubit.approve(
        request: _stored,
        employeeId: 'emp-7',
        approverEmail: 'amr@knowticed.com',
        approverEmployeeId: 'emp-1',
      );
      await cubit.reject(
        _stored,
        approverEmail: 'amr@knowticed.com',
        approverEmployeeId: 'emp-1',
        rejectionReason: 'Wrong number',
      );

      expect(sent.map((_Sent s) => s.requestId), <String>['req-77', 'req-77']);
      expect(sent.map((_Sent s) => s.pageKey).toSet(),
          <String>{SettingsNotificationPage.myRequestPage.key});
      await cubit.close();
    });

    test('the service trims the id', () async {
      await SettingsNotificationService.changeRequestApproved(
        requestId: '  req-77 ',
        section: 'Personal Information',
        employeeEmail: 'mona@knowticed.com',
        approverEmail: 'amr@knowticed.com',
      );
      expect(sent.single.requestId, 'req-77');
    });
  });

  group('SettingsNotificationRecord.pageFor', () {
    test('review pages open the reviewer\'s Approve / Reject screen', () {
      for (final SettingsNotificationPage page in <SettingsNotificationPage>[
        SettingsNotificationPage.previewChangesPage,
        SettingsNotificationPage.previewHealthInsuranceChangesPage,
      ]) {
        final Widget w = SettingsNotificationRecord.pageFor(
            requestId: 'req-77', pageKey: page.key);
        expect(w, isA<UserManagementDetailsRequestSettings>());
        expect((w as UserManagementDetailsRequestSettings).requestId, 'req-77');
      }
    });

    test('the requester\'s pages open their own request', () {
      final Widget w = SettingsNotificationRecord.pageFor(
          requestId: 'req-77',
          pageKey: SettingsNotificationPage.myRequestPage.key);
      expect(w, isA<DetailsRequestSettings>());
      expect((w as DetailsRequestSettings).requestId, 'req-77');
    });
  });
}
