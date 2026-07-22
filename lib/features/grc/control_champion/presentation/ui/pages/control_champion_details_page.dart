import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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
    polResult.fold(
      (failure) {},
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

  EmployeeEntityPro? _findEmployee(String email) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
    final employees =
        Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
    for (final e in employees) {
      if (e.email == email) return e;
    }
    return null;
  }

  String _employeeDisplayName(BuildContext context, String email) {
    final employee = _findEmployee(email);
    if (employee == null) return email;
    return EmployeeHelper.getEmployeeLocalizedName(
        employee: employee, context: context);
  }

  PolicyEntity? _getPolicyEntity(String policyId) {
    for (final p in _allPolicies) {
      if (p.id == policyId) return p;
    }
    return null;
  }

  ControlEntity? _getControlEntity(String policyId, String controlId) {
    final list = _policyControls[policyId];
    if (list != null) {
      for (final c in list) {
        if (c.id == controlId) return c;
      }
    }
    return null;
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'Remove Control Champion'.tr,
          style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
        ),
        content: Text(
          'Are you sure you want to remove this Control Champion? This action is reversible.'
              .tr,
          style: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel'.tr,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<ChampionCubit>().updateChampion(
                    championEmail: _currentChampion.championEmail,
                    moduleId: widget.module.moduleId,
                    status: ChampionStatus.removed,
                  );
            },
            child: Text(
              'Remove'.tr,
              style:
                  StyleText.fontSize14Weight500.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employee = _findEmployee(_currentChampion.championEmail);
    final name = _employeeDisplayName(context, _currentChampion.championEmail);
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
        : 'assets/icons_assets/main_icons_assets/assets_male.svg';
    final phone = employee?.mobilePhone?.phone ??
        '2010258963'; // Mock placeholder if empty
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

                // Employee Profile Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dropShadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40.r,
                        backgroundColor: AppColors.barrierColor,
                        backgroundImage: photo.startsWith('http')
                            ? NetworkImage(photo)
                            : null,
                        child: !photo.startsWith('http')
                            ? SvgPicture.asset(photo, width: 45.w, height: 45.h)
                            : null,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: StyleText.fontSize16Weight600
                                  .copyWith(color: AppColors.text),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons_assets/data_grc_assets/approved-evidence-icon.svg",
                                  width: 14.sp,
                                  height: 14.sp,
                                  color: AppColors.secondaryText,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Title: ${jobTitle.isNotEmpty ? jobTitle : 'Technician'.tr}',
                                  style: StyleText.fontSize12Weight500
                                      .copyWith(color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 14, color: AppColors.colorGrey),
                                SizedBox(width: 6.w),
                                Text(
                                  'Phone Number: $phone',
                                  style: StyleText.fontSize12Weight500
                                      .copyWith(color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                const Icon(Icons.account_tree_outlined,
                                    size: 14, color: AppColors.colorGrey),
                                SizedBox(width: 6.w),
                                Text(
                                  'Department: ${department.isNotEmpty ? department : 'IT'.tr}',
                                  style: StyleText.fontSize12Weight500
                                      .copyWith(color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                const Icon(Icons.email_outlined,
                                    size: 14, color: AppColors.colorGrey),
                                SizedBox(width: 6.w),
                                Text(
                                  'Email: $email',
                                  style: StyleText.fontSize12Weight500
                                      .copyWith(color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44.sp,
                        height: 44.sp,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.chat_bubble_outline,
                              color: Colors.black),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

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
                        textStyle: StyleText.fontSize14Weight500
                            .copyWith(color: Colors.black),
                      ),
                    ),
                    Expanded(
                      child: customButton(
                        title: "Reassign".tr,
                        function: () async {
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
                                  FadeTransition(
                                      opacity: animation, child: child),
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                            ),
                          );
                          if (result == true && mounted) {
                            context.read<ChampionCubit>().getAllChampions(
                                moduleId: widget.module.moduleId);
                            Navigator.pop(context, true);
                          }
                        },
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize14Weight500
                            .copyWith(color: Colors.black),
                      ),
                    ),
                    Expanded(
                      child: customButtonWithSvg(
                        colorBorder: AppColors.primary,
                        space: 8.w,
                        widthImage: 16.w,
                        heightImage: 16.h,
                        image:
                            "assets/icons_assets/main_icons_assets/assets_edit.svg",
                        title: "Edit".tr,
                        function: () async {
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
                        textStyle: StyleText.fontSize14Weight500
                            .copyWith(color: Colors.black),
                      ),
                    ),
                    Expanded(
                      child: customButtonWithSvg(
                        colorBorder: AppColors.red,
                        space: 8.w,
                        widthImage: 16.w,
                        heightImage: 16.h,
                        image:
                            "assets/icons_assets/main_icons_assets/assets_cancel.svg",
                        title: "Remove".tr,
                        function: () => _showDeleteConfirmation(context),
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
                        child:
                            CircularProgressIndicator(color: AppColors.primary))
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
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              pName,
                              style: StyleText.fontSize14Weight500
                                  .copyWith(color: AppColors.text),
                            ),
                          );
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
                        child:
                            CircularProgressIndicator(color: AppColors.primary))
                    : Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            children:
                                _currentChampion.assigningControls.map((ac) {
                              final ctrl =
                                  _getControlEntity(ac.policyId, ac.controlId);
                              final cName = ctrl != null
                                  ? (context.isArabic
                                      ? ctrl.controlsNameAr
                                      : ctrl.controlsNameEn)
                                  : ac.controlId;
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(8.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.dropShadow,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  cName,
                                  style: StyleText.fontSize14Weight500
                                      .copyWith(color: AppColors.text),
                                ),
                              );
                            }).toList(),
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
