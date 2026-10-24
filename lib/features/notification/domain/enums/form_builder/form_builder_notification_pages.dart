/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_notification_pages.dart
/// Description: Target pages a notification from the Form Builder module can
///          navigate to (Firestore field `name_of_page`).
/// Author: Amr Mesbah
/// Created at: 12/10/2026
///
/// Pattern: one `<module>_notification_pages.dart` per module folder, beside
/// that module's event enum. Values are the real screen widget names in
/// `features/form_builder_module`, so a key can always be traced to a class.
///
/// ⚠️ Like the other modules, the tap handlers route by MODULE today
/// (`NotificationRouting.moduleForStoredKey` → `Modules.formBuilder`); these
/// keys are stored so a future deep-link router can open the exact screen.
///
/// ⚠️ RULE: Never write page names as raw strings. Always use this enum.
library;

enum FormBuilderNotificationPage {
  /// The module landing page (published / drafts / requested / submissions).
  homeScreen('FormBuilderHomeScreen'),

  /// One form — what a recipient opens to fill it in.
  formDetailsScreen('FormDetailsScreen'),

  /// The owner's results page (pending / submitted users).
  resultScreen('ResultScreen'),

  /// The owner's list of groups.
  groupScreen('GroupScreen'),
  ;

  const FormBuilderNotificationPage(this.key);

  /// The exact string stored in Firestore (`name_of_page`).
  final String key;

  static FormBuilderNotificationPage? fromKey(String key) {
    for (final p in values) {
      if (p.key == key) return p;
    }
    return null;
  }
}
