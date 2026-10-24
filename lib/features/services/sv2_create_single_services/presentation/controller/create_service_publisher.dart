/// Module: services / sv2_create_single_services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: create_service_publisher.dart
/// Purpose: The last step of the create/edit-service wizard: reads what the
///          wizard staged, builds the service and saves it, then clears the
///          drafts and staged values (rule C1: this logic lived inside the
///          confirmation dialog's button callback).
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:knowticed_plus/features/services/data/data_source/local_data_source/services_prefs_employee.dart';
import 'package:knowticed_plus/features/services/data/data_source/local_data_source/shared_prefs_service_master.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/shared.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Class Name: [CreateServicePublisher]
///
/// Purpose: Publishes the service the wizard built.
class CreateServicePublisher {
  const CreateServicePublisher(this._manager);

  final ServicesManagerCubit _manager;

  /// Function Name: [publish]
  ///
  /// Purpose: Builds the service from the staged wizard values (falling back
  /// to [modelCreate] for anything the user did not revisit) and saves it.
  ///
  /// Parameters:
  /// - [modelCreate]: the service or draft being edited, if any.
  /// - [isEditingExisting]: true when a live service is being edited.
  /// - [isDraft]: true when a draft is being finished.
  /// - [notifyRequesterSwitch0]/[notifyManagerSwitch1]: the first switch of
  ///   the provider and manager notification sections.
  ///
  /// Returns: the saved service, or `null` when the save failed (the drafts
  /// and staged values are then kept so nothing is lost).
  Future<ServicesHistoryModel?> publish({
    required ServicesHistoryModel? modelCreate,
    required bool isEditingExisting,
    required bool isDraft,
    required bool notifyRequesterSwitch0,
    required bool notifyManagerSwitch1,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Every field falls back to the stored model so an edit that skipped a
    // screen does not lose that screen's values.
    final nameEn = await SharedPrefsHelper.getString('service_name_en') ??
        modelCreate?.currentServiceNameEnglish ??
        '';
    final nameAr = await SharedPrefsHelper.getString('service_name_ar') ??
        modelCreate?.currentServiceNameArabic ??
        '';
    final descEn =
        await SharedPrefsHelper.getString('service_description_en') ??
            modelCreate?.currentServiceDescriptionEnglish ??
            '';
    final descAr =
        await SharedPrefsHelper.getString('service_description_ar') ??
            modelCreate?.currentServiceDescriptionArabic ??
            '';
    final duration = await SharedPrefsHelper.getString('duration_value') ??
        modelCreate?.currentDurationOfServices ??
        '';
    final durationUnit = await SharedPrefsHelper.getString('duration_unit') ??
        modelCreate?.currentSelectedDurationUnit ??
        '';
    // Falls back only when the key is absent: a user who removed the picture
    // stages '' and the removed picture does not come back.
    final imageUrl = await SharedPrefsHelper.getString('service_image_url') ??
        modelCreate?.currentImageUrl ??
        '';

    final providers = await SharedPrefsEmployeeHelper.getSelectedEmployees();
    final departments = await SharedPrefsDepartmentsHelper.getDepartments();
    final approvers = await SharedPrefsApprovalHelper.getApprovalCycle();

    final slaOne = await SharedPrefsHelper.getString('sla_one') ??
        modelCreate?.currentSlaOneControllerEnglish ??
        '';
    final slaTwo = await SharedPrefsHelper.getString('sla_two') ??
        modelCreate?.currentSlaTwoControllerEnglish ??
        '';
    final notifyRequesterChecked =
        await SharedPrefsHelper.getBool('Notify Service Requester_checked') ??
            modelCreate?.currentNotifyRequesterChecked ??
            false;
    final notifyProviderChecked =
        await SharedPrefsHelper.getBool('Notify Service Provider_checked') ??
            modelCreate?.currentNotifyProviderChecked ??
            false;
    final notifyManagerChecked =
        await SharedPrefsHelper.getBool('Notify Provider Manager_checked') ??
            modelCreate?.currentNotifyManagerChecked ??
            false;

    // SVC-CREATE-03: a new service gets a Firestore auto id.
    String docId;
    var isNewService = false;
    if (isEditingExisting && modelCreate?.currentId.isNotEmpty == true) {
      docId = modelCreate!.currentId;
    } else if (isDraft &&
        modelCreate?.currentId.isNotEmpty == true &&
        !modelCreate!.currentId.startsWith('draft_') &&
        !modelCreate.currentId.startsWith('User')) {
      docId = modelCreate.currentId;
    } else {
      docId = _manager.newServiceId();
      isNewService = true;
    }

    final limitAvailability =
        await SharedPrefsHelper.getBool(ServicesPrefsKeys.limitAvailability) ??
            (modelCreate?.currentLimitAvailability ?? false);
    final requireApproval =
        await SharedPrefsHelper.getBool(ServicesPrefsKeys.requireApproval) ??
            (modelCreate?.currentRequireApproval ?? false);
    // Absent means active (draft bug #1).
    final isActive = await SharedPrefsHelper.getBool('service_status') ?? true;

    final model = ServicesHistoryFactory.createNew(
      id: docId,
      state: isEditingExisting ? modelCreate!.currentState : 'active',
      status: isActive ? 'active' : 'inactive',
      serviceNameEnglish: nameEn,
      serviceNameArabic: nameAr,
      serviceDescriptionEnglish: descEn,
      serviceDescriptionArabic: descAr,
      durationOfServices: duration,
      selectedDurationUnit: durationUnit,
      imageUrl: imageUrl,
      providerServices: providers,
      selectDepartment: limitAvailability ? departments : const [],
      approvalCycle:
          requireApproval ? approvers : const <ServiceEmployeeModel>[],
      limitAvailability: limitAvailability,
      requireApproval: requireApproval,
      slaOneControllerEnglish: slaOne,
      slaTwoControllerEnglish: slaTwo,
      notifyRequesterChecked: notifyRequesterChecked,
      notifyProviderChecked: notifyProviderChecked,
      notifyManagerChecked: notifyManagerChecked,
      notifyRequesterSwitch0: notifyRequesterSwitch0,
      notifyManagerSwitch1: notifyManagerSwitch1,
      emailRequester: prefs.getString('emailRequester') ?? '',
    );

    final bool ok = isEditingExisting
        ? await _manager.updateService(docId, model)
        : isNewService
            ? await _manager.createService(docId, model)
            : await _manager.saveService(docId, model);
    // A failed write keeps the drafts and staged values.
    if (!ok) return null;

    await SharedPrefsHelper.setString('service_image_url', '');

    // Draft bug #2: remove every draft that fed this service.
    final trackedDraftId = _manager.currentDraftId ?? '';
    final modelDraftId = modelCreate?.currentId ?? '';
    final draftIds = <String>{
      if (modelDraftId.startsWith('draft_')) modelDraftId,
      if (trackedDraftId.startsWith('draft_')) trackedDraftId,
    };
    for (final draftId in draftIds) {
      await _manager.discardPublishedDraft(draftId);
      await SharedPrefsServiceMaster.removeDraftById(draftId);
    }
    _manager.clearCurrentDraft();

    // Reset the status only after the draft cleanup.
    await SharedPrefsHelper.setBool('service_status', true);

    if (!isEditingExisting) {
      for (final key in const [
        'sla_one',
        'sla_two',
        'service_name_en',
        'service_name_ar',
        'service_description_en',
        'service_description_ar',
        'duration_value',
        'duration_unit',
      ]) {
        await SharedPrefsHelper.setString(key, '');
      }
    }

    _manager.clearDocService();
    _manager.getAllServices();
    return model;
  }
}
