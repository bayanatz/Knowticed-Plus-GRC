/// Module: test / services
///
///*************************** FILE INFO ****************************///
/// File Name: services_notification_record_test.dart
/// Purpose: Owner 22/10/2026 — a Services notification's View opens the
///          request itself. Every send saves the request's id (`Request_Id`),
///          the stored page key picks whose view opens (approver / provider /
///          requester), and the request is loaded by that id.
/// Created at: 22/10/2026
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/services/domain/entities/parent_service_details.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_keys.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/services/services_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/services/services_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/routing/notification_deep_link.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_notification_record.dart';

class _Sent {
  const _Sent(this.event, this.pageKey, this.requestId);
  final ServicesNotificationEvent event;
  final String pageKey;
  final String requestId;
}

/// Only `getRequestServiceDocById` is used by the loader.
class _FakeRepo extends Fake implements CreateServicesRepository {
  _FakeRepo(this.docs, {this.throws = false});
  final Map<String, Map<String, dynamic>> docs;
  final bool throws;
  final List<String> reads = <String>[];

  @override
  Future<Map<String, dynamic>?> getRequestServiceDocById(String docId) async {
    reads.add(docId);
    if (throws) throw StateError('offline');
    return docs[docId];
  }
}

const String _id = 'REQ-2026-0042';

void main() {
  group('every Services send saves the request id', () {
    final List<_Sent> sent = <_Sent>[];

    setUp(() {
      sent.clear();
      ServicesNotificationService.debugSendOverride = ({
        required ServicesNotificationEvent event,
        required String pageKey,
        required String senderEmail,
        required String receiverEmail,
        required bool isArabic,
        required String requestId,
        required Map<TemplateVariable, String> variables,
        Map<TemplateVariable, String>? variablesAr,
      }) async {
        sent.add(_Sent(event, pageKey, requestId));
        return true;
      };
    });
    tearDown(() => ServicesNotificationService.debugSendOverride = null);

    test('all nine methods, id trimmed', () async {
      const String raw = '  $_id ';
      await const ServicesNotificationService().notifyApproverOfNewRequest(
          requestId: raw,
          senderEmail: 's',
          approverEmail: 'a',
          serviceName: 'n',
          requesterName: 'r',
          isArabic: false);
      await const ServicesNotificationService().notifyRequesterOfSubmission(
          requestId: raw,
          senderEmail: 's',
          requesterEmail: 'r',
          serviceName: 'n',
          isArabic: false);
      for (final bool approved in <bool>[true, false]) {
        await const ServicesNotificationService().notifyRequesterOfDecision(
            requestId: raw,
            approved: approved,
            approverEmail: 'a',
            requesterEmail: 'r',
            serviceName: 'n',
            approverName: 'x',
            isArabic: false);
      }
      for (final bool done in <bool>[true, false]) {
        await const ServicesNotificationService().notifyRequesterOfProgress(
            requestId: raw,
            isDone: done,
            senderEmail: 's',
            requesterEmail: 'r',
            serviceName: 'n',
            isArabic: false);
      }
      await const ServicesNotificationService().notifyProviderOfAssignment(
          requestId: raw,
          senderEmail: 's',
          providerEmail: 'p',
          serviceName: 'n',
          isArabic: false);
      await const ServicesNotificationService().notifyOfSla(
          requestId: raw,
          event: ServicesNotificationEvent.slaBreachedManager,
          senderEmail: 's',
          receiverEmail: 'm',
          serviceName: 'n',
          isArabic: false);
      await const ServicesNotificationService().notifyManagerOfPendingReview(
          requestId: raw,
          senderEmail: 's',
          managerEmail: 'm',
          serviceName: 'n',
          isArabic: false);
      await const ServicesNotificationService().notifyProviderOfCancellation(
          requestId: raw,
          senderEmail: 's',
          providerEmail: 'p',
          serviceName: 'n',
          isArabic: false);
      await const ServicesNotificationService().notifyProviderOfCompletion(
          requestId: raw,
          senderEmail: 's',
          providerEmail: 'p',
          serviceName: 'n',
          isArabic: false);

      expect(sent, hasLength(11));
      expect(sent.map((_Sent s) => s.requestId).toSet(), <String>{_id});
    });

    test('approver / provider pages open the matching view', () async {
      await const ServicesNotificationService().notifyApproverOfNewRequest(
          requestId: _id,
          senderEmail: 's',
          approverEmail: 'a',
          serviceName: 'n',
          requesterName: 'r',
          isArabic: false);
      await const ServicesNotificationService().notifyProviderOfAssignment(
          requestId: _id,
          senderEmail: 's',
          providerEmail: 'p',
          serviceName: 'n',
          isArabic: false);
      await const ServicesNotificationService().notifyRequesterOfSubmission(
          requestId: _id,
          senderEmail: 's',
          requesterEmail: 'r',
          serviceName: 'n',
          isArabic: false);

      expect(
        sent.map((_Sent s) => ServicesNotificationRecord.viewFor(s.pageKey)),
        <ServicesRecordView>[
          ServicesRecordView.approver,
          ServicesRecordView.provider,
          ServicesRecordView.requester,
        ],
      );
    });
  });

  group('ServicesNotificationRecord.viewFor', () {
    test('page key → view → the list under it', () {
      expect(
        ServicesNotificationRecord.viewFor(
            ServicesNotificationPage.approvalRequestCard.key),
        ServicesRecordView.approver,
      );
      expect(
        ServicesNotificationRecord.viewFor(
            ServicesNotificationPage.serviceProviderDashboard.key),
        ServicesRecordView.provider,
      );
      expect(
        ServicesNotificationRecord.viewFor(
            ServicesNotificationPage.requestServicesToggle.key),
        ServicesRecordView.requester,
      );
      expect(ServicesNotificationRecord.viewFor('Unknown'),
          ServicesRecordView.requester);

      expect(ServicesRecordView.approver.section,
          NotificationServicesSection.approvals);
      expect(ServicesRecordView.provider.section,
          NotificationServicesSection.providerDashboard);
      expect(ServicesRecordView.requester.section,
          NotificationServicesSection.requests);
    });
  });

  group('ServicesNotificationRecord.load', () {
    Future<ParentServiceDetails> names(String parentServiceId) async =>
        ParentServiceDetails(
          nameEnglish: 'Laptop for $parentServiceId',
          nameArabic: 'حاسوب',
          duration: '2',
          unit: 'days',
        );

    test('loads the request by id and fills its names', () async {
      final _FakeRepo repo = _FakeRepo(<String, Map<String, dynamic>>{
        _id: <String, dynamic>{
          ServicesHistoryKeys.kParentServiceId: <String>['svc-9'],
          ServicesHistoryKeys.kEmailRequester: <String>['mona@x.com'],
          ServicesHistoryKeys.kState: <String>['pending'],
        },
      });

      final ServicesHistoryModel? model = await ServicesNotificationRecord.load(
          repository: repo, recordId: _id, fetchNames: names);

      expect(repo.reads, <String>[_id]);
      expect(model, isNotNull);
      expect(model!.currentId, _id);
      expect(model.currentState, 'pending');
      expect(model.currentServiceNameEnglish, 'Laptop for svc-9');
    });

    test('a deleted request or a failed read opens nothing', () async {
      expect(
        await ServicesNotificationRecord.load(
            repository: _FakeRepo(<String, Map<String, dynamic>>{}),
            recordId: _id,
            fetchNames: names),
        isNull,
      );
      expect(
        await ServicesNotificationRecord.load(
            repository:
                _FakeRepo(<String, Map<String, dynamic>>{}, throws: true),
            recordId: _id,
            fetchNames: names),
        isNull,
      );
    });

    test('names failing still opens the request', () async {
      final ServicesHistoryModel? model = await ServicesNotificationRecord.load(
        repository: _FakeRepo(<String, Map<String, dynamic>>{
          _id: <String, dynamic>{
            ServicesHistoryKeys.kParentServiceId: <String>['svc-9'],
          },
        }),
        recordId: _id,
        fetchNames: (String parentServiceId) => throw StateError('offline'),
      );
      expect(model?.currentId, _id);
    });
  });
}
