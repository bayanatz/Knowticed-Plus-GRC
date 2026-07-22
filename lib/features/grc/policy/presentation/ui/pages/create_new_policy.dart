/// Module: GRC Policy Management
/// Description: Three-step page for creating a new GRC policy.
///              Step 0: Policy info form.
///              Step 1: Add / edit controls.
///              Step 2: Full preview with controls table, weight validation,
///                      Equal Weight, and Publish action.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-06
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyCubit,
///               PolicyControlsTableWidget
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-06 - Added step 2 preview, Draft/Publish status,
///                                Equal Weight, weight validation (Mohamed Elrashidy)
///                   2026-07-16 - Split step content and button rows into
///                                their own widget files (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: create_new_policy.dart
/// Purpose: Contains CreateNewPolicyPage, the three-step form for policy
///          creation — step 0: policy info, step 1: controls, step 2: preview.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'dart:io';

// 11's own showUploadDialog is a near-duplicate of 10's — hidden here to
// avoid an ambiguous-import error; section 10 already demos the dedicated one.
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/add_policy_controls.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step0.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step0_buttons.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step1_buttons.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step2_buttons.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step2_preview.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_completeness.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';

/// class name: [CreateNewPolicyPage]
///
/// purpose: three-step page that collects policy info (step 0), manages
///          controls (step 1), then shows a full preview with the controls
///          table (step 2). The body switches in-place via [_step]; no new
///          routes are pushed.
///
///          Supported actions:
///           - Save For Later  → persists as [PolicyStatus.draft]
///           - Preview         → advances from step 1 to step 2
///           - Equal Weight    → distributes 100 equally across all controls
///           - Publish         → persists as [PolicyStatus.active] (requires
///                               total weight == 100)
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class CreateNewPolicyPage extends StatefulWidget {
  final String moduleId;
  final String moduleNameEn;
  final String moduleNameAr;

  /// When set, the wizard resumes this already-saved Draft instead of
  /// starting blank: Step 0 is prefilled from it and its saved Controls
  /// are fetched and prefilled into Step 1. Save For Later/Publish then
  /// update this same Policy instead of creating a new one.
  final PolicyEntity? existingPolicy;

  const CreateNewPolicyPage({
    super.key,
    required this.moduleId,
    required this.moduleNameEn,
    required this.moduleNameAr,
    this.existingPolicy,
  });

  @override
  State<CreateNewPolicyPage> createState() => _CreateNewPolicyPageState();
}

class _CreateNewPolicyPageState extends State<CreateNewPolicyPage> {
  // ----------------------------------------------------------------
  // State
  // ----------------------------------------------------------------
  int _step = 0; // 0 = info, 1 = controls, 2 = preview
  bool _isArabicEnabled = true;
  bool _step0Submitted = false;
  bool _controlsSubmitted = false;

  // Step 0 controllers
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _numberController = TextEditingController();
  final _numberArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _weightController = TextEditingController();

  List<PolicyControlModel> _controls = [PolicyControlModel()];

  DateTime? _startDate;
  DateTime? _endDate;
  File? _imageFile;
  String? _imageUrl;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;

  /// Snapshot of the ids of controls already saved under [widget.existingPolicy]
  /// at the moment they were loaded — diffed against what's still touched
  /// in [_controls] at save time to know which ones the user removed.
  Set<String> _originalControlIds = {};

  // ----------------------------------------------------------------
  // Lifecycle
  // ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    final existing = widget.existingPolicy;
    if (existing == null) return;
    _nameController.text = existing.policyNameEn;
    _nameArController.text = existing.policyNameAr;
    _numberController.text = existing.policyNumberEn;
    _numberArController.text = existing.policyNumberAr;
    _descriptionController.text = existing.policyDescriptionEn;
    _descriptionArController.text = existing.policyDescriptionAr;
    _weightController.text = existing.policyWeight.toStringAsFixed(0);
    _startDate = existing.startDate;
    _endDate = existing.endDate;
    _imageUrl = existing.policyImage;
    _documentEn = existing.policyDocumentEn != null
        ? PolicyDocumentInfo.fromUrl(existing.policyDocumentEn!)
        : null;
    _documentAr = existing.policyDocumentAr != null
        ? PolicyDocumentInfo.fromUrl(existing.policyDocumentAr!)
        : null;
    // No stored toggle for this — infer it from whether any Arabic field
    // was ever filled in, the same way the fields themselves imply it.
    _isArabicEnabled = existing.policyNameAr.trim().isNotEmpty ||
        existing.policyNumberAr.trim().isNotEmpty ||
        existing.policyDescriptionAr.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _numberController.dispose();
    _numberArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _weightController.dispose();
    for (final c in _controls) c.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------------

  /// function name: [_totalControlWeight]
  ///
  /// purpose: sum up the weight values entered for all controls.
  ///
  /// parameters: none
  ///
  /// return type: [double] - the current total control weight
  double get _totalControlWeight => _controls.fold(
        0,
        (sum, c) =>
            sum + (double.tryParse(c.weightController.text.trim()) ?? 0),
      );

  /// function name: [_touchedControls]
  ///
  /// purpose: the subset of [_controls] the user has actually entered data
  ///          into — see [controlIsTouched]. An untouched default control
  ///          card is not a "real" control.
  ///
  /// parameters: none
  ///
  /// return type: [List<PolicyControlModel>]
  List<PolicyControlModel> get _touchedControls =>
      _controls.where(controlIsTouched).toList();

  /// function name: [_hasIncompleteTouchedControl]
  ///
  /// purpose: true if any touched control is missing a required field —
  ///          see [controlIsComplete]. Used to block Preview until every
  ///          control the user started filling in is finished.
  ///
  /// parameters: none
  ///
  /// return type: [bool]
  bool get _hasIncompleteTouchedControl => _touchedControls.any(
      (c) => !controlIsComplete(c, isArabicEnabled: _isArabicEnabled));

  bool get _isWeightValid =>
      _touchedControls.isEmpty || _totalControlWeight == 100;

  /// function name: [_canPreview]
  ///
  /// purpose: same conditions [_handlePreviewPressed] already checks before
  ///          allowing the step transition — reused here so the Preview
  ///          button itself is disabled/greyed while any of them fail,
  ///          instead of the button always being clickable and only then
  ///          surfacing per-field required errors (which fired the moment
  ///          any field anywhere was touched, not just the one being
  ///          edited).
  ///
  /// parameters: none
  ///
  /// return type: [bool]
  bool get _canPreview =>
      !_hasPolicyLanguageErrors && !_hasControlErrors && !_hasIncompleteTouchedControl;

  void _onUploadDocumentEn() {
    showUploadDialog(
      context: context,
      dialogTitle: 'Upload Policy Document (English)'.tr,
      titleFieldLabel: 'Document Title'.tr,
      titleFieldHint: 'Text here'.tr,
      browseLabel: 'Browse Files'.tr,
      submitLabel: 'Submit'.tr,
      discardLabel: 'Discard'.tr,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onSubmit: (file, title) {
        setState(() => _documentEn = PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  void _onUploadDocumentAr() {
    showUploadDialog(
      context: context,
      dialogTitle: 'رفع مستند السياسة (عربي)',
      titleFieldLabel: 'عنوان المستند',
      titleFieldHint: 'اكتب هنا',
      browseLabel: 'تصفح الملفات',
      submitLabel: 'إرسال',
      discardLabel: 'إلغاء',
      textDirection: TextDirection.rtl,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onSubmit: (file, title) {
        setState(() => _documentAr = PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  /// function name: [_onStartDateChanged]
  ///
  /// purpose: update the start date and, if the previously selected end
  ///          date now falls before it, clear the end date so the user must
  ///          pick a new one.
  ///
  /// parameters:
  ///            [DateTime?] date: the newly selected start date
  ///
  /// return type: void
  void _onStartDateChanged(DateTime? date) {
    setState(() {
      _startDate = date;
      if (_endDate != null && date != null && _endDate!.isBefore(date)) {
        _endDate = null;
      }
    });
  }

  /// function name: [_validateStep0]
  ///
  /// purpose: verify that all required policy-info fields have been filled
  ///          before allowing the user to advance to step 1.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if all required fields are non-empty
  bool _validateStep0() {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return _nameController.text.trim().isNotEmpty &&
        _numberController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _startDate != null &&
        _endDate != null &&
        !_startDate!.isBefore(startOfToday) &&
        !_endDate!.isBefore(_startDate!) &&
        _weightController.text.trim().isNotEmpty &&
        (!_isArabicEnabled || !_arabicTouched ||
            (_nameArController.text.trim().isNotEmpty &&
                _numberArController.text.trim().isNotEmpty &&
                _descriptionArController.text.trim().isNotEmpty)) &&
        !_hasPolicyLanguageErrors;
  }

  /// True once the user has entered something into any Arabic policy-info
  /// field. Turning the Arabic toggle on by itself doesn't make Name/
  /// Number/Description AR required — only starting to fill one of them
  /// in does, at which point all three become required together.
  bool get _arabicTouched =>
      _nameArController.text.trim().isNotEmpty ||
      _numberArController.text.trim().isNotEmpty ||
      _descriptionArController.text.trim().isNotEmpty;

  /// function name: [_hasPolicyLanguageErrors]
  ///
  /// purpose: true if any policy-level EN/AR field currently shows a
  ///          language-mismatch error (English field containing Arabic
  ///          letters, or vice versa). Used to block Publish/Save For Later
  ///          until the user fixes highlighted errors.
  bool get _hasPolicyLanguageErrors {
    if (containsArabicLetters(_nameController.text)) return true;
    if (containsArabicLetters(_numberController.text)) return true;
    if (containsArabicLetters(_descriptionController.text)) return true;
    if (_isArabicEnabled) {
      if (containsEnglishLetters(_nameArController.text)) return true;
      if (containsEnglishLetters(_numberArController.text)) return true;
      if (containsEnglishLetters(_descriptionArController.text)) return true;
    }
    return false;
  }

  /// function name: [_controlHasErrors]
  ///
  /// purpose: true if [control] currently shows a language-mismatch error
  ///          on Name/Number/Description, or a date-range error (its own
  ///          End Date before its Start Date, or either date falling
  ///          outside the parent Policy's own Start/End Date range).
  bool _controlHasErrors(PolicyControlModel control) {
    if (containsArabicLetters(control.nameController.text)) return true;
    if (containsArabicLetters(control.numberController.text)) return true;
    if (containsArabicLetters(control.descriptionController.text)) return true;
    if (_isArabicEnabled) {
      if (containsEnglishLetters(control.nameArController.text)) return true;
      if (containsEnglishLetters(control.numberArController.text)) return true;
      if (containsEnglishLetters(control.descriptionArController.text))
        return true;
    }
    final start = control.startDate;
    final end = control.endDate;
    if (start != null && end != null && end.isBefore(start)) return true;
    for (final date in [start, end]) {
      if (date == null) continue;
      if (_startDate != null && date.isBefore(_startDate!)) return true;
      if (_endDate != null && date.isAfter(_endDate!)) return true;
    }
    return false;
  }

  /// function name: [_hasControlErrors]
  ///
  /// purpose: true if any filled-in control (non-empty English name — the
  ///          same filter [_buildPendingControls] uses to decide which
  ///          controls are actually sent to the cubit) currently has a
  ///          language or date-range error.
  bool get _hasControlErrors => _controls.any(
      (c) => c.nameController.text.trim().isNotEmpty && _controlHasErrors(c));

  /// function name: [_showBlockingErrorsSnackbar]
  ///
  /// purpose: show the shared red snackbar used whenever Save For Later or
  ///          Publish is blocked by an unresolved validation error.
  void _showBlockingErrorsSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Please fix the highlighted errors before continuing.'.tr),
        backgroundColor: AppColors.red,
      ),
    );
  }

  // ----------------------------------------------------------------
  // Cubit actions
  // ----------------------------------------------------------------

  /// function name: [_onSaveForLater]
  ///
  /// purpose: persist the policy as a Draft regardless of the current step.
  ///          Controls are included if any have been filled in; an empty
  ///          list is valid for a draft.
  ///
  /// parameters:
  ///            [PolicyCubit] cubit: the cubit instance from the BlocProvider
  ///
  /// return type: void
  List<PendingControlInput> _buildPendingControls(ControlStatus status) {
    return _controls
        .where(controlIsTouched)
        .map((c) => PendingControlInput(
              controlsNameEn: c.nameController.text.trim(),
              controlsNameAr: c.nameArController.text.trim(),
              controlsNumberEn: c.numberController.text.trim(),
              controlsNumberAr: c.numberArController.text.trim(),
              controlsDescriptionEn: c.descriptionController.text.trim(),
              controlsDescriptionAr: c.descriptionArController.text.trim(),
              controlsWeight:
                  double.tryParse(c.weightController.text.trim()) ?? 0,
              frequency: c.frequency ?? '',
              startDate: c.startDate ?? _startDate ?? DateTime.now(),
              endDate: c.endDate ?? _endDate ?? DateTime.now(),
              // equalWeights: true (not false) — this wizard never lets the
              // user assign per-department weights, so departments is
              // always []. ControlModel.create asserts that
              // departmentWeights is non-null whenever equalWeights is
              // false; equalWeights: true skips that requirement and
              // DepartmentWeight.equalSplit([]) safely returns [].
              departments: const [],
              equalWeights: true,
              score: 0,
              status: status,
              controlsDocumentFileEn: c.documentEn?.file,
              controlsDocumentFileAr: c.documentAr?.file,
              existingControlId: c.existingControlId,
            ))
        .toList();
  }

  /// function name: [_controlModelFromEntity]
  ///
  /// purpose: build an editable [PolicyControlModel] prefilled from an
  ///          already-saved [ControlEntity], tagging it with
  ///          [PolicyControlModel.existingControlId] so a later Save For
  ///          Later/Publish updates this same Control instead of creating
  ///          a duplicate.
  ///
  /// parameters:
  ///            [ControlEntity] c: the saved control to prefill from
  ///
  /// return type: [PolicyControlModel]
  PolicyControlModel _controlModelFromEntity(ControlEntity c) =>
      PolicyControlModel(
        existingControlId: c.id,
        nameController: TextEditingController(text: c.controlsNameEn),
        nameArController: TextEditingController(text: c.controlsNameAr),
        numberController: TextEditingController(text: c.controlsNumberEn),
        numberArController: TextEditingController(text: c.controlsNumberAr),
        descriptionController:
            TextEditingController(text: c.controlsDescriptionEn),
        descriptionArController:
            TextEditingController(text: c.controlsDescriptionAr),
        weightController:
            TextEditingController(text: c.controlsWeight.toStringAsFixed(0)),
        frequency: c.frequency,
        startDate: c.startDate,
        endDate: c.endDate,
        documentEn: c.controlsDocumentEn != null
            ? PolicyDocumentInfo.fromUrl(c.controlsDocumentEn!)
            : null,
        documentAr: c.controlsDocumentAr != null
            ? PolicyDocumentInfo.fromUrl(c.controlsDocumentAr!)
            : null,
      );

  void _onSaveForLater(PolicyCubit cubit) {
    if (widget.existingPolicy != null) {
      _updateExisting(cubit, status: PolicyStatus.draft);
      return;
    }
    cubit.saveAsDraft(
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      moduleId: widget.moduleId,
      controls: _buildPendingControls(ControlStatus.draft),
      imageFile: _imageFile,
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentFileAr: _documentAr?.file,
    );
  }

  /// function name: [_onPublish]
  ///
  /// purpose: validate that the total control weight equals 100 then
  ///          persist the policy with [PolicyStatus.active].
  ///
  /// parameters:
  ///            [PolicyCubit] cubit: the cubit instance from the BlocProvider
  ///
  /// return type: void
  void _onPublish(PolicyCubit cubit) {
    if (!_isWeightValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total Weight should be 100'.tr),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    if (widget.existingPolicy != null) {
      _updateExisting(cubit, status: PolicyStatus.active);
      return;
    }
    cubit.createPolicy(
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      moduleId: widget.moduleId,
      // Controls added inline here have no Champion/Owner assignment UI at
      // all in this wizard, so a freshly published one must start
      // Unassigned — never Active — matching the same "no assignee = can't
      // be Active" rule the single Add/Edit Control page enforces (see
      // ControlStatus doc and add_edit_control_page.dart's _resolvedStatus).
      controls: _buildPendingControls(ControlStatus.unassigned),
      imageFile: _imageFile,
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentFileAr: _documentAr?.file,
    );
  }

  /// function name: [_updateExisting]
  ///
  /// purpose: Save For Later/Publish path when resuming a Draft — updates
  ///          [widget.existingPolicy] and its Controls in place via
  ///          [PolicyCubit.updatePolicyWithControls] instead of creating a
  ///          new Policy. [status] decides whether the Policy (and every
  ///          touched control) ends up Draft again or Unassigned — never
  ///          Active, since this wizard has no Champion/Owner assignment UI.
  ///
  /// parameters:
  ///            [PolicyCubit] cubit: the cubit instance from the BlocProvider
  ///            [PolicyStatus] status: the status to persist
  ///
  /// return type: [void]
  void _updateExisting(PolicyCubit cubit, {required PolicyStatus status}) {
    final controlStatus =
        status == PolicyStatus.active ? ControlStatus.unassigned : ControlStatus.draft;
    final currentIds = _touchedControls
        .map((c) => c.existingControlId)
        .whereType<String>()
        .toSet();
    cubit.updatePolicyWithControls(
      id: widget.existingPolicy!.id,
      moduleId: widget.moduleId,
      status: status,
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      controls: _buildPendingControls(controlStatus),
      removedControlIds: _originalControlIds.difference(currentIds).toList(),
      imageFile: _imageFile,
      imageUrl: _imageFile == null ? _imageUrl : null,
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentUrlEn: _documentEn?.file == null ? _documentEn?.url : null,
      policyDocumentFileAr: _documentAr?.file,
      policyDocumentUrlAr: _documentAr?.file == null ? _documentAr?.url : null,
    );
  }

  // ----------------------------------------------------------------
  // Button-row press handlers
  // ----------------------------------------------------------------

  void _handleDiscardPressed() {
    showConfirmDialog(
      context: context,
      title: 'Discard Policy'.tr,
      subtitle:
          'Are you sure you want to discard this policy? Any unsaved changes will be lost.'
              .tr,
      confirmLabel: 'Discard'.tr,
      cancelLabel: 'Cancel'.tr,
      onConfirm: () => Navigator.of(context).pop(),
    );
  }

  void _handleNextPressed() {
    setState(() => _step0Submitted = true);
    if (!_validateStep0()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'.tr),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    setState(() => _step = 1);
  }

  void _handleSaveForLaterPressed(PolicyCubit cubit) {
    if (_hasPolicyLanguageErrors || _hasControlErrors) {
      _showBlockingErrorsSnackbar();
      return;
    }
    showConfirmDialog(
      context: context,
      title: 'Save As Draft'.tr,
      subtitle: 'Are you sure you want to save this policy as a draft?'.tr,
      confirmLabel: 'Save'.tr,
      cancelLabel: 'Cancel'.tr,
      onConfirm: () => _onSaveForLater(cubit),
    );
  }

  void _handlePreviewPressed() {
    setState(() => _controlsSubmitted = true);
    if (_hasPolicyLanguageErrors || _hasControlErrors) {
      _showBlockingErrorsSnackbar();
      return;
    }
    if (_hasIncompleteTouchedControl) {
      return;
    }
    setState(() => _step = 2);
  }

  void _handlePublishPressed(PolicyCubit cubit) {
    if (!_isWeightValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total Weight should be 100'.tr),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    if (_hasPolicyLanguageErrors || _hasControlErrors) {
      _showBlockingErrorsSnackbar();
      return;
    }
    showConfirmDialog(
      context: context,
      title: 'Publish Policy'.tr,
      subtitle:
          'Are you sure you want to publish this policy? This will make it active.'
              .tr,
      confirmLabel: 'Publish'.tr,
      cancelLabel: 'Cancel'.tr,
      onConfirm: () => _onPublish(cubit),
    );
  }

  // ----------------------------------------------------------------
  // BlocListener callback
  // ----------------------------------------------------------------

  /// function name: [_onStateChange]
  ///
  /// purpose: react to [PolicyState] changes emitted by [PolicyCubit]:
  ///          show / hide the loading indicator, display success dialogs,
  ///          and show error snackbars.
  ///
  /// parameters:
  ///            [BuildContext] context: the current build context
  ///            [PolicyState] state: the newly emitted state
  ///
  /// return type: void
  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyControlsListLoaded) {
      if (widget.existingPolicy == null) return;
      _originalControlIds = state.controls.map((c) => c.id).toSet();
      setState(() {
        for (final c in _controls) c.dispose();
        _controls = state.controls.isEmpty
            ? [PolicyControlModel()]
            : state.controls.map(_controlModelFromEntity).toList();
      });
      return;
    }

    if (state is PolicyActionSuccess) {
      final isDraft = state.policy.status.value == 'Draft';
      showSuccessDialog(
        context: context,
        title: isDraft ? 'Saved as Draft'.tr : 'Policy Created'.tr,
        subtitle: isDraft
            ? 'Policy saved as draft successfully'.tr
            : 'You Successfully Created This Policy'.tr,
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is PolicyActionPartialSuccess) {
      // The Policy itself was saved/updated successfully at this point —
      // only one or more of its Controls failed. Surface that instead of
      // staying silent, and still leave: the list needs to reflect the
      // Policy's new state either way.
      final reasons =
          state.failedControls.map((f) => f.message).toSet().join('; ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${'Policy saved, but one or more Controls failed to save:'.tr} $reasons',
          ),
          backgroundColor: AppColors.red,
        ),
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is PolicyFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  // ----------------------------------------------------------------
  // Build
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = GetIt.instance<PolicyCubit>();
        final existing = widget.existingPolicy;
        if (existing != null) {
          cubit.getAllControls(moduleId: widget.moduleId, policyId: existing.id);
        }
        return cubit;
      },
      child: Builder(
        builder: (ctx) {
          final cubit = ctx.read<PolicyCubit>();
          return BlocListener<PolicyCubit, PolicyState>(
            listener: _onStateChange,
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaginationAppBar(
                      screensTitles: [
                        'GRC'.tr,
                        ctx.isArabic
                            ? widget.moduleNameAr
                            : widget.moduleNameEn,
                        'Create New Policy'.tr,
                      ],
                    ),
                    Expanded(child: _buildCurrentStep()),
                    SizedBox(height: 16.h),
                    _buildButtons(cubit),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      default:
        return _buildStep0();
    }
  }

  // ----------------------------------------------------------------
  // Step 0: Policy Info
  // ----------------------------------------------------------------
  Widget _buildStep0() {
    return CreatePolicyStep0(
      isArabicEnabled: _isArabicEnabled,
      onArabicToggle: (v) => setState(() => _isArabicEnabled = v),
      imageFile: _imageFile,
      onImagePicked: (file) => setState(() => _imageFile = file),
      submitted: _step0Submitted,
      nameController: _nameController,
      nameArController: _nameArController,
      numberController: _numberController,
      numberArController: _numberArController,
      descriptionController: _descriptionController,
      descriptionArController: _descriptionArController,
      weightController: _weightController,
      startDate: _startDate,
      endDate: _endDate,
      onStartDateChanged: _onStartDateChanged,
      onEndDateChanged: (d) => setState(() => _endDate = d),
      documentEn: _documentEn,
      documentAr: _documentAr,
      onUploadDocumentEn: _onUploadDocumentEn,
      onUploadDocumentAr: _onUploadDocumentAr,
      onRemoveDocumentEn: () => setState(() => _documentEn = null),
      onRemoveDocumentAr: () => setState(() => _documentAr = null),
    );
  }

  // ----------------------------------------------------------------
  // Step 1: Controls
  // ----------------------------------------------------------------
  Widget _buildStep1() {
    return AddPolicyControlsPage(
      isArabicEnabled: _isArabicEnabled,
      controls: _controls,
      policyStartDate: _startDate,
      policyEndDate: _endDate,
      controlsSubmitted: _controlsSubmitted,
      editPolicy: () => setState(() => _step = 0),
    );
  }

  // ----------------------------------------------------------------
  // Step 2: Preview — policy summary + controls table
  // ----------------------------------------------------------------
  Widget _buildStep2() {
    return CreatePolicyStep2Preview(
      isArabicEnabled: _isArabicEnabled,
      nameController: _nameController,
      nameArController: _nameArController,
      numberController: _numberController,
      numberArController: _numberArController,
      descriptionController: _descriptionController,
      descriptionArController: _descriptionArController,
      weightController: _weightController,
      startDate: _startDate,
      endDate: _endDate,
      imageFile: _imageFile,
      imageUrl: _imageUrl,
      documentEn: _documentEn,
      documentAr: _documentAr,
      touchedControls: _touchedControls,
      onAddController: () => setState(() => _step = 1),
      onControlsChanged: () => setState(() {}),
    );
  }

  // ----------------------------------------------------------------
  // Buttons row per step
  // ----------------------------------------------------------------

  /// function name: [_buildButtons]
  ///
  /// purpose: render the correct bottom-action buttons depending on the
  ///          current step.
  ///
  /// parameters:
  ///            [PolicyCubit] cubit: the cubit instance from the BlocProvider
  ///
  /// return type: [Widget]
  Widget _buildButtons(PolicyCubit cubit) {
    switch (_step) {
      case 0:
        return CreatePolicyStep0Buttons(
          onDiscard: _handleDiscardPressed,
          onNext: _handleNextPressed,
        );
      case 1:
        return CreatePolicyStep1Buttons(
          onSaveForLater: () => _handleSaveForLaterPressed(cubit),
          onPreview: _handlePreviewPressed,
          previewEnabled: _canPreview,
        );
      case 2:
        return CreatePolicyStep2Buttons(
          onSaveForLater: () => _handleSaveForLaterPressed(cubit),
          onPublish: () => _handlePublishPressed(cubit),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
