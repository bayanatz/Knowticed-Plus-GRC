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

import 'package:grc_module/core/custom/11_custom_confirm_diaolog.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/grc/control/domain/entities/assigning_control.dart';
import 'package:grc_module/features/grc/control/domain/entities/control_entity.dart';
import 'package:grc_module/features/grc/control/domain/entities/control_status_resolver.dart';
import 'package:grc_module/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:grc_module/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:grc_module/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:grc_module/features/grc/shared/widgets/grc_policy_control_picker_row.dart';
import 'package:grc_module/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:grc_module/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:grc_module/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';

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

  /// Every Champion currently assigned to any {Policy, Control} pair in this
  /// module — used to disable Controls that already have a Champion, since
  /// each Control now allows only one. Fetched once on open, same "snapshot,
  /// no re-fetch" approach the rest of this page uses for Policies/Controls.
  List<ChampionEntity> _existingChampions = [];

  // Resolved once up-front (instead of via BlocProvider's `create:`) so it's
  // available to _loadPolicies() from initState(), before this State's own
  // build() has run and created the BlocProvider below it in the tree.
  late final ChampionCubit _championCubit;

  @override
  void initState() {
    super.initState();
    _championCubit = GetIt.instance<ChampionCubit>();
    _loadPolicies();
    _loadExistingChampions();
  }

  @override
  void dispose() {
    _championCubit.close();
    super.dispose();
  }

  Future<void> _loadPolicies() async {
    final result =
        await _championCubit.getAllPolicies(moduleId: widget.moduleId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _loadingPolicies = false),
      (policies) => setState(() {
        _policies = policies;
        _loadingPolicies = false;
      }),
    );
  }

  Future<void> _loadExistingChampions() async {
    final result =
        await _championCubit.getAllChampionsRaw(moduleId: widget.moduleId);
    if (!mounted) return;
    result.fold(
      (failure) {},
      (champions) => setState(() => _existingChampions = champions),
    );
  }

  /// True if [controlId] under [policyId] already has any Champion assigned
  /// — such a Control is shown but disabled in the picker, since only one
  /// Champion per Control is allowed.
  bool _controlHasChampion(String policyId, String controlId) {
    return _existingChampions.any((c) => c.assigningControls
        .any((a) => a.policyId == policyId && a.controlId == controlId));
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
    final result = await _championCubit.getAllControlsForPolicy(
        moduleId: widget.moduleId, policyId: policyId);
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

    showConfirmDialog(
      context: context,
      title: S.of(context).addControlChampion,
      subtitle: S.of(context).areYouSureYouWantToAddThisControlChampion,
      confirmLabel: S.of(context).add,
      cancelLabel: S.of(context).Cancel,
      onConfirm: () {
        // Fire-and-forget: touches each affected Control document directly,
        // not the Champion doc this page's own submit/loading state tracks.
        _recomputeControlStatuses();
        context.read<ChampionCubit>().createChampion(
              moduleId: widget.moduleId,
              championEmail: _selectedEmployees.first.email,
              // One row (one Policy) can carry several Controls — expand
              // each row into one {Policy, Control} pair per selected
              // Control.
              assigningControls: _rows
                  .expand((r) =>
                      r.controlIds.map((controlId) => AssigningControlEntity(
                            policyId: r.policyId!,
                            controlId: controlId,
                          )))
                  .toList(),
            );
      },
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
        await _championCubit.updateControl(
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
    return BlocProvider.value(
      value: _championCubit,
      child: BlocConsumer<ChampionCubit, ChampionState>(
        listener: (context, state) {
          if (state is ChampionActionSuccess) {
            showSuccessDialog(
              context: context,
              title: S.of(context).controlChampionAdded,
              subtitle: S.of(context).youSuccessfullyAddedThisControlChampion,
            );
            Navigator.pop(context, true);
          } else if (state is ChampionFailure) {
            CustomDialogManager.showMessage(
              context: context,
              lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
              title: S.of(context).unsuccessful,
              subtitle: state.message,
            );
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
                          S.of(context).grc,
                          context.isArabic
                              ? widget.moduleNameAr
                              : widget.moduleNameEn,
                          S.of(context).addingNewControlChampion,
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
          Text(S.of(context).controlChampion, style: StyleText.fontSize16Weight500),
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
                S.of(context).pleaseSelectAControlChampion,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.red),
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
          Text(S.of(context).assigningControl, style: StyleText.fontSize16Weight500),
          SizedBox(height: 12.h),
          for (var i = 0; i < _rows.length; i++) ...[
            GrcPolicyControlPickerRow(
              policies: _policies,
              policiesEnabled: !_loadingPolicies,
              policyId: _rows[i].policyId,
              onPolicyChanged: (v) => _onPolicyChanged(_rows[i], v),
              policyErrorText: _submitted && _rows[i].policyId == null
                  ? S.of(context).required
                  : null,
              availableControls: _rows[i].availableControls,
              controlsEnabled:
                  _rows[i].policyId != null && !_rows[i].isLoadingControls,
              controlIds: _rows[i].controlIds,
              onControlsChanged: (v) => setState(() => _rows[i].controlIds = v),
              controlsErrorText: _submitted && _rows[i].controlIds.isEmpty
                  ? S.of(context).required
                  : null,
              disabledControlIds: _rows[i].policyId == null
                  ? const []
                  : _rows[i]
                      .availableControls
                      .where(
                          (c) => _controlHasChampion(_rows[i].policyId!, c.id))
                      .map((c) => c.id)
                      .toList(),
              spacing: 10.w,
              onRemoveRow: _rows.length > 1 ? () => _removeRow(i) : null,
            ),
            SizedBox(height: 12.h),
          ],
          customButton(
            width: 120.w,
            color: AppColors.black,
            function: _addRow,
            title: '+ ${S.of(context).policy}',
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, bool isSubmitting) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          width: 120.w,
          title: S.of(context).discard,
          function: () => Navigator.pop(context, false),
          color: AppColors.colorGrey,
          textStyle:
              StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
        ),
        customButton(
          width: 120.w,
          title: S.of(context).submit,
          function: isSubmitting ? () {} : () => _submit(context),
          color: AppColors.primary,
          textStyle: StyleText.fontSize16Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }
}
