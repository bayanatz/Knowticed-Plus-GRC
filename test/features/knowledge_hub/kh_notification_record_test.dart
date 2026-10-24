/// Owner, 22/10/2026: a Knowledge Hub notification's View opens its document.
///
/// 1. Every notify method stores the document's knowledgeId as `Request_Id`.
/// 2. The stored page picks the view (approval / submission / published).
/// 3. The opener pushes the list, then the document, so Back lands on the list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/notifications/knowledge_hub_notification_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/pages/knowledge_hub_record_opener.dart';
import 'package:knowticed_plus/features/notification/domain/enums/knowledge_hub/knowledge_hub_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_event.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';

class _Sent {
  const _Sent(this.pageKey, this.receiver, this.requestId);
  final String pageKey;
  final String receiver;
  final String requestId;
}

void main() {
  group('KnowledgeHubNotificationService stores the document id', () {
    final List<_Sent> sent = <_Sent>[];
    late KhSendEvent original;

    setUp(() {
      sent.clear();
      original = KnowledgeHubNotificationService.sendEvent;
      KnowledgeHubNotificationService.sendEvent = ({
        required NotificationEvent event,
        required String pageKey,
        required String senderEmail,
        required String receiverEmail,
        required bool isArabic,
        Map<TemplateVariable, String> variables = const {},
        Map<TemplateVariable, String> variablesAr = const {},
        bool isPinned = false,
        String requestId = '',
      }) async {
        sent.add(_Sent(pageKey, receiverEmail, requestId));
        return true;
      };
    });
    tearDown(() => KnowledgeHubNotificationService.sendEvent = original);

    const String id = 'k-42';
    const String me = 'me@co.com';
    const String you = 'you@co.com';

    final Map<String, Future<Object> Function()> calls =
        <String, Future<Object> Function()>{
      'submitted': () =>
          KnowledgeHubNotificationService.notifyAuthorOfSubmission(
              documentId: id,
              senderEmail: me,
              authorEmail: you,
              documentNameEn: 'D',
              documentNameAr: 'د',
              isArabic: false),
      'review request': () =>
          KnowledgeHubNotificationService.notifyApproverOfReviewRequest(
              documentId: id,
              senderEmail: me,
              approverEmail: you,
              documentNameEn: 'D',
              documentNameAr: '',
              isArabic: false),
      'review request (many)': () =>
          KnowledgeHubNotificationService.notifyApproversOfReviewRequest(
              documentId: id,
              senderEmail: me,
              approverEmails: <String>[you, ' $you ', ''],
              documentNameEn: 'D',
              documentNameAr: '',
              isArabic: false),
      'reminder': () => KnowledgeHubNotificationService.remindOfPendingReview(
          documentId: id,
          senderEmail: me,
          receiverEmail: you,
          documentNameEn: 'D',
          documentNameAr: '',
          isArabic: false),
      'approved': () => KnowledgeHubNotificationService.notifyAuthorOfDecision(
          documentId: id,
          approved: true,
          approverEmail: me,
          authorEmail: you,
          documentNameEn: 'D',
          documentNameAr: '',
          isArabic: false),
      'rejected': () => KnowledgeHubNotificationService.notifyAuthorOfDecision(
          documentId: id,
          approved: false,
          approverEmail: me,
          authorEmail: you,
          documentNameEn: 'D',
          documentNameAr: '',
          isArabic: false),
      'revision': () =>
          KnowledgeHubNotificationService.notifyAuthorOfRevisionRequest(
              documentId: id,
              senderEmail: me,
              authorEmail: you,
              documentNameEn: 'D',
              documentNameAr: '',
              isArabic: false),
      'published': () => KnowledgeHubNotificationService.notifyOfPublication(
          documentId: id,
          senderEmail: me,
          receiverEmail: you,
          documentNameEn: 'D',
          documentNameAr: '',
          isArabic: false),
      'announced': () => KnowledgeHubNotificationService.announcePublication(
          documentId: id,
          senderEmail: me,
          audienceEmails: <String>[you],
          documentNameEn: 'D',
          documentNameAr: '',
          isArabic: false),
      'removed': () => KnowledgeHubNotificationService.notifyOfRemoval(
          documentId: id,
          senderEmail: me,
          receiverEmail: you,
          documentNameEn: 'D',
          documentNameAr: '',
          isArabic: false),
      'expiring': () =>
          KnowledgeHubNotificationService.notifyOwnerOfUpcomingExpiry(
              documentId: id,
              senderEmail: me,
              ownerEmail: you,
              documentNameEn: 'D',
              documentNameAr: '',
              endDateEn: '1/1/2027',
              isArabic: false),
      'archived': () => KnowledgeHubNotificationService.notifyOwnerOfArchival(
          documentId: id,
          senderEmail: me,
          ownerEmail: you,
          documentNameEn: 'D',
          documentNameAr: '',
          isArabic: false),
      'inquiry': () => KnowledgeHubNotificationService.notifyOwnerOfInquiry(
          documentId: id,
          commenterEmail: me,
          ownerEmail: you,
          documentNameEn: 'D',
          documentNameAr: '',
          isArabic: false),
    };

    calls.forEach((String name, Future<Object> Function() call) {
      test('$name → Request_Id is the knowledgeId', () async {
        await call();
        expect(sent, hasLength(1), reason: 'one recipient, sent once');
        expect(sent.single.requestId, id);
        expect(sent.single.receiver, you);
      });
    });

    test('the reviewer reminder can open the approval details', () async {
      await KnowledgeHubNotificationService.remindOfPendingReview(
          documentId: id,
          senderEmail: me,
          receiverEmail: you,
          documentNameEn: 'D',
          documentNameAr: '',
          isArabic: false,
          page: KnowledgeHubNotificationPage.approvalsDetails);
      expect(sent.single.pageKey,
          KnowledgeHubNotificationPage.approvalsDetails.key);
    });
  });

  group('KnowledgeHubRecordOpener.viewFor', () {
    test('approval pages open the approval details', () {
      expect(KnowledgeHubRecordOpener.viewFor('ApprovalsDetails'),
          KhRecordView.approval);
      expect(
          KnowledgeHubRecordOpener.viewFor('Approvals'), KhRecordView.approval);
    });
    test('submission pages open the submission details', () {
      expect(KnowledgeHubRecordOpener.viewFor('SubmissionDetails'),
          KhRecordView.submission);
      expect(KnowledgeHubRecordOpener.viewFor('Submissions'),
          KhRecordView.submission);
    });
    test('anything else opens the published document', () {
      expect(KnowledgeHubRecordOpener.viewFor('ViewKnowledgeDetails'),
          KhRecordView.document);
      expect(KnowledgeHubRecordOpener.viewFor('ViewKnowledgeHub'),
          KhRecordView.document);
      expect(KnowledgeHubRecordOpener.viewFor('somethingOld'),
          KhRecordView.document);
    });
  });

  group('KnowledgeHubRecordOpener.open', () {
    late KhDocumentFetcher originalFetch;
    final List<String> fetched = <String>[];

    setUp(() {
      fetched.clear();
      originalFetch = KnowledgeHubRecordOpener.fetch;
      KnowledgeHubRecordOpener.fetch = (String id) async {
        fetched.add(id);
        return id == 'k1'
            ? CreateKnowledgeModel.fromJson(<String, dynamic>{
                'knowledgeId': <String>['k1'],
                'nameEnglish': <String>['Doc'],
              }, 'firestore-doc')
            : null;
      };
      KnowledgeHubRecordOpener.debugScreenBuilder =
          (KhRecordView view, CreateKnowledgeModel? doc) => Text(doc == null
              ? 'list:${view.name}'
              : 'details:${view.name}:${doc.currentKnowledgeId}');
    });
    tearDown(() {
      KnowledgeHubRecordOpener.fetch = originalFetch;
      KnowledgeHubRecordOpener.debugScreenBuilder = null;
    });

    Future<BuildContext> pumpLanding(WidgetTester tester) async {
      late BuildContext context;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (BuildContext c) {
          context = c;
          return const Text('landing');
        }),
      ));
      return context;
    }

    Future<void> back(WidgetTester tester) async {
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }

    for (final (String page, KhRecordView view) in <(String, KhRecordView)>[
      ('ApprovalsDetails', KhRecordView.approval),
      ('SubmissionDetails', KhRecordView.submission),
    ]) {
      testWidgets('$page: list, then the document; Back lands on the list',
          (WidgetTester tester) async {
        final BuildContext context = await pumpLanding(tester);
        await KnowledgeHubRecordOpener.open(
            context, PendingNotificationRecord(recordId: 'k1', pageKey: page));
        await tester.pumpAndSettle();

        expect(fetched, <String>['k1']);
        expect(find.text('details:${view.name}:k1'), findsOneWidget);
        await back(tester);
        expect(find.text('list:${view.name}'), findsOneWidget);
        await back(tester);
        expect(find.text('landing'), findsOneWidget);
      });
    }

    testWidgets('a published document opens over the landing page',
        (WidgetTester tester) async {
      final BuildContext context = await pumpLanding(tester);
      await KnowledgeHubRecordOpener.open(
          context,
          const PendingNotificationRecord(
              recordId: 'k1', pageKey: 'ViewKnowledgeDetails'));
      await tester.pumpAndSettle();

      expect(find.text('details:document:k1'), findsOneWidget);
      await back(tester);
      expect(find.text('landing'), findsOneWidget);
    });

    testWidgets('a document that is gone leaves the reader on the list',
        (WidgetTester tester) async {
      final BuildContext context = await pumpLanding(tester);
      await KnowledgeHubRecordOpener.open(
          context,
          const PendingNotificationRecord(
              recordId: 'gone', pageKey: 'ApprovalsDetails'));
      await tester.pumpAndSettle();

      expect(find.text('list:approval'), findsOneWidget);
      expect(find.textContaining('details:'), findsNothing);
    });
  });
}
