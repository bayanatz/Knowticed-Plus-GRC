/// Module: GRC Policy Management
/// Description: Read-only details page for a single Control — view its
///              fields, open it for editing, or delete it. Editing is a
///              separate full-page route, AddEditControlPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter_bloc, ControlCubit, ChampionCubit, OwnerCubit,
///               ControlEntity, GRCModuleEntity, PolicyEntity, get_it
/// Revision History: 2026-07-21 - Initial creation
///                   2026-07-28 - Split view sections out into
///                                widgets/control_details_widget/
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_details_page.dart
/// Purpose: Contains ControlDetailsPage, the read/delete details screen for
///          a single Control, opened by tapping a Control card on the
///          Policy Details page. Owns the Control state (post-edit/delete
///          refresh); every visual section is delegated to a widget under
///          widgets/control_details_widget/.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 21/7/2026

import 'package:grc_module/core/custom/11_custom_confirm_diaolog.dart' show showSuccessDialog;
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/grc/control/domain/entities/control_entity.dart';
import 'package:grc_module/features/grc/control/presentation/ui/pages/add_edit_control_page.dart';
import 'package:grc_module/features/grc/control/presentation/ui/widgets/control_details_widget/control_departments_weight_section_widget.dart';
import 'package:grc_module/features/grc/control/presentation/ui/widgets/control_details_widget/control_description_section_widget.dart';
import 'package:grc_module/features/grc/control/presentation/ui/widgets/control_details_widget/control_documents_preview_row_widget.dart';
import 'package:grc_module/features/grc/control/presentation/ui/widgets/control_details_widget/control_frequency_weight_dates_row_widget.dart';
import 'package:grc_module/features/grc/control/presentation/ui/widgets/control_details_widget/control_score_and_previous_owners_row_widget.dart';
import 'package:grc_module/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:grc_module/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:grc_module/features/grc/control_owner/presentation/ui/pages/control_previous_owners_page.dart';
import 'package:grc_module/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:grc_module/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart';
import 'package:grc_module/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:grc_module/features/grc/control/presentation/controller/control_cubit.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';

/// class name: [ControlDetailsPage]
///
/// purpose: entry-point widget for the Control Details screen. Provides its
///          own [ControlCubit] (delete + post-edit refresh), [ChampionCubit]
///          and [OwnerCubit] (champion/owner lookup), and hands all three
///          down to [AddEditControlPage] via `BlocProvider.value` so state
///          doesn't diverge between the two pages.
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
        BlocProvider<ControlCubit>(
          create: (_) => GetIt.instance<ControlCubit>(),
        ),
        BlocProvider<ChampionCubit>(
          create: (_) => GetIt.instance<ChampionCubit>()
            ..getAllChampions(moduleId: module.moduleId),
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

  Future<void> _openEditControl(ControlCubit cubit) async {
    final championCubit = context.read<ChampionCubit>();
    final ownerCubit = context.read<OwnerCubit>();
    await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MultiBlocProvider(
          providers: [
            BlocProvider<ControlCubit>.value(value: cubit),
            BlocProvider<ChampionCubit>.value(value: championCubit),
            BlocProvider<OwnerCubit>.value(value: ownerCubit),
          ],
          child: AddEditControlPage(
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

  void _onDelete(ControlCubit cubit) {
    cubit.deleteControl(
      id: _control.id,
      moduleId: widget.module.moduleId,
      policyId: widget.policy.id,
    );
  }

  void _onStateChange(BuildContext context, ControlState state) {
    if (state is ControlLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is ControlsListLoaded) {
      final updated = state.controls.where((c) => c.id == _control.id);
      if (updated.isNotEmpty) setState(() => _control = updated.first);
      return;
    }

    if (state is ControlDeleted) {
      showSuccessDialog(
        context: context,
        title: S.of(context).controlDeleted,
        subtitle: S.of(context).youSuccessfullyDeletedThisControl,
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is ControlFailure) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        title: S.of(context).unsuccessful,
        subtitle: state.message,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ControlCubit>();
    final isArabic = context.isArabic;
    final dateFormat = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');

    return BlocListener<ControlCubit, ControlState>(
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
                    S.of(context).grc,
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
                ControlScoreAndPreviousOwnersRowWidget(
                  score: _control.score,
                  onPreviousOwnersTap: _openPreviousControlOwners,
                ),
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
                            ControlDescriptionSectionWidget(
                              descriptionEn: _control.controlsDescriptionEn,
                              descriptionAr: _control.controlsDescriptionAr,
                              isArabic: isArabic,
                              lastModifiedDate: _control.lastModifiedDate,
                              dateFormat: dateFormat,
                              policyId: widget.policy.id,
                              controlId: _control.id,
                            ),
                            SizedBox(height: 10.h),
                            ControlDocumentsPreviewRowWidget(
                              documentEnUrl: _control.controlsDocumentEn,
                              documentArUrl: _control.controlsDocumentAr,
                              lastModifiedDate: _control.lastModifiedDate,
                              dateFormat: dateFormat,
                            ),
                            ControlFrequencyWeightDatesRowWidget(
                              frequency: _control.frequency,
                              weight: _control.controlsWeight,
                              startDate: _control.startDate,
                              endDate: _control.endDate,
                              dateFormat: dateFormat,
                            ),
                            SizedBox(height: 10.h),
                            ControlDepartmentsWeightSectionWidget(
                              departments: _control.departments,
                            ),
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
