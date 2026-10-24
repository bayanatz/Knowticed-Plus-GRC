/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_notifier.dart
/// Description: `FormBuilderNotifier`, the notifications the Form Builder
///              sends, as an interface. Use cases and cubits receive it by
///              injection instead of creating a notification sender or
///              importing another feature's notification code.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

/// The notifications the Form Builder sends.
abstract class FormBuilderNotifier {
  /// Method Name: [notifyResponse]
  ///
  /// Purpose: tells the form owner that a response arrived (or was re-sent).
  ///
  /// Parameters:
  /// - [formId]: the form.
  /// - [ownerEmail]: the form owner.
  /// - [formNameEn] / [formNameAr]: the form title in both languages.
  /// - [isResubmission]: true for an edited, re-sent answer.
  ///
  /// Returns: [Future] that completes when the notification is queued.
  Future<void> notifyResponse({
    required String formId,
    required String ownerEmail,
    required String formNameEn,
    String? formNameAr,
    required bool isResubmission,
  });

  /// Method Name: [notifyReminder]
  ///
  /// Purpose: sends a "please fill out the form" reminder to one person.
  ///
  /// Parameters:
  /// - [formId]: the form.
  /// - [recipientEmail]: the person reminded.
  /// - [formNameEn] / [formNameAr]: the form title in both languages.
  ///
  /// Returns: [Future] that completes when the notification is queued.
  Future<void> notifyReminder({
    required String formId,
    required String recipientEmail,
    required String formNameEn,
    String? formNameAr,
  });
}
