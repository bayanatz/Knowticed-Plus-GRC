/// Module: services / sv2_create_single_services / data / data_source
///
///*************************** FILE INFO ****************************///
/// File Name: sla_draft_model_builder.dart
/// Purpose: Builds the draft service from what the create wizard has staged
///          so far. Moved out of SlaNotificationCubit (rule C7: the cubit was
///          over 800 lines).
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:knowticed_plus/features/services/data/data_source/local_data_source/services_prefs_employee.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/shared.dart';
import 'package:knowticed_plus/features/services/domain/enums/service_display_status.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/data/models/sla_notification_model.dart';

/// Class Name: [SlaDraftModelBuilder]
///
/// Purpose: Assembles a draft [ServicesHistoryModel] from the staged values.
class SlaDraftModelBuilder {
  const SlaDraftModelBuilder._();

  /// Function Name: [build]
  ///
  /// Purpose: Assemble the model a draft should be saved as, from everything the
  /// wizard has staged so far.
  ///
  /// ADDED 26/8/2026, generalising what was PATH B of [_saveDraftData].
  ///
  /// The wizard spreads one service across three places by the time the user
  /// reaches this screen: page 1's fields sit in SharedPrefs, the provider /
  /// department / approver selections sit in their own prefs helpers, and the
  /// SLA and notification values are live on this screen's controllers. Only the
  /// combination is a complete service, which is why saving `currentModel`
  /// alone produced an empty draft.
  ///
  /// Every staged value falls back to the one already on [base] when it
  /// is empty, so this is safe for the other case too: resuming a real service
  /// keeps its stored fields wherever the wizard has not staged a replacement.
  ///
  /// Returns: [ServicesHistoryModel] carrying [docId] as its id, so the
  /// draft record lands against the document this flow is already using.
  ///
  /// Parameters:
  /// - [base]: the service or draft being edited, if any.
  /// - [docId]: the document this flow already writes to.
  /// - [form]: the SLA screen's values.
  static Future<ServicesHistoryModel> build({
    required ServicesHistoryModel? base,
    required String? docId,
    required SlaNotificationModel form,
  }) async {
    /// Staged value wins when it has content; otherwise keep what is stored.
    String prefer(String staged, String stored) =>
        staged.trim().isNotEmpty ? staged : stored;

    final nameEn = prefer(
      await SharedPrefsHelper.getString('service_name_en') ?? '',
      base?.currentServiceNameEnglish ?? '',
    );
    final nameAr = prefer(
      await SharedPrefsHelper.getString('service_name_ar') ?? '',
      base?.currentServiceNameArabic ?? '',
    );
    final descEn = prefer(
      await SharedPrefsHelper.getString('service_description_en') ?? '',
      base?.currentServiceDescriptionEnglish ?? '',
    );
    final descAr = prefer(
      await SharedPrefsHelper.getString('service_description_ar') ?? '',
      base?.currentServiceDescriptionArabic ?? '',
    );
    final durationVal = prefer(
      await SharedPrefsHelper.getString('duration_value') ?? '',
      base?.currentDurationOfServices ?? '',
    );
    final durationUnit = prefer(
      await SharedPrefsHelper.getString('duration_unit') ?? '',
      base?.currentSelectedDurationUnit ?? '',
    );
    final imageUrl = prefer(
      await SharedPrefsHelper.getString('service_image_url') ?? '',
      base?.currentImageUrl ?? '',
    );

    // ✅ FIX (draft bug #1): `== true` made a missing pref mean "inactive".
    // Default to active, same as updateAndSaveModel and the create form.
    final status = (await SharedPrefsHelper.getBool('service_status') ?? true)
        ? 'active'
        : 'inactive';

    // These three helpers all return non-nullable lists, so an empty one means
    // "nothing staged" rather than "not asked yet" — hence the isNotEmpty test
    // rather than a null check.
    final List<ServiceEmployeeModel> stagedProviders =
        await SharedPrefsEmployeeHelper.getSelectedEmployees();
    final List<ServiceEmployeeModel> providers = stagedProviders.isNotEmpty
        ? stagedProviders
        : (base?.currentProviderServices ?? const <ServiceEmployeeModel>[]);

    final List<String> stagedDepartments =
        await SharedPrefsDepartmentsHelper.getDepartments();
    final List<String> departments = stagedDepartments.isNotEmpty
        ? stagedDepartments
        : (base?.currentSelectDepartment ?? const <String>[]);

    final List<ServiceEmployeeModel> stagedCycle =
        await SharedPrefsApprovalHelper.getApprovalCycle();
    final List<ServiceEmployeeModel> approvalCycle = stagedCycle.isNotEmpty
        ? stagedCycle
        : (base?.currentApprovalCycle ?? const <ServiceEmployeeModel>[]);

    // SLA and notification values come from this screen's own controllers
    // rather than from prefs: they are the live edit, and the prefs copy was
    // only written moments ago from these same fields.
    return ServicesHistoryFactory.createNew(
      id: docId ?? 'draft_${DateTime.now().millisecondsSinceEpoch}',
      state: ServiceDisplayStatus.draftState,
      status: status,
      serviceNameEnglish: nameEn,
      serviceNameArabic: nameAr,
      serviceDescriptionEnglish: descEn,
      serviceDescriptionArabic: descAr,
      durationOfServices: durationVal,
      selectedDurationUnit: durationUnit,
      imageUrl: imageUrl,
      providerServices: providers,
      selectDepartment: departments,
      approvalCycle: approvalCycle,
      limitAvailability: departments.isNotEmpty,
      requireApproval: approvalCycle.isNotEmpty,
      slaOneControllerEnglish: form.slaOne.trim(),
      slaTwoControllerEnglish: form.slaTwo.trim(),
      notifyRequesterChecked: form.notifyRequesterChecked,
      notifyProviderChecked: form.notifyProviderChecked,
      notifyManagerChecked: form.notifyManagerChecked,
      notifyRequesterSwitch0: form.notifyRequesterSwitch0,
      notifyManagerSwitch1: form.notifyManagerSwitch1,
    );
  }
}
