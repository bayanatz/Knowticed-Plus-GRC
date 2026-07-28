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
import 'package:demo_app/features/grc/approval/domain/entities/approval_resolver.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_status.dart';
import 'package:demo_app/features/grc/approval/presentation/controller/approval_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_contact_inline_row.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_label_value_row.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_section_card.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_section_sub_tabs.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_status_pill.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_submitter_row.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';

final DateFormat _cardDateFormat = DateFormat('d MMM yyyy');
final DateFormat _cardTimeFormat = DateFormat('h:mm a');

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
  int _approvalsTab = 0; // 0 = Approvals, 1 = Inquires

  void _onApprovePressed(BuildContext context) {
    final cubit = context.read<ApprovalCubit>();
    showConfirmDialog(
      context: context,
      title: 'Approve Request'.tr,
      subtitle: 'Are you sure you want to approve this request?'.tr,
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
      title: 'Reject Document'.tr,
      subtitle: 'Are you sure you want to reject this document?'.tr,
      confirmLabel: 'Yes'.tr,
      cancelLabel: 'No'.tr,
      onConfirm: () => showCommentDialog(
        context: context,
        title: 'Reason Of Rejection'.tr,
        fieldLabel: 'Justifications'.tr,
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

  @override
  Widget build(BuildContext context) {
    final control = widget.item.control;
    final policy = widget.item.policy;
    final assignmentControl = widget.item.assignmentControl;
    final isArabic = context.isArabic;
    final championEmail = assignmentControl.controlChampionEmail;
    final isPending = widget.item.approval.status == ApprovalStatus.pending;

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
        final style = ApprovalStatusStyle.of(widget.item.approval.status);
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
                        GrcSectionCard(children: [
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
                        GrcSectionCard(children: [
                          Text(
                            isArabic ? control.controlsNameAr : control.controlsNameEn,
                            style: StyleText.fontSize16Weight600,
                          ),
                          SizedBox(height: 8.h),
                          GrcLabelValueRow(
                            'Description'.tr,
                            isArabic
                                ? control.controlsDescriptionAr
                                : control.controlsDescriptionEn,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (assignmentControl.controlOwner != null)
                                Expanded(
                                  child: GrcContactInlineRow(
                                    label: 'Control Owner'.tr,
                                    email: assignmentControl.controlOwner,
                                  ),
                                ),
                              GrcContactInlineRow(
                                label: 'Control Champion'.tr,
                                email: championEmail,
                              ),
                            ],
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Approvals'.tr, style: StyleText.fontSize16Weight600),
                            GrcSectionSubTabs(
                              labels: ['Approvals'.tr, 'Inquires'.tr],
                              selected: _approvalsTab,
                              onChanged: (i) => setState(() => _approvalsTab = i),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        if (_approvalsTab == 1)
                          GrcSectionCard(children: [
                            Text('Inquiries coming soon'.tr, style: CardStyles.value(12)),
                          ])
                        else
                          GrcSectionCard(children: [
                            GrcSubmitterRow(email: championEmail),
                            SizedBox(height: 8.h),
                            Text(
                              '${'Submission Date'.tr}: '
                              '${_cardDateFormat.format(assignmentControl.lastModificationDate)} '
                              '${'At'.tr} '
                              '${_cardTimeFormat.format(assignmentControl.lastModificationDate)}',
                              style: CardStyles.label(12),
                            ),
                            SizedBox(height: 12.h),
                            if (assignmentControl.submissionDocument.isNotEmpty)
                              ProductWarrantyCard(
                                fileName: assignmentControl.submissionDocument
                                    .split('/')
                                    .last
                                    .split('?')
                                    .first,
                                onTapFile: () {},
                              ),
                            SizedBox(height: 12.h),
                            if (assignmentControl.submissionNote.isNotEmpty) ...[
                              GrcLabelValueRow(
                                  'Submission Notes'.tr, assignmentControl.submissionNote),
                              SizedBox(height: 12.h),
                            ],
                            if (widget.item.approval.reasonOfRejection != null &&
                                widget.item.approval.reasonOfRejection!.isNotEmpty) ...[
                              GrcLabelValueRow(
                                'Reasons of Rejection'.tr,
                                widget.item.approval.reasonOfRejection!,
                                color: Colors.red,
                              ),
                              SizedBox(height: 12.h),
                            ],
                            SizedBox(height: 8.h),
                            if (isPending)
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
                              )
                            else
                              Align(
                                alignment: Alignment.centerRight,
                                child: GrcStatusPill(
                                  label: widget.item.approval.status.value.tr,
                                  color: style.color,
                                  icon: style.icon,
                                ),
                              ),
                          ]),
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
