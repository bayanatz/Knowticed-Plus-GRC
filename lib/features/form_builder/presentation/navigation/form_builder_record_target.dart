/// Module: form_builder_module/presentation
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_record_target.dart
/// Description: Which form screen a notification's View opens.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Owner, 22/10/2026: a notification's View opens the place you act on it.
/// Every Form Builder notification about a form stores the form's id as its
/// `Request_Id`; `NotificationRouting` hands it over as a
/// `PendingNotificationRecord`, and `FormBuilderHomeScreen` resolves it here
/// once its lists have loaded — the same `FormEntity`s a card tap opens, with
/// the access and submission data the home already worked out.
///
///   ResultScreen (owner: a response came in) → the form's Results
///   anything else, form is the reader's own  → the form's details
///   anything else, form was sent to them     → the form itself (fill / view
///                                              their response), on the
///                                              Requested or Submissions tab
///   GroupScreen                              → nothing (no member-facing
///                                              group page exists)
///
/// A form the reader can no longer see (deleted, access not started) is not in
/// the lists, so the home stays as it is.
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/notification/domain/enums/form_builder/form_builder_notification_pages.dart';

/// The screen to push for a form.
enum FormBuilderRecordScreen {
  /// `ResultScreen` — the owner's pending / submitted responses.
  results,

  /// `FormDetailsScreen` — the owner's view of their own form.
  details,

  /// `FormSubmissionsScreen` — a recipient fills the form or views their
  /// response.
  form,
}

class FormBuilderRecordTarget {
  const FormBuilderRecordTarget({
    required this.form,
    required this.screen,
    required this.tabIndex,
  });

  final FormEntity form;
  final FormBuilderRecordScreen screen;

  /// The home tab to sit under the pushed screen (0 Publish, 2 Requested,
  /// 3 Submissions), so Back lands on the list the form belongs to.
  final int tabIndex;

  /// Function Name: [resolve]
  ///
  /// Purpose: Find [formId] in the home's lists and pick its screen for the
  /// notification page [pageKey]. Null when there is nothing to open.
  static FormBuilderRecordTarget? resolve({
    required String formId,
    required String pageKey,
    required List<FormEntity> published,
    required List<FormEntity> requested,
    required List<FormEntity> submitted,
  }) {
    final FormBuilderNotificationPage? page =
        FormBuilderNotificationPage.fromKey(pageKey);
    if (page == FormBuilderNotificationPage.groupScreen) return null;

    final FormEntity? own = _find(published, formId);
    if (own != null) {
      return FormBuilderRecordTarget(
        form: own,
        screen: page == FormBuilderNotificationPage.resultScreen
            ? FormBuilderRecordScreen.results
            : FormBuilderRecordScreen.details,
        tabIndex: 0,
      );
    }
    final FormEntity? received = _find(requested, formId);
    if (received != null) {
      return FormBuilderRecordTarget(
          form: received, screen: FormBuilderRecordScreen.form, tabIndex: 2);
    }
    final FormEntity? answered = _find(submitted, formId);
    if (answered != null) {
      return FormBuilderRecordTarget(
          form: answered, screen: FormBuilderRecordScreen.form, tabIndex: 3);
    }
    return null;
  }

  static FormEntity? _find(List<FormEntity> forms, String id) {
    for (final FormEntity form in forms) {
      if (form.id == id) return form;
    }
    return null;
  }
}
