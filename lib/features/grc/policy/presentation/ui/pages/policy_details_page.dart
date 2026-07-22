/// Module: GRC Policy Management
/// Description: Details page for a single Policy — view its fields and
///              delete the Policy (soft-delete). Editing is a separate
///              full-page route, [PolicyEditPage].
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-18
/// Dependencies: flutter_bloc, PolicyCubit, PolicyEntity, GRCModuleEntity,
///               get_it
/// Revision History: 2026-07-15 - Initial creation (Policy view/edit/delete)
///                   2026-07-18 - Reworked view-mode layout to match the
///                                latest design mock: Policy Number / Last
///                                Edit on one row, Owner moved above the
///                                Weight/Start/End row, documents shown side
///                                by side, a search bar + "Control" dropdown
///                                (Add Control / Bulk Upload) above the
///                                controls list, a weight-mismatch banner,
///                                and a responsive 2-column controls grid.
///                   2026-07-18 - Split view/edit bodies into
///                                PolicyViewModeWidget / PolicyEditModeWidget
///                                (widgets/policy_details_widget/) so both
///                                modes are organized the same way; fixed
///                                _submitted not resetting on re-entering
///                                Edit, which made validation errors show up
///                                inconsistently depending on prior use.
///                   2026-07-18 - Moved editing out of this page entirely
///                                into its own route, [PolicyEditPage] —
///                                matching the AddEditControlPage pattern —
///                                so view and edit are fully independent
///                                pages instead of one page toggling modes.
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_details_page.dart
/// Purpose: Contains PolicyDetailsPage, the read/delete details screen for a
///          single Policy, opened by tapping a policy card on the GRC
///          Module details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 15/7/2026

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    show showSuccessDialog;
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/add_edit_control_page.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_page.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_edit_page.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_view_mode_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// class name: [PolicyDetailsPage]
///
/// purpose: entry-point widget for the Policy Details screen. Provides a
///          [PolicyCubit] and fetches [policyId] fresh from Firestore so the
///          page always reflects the latest saved state.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 15/7/2026
class PolicyDetailsPage extends StatelessWidget {
  final String policyId;
  final String moduleId;
  final GRCModuleEntity module;

  const PolicyDetailsPage({
    super.key,
    required this.policyId,
    required this.moduleId,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<PolicyCubit>(),
      child: _PolicyDetailsBody(
        policyId: policyId,
        moduleId: moduleId,
        module: module,
      ),
    );
  }
}

class _PolicyDetailsBody extends StatefulWidget {
  final String policyId;
  final String moduleId;
  final GRCModuleEntity module;

  const _PolicyDetailsBody({
    required this.policyId,
    required this.moduleId,
    required this.module,
  });

  @override
  State<_PolicyDetailsBody> createState() => _PolicyDetailsBodyState();
}

class _PolicyDetailsBodyState extends State<_PolicyDetailsBody> {
  PolicyEntity? _policy;
  bool _pendingDelete = false;
  List<ControlEntity> _controls = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final cubit = context.read<PolicyCubit>();
    await cubit.getPolicy(widget.policyId, moduleId: widget.moduleId);
    await cubit.getAllControls(
      moduleId: widget.moduleId,
      policyId: widget.policyId,
    );
  }

  void _onDelete(PolicyCubit cubit) {
    _pendingDelete = true;
    cubit.deletePolicy(id: _policy!.id, moduleId: widget.moduleId);
  }

  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      if (_policy != null) showLoadingIndicator();
      return;
    }
    if (_policy != null) hideLoadingIndicator();

    if (state is PolicySingleLoaded) {
      setState(() => _policy = state.policy);
      return;
    }

    if (state is PolicyControlsListLoaded) {
      setState(() => _controls = state.controls);
      return;
    }

    if (state is PolicyActionSuccess) {
      if (_pendingDelete) {
        showSuccessDialog(
          context: context,
          title: 'Policy Deleted'.tr,
          subtitle: 'You successfully deleted this policy.'.tr,
        );
        Navigator.of(context).pop(true);
      }
      return;
    }

    if (state is PolicyFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
      );
    }
  }

  Future<void> _openEditPolicy() async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PolicyEditPage(
          moduleId: widget.moduleId,
          policy: _policy!,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      context.read<PolicyCubit>().getPolicy(
            widget.policyId,
            moduleId: widget.moduleId,
          );
    }
  }

  Future<void> _openAddEditControl({ControlEntity? existing}) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddEditControlPage(
          moduleId: widget.moduleId,
          policyId: widget.policyId,
          existingControl: existing,
          siblingControls: _controls,
          policyStartDate: _policy!.startDate,
          policyEndDate: _policy!.endDate,
          policyHasArabic: _policy!.policyNameAr.trim().isNotEmpty ||
              _policy!.policyNumberAr.trim().isNotEmpty ||
              _policy!.policyDescriptionAr.trim().isNotEmpty,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      context
          .read<PolicyCubit>()
          .getAllControls(moduleId: widget.moduleId, policyId: widget.policyId);
    }
  }

  Future<void> _onBulkUploadControls() async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ControlBulkUploadPage(
          moduleId: widget.moduleId,
          policyId: widget.policyId,
          policyStartDate: _policy!.startDate,
          policyEndDate: _policy!.endDate,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      context
          .read<PolicyCubit>()
          .getAllControls(moduleId: widget.moduleId, policyId: widget.policyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PolicyCubit>();
    final isArabic = context.isArabic;
    final dateFormat = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');

    return BlocListener<PolicyCubit, PolicyState>(
      listener: _onStateChange,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _policy == null
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaginationAppBar(
                        screensTitles: [
                          'GRC'.tr,
                          isArabic
                              ? widget.module.moduleNameAr
                              : widget.module.moduleNameEn,
                          isArabic
                              ? _policy!.policyNameAr
                              : _policy!.policyNameEn,
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Policy Details'.tr,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          Spacer(),
                          GrcActionButtons(
                            onEditTap: _openEditPolicy,
                            onDeleteTap: () => _onDelete(cubit),
                            deleteDialogTitle: 'Deleting Policy',
                            deleteDialogSubtitle:
                                'Are You Sure You Want To Delete This Policy ?',
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            child: PolicyViewModeWidget(
                              policy: _policy!,
                              module: widget.module,
                              controls: _controls,
                              isArabic: isArabic,
                              dateFormat: dateFormat,
                              onControlTap: (existing) =>
                                  _openAddEditControl(existing: existing),
                              onBulkUpload: _onBulkUploadControls,
                              onControlsChanged: () =>
                                  context.read<PolicyCubit>().getAllControls(
                                        moduleId: widget.moduleId,
                                        policyId: widget.policyId,
                                      ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
