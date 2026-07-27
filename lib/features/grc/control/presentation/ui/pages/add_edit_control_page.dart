/// Module: GRC Policy Management
/// Description: Full-page form for creating or editing a single standalone
///              Control under an existing Policy, opened from the Policy
///              Details page's Controls section.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter_bloc, PolicyCubit, ControlEntity, ControlStatus, get_it
/// Revision History: 2026-07-15 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: add_edit_control_page.dart
/// Purpose: Contains AddEditControlPage, the create/edit form for a single
///          Control. Enforces that this control's weight plus every sibling
///          control's weight sums to 100.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 15/7/2026

import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:demo_app/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_department_weight.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_frequency.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_preview_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' as intl;
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';

/// class name: [AddEditControlPage]
///
/// purpose: full-page form to create a new Control or edit an existing one,
///          scoped to one Policy. Validates that this control's weight plus
///          every entry in [siblingControls] sums to exactly 100.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 15/7/2026
class AddEditControlPage extends StatefulWidget {
  final String moduleId;
  final String policyId;
  final List<ControlEntity> siblingControls;
  final ControlEntity? existingControl;
  final DateTime policyStartDate;
  final DateTime policyEndDate;
  final bool policyHasArabic;
  final PolicyEntity policy;

  const AddEditControlPage({
    super.key,
    required this.moduleId,
    required this.policyId,
    required this.siblingControls,
    required this.policyStartDate,
    required this.policyEndDate,
    required this.policyHasArabic,
    this.existingControl,
    required this.policy,
  });

  @override
  State<AddEditControlPage> createState() => _AddEditControlPageState();
}

class _AddEditControlPageState extends State<AddEditControlPage> {
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _numberController = TextEditingController();
  final _numberArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _weightController = TextEditingController();

  String? _frequency;
  DateTime? _startDate;
  DateTime? _endDate;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;
  bool _submitted = false;

  /// The "Status" switch: true once the user manually flips an Active
  /// control to Inactive. Initialized from the existing control's status in
  /// Edit mode (see initState) so re-opening an already-Inactive control
  /// shows the switch correctly; always false in Create mode.
  bool _manualInactive = false;
  List<String>? _currentChampionEmails;
  List<String>? _currentOwnerEmails;

  static const String _allDepartmentsValue = 'All';

  // Department + weight state.
  // - [_selectedDepartments] holds every checked value from the Department
  //   multi-select, including the [_allDepartmentsValue] sentinel when "All"
  //   is checked. [_realSelectedDepartments] strips that sentinel out.
  // - Checking "All" (or manually checking every real department) selects
  //   every department and forces [_equalWeights] on, since an all-department
  //   split is always equal by definition.
  // - Otherwise [_equalWeights] is user-controlled: true auto-splits 100
  //   evenly across the selected departments, false requires a manual weight
  //   per department (summing to 100) via [_departmentWeightControllers].
  bool _equalWeights = true;
  List<String> _selectedDepartments = [];
  final Map<String, TextEditingController> _departmentWeightControllers = {};

  bool get _isEdit => widget.existingControl != null;

  /// Whether Arabic fields show at all — no longer a per-Control toggle,
  /// this now always mirrors the parent Policy's own Arabic-enabled state
  /// (same "any Arabic field non-empty" inference PolicyEditPage uses),
  /// so a Policy without Arabic content never shows Arabic fields on any
  /// of its Controls, and vice versa.
  bool get _isArabicEnabled => widget.policyHasArabic;

  /// True once the user has entered something into any Arabic field —
  /// mirrors PolicyEditPage/CreateNewPolicyPage's _arabicTouched. Turning
  /// the toggle on by itself doesn't make Name/Number/Description AR
  /// required — only starting to fill one of them in does.
  bool get _arabicTouched =>
      _nameArController.text.trim().isNotEmpty ||
      _numberArController.text.trim().isNotEmpty ||
      _descriptionArController.text.trim().isNotEmpty;

  /// In Create mode there's no per-control Start/End Date UI — the Control
  /// inherits the parent Policy's dates. In Edit mode the existing
  /// per-control fields are used unchanged.
  DateTime get _effectiveStartDate =>
      _isEdit ? _startDate! : widget.policyStartDate;
  DateTime get _effectiveEndDate => _isEdit ? _endDate! : widget.policyEndDate;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingControl;
    if (existing == null) return;
    _nameController.text = existing.controlsNameEn;
    _nameArController.text = existing.controlsNameAr;
    _numberController.text = existing.controlsNumberEn;
    _numberArController.text = existing.controlsNumberAr;
    _descriptionController.text = existing.controlsDescriptionEn;
    _descriptionArController.text = existing.controlsDescriptionAr;
    _weightController.text = existing.controlsWeight.toStringAsFixed(0);
    _frequency = existing.frequency.isEmpty ? null : existing.frequency;
    _startDate = existing.startDate;
    _endDate = existing.endDate;
    _manualInactive = existing.status == ControlStatus.inactive;
    _documentEn = existing.controlsDocumentEn != null
        ? PolicyDocumentInfo.fromUrl(existing.controlsDocumentEn!)
        : null;
    _documentAr = existing.controlsDocumentAr != null
        ? PolicyDocumentInfo.fromUrl(existing.controlsDocumentAr!)
        : null;
    _equalWeights = existing.equalWeights;
    final existingDepartmentNames =
        existing.departments.map((d) => d.department).toList();
    final totalDepartmentsCount =
        Get.find<MainCoreDepartmentController>().departmentIds.length;
    final wasAllDepartments = existingDepartmentNames.isNotEmpty &&
        existingDepartmentNames.length == totalDepartmentsCount;
    _selectedDepartments = [
      if (wasAllDepartments) _allDepartmentsValue,
      ...existingDepartmentNames,
    ];
    // Rows (and their weight fields) are hidden entirely once "All" is
    // selected, so only build controllers otherwise. The persisted weight is
    // shown as-is — when equalWeights is true that's already an equal split.
    if (!wasAllDepartments) {
      for (final d in existing.departments) {
        _departmentWeightControllers[d.department] =
            TextEditingController(text: formatControlWeight(d.weight));
      }
    }
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
    for (final c in _departmentWeightControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double get _siblingsWeight => widget.siblingControls
      .where((c) => c.id != widget.existingControl?.id)
      .fold<double>(0, (sum, c) => sum + c.controlsWeight);

  double get _thisWeight => double.tryParse(_weightController.text.trim()) ?? 0;

  double get _totalDepartmentsWeight => _departmentWeightControllers.values
      .fold<double>(0, (sum, c) => sum + (double.tryParse(c.text.trim()) ?? 0));

  /// Every checked department, minus the [_allDepartmentsValue] sentinel.
  List<String> get _realSelectedDepartments =>
      _selectedDepartments.where((d) => d != _allDepartmentsValue).toList();

  bool get _isAllDepartmentsSelected =>
      _selectedDepartments.contains(_allDepartmentsValue);

  bool get _isDepartmentsWeightValid =>
      _equalWeights ||
      _realSelectedDepartments.isEmpty ||
      _totalDepartmentsWeight == 100;

  /// True unless the currently entered Start/End Date fall outside the
  /// parent Policy's own Start/End Date range, or End Date is before Start
  /// Date. A Control's schedule must always sit inside its Policy's.
  bool get _isControlDateRangeValid {
    if (_startDate == null || _endDate == null) return true;
    return !_startDate!.isBefore(widget.policyStartDate) &&
        !_startDate!.isAfter(widget.policyEndDate) &&
        !_endDate!.isBefore(widget.policyStartDate) &&
        !_endDate!.isAfter(widget.policyEndDate) &&
        !_endDate!.isBefore(_startDate!);
  }

  String? get _startDateError {
    if (_submitted && _startDate == null) return 'This field is required.'.tr;
    if (_startDate == null) return null;
    if (_startDate!.isBefore(widget.policyStartDate)) {
      return 'Start date cannot be before the Policy start date.'.tr;
    }
    if (_startDate!.isAfter(widget.policyEndDate)) {
      return 'Start date cannot be after the Policy end date.'.tr;
    }
    return null;
  }

  String? get _endDateError {
    if (_submitted && _endDate == null) return 'This field is required.'.tr;
    if (_endDate == null) return null;
    if (_startDate != null && _endDate!.isBefore(_startDate!)) {
      return 'End date cannot be before start date.'.tr;
    }
    if (_endDate!.isBefore(widget.policyStartDate)) {
      return 'End date cannot be before the Policy start date.'.tr;
    }
    if (_endDate!.isAfter(widget.policyEndDate)) {
      return 'End date cannot be after the Policy end date.'.tr;
    }
    return null;
  }

  /// The department names to send to the cubit on save.
  List<String> get _departmentsForSave => _realSelectedDepartments;

  /// The manual per-department weights to send to the cubit on save. `null`
  /// when [_equalWeights] is true, since the model generates an equal split
  /// on its own.
  List<double>? get _departmentWeightsForSave {
    if (_equalWeights) return null;
    return _realSelectedDepartments
        .map((d) =>
            double.tryParse(
                _departmentWeightControllers[d]?.text.trim() ?? '') ??
            0)
        .toList();
  }

  /// Keeps [_departmentWeightControllers] in sync with the currently
  /// selected (non-"All") departments: adds a controller for newly selected
  /// departments and disposes/removes controllers for deselected ones.
  void _syncDepartmentWeightControllers() {
    final selected = _realSelectedDepartments.toSet();
    _departmentWeightControllers.removeWhere((department, controller) {
      final stale = !selected.contains(department);
      if (stale) controller.dispose();
      return stale;
    });
    for (final department in selected) {
      _departmentWeightControllers.putIfAbsent(
          department, () => TextEditingController(text: '0'));
    }
  }

  /// Overwrites every selected department's weight controller with its
  /// share of an equal 100-way split, matching [DepartmentWeight.equalSplit]
  /// (the same helper the backend uses on save) so what's shown here is
  /// exactly what gets persisted.
  void _applyEqualSplitToControllers() {
    for (final entry in DepartmentWeight.equalSplit(_realSelectedDepartments)) {
      _departmentWeightControllers[entry.department]?.text =
          formatControlWeight(entry.weight);
    }
  }

  void _onEqualWeightsChanged(bool value) {
    if (_isAllDepartmentsSelected) return;
    setState(() {
      _equalWeights = value;
      _syncDepartmentWeightControllers();
      if (value) _applyEqualSplitToControllers();
    });
  }

  /// function name: [_onDepartmentsChanged]
  ///
  /// purpose: reconcile the raw toggle event from [CustomMultiSelectDropdown]
  ///          against the business rule that "All" and "every real department
  ///          individually checked" are the same state, and that state always
  ///          forces [_equalWeights] on.
  ///
  /// parameters:
  ///            [List<String>] newSelection: the full new selection reported by the dropdown
  ///            [List<String>] availableDepartmentNames: every real (non-"All") department name
  void _onDepartmentsChanged(
      List<String> newSelection, List<String> availableDepartmentNames) {
    final justChecked =
        newSelection.where((d) => !_selectedDepartments.contains(d)).toList();
    final justUnchecked =
        _selectedDepartments.where((d) => !newSelection.contains(d)).toList();
    final toggled = justChecked.isNotEmpty
        ? justChecked.first
        : (justUnchecked.isNotEmpty ? justUnchecked.first : null);

    setState(() {
      if (toggled == _allDepartmentsValue) {
        if (justChecked.contains(_allDepartmentsValue)) {
          _selectedDepartments = [
            _allDepartmentsValue,
            ...availableDepartmentNames,
          ];
          _equalWeights = true;
        } else {
          _selectedDepartments = [];
        }
      } else {
        final realSelection =
            newSelection.where((d) => d != _allDepartmentsValue).toList();
        if (availableDepartmentNames.isNotEmpty &&
            realSelection.length == availableDepartmentNames.length) {
          _selectedDepartments = [_allDepartmentsValue, ...realSelection];
          _equalWeights = true;
        } else {
          _selectedDepartments = realSelection;
        }
      }
      if (_isAllDepartmentsSelected) {
        for (final c in _departmentWeightControllers.values) {
          c.dispose();
        }
        _departmentWeightControllers.clear();
      } else {
        _syncDepartmentWeightControllers();
        if (_equalWeights) _applyEqualSplitToControllers();
      }
    });
  }

  void _onRemoveDepartment(String department) {
    setState(() {
      _selectedDepartments = _selectedDepartments
          .where((d) => d != department && d != _allDepartmentsValue)
          .toList();
      _departmentWeightControllers.remove(department)?.dispose();
      if (_equalWeights) _applyEqualSplitToControllers();
    });
  }

  bool _validate() {
    setState(() => _submitted = true);
    final endBeforeStart = _endDate != null &&
        _startDate != null &&
        _endDate!.isBefore(_startDate!);
    return _nameController.text.trim().isNotEmpty &&
        _numberController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        (!_isArabicEnabled ||
            !_arabicTouched ||
            (_nameArController.text.trim().isNotEmpty &&
                _numberArController.text.trim().isNotEmpty &&
                _descriptionArController.text.trim().isNotEmpty)) &&
        !containsArabicLetters(_nameController.text) &&
        !containsArabicLetters(_numberController.text) &&
        !containsArabicLetters(_descriptionController.text) &&
        (!_isArabicEnabled ||
            (!containsEnglishLetters(_nameArController.text) &&
                !containsEnglishLetters(_numberArController.text) &&
                !containsEnglishLetters(_descriptionArController.text))) &&
        _frequency != null &&
        (!_isEdit ||
            (_startDate != null && _endDate != null && !endBeforeStart)) &&
        double.tryParse(_weightController.text.trim()) != null &&
        (!_isEdit ||
            (_realSelectedDepartments.isNotEmpty &&
                (_equalWeights || _totalDepartmentsWeight == 100)));
  }

  void _onUploadDocumentEn() {
    showUploadDialog(
      context: context,
      dialogTitle: 'Upload Control Document (English)'.tr,
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
      dialogTitle: 'Upload Control Document (Arabic)'.tr,
      titleFieldLabel: 'Document Title'.tr,
      titleFieldHint: 'Type here'.tr,
      browseLabel: 'Browse Files'.tr,
      submitLabel: 'Submit'.tr,
      discardLabel: 'Cancel'.tr,
      textDirection: TextDirection.rtl,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onSubmit: (file, title) {
        setState(() => _documentAr = PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  void _onRemoveDocumentEn() => setState(() => _documentEn = null);
  void _onRemoveDocumentAr() => setState(() => _documentAr = null);

  /// Live validation for the Control Weight field: must be a positive
  /// number no greater than 100, mirroring Policy Weight's own rule.
  String? get _weightError {
    final text = _weightController.text.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null) return 'Control Weight must be a valid number'.tr;
    if (value <= 0) return 'Control Weight must be a positive number'.tr;
    if (value > 100) return 'Control Weight cannot be more than 100'.tr;
    return null;
  }

  /// Shared text field builder: shows a live English-only/Arabic-only
  /// language-mismatch error, matching the same rule used elsewhere in
  /// this feature (e.g. PolicyControlItemWidget).
  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool rtl = false,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool showCharCount = false,
    bool onlyDigits = false,
    bool submitted = false,
    String? englishOnlyError,
    String? arabicOnlyError,
    String? customError,
  }) {
    final languageError = rtl
        ? (containsEnglishLetters(controller.text) ? arabicOnlyError : null)
        : (containsArabicLetters(controller.text) ? englishOnlyError : null);

    final field = CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      required: true,
      submitted: submitted,
      onlyDigits: onlyDigits,
      errorText: customError ?? languageError,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCharCount: showCharCount,
      fillColor: AppColors.background,
      onChanged: (_) => setState(() {}),
    );

    if (!rtl) return field;
    return Directionality(textDirection: TextDirection.rtl, child: field);
  }

  /// Scheduled if the effective Start Date (the inherited Policy date in
  /// Create mode, or the control's own edited date in Edit mode) hasn't
  /// arrived yet (strictly after today), otherwise Active. This is the
  /// "would-be" status before [_resolvedStatus]'s assignee-based
  /// Unassigned override is applied — used by both the Add and Save
  /// actions, recomputed every time either is pressed.
  ControlStatus get _computedStatus {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return _effectiveStartDate.isAfter(startOfToday)
        ? ControlStatus.scheduled
        : ControlStatus.active;
  }

  /// True if at least one Champion or Owner is currently assigned to this
  /// control: the live picker selection if the user touched it, otherwise
  /// whoever was already assigned when the page opened. A brand-new
  /// Control has no assignees section at all (Create mode hides it), so
  /// this is always false there.
  bool _hasAnyAssignee(BuildContext context) {
    final championState = context.read<ChampionCubit>().state;
    final championEmails = _currentChampionEmails ??
        (_isEdit && championState is ChampionListLoaded
            ? _alreadyAssignedChampionEmails(championState.champions)
            : const <String>[]);
    final ownerState = context.read<OwnerCubit>().state;
    final ownerEmails = _currentOwnerEmails ??
        (_isEdit && ownerState is OwnerListLoaded
            ? _alreadyAssignedOwnerEmails(ownerState.owners)
            : const <String>[]);
    return championEmails.isNotEmpty || ownerEmails.isNotEmpty;
  }

  /// Applies the manual-Inactive and assignee-based overrides on top of
  /// [requested]: Draft (Save For Later) always wins as-is. Otherwise, if
  /// the user flipped the "Status" switch to Inactive, that wins next.
  /// Failing both, any other status becomes Unassigned unless at least one
  /// Champion or Owner is currently assigned, in which case [requested]
  /// (the date-computed Scheduled/Active) stands.
  ControlStatus _resolvedStatus(BuildContext context, ControlStatus requested) {
    if (requested == ControlStatus.draft) return requested;
    if (_manualInactive) return ControlStatus.inactive;
    return _hasAnyAssignee(context) ? requested : ControlStatus.unassigned;
  }

  void _onSave(PolicyCubit cubit, {required ControlStatus status}) {
    if (_isEdit) {
      cubit.updateControl(
        id: widget.existingControl!.id,
        moduleId: widget.moduleId,
        policyId: widget.policyId,
        controlsNameEn: _nameController.text.trim(),
        controlsNameAr: _nameArController.text.trim(),
        controlsNumberEn: _numberController.text.trim(),
        controlsNumberAr: _numberArController.text.trim(),
        controlsDescriptionEn: _descriptionController.text.trim(),
        controlsDescriptionAr: _descriptionArController.text.trim(),
        controlsWeight: _thisWeight,
        frequency: _frequency,
        startDate: _startDate,
        endDate: _endDate,
        departments: _departmentsForSave,
        departmentsWeights: _departmentWeightsForSave,
        equalWeights: _equalWeights,
        status: status,
        controlsDocumentFileEn: _documentEn?.file,
        controlsDocumentUrlEn:
            _documentEn?.file == null ? _documentEn?.url : null,
        controlsDocumentFileAr: _documentAr?.file,
        controlsDocumentUrlAr:
            _documentAr?.file == null ? _documentAr?.url : null,
      );
    } else {
      cubit.createControl(
        moduleId: widget.moduleId,
        policyId: widget.policyId,
        controlsNameEn: _nameController.text.trim(),
        controlsNameAr: _nameArController.text.trim(),
        controlsNumberEn: _numberController.text.trim(),
        controlsNumberAr: _numberArController.text.trim(),
        controlsDescriptionEn: _descriptionController.text.trim(),
        controlsDescriptionAr: _descriptionArController.text.trim(),
        controlsWeight: _thisWeight,
        frequency: _frequency!,
        startDate: _effectiveStartDate,
        endDate: _effectiveEndDate,
        departments: const [],
        departmentsWeights: null,
        equalWeights: true,
        score: 0,
        status: status,
        controlsDocumentFileEn: _documentEn?.file,
        controlsDocumentFileAr: _documentAr?.file,
      );
    }
  }

  Future<void> _onStateChange(BuildContext context, PolicyState state) async {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyControlActionSuccess) {
      if (_isEdit) {
        await _applyAssigneeChanges(context);
      }
      if (!context.mounted) return;
      final isDraft = state.control.status == ControlStatus.draft;
      showSuccessDialog(
        context: context,
        title: isDraft
            ? 'Saved as Draft'.tr
            : (_isEdit ? 'Control Updated'.tr : 'Control Created'.tr),
        subtitle: isDraft
            ? 'Control saved as draft successfully'.tr
            : (_isEdit
                ? 'You successfully updated this control.'.tr
                : 'You successfully created this control.'.tr),
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is PolicyFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
      );
    }
  }

  Widget _documentButton({required VoidCallback onTap, required String title}) {
    return customButtonWithSvg(
      colorBorder: AppColors.primary,
      space: 10.w,
      radius: 8.r,
      widthImage: 16.w,
      heightImage: 16.h,
      function: onTap,
      title: title,
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
      image: 'assets/hrAsset/Upload.svg',
      color: AppColors.primary,
      width: 220.w,
      height: 36.h,
      svgColor: AppColors.textButton,
    );
  }

  /// function name: [_documentColumn]
  ///
  /// purpose: one document upload/preview column — shared by the ENG and AR
  ///          Control Document sections so their layout stays identical
  ///          whether they're shown side by side or (Arabic disabled) alone.
  Widget _documentColumn({
    required String label,
    required PolicyDocumentInfo? document,
    required VoidCallback onRemove,
    required VoidCallback onUpload,
  }) {
    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        document != null
            ? PolicyDocumentPreviewWidget(
                document: document, onRemove: onRemove)
            : SizedBox(
                width: double.infinity,
                child:
                    _documentButton(onTap: onUpload, title: 'Control Document'),
              ),
      ],
    );
  }

  /// function name: [_availableDepartmentNames]
  ///
  /// purpose: build the list of real (non-"All") department names from
  ///          [MainCoreDepartmentController], localized to the current
  ///          locale, mirroring the pattern used by `GrcFormFields`.
  List<String> _availableDepartmentNames(BuildContext context) {
    final departmentController = Get.find<MainCoreDepartmentController>();
    final isArabic = context.isArabic;
    return departmentController.departmentIds
        .map((id) => isArabic
            ? departmentController.getArabicDepartmentNameFromDepartmentId(
                departmentId: id)
            : departmentController.getEnglishDepartmentNameFromDepartmentId(
                departmentId: id))
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// function name: [_buildDepartmentsSection]
  ///
  /// purpose: render the Department multi-select next to the Equal Weights
  ///          toggle. Checking "All" (or every real department individually)
  ///          selects every department and locks Equal Weights on, since an
  ///          all-department split is always equal. Otherwise Equal Weights
  ///          is user-controlled: on auto-splits 100 across the selection,
  ///          off shows an editable weight row per selected department with
  ///          a running total below (highlighted in red until it sums to
  ///          100).
  Widget _buildDepartmentsSection() {
    final availableDepartmentNames = _availableDepartmentNames(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomMultiSelectDropdown<String>(
                label: 'Department'.tr,
                hint: 'Select Department'.tr,
                items: [
                  MultiSelectDropdownItem<String>(
                      value: _allDepartmentsValue, label: 'All'.tr),
                  ...availableDepartmentNames.map(
                    (d) => MultiSelectDropdownItem<String>(value: d, label: d),
                  ),
                ],
                values: _selectedDepartments,
                onChanged: (newSelection) => _onDepartmentsChanged(
                    newSelection, availableDepartmentNames),
                fillColor: AppColors.background,
                errorText: _submitted && _realSelectedDepartments.isEmpty
                    ? 'This field is required.'.tr
                    : null,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Equal Weights'.tr,
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.text),
                  ),
                  Spacer(),
                  FlutterSwitch(
                    width: 38.sp,
                    height: 22.sp,
                    padding: 3.sp,
                    borderRadius: 20.sp,
                    toggleSize: 16.sp,
                    activeColor: AppColors.secondaryPrimary,
                    inactiveColor: Colors.grey.withValues(alpha: 0.16),
                    value: _equalWeights,
                    onToggle: _onEqualWeightsChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_realSelectedDepartments.isNotEmpty &&
            !_isAllDepartmentsSelected) ...[
          SizedBox(height: 15.h),
          ..._realSelectedDepartments.map(_buildDepartmentWeightRow),
          Container(
            width: 160.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isDepartmentsWeightValid
                    ? AppColors.border
                    : AppColors.red,
              ),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '${'Total Weight'.tr} : ${_totalDepartmentsWeight.toStringAsFixed(0)}',
              style: StyleText.fontSize14Weight500.copyWith(
                color:
                    _isDepartmentsWeightValid ? AppColors.text : AppColors.red,
              ),
            ),
          ),
          if (!_isDepartmentsWeightValid) ...[
            SizedBox(height: 4.h),
            Text(
              'Total Weight should be 100'.tr,
              style:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
            ),
          ],
        ],
      ],
    );
  }

  /// function name: [_buildDepartmentWeightRow]
  ///
  /// purpose: render a single selected department's name alongside its
  ///          weight field and a control to remove it from the selection.
  ///          The weight field is editable while Equal Weights is off, and
  ///          read-only (showing the auto-computed equal share) while it's
  ///          on — hidden entirely only when "All" is selected instead.
  ///
  /// parameters:
  ///            [String] department: the department name this row represents
  ///
  /// return type: [Widget] - the row widget for this department
  Widget _buildDepartmentWeightRow(String department) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40.h,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                department,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: CustomTextField(
              hint: '0',
              controller: _departmentWeightControllers[department],
              fillColor: AppColors.background,
              readOnly: _equalWeights,
              onChanged: _equalWeights ? null : (_) => setState(() {}),
            ),
          ),
          SizedBox(width: 4.w),
          IconButton(
            icon: Icon(Icons.remove_circle, color: AppColors.red, size: 20.sp),
            onPressed: () => _onRemoveDepartment(department),
          ),
        ],
      ),
    );
  }

  /// Every Champion email whose Assigning_Controls already includes this
  /// exact {Policy, Control} pair. Only meaningful in edit mode.
  List<String> _alreadyAssignedChampionEmails(List<ChampionEntity> champions) {
    final controlId = widget.existingControl!.id;
    return champions
        .where((c) => c.assigningControls.any(
            (a) => a.policyId == widget.policyId && a.controlId == controlId))
        .map((c) => c.championEmail)
        .toList();
  }

  /// Every Owner email whose Assigning_Controls already includes this
  /// exact {Policy, Control} pair. Only meaningful in edit mode.
  List<String> _alreadyAssignedOwnerEmails(List<OwnerEntity> owners) {
    final controlId = widget.existingControl!.id;
    return owners
        .where((o) => o.assigningControls.any(
            (a) => a.policyId == widget.policyId && a.controlId == controlId))
        .map((o) => o.ownerEmail)
        .toList();
  }

  ChampionEntity? _findChampion(List<ChampionEntity> all, String email) {
    for (final c in all) {
      if (c.championEmail == email) return c;
    }
    return null;
  }

  OwnerEntity? _findOwner(List<OwnerEntity> all, String email) {
    for (final o in all) {
      if (o.ownerEmail == email) return o;
    }
    return null;
  }

  /// function name: [_applyChampionDiff]
  ///
  /// purpose: reconcile [selected] (the picker's current selection) against
  ///          [alreadyAssigned] (what was true when the page opened) by
  ///          appending/removing this {Policy, Control} pair on exactly the
  ///          people whose selection state actually changed. Every call is
  ///          awaited sequentially — at most a handful of people per save,
  ///          simplicity over throughput.
  ///
  /// return type: [Future<bool>] - false if any individual update/create failed
  Future<bool> _applyChampionDiff({
    required ChampionCubit cubit,
    required List<ChampionEntity> allChampions,
    required List<String> alreadyAssigned,
    required List<String> selected,
    required String controlId,
  }) async {
    var success = true;
    final added = selected.where((e) => !alreadyAssigned.contains(e));
    final removed = alreadyAssigned.where((e) => !selected.contains(e));

    for (final email in added) {
      final existing = _findChampion(allChampions, email);
      if (existing != null) {
        await cubit.updateChampion(
          championEmail: email,
          moduleId: widget.moduleId,
          assigningControls: [
            ...existing.assigningControls,
            AssigningControlEntity(
                policyId: widget.policyId, controlId: controlId),
          ],
        );
      } else {
        await cubit.createChampion(
          moduleId: widget.moduleId,
          championEmail: email,
          assigningControls: [
            AssigningControlEntity(
                policyId: widget.policyId, controlId: controlId),
          ],
        );
      }
      if (cubit.state is ChampionFailure) success = false;
    }

    for (final email in removed) {
      final existing = _findChampion(allChampions, email);
      if (existing == null) continue;
      await cubit.updateChampion(
        championEmail: email,
        moduleId: widget.moduleId,
        assigningControls: existing.assigningControls
            .where((a) =>
                !(a.policyId == widget.policyId && a.controlId == controlId))
            .toList(),
      );
      if (cubit.state is ChampionFailure) success = false;
    }

    return success;
  }

  /// Mirrors [_applyChampionDiff] for Control Owners.
  Future<bool> _applyOwnerDiff({
    required OwnerCubit cubit,
    required List<OwnerEntity> allOwners,
    required List<String> alreadyAssigned,
    required List<String> selected,
    required String controlId,
  }) async {
    var success = true;
    final added = selected.where((e) => !alreadyAssigned.contains(e));
    final removed = alreadyAssigned.where((e) => !selected.contains(e));

    for (final email in added) {
      final existing = _findOwner(allOwners, email);
      if (existing != null) {
        await cubit.updateOwner(
          ownerEmail: email,
          moduleId: widget.moduleId,
          assigningControls: [
            ...existing.assigningControls,
            AssigningControlEntity(
                policyId: widget.policyId, controlId: controlId),
          ],
        );
      } else {
        await cubit.createOwner(
          moduleId: widget.moduleId,
          ownerEmail: email,
          assigningControls: [
            AssigningControlEntity(
                policyId: widget.policyId, controlId: controlId),
          ],
        );
      }
      if (cubit.state is OwnerFailure) success = false;
    }

    for (final email in removed) {
      final existing = _findOwner(allOwners, email);
      if (existing == null) continue;
      await cubit.updateOwner(
        ownerEmail: email,
        moduleId: widget.moduleId,
        assigningControls: existing.assigningControls
            .where((a) =>
                !(a.policyId == widget.policyId && a.controlId == controlId))
            .toList(),
      );
      if (cubit.state is OwnerFailure) success = false;
    }

    return success;
  }

  /// function name: [_applyAssigneeChanges]
  ///
  /// purpose: called once the Control itself has already saved
  ///          successfully. Reads each Cubit's already-loaded state
  ///          directly (no re-fetch — the page loaded it once on open and
  ///          never refreshes it), recomputes "already assigned" the same
  ///          way [_buildAssigneesSections] did, and diffs it against
  ///          whatever the user last toggled. If a Cubit never finished
  ///          loading, that side is skipped entirely rather than guessed at.
  Future<void> _applyAssigneeChanges(BuildContext context) async {
    final controlId = widget.existingControl!.id;
    final championCubit = context.read<ChampionCubit>();
    final ownerCubit = context.read<OwnerCubit>();
    var hadFailure = false;

    final championState = championCubit.state;
    if (championState is ChampionListLoaded) {
      final alreadyAssigned =
          _alreadyAssignedChampionEmails(championState.champions);
      final selected = _currentChampionEmails ?? alreadyAssigned;
      final ok = await _applyChampionDiff(
        cubit: championCubit,
        allChampions: championState.champions,
        alreadyAssigned: alreadyAssigned,
        selected: selected,
        controlId: controlId,
      );
      if (!ok) hadFailure = true;
    }

    final ownerState = ownerCubit.state;
    if (ownerState is OwnerListLoaded) {
      final alreadyAssigned = _alreadyAssignedOwnerEmails(ownerState.owners);
      final selected = _currentOwnerEmails ?? alreadyAssigned;
      final ok = await _applyOwnerDiff(
        cubit: ownerCubit,
        allOwners: ownerState.owners,
        alreadyAssigned: alreadyAssigned,
        selected: selected,
        controlId: controlId,
      );
      if (!ok) hadFailure = true;
    }

    if (hadFailure && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Some champion/owner assignments couldn't be saved.".tr),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  /// function name: [_buildAssigneesSections]
  ///
  /// purpose: render the "Control Champions" and "Control Owner" pickers
  ///          below the Departments section. Edit mode only — a new
  ///          Control has no id to assign against yet. Each picker starts
  ///          pre-selected with whoever is already assigned to this exact
  ///          {Policy, Control} pair, filtered live by the Control's
  ///          currently-selected departments, and reports every toggle back
  ///          via [_currentChampionEmails]/[_currentOwnerEmails] — nothing
  ///          is persisted here; see [_applyAssigneeChanges] (Task 4) for
  ///          that, which runs after the Control itself saves.
  Widget _buildAssigneesSections() {
    if (!_isEdit) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        BlocBuilder<ChampionCubit, ChampionState>(
          builder: (context, state) {
            if (state is! ChampionListLoaded) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return GrcOwnerSection(
              sectionTitle: 'Control Champions',
              initialOwnerEmails:
                  _alreadyAssignedChampionEmails(state.champions),
              selectedDepartmentNames: _realSelectedDepartments,
              showRemoveIconWhenSelected: true,
              onOwnersChanged: (selected) => setState(() =>
                  _currentChampionEmails =
                      selected.map((o) => o.email).toList()),
            );
          },
        ),
        SizedBox(height: 15.h),
        BlocBuilder<OwnerCubit, OwnerState>(
          builder: (context, state) {
            if (state is! OwnerListLoaded) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return GrcOwnerSection(
              sectionTitle: 'Control Owner',
              initialOwnerEmails: _alreadyAssignedOwnerEmails(state.owners),
              selectedDepartmentNames: _realSelectedDepartments,
              showRemoveIconWhenSelected: true,
              onOwnersChanged: (selected) => setState(() =>
                  _currentOwnerEmails = selected.map((o) => o.email).toList()),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyCubit>(create: (_) => GetIt.instance<PolicyCubit>()),
        BlocProvider<ChampionCubit>(
          create: (_) => GetIt.instance<ChampionCubit>()
            ..getAllChampions(moduleId: widget.moduleId),
        ),
        BlocProvider<OwnerCubit>(
          create: (_) => GetIt.instance<OwnerCubit>()
            ..getAllOwners(moduleId: widget.moduleId),
        ),
      ],
      child: Builder(
        builder: (ctx) {
          final cubit = ctx.read<PolicyCubit>();
          return BlocListener<PolicyCubit, PolicyState>(
            listener: _onStateChange,
            child: Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaginationAppBar(
                        screensTitles: [
                          'GRC'.tr,
                          context.isArabic
                              ? widget.policy.policyNameAr
                              : widget.policy.policyNameEn,
                          context.isArabic
                              ? "Edit ${widget.existingControl?.controlsNameAr}"
                              : "Edit ${widget.existingControl?.controlsNameEn}",
                        ],
                      ),
                      // Only an already-saved Control has a real status to
                      // manually deactivate — Create mode's status isn't
                      // decided until Add/Save For Later is pressed.
                      if (_isEdit)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SvgPicture.asset(
                                'assets/icons_assets/data_grc_assets/icons_status.svg'),
                            SizedBox(width: 10.w),
                            Text('Status'.tr),
                            SizedBox(width: 10.w),
                            FlutterSwitch(
                              width: 38.sp,
                              height: 22.sp,
                              padding: 3.sp,
                              borderRadius: 20.sp,
                              toggleSize: 16.sp,
                              activeColor: AppColors.secondaryPrimary,
                              inactiveColor:
                                  Colors.grey.withValues(alpha: 0.16),
                              value: !_manualInactive,
                              onToggle: (v) =>
                                  setState(() => _manualInactive = !v),
                            ),
                          ],
                        ),
                      SizedBox(height: 12.h),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15.sp),
                          decoration: BoxDecoration(
                            color: AppColors.field,
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isTablet
                                      ? Row(children: [
                                          Expanded(
                                            child: _textField(
                                              label: 'Control Name'.tr,
                                              hint: 'Text here'.tr,
                                              controller: _nameController,
                                              submitted: _submitted,
                                              englishOnlyError:
                                                  'Control Name must be written in English'
                                                      .tr,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: _isArabicEnabled
                                                ? _textField(
                                                    label: 'Control Name'.tr,
                                                    hint: 'Type here'.tr,
                                                    controller:
                                                        _nameArController,
                                                    rtl: true,
                                                    submitted: _submitted &&
                                                        _arabicTouched,
                                                    arabicOnlyError:
                                                        'Control Name must be written in Arabic'
                                                            .tr,
                                                  )
                                                : _textField(
                                                    label: 'Control Number'.tr,
                                                    hint: 'Text here'.tr,
                                                    controller:
                                                        _numberController,
                                                    submitted: _submitted,
                                                    englishOnlyError:
                                                        'Control Number must be written in English'
                                                            .tr,
                                                  ),
                                          ),
                                        ])
                                      : Column(children: [
                                          _textField(
                                            label: 'Control Name'.tr,
                                            hint: 'Text here'.tr,
                                            controller: _nameController,
                                            submitted: _submitted,
                                            englishOnlyError:
                                                'Control Name must be written in English'
                                                    .tr,
                                          ),
                                          SizedBox(height: 15.h),
                                          _isArabicEnabled
                                              ? _textField(
                                                  label: 'Control Name'.tr,
                                                  hint: 'Type here'.tr,
                                                  controller: _nameArController,
                                                  rtl: true,
                                                  submitted: _submitted &&
                                                      _arabicTouched,
                                                  arabicOnlyError:
                                                      'Control Name must be written in Arabic'
                                                          .tr,
                                                )
                                              : _textField(
                                                  label: 'Control Number'.tr,
                                                  hint: 'Text here'.tr,
                                                  controller: _numberController,
                                                  submitted: _submitted,
                                                  englishOnlyError:
                                                      'Control Number must be written in English'
                                                          .tr,
                                                ),
                                        ]),
                                  SizedBox(height: 15.h),
                                  if (_isArabicEnabled) ...[
                                    isTablet
                                        ? Row(children: [
                                            Expanded(
                                              child: _textField(
                                                label: 'Control Number'.tr,
                                                hint: 'Text here'.tr,
                                                controller: _numberController,
                                                submitted: _submitted,
                                                englishOnlyError:
                                                    'Control Number must be written in English'
                                                        .tr,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: _textField(
                                                label: 'Control Number'.tr,
                                                hint: 'Type here'.tr,
                                                controller: _numberArController,
                                                rtl: true,
                                                submitted: _submitted &&
                                                    _arabicTouched,
                                                arabicOnlyError:
                                                    'Control Number must be written in Arabic'
                                                        .tr,
                                              ),
                                            ),
                                          ])
                                        : Column(children: [
                                            _textField(
                                              label: 'Control Number'.tr,
                                              hint: 'Text here'.tr,
                                              controller: _numberController,
                                              submitted: _submitted,
                                              englishOnlyError:
                                                  'Control Number must be written in English'
                                                      .tr,
                                            ),
                                            SizedBox(height: 15.h),
                                            _textField(
                                              label: 'Control Number'.tr,
                                              hint: 'Type here'.tr,
                                              controller: _numberArController,
                                              rtl: true,
                                              submitted:
                                                  _submitted && _arabicTouched,
                                              arabicOnlyError:
                                                  'Control Number must be written in Arabic'
                                                      .tr,
                                            ),
                                          ]),
                                    SizedBox(height: 15.h),
                                  ],
                                  _textField(
                                    label: 'Control Description'.tr,
                                    hint: 'Text here'.tr,
                                    controller: _descriptionController,
                                    submitted: _submitted,
                                    maxLines: 3,
                                    minLines: 3,
                                    maxLength: 500,
                                    showCharCount: true,
                                    englishOnlyError:
                                        'Control Description must be written in English'
                                            .tr,
                                  ),
                                  if (_isArabicEnabled) ...[
                                    SizedBox(height: 15.h),
                                    _textField(
                                      label: 'Control Description'.tr,
                                      hint: 'Write a Description'.tr,
                                      controller: _descriptionArController,
                                      rtl: true,
                                      submitted: _submitted && _arabicTouched,
                                      maxLines: 3,
                                      minLines: 3,
                                      maxLength: 500,
                                      showCharCount: true,
                                      arabicOnlyError:
                                          'Control Description must be written in Arabic'
                                              .tr,
                                    ),
                                  ],
                                  SizedBox(height: 15.h),
                                  if (_isEdit) ...[
                                    isTablet
                                        ? Row(children: [
                                            Expanded(
                                              child: CustomDropdownCalendar(
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                                label: 'Start Date'.tr,
                                                hint: 'Select Start Date'.tr,
                                                value: _startDate,
                                                onChanged: (d) => setState(
                                                    () => _startDate = d),
                                                fillColor: AppColors.background,
                                                firstDate:
                                                    widget.policyStartDate,
                                                lastDate: widget.policyEndDate,
                                                dateFormatter: (d) =>
                                                    intl.DateFormat(
                                                            'd MMM yyyy')
                                                        .format(d),
                                                errorText: _startDateError,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: CustomDropdownCalendar(
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                                label: 'End Date'.tr,
                                                hint: 'Select End Date'.tr,
                                                value: _endDate,
                                                onChanged: (d) => setState(
                                                    () => _endDate = d),
                                                fillColor: AppColors.background,
                                                firstDate: _startDate ??
                                                    widget.policyStartDate,
                                                lastDate: widget.policyEndDate,
                                                dateFormatter: (d) =>
                                                    intl.DateFormat(
                                                            'd MMM yyyy')
                                                        .format(d),
                                                errorText: _endDateError,
                                              ),
                                            ),
                                          ])
                                        : Column(children: [
                                            CustomDropdownCalendar(
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                              label: 'Start Date'.tr,
                                              hint: 'Select Start Date'.tr,
                                              value: _startDate,
                                              onChanged: (d) => setState(
                                                  () => _startDate = d),
                                              fillColor: AppColors.background,
                                              firstDate: widget.policyStartDate,
                                              lastDate: widget.policyEndDate,
                                              errorText: _startDateError,
                                            ),
                                            SizedBox(height: 15.h),
                                            CustomDropdownCalendar(
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                              label: 'End Date'.tr,
                                              hint: 'Select End Date'.tr,
                                              value: _endDate,
                                              onChanged: (d) =>
                                                  setState(() => _endDate = d),
                                              fillColor: AppColors.background,
                                              firstDate: _startDate ??
                                                  widget.policyStartDate,
                                              lastDate: widget.policyEndDate,
                                              errorText: _endDateError,
                                            ),
                                          ]),
                                    SizedBox(height: 15.h),
                                  ],
                                  isTablet
                                      ? Row(children: [
                                          Expanded(
                                            child: CustomDropdown<String>(
                                              label: 'Frequency'.tr,
                                              hint: 'Choose Here'.tr,
                                              items: ControlFrequency.allValues
                                                  .map((d) =>
                                                      DropdownItem<String>(
                                                          value: d, label: d))
                                                  .toList(),
                                              value: _frequency,
                                              onChanged: (v) => setState(
                                                  () => _frequency = v),
                                              fillColor: AppColors.background,
                                              errorText: _submitted &&
                                                      _frequency == null
                                                  ? 'This field is required.'.tr
                                                  : null,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: _textField(
                                              label: 'Control Weight'.tr,
                                              hint: 'Text Here'.tr,
                                              controller: _weightController,
                                              submitted: _submitted,
                                              onlyDigits: true,
                                              customError: _weightError,
                                            ),
                                          ),
                                        ])
                                      : Column(children: [
                                          CustomDropdown<String>(
                                            label: 'Frequency'.tr,
                                            hint: 'Choose Here'.tr,
                                            items: ControlFrequency.allValues
                                                .map((d) =>
                                                    DropdownItem<String>(
                                                        value: d, label: d))
                                                .toList(),
                                            value: _frequency,
                                            onChanged: (v) =>
                                                setState(() => _frequency = v),
                                            fillColor: AppColors.background,
                                            errorText: _submitted &&
                                                    _frequency == null
                                                ? 'This field is required.'.tr
                                                : null,
                                          ),
                                          SizedBox(height: 15.h),
                                          _textField(
                                            label: 'Control Weight'.tr,
                                            hint: 'Text Here'.tr,
                                            controller: _weightController,
                                            submitted: _submitted,
                                            onlyDigits: true,
                                            customError: _weightError,
                                          ),
                                        ]),
                                  SizedBox(height: 15.h),
                                  // Two Expanded columns split the row 50/50
                                  // when Arabic is on; with only the ENG
                                  // column left, an Expanded there would
                                  // stretch it across the whole row instead
                                  // of keeping that same half-width look.
                                  _isArabicEnabled
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _documentColumn(
                                                label: 'Control Document ENG',
                                                document: _documentEn,
                                                onRemove: _onRemoveDocumentEn,
                                                onUpload: _onUploadDocumentEn,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: _documentColumn(
                                                label: 'Control Document AR',
                                                document: _documentAr,
                                                onRemove: _onRemoveDocumentAr,
                                                onUpload: _onUploadDocumentAr,
                                              ),
                                            ),
                                          ],
                                        )
                                      : FractionallySizedBox(
                                          widthFactor: 0.5,
                                          alignment: Alignment.centerLeft,
                                          child: _documentColumn(
                                            label: 'Control Document ENG',
                                            document: _documentEn,
                                            onRemove: _onRemoveDocumentEn,
                                            onUpload: _onUploadDocumentEn,
                                          ),
                                        ),
                                  SizedBox(height: 15.h),
                                  if (_isEdit) _buildDepartmentsSection(),
                                  _buildAssigneesSections(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customButton(
                            title: 'Discard'.tr,
                            function: () => Navigator.of(context).pop(),
                            height: 38.h,
                            width: 150.w,
                            color: AppColors.grey,
                            textColor: AppColors.text,
                            borderColor: AppColors.border,
                          ),
                          Row(
                            children: [
                              if (!_isEdit) ...[
                                customButton(
                                  title: 'Save For Later'.tr,
                                  function: () {
                                    showConfirmDialog(
                                      context: context,
                                      title: 'Save As Draft'.tr,
                                      cancelLabel: 'Cancel'.tr,
                                      confirmLabel: 'Save'.tr,
                                      subtitle:
                                          'Are you sure you want to save this control as a draft?'
                                              .tr,
                                      onConfirm: () => _onSave(cubit,
                                          status: ControlStatus.draft),
                                    );
                                  },
                                  height: 38.h,
                                  width: 150.w,
                                  color: AppColors.grey,
                                  textColor: AppColors.text,
                                  borderColor: AppColors.border,
                                ),
                                SizedBox(width: 10.w),
                              ],
                              customButton(
                                title: _isEdit ? 'Save'.tr : 'Add'.tr,
                                function: () {
                                  if (_isEdit &&
                                      (!_isDepartmentsWeightValid ||
                                          !_isControlDateRangeValid)) {
                                    setState(() {});
                                    return;
                                  }
                                  showConfirmDialog(
                                    context: context,
                                    title: _isEdit
                                        ? 'Editing Control'.tr
                                        : 'Creating Control'.tr,
                                    cancelLabel: 'No'.tr,
                                    confirmLabel: 'Yes'.tr,
                                    subtitle: _isEdit
                                        ? 'Are You Sure You Want To Edit This Control ?'
                                            .tr
                                        : 'Are You Sure You Want To Create This Control ?'
                                            .tr,
                                    onConfirm: () => _onSave(cubit,
                                        status: _resolvedStatus(
                                            ctx, _computedStatus)),
                                  );
                                },
                                height: 38.h,
                                width: 150.w,
                                color: AppColors.primary,
                                textColor: AppColors.textButton,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
