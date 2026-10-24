/// Module: services / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: services_notification_events.dart
/// Purpose: Part of the services / domain / enums module.
///
/// The Services event list moved to the shared per-module catalog at
/// `features/notification/domain/enums/services_module/services_events.dart`,
/// where it now carries its default bilingual title/body and its
/// placeholder set alongside the key. Every module lives beside it in the
/// same folder, and NotificationCatalog walks them all.
/// The keys and value names are unchanged, so this is a pure re-export —
/// nothing at a call site needs to change. Import the canonical path in
/// new code and delete this file once no import points here.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

export 'package:knowticed_plus/features/notification/domain/enums/services/services_events.dart'
    show ServicesNotificationEvent;
