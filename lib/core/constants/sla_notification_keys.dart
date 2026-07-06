// ******************* FILE INFO *******************
// File Name: sla_notification_keys
// Description: Stable string keys for SLA notification sections (map / prefs
//   keys — NOT display strings).
// Module: core / constants / services_management
// *************************************************

/// Canonical keys for the three SLA notification toggles. These are used as
/// map keys and SharedPreferences keys (the persisted contract), so the string
/// values must never change — they are centralised here to remove magic-string
/// literals from widgets (§15).
class SlaNotificationKeys {
  const SlaNotificationKeys._();

  static const String serviceRequester = 'Notify Service Requester';
  static const String serviceProvider = 'Notify Service Provider';
  static const String providerManager = 'Notify Provider Manager';
}
