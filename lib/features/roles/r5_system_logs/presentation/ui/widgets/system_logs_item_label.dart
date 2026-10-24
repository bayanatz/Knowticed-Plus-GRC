/// Module: roles / r5_system_logs / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: system_logs_item_label.dart
/// Purpose: The on-screen (localised) column title of a `SystemLogsItems`.
/// Author: Knowticed Plus team
/// Created: 21/10/2026
library;

import 'package:knowticed_plus/features/roles/r5_system_logs/domain/enums/system_logs_items.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Owner 21/10/2026: column titles on screen come from S. `SystemLogsItems.name`
/// stays English — it is the CSV header and the value key of the column picker.
extension SystemLogsItemsLabel on SystemLogsItems {
  String label(S s) {
    switch (this) {
      case SystemLogsItems.firstName:
        return s.firstName;
      case SystemLogsItems.middleName:
        return s.middleName;
      case SystemLogsItems.lastName:
        return s.lastName;
      case SystemLogsItems.role:
        return s.role;
      case SystemLogsItems.country:
        return s.country;
      case SystemLogsItems.city:
        return s.city;
      case SystemLogsItems.date:
        return s.date;
      case SystemLogsItems.time:
        return s.time;
      case SystemLogsItems.lat:
        return s.latitude;
      case SystemLogsItems.long:
        return s.longitude;
      case SystemLogsItems.module:
        return s.module;
      case SystemLogsItems.action:
        return s.action;
    }
  }
}
