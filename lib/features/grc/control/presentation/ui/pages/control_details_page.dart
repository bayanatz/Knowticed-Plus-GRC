/// Module: GRC Policy Management
/// Description: Read-only details page for a single Control — view its
///              fields, open it for editing, or delete it. Editing is a
///              separate full-page route, AddEditControlPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter_bloc, PolicyCubit, OwnerCubit, ControlEntity,
///               GRCModuleEntity, PolicyEntity, get_it
/// Revision History: 2026-07-21 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_details_page.dart
/// Purpose: Contains ControlDetailsPage, the read/delete details screen for
///          a single Control, opened by tapping a Control card on the
///          Policy Details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 21/7/2026

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    show showSuccessDialog, showErrorDialog;
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/add_edit_control_page.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/grc/control_owner/presentation/ui/pages/control_previous_owners_page.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// class name: [ControlDetailsPage]
///
/// purpose: entry-point widget for the Control Details screen. Provides its
///          own [PolicyCubit] (delete + post-edit refresh) and [OwnerCubit]
///          (owner lookup).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 21/7/2026
class ControlDetailsPage extends StatelessWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;
  final ControlEntity control;
  final List<ControlEntity> siblingControls;

  const ControlDetailsPage({
    super.key,
    required this.module,
    required this.policy,
    required this.control,
    required this.siblingControls,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyCubit>(
          create: (_) => GetIt.instance<PolicyCubit>(),
        ),
        BlocProvider<OwnerCubit>(
          create: (_) => GetIt.instance<OwnerCubit>()
            ..getAllOwners(moduleId: module.moduleId),
        ),
      ],
      child: _ControlDetailsBody(
        module: module,
        policy: policy,
        initialControl: control,
        siblingControls: siblingControls,
      ),
    );
  }
}

class _ControlDetailsBody extends StatefulWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;
  final ControlEntity initialControl;
  final List<ControlEntity> siblingControls;

  const _ControlDetailsBody({
    required this.module,
    required this.policy,
    required this.initialControl,
    required this.siblingControls,
  });

  @override
  State<_ControlDetailsBody> createState() => _ControlDetailsBodyState();
}

class _ControlDetailsBodyState extends State<_ControlDetailsBody> {
  late ControlEntity _control;

  @override
  void initState() {
    super.initState();
    _control = widget.initialControl;
  }

  Future<void> _openEditControl(PolicyCubit cubit) async {
    await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddEditControlPage(
          policy: widget.policy,
          moduleId: widget.module.moduleId,
          policyId: widget.policy.id,
          existingControl: _control,
          siblingControls: widget.siblingControls,
          policyStartDate: widget.policy.startDate,
          policyEndDate: widget.policy.endDate,
          policyHasArabic: widget.policy.policyNameAr.trim().isNotEmpty ||
              widget.policy.policyNumberAr.trim().isNotEmpty ||
              widget.policy.policyDescriptionAr.trim().isNotEmpty,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (mounted) {
      cubit.getAllControls(
        moduleId: widget.module.moduleId,
        policyId: widget.policy.id,
      );
    }
  }

  void _onDelete(PolicyCubit cubit) {
    cubit.deleteControl(
      id: _control.id,
      moduleId: widget.module.moduleId,
      policyId: widget.policy.id,
    );
  }

  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyControlsListLoaded) {
      final updated = state.controls.where((c) => c.id == _control.id);
      if (updated.isNotEmpty) setState(() => _control = updated.first);
      return;
    }

    if (state is PolicyControlDeleted) {
      showSuccessDialog(
        context: context,
        title: 'Control Deleted'.tr,
        subtitle: 'You successfully deleted this control.'.tr,
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is PolicyFailure) {
      showErrorDialog(context: context, subtitle: state.message);
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text.rich(
        TextSpan(
          text: '$label ',
          style: CardStyles.label(14),
          children: [TextSpan(text: value, style: CardStyles.value(14))],
        ),
      ),
    );
  }

  /// Every owner email assigned to this exact {Policy, Control} pair, in
  /// [owners]' original order. Mirrors AddEditControlPage's
  /// `_alreadyAssignedOwnerEmails`.
  List<String> _ownerEmailsForControl(List<OwnerEntity> owners) {
    return owners
        .where((o) => o.assigningControls.any((a) =>
            a.policyId == widget.policy.id && a.controlId == _control.id))
        .map((o) => o.ownerEmail)
        .toList();
  }

  Widget _buildDescriptionHeaderRow(DateFormat dateFormat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Control Description'.tr,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
        Text(
          '${'Last Update'.tr}: ${dateFormat.format(_control.lastModifiedDate)}',
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
      ],
    );
  }

  Widget _buildDocumentsRow(DateFormat dateFormat) {
    final hasEn = _control.controlsDocumentEn != null;
    final hasAr = _control.controlsDocumentAr != null;
    if (!hasEn && !hasAr) return const SizedBox.shrink();

    Widget documentCard(String url) => Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: ProductWarrantyCard(
              fileName: url.split('/').last,
              date: dateFormat.format(_control.lastModifiedDate),
            ),
          ),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasEn) documentCard(_control.controlsDocumentEn!),
          if (hasEn && hasAr) SizedBox(width: 12.w),
          if (hasAr) documentCard(_control.controlsDocumentAr!),
        ],
      ),
    );
  }

  Widget _buildFrequencyWeightDatesRow(DateFormat dateFormat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _infoRow('Frequency:'.tr, _control.frequency)),
        Expanded(
          child: _infoRow(
            'Control Weight:'.tr,
            _control.controlsWeight.toStringAsFixed(0),
          ),
        ),
        Expanded(
          child: _infoRow(
            'Start Date:'.tr,
            dateFormat.format(_control.startDate),
          ),
        ),
        Expanded(
          child: _infoRow('End Date:'.tr, dateFormat.format(_control.endDate)),
        ),
      ],
    );
  }

  Widget _departmentChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
      ),
    );
  }

  Widget _buildDepartmentsWeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Departments Weight'.tr,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
        SizedBox(height: 8.h),
        _control.departments.isEmpty
            ? _departmentChip('Not Assigned'.tr)
            : Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _control.departments
                    .map((d) => _departmentChip(
                        '${d.department} | ${d.weight.toStringAsFixed(0)}'))
                    .toList(),
              ),
      ],
    );
  }

  void _openPreviousControlOwners() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ControlPreviousOwnersPage(
          module: widget.module,
          policy: widget.policy,
          control: _control,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildScoreAndPreviousOwnersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text.rich(
            TextSpan(
              text: '${'Score'.tr}: ',
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryText),
              children: [
                TextSpan(
                  text: '${_control.score}',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: AppColors.green),
                ),
              ],
            ),
          ),
        ),
        customButton(
          title: 'Previous Control Owners'.tr,
          function: _openPreviousControlOwners,
          height: 38.h,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(
                  screensTitles: [
                    'GRC'.tr,
                    isArabic
                        ? widget.module.moduleNameAr
                        : widget.module.moduleNameEn,
                    isArabic
                        ? widget.policy.policyNameAr
                        : widget.policy.policyNameEn,
                    isArabic
                        ? _control.controlsNameAr
                        : _control.controlsNameEn,
                  ],
                ),
                GrcActionButtons(
                  onEditTap: () => _openEditControl(cubit),
                  onDeleteTap: () => _onDelete(cubit),
                  deleteDialogTitle: 'Deleting Control',
                  deleteDialogSubtitle:
                      'Are You Sure You Want To Delete This Control ?',
                ),
                SizedBox(height: 12.h),
                _buildScoreAndPreviousOwnersRow(),
                SizedBox(height: 12.h),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15.sp),
                        decoration: BoxDecoration(
                          color: AppColors.field,
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDescriptionHeaderRow(dateFormat),
                            Text(
                              isArabic
                                  ? _control.controlsDescriptionAr
                                  : _control.controlsDescriptionEn,
                              style: StyleText.fontSize12Weight500
                                  .copyWith(color: AppColors.secondaryText),
                            ),
                            SizedBox(height: 10.h),
                            BlocBuilder<OwnerCubit, OwnerState>(
                              builder: (context, state) {
                                final owners = state is OwnerListLoaded
                                    ? state.owners
                                    : const <OwnerEntity>[];
                                return GrcOwnerBadge(
                                  label: 'Control Owner:',
                                  ownerEmails: _ownerEmailsForControl(owners),
                                  onMessageTap: (owner) {},
                                );
                              },
                            ),
                            SizedBox(height: 10.h),
                            _buildDocumentsRow(dateFormat),
                            _buildFrequencyWeightDatesRow(dateFormat),
                            SizedBox(height: 10.h),
                            _buildDepartmentsWeightSection(),
                          ],
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
