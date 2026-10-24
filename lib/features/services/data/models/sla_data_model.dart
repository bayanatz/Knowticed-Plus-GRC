/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: sla_data_model.dart
/// Purpose: DTO holding SLA + notification configuration values for the
///          services module.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

class SlaDataModel {
  final String slaOne;
  final String slaTwo;

  final bool notifyRequesterChecked;
  final bool notifyProviderChecked;
  final bool notifyManagerChecked;

  final bool notifyRequesterSwitch0;
  final bool notifyManagerSwitch1;

  final Map<String, Map<int, bool>> notificationSwitches;

  final List<String> extraSlaValues;
  final List<String> extraSlaTwoValues;

  const SlaDataModel({
    required this.slaOne,
    required this.slaTwo,
    required this.notifyRequesterChecked,
    required this.notifyProviderChecked,
    required this.notifyManagerChecked,
    required this.notifyRequesterSwitch0,
    required this.notifyManagerSwitch1,
    required this.notificationSwitches,
    required this.extraSlaValues,
    required this.extraSlaTwoValues,
  });
}
