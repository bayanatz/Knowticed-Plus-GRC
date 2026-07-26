import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
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
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/grc/shared/models/pending_assignment_row.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_assignment_chip.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_policy_control_picker_row.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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

  // Each row is its own independent Policy + Controls picker. Selections
  // made here are staging only — they aren't added to _tempControls (and
  // so don't appear as chips under "Assigned Controls") until Save.
  final List<PendingAssignmentRow> _pendingRows = [PendingAssignmentRow()];

  @override
  void initState() {
    super.initState();
    _tempControls = List.from(widget.champion.assigningControls);
  }

  void _removeControl(int index) {
    setState(() {
      _tempControls.removeAt(index);
    });
  }

  void _addPolicyRow() {
    setState(() {
      _pendingRows.add(PendingAssignmentRow());
    });
  }

  void _confirmAndSave(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: 'Save Changes'.tr,
      subtitle: 'Are you sure you want to save these changes?'.tr,
      cancelLabel: 'Cancel'.tr,
      confirmLabel: 'Save'.tr,
      onConfirm: () => _save(context),
    );
  }

  void _save(BuildContext context) {
    setState(() {
      commitPendingAssignmentRows(
          pendingRows: _pendingRows, target: _tempControls);
      _pendingRows
        ..clear()
        ..add(PendingAssignmentRow());
    });
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

    final editor = currentGrcUserEmail();
    final updateUseCase = GetIt.instance<UpdateControlUseCase>();

    Future<void> applyStatus(
      (String, String) pair, {
      required bool hasAnyAssignee,
    }) async {
      final control = findControlInPolicy(widget.policyControls, pair.$1, pair.$2);
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
          owners.any((o) => o.assigningControls
              .any((ac) => ac.policyId == pair.$1 && ac.controlId == pair.$2));
      await applyStatus(pair, hasAnyAssignee: stillCovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChampionCubit, ChampionState>(
      listener: (context, state) {
        if (state is ChampionActionSuccess) {
          showSuccessDialog(
            context: context,
            title: 'Controls Updated'.tr,
            subtitle: 'Controls updated successfully'.tr,
          );
          Navigator.pop(context, state.champion);
        } else if (state is ChampionFailure) {
          showErrorDialog(context: context, subtitle: state.message);
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
              maxHeight: 0.6.sh,
              maxWidth: 800.w,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.r),
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
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            "assets/icons_assets/data_grc_assets/editButton.svg",
                            height: 24.h,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Edit Controls'.tr,
                          style: StyleText.fontSize20Weight600
                              .copyWith(color: AppColors.text),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

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
                                  findControlInPolicy(widget.policyControls,
                                      ac.policyId, ac.controlId);
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
                    SizedBox(height: 16.h),

                    // One Policy + Controls picker row per pending
                    // assignment. Tapping "+ Add Policy" below appends
                    // another independent row; nothing here touches
                    // "Assigned Controls" until Save.
                    ...List.generate(_pendingRows.length, (i) {
                      final row = _pendingRows[i];
                      final availableControlsForPolicy = row.policyId != null
                          ? (widget.policyControls[row.policyId] ?? [])
                          : <ControlEntity>[];

                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
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
                          onControlsChanged: (v) =>
                              setState(() => row.controlIds = v),
                          controlsLabel: 'Add Controls',
                          controlsHint: 'Choose Controls',
                          spacing: 12.w,
                        ),
                      );
                    }),
                    SizedBox(height: 8.h),

                    // Add Policy Button
                    customButton(
                      title: '+ Add Policy'.tr,
                      function: _addPolicyRow,
                      width: 140.w,
                      radius: 12,
                      color: AppColors.blackButton,
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 16.h),

                    // Save Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: customButton(
                        title: isSaving ? 'Saving...'.tr : 'Save'.tr,
                        function:
                            isSaving ? () {} : () => _confirmAndSave(context),
                        width: 120.w,
                        radius: 12,
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
