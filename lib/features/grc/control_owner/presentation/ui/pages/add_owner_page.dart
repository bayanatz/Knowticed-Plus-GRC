// lib/features/grc/control_owner/presentation/ui/pages/add_owner_page.dart
/// Module: Control Owner Management
/// Description: Single-page form for adding a new Control Owner — pick
///              exactly one employee, then assign one or more {Policy,
///              Control} pairs to them. Control_Owners_Permissions is left
///              empty per assigned control (no picker UI in this iteration —
///              see the design spec's scope decisions).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: OwnerCubit, GrcOwnerSection, GetAllPoliciesUseCase,
///               GetAllControlsUseCase, PolicyEntity, ControlEntity
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
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

class AddOwnerPage extends StatefulWidget {
  final String moduleId;
  final String moduleNameEn;
  final String moduleNameAr;

  const AddOwnerPage({
    super.key,
    required this.moduleId,
    required this.moduleNameEn,
    required this.moduleNameAr,
  });

  @override
  State<AddOwnerPage> createState() => _AddOwnerPageState();
}

class _AddOwnerPageState extends State<AddOwnerPage> {
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

  Future<void> _onPolicyChanged(_AssigningControlRow row, String policyId) async {
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

    context.read<OwnerCubit>().createOwner(
          moduleId: widget.moduleId,
          ownerEmail: _selectedEmployees.first.email,
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<OwnerCubit>(),
      child: BlocConsumer<OwnerCubit, OwnerState>(
        listener: (context, state) {
          if (state is OwnerActionSuccess) {
            Navigator.pop(context, true);
          } else if (state is OwnerFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isSubmitting = state is OwnerLoading;
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
                          'Adding New Control Owner'.tr,
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
          Text('Control Owner'.tr, style: StyleText.fontSize16Weight500),
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
                'Please select a Control Owner'.tr,
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
            _buildRow(context, _rows[i], i),
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

  Widget _buildRow(BuildContext context, _AssigningControlRow row, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomDropdown<String>(
            label: 'Add Policy'.tr,
            hint: 'Choose Policy'.tr,
            enabled: !_loadingPolicies,
            items: _policies
                .map((p) => DropdownItem<String>(
                      value: p.id,
                      label: context.isArabic ? p.policyNameAr : p.policyNameEn,
                    ))
                .toList(),
            value: row.policyId,
            onChanged: (v) => _onPolicyChanged(row, v),
            fillColor: AppColors.background,
            required: false,
            errorText: _submitted && row.policyId == null
                ? 'Required'.tr
                : null,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: CustomMultiSelectDropdown<String>(
            label: 'Control'.tr,
            hint: 'Choose Control'.tr,
            enabled: row.policyId != null && !row.isLoadingControls,
            items: row.availableControls
                .map((c) => MultiSelectDropdownItem<String>(
                      value: c.id,
                      label: context.isArabic ? c.controlsNameAr : c.controlsNameEn,
                    ))
                .toList(),
            values: row.controlIds,
            onChanged: (v) => setState(() => row.controlIds = v),
            fillColor: AppColors.background,
            required: false,
            errorText: _submitted && row.controlIds.isEmpty
                ? 'Required'.tr
                : null,
          ),
        ),
        if (_rows.length > 1) ...[
          SizedBox(width: 8.w),
          Padding(
            padding: EdgeInsets.only(top: 24.h),
            child: IconButton(
              icon: const Icon(Icons.close),
              color: AppColors.red,
              onPressed: () => _removeRow(index),
            ),
          ),
        ],
      ],
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
