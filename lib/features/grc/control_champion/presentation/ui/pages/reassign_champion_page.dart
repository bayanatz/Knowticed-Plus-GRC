import 'dart:async';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/21-custom_contact_card.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
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

class ReassignChampionPage extends StatefulWidget {
  final ChampionEntity champion;
  final GRCModuleEntity module;
  final List<PolicyEntity> allPolicies;
  final Map<String, List<ControlEntity>> policyControls;

  const ReassignChampionPage({
    super.key,
    required this.champion,
    required this.module,
    required this.allPolicies,
    required this.policyControls,
  });

  @override
  State<ReassignChampionPage> createState() => _ReassignChampionPageState();
}

class _ReassignChampionPageState extends State<ReassignChampionPage> {
  List<OwnerData> _newSelectedEmployees = [];
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _noteController = TextEditingController();

  // Controls being reassigned (transferred to the new champion)
  List<AssigningControlEntity> _reassignedControls = [];

  // Each row is its own independent Policy + Controls picker. Selections
  // made here are staging only — they aren't added to _reassignedControls
  // (and so don't appear as chips under "Assigned Controls") until Submit.
  final List<PendingAssignmentRow> _pendingRows = [PendingAssignmentRow()];
  bool _submitting = false;

  String? _championError;
  String? _controlsError;
  String? _startDateError;

  @override
  void initState() {
    super.initState();
    _reassignedControls = List.from(widget.champion.assigningControls);
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

  Future<bool> _confirmReassign(BuildContext context) async {
    final completer = Completer<bool>();
    await showConfirmDialog(
      context: context,
      title: 'Reassign Champion'.tr,
      subtitle: 'Are you sure you want to submit this reassignment request?'.tr,
      confirmLabel: 'Submit'.tr,
      cancelLabel: 'Cancel'.tr,
      onConfirm: () => completer.complete(true),
      onCancel: () => completer.complete(false),
    );
    return completer.future;
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      commitPendingAssignmentRows(
          pendingRows: _pendingRows, target: _reassignedControls);
      _pendingRows
        ..clear()
        ..add(PendingAssignmentRow());
    });

    final newChampionEmail = _newSelectedEmployees.isNotEmpty
        ? _newSelectedEmployees.first.email
        : null;

    final championError = _newSelectedEmployees.isEmpty
        ? 'Please select a new Control Champion'.tr
        : newChampionEmail == widget.champion.championEmail
            ? 'New champion cannot be the current champion'.tr
            : null;
    final controlsError = _reassignedControls.isEmpty
        ? 'Please assign at least one Control'.tr
        : null;
    final startDateError =
        _startDate == null ? 'Please choose a start date'.tr : null;

    setState(() {
      _championError = championError;
      _controlsError = controlsError;
      _startDateError = startDateError;
    });

    if (championError != null ||
        controlsError != null ||
        startDateError != null) {
      return;
    }

    final confirmed = await _confirmReassign(context);
    if (!confirmed) return;
    if (!context.mounted) return;

    setState(() => _submitting = true);

    final requestCubit = context.read<GrcRequestCubit>();
    await requestCubit.createRequest(
      CreateGrcRequestParams(
        moduleId: widget.module.moduleId,
        requestedBy: currentGrcUserEmail(),
        note: _noteController.text,
        currentChampionEmail: widget.champion.championEmail,
        newChampionEmail: newChampionEmail!,
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
        subtitle: 'Your reassign champion request has been submitted.'.tr,
      );
      Navigator.pop(context, true);
    } else if (state is GrcRequestFailure) {
      showErrorDialog(
        context: context,
        subtitle: 'Failed to submit request: ${state.message}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcRequestCubit>(
      create: (_) => GetIt.instance<GrcRequestCubit>(),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    final currentEmp = findEmployeeByEmail(widget.champion.championEmail);
    final currentPhoto = currentEmp.displayPhoto;
    final currentName =
        employeeDisplayName(context, widget.champion.championEmail);
    final currentDept = currentEmp.localizedDepartment(context);
    final currentTitle = currentEmp.localizedJobTitle(context);
    final currentPhone = currentEmp.displayPhone;

    final dateFormat = DateFormat('yyyy-MM-dd');

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
                  'Reassign Control Champion Request'.tr,
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _buildFormCard(
                        context,
                        currentName: currentName,
                        currentTitle: currentTitle,
                        currentDept: currentDept,
                        currentPhone: currentPhone,
                        currentPhoto: currentPhoto,
                        dateFormat: dateFormat,
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

  Widget _buildFormCard(
    BuildContext context, {
    required String currentName,
    required String currentTitle,
    required String currentDept,
    required String currentPhone,
    required String currentPhoto,
    required DateFormat dateFormat,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Control Champion Section
          ..._buildCurrentChampionSection(
            currentName: currentName,
            currentTitle: currentTitle,
            currentDept: currentDept,
            currentPhone: currentPhone,
            currentPhoto: currentPhoto,
          ),
          SizedBox(height: 20.h),

          // New Control Champion Section
          ..._buildNewChampionSection(),
          SizedBox(height: 20.h),

          // Dates Pickers Section
          _buildDatesSection(dateFormat),
          SizedBox(height: 20.h),

          // Request Note Section
          _buildNoteSection(),
          SizedBox(height: 20.h),

          // Assigned Controls List Section
          ..._buildAssignedControlsSection(context),
          SizedBox(height: 20.h),

          // Assigning Controls Form Section — one Policy +
          // Controls picker row per pending assignment. Tapping
          // "+ Policy" appends another independent row; nothing
          // here touches "Assigned Controls" until Submit.
          ..._buildAssigningControlsSection(),
        ],
      ),
    );
  }

  List<Widget> _buildCurrentChampionSection({
    required String currentName,
    required String currentTitle,
    required String currentDept,
    required String currentPhone,
    required String currentPhoto,
  }) {
    return [
      Text('Current Control Champion'.tr,
          style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
      SizedBox(height: 8.h),
      ContactCard(
        name: currentName,
        jobTitle: currentTitle.isNotEmpty ? currentTitle : grcMockJobTitleFallback.tr,
        department: currentDept.isNotEmpty ? currentDept : grcMockDepartmentFallback.tr,
        email: widget.champion.championEmail,
        phone: currentPhone,
        avatar:
            currentPhoto.startsWith('http') ? NetworkImage(currentPhoto) : null,
        onMessage: () {},
      ),
    ];
  }

  List<Widget> _buildNewChampionSection() {
    return [
      Text('New Control Champion'.tr,
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
          errorText: _championError,
          onOwnersChanged: (selected) => setState(() {
            _newSelectedEmployees = selected;
            _championError = null;
          }),
        ),
      ),
    ];
  }

  Widget _buildDatesSection(DateFormat dateFormat) {
    return Row(
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
            dateFormatter: dateFormat.format,
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
            dateFormatter: dateFormat.format,
          ),
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return CustomTextField(
      label: 'Request Note'.tr,
      hint: 'Text here'.tr,
      controller: _noteController,
      maxLines: 4,
      maxLength: 500,
      fillColor: AppColors.background,
      onChanged: (v) => setState(() {}),
    );
  }

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

  List<Widget> _buildAssigningControlsSection() {
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
        textStyle:
            StyleText.fontSize14Weight500.copyWith(color: Colors.white),
      ),
    ];
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: 'Discard'.tr,
          width: 120.w,
          function: () => Navigator.pop(context, false),
          color: AppColors.colorGrey,
          textStyle:
              StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
        ),
        _submitting
            ? Container(
                width: 120.w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  height: 18.h,
                  width: 18.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              )
            : customButton(
                width: 120.w,
                title: 'Submit'.tr,
                function: () => _submit(context),
                color: AppColors.primary,
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: Colors.black),
              ),
      ],
    );
  }
}
