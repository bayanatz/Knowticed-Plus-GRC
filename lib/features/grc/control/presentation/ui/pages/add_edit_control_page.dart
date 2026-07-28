/// Module: GRC Policy Management
/// Description: Full-page form for creating or editing a single standalone
///              Control under an existing Policy, opened from the Policy
///              Details page's Controls section.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter_bloc, ControlCubit, ControlEntity, ControlStatus, get_it
/// Revision History: 2026-07-15 - Initial creation
///                   2026-07-27 - Split form sections out into
///                                widgets/add_edit_control_widget/
library;

/// ************************* FILE INFO *************************** ///
/// File Name: add_edit_control_page.dart
/// Purpose: Contains AddEditControlPage, the create/edit form for a single
///          Control. Enforces that this control's weight plus every sibling
///          control's weight sums to 100. Owns all form state and
///          save/validation logic; every visual section is delegated to a
///          widget under widgets/add_edit_control_widget/.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 15/7/2026

import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/control/presentation/controller/control_assignee_assignments.dart';
import 'package:demo_app/features/grc/control/presentation/controller/control_department_weight_form.dart';
import 'package:demo_app/features/grc/control/presentation/ui/widgets/add_edit_control_widget/control_action_buttons_widget.dart';
import 'package:demo_app/features/grc/control/presentation/ui/widgets/add_edit_control_widget/control_assignees_section_widget.dart';
import 'package:demo_app/features/grc/control/presentation/ui/widgets/add_edit_control_widget/control_date_row_widget.dart';
import 'package:demo_app/features/grc/control/presentation/ui/widgets/add_edit_control_widget/control_departments_section_widget.dart';
import 'package:demo_app/features/grc/control/presentation/ui/widgets/add_edit_control_widget/control_documents_row_widget.dart';
import 'package:demo_app/features/grc/control/presentation/ui/widgets/add_edit_control_widget/control_frequency_weight_row_widget.dart';
import 'package:demo_app/features/grc/control/presentation/ui/widgets/add_edit_control_widget/control_info_form_widget.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/control/presentation/controller/control_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';

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

  /// True once the user has attempted to Save at least once — gates the
  /// "Please select a Control Owner" error so it never appears just from
  /// picking a Champion, only once a save was actually attempted while that
  /// Champion has no Owner.
  bool _assigneesSaveAttempted = false;

  final _assignees = ControlAssigneeAssignments();
  final _departmentsForm = ControlDepartmentWeightForm();

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
    _departmentsForm.prefillFromExisting(
      departments: existing.departments,
      equalWeights: existing.equalWeights,
      totalDepartmentsCount:
          Get.find<MainCoreDepartmentController>().departmentIds.length,
    );
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
    _departmentsForm.dispose();
    super.dispose();
  }

  double get _siblingsWeight => widget.siblingControls
      .where((c) => c.id != widget.existingControl?.id)
      .fold<double>(0, (sum, c) => sum + c.controlsWeight);

  double get _thisWeight => double.tryParse(_weightController.text.trim()) ?? 0;

  /// The currently selected Champion/Owner emails — live selection if
  /// touched, otherwise whoever is already assigned. Each is hidden from the
  /// *other* picker (see ControlAssigneesSectionWidget) so the same person
  /// can never be picked as both this Control's Champion and its Owner.
  List<String> get _currentChampionEmails => _assignees.resolvedChampionEmails(
        context: context,
        isEdit: _isEdit,
        policyId: widget.policyId,
        controlId: widget.existingControl?.id ?? '',
      );
  List<String> get _currentOwnerEmails => _assignees.resolvedOwnerEmails(
        context: context,
        isEdit: _isEdit,
        policyId: widget.policyId,
        controlId: widget.existingControl?.id ?? '',
      );

  /// True once a Save was attempted while a Control Champion is assigned but
  /// no Control Owner is — an Owner is required whenever a Champion is
  /// assigned, while an Owner alone (no Champion) is valid. Recomputed live
  /// so fixing the selection clears the error without needing another Save
  /// press.
  bool get _ownerRequiredForChampion =>
      _assigneesSaveAttempted &&
      _isEdit &&
      _assignees.isChampionWithoutOwner(
        context: context,
        isEdit: _isEdit,
        policyId: widget.policyId,
        controlId: widget.existingControl?.id ?? '',
      );

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
            (_departmentsForm.realSelectedDepartments.isNotEmpty &&
                (_departmentsForm.equalWeights ||
                    _departmentsForm.totalDepartmentsWeight == 100)));
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

  void _onSave(ControlCubit cubit, {required ControlStatus status}) {
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
        departments: _departmentsForm.departmentsForSave,
        departmentsWeights: _departmentsForm.departmentWeightsForSave,
        equalWeights: _departmentsForm.equalWeights,
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

  Future<void> _onStateChange(BuildContext context, ControlState state) async {
    if (state is ControlLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is ControlActionSuccess) {
      if (_isEdit) {
        final hadFailure = await _assignees.applyAssigneeChanges(
          context: context,
          moduleId: widget.moduleId,
          policyId: widget.policyId,
          controlId: widget.existingControl!.id,
        );
        if (hadFailure && context.mounted) {
          await showErrorDialog(
            context: context,
            subtitle: "Some champion/owner assignments couldn't be saved.".tr,
          );
        }
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

    if (state is ControlFailure) {
      showErrorDialog(context: context, subtitle: state.message);
    }
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

  Widget _buildAppBar() {
    return PaginationAppBar(
      screensTitles: [
        'GRC'.tr,
        context.isArabic
            ? widget.policy.policyNameAr
            : widget.policy.policyNameEn,
        context.isArabic
            ? "Edit ${widget.existingControl?.controlsNameAr}"
            : "Edit ${widget.existingControl?.controlsNameEn}",
      ],
    );
  }

  /// The "Status" switch row. Only an already-saved Control has a real status
  /// to manually deactivate — Create mode's status isn't decided until
  /// Add/Save For Later is pressed — so this is rendered only in Edit mode.
  Widget _buildStatusRow() {
    return Row(
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
          inactiveColor: Colors.grey.withValues(alpha: 0.16),
          value: !_manualInactive,
          onToggle: (v) => setState(() => _manualInactive = !v),
        ),
      ],
    );
  }

  /// The scrollable form card: every field, wrapped in the rounded container
  /// that fills the space between the app bar and the action buttons.
  Widget _buildFormCard(bool isTablet) {
    final availableDepartmentNames =
        _isEdit ? _availableDepartmentNames(context) : const <String>[];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ControlInfoFormWidget(
                isTablet: isTablet,
                isArabicEnabled: _isArabicEnabled,
                submitted: _submitted,
                arabicTouched: _arabicTouched,
                nameController: _nameController,
                nameArController: _nameArController,
                numberController: _numberController,
                numberArController: _numberArController,
                descriptionController: _descriptionController,
                descriptionArController: _descriptionArController,
              ),
              SizedBox(height: 15.h),
              if (_isEdit) ...[
                ControlDateRowWidget(
                  isTablet: isTablet,
                  startDate: _startDate,
                  endDate: _endDate,
                  onStartDateChanged: (d) => setState(() => _startDate = d),
                  onEndDateChanged: (d) => setState(() => _endDate = d),
                  firstDate: widget.policyStartDate,
                  lastDate: widget.policyEndDate,
                  startDateError: _startDateError,
                  endDateError: _endDateError,
                ),
                SizedBox(height: 15.h),
              ],
              ControlFrequencyWeightRowWidget(
                isTablet: isTablet,
                submitted: _submitted,
                frequency: _frequency,
                onFrequencyChanged: (v) => setState(() => _frequency = v),
                weightController: _weightController,
              ),
              SizedBox(height: 15.h),
              ControlDocumentsRowWidget(
                isArabicEnabled: _isArabicEnabled,
                documentEn: _documentEn,
                documentAr: _documentAr,
                onUploadDocumentEn: _onUploadDocumentEn,
                onUploadDocumentAr: _onUploadDocumentAr,
                onRemoveDocumentEn: _onRemoveDocumentEn,
                onRemoveDocumentAr: _onRemoveDocumentAr,
              ),
              SizedBox(height: 15.h),
              if (_isEdit)
                ControlDepartmentsSectionWidget(
                  allDepartmentsValue:
                      ControlDepartmentWeightForm.allDepartmentsValue,
                  availableDepartmentNames: availableDepartmentNames,
                  selectedDepartments: _departmentsForm.selectedDepartments,
                  realSelectedDepartments:
                      _departmentsForm.realSelectedDepartments,
                  isAllDepartmentsSelected:
                      _departmentsForm.isAllDepartmentsSelected,
                  equalWeights: _departmentsForm.equalWeights,
                  departmentWeightControllers:
                      _departmentsForm.departmentWeightControllers,
                  totalDepartmentsWeight:
                      _departmentsForm.totalDepartmentsWeight,
                  isDepartmentsWeightValid:
                      _departmentsForm.isDepartmentsWeightValid,
                  submitted: _submitted,
                  onDepartmentsChanged: (newSelection) => setState(() =>
                      _departmentsForm.onDepartmentsChanged(
                          newSelection, availableDepartmentNames)),
                  onEqualWeightsChanged: (v) =>
                      setState(() => _departmentsForm.onEqualWeightsChanged(v)),
                  onRemoveDepartment: (d) =>
                      setState(() => _departmentsForm.onRemoveDepartment(d)),
                ),
              if (_isEdit)
                ControlAssigneesSectionWidget(
                  policyId: widget.policyId,
                  controlId: widget.existingControl!.id,
                  realSelectedDepartments:
                      _departmentsForm.realSelectedDepartments,
                  onChampionsChanged: (selected) => setState(() =>
                      _assignees.currentChampionEmails =
                          selected.map((o) => o.email).toList()),
                  onOwnersChanged: (selected) => setState(() =>
                      _assignees.currentOwnerEmails =
                          selected.map((o) => o.email).toList()),
                  ownerErrorText: _ownerRequiredForChampion
                      ? 'Please select a Control Owner'.tr
                      : null,
                  selectedChampionEmails: _currentChampionEmails,
                  selectedOwnerEmails: _currentOwnerEmails,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// The bottom action bar: Discard on the left, and (Save For Later +)
  /// Add/Save on the right. [ctx] is the Builder context that carries the
  /// Champion/Owner cubits; [cubit] is the already-read ControlCubit.
  Widget _buildActionButtons(ControlCubit cubit, BuildContext ctx) {
    return ControlActionButtonsWidget(
      isEdit: _isEdit,
      onDiscard: () => Navigator.of(context).pop(),
      onSaveDraft: _isEdit
          ? null
          : () {
              showConfirmDialog(
                context: context,
                title: 'Save As Draft'.tr,
                cancelLabel: 'Cancel'.tr,
                confirmLabel: 'Save'.tr,
                subtitle:
                    'Are you sure you want to save this control as a draft?'.tr,
                onConfirm: () => _onSave(cubit, status: ControlStatus.draft),
              );
            },
      onSave: () {
        setState(() => _assigneesSaveAttempted = true);
        if (_isEdit &&
            (!_departmentsForm.isDepartmentsWeightValid ||
                !_isControlDateRangeValid ||
                _ownerRequiredForChampion)) {
          return;
        }
        showConfirmDialog(
          context: context,
          title: _isEdit ? 'Editing Control'.tr : 'Creating Control'.tr,
          cancelLabel: 'No'.tr,
          confirmLabel: 'Yes'.tr,
          subtitle: _isEdit
              ? 'Are You Sure You Want To Edit This Control ?'.tr
              : 'Are You Sure You Want To Create This Control ?'.tr,
          onConfirm: () => _onSave(
            cubit,
            status: ControlStatus.resolve(
              requested: ControlStatus.computeDateBased(_effectiveStartDate),
              manualInactive: _manualInactive,
              hasAnyAssignee: _assignees.hasAnyAssignee(
                context: ctx,
                isEdit: _isEdit,
                policyId: widget.policyId,
                controlId: widget.existingControl?.id ?? '',
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    // Control/Champion/Owner cubits are provided by whichever page pushed
    // this route (ControlDetailsPage reuses its own instances via
    // BlocProvider.value; flow-start entry points such as "Add Control"
    // create fresh ones) — this page only ever reads them.
    return Builder(
      builder: (ctx) {
        final cubit = ctx.read<ControlCubit>();
        return BlocListener<ControlCubit, ControlState>(
          listener: _onStateChange,
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(),
                    if (_isEdit) _buildStatusRow(),
                    SizedBox(height: 12.h),
                    Expanded(child: _buildFormCard(isTablet)),
                    SizedBox(height: 16.h),
                    _buildActionButtons(cubit, ctx),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
