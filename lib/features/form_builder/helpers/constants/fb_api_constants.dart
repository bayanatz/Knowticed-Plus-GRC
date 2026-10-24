/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: fb_api_constants.dart
/// Description: `FormApiConstants`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/network/get_base_url.dart';

abstract class FormApiConstants {
  /// Root path for the Form Builder module.
  /// Combined with getBaseUrl(...) (which prepends "Demo/{companyId}") every
  /// top-level collection below resolves to:
  ///   Demo/{companyId}/Modules/form_builder/...
  static const String moduleBase = 'Modules/form_builder';

  // ---- Top-level (module root) collections ----
  // Use these with getBaseUrl(...). Resolves to:
  //   Demo/{companyId}/Modules/form_builder/{collection}
  static const String forms = '$moduleBase/Forms';
  static const String formResponses = '$moduleBase/Form Responses';
  static const String formPrivacy = '$moduleBase/Form Privacy';
  static const String formGroups = '$moduleBase/Forms Groups';
  // Dedup log for the module's time-driven notifications
  // ("Form Access Ends in 14 Days", "Form Access Has Ended"). One marker per
  // raised notification, keyed `<formId>__<email>__<eventKey>__<dueMillis>`.
  // They are raised by a client-side sweep (FormBuilderNotificationScheduler)
  // because the app has no server cron; without this log every module open
  // would re-send every warning that is currently due.
  static const String notificationLog = '$moduleBase/Notification_Log';

  // ---- Nested subcollection names ----
  // These live under a document of a top-level collection above, so they are
  // NOT prefixed with the module base.
  static const String responses = 'Responses';
  static const String groups = 'Groups';

  // ---- Cloud Storage folder ----
  // Every Storage upload of the module (form images, watermarks, group images,
  // response media) lives under this folder. Use with getBaseUrl(...):
  //   Demo/{companyId}/Modules/form_builder/Storage/...
  static const String storageBase = '$moduleBase/Storage';

  // ---- Full-path convenience getter ----
  // Resolves to: Demo/{companyId}/Modules/form_builder/User Responses
  static String get userResponses => getBaseUrl('$moduleBase/User Responses');
}
