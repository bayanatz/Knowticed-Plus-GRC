/// Module: services / sv2_create_single_services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: sla_notification_model.dart
/// Purpose: Data model for the SLA notification screen: the SLA values as
///          plain strings plus the checkbox/switch states. Rule "No text
///          controllers in models or cubits": the TextEditingControllers
///          live in the page (sla_screen_page_part2.dart).
/// Author: Amr Mesbah
/// Date: 30/8/2025
/// Dependencies: none
/// Revision History:
///   - 30/8/2025 (Amr Mesbah): Initial version.
///   - 02/07/2026 (Knowticed Team): Moved controller add/remove/listener
///     lifecycle methods here from SlaNotificationCubit (fix item 3).
///   - 22/10/2026 (Amr Mesbah): Controllers moved to the page; plain values.
library;

class SlaNotificationModel {
  // SLA values (the page's text fields write into these).
  String slaOne = '';
  String slaTwo = '';
  List<String> extraSla = [];
  List<String> extraSlaTwo = [];

  // Checkbox states
  bool notifyRequesterChecked = true;
  bool notifyProviderChecked = true;
  bool notifyManagerChecked = true;

  // Switch states
  bool notifyRequesterSwitch0 = false;
  bool notifyManagerSwitch1 = false;

  // Validation flags
  bool isInvalidNumber = false;
  bool isInvalidNumberTwo = false;

  // Notification switches map
  Map<String, Map<int, bool>> notificationSwitches = {};

  // Other fields
  String? formatDate;
  static const int maxSlaInputs = 5;

  /// Adds an empty extra SLA value (list 1). Returns true if one was added.
  bool addExtraSla() {
    if (extraSla.length >= maxSlaInputs) return false;
    extraSla.add('');
    return true;
  }

  /// Adds an empty extra SLA value (list 2). Returns true if one was added.
  bool addExtraSlaTwo() {
    if (extraSlaTwo.length >= maxSlaInputs) return false;
    extraSlaTwo.add('');
    return true;
  }

  /// Removes the extra SLA value (list 1) at [index].
  bool removeExtraSla(int index) {
    if (index < 0 || index >= extraSla.length) return false;
    extraSla.removeAt(index);
    return true;
  }

  /// Removes the extra SLA value (list 2) at [index].
  bool removeExtraSlaTwo(int index) {
    if (index < 0 || index >= extraSlaTwo.length) return false;
    extraSlaTwo.removeAt(index);
    return true;
  }
}
