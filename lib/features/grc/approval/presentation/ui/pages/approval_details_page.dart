// lib/features/grc/approval/presentation/ui/pages/approval_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_item.dart';
import 'package:demo_app/features/grc/approval/presentation/controller/approval_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';

final DateFormat _cardDateFormat = DateFormat('d MMM yyyy');

class ApprovalDetailsPage extends StatefulWidget {
  final ApprovalItem item;
  final GRCModuleEntity module;

  const ApprovalDetailsPage({
    super.key,
    required this.item,
    required this.module,
  });

  @override
  State<ApprovalDetailsPage> createState() => _ApprovalDetailsPageState();
}

class _ApprovalDetailsPageState extends State<ApprovalDetailsPage> {
  void _onApprovePressed(BuildContext context) {
    final cubit = context.read<ApprovalCubit>();
    showConfirmDialog(
      context: context,
      title: 'Approve Request'.tr,
      subtitle: 'Approve this request?'.tr,
      confirmLabel: 'Yes'.tr,
      cancelLabel: 'No'.tr,
      onConfirm: () => cubit.approve(
        moduleId: widget.module.moduleId,
        controlId: widget.item.control.id,
        championEmail: widget.item.assignmentControl.controlChampionEmail,
        managerEmail: currentGrcUserEmail(),
      ),
    );
  }

  void _onRejectPressed(BuildContext context) {
    final cubit = context.read<ApprovalCubit>();
    showConfirmDialog(
      context: context,
      title: 'Reject Request'.tr,
      subtitle: 'Reject this request?'.tr,
      confirmLabel: 'Yes'.tr,
      cancelLabel: 'No'.tr,
      onConfirm: () => showCommentDialog(
        context: context,
        title: 'Reason of Rejection'.tr,
        fieldLabel: 'Reason of Rejection'.tr,
        hint: 'Text here'.tr,
        submitLabel: 'Submit'.tr,
        onSubmit: (reason) => cubit.reject(
          moduleId: widget.module.moduleId,
          controlId: widget.item.control.id,
          championEmail: widget.item.assignmentControl.controlChampionEmail,
          managerEmail: currentGrcUserEmail(),
          reason: reason,
        ),
      ),
    );
  }

  Widget _labelValueRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: CardStyles.label(12)),
        Expanded(child: Text(value, style: CardStyles.value(12))),
      ],
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.item.control;
    final policy = widget.item.policy;
    final assignmentControl = widget.item.assignmentControl;
    final isArabic = context.isArabic;
    final championEmail = assignmentControl.controlChampionEmail;
    final championName = employeeDisplayName(context, championEmail);

    return BlocConsumer<ApprovalCubit, ApprovalState>(
      listener: (context, state) {
        if (state is ApprovalActionSuccess) {
          context.read<ApprovalCubit>().getMyApprovals(
                moduleId: widget.module.moduleId,
                managerEmail: currentGrcUserEmail(),
              );
          showSuccessDialog(
            context: context,
            title: 'Request Updated'.tr,
            subtitle: 'The request has been updated successfully'.tr,
          );
          Navigator.pop(context);
        } else if (state is ApprovalFailure) {
          showErrorDialog(context: context, subtitle: state.message);
        }
      },
      builder: (context, state) {
        final isSaving = state is ApprovalLoading;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(
                    screensTitles: [
                      'GRC'.tr,
                      'Approvals'.tr,
                      isArabic ? control.controlsNameAr : control.controlsNameEn,
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Expanded(
                    child: ListView(
                      children: [
                        Text('Policy Details'.tr, style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        _sectionCard(children: [
                          Text(
                            isArabic ? policy.policyNameAr : policy.policyNameEn,
                            style: StyleText.fontSize16Weight600,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            isArabic
                                ? policy.policyDescriptionAr
                                : policy.policyDescriptionEn,
                            style: CardStyles.value(12),
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Text('Control Details'.tr, style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        _sectionCard(children: [
                          Text(
                            isArabic ? control.controlsNameAr : control.controlsNameEn,
                            style: StyleText.fontSize16Weight600,
                          ),
                          SizedBox(height: 8.h),
                          _labelValueRow(
                            'Description'.tr,
                            isArabic
                                ? control.controlsDescriptionAr
                                : control.controlsDescriptionEn,
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Text('Champion & Submission'.tr,
                            style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        _sectionCard(children: [
                          _labelValueRow('Champion'.tr, championName),
                          SizedBox(height: 8.h),
                          _labelValueRow('Champion Email'.tr, championEmail),
                          SizedBox(height: 8.h),
                          _labelValueRow(
                            'Submission Date'.tr,
                            _cardDateFormat.format(assignmentControl.lastModificationDate),
                          ),
                          SizedBox(height: 12.h),
                          if (assignmentControl.submissionNote.isNotEmpty) ...[
                            _labelValueRow(
                                'Submission Notes'.tr, assignmentControl.submissionNote),
                            SizedBox(height: 12.h),
                          ],
                          if (assignmentControl.submissionDocument.isNotEmpty)
                            ProductWarrantyCard(
                              fileName: assignmentControl.submissionDocument
                                  .split('/')
                                  .last
                                  .split('?')
                                  .first,
                              onTapFile: () {},
                            ),
                        ]),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: customButton(
                                title: 'Reject'.tr,
                                function: isSaving
                                    ? () {}
                                    : () => _onRejectPressed(context),
                                height: 44.h,
                                color: AppColors.red,
                                textStyle: StyleText.fontSize16Weight500
                                    .copyWith(color: AppColors.textButton),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: customButton(
                                title: 'Approve'.tr,
                                function: isSaving
                                    ? () {}
                                    : () => _onApprovePressed(context),
                                height: 44.h,
                                color: AppColors.primary,
                                textStyle: StyleText.fontSize16Weight500
                                    .copyWith(color: AppColors.textButton),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
