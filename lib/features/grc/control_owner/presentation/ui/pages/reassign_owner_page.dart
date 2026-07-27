import 'dart:async';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/constants/app_assets.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/21-custom_contact_card.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/create_grc_request_usecase.dart';
import 'package:demo_app/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/grc/shared/models/pending_assignment_row.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_assignment_chip.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_policy_control_picker_row.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class ReassignOwnerPage extends StatefulWidget {
  final OwnerEntity owner;
  final GRCModuleEntity module;
  final List<PolicyEntity> allPolicies;
  final Map<String, List<ControlEntity>> policyControls;

  const ReassignOwnerPage({
    super.key,
    required this.owner,
    required this.module,
    required this.allPolicies,
    required this.policyControls,
  });

  @override
  State<ReassignOwnerPage> createState() => _ReassignOwnerPageState();
}

class _ReassignOwnerPageState extends State<ReassignOwnerPage> {
  List<OwnerData> _newSelectedEmployees = [];
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _noteController = TextEditingController();

  // Controls being reassigned (transferred to the new owner)
  List<AssigningControlEntity> _reassignedControls = [];

  // Each row is its own independent Policy + Controls picker. Selections
  // made here are staging only — they aren't added to _reassignedControls
  // (and so don't appear as chips under "Assigned Controls") until Submit.
  final List<PendingAssignmentRow> _pendingRows = [PendingAssignmentRow()];
  bool _submitting = false;

  String? _ownerError;
  String? _controlsError;
  String? _startDateError;

  @override
  void initState() {
    super.initState();
    _reassignedControls = List.from(widget.owner.assigningControls);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addPolicyRow() {
    setState(() {
      _pendingRows.add(PendingAssignmentRow());
    });
  }

  void _removeControl(int index) {
    setState(() {
      _reassignedControls.removeAt(index);
    });
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      commitPendingAssignmentRows(
          pendingRows: _pendingRows, target: _reassignedControls);
      _pendingRows
        ..clear()
        ..add(PendingAssignmentRow());
    });

    final newOwnerEmail = _newSelectedEmployees.isNotEmpty
        ? _newSelectedEmployees.first.email
        : null;

    final ownerError = _newSelectedEmployees.isEmpty
        ? 'Please select a new Control Owner'.tr
        : newOwnerEmail == widget.owner.ownerEmail
            ? 'New owner cannot be the current owner'.tr
            : null;
    final controlsError = _reassignedControls.isEmpty
        ? 'Please assign at least one Control'.tr
        : null;
    final startDateError =
        _startDate == null ? 'Please choose a start date'.tr : null;

    setState(() {
      _ownerError = ownerError;
      _controlsError = controlsError;
      _startDateError = startDateError;
    });

    if (ownerError != null || controlsError != null || startDateError != null) {
      return;
    }

    final confirmed = await _confirmReassign(context);
    if (!confirmed) return;
    if (!context.mounted) return;

    setState(() => _submitting = true);

    final requestCubit = context.read<GrcRequestCubit>();
    await requestCubit.createRequest(
      CreateGrcRequestParams(
        type: GrcRequestType.reassignOwner,
        moduleId: widget.module.moduleId,
        requestedBy: currentGrcUserEmail(),
        note: _noteController.text,
        currentOwnerEmail: widget.owner.ownerEmail,
        newOwnerEmail: newOwnerEmail!,
        controls: _reassignedControls,
        startDate: _startDate!,
        endDate: _endDate,
      ),
    );

    if (mounted) {
      setState(() => _submitting = false);
    }
    if (!context.mounted) return;

    final state = requestCubit.state;
    if (state is GrcRequestActionSuccess) {
      showSuccessDialog(
        context: context,
        title: 'Request Submitted'.tr,
        subtitle: 'Your reassign owner request has been submitted.'.tr,
      );
      Navigator.pop(context, true);
    } else if (state is GrcRequestFailure) {
      showErrorDialog(
        context: context,
        subtitle: 'Failed to submit request: ${state.message}',
      );
    }
  }

  Future<bool> _confirmReassign(BuildContext context) async {
    final completer = Completer<bool>();
    await showConfirmDialog(
      context: context,
      title: 'Reassign Owner'.tr,
      subtitle: 'Are you sure you want to submit this reassignment request?'.tr,
      confirmLabel: 'Submit'.tr,
      cancelLabel: 'Cancel'.tr,
      onConfirm: () => completer.complete(true),
      onCancel: () => completer.complete(false),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcRequestCubit>(
      create: (_) => GetIt.instance<GrcRequestCubit>(),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [
                  context.isArabic
                      ? widget.module.moduleNameAr
                      : widget.module.moduleNameEn,
                  'Reassign Control Owner Request'.tr,
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Current Control Owner Section
                            ..._buildCurrentOwnerSection(context),
                            SizedBox(height: 20.h),

                            // New Control Owner Section
                            ..._buildNewOwnerSection(),
                            SizedBox(height: 20.h),

                            // Dates Pickers + Request Note Sections
                            ..._buildDatesAndNoteSection(),
                            SizedBox(height: 20.h),

                            // Assigned Controls List Section
                            ..._buildAssignedControlsSection(context),
                            SizedBox(height: 20.h),

                            // Assigning Controls Form Section — one Policy +
                            // Controls picker row per pending assignment. Tapping
                            // "+ Policy" appends another independent row; nothing
                            // here touches "Assigned Controls" until Submit.
                            ..._buildAssigningControlsFormSection(),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Action Buttons
                      _buildActionButtonsRow(context),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Current Control Owner" heading + read-only profile card.
  List<Widget> _buildCurrentOwnerSection(BuildContext context) {
    final currentEmp = findEmployeeByEmail(widget.owner.ownerEmail);
    final currentPhoto = currentEmp != null
        ? EmployeeHelper.getEmployeeImage(employee: currentEmp)
        : AppAssets.defaultEmployeeAvatar;
    final currentName = employeeDisplayName(context, widget.owner.ownerEmail);
    final currentDept = currentEmp != null
        ? EmployeeHelper.getEmployeeLocalizeDepartment(
            employee: currentEmp, context: context)
        : '';
    final currentTitle = currentEmp != null
        ? (EmployeeHelper.getEmployeeLocalizedTitle(
                    employee: currentEmp, context: context)
                ?.toString() ??
            '')
        : '';
    final currentPhone = currentEmp?.mobilePhone?.phone ?? grcMockPhoneFallback;

    return [
      Text('Current Control Owner'.tr,
          style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
      SizedBox(height: 8.h),
      ContactCard(
        name: currentName,
        jobTitle:
            currentTitle.isNotEmpty ? currentTitle : grcMockJobTitleFallback.tr,
        department:
            currentDept.isNotEmpty ? currentDept : grcMockDepartmentFallback.tr,
        email: widget.owner.ownerEmail,
        phone: currentPhone,
        avatar:
            currentPhoto.startsWith('http') ? NetworkImage(currentPhoto) : null,
        onMessage: () {},
      ),
    ];
  }

  /// "New Control Owner" heading + owner picker.
  List<Widget> _buildNewOwnerSection() {
    return [
      Text('New Control Owner'.tr,
          style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
      SizedBox(height: 8.h),
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: GrcOwnerSection(
          singleSelect: true,
          errorText: _ownerError,
          onOwnersChanged: (selected) => setState(() {
            _newSelectedEmployees = selected;
            _ownerError = null;
          }),
        ),
      ),
    ];
  }

  /// Start/End date pickers row + the request note text field.
  List<Widget> _buildDatesAndNoteSection() {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomDropdownCalendar(
              label: 'Start Date'.tr,
              hint: 'Choose The Date'.tr,
              value: _startDate,
              errorText: _startDateError,
              onChanged: (d) => setState(() {
                _startDate = d;
                _startDateError = null;
              }),
              fillColor: AppColors.background,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              dateFormatter: (d) =>
                  DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en')
                      .format(d),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomDropdownCalendar(
              label: 'End Date'.tr,
              hint: 'Choose The Date'.tr,
              value: _endDate,
              onChanged: (d) => setState(() => _endDate = d),
              fillColor: AppColors.background,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              dateFormatter: (d) =>
                  DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en')
                      .format(d),
            ),
          ),
        ],
      ),
      SizedBox(height: 20.h),
      CustomTextField(
        label: 'Request Note'.tr,
        hint: 'Text here'.tr,
        controller: _noteController,
        maxLines: 4,
        maxLength: 500,
        fillColor: AppColors.background,
        onChanged: (v) => setState(() {}),
      ),
    ];
  }

  /// "Assigned Controls" heading + chip list (or empty-state text) + error.
  List<Widget> _buildAssignedControlsSection(BuildContext context) {
    return [
      Text('Assigned Controls'.tr,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
      SizedBox(height: 8.h),
      _reassignedControls.isEmpty
          ? Text(
              'No Controls assigned.'.tr,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText),
            )
          : Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List.generate(_reassignedControls.length, (index) {
                final ac = _reassignedControls[index];
                final ctrl = findControlInPolicy(
                    widget.policyControls, ac.policyId, ac.controlId);
                final cName = ctrl != null
                    ? (context.isArabic
                        ? ctrl.controlsNameAr
                        : ctrl.controlsNameEn)
                    : ac.controlId;
                return GrcAssignmentChip(
                  label: cName,
                  onRemove: () => _removeControl(index),
                );
              }),
            ),
      if (_controlsError != null) ...[
        SizedBox(height: 6.h),
        Text(
          _controlsError!,
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
        ),
      ],
    ];
  }

  /// "Assigning Controls" heading + one picker row per pending assignment
  /// + the "+ Policy" button that appends another row.
  List<Widget> _buildAssigningControlsFormSection() {
    return [
      Text('Assigning Controls'.tr,
          style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
      SizedBox(height: 12.h),
      ...List.generate(_pendingRows.length, (i) {
        final row = _pendingRows[i];
        final availableControlsForPolicy = row.policyId != null
            ? (widget.policyControls[row.policyId] ?? [])
            : <ControlEntity>[];

        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: GrcPolicyControlPickerRow(
            policies: widget.allPolicies,
            policyId: row.policyId,
            onPolicyChanged: (v) {
              setState(() {
                row.policyId = v;
                row.controlIds = [];
              });
            },
            availableControls: availableControlsForPolicy,
            controlsEnabled: row.policyId != null,
            controlIds: row.controlIds,
            onControlsChanged: (v) => setState(() => row.controlIds = v),
            spacing: 16.w,
          ),
        );
      }),
      customButton(
        title: '+ Policy'.tr,
        function: _addPolicyRow,
        width: 120.w,
        color: AppColors.blackButton,
        textStyle: StyleText.fontSize14Weight500.copyWith(color: Colors.white),
      ),
    ];
  }

  /// Discard / Submit action row at the bottom of the page.
  Widget _buildActionButtonsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          width: 120.w,
          title: 'Discard'.tr,
          function: () => Navigator.pop(context, false),
          color: AppColors.colorGrey,
          textStyle:
              StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
        ),
        _submitting
            ? Container(
                height: 34.h,
                width: 120.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Submitting...'.tr,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: Colors.black),
                ),
              )
            : customButton(
                width: 120.w,
                title: _submitting ? 'Submitting...'.tr : 'Submit'.tr,
                function: _submitting ? () {} : () => _submit(context),
                color: AppColors.primary,
                textStyle:
                    StyleText.fontSize16Weight500.copyWith(color: Colors.black),
              ),
      ],
    );
  }
}
