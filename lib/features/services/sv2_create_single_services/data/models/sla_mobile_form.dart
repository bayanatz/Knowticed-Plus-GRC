/// Module: services / sv2_create_single_services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: sla_mobile_form.dart
/// Purpose: The values of the phone SLA & notifications step: the two SLA
///          percentages, the three "notify" checkboxes and the two switches.
///          Plain values with fixed keys — never translated text (Provider
///          rule 5).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

/// Class Name: [SlaMobileForm]
///
/// Purpose: What the phone SLA step saves.
class SlaMobileForm {
  const SlaMobileForm({
    this.slaOne = '',
    this.slaTwo = '',
    this.notifyRequester = true,
    this.notifyProvider = true,
    this.notifyManager = true,
    this.whenRequestedAndApproved = false,
    this.whenStatusChanges = false,
  });

  /// SVC-PROV-04: the saved values of the service being edited.
  factory SlaMobileForm.fromModel(ServicesHistoryModel? model) {
    if (model == null) return const SlaMobileForm();
    return SlaMobileForm(
      slaOne: model.currentSlaOneControllerEnglish,
      slaTwo: model.currentSlaTwoControllerEnglish,
      notifyRequester: model.currentNotifyRequesterChecked,
      notifyProvider: model.currentNotifyProviderChecked,
      notifyManager: model.currentNotifyManagerChecked,
      whenRequestedAndApproved: model.currentNotifyRequesterSwitch0,
      whenStatusChanges: model.currentNotifyManagerSwitch1,
    );
  }

  /// SLA percentage of the provider section.
  final String slaOne;

  /// SLA percentage of the provider-manager section.
  final String slaTwo;
  final bool notifyRequester;
  final bool notifyProvider;
  final bool notifyManager;

  /// Manager switch "when the service is requested and approved".
  final bool whenRequestedAndApproved;

  /// Manager switch "when the service status changes".
  final bool whenStatusChanges;

  SlaMobileForm copyWith({
    String? slaOne,
    String? slaTwo,
    bool? notifyRequester,
    bool? notifyProvider,
    bool? notifyManager,
    bool? whenRequestedAndApproved,
    bool? whenStatusChanges,
  }) {
    return SlaMobileForm(
      slaOne: slaOne ?? this.slaOne,
      slaTwo: slaTwo ?? this.slaTwo,
      notifyRequester: notifyRequester ?? this.notifyRequester,
      notifyProvider: notifyProvider ?? this.notifyProvider,
      notifyManager: notifyManager ?? this.notifyManager,
      whenRequestedAndApproved:
          whenRequestedAndApproved ?? this.whenRequestedAndApproved,
      whenStatusChanges: whenStatusChanges ?? this.whenStatusChanges,
    );
  }
}
