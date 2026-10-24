/// Module: services / sv2_create_single_services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: sla_mobile_cubit.dart
/// Purpose: The phone SLA step's Submit and Save-for-later. Submit stages
///          the screen's SLA and notification values and publishes with the
///          SAME CreateServicePublisher as desktop, so a reopened draft
///          becomes a new service and the draft is removed (SVC-PROV-16),
///          and departments / approvers are saved only when their switch is
///          on (SVC-PROV-17). Moved here from the page (Provider rule 2).
/// Author: Knowticed Team
/// Created At: 02/07/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): replaces SlaCubit (sv12) — its unused
///     seedFromDocRawJson and submitPercentagesAndSwitches are gone (rules
///     24, 28); the build-and-save logic moved in from the page.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/network/api_constants.dart'
    show SlaNotificationKeys;
import 'package:knowticed_plus/features/services/data/data_source/local_data_source/services_prefs_employee.dart';
import 'package:knowticed_plus/features/services/data/data_source/local_data_source/shared_prefs_service_master.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/shared.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_prefs_keys.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/data/models/sla_mobile_form.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/create_service_publisher.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/sla_mobile_state.dart';

class SlaMobileCubit extends Cubit<SlaMobileState> {
  // B5 FIX: guard against emit-after-close (StateError).
  @override
  void emit(SlaMobileState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Publishes the service the wizard built (shared with desktop).
  final CreateServicePublisher publisher;

  SlaMobileCubit({required this.publisher}) : super(const SlaMobileIdle());

  /// Stores the screen's values where the publisher reads them.
  Future<void> _stage(SlaMobileForm form) async {
    await SharedPrefsHelper.setString(
      ServicesPrefsKeys.slaOne,
      form.slaOne.trim(),
    );
    await SharedPrefsHelper.setString(
      ServicesPrefsKeys.slaTwo,
      form.slaTwo.trim(),
    );
    await SharedPrefsHelper.setBool(
      SlaNotificationKeys.serviceRequester + ServicesPrefsKeys.checkedSuffix,
      form.notifyRequester,
    );
    await SharedPrefsHelper.setBool(
      SlaNotificationKeys.serviceProvider + ServicesPrefsKeys.checkedSuffix,
      form.notifyProvider,
    );
    await SharedPrefsHelper.setBool(
      SlaNotificationKeys.providerManager + ServicesPrefsKeys.checkedSuffix,
      form.notifyManager,
    );
  }

  /// Function Name: [submit]
  ///
  /// Purpose: Creates the service, finishes a draft, or updates the service
  /// being edited ([editing]).
  Future<void> submit({
    required ServicesHistoryModel? editing,
    required SlaMobileForm form,
  }) async {
    emit(const SlaMobileBusy());
    try {
      await _stage(form);
      final isDraft = editing?.isDraftState ?? false;
      final isEdit = editing != null && !isDraft;
      final saved = await publisher.publish(
        modelCreate: editing,
        isEditingExisting: isEdit,
        isDraft: isDraft,
        notifyRequesterSwitch0: form.whenRequestedAndApproved,
        notifyManagerSwitch1: form.whenStatusChanges,
      );
      if (saved == null) {
        emit(const SlaMobileFailed('publish returned null'));
        return;
      }
      emit(SlaMobilePublished(wasEdit: isEdit));
    } catch (e, st) {
      svcLog('SLA submit failed', error: e, stackTrace: st);
      emit(SlaMobileFailed('$e'));
    }
  }

  /// Function Name: [saveDraft]
  ///
  /// Purpose: SVC-PROV-09 — "Save for later" stores a DRAFT only (no write to
  /// the live service list).
  Future<void> saveDraft({
    required ServicesHistoryModel? editing,
    required SlaMobileForm form,
  }) async {
    emit(const SlaMobileBusy());
    try {
      final approvers = await SharedPrefsApprovalHelper.getApprovalCycle();
      final model = ServicesHistoryFactory.createNew(
        id: '',
        state: 'draft',
        status: 'draft',
        serviceNameEnglish:
            await SharedPrefsHelper.getString('service_name_en') ?? '',
        serviceNameArabic:
            await SharedPrefsHelper.getString('service_name_ar') ?? '',
        serviceDescriptionEnglish:
            await SharedPrefsHelper.getString('service_description_en') ?? '',
        serviceDescriptionArabic:
            await SharedPrefsHelper.getString('service_description_ar') ?? '',
        durationOfServices:
            await SharedPrefsHelper.getString('duration_value') ?? '',
        selectedDurationUnit:
            await SharedPrefsHelper.getString('duration_unit') ?? '',
        providerServices:
            await SharedPrefsEmployeeHelper.getSelectedEmployees(),
        selectDepartment: await SharedPrefsDepartmentsHelper.getDepartments(),
        approvalCycle: approvers
            .map(
              (e) => ServiceEmployeeModel(
                id: e.id ?? '',
                state: 'pending',
                firstName: e.firstName,
                middleName: e.middleName,
                lastName: e.lastName,
                email: e.email,
                gender: e.gender,
                title: e.title,
              ),
            )
            .toList(),
        slaOneControllerEnglish: form.slaOne.trim(),
        slaTwoControllerEnglish: form.slaTwo.trim(),
        notifyRequesterChecked: form.notifyRequester,
        notifyProviderChecked: form.notifyProvider,
        notifyManagerChecked: form.notifyManager,
        notifyRequesterSwitch0: form.whenRequestedAndApproved,
        notifyManagerSwitch1: form.whenStatusChanges,
      );
      if (editing != null) {
        final updated = model.copyWith(id: editing.currentId);
        await SharedPrefsServiceMaster.updateDraft(updated, updated);
      } else {
        await SharedPrefsServiceMaster.saveDraft(model);
      }
      emit(const SlaMobileDraftSaved());
    } catch (e, st) {
      svcLog('SLA draft save failed', error: e, stackTrace: st);
      emit(SlaMobileFailed('$e'));
    }
  }
}
