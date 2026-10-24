// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_type_form_page.dart
// Purpose: Creates, views, edits, and removes CRM team types
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/features/crm/data/legacy_core/custom/custom_status_dropdown_button_99.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/entities/crm_team_type.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/interfaces/crm_team_types_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/presentation/controller/crm_team_type_form_cubit.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/presentation/controller/crm_team_type_form_state.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Page that owns the add, details, and edit modes for one team type.
class CrmTeamTypeFormPage extends StatefulWidget {
  final CrmTeamType? teamType;

  const CrmTeamTypeFormPage({super.key, this.teamType});

  @override
  State<CrmTeamTypeFormPage> createState() => _CrmTeamTypeFormPageState();
}

class _CrmTeamTypeFormPageState extends State<CrmTeamTypeFormPage> {
  late final CrmTeamTypeFormCubit _cubit;
  late bool _readOnly;
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;
  late final TextEditingController _noteEnController;
  late final TextEditingController _noteArController;

  @override
  void initState() {
    super.initState();
    _readOnly = widget.teamType != null;
    _cubit = CrmTeamTypeFormCubit(
      repository: Get.find<CrmTeamTypesBaseRepository>(),
      teamType: widget.teamType,
    )..init();
    _nameEnController = TextEditingController(text: widget.teamType?.nameEn);
    _nameArController = TextEditingController(text: widget.teamType?.nameAr);
    _noteEnController = TextEditingController(text: widget.teamType?.noteEn);
    _noteArController = TextEditingController(text: widget.teamType?.noteAr);
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _noteEnController.dispose();
    _noteArController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _save() => CrmControlDialogs.showSaveDialog(
        context: context,
        title: widget.teamType == null ? 'Add Type' : 'Save Type',
        subtitle: 'Are you sure you want to save this team type?',
        onConfirm: () async {
          showLoadingIndicator();
          final bool saved = await _cubit.save();
          hideLoadingIndicator();
          if (!mounted || !saved) return;
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: widget.teamType == null
                ? 'Team type added successfully'
                : 'Team type updated successfully',
            onComplete: () => CrmNavigationHelper.pop(context),
          );
        },
      );

  void _delete() => CrmControlDialogs.showRemoveDialog(
        context: context,
        title: 'Remove Type',
        subtitle: 'Are you sure you want to remove this team type?',
        onConfirm: () async {
          showLoadingIndicator();
          final bool deleted = await _cubit.delete();
          hideLoadingIndicator();
          if (!mounted || !deleted) return;
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: 'Team type removed successfully',
            onComplete: () => CrmNavigationHelper.pop(context),
          );
        },
      );

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CrmTeamTypeFormCubit, CrmTeamTypeFormState>(
        bloc: _cubit,
        listener: (BuildContext context, CrmTeamTypeFormState state) {
          if (state.errorMessage != null) {
            final String message = state.errorMessage!;
            _cubit.clearError();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              CrmControlDialogs.showErrorDialog(
                context: context,
                title: S.current.crmAlert,
                subtitle: message,
              );
            });
          }
        },
        builder: (BuildContext context, CrmTeamTypeFormState state) => Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: S.current.crm,
            secondTitle: S.current.crmSectionControls,
            thirdTitle: 'Team Types',
            fourthTitle: widget.teamType == null
                ? 'Add Type'
                : (_readOnly ? 'Type Details' : 'Edit Type'),
            onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
            onSecondTap: () => CrmNavigationHelper.pop(context),
            onThirdTap: () => CrmNavigationHelper.pop(context),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.teamType != null) _actions(state.teamType),
                  if (widget.teamType != null) SizedBox(height: 14.sp),
                  _details(state),
                  SizedBox(height: 18.sp),
                  if (!_readOnly) _formActions(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _actions(CrmTeamType teamType) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CustomStatusDropdownButton<bool>(
            value: teamType.isActive,
            fixedWidth: 200.sp,
            fixedHeight: 48.sp,
            color: teamType.isActive ? AppColors.green : AppColors.orange,
            textColor: AppColors.white,
            textStyle:
                StyleText.fontSize16Weight600.copyWith(color: AppColors.white),
            trailingIconColor: AppColors.white,
            isEnabled: !_readOnly,
            items: <StatusDropdownItem<bool>>[
              StatusDropdownItem(
                value: true,
                label: 'Active',
                color: AppColors.green,
              ),
              StatusDropdownItem(
                value: false,
                label: 'Inactive',
                color: AppColors.orange,
              ),
            ],
            onChanged: _cubit.updateIsActive,
          ),
          if (_readOnly)
            Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              CustomEditIcon(onTap: () => setState(() => _readOnly = false)),
              SizedBox(width: 12.sp),
              CustomDeleteIcon(
                title: 'Remove',
                color: AppColors.red,
                svgColor: AppColors.white,
                textStyle: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.white),
                onTap: _delete,
              ),
            ]),
        ],
      );

  Widget _details(CrmTeamTypeFormState state) => CrmSectionCard(
        title: 'Type Details',
        child: Column(children: <Widget>[
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: _nameEnController,
              label: 'Name',
              hint: 'Text Here',
              errorText: state.nameEnError,
              enabled: !_readOnly,
              fillColor: AppColors.background,
              onChanged: _cubit.updateNameEn,
            ),
            right: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                controller: _nameArController,
                label: 'الاسم',
                hint: 'اكتب هنا',
                errorText: state.nameArError,
                textAlign: TextAlign.right,
                enabled: !_readOnly,
                fillColor: AppColors.background,
                onChanged: _cubit.updateNameAr,
              ),
            ),
          ),
          SizedBox(height: 14.sp),
          CustomTextField(
            controller: _noteEnController,
            label: 'Note',
            hint: 'Description',
            maxLines: 3,
            maxLength: 500,
            showCharCount: true,
            enabled: !_readOnly,
            fillColor: AppColors.background,
            onChanged: _cubit.updateNoteEn,
          ),
          SizedBox(height: 14.sp),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomTextField(
              controller: _noteArController,
              label: 'ملاحظة',
              hint: 'اكتب هنا',
              maxLines: 3,
              maxLength: 500,
              showCharCount: true,
              textAlign: TextAlign.right,
              enabled: !_readOnly,
              fillColor: AppColors.background,
              onChanged: _cubit.updateNoteAr,
            ),
          ),
        ]),
      );

  Widget _formActions() => Row(
        textDirection: TextDirection
            .ltr, // X-73: Cancel left, action right in both languages

        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          customButton(
            title: 'Discard',
            function: () => CrmNavigationHelper.pop(context),
            color: AppColors.disabledGrey,
            textStyle:
                StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
          ),
          customButton(
            title: widget.teamType == null ? 'Add' : 'Save',
            function: _save,
            color: AppColors.primary,
            textStyle: StyleText.fontSize16Weight500
                .copyWith(color: AppColors.blackButton),
          ),
        ],
      );
}
