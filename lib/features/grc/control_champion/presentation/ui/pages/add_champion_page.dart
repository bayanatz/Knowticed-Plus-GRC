// lib/features/grc/control_champion/presentation/ui/pages/add_champion_page.dart
/// Module: Control Champion Management
/// Description: Single-page form for adding a new Control Champion — pick
///              exactly one employee, then assign one or more {Policy,
///              Control} pairs to them.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: ChampionCubit, GrcOwnerSection, GetAllPoliciesUseCase,
///               GetAllControlsUseCase, PolicyEntity, ControlEntity
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status_resolver.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_policy_control_picker_row.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

class _AssigningControlRow {
  String? policyId;
  List<String> controlIds;
  List<ControlEntity> availableControls;
  bool isLoadingControls;

  _AssigningControlRow({
    this.policyId,
    List<String>? controlIds,
    List<ControlEntity>? availableControls,
    this.isLoadingControls = false,
  })  : controlIds = controlIds ?? [],
        availableControls = availableControls ?? [];
}

class AddChampionPage extends StatefulWidget {
  final String moduleId;
  final String moduleNameEn;
  final String moduleNameAr;

  const AddChampionPage({
    super.key,
    required this.moduleId,
    required this.moduleNameEn,
    required this.moduleNameAr,
  });

  @override
  State<AddChampionPage> createState() => _AddChampionPageState();
}

class _AddChampionPageState extends State<AddChampionPage> {
  final List<_AssigningControlRow> _rows = [_AssigningControlRow()];
  List<OwnerData> _selectedEmployees = [];
  List<PolicyEntity> _policies = [];
  bool _loadingPolicies = true;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  Future<void> _loadPolicies() async {
    final result = await GetIt.instance<GetAllPoliciesUseCase>()
        .call(moduleId: widget.moduleId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _loadingPolicies = false),
      (policies) => setState(() {
        _policies = policies;
        _loadingPolicies = false;
      }),
    );
  }

  Future<void> _onPolicyChanged(
      _AssigningControlRow row, String? policyId) async {
    if (policyId == null) {
      setState(() {
        row.policyId = null;
        row.controlIds = [];
        row.availableControls = [];
      });
      return;
    }
    setState(() {
      row.policyId = policyId;
      row.controlIds = [];
      row.availableControls = [];
      row.isLoadingControls = true;
    });
    final result = await GetIt.instance<GetAllControlsUseCase>()
        .call(moduleId: widget.moduleId, policyId: policyId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => row.isLoadingControls = false),
      (controls) => setState(() {
        row.availableControls = controls;
        row.isLoadingControls = false;
      }),
    );
  }

  void _addRow() => setState(() => _rows.add(_AssigningControlRow()));

  void _removeRow(int index) => setState(() => _rows.removeAt(index));

  bool get _rowsValid =>
      _rows.every((r) => r.policyId != null && r.controlIds.isNotEmpty);

  void _submit(BuildContext context) {
    setState(() => _submitted = true);
    if (_selectedEmployees.length != 1 || !_rowsValid) return;

    // Fire-and-forget: touches each affected Control document directly, not
    // the Champion doc this page's own submit/loading state tracks.
    _recomputeControlStatuses();
    context.read<ChampionCubit>().createChampion(
          moduleId: widget.moduleId,
          championEmail: _selectedEmployees.first.email,
          // One row (one Policy) can carry several Controls — expand each
          // row into one {Policy, Control} pair per selected Control.
          assigningControls: _rows
              .expand((r) => r.controlIds.map((controlId) =>
                  AssigningControlEntity(
                    policyId: r.policyId!,
                    controlId: controlId,
                  )))
              .toList(),
        );
  }

  ControlEntity? _findControl(_AssigningControlRow row, String controlId) {
    for (final c in row.availableControls) {
      if (c.id == controlId) return c;
    }
    return null;
  }

  /// function name: [_recomputeControlStatuses]
  ///
  /// purpose: every control just selected here has gained this brand-new
  ///          Champion as an assignee — flip any of them still sitting on
  ///          Unassigned to Scheduled/Active. Controls that are Draft/
  ///          Inactive/Expired, or already Scheduled/Active, are left
  ///          untouched (see [shouldRecomputeAssigneeBasedStatus]).
  Future<void> _recomputeControlStatuses() async {
    final editor = currentGrcUserEmail();
    final updateUseCase = GetIt.instance<UpdateControlUseCase>();
    for (final row in _rows) {
      for (final controlId in row.controlIds) {
        final control = _findControl(row, controlId);
        if (control == null) continue;
        if (!shouldRecomputeAssigneeBasedStatus(control.status)) continue;
        final newStatus = computeAssigneeBasedControlStatus(
          effectiveStartDate: control.startDate,
          hasAnyAssignee: true,
        );
        if (newStatus == control.status) continue;
        await updateUseCase.call(
          UpdateControlParams(
            id: control.id,
            moduleId: widget.moduleId,
            policyId: row.policyId!,
            editorId: editor,
            status: newStatus,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ChampionCubit>(),
      child: BlocConsumer<ChampionCubit, ChampionState>(
        listener: (context, state) {
          if (state is ChampionActionSuccess) {
            Navigator.pop(context, true);
          } else if (state is ChampionFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isSubmitting = state is ChampionLoading;
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaginationAppBar(
                        screensTitles: [
                          'GRC'.tr,
                          context.isArabic ? widget.moduleNameAr : widget.moduleNameEn,
                          'Adding New Control Champion'.tr,
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildEmployeeSection(),
                      SizedBox(height: 24.h),
                      _buildAssigningControlSection(context),
                      SizedBox(height: 24.h),
                      _buildButtons(context, isSubmitting),
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

  Widget _buildEmployeeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Control Champion'.tr, style: StyleText.fontSize16Weight500),
          SizedBox(height: 8.h),
          GrcOwnerSection(
            singleSelect: true,
            onOwnersChanged: (selected) =>
                setState(() => _selectedEmployees = selected),
          ),
          if (_submitted && _selectedEmployees.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'Please select a Control Champion'.tr,
                style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssigningControlSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assigning Control'.tr, style: StyleText.fontSize16Weight500),
          SizedBox(height: 12.h),
          for (var i = 0; i < _rows.length; i++) ...[
            GrcPolicyControlPickerRow(
              policies: _policies,
              policiesEnabled: !_loadingPolicies,
              policyId: _rows[i].policyId,
              onPolicyChanged: (v) => _onPolicyChanged(_rows[i], v),
              policyErrorText: _submitted && _rows[i].policyId == null
                  ? 'Required'.tr
                  : null,
              availableControls: _rows[i].availableControls,
              controlsEnabled:
                  _rows[i].policyId != null && !_rows[i].isLoadingControls,
              controlIds: _rows[i].controlIds,
              onControlsChanged: (v) =>
                  setState(() => _rows[i].controlIds = v),
              controlsErrorText: _submitted && _rows[i].controlIds.isEmpty
                  ? 'Required'.tr
                  : null,
              spacing: 10.w,
              onRemoveRow: _rows.length > 1 ? () => _removeRow(i) : null,
            ),
            SizedBox(height: 12.h),
          ],
          TextButton(
            onPressed: _addRow,
            child: Text('+ Policy'.tr, style: StyleText.fontSize14Weight500),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, bool isSubmitting) {
    return Row(
      children: [
        Expanded(
          child: customButton(
            title: 'Discard'.tr,
            function: () => Navigator.pop(context, false),
            color: AppColors.colorGrey,
            textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: customButton(
            title: 'Submit'.tr,
            function: isSubmitting ? () {} : () => _submit(context),
            color: AppColors.primary,
            textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
          ),
        ),
      ],
    );
  }
}
