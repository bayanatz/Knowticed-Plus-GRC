/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_notifier_impl.dart
/// Description: `FormBuilderNotifierImpl`, the [FormBuilderNotifier] that
///              sends through `FormBuilderNotificationService`. Registered
///              once in the Form Builder's dependency injection.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_notifier.dart';
import 'package:knowticed_plus/features/notification/data/repository/form_builder_notification_service.dart';

/// Sends the Form Builder notifications.
class FormBuilderNotifierImpl implements FormBuilderNotifier {
  const FormBuilderNotifierImpl();

  @override
  Future<void> notifyResponse({
    required String formId,
    required String ownerEmail,
    required String formNameEn,
    String? formNameAr,
    required bool isResubmission,
  }) async {
    await FormBuilderNotificationService.notifyResponse(
      formId: formId,
      ownerEmail: ownerEmail,
      formNameEn: formNameEn,
      formNameAr: formNameAr,
      isResubmission: isResubmission,
    );
  }

  @override
  Future<void> notifyReminder({
    required String formId,
    required String recipientEmail,
    required String formNameEn,
    String? formNameAr,
  }) async {
    await FormBuilderNotificationService.notifyReminder(
      formId: formId,
      recipientEmail: recipientEmail,
      formNameEn: formNameEn,
      formNameAr: formNameAr,
    );
  }
}
