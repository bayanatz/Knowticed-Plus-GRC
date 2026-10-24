/// Module: services / helpers / constants
///
///*************************** FILE INFO ****************************///
/// File Name: services_prefs_keys.dart
/// Purpose: Local-storage keys the create-service wizard writes on one step
///          and reads on a later one. One constant per key, so the phone and
///          the desktop SLA steps cannot read different spellings
///          (SVC-PROV-17: the phone read "limit_availability" while the
///          wizard saved "limitAvailability", so both switches were always
///          saved as off).
/// Author: Amr Mesbah
/// Created at: 22/10/2026
library;

/// Class Name: [ServicesPrefsKeys]
///
/// Purpose: SharedPreferences keys of the create-service wizard.
class ServicesPrefsKeys {
  const ServicesPrefsKeys._();

  /// "Limit availability" switch of the details step.
  static const String limitAvailability = 'limitAvailability';

  /// "Requires approval" switch of the details step.
  static const String requireApproval = 'requireApproval';

  /// SLA percentage of the provider section.
  static const String slaOne = 'sla_one';

  /// SLA percentage of the provider-manager section.
  static const String slaTwo = 'sla_two';

  /// Suffix of a notification section's checkbox key
  /// (SlaNotificationKeys.x + checkedSuffix).
  static const String checkedSuffix = '_checked';
}
