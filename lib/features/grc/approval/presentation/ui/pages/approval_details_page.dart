// lib/features/grc/approval/presentation/ui/pages/approval_details_page.dart
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_item.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_status.dart';
import 'package:demo_app/features/grc/approval/presentation/controller/approval_cubit.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_document_launcher.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_button_loading_placeholder.dart';
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
  late final SubmissionHistoryCubit _historyCubit;

  @override
  void initState() {
    super.initState();
    _historyCubit = GetIt.instance<SubmissionHistoryCubit>();
    _historyCubit.loadHistory(
      moduleId: widget.module.moduleId,
      controlId: widget.item.control.id,
      championEmail: widget.item.assignmentControl.controlChampionEmail,
    );
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }

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
    final moduleOwnerEmail = widget.module.moduleOwners.isNotEmpty
        ? widget.module.moduleOwners.first
        : null;
    final policyDocument =
        isArabic ? policy.policyDocumentAr : policy.policyDocumentEn;

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
                      isArabic
                          ? control.controlsNameAr
                          : control.controlsNameEn,
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Expanded(
                    child: ListView(
                      children: [
                        Text('Policy Details'.tr,
                            style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        GrcSectionCard(color: AppColors.card, children: [
                          Text(
                            isArabic
                                ? policy.policyNameAr
                                : policy.policyNameEn,
                            style: StyleText.fontSize16Weight600,
                          ),
                          SizedBox(height: 8.h),
                          Text('Policy Description'.tr,
                              style: CardStyles.label(12)),
                          SizedBox(height: 4.h),
                          Text(
                            isArabic
                                ? policy.policyDescriptionAr
                                : policy.policyDescriptionEn,
                            style: CardStyles.value(12),
                          ),
                          SizedBox(height: 12.h),
                          if (moduleOwnerEmail != null) ...[
                            GrcContactInlineRow(
                                label: 'Module Owner'.tr,
                                email: moduleOwnerEmail),
                            SizedBox(height: 12.h),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: GrcLabelValueRow('Policy Weight'.tr,
                                    policy.policyWeight.toString()),
                              ),
                              Expanded(
                                child: GrcLabelValueRow(
                                  'Policy Number'.tr,
                                  isArabic
                                      ? policy.policyNumberAr
                                      : policy.policyNumberEn,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GrcLabelValueRow(
                                        'Start Date'.tr,
                                        _cardDateFormat
                                            .format(policy.startDate)),
                                    SizedBox(height: 4.h),
                                    GrcLabelValueRow('End Date'.tr,
                                        _cardDateFormat.format(policy.endDate)),
                                  ],
                                ),
                              ),
                              if (policyDocument != null &&
                                  policyDocument.isNotEmpty)
                                ProductWarrantyCard(
                                  fileName: policyDocument
                                      .split('/')
                                      .last
                                      .split('?')
                                      .first,
                                  onTapFile: () =>
                                      openGrcDocument(policyDocument),
                                ),
                            ],
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Text('Control Details'.tr,
                            style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        GrcSectionCard(color: AppColors.card, children: [
                          Text(
                            isArabic
                                ? control.controlsNameAr
                                : control.controlsNameEn,
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
                              Expanded(
                                child: GrcContactInlineRow(
                                  label: 'Control Owner'.tr,
                                  email: assignmentControl.controlOwner,
                                ),
                              ),
                              Expanded(
                                child: GrcContactInlineRow(
                                  label: 'Control Champion'.tr,
                                  email: championEmail,
                                ),
                              ),
                            ],
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Approvals'.tr,
                                style: StyleText.fontSize16Weight600),
                            GrcSectionSubTabs(
                              labels: ['Approvals'.tr, 'Inquires'.tr],
                              selected: _approvalsTab,
                              onChanged: (i) =>
                                  setState(() => _approvalsTab = i),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        if (_approvalsTab == 1)
                          GrcSectionCard(children: [
                            Text('Inquiries coming soon'.tr,
                                style: CardStyles.value(12)),
                          ])
                        else
                          Column(
                            children: [
                              BlocBuilder<SubmissionHistoryCubit,
                                  SubmissionHistoryState>(
                                bloc: _historyCubit,
                                builder: (context, historyState) {
                                  if (historyState
                                      is SubmissionHistoryFailure) {
                                    return GrcSectionCard(children: [
                                      Text(
                                        historyState.message,
                                        style: CardStyles.value(12)
                                            .copyWith(color: Colors.red),
                                      ),
                                    ]);
                                  }
                                  if (historyState
                                      is! SubmissionHistoryLoaded) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 24.h),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            color: AppColors.primary),
                                      ),
                                    );
                                  }
                                  final entries = historyState.entries;
                                  return Column(
                                    children: [
                                      for (final e
                                          in entries.asMap().entries) ...[
                                        GrcSectionCard(
                                            color: AppColors.card,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  GrcSubmitterRow(
                                                      email: championEmail),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              '${'Submission Date'.tr}: ',
                                                          style: CardStyles
                                                                  .label(12)
                                                              .copyWith(
                                                                  color:
                                                                      AppColors
                                                                          .text),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '${_cardDateFormat.format(e.value.submittedDate)} '
                                                              '${'At'.tr} '
                                                              '${_cardTimeFormat.format(e.value.submittedDate)}',
                                                          style:
                                                              CardStyles.label(
                                                                  12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 12.h),
                                              if (e.value.document.isNotEmpty)
                                                ProductWarrantyCard(
                                                  fileName: e.value.document
                                                      .split('/')
                                                      .last
                                                      .split('?')
                                                      .first,
                                                  onTapFile: () =>
                                                      openGrcDocument(
                                                          e.value.document),
                                                ),
                                              SizedBox(height: 12.h),
                                              if (e.value.note.isNotEmpty) ...[
                                                GrcLabelValueRow(
                                                    'Submission Notes'.tr,
                                                    e.value.note),
                                                SizedBox(height: 12.h),
                                              ],
                                              if (e.value.status ==
                                                      AssignmentControlStatus
                                                          .rejected &&
                                                  (e.value.rejectionReason
                                                          ?.isNotEmpty ??
                                                      false)) ...[
                                                GrcLabelValueRow(
                                                  'Reasons of Rejection'.tr,
                                                  e.value.rejectionReason!,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(height: 12.h),
                                              ],
                                              if (e.key == 0 && isPending)
                                                isSaving
                                                    ? Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child:
                                                            GrcButtonLoadingPlaceholder(
                                                          width: 120.w,
                                                          height: 44.h,
                                                        ),
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          customButtonWithSvg(
                                                            colorBorder:
                                                                AppColors.red,
                                                            space: 8.w,
                                                            widthImage: 18.w,
                                                            heightImage: 18.h,
                                                            image:
                                                                "assets/icons_assets/data_grc_assets/icons_icon _trash.svg",
                                                            title: 'Reject'.tr,
                                                            function: () =>
                                                                _onRejectPressed(
                                                                    context),
                                                            color:
                                                                AppColors.red,
                                                            textStyle: StyleText
                                                                .fontSize16Weight500
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white),
                                                            svgColor:
                                                                Colors.white,
                                                          ),
                                                          SizedBox(width: 16.w),
                                                          customButtonWithSvg(
                                                            colorBorder:
                                                                AppColors.green,
                                                            space: 8.w,
                                                            widthImage: 18.w,
                                                            heightImage: 18.h,
                                                            image:
                                                                'assets/icons_assets/data_grc_assets/images_success.svg',
                                                            title: 'Approve'.tr,
                                                            function: () =>
                                                                _onApprovePressed(
                                                                    context),
                                                            color:
                                                                AppColors.green,
                                                            textStyle: StyleText
                                                                .fontSize16Weight500
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white),
                                                            svgColor:
                                                                Colors.white,
                                                          ),
                                                        ],
                                                      )
                                              else
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: GrcStatusPill(
                                                    label:
                                                        e.value.status.label.tr,
                                                    color:
                                                        AssignmentControlStatusStyle
                                                                .of(e.value
                                                                    .status)
                                                            .color,
                                                    icon:
                                                        AssignmentControlStatusStyle
                                                                .of(e.value
                                                                    .status)
                                                            .icon,
                                                  ),
                                                ),
                                            ]),
                                        SizedBox(height: 12.h),
                                      ],
                                    ],
                                  );
                                },
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
