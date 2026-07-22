import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status_resolver.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/get_champion_usecases.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

class EditChampionControlsPage extends StatefulWidget {
  final ChampionEntity champion;
  final GRCModuleEntity module;
  final List<PolicyEntity> allPolicies;
  final Map<String, List<ControlEntity>> policyControls;

  const EditChampionControlsPage({
    super.key,
    required this.champion,
    required this.module,
    required this.allPolicies,
    required this.policyControls,
  });

  @override
  State<EditChampionControlsPage> createState() =>
      _EditChampionControlsPageState();
}

class _EditChampionControlsPageState extends State<EditChampionControlsPage> {
  late List<AssigningControlEntity> _tempControls;
  String? _selectedPolicyId;
  List<String> _selectedControlIds = [];

  @override
  void initState() {
    super.initState();
    _tempControls = List.from(widget.champion.assigningControls);
  }

  ControlEntity? _getControlEntity(String policyId, String controlId) {
    final list = widget.policyControls[policyId];
    if (list != null) {
      for (final c in list) {
        if (c.id == controlId) return c;
      }
    }
    return null;
  }

  void _removeControl(int index) {
    setState(() {
      _tempControls.removeAt(index);
    });
  }

  void _addControls() {
    if (_selectedPolicyId == null || _selectedControlIds.isEmpty) return;

    setState(() {
      for (final cid in _selectedControlIds) {
        final exists = _tempControls.any(
            (ac) => ac.policyId == _selectedPolicyId && ac.controlId == cid);
        if (!exists) {
          _tempControls.add(AssigningControlEntity(
            policyId: _selectedPolicyId!,
            controlId: cid,
          ));
        }
      }
      // Reset selection
      _selectedControlIds = [];
    });
  }

  void _save(BuildContext context) {
    // Fire-and-forget: these touch each affected Control document directly
    // (not the Champion doc this page's own loading/success state tracks),
    // so they don't need to block the Save button.
    _recomputeControlStatuses();
    context.read<ChampionCubit>().updateChampion(
          championEmail: widget.champion.championEmail,
          moduleId: widget.module.moduleId,
          assigningControls: _tempControls,
        );
  }

  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  /// function name: [_recomputeControlStatuses]
  ///
  /// purpose: before [_tempControls] is persisted, recompute the status of
  ///          every control whose assignment to this Champion just changed
  ///          — a newly-added control flips Unassigned -> Scheduled/Active;
  ///          a newly-removed one flips back to Unassigned, but only if no
  ///          other Champion or Owner in the module still covers it.
  ///          Controls currently Draft/Inactive/Expired are left untouched
  ///          either way (see [shouldRecomputeAssigneeBasedStatus]).
  Future<void> _recomputeControlStatuses() async {
    final originalPairs = widget.champion.assigningControls
        .map((ac) => (ac.policyId, ac.controlId))
        .toSet();
    final newPairs =
        _tempControls.map((ac) => (ac.policyId, ac.controlId)).toSet();
    final added = newPairs.difference(originalPairs);
    final removed = originalPairs.difference(newPairs);
    if (added.isEmpty && removed.isEmpty) return;

    var otherChampions = const <ChampionEntity>[];
    var owners = const <OwnerEntity>[];
    if (removed.isNotEmpty) {
      final championsResult = await GetIt.instance<GetAllChampionsUseCase>()
          .call(moduleId: widget.module.moduleId);
      otherChampions = championsResult.fold(
        (failure) => const <ChampionEntity>[],
        (champions) => champions
            .where((c) => c.championEmail != widget.champion.championEmail)
            .toList(),
      );
      final ownersResult = await GetIt.instance<GetAllOwnersUseCase>()
          .call(moduleId: widget.module.moduleId);
      owners = ownersResult.fold((failure) => const <OwnerEntity>[], (o) => o);
    }

    final editor = _currentUserEmail;
    final updateUseCase = GetIt.instance<UpdateControlUseCase>();

    Future<void> applyStatus(
      (String, String) pair, {
      required bool hasAnyAssignee,
    }) async {
      final control = _getControlEntity(pair.$1, pair.$2);
      if (control == null) return;
      if (!shouldRecomputeAssigneeBasedStatus(control.status)) return;
      final newStatus = computeAssigneeBasedControlStatus(
        effectiveStartDate: control.startDate,
        hasAnyAssignee: hasAnyAssignee,
      );
      if (newStatus == control.status) return;
      await updateUseCase.call(
        UpdateControlParams(
          id: control.id,
          moduleId: widget.module.moduleId,
          policyId: pair.$1,
          editorId: editor,
          status: newStatus,
        ),
      );
    }

    for (final pair in added) {
      await applyStatus(pair, hasAnyAssignee: true);
    }
    for (final pair in removed) {
      final stillCovered = otherChampions.any((c) => c.assigningControls.any(
              (ac) => ac.policyId == pair.$1 && ac.controlId == pair.$2)) ||
          owners.any((o) => o.assigningControls.any(
              (ac) => ac.policyId == pair.$1 && ac.controlId == pair.$2));
      await applyStatus(pair, hasAnyAssignee: stillCovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableControlsForPolicy = _selectedPolicyId != null
        ? (widget.policyControls[_selectedPolicyId] ?? [])
        : <ControlEntity>[];

    return BlocConsumer<ChampionCubit, ChampionState>(
      listener: (context, state) {
        if (state is ChampionActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Controls updated successfully'.tr)),
          );
          Navigator.pop(context, state.champion);
        } else if (state is ChampionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is ChampionLoading;

        return Dialog(
          backgroundColor: AppColors.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 0.8.sh,
              maxWidth: 0.9.sw,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit_outlined,
                              color: AppColors.yellow, size: 24.sp),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Edit Controls'.tr,
                          style: StyleText.fontSize20Weight600
                              .copyWith(color: AppColors.text),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Assigned Controls Section
                    Text(
                      'Assigned Controls'.tr,
                      style: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.text),
                    ),
                    SizedBox(height: 10.h),
                    _tempControls.isEmpty
                        ? Text(
                            'No Controls assigned.'.tr,
                            style: StyleText.fontSize14Weight400
                                .copyWith(color: AppColors.secondaryText),
                          )
                        : Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children:
                                List.generate(_tempControls.length, (index) {
                              final ac = _tempControls[index];
                              final ctrl =
                                  _getControlEntity(ac.policyId, ac.controlId);
                              final cName = ctrl != null
                                  ? (context.isArabic
                                      ? ctrl.controlsNameAr
                                      : ctrl.controlsNameEn)
                                  : ac.controlId;
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      cName,
                                      style: StyleText.fontSize12Weight500
                                          .copyWith(color: AppColors.text),
                                    ),
                                    SizedBox(width: 6.w),
                                    GestureDetector(
                                      onTap: () => _removeControl(index),
                                      child: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                    SizedBox(height: 20.h),

                    // Add Policy Dropdown
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomDropdown<String>(
                            label: 'Add Policy'.tr,
                            hint: 'Choose Policy'.tr,
                            items: widget.allPolicies
                                .map((p) => DropdownItem<String>(
                                      value: p.id,
                                      label: context.isArabic
                                          ? p.policyNameAr
                                          : p.policyNameEn,
                                    ))
                                .toList(),
                            value: _selectedPolicyId,
                            onChanged: (v) {
                              setState(() {
                                _selectedPolicyId = v;
                                _selectedControlIds = [];
                              });
                            },
                            fillColor: AppColors.background,
                            required: false,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomMultiSelectDropdown<String>(
                            label: 'Add Controls'.tr,
                            hint: 'Choose Controls'.tr,
                            enabled: _selectedPolicyId != null,
                            items: availableControlsForPolicy
                                .map((c) => MultiSelectDropdownItem<String>(
                                      value: c.id,
                                      label: context.isArabic
                                          ? c.controlsNameAr
                                          : c.controlsNameEn,
                                    ))
                                .toList(),
                            values: _selectedControlIds,
                            onChanged: (v) {
                              setState(() {
                                _selectedControlIds = v;
                              });
                            },
                            fillColor: AppColors.background,
                            required: false,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Add Policy Button
                    customButton(
                      title: '+ Add Policy'.tr,
                      function: _addControls,
                      width: 140.w,
                      color: AppColors.blackButton,
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 24.h),

                    // Save Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: customButton(
                        title: isSaving ? 'Saving...'.tr : 'Save'.tr,
                        function: isSaving ? () {} : () => _save(context),
                        width: 120.w,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize14Weight500
                            .copyWith(color: Colors.black),
                      ),
                    ),
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
