// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_stage_form_page.dart
// Purpose: View, add, and edit CRM conversion stages
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/crm/data/legacy_core/custom/custom_status_dropdown_button_99.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/domain/entities/crm_convert_stage.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/presentation/controller/crm_convert_cubit.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/presentation/controller/crm_convert_form_cubit.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/presentation/controller/crm_convert_form_state.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/presentation/ui/widgets/crm_convert_checklist_item_row.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmConvertStageFormPage extends StatefulWidget {
  final CrmConvertCubit convertCubit;
  final CrmConvertStage? stage;
  final bool readOnly;

  const CrmConvertStageFormPage({
    super.key,
    required this.convertCubit,
    this.stage,
    this.readOnly = false,
  });

  @override
  State<CrmConvertStageFormPage> createState() =>
      _CrmConvertStageFormPageState();
}

class _CrmConvertStageFormPageState extends State<CrmConvertStageFormPage> {
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;
  late final CrmConvertFormCubit _formCubit;
  late bool _readOnly;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _readOnly = widget.readOnly;
    _isActive = widget.stage?.isActive ?? true;
    _nameEnController = TextEditingController(text: widget.stage?.nameEn ?? '');
    _nameArController = TextEditingController(text: widget.stage?.nameAr ?? '');
    _formCubit = CrmConvertFormCubit(widget.convertCubit)
      ..prepare(widget.stage);
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _formCubit.close();
    super.dispose();
  }

  void _save() {
    CrmControlDialogs.showSaveDialog(
      context: context,
      title:
          widget.stage == null ? S.current.crmAddStage : S.current.crmEditStage,
      subtitle: S.current.crmSaveSubtitle,
      onConfirm: () async {
        showLoadingIndicator();
        final bool saved = await _formCubit.submit(
          existing: widget.stage,
          nameEn: _nameEnController.text,
          nameAr: _nameArController.text,
          status: _isActive ? 'active' : 'inactive',
        );
        hideLoadingIndicator();
        if (!mounted || !saved) return;
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccess,
          subtitle: widget.stage == null
              ? S.current.crmStageSavedSuccess
              : S.current.crmStageUpdatedSuccess,
          onComplete: () {
            if (mounted) {
              if (widget.stage != null) {
                setState(() => _readOnly = true);
              } else {
                Navigator.of(context).pop();
              }
            }
          },
        );
      },
    );
  }

  void _delete() {
    final CrmConvertStage? stage = widget.stage;
    if (stage == null) return;
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmDeleteStage,
      subtitle: S.current.crmDeleteStageConfirm,
      onConfirm: () async {
        showLoadingIndicator();
        final bool deleted = await widget.convertCubit.deleteStage(stage);
        hideLoadingIndicator();
        if (!mounted || !deleted) return;
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccess,
          subtitle: S.current.crmStageDeletedSuccess,
          onComplete: () {
            if (mounted) Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String pageTitle = widget.stage == null
        ? S.current.crmAddStage
        : (_readOnly
            ? FormatHelper.localizedString(
                englishName: 'Stage Detail',
                arabicName: 'تفاصيل المرحلة',
              )
            : S.current.crmEditStage);

    return BlocConsumer<CrmConvertFormCubit, CrmConvertFormState>(
      bloc: _formCubit,
      listener: (BuildContext context, CrmConvertFormState state) {
        final String? error = widget.convertCubit.state.errorMessage;
        if (error != null && error.isNotEmpty) {
          widget.convertCubit.clearError();
          CrmControlDialogs.showErrorDialog(
              context: context, title: S.current.crmAlert, subtitle: error);
        }
      },
      builder: (BuildContext context, CrmConvertFormState state) => Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crm,
          secondTitle: S.current.crmSectionControls,
          thirdTitle: S.current.crmControlConvert,
          fourthTitle: pageTitle,
          onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
          onSecondTap: () => CrmNavigationHelper.pop(context),
          onThirdTap: () => CrmNavigationHelper.pop(context),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Details Mode Action Triggers: Status Dropdown on left, Edit & Delete on right
                if (widget.stage != null && _readOnly) ...<Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CustomStatusDropdownButton<bool>(
                        value: _isActive,
                        color: _isActive ? AppColors.green : AppColors.orange,
                        textColor: AppColors.white,
                        trailingIconColor: AppColors.white,
                        borderRadius: 8.r,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.sp,
                          vertical: 8.sp,
                        ),
                        items: <StatusDropdownItem<bool>>[
                          StatusDropdownItem<bool>(
                            value: true,
                            label: 'Active',
                            color: AppColors.green,
                            textColor: AppColors.white,
                          ),
                          StatusDropdownItem<bool>(
                            value: false,
                            label: 'Inactive',
                            color: AppColors.orange,
                            textColor: AppColors.white,
                          ),
                        ],
                        onChanged: (bool? val) {
                          if (val != null && widget.stage != null) {
                            setState(() => _isActive = val);
                            widget.convertCubit.updateStatus(
                              widget.stage!,
                              val ? 'active' : 'inactive',
                            );
                          }
                        },
                      ),
                      Wrap(
                        spacing: 8.sp,
                        children: <Widget>[
                          CustomEditIcon(
                            onTap: () => setState(() => _readOnly = false),
                          ),
                          CustomDeleteIcon(onTap: _delete),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.sp),
                ],

                // Details Form Section
                CrmSectionCard(
                  title: FormatHelper.localizedString(
                    englishName: 'Details',
                    arabicName: 'التفاصيل',
                  ),
                  showHideToggle: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildResponsiveFields(
                        context: context,
                        left: _field(
                          label: 'Stage Name',
                          controller: _nameEnController,
                          hint: 'Text Here',
                          readOnly: _readOnly,
                          error: state.nameEnError,
                          fillColor: AppColors.background,
                          onChanged: (_) => _formCubit.clearNameEnError(),
                        ),
                        right: Directionality(
                          textDirection: TextDirection.rtl,
                          child: _field(
                            label: 'اسم المرحلة',
                            controller: _nameArController,
                            hint: 'اكتب هنا',
                            readOnly: _readOnly,
                            error: state.nameArError,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            fillColor: AppColors.background,
                            onChanged: (_) => _formCubit.clearNameArError(),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.sp),
                      buildResponsiveFields(
                        context: context,
                        left: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Display Order',
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: 6.sp),
                            CustomDropdown<int>(
                              value: state.selectedOrder,
                              hint: 'Choose',
                              fillColor: AppColors.background,
                              items: List<DropdownItem<int>>.generate(
                                widget.convertCubit.state.stages.length + 1,
                                (int index) => DropdownItem<int>(
                                  value: index + 1,
                                  label: '${index + 1}',
                                ),
                              ),
                              onChanged: _readOnly
                                  ? null
                                  : (int? value) {
                                      if (value != null) {
                                        _formCubit.selectOrder(value);
                                      }
                                    },
                            ),
                          ],
                        ),
                        right: const SizedBox.shrink(),
                      ),
                      SizedBox(height: 20.sp),
                      Text(
                        'Checklist Progress',
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 12.sp),
                      ...List.generate(
                        state.checklist.length,
                        (int index) {
                          final CrmConvertChecklistInput item =
                              state.checklist[index];
                          return CrmConvertChecklistItemRow(
                            key: ValueKey<int>(item.id),
                            index: index + 1,
                            initialNameEn: item.nameEn,
                            initialNameAr: item.nameAr,
                            readOnly: _readOnly,
                            canDelete: state.checklist.length > 1,
                            onNameEnChanged: (String value) => _formCubit
                                .updateChecklistNameEn(item.id, value),
                            onNameArChanged: (String value) => _formCubit
                                .updateChecklistNameAr(item.id, value),
                            onDelete: () =>
                                _formCubit.removeChecklistItem(item.id),
                          );
                        },
                      ),
                      if (!_readOnly) ...<Widget>[
                        SizedBox(height: 4.sp),
                        customButtonWithSvg(
                          title: FormatHelper.localizedString(
                            englishName: 'Checklist',
                            arabicName: 'قائمة التحقق',
                          ),
                          function: _formCubit.addChecklistItem,
                          color: AppColors.blackButton,
                          colorBorder: AppColors.transparent,
                          image: AppAssets.crmPlusBold,
                          svgColor: AppTheme.readableOn(AppColors.blackButton),
                          widthImage: 14.sp,
                          heightImage: 14.sp,
                          textStyle: StyleText.fontSize12Weight400.copyWith(
                              color:
                                  AppTheme.readableOn(AppColors.blackButton)),
                        ),
                      ],
                    ],
                  ),
                ),

                // Bottom Action Buttons in Edit/Add Mode
                if (!_readOnly) ...<Widget>[
                  SizedBox(height: 24.sp),
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    children: <Widget>[
                      Expanded(
                        child: customButton(
                          title: S.current.crmDiscard,
                          function: () {
                            if (widget.stage != null) {
                              setState(() => _readOnly = true);
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          color: AppColors.grey,
                          textColor: AppColors.black,
                        ),
                      ),
                      SizedBox(width: 16.sp),
                      Expanded(
                        child: customButton(
                          title: widget.stage == null
                              ? S.current.crmAdd
                              : S.current.crmSave,
                          function: state.isSubmitting ? () {} : _save,
                          color: state.isSubmitting
                              ? AppColors.disabledGrey
                              : AppColors.primary,
                          textColor: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 32.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool readOnly,
    required ValueChanged<String> onChanged,
    Color? fillColor,
    String? error,
    TextAlign textAlign = TextAlign.start,
    TextDirection? textDirection,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 6.sp),
          CustomTextField(
            controller: controller,
            hint: hint,
            readOnly: readOnly,
            errorText: error,
            textAlign: textAlign,
            textDirection: textDirection,
            fillColor: fillColor ?? AppColors.background,
            onChanged: onChanged,
          ),
        ],
      );
}
