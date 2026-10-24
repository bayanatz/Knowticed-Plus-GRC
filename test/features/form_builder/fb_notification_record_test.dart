/// Owner, 22/10/2026: a Form Builder notification's View opens its form.
///
/// 1. Every notify method about a form stores the form id as `Request_Id`;
///    group events store none (no member-facing group page exists).
/// 2. `FormBuilderRecordTarget.resolve` picks the screen and the tab under it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/data/models/users_model.dart';
import 'package:knowticed_plus/features/form_builder/presentation/navigation/form_builder_record_target.dart';
import 'package:knowticed_plus/features/notification/data/repository/form_builder_notification_service.dart';
import 'package:knowticed_plus/features/notification/domain/enums/form_builder/form_builder_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_event.dart';

class _Sent {
  const _Sent(this.pageKey, this.receiver, this.requestId);
  final String pageKey;
  final String receiver;
  final String requestId;
}

FormEntity _form(String id, FormStatus status) => FormEntity(
      id: id,
      status: status,
      formHeadModel: FormHeadData(
        title: 'Form $id',
        description: '',
        accessManagement: '',
        orientation: 'portrait',
      ),
      pages: [],
      createDate: DateTime(2026, 10, 1),
      personEntity: PersonEntity(
        department: '',
        id: 'owner@co.com',
        isSelected: false,
        image: '',
        arabicName: '',
        englishName: '',
        titleEnglish: '',
        titleArabic: '',
        phone: '',
      ),
    );

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  group('FormBuilderNotificationService stores the form id', () {
    final List<_Sent> sent = <_Sent>[];
    late FbSendEvent original;

    setUp(() {
      sent.clear();
      original = FormBuilderNotificationService.sendEvent;
      FormBuilderNotificationService.sendEvent = ({
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
    tearDown(() => FormBuilderNotificationService.sendEvent = original);

    const String formId = 'form-7';
    const String you = 'you@co.com';
    final String details = FormBuilderNotificationPage.formDetailsScreen.key;
    final String results = FormBuilderNotificationPage.resultScreen.key;

    test('Form Assigned (first publish)', () async {
      await FormBuilderNotificationService.notifyAccessListChanged(
        formId: formId,
        before: null,
        after: UsersModel(
          emails: <String>[you],
          status: <String>['active'],
        ),
        formNameEn: 'F',
      );
      expect(sent, hasLength(1));
      expect(sent.single.requestId, formId);
      expect(sent.single.pageKey, details);
    });

    test('Form Shared With You — one per recipient, each with the id',
        () async {
      await FormBuilderNotificationService.notifyFormShared(
        formId: formId,
        recipients: <String>[you, 'b@co.com', ' '],
        formNameEn: 'F',
        accessEnd: DateTime(2027),
      );
      expect(
          sent.map((_Sent s) => s.receiver).toSet(), <String>{you, 'b@co.com'});
      expect(sent.every((_Sent s) => s.requestId == formId), isTrue);
    });

    test('Reminder', () async {
      await FormBuilderNotificationService.notifyReminder(
          formId: formId, recipientEmail: you, formNameEn: 'F');
      expect(sent.single.requestId, formId);
      expect(sent.single.pageKey, details);
    });

    test('Submission Received → the owner, on Results', () async {
      await FormBuilderNotificationService.notifyResponse(
        formId: formId,
        ownerEmail: you,
        formNameEn: 'F',
        isResubmission: false,
      );
      expect(sent.first.requestId, formId);
      expect(sent.first.pageKey, results);
    });

    test('Response Resubmitted → the owner, on Results', () async {
      await FormBuilderNotificationService.notifyResponse(
        formId: formId,
        ownerEmail: you,
        formNameEn: 'F',
        isResubmission: true,
      );
      expect(sent.single.requestId, formId);
      expect(sent.single.pageKey, results);
    });

    test('Access Ends in 14 Days / Access Has Ended', () async {
      await FormBuilderNotificationService.notifyAccessEndsIn14Days(
        formId: formId,
        recipientEmail: you,
        senderEmail: 'sweep@co.com',
        formNameEn: 'F',
        accessEnd: DateTime(2027),
      );
      await FormBuilderNotificationService.notifyAccessEnded(
        formId: formId,
        recipientEmail: you,
        senderEmail: 'sweep@co.com',
        formNameEn: 'F',
      );
      expect(sent.map((_Sent s) => s.requestId), <String>[formId, formId]);
    });

    test('group events carry no record id', () async {
      await FormBuilderNotificationService.notifyAddedToGroup(
          members: <String>[you], groupName: 'G');
      await FormBuilderNotificationService.notifyRemovedFromGroup(
          members: <String>[you], groupName: 'G');
      await FormBuilderNotificationService.notifyGroupRenamed(
          members: <String>[you], oldGroupName: 'G', newGroupName: 'H');
      expect(sent, hasLength(3));
      expect(sent.every((_Sent s) => s.requestId.isEmpty), isTrue);
    });
  });

  group('FormBuilderRecordTarget.resolve', () {
    final FormEntity mine = _form('mine', FormStatus.publish);
    final FormEntity toFill = _form('toFill', FormStatus.requestedForms);
    final FormEntity done = _form('done', FormStatus.submissions);

    FormBuilderRecordTarget? resolve(
            String id, FormBuilderNotificationPage p) =>
        FormBuilderRecordTarget.resolve(
          formId: id,
          pageKey: p.key,
          published: <FormEntity>[mine],
          requested: <FormEntity>[toFill],
          submitted: <FormEntity>[done],
        );

    test('a response on my form opens its Results (Publish tab)', () {
      final FormBuilderRecordTarget t =
          resolve('mine', FormBuilderNotificationPage.resultScreen)!;
      expect(t.form, same(mine));
      expect(t.screen, FormBuilderRecordScreen.results);
      expect(t.tabIndex, 0);
    });

    test('a form sent to me opens the form (Requested tab)', () {
      final FormBuilderRecordTarget t =
          resolve('toFill', FormBuilderNotificationPage.formDetailsScreen)!;
      expect(t.form, same(toFill));
      expect(t.screen, FormBuilderRecordScreen.form);
      expect(t.tabIndex, 2);
    });

    test('a form I already answered opens my response (Submissions tab)', () {
      final FormBuilderRecordTarget t =
          resolve('done', FormBuilderNotificationPage.homeScreen)!;
      expect(t.form, same(done));
      expect(t.screen, FormBuilderRecordScreen.form);
      expect(t.tabIndex, 3);
    });

    test('my own form on a details page opens its details', () {
      final FormBuilderRecordTarget t =
          resolve('mine', FormBuilderNotificationPage.formDetailsScreen)!;
      expect(t.screen, FormBuilderRecordScreen.details);
    });

    test('a form I cannot see, or a group page, opens nothing', () {
      expect(resolve('gone', FormBuilderNotificationPage.formDetailsScreen),
          isNull);
      expect(resolve('mine', FormBuilderNotificationPage.groupScreen), isNull);
    });
  });
}
