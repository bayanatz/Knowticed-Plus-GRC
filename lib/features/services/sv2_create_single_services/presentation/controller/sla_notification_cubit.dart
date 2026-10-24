/// Module: services / sv2_create_single_services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: sla_notification_cubit.dart
/// Purpose: Business logic for the SLA notification screen. Requires a
///          CreateServicesRepository via constructor injection (no
///          default/fallback instantiation) and never imports cloud_firestore
///          directly — all persistence goes through the injected repository.
///          Holds the SLA values as plain strings; the page owns the
///          TextEditingControllers and reports the text here.
/// Author: Amr Mesbah
/// Date: 30/8/2025
/// Dependencies: flutter_bloc, sla_notification_state.dart,
///              sla_notification_model.dart, CreateServicesRepository
/// Revision History:
///   - 30/8/2025 (Amr Mesbah): Initial version.
///   - 02/07/2026 (Knowticed Team): Removed default repo instantiation
///     (now constructor-required); removed cloud_firestore import; moved
///     TextEditingController add/remove/dispose into SlaNotificationModel.
///   - 22/10/2026 (Amr Mesbah): No text controllers in models or cubits —
///     the model keeps plain values and the page owns the controllers.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/sla_notification_state.dart';
import 'package:knowticed_plus/features/services/data/utils/shared.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/data/data_source/local_data_source/services_prefs_employee.dart';

import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/domain/enums/service_display_status.dart';
import 'package:knowticed_plus/features/services/data/data_source/local_data_source/shared_prefs_service_master.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/data/data_source/sla_draft_model_builder.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/data/models/sla_notification_model.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

class SlaNotificationCubit extends Cubit<SlaNotificationState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  // Function types for dependencies
  final Future<void> Function({
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
  }) submitSlaData;

  final Future<void> Function(ServicesHistoryModel)? saveDraft;

  // 006: repository is required — no default instantiation. Callers must
  // inject a real CreateServicesRepository (see ServicesManagerCubit.repository).
  final CreateServicesRepository _repository;

  SlaNotificationCubit({
    required this.submitSlaData,
    required CreateServicesRepository repository,
    this.saveDraft,
  })  : _repository = repository,
        super(SlaNotificationInitial());

  // Model instance
  final SlaNotificationModel model = SlaNotificationModel();

  // Firestore related
  ServicesHistoryModel? currentModel;
  String? currentDocId;
  bool creatingDraftDoc = false;

  Future<void> initialize(ServicesHistoryModel? editingModel) async {
    emit(SlaNotificationLoading());

    model.notifyRequesterChecked = false;
    model.notifyProviderChecked = false;
    model.notifyManagerChecked = false;

    final dateTime = DateTime.now();
    model.formatDate = DateFormat("MMMdd_yyyy").format(dateTime);

    currentDocId = editingModel?.currentId;

    if (editingModel != null) {
      await _loadExistingData(editingModel);
    } else {
      _clearFormForNewService();
      if (currentDocId == null || currentDocId!.isEmpty) {
        await _ensureDraftDoc();
      }
    }

    emit(
      SlaNotificationLoaded(
        currentDocId: currentDocId,
        notifyRequesterChecked: model.notifyRequesterChecked,
        notifyProviderChecked: model.notifyProviderChecked,
        notifyManagerChecked: model.notifyManagerChecked,
        notifyRequesterSwitch0: model.notifyRequesterSwitch0,
        notifyManagerSwitch1: model.notifyManagerSwitch1,
        extraSlaList: List<String>.from(model.extraSla),
        extraSlaTwoList: List<String>.from(model.extraSlaTwo),
        notificationSwitches: model.notificationSwitches,
      ),
    );
  }

  /// Makes sure there is an in-memory model for the wizard.
  ///
  /// SVC-CREATE-11: this used to create (and, on every save, re-write) a copy
  /// of the service in Modules/services/Services — a collection nothing else
  /// reads — with a "User + random + date" id. Those copies piled up, and
  /// Submit was blocked whenever that extra write failed. The wizard state now
  /// lives only here and in the draft repository; the real service is saved
  /// to CreateServices by the confirm dialog.
  Future<void> _ensureDraftDoc() async {
    if (currentModel != null) return;
    if (currentDocId == null || currentDocId!.isEmpty) {
      currentDocId = _repository.newCreateServiceId();
    }
    currentModel = ServicesHistoryFactory.createNew(
      id: currentDocId!,
      state: 'draft',
      status: 'draft',
    );
  }

  Future<void> _loadExistingData(ServicesHistoryModel editingModel) async {
    currentModel = editingModel;
    currentDocId = editingModel.currentId;

    model.slaOne = editingModel.currentSlaOneControllerEnglish;
    model.slaTwo = editingModel.currentSlaTwoControllerEnglish;
    model.notifyRequesterChecked = editingModel.currentNotifyRequesterChecked;
    model.notifyProviderChecked = editingModel.currentNotifyProviderChecked;
    model.notifyManagerChecked = editingModel.currentNotifyManagerChecked;
    model.notifyRequesterSwitch0 = editingModel.currentNotifyRequesterSwitch0;
    model.notifyManagerSwitch1 = editingModel.currentNotifyManagerSwitch1;
  }

  void _clearFormForNewService() {
    model.slaOne = '';
    model.slaTwo = '';

    model.notifyRequesterChecked = false;
    model.notifyProviderChecked = false;
    model.notifyManagerChecked = false;
    model.notifyRequesterSwitch0 = false;
    model.notifyManagerSwitch1 = false;

    model.notificationSwitches.clear();
    model.isInvalidNumber = false;
    model.isInvalidNumberTwo = false;

    model.extraSla.clear();
    model.extraSlaTwo.clear();

    _clearSlaSharedPreferences();
  }

  Future<void> _clearSlaSharedPreferences() async {
    await SharedPrefsHelper.setString('sla_one', '');
    await SharedPrefsHelper.setString('sla_two', '');
    await SharedPrefsHelper.setBool('Notify Service Requester_checked', false);
    await SharedPrefsHelper.setBool('Notify Service Provider_checked', false);
    await SharedPrefsHelper.setBool('Notify Provider Manager_checked', false);
    await SharedPrefsHelper.setBool('notifyRequesterSwitch0', false);
    await SharedPrefsHelper.setBool('notifyManagerSwitch1', false);
    await SharedPrefsHelper.setStringList('extra_sla_list', []);
    await SharedPrefsHelper.setStringList('extra_sla_two_list', []);
  }

  /// Returns true when the model was persisted (or there was nothing to
  /// persist), false when the write failed — callers that go on to report
  /// success must abort on false.
  ///
  /// [keepAsDraft] pins the lifecycle `state` to 'draft' for this write.
  ///
  /// ADDED 26/8/2026. This method writes `status` and never touched `state`, so
  /// the lifecycle was whatever the loaded document happened to be holding. On
  /// the Save For Later path that is the one thing that must not be left to
  /// chance — the entire meaning of the button is "this is not finished" — and
  /// leaving it implicit is how a draft can quietly stop being one after an
  /// unrelated write. Submit deliberately does not pass it: publishing is what
  /// moves a service out of draft.
  Future<bool> updateAndSaveModel({bool keepAsDraft = false}) async {
    try {
      await _ensureDraftDoc();

      // ✅ FIX 26/8/2026 — this used to `return true` here, i.e. report SUCCESS
      // for a call that wrote nothing at all.
      //
      // `currentModel` is null whenever `_loadModelFromFirestore` came back
      // empty — the document was missing, or the read threw into its bare
      // `catch (e, st) {}`. Nothing downstream could tell that apart from a
      // real save, so Save For Later showed its success dialog over a document
      // that was never written. That is the "it says saved and there is
      // nothing in Firebase" report.
      //
      // Returning false lets the caller say so. `handleSubmit` already aborts
      // on false; `handleSaveForLater` now does too.
      if (currentModel == null || currentDocId == null) {
        return false;
      }

      // ✅ Read toggled status from SharedPrefs (set by page 1)
      final isActive =
          await SharedPrefsHelper.getBool('service_status') ?? true;
      final status = isActive ? 'active' : 'inactive';

      // ✅ FIX (bug report p1/p10): carry the approval cycle through the edit
      // path.
      //
      // This copyWith only ever touched the SLA / notification / status fields,
      // so editing an existing service re-saved the approval cycle that was
      // loaded from Firestore. Changing an approver silently did nothing, and
      // because the doc kept the old approver the new approver's Approvals
      // screen stayed empty.
      //
      // The approvals step stages its selection via
      // SharedPrefsApprovalHelper.saveApprovalCycle(); read it back here and
      // only append when it actually differs, since ServicesHistoryModel is an
      // append-only history model and copyWith pushes a new revision.
      final stagedCycle = await SharedPrefsApprovalHelper.getApprovalCycle();
      final cycleChanged = !_isSameApprovalCycle(
        stagedCycle,
        currentModel!.currentApprovalCycle,
      );

      currentModel = currentModel!.copyWith(
        slaOneControllerEnglish: model.slaOne.trim(),
        slaTwoControllerEnglish: model.slaTwo.trim(),
        notifyRequesterChecked: model.notifyRequesterChecked,
        notifyProviderChecked: model.notifyProviderChecked,
        notifyManagerChecked: model.notifyManagerChecked,
        notifyRequesterSwitch0: model.notifyRequesterSwitch0,
        notifyManagerSwitch1: model.notifyManagerSwitch1,
        status: status, // ✅ Apply correct status
        // Only ever set, never cleared: passing null leaves the existing
        // lifecycle alone, which is what the submit path wants.
        state: keepAsDraft ? ServiceDisplayStatus.draftState : null,
        approvalCycle: cycleChanged ? stagedCycle : null,
        requireApproval: cycleChanged ? stagedCycle.isNotEmpty : null,
      );

      // SVC-CREATE-11: no extra Firestore write here (see _ensureDraftDoc).
      return true;
    } catch (e, st) {
      // ✅ FIX: this was a bare `catch (e, st) {}`. Every failure of the final
      // save — including the status write — was swallowed, so a service that
      // never persisted its inactive status looked like it saved fine and then
      // showed up under Active on the home page with no error anywhere.
      //
      // Surface it as an error state; the SLA page already listens for
      // SlaNotificationValidationError and shows the message.
      svcLog('updateAndSaveModel failed', error: e, stackTrace: st);
      emit(const SlaNotificationValidationError(SlaValidationIssue.saveFailed));
      return false;
    }
  }

  /// Order-sensitive comparison of two approval cycles by email.
  ///
  /// Order matters: the cycle is sequential, so swapping two approvers is a
  /// real change even though the set of emails is identical.
  bool _isSameApprovalCycle(
    List<ServiceEmployeeModel> a,
    List<ServiceEmployeeModel> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final left = (a[i].email ?? '').trim().toLowerCase();
      final right = (b[i].email ?? '').trim().toLowerCase();
      if (left != right) return false;
    }
    return true;
  }

  void updateCheckbox(String type, bool value) {
    switch (type) {
      case 'requester':
        model.notifyRequesterChecked = value;
        break;
      case 'provider':
        model.notifyProviderChecked = value;
        break;
      case 'manager':
        model.notifyManagerChecked = value;
        break;
    }
    _emitLoadedState();
  }

  void updateNotificationSwitches(String title, Map<int, bool> switches) {
    model.notificationSwitches[title] = Map<int, bool>.from(switches);
    _emitLoadedState();
  }

  void updateSlaOne(String value) {
    if (value.trim().isNotEmpty) {
      if (value.contains('.') || value.contains(',')) {
        model.isInvalidNumber = true;
      } else if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
        model.isInvalidNumber = true;
      } else {
        model.isInvalidNumber = false;
      }
    } else {
      model.isInvalidNumber = false;
    }
    _emitLoadedState();
  }

  void updateSlaTwo(String value) {
    if (value.trim().isNotEmpty) {
      if (value.contains('.') || value.contains(',')) {
        model.isInvalidNumberTwo = true;
      } else if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
        model.isInvalidNumberTwo = true;
      } else {
        model.isInvalidNumberTwo = false;
      }
    } else {
      model.isInvalidNumberTwo = false;
    }
    _emitLoadedState();
  }

  // Rule "No text controllers in cubits": the page owns the text fields
  // and reports their values here; the cubit keeps plain strings.
  void addExtraSlaController() {
    if (model.addExtraSla()) _emitLoadedState();
  }

  void addExtraSlaTwoController() {
    if (model.addExtraSlaTwo()) _emitLoadedState();
  }

  void removeExtraSlaController(int index) {
    if (model.removeExtraSla(index)) {
      _saveExtraControllersToSharedPrefs();
      _emitLoadedState();
    }
  }

  void removeExtraSlaTwoController(int index) {
    if (model.removeExtraSlaTwo(index)) {
      _saveExtraControllersToSharedPrefs();
      _emitLoadedState();
    }
  }

  /// The page reports the text of the first SLA field (provider).
  void setSlaOneText(String value) => model.slaOne = value;

  /// The page reports the text of the first SLA field (manager).
  void setSlaTwoText(String value) => model.slaTwo = value;

  Timer? _extraDebounce;

  /// The page reports an extra SLA field's text ([two]: the manager list).
  /// Saving is debounced by 500 ms, as before.
  void setExtraSlaText(int index, String value, {bool two = false}) {
    final list = two ? model.extraSlaTwo : model.extraSla;
    if (index < 0 || index >= list.length) return;
    list[index] = value;
    _extraDebounce?.cancel();
    _extraDebounce = Timer(const Duration(milliseconds: 500), () {
      if (isClosed) return;
      updateAndSaveModel();
      _saveExtraControllersToSharedPrefs();
    });
  }

  Future<void> _saveExtraControllersToSharedPrefs() async {
    final extraSlaValues = List<String>.from(model.extraSla);
    final extraSlaTwoValues = List<String>.from(model.extraSlaTwo);

    await SharedPrefsHelper.setStringList('extra_sla_list', extraSlaValues);
    await SharedPrefsHelper.setStringList(
      'extra_sla_two_list',
      extraSlaTwoValues,
    );
  }

  bool hasProviderSlaData() {
    bool hasSlaOneText = model.slaOne.trim().isNotEmpty;
    bool hasExtraSlaText = model.extraSla.any((v) => v.trim().isNotEmpty);
    return hasSlaOneText || hasExtraSlaText;
  }

  bool hasManagerSlaData() {
    bool hasSlaTwoText = model.slaTwo.trim().isNotEmpty;
    bool hasExtraSlaTwoText = model.extraSlaTwo.any((v) => v.trim().isNotEmpty);
    return hasSlaTwoText || hasExtraSlaTwoText;
  }

  SlaNotificationValidationError? validateNotificationSettings(
    String requesterTitle,
    String providerTitle,
    String managerTitle,
  ) {
    final errors = <SlaNotificationValidationError>[];

    final requesterSwitches = model.notificationSwitches[requesterTitle] ?? {};
    bool hasRequesterSwitchEnabled = requesterSwitches.values.any(
      (enabled) => enabled == true,
    );

    if (hasRequesterSwitchEnabled && !model.notifyRequesterChecked) {
      errors.add(
        SlaNotificationValidationError(
          SlaValidationIssue.enableSection,
          section: requesterTitle,
        ),
      );
    }

    final providerSwitches = model.notificationSwitches[providerTitle] ?? {};
    bool hasProviderSwitchEnabled = providerSwitches.values.any(
      (enabled) => enabled == true,
    );
    bool providerSlaDataExists = hasProviderSlaData();

    if ((hasProviderSwitchEnabled || providerSlaDataExists) &&
        !model.notifyProviderChecked) {
      errors.add(
        SlaNotificationValidationError(
          SlaValidationIssue.enableSectionWithSla,
          section: providerTitle,
        ),
      );
    }

    final managerSwitches = model.notificationSwitches[managerTitle] ?? {};
    bool hasManagerSwitchEnabled = managerSwitches.values.any(
      (enabled) => enabled == true,
    );
    bool managerSlaDataExists = hasManagerSlaData();

    if ((hasManagerSwitchEnabled || managerSlaDataExists) &&
        !model.notifyManagerChecked) {
      errors.add(
        SlaNotificationValidationError(
          SlaValidationIssue.enableSectionWithSla,
          section: managerTitle,
        ),
      );
    }

    return errors.isNotEmpty ? errors.first : null;
  }

  bool validateNumericInputs() {
    if (model.slaOne.trim().isNotEmpty) {
      if (model.slaOne.contains('.') ||
          model.slaOne.contains(',') ||
          !RegExp(r'^\d+$').hasMatch(model.slaOne.trim())) {
        return false;
      }
    }

    if (model.slaTwo.trim().isNotEmpty) {
      if (model.slaTwo.contains('.') ||
          model.slaTwo.contains(',') ||
          !RegExp(r'^\d+$').hasMatch(model.slaTwo.trim())) {
        return false;
      }
    }

    for (var value in model.extraSla) {
      if (value.trim().isNotEmpty) {
        if (value.contains('.') ||
            value.contains(',') ||
            !RegExp(r'^\d+$').hasMatch(value.trim())) {
          return false;
        }
      }
    }

    for (var value in model.extraSlaTwo) {
      if (value.trim().isNotEmpty) {
        if (value.contains('.') ||
            value.contains(',') ||
            !RegExp(r'^\d+$').hasMatch(value.trim())) {
          return false;
        }
      }
    }

    return true;
  }

  bool hasAnyNotificationData() {
    bool hasAnySwitchEnabled = model.notificationSwitches.values.any(
      (switchMap) => switchMap.values.any((enabled) => enabled == true),
    );

    bool hasAnySlaData = model.slaOne.trim().isNotEmpty ||
        model.slaTwo.trim().isNotEmpty ||
        model.extraSla.any((v) => v.trim().isNotEmpty) ||
        model.extraSlaTwo.any((v) => v.trim().isNotEmpty);

    return hasAnySwitchEnabled || hasAnySlaData;
  }

  Future<void> handleSubmit(
    String requesterTitle,
    String providerTitle,
    String managerTitle,
  ) async {
    if (!validateNumericInputs()) {
      emit(
        const SlaNotificationValidationError(
          SlaValidationIssue.wholeNumbersOnly,
        ),
      );
      return;
    }

    if (hasAnyNotificationData()) {
      final validationError = validateNotificationSettings(
        requesterTitle,
        providerTitle,
        managerTitle,
      );
      if (validationError != null) {
        emit(validationError);
        return;
      }
    }

    // ✅ FIX: abort on a failed save. updateAndSaveModel used to swallow its
    // errors, so submit carried on and emitted SlaNotificationSaved — the
    // success dialog appeared for a service that was never written.
    final saved = await updateAndSaveModel();
    if (!saved) return;

    final extraSlaList = List<String>.from(model.extraSla);
    final extraSlaTwoList = List<String>.from(model.extraSlaTwo);

    await submitSlaData(
      slaOne: model.slaOne,
      slaTwo: model.slaTwo,
      notifyRequesterChecked: model.notifyRequesterChecked,
      notifyProviderChecked: model.notifyProviderChecked,
      notifyManagerChecked: model.notifyManagerChecked,
      notifyRequesterSwitch0: model.notifyRequesterSwitch0,
      notifyManagerSwitch1: model.notifyManagerSwitch1,
      extraSlaList: extraSlaList,
      extraSlaTwoList: extraSlaTwoList,
      notificationSwitches: model.notificationSwitches,
    );

    if (isClosed) return;
    await _saveAllToSharedPrefs();

    emit(SlaNotificationSaved());
  }

  Future<void> handleSaveForLater(
    ServicesHistoryModel? editingModel,
    VoidCallback onNavigate,
  ) async {
    final isEditingSubmittedService =
        editingModel != null && editingModel.currentState == "submitted";

    if (isEditingSubmittedService) {
      onNavigate();
      return;
    }

    if (!validateNumericInputs()) {
      emit(
        const SlaNotificationValidationError(SlaValidationIssue.numbersOnly),
      );
      return;
    }

    emit(SlaNotificationSaving());

    final bool saved = await _saveDraftData();

    // ✅ FIX 26/8/2026 — this used to emit `SlaNotificationSaved()`, which is
    // the SUBMIT state.
    //
    // `sla_screen_page_part2`'s listener keeps the two apart, and says so in
    // its own comments:
    //
    //     } else if (state is SlaNotificationDraftSaved) {
    //       // ✅ Only shows for Save For Later
    //       showDraftSavedSuccessDialog(context);
    //     } else if (state is SlaNotificationSaved) {
    //       // ✅ Only shows for Submit
    //       showCreateServiceDialog(...);
    //
    // Save For Later emitted the submit state, so it took the submit branch:
    // the user was shown the "service created" dialog — the one that reports a
    // finished, published service and offers what to do with it next — for a
    // draft they had explicitly chosen NOT to finish. `SlaNotificationDraftSaved`
    // existed the whole time with nothing emitting it.
    //
    // The `if (isDraft || editingModel != null) … else …` this replaces had
    // identical bodies in both branches, so `isDraft` was computed, never used,
    // and goes with it.
    //
    // ✅ FIX 26/8/2026 — and this emit is now CONDITIONAL. It used to fire
    // whatever `_saveDraftData` did, and `_saveDraftData` returned void, so a
    // save that wrote nothing still produced the success dialog. Reporting a
    // draft that does not exist is worse than reporting the failure: the user
    // closes the app believing their work is safe.
    if (!saved) {
      emit(
        const SlaNotificationValidationError(SlaValidationIssue.draftNotSaved),
      );
      return;
    }

    emit(const SlaNotificationDraftSaved());
  }

  /// Returns true when the draft actually reached storage.
  Future<bool> _saveDraftData() async {
    await SharedPrefsHelper.setString('sla_one', model.slaOne.trim());
    await SharedPrefsHelper.setString('sla_two', model.slaTwo.trim());
    await SharedPrefsHelper.setBool(
      'Notify Service Requester_checked',
      model.notifyRequesterChecked,
    );
    await SharedPrefsHelper.setBool(
      'Notify Service Provider_checked',
      model.notifyProviderChecked,
    );
    await SharedPrefsHelper.setBool(
      'Notify Provider Manager_checked',
      model.notifyManagerChecked,
    );

    final reqMap = model.notificationSwitches['notifyServiceRequester'] ?? {};
    final mgrMap = model.notificationSwitches['notifyProviderManager'] ?? {};
    model.notifyRequesterSwitch0 = reqMap[0] ?? false;
    model.notifyManagerSwitch1 = mgrMap[0] ?? false;

    await SharedPrefsHelper.setBool(
      'notifyRequesterSwitch0',
      model.notifyRequesterSwitch0,
    );
    await SharedPrefsHelper.setBool(
      'notifyManagerSwitch1',
      model.notifyManagerSwitch1,
    );
    await _saveExtraControllersToSharedPrefs();

    final extraSlaList = List<String>.from(model.extraSla);
    final extraSlaTwoList = List<String>.from(model.extraSlaTwo);

    // Call submitSlaData for draft saving too
    await submitSlaData(
      slaOne: model.slaOne,
      slaTwo: model.slaTwo,
      notifyRequesterChecked: model.notifyRequesterChecked,
      notifyProviderChecked: model.notifyProviderChecked,
      notifyManagerChecked: model.notifyManagerChecked,
      notifyRequesterSwitch0: model.notifyRequesterSwitch0,
      notifyManagerSwitch1: model.notifyManagerSwitch1,
      extraSlaList: extraSlaList,
      extraSlaTwoList: extraSlaTwoList,
      notificationSwitches: model.notificationSwitches,
    );

    // S2: submitSlaData is awaited above — no fixed wait needed.
    final isEditingExisting =
        currentDocId != null && !currentDocId!.startsWith('draft_');

    // ✅ FIX 26/8/2026 — THE DRAFT WAS SAVING EMPTY.
    //
    // The branch below used to decide WHICH DATA got saved, and for the wizard
    // flow it chose the wrong one.
    //
    // PATH A (`updateAndSaveModel`) copies the SLA and notification fields onto
    // `currentModel` and writes that. But on a new service `currentModel` is the
    // skeleton `_ensureDraftDoc` created — `createNew(id:, state:, status:)`,
    // with an empty name, description and duration. The wizard's page-1 data
    // never travels into that document: `CreateServiceCubit.submitForm` hands it
    // to `saveServiceDraft`, which is `repository.saveServiceToPrefs` — prefs,
    // not Firestore. So PATH A faithfully saved a blank service, which is why
    // the draft reopened with every field empty.
    //
    // PATH B is the code that knows better: it reads the staged wizard values
    // back out of SharedPrefs and assembles a complete model. It was only ever
    // reached for `draft_`-prefixed ids, which this screen never mints.
    //
    // So the assembly now runs for BOTH, and the branch decides only whether the
    // `services/` document also needs updating.
    if (isEditingExisting) {
      // Keep `services/{docId}` in step — the submit path reads it back. It is
      // NOT what the home page lists (different collection, see
      // [_stampDraftRecord]), so it cannot stand in for the draft record.
      final bool written = await updateAndSaveModel(keepAsDraft: true);
      if (!written) return false;
    }

    final ServicesHistoryModel draftModel = await SlaDraftModelBuilder.build(
      base: currentModel,
      docId: currentDocId,
      form: model,
    );

    return await _stampDraftRecord(draftModel);
  }

  /// Function Name: [_stampDraftRecord]
  ///
  /// Purpose: Record [draftModel] as a DRAFT the current user owns.
  ///
  /// ADDED 26/8/2026. This is the step the SLA screen was missing entirely.
  /// Writing the service document is not enough to produce a draft: a draft is
  /// a document that also carries `draftMetadata` — `createdBy`, `draftState`,
  /// `currentPage`, `intendedStatus` — because that is what
  /// `FirebaseDraftRepository.getUserDrafts()` queries on and what the home
  /// page's ownership checks read. Without it the document exists and nothing
  /// can attribute it to anyone.
  ///
  /// The injected [saveDraft] is the Firebase write (see the page's
  /// `initState`); the SharedPrefs fallback is only reached when no callback
  /// was supplied, and is local-only — it cannot make a draft visible on the
  /// home page, so it is logged as such rather than passing quietly for a real
  /// save.
  ///
  /// Parameters:
  /// - [draftModel]: the model to record, carrying the id of the document that
  ///   has already been written so the draft record lands on the same one.
  ///
  /// Returns: [Future<bool>] false when the write threw — never swallowed, or
  /// the caller would report a success it cannot back up.
  Future<bool> _stampDraftRecord(ServicesHistoryModel draftModel) async {
    try {
      if (saveDraft != null) {
        await saveDraft!(draftModel);
      } else {
        await SharedPrefsServiceMaster.saveDraft(draftModel);
      }
      return true;
    } catch (e, stackTrace) {
      svcLog('save failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> _saveAllToSharedPrefs() async {
    await SharedPrefsHelper.setString('sla_one', model.slaOne.trim());
    await SharedPrefsHelper.setString('sla_two', model.slaTwo.trim());
    await SharedPrefsHelper.setBool(
      'Notify Service Requester_checked',
      model.notifyRequesterChecked,
    );
    await SharedPrefsHelper.setBool(
      'Notify Service Provider_checked',
      model.notifyProviderChecked,
    );
    await SharedPrefsHelper.setBool(
      'Notify Provider Manager_checked',
      model.notifyManagerChecked,
    );

    final reqMap = model.notificationSwitches['notifyServiceRequester'] ?? {};
    final mgrMap = model.notificationSwitches['notifyProviderManager'] ?? {};
    model.notifyRequesterSwitch0 = reqMap[0] ?? false;
    model.notifyManagerSwitch1 = mgrMap[0] ?? false;

    await SharedPrefsHelper.setBool(
      'notifyRequesterSwitch0',
      model.notifyRequesterSwitch0,
    );
    await SharedPrefsHelper.setBool(
      'notifyManagerSwitch1',
      model.notifyManagerSwitch1,
    );

    await _saveExtraControllersToSharedPrefs();
  }

  void _emitLoadedState() {
    emit(
      SlaNotificationLoaded(
        currentDocId: currentDocId,
        notifyRequesterChecked: model.notifyRequesterChecked,
        notifyProviderChecked: model.notifyProviderChecked,
        notifyManagerChecked: model.notifyManagerChecked,
        notifyRequesterSwitch0: model.notifyRequesterSwitch0,
        notifyManagerSwitch1: model.notifyManagerSwitch1,
        extraSlaList: List<String>.from(model.extraSla),
        extraSlaTwoList: List<String>.from(model.extraSlaTwo),
        notificationSwitches: model.notificationSwitches,
      ),
    );
  }

  @override
  Future<void> close() {
    _extraDebounce?.cancel();
    return super.close();
  }
}
