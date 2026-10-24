/// Module: services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: services_manager_sla_ext.dart
/// Purpose: Saves the SLA settings from the SLA screen. The method was
///          removed from [ServicesManagerCubit] while the SLA page still
///          passes it to `SlaNotificationCubit`; it lives here until the page
///          takes the repository directly.
/// Created At: 24/10/2026 (Amr merge)
library;

import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';

extension ServicesManagerSlaData on ServicesManagerCubit {
  Future<void> submitSlaData({
    required String slaOne,
    required String slaTwo,
    required bool notifyRequesterChecked,
    required bool notifyProviderChecked,
    required bool notifyManagerChecked,
    required bool notifyRequesterSwitch0,
    required bool notifyManagerSwitch1,
    required List<String> extraSlaList,
    required List<String> extraSlaTwoList,
    required Map<String, Map<int, bool>> notificationSwitches,
  }) async {
    await repository.saveSlaToPrefs(
      slaOne: slaOne,
      slaTwo: slaTwo,
      notifyRequesterChecked: notifyRequesterChecked,
      notifyProviderChecked: notifyProviderChecked,
      notifyManagerChecked: notifyManagerChecked,
      notifyRequesterSwitch0: notifyRequesterSwitch0,
      notifyManagerSwitch1: notifyManagerSwitch1,
      extraSlaList: extraSlaList,
      extraSlaTwoList: extraSlaTwoList,
      notificationSwitches: notificationSwitches,
    );
  }
}
