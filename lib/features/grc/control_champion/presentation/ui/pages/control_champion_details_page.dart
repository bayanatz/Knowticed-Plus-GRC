import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/features/grc/control/domain/entities/control_entity.dart';
import 'package:grc_module/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:grc_module/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:grc_module/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:grc_module/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:grc_module/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:grc_module/features/grc/shared/widgets/grc_assignment_chip.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';

import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/custom/41_custom_button_sizing.dart';
import 'package:grc_module/core/custom/21-custom_contact_card.dart';
import 'package:grc_module/core/custom/11_custom_confirm_diaolog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import 'edit_champion_controls_page.dart';
import 'reassign_champion_page.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_l10n.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';

class ControlChampionDetailsPage extends StatelessWidget {
  final ChampionEntity champion;
  final GRCModuleEntity module;

  const ControlChampionDetailsPage({
    super.key,
    required this.champion,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChampionCubit>(
      create: (_) => GetIt.instance<ChampionCubit>(),
      child: _ControlChampionDetailsBody(
        champion: champion,
        module: module,
      ),
    );
  }
}

class _ControlChampionDetailsBody extends StatefulWidget {
  final ChampionEntity champion;
  final GRCModuleEntity module;

  const _ControlChampionDetailsBody({
    required this.champion,
    required this.module,
  });

  @override
  State<_ControlChampionDetailsBody> createState() =>
      _ControlChampionDetailsBodyState();
}

class _ControlChampionDetailsBodyState
    extends State<_ControlChampionDetailsBody> {
  late ChampionEntity _currentChampion;
  bool _isLoadingData = true;
  bool _isReassignLoading = false;
  bool _isEditLoading = false;
  List<PolicyEntity> _allPolicies = [];
  final Map<String, List<ControlEntity>> _policyControls = {};

  @override
  void initState() {
    super.initState();
    _currentChampion = widget.champion;
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final championCubit = context.read<ChampionCubit>();
    final polResult =
        await championCubit.getAllPolicies(moduleId: widget.module.moduleId);
    await polResult.fold(
      (failure) async {},
      (policies) async {
        _allPolicies = policies;
        for (final policy in policies) {
          final ctrlResult = await championCubit.getAllControlsForPolicy(
              moduleId: widget.module.moduleId, policyId: policy.id);
          ctrlResult.fold(
            (failure) {},
            (controls) {
              _policyControls[policy.id] = controls;
            },
          );
        }
      },
    );
    if (mounted) {
      setState(() => _isLoadingData = false);
    }
  }

  PolicyEntity? _getPolicyEntity(String policyId) {
    for (final p in _allPolicies) {
      if (p.id == policyId) return p;
    }
    return null;
  }

  void _showDeleteConfirmation(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: S.of(context).removeControlChampion,
      subtitle:
          S.of(context).areYouSureYouWantToRemoveThisControlChampion,
      cancelLabel: S.of(context).Cancel,
      confirmLabel: S.of(context).remove,
      onConfirm: () {
        context.read<ChampionCubit>().updateChampion(
              championEmail: _currentChampion.championEmail,
              moduleId: widget.module.moduleId,
              status: ChampionStatus.removed,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final employee = findEmployeeByEmail(_currentChampion.championEmail);
    final name = employeeDisplayName(context, _currentChampion.championEmail);
    final department = employee.localizedDepartment(context);
    final jobTitle = employee.localizedJobTitle(context);
    final photo = employee.displayPhoto;
    final phone = employee.displayPhone;
    final email = _currentChampion.championEmail;

    // Get unique assigned policies
    final assignedPolicyIds = _currentChampion.assigningControls
        .map((ac) => ac.policyId)
        .toSet()
        .toList();

    return BlocListener<ChampionCubit, ChampionState>(
      listener: (context, state) {
        if (state is ChampionActionSuccess) {
          if (state.champion.status == ChampionStatus.removed) {
            showSuccessDialog(
              context: context,
              title: S.of(context).controlChampionRemoved,
              subtitle: S.of(context).controlChampionRemovedSuccessfully,
            );
            Navigator.pop(context, true);
          } else {
            setState(() {
              _currentChampion = state.champion;
            });
          }
        } else if (state is ChampionFailure) {
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
            title: S.of(context).unsuccessful,
            subtitle: state.message,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(
                  screensTitles: [
                    S.of(context).grc,
                    context.isArabic
                        ? widget.module.moduleNameAr
                        : widget.module.moduleNameEn,
                    S.of(context).controlChampion,
                  ],
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employee Profile Card
                        _buildProfileCard(
                          name: name,
                          jobTitle: jobTitle,
                          department: department,
                          email: email,
                          phone: phone,
                          photo: photo,
                        ),
                        SizedBox(height: 15.h),

                        // Action Buttons
                        _buildActionButtonsRow(context),
                        SizedBox(height: 24.h),

                        // Policies Section
                        ..._buildPoliciesSection(context, assignedPolicyIds),
                        SizedBox(height: 24.h),

                        // Controls Section
                        ..._buildControlsSection(context),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String jobTitle,
    required String department,
    required String email,
    required String phone,
    required String photo,
  }) {
    return ContactCard(
      name: name,
      jobTitle: jobTitle.isNotEmpty ? jobTitle :grcTr(context, grcMockJobTitleFallback),
      department: department.isNotEmpty ? department :grcTr(context, grcMockDepartmentFallback),
      email: email,
      phone: phone,
      avatar: photo.startsWith('http') ? NetworkImage(photo) : null,
      onMessage: () {},
    );
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return Row(
      spacing: 8.w,
      children: [
        customButtonWithSvg(
          colorBorder: AppColors.primary,
          space: 8.w,
          widthImage: 16.w,
          heightImage: 16.h,
          image: "assets/icons_assets/data_grc_assets/messages_new.svg",
          title: S.of(context).contactManager,
          function: () {},
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500,
        ),
        _isReassignLoading
            ? Container(
                height: 34.h,
                width: 135.w,
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
                    color: Colors.white,
                  ),
                ),
              )
            : customButton(
                title: S.of(context).reassign,
                height: 34.h,
                width: 135.w,
                function: () async {
                  setState(() => _isReassignLoading = true);
                  await _loadAllData();
                  if (mounted) {
                    setState(() => _isReassignLoading = false);
                  }
                  if (!context.mounted) return;
                  final result = await Navigator.push<bool>(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => BlocProvider.value(
                        value: context.read<ChampionCubit>(),
                        child: ReassignChampionPage(
                          champion: _currentChampion,
                          module: widget.module,
                          allPolicies: _allPolicies,
                          policyControls: _policyControls,
                        ),
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                  if (result == true && mounted) {
                    context
                        .read<ChampionCubit>()
                        .getAllChampions(moduleId: widget.module.moduleId);
                    Navigator.pop(context, true);
                  }
                },
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500,
              ),
        Spacer(),
        _isEditLoading
            ? Container(
                width: 135.w,
                height: 34.h,
                padding: EdgeInsets.symmetric(
                    horizontal: ButtonSizing.horizontalPadding),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(ButtonSizing.radius),
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  height: 18.h,
                  width: 18.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : customButtonWithSvg(
                colorBorder: AppColors.primary,
                space: 8.w,
                widthImage: 16.w,
                heightImage: 16.h,
                image: "assets/icons_assets/data_grc_assets/editButton.svg",
                title: S.of(context).Edit,
                function: () async {
                  setState(() => _isEditLoading = true);
                  await _loadAllData();
                  if (mounted) {
                    setState(() => _isEditLoading = false);
                  }
                  if (!context.mounted) return;
                  final result = await showDialog<ChampionEntity>(
                    context: context,
                    builder: (dialogCtx) => BlocProvider.value(
                      value: context.read<ChampionCubit>(),
                      child: EditChampionControlsPage(
                        champion: _currentChampion,
                        module: widget.module,
                        allPolicies: _allPolicies,
                        policyControls: _policyControls,
                      ),
                    ),
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _currentChampion = result;
                    });
                  }
                },
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500,
              ),
        customButtonWithSvg(
          colorBorder: AppColors.red,
          space: 8.w,
          widthImage: 16.w,
          heightImage: 16.h,
          image: "assets/icons_assets/data_grc_assets/icons_icon _trash.svg",
          title: S.of(context).remove,
          function: () => _showDeleteConfirmation(context),
          color: AppColors.red,
          textStyle:
              StyleText.fontSize14Weight500.copyWith(color: Colors.white),
          svgColor: Colors.white,
        ),
      ],
    );
  }

  List<Widget> _buildPoliciesSection(
      BuildContext context, List<String> assignedPolicyIds) {
    return [
      Text(
        S.of(context).policies,
        style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
      ),
      SizedBox(height: 12.h),
      _isLoadingData
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: assignedPolicyIds.map((policyId) {
                final policy = _getPolicyEntity(policyId);
                final pName = policy != null
                    ? (context.isArabic
                        ? policy.policyNameAr
                        : policy.policyNameEn)
                    : policyId;
                return GrcAssignmentChip(label: pName);
              }).toList(),
            ),
    ];
  }

  List<Widget> _buildControlsSection(BuildContext context) {
    return [
      Text(
        S.of(context).controls,
        style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
      ),
      SizedBox(height: 12.h),
      _isLoadingData
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: _currentChampion.assigningControls.map((ac) {
                final ctrl = findControlInPolicy(
                    _policyControls, ac.policyId, ac.controlId);
                final cName = ctrl != null
                    ? (context.isArabic
                        ? ctrl.controlsNameAr
                        : ctrl.controlsNameEn)
                    : ac.controlId;
                return GrcAssignmentChip(label: cName);
              }).toList(),
            ),
    ];
  }
}
