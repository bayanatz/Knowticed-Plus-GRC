// ****************** FILE INFO ******************
// File Name: crm_custom_grid_page.dart
// Purpose: Full-screen page for configuring CRM Custom Grid fields on mobile devices
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_custom_grid_draft_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_custom_grid_draft_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_custom_grid_edit_actions.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_custom_grid_limit_notice.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_custom_grid_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmCustomGridPage extends StatelessWidget {
  final String templateId;
  final String templateName;
  final String clientTypeId;
  final String clientType;
  final CrmCustomGridDraftCubit? draftCubit;

  const CrmCustomGridPage({
    super.key,
    required this.templateId,
    required this.templateName,
    required this.clientTypeId,
    this.clientType = 'Individuals',
    this.draftCubit,
  });

  @override
  Widget build(BuildContext context) {
    if (draftCubit != null) {
      return BlocProvider<CrmCustomGridDraftCubit>.value(
        value: draftCubit!,
        child: const _CrmCustomGridPageView(),
      );
    }

    final CrmTemplateBuilderCubit builderCubit =
        context.read<CrmTemplateBuilderCubit>();

    return BlocProvider<CrmCustomGridDraftCubit>(
      create: (BuildContext ctx) {
        final CrmCustomGridDraftCubit cubit = CrmCustomGridDraftCubit(
          saveCallback: builderCubit.saveCustomGrid,
        );
        cubit.syncTemplateData(
          template: builderCubit.state.template,
          fields: builderCubit.state.fields,
          sections: builderCubit.state.sections,
        );
        return cubit;
      },
      child: const _CrmCustomGridPageView(),
    );
  }
}

class _CrmCustomGridPageView extends StatelessWidget {
  const _CrmCustomGridPageView();

  CrmTemplateBuilderCubit? _tryGetBuilderCubit(BuildContext context) {
    try {
      return context.read<CrmTemplateBuilderCubit>();
    } catch (_) {
      return null;
    }
  }

  void _onEvent(BuildContext context, CrmCustomGridDraftState draftState) {
    if (draftState.event == CrmCustomGridEvent.limitReached) {
      CrmControlDialogs.showErrorDialog(
        context: context,
        title: S.current.crmCustomGridLimitReached,
        subtitle: S.current.crmMax4FieldsCanBeSelected,
      );
      context.read<CrmCustomGridDraftCubit>().clearEvent();
    } else if (draftState.event == CrmCustomGridEvent.saveFailed) {
      final String fallback = S.current.crmCustomGridSaveFailedDesc;
      final String message =
          _tryGetBuilderCubit(context)?.state.errorMessage ?? fallback;
      CrmControlDialogs.showErrorDialog(
        context: context,
        title: S.current.crmSaveFailed,
        subtitle: message,
      );
      context.read<CrmCustomGridDraftCubit>().clearEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CrmTemplateBuilderCubit? builderCubit = _tryGetBuilderCubit(context);
    final bool isMobile = kpIsPhoneLayout(context);

    Widget content =
        BlocConsumer<CrmCustomGridDraftCubit, CrmCustomGridDraftState>(
      listener: _onEvent,
      builder: (BuildContext context, CrmCustomGridDraftState draftState) {
        final bool isEditing = draftState.mode == CrmCustomGridMode.editing;
        final CrmCustomGridDraftCubit draftController =
            context.read<CrmCustomGridDraftCubit>();
        final bool isLoading = builderCubit != null &&
            (builderCubit.state.isLoading ||
                builderCubit.state.template == null);

        final String pageTitle =
            isEditing ? S.current.crmEditCustomGrid : S.current.crmCustomGrid;

        return PopScope(
          canPop: !isEditing,
          onPopInvokedWithResult: (bool didPop, dynamic result) {
            if (didPop) return;
            draftController.discardChanges();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SideFrameMasterServices(
              titleText: S.current.crmSectionControls,
              secondTitle: pageTitle,
              onFirstTap: () => CrmNavigationHelper.pop(context),
              onSecondTap: () {
                if (isEditing) {
                  draftController.discardChanges();
                } else {
                  CrmNavigationHelper.pop(context);
                }
              },
              child: isLoading && draftState.groups.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: CircleProgressMaster(),
                      ),
                    )
                  : _buildContent(
                      context,
                      isMobile: isMobile,
                      isEditing: isEditing,
                      draftState: draftState,
                      draftController: draftController,
                    ),
            ),
          ),
        );
      },
    );

    if (builderCubit != null) {
      content = BlocListener<CrmTemplateBuilderCubit, CrmTemplateBuilderState>(
        listener: (BuildContext ctx, CrmTemplateBuilderState bState) {
          ctx.read<CrmCustomGridDraftCubit>().syncTemplateData(
                template: bState.template,
                fields: bState.fields,
                sections: bState.sections,
              );
        },
        child: content,
      );
    }

    return content;
  }

  Widget _buildContent(
    BuildContext context, {
    required bool isMobile,
    required bool isEditing,
    required CrmCustomGridDraftState draftState,
    required CrmCustomGridDraftCubit draftController,
  }) {
    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isEditing) ...[
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CustomEditIcon(
              key: const Key('crm_custom_grid_edit_button'),
              color: AppColors.primary,
              svgColor: AppColors.black,
              onTap: draftController.enterEditMode,
            ),
          ),
          SizedBox(height: 16.sp),
        ],
        if (isEditing) ...[
          const CrmCustomGridLimitNotice(),
          SizedBox(height: 16.sp),
        ],
        for (final group in draftState.groups) ...[
          CrmCustomGridSectionCard(
            group: group,
            isReadOnly: !isEditing,
            isFieldSelected: draftState.isFieldSelected,
            onToggle: (String fieldId, bool enabled) =>
                draftController.toggleField(fieldId, enabled),
          ),
          SizedBox(height: 16.sp),
        ],
        if (isEditing) ...[
          CrmCustomGridEditActions(
            isSaving: draftState.isSaving,
            onDiscard: draftController.discardChanges,
            onSubmit: draftController.submitDraft,
          ),
          SizedBox(height: 24.sp),
        ],
      ],
    );

    if (isMobile) {
      return column;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: column,
    );
  }
}
