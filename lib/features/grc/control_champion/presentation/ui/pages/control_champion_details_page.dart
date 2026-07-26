import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/constants/app_assets.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_assignment_chip.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/custom/21-custom_contact_card.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import 'edit_champion_controls_page.dart';
import 'reassign_champion_page.dart';

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
    final polResult = await GetIt.instance<GetAllPoliciesUseCase>()
        .call(moduleId: widget.module.moduleId);
    await polResult.fold(
      (failure) async {},
      (policies) async {
        _allPolicies = policies;
        for (final policy in policies) {
          final ctrlResult = await GetIt.instance<GetAllControlsUseCase>()
              .call(moduleId: widget.module.moduleId, policyId: policy.id);
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
      title: 'Remove Control Champion'.tr,
      subtitle:
          'Are you sure you want to remove this Control Champion? This action is reversible.'
              .tr,
      cancelLabel: 'Cancel'.tr,
      confirmLabel: 'Remove'.tr,
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
    final department = employee != null
        ? EmployeeHelper.getEmployeeLocalizeDepartment(
            employee: employee, context: context)
        : '';
    final jobTitle = employee != null
        ? (EmployeeHelper.getEmployeeLocalizedTitle(
                    employee: employee, context: context)
                ?.toString() ??
            '')
        : '';
    final photo = employee != null
        ? EmployeeHelper.getEmployeeImage(employee: employee)
        : AppAssets.defaultEmployeeAvatar;
    final phone = employee?.mobilePhone?.phone ?? grcMockPhoneFallback;
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Control Champion removed successfully'.tr)),
            );
            Navigator.pop(context, true);
          } else {
            setState(() {
              _currentChampion = state.champion;
            });
          }
        } else if (state is ChampionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
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
                    'GRC'.tr,
                    context.isArabic
                        ? widget.module.moduleNameAr
                        : widget.module.moduleNameEn,
                    'Control Champion'.tr,
                  ],
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employee Profile Card
                        ContactCard(
                          name: name,
                          jobTitle:
                              jobTitle.isNotEmpty ? jobTitle : 'Technician'.tr,
                          department:
                              department.isNotEmpty ? department : 'IT'.tr,
                          email: email,
                          phone: phone,
                          avatar: photo.startsWith('http')
                              ? NetworkImage(photo)
                              : null,
                          onMessage: () {},
                        ),
                        SizedBox(height: 15.h),

                        // Action Buttons
                        Row(
                          spacing: 8.w,
                          children: [
                            Expanded(
                              child: customButtonWithSvg(
                                colorBorder: AppColors.primary,
                                space: 8.w,
                                widthImage: 16.w,
                                heightImage: 16.h,
                                image:
                                    "assets/icons_assets/data_grc_assets/messages_new.svg",
                                title: "Contact Manager".tr,
                                function: () {},
                                color: AppColors.primary,
                                textStyle: StyleText.fontSize14Weight500,
                              ),
                            ),
                            Expanded(
                              child: customButton(
                                title: _isReassignLoading
                                    ? "Loading...".tr
                                    : "Reassign".tr,
                                height: 34.h,
                                function: _isReassignLoading
                                    ? () {}
                                    : () async {
                                        setState(
                                            () => _isReassignLoading = true);
                                        await _loadAllData();
                                        if (mounted) {
                                          setState(
                                              () => _isReassignLoading = false);
                                        }
                                        if (!context.mounted) return;
                                        final result =
                                            await Navigator.push<bool>(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>
                                                BlocProvider.value(
                                              value:
                                                  context.read<ChampionCubit>(),
                                              child: ReassignChampionPage(
                                                champion: _currentChampion,
                                                module: widget.module,
                                                allPolicies: _allPolicies,
                                                policyControls: _policyControls,
                                              ),
                                            ),
                                            transitionsBuilder:
                                                (_, animation, __, child) =>
                                                    FadeTransition(
                                                        opacity: animation,
                                                        child: child),
                                            transitionDuration: const Duration(
                                                milliseconds: 300),
                                          ),
                                        );
                                        if (result == true && mounted) {
                                          context
                                              .read<ChampionCubit>()
                                              .getAllChampions(
                                                  moduleId:
                                                      widget.module.moduleId);
                                          Navigator.pop(context, true);
                                        }
                                      },
                                color: AppColors.primary,
                                textStyle: StyleText.fontSize14Weight500,
                              ),
                            ),
                            Spacer(),
                            Expanded(
                              child: customButtonWithSvg(
                                colorBorder: AppColors.primary,
                                space: 8.w,
                                widthImage: 16.w,
                                heightImage: 16.h,
                                image:
                                    "assets/icons_assets/data_grc_assets/editButton.svg",
                                title: _isEditLoading
                                    ? "Loading...".tr
                                    : "Edit".tr,
                                function: _isEditLoading
                                    ? () {}
                                    : () async {
                                        setState(() => _isEditLoading = true);
                                        await _loadAllData();
                                        if (mounted) {
                                          setState(
                                              () => _isEditLoading = false);
                                        }
                                        if (!context.mounted) return;
                                        final result =
                                            await showDialog<ChampionEntity>(
                                          context: context,
                                          builder: (dialogCtx) =>
                                              BlocProvider.value(
                                            value:
                                                context.read<ChampionCubit>(),
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
                            ),
                            Expanded(
                              child: customButtonWithSvg(
                                colorBorder: AppColors.red,
                                space: 8.w,
                                widthImage: 16.w,
                                heightImage: 16.h,
                                image:
                                    "assets/icons_assets/data_grc_assets/icons_icon _trash.svg",
                                title: "Remove".tr,
                                function: () =>
                                    _showDeleteConfirmation(context),
                                color: AppColors.red,
                                textStyle: StyleText.fontSize14Weight500
                                    .copyWith(color: Colors.white),
                                svgColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Policies Section
                        Text(
                          'Policies'.tr,
                          style: StyleText.fontSize16Weight600
                              .copyWith(color: AppColors.text),
                        ),
                        SizedBox(height: 12.h),
                        _isLoadingData
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary))
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
                        SizedBox(height: 24.h),

                        // Controls Section
                        Text(
                          'Controls'.tr,
                          style: StyleText.fontSize16Weight600
                              .copyWith(color: AppColors.text),
                        ),
                        SizedBox(height: 12.h),
                        _isLoadingData
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary))
                            : Wrap(
                                spacing: 10.w,
                                runSpacing: 10.h,
                                children: _currentChampion.assigningControls
                                    .map((ac) {
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
}
