// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reason_details_page.dart
// Purpose: View and edit a bilingual CRM reason set
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/domain/entities/crm_reason.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/domain/interfaces/crm_reasons_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/presentation/controller/crm_reasons_cubit.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/presentation/controller/crm_reasons_state.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/presentation/ui/widgets/crm_reason_input_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

class CrmReasonDetailsPage extends StatefulWidget {
  final CrmReasonSetDefinition reasonSet;

  const CrmReasonDetailsPage({super.key, required this.reasonSet});

  @override
  State<CrmReasonDetailsPage> createState() => _CrmReasonDetailsPageState();
}

class _CrmReasonDetailsPageState extends State<CrmReasonDetailsPage> {
  late final CrmReasonsCubit _cubit;
  bool _readOnly = true;

  @override
  void initState() {
    super.initState();
    _cubit = CrmReasonsCubit(
      repository: Get.find<CrmReasonsBaseRepository>(),
      reasonSetId: widget.reasonSet.id,
    )..init();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _save() {
    CrmControlDialogs.showSaveDialog(
      context: context,
      title: 'Save Reasons',
      subtitle: S.current.crmSaveSubtitle,
      onConfirm: () async {
        showLoadingIndicator();
        final bool saved = await _cubit.save();
        hideLoadingIndicator();
        if (!mounted || !saved) return;
        setState(() => _readOnly = true);
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccess,
          subtitle: 'Reasons saved successfully',
        );
      },
    );
  }

  void _removeReason(int reasonId) {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: 'Remove Reason',
      subtitle: 'Are you sure you want to remove this reason?',
      onConfirm: () => _cubit.removeReason(reasonId),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CrmReasonsCubit, CrmReasonsState>(
        bloc: _cubit,
        listener: (BuildContext context, CrmReasonsState state) {
          final String? error = state.errorMessage;
          if (error != null && error.isNotEmpty) {
            _cubit.clearError();
            CrmControlDialogs.showErrorDialog(
              context: context,
              title: S.current.crmAlert,
              subtitle: error,
            );
          }
        },
        builder: (BuildContext context, CrmReasonsState state) => Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: S.current.crm,
            secondTitle: S.current.crmSectionControls,
            thirdTitle: S.current.crmControlReasons,
            fourthTitle: widget.reasonSet.title,
            onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
            onSecondTap: () => CrmNavigationHelper.pop(context),
            onThirdTap: () => CrmNavigationHelper.pop(context),
            child: state.isLoading
                ? const Center(child: CircleProgressMaster())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (_readOnly)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: CustomEditIcon(
                              onTap: () => setState(() => _readOnly = false),
                            ),
                          ),
                        if (_readOnly) SizedBox(height: 16.sp),
                        Text('Details', style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.sp),
                        Container(
                          padding: EdgeInsets.all(16.sp),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Reasons',
                                  style: StyleText.fontSize14Weight500),
                              SizedBox(height: 10.sp),
                              ...state.reasons.map(
                                (CrmReasonInput reason) => CrmReasonInputRow(
                                  key: ValueKey<int>(reason.id),
                                  initialNameEn: reason.nameEn,
                                  initialNameAr: reason.nameAr,
                                  readOnly: _readOnly,
                                  canDelete: state.reasons.length > 1,
                                  onNameEnChanged: (String value) =>
                                      _cubit.updateReasonEn(reason.id, value),
                                  onNameArChanged: (String value) =>
                                      _cubit.updateReasonAr(reason.id, value),
                                  onDelete: () => _removeReason(reason.id),
                                ),
                              ),
                              if (!_readOnly)
                                customButtonWithSvg(
                                  title: 'Reason',
                                  function: _cubit.addReason,
                                  color: AppColors.blackButton,
                                  colorBorder: AppColors.transparent,
                                  image: AppAssets.crmPlusBold,
                                  svgColor: AppTheme.readableOn(
                                      AppColors.blackButton),
                                  widthImage: 14.sp,
                                  heightImage: 14.sp,
                                  textStyle: StyleText.fontSize12Weight400
                                      .copyWith(
                                          color: AppTheme.readableOn(
                                              AppColors.blackButton)),
                                ),
                            ],
                          ),
                        ),
                        if (!_readOnly) ...<Widget>[
                          SizedBox(height: 24.sp),
                          Row(
                            textDirection: TextDirection
                                .ltr, // X-73: Cancel left, action right in both languages

                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              customButton(
                                title: S.current.crmDiscard,
                                function: () {
                                  _cubit.discardEdits();
                                  setState(() => _readOnly = true);
                                },
                                color: AppColors.grey,
                                textColor: AppColors.black,
                              ),
                              customButton(
                                title: S.current.crmSave,
                                function: state.isSaving ? () {} : _save,
                                color: state.isSaving
                                    ? AppColors.disabledGrey
                                    : AppColors.primary,
                                textColor: AppColors.black,
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
