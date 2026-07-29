// lib/features/grc/my_audit/presentation/ui/pages/my_audit_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart';
import 'package:demo_app/features/grc/my_audit/domain/entities/my_audit_item.dart';
import 'package:demo_app/features/grc/my_audit/domain/entities/my_audit_tab.dart';
import 'package:demo_app/features/grc/my_audit/presentation/controller/my_audit_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_document_launcher.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_button_loading_placeholder.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_contact_inline_row.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_label_value_row.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_score_badge.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_section_card.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_section_sub_tabs.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_status_pill.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_submitter_row.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';

final DateFormat _cardDateFormat = DateFormat('d MMM yyyy');
final DateFormat _cardTimeFormat = DateFormat('h:mm a');

class MyAuditDetailsPage extends StatefulWidget {
  final MyAuditItem item;
  final GRCModuleEntity module;

  const MyAuditDetailsPage(
      {super.key, required this.item, required this.module});

  @override
  State<MyAuditDetailsPage> createState() => _MyAuditDetailsPageState();
}

class _MyAuditDetailsPageState extends State<MyAuditDetailsPage> {
  int _submissionTab = 0; // 0 = Submission, 1 = Inquires
  late final SubmissionHistoryCubit _historyCubit;

  @override
  void initState() {
    super.initState();
    _historyCubit = GetIt.instance<SubmissionHistoryCubit>();
    final assignmentControl = widget.item.assignmentControl;
    if (assignmentControl != null) {
      _historyCubit.loadHistory(
        moduleId: widget.module.moduleId,
        controlId: widget.item.control.id,
        championEmail: assignmentControl.controlChampionEmail,
      );
    }
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }

  void _onApprovePressed(BuildContext context) {
    final cubit = context.read<MyAuditCubit>();
    showConfirmDialog(
      context: context,
      title: 'Approve Evidence'.tr,
      subtitle: 'Are you sure you want to approve this evidence?'.tr,
      confirmLabel: 'Yes'.tr,
      cancelLabel: 'No'.tr,
      onConfirm: () => cubit.approve(
        moduleId: widget.module.moduleId,
        controlId: widget.item.control.id,
        championEmail: widget.item.assignmentControl!.controlChampionEmail,
        ownerEmail: currentGrcUserEmail(),
      ),
    );
  }

  void _onRejectPressed(BuildContext context) {
    final cubit = context.read<MyAuditCubit>();
    showConfirmDialog(
      context: context,
      title: 'Reject Evidence'.tr,
      subtitle: 'Are you sure you want to reject this evidence?'.tr,
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
          championEmail: widget.item.assignmentControl!.controlChampionEmail,
          ownerEmail: currentGrcUserEmail(),
          reason: reason,
        ),
      ),
    );
  }

  void _onScorePressed(BuildContext context) {
    final cubit = context.read<MyAuditCubit>();
    final scoreController = TextEditingController(
        text: widget.item.audit?.controlScore?.toString() ?? '');
    final justificationController = TextEditingController(
        text: widget.item.audit?.controlOwnerJustification ?? '');
    showDialog(
      context: context,
      barrierColor: AppColors.totalBlack.withValues(alpha: 0.4),
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.card,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          width: 380.w,
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30.r,
                    height: 30.r,
                    decoration: BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: Icon(Icons.workspace_premium,
                        size: 16.r, color: AppColors.textButton),
                  ),
                  SizedBox(width: 8.w),
                  Text('Give a Score'.tr, style: StyleText.fontSize14Weight600),
                ],
              ),
              SizedBox(height: 16.h),
              Text('Score'.tr, style: CardStyles.label(12)),
              SizedBox(height: 6.h),
              CustomTextField(
                hint: 'Text here'.tr,
                controller: scoreController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12.h),
              Text('Justifications'.tr, style: CardStyles.label(12)),
              SizedBox(height: 6.h),
              CustomTextField(
                hint: 'Text here'.tr,
                controller: justificationController,
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 120.w,
                  child: customButton(
                    title: 'Submit'.tr,
                    function: () {
                      final score =
                          double.tryParse(scoreController.text.trim());
                      if (score == null) return;
                      Navigator.of(dialogContext).pop();
                      cubit.submitScore(
                        moduleId: widget.module.moduleId,
                        policyId: widget.item.control.policyId,
                        controlId: widget.item.control.id,
                        championEmail:
                            widget.item.assignmentControl!.controlChampionEmail,
                        ownerEmail: currentGrcUserEmail(),
                        score: score,
                        justification:
                            justificationController.text.trim().isEmpty
                                ? null
                                : justificationController.text.trim(),
                      );
                    },
                    height: 36.h,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.textButton),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final control = widget.item.control;
    final policy = widget.item.policy;
    final assignmentControl = widget.item.assignmentControl;
    final audit = widget.item.audit;
    final moduleOwnerEmail = widget.module.moduleOwners.isNotEmpty
        ? widget.module.moduleOwners.first
        : null;
    final policyDocument =
        isArabic ? policy.policyDocumentAr : policy.policyDocumentEn;

    return BlocConsumer<MyAuditCubit, MyAuditState>(
      listener: (context, state) {
        if (state is MyAuditActionSuccess) {
          context.read<MyAuditCubit>().getMyAudits(
                moduleId: widget.module.moduleId,
                ownerEmail: currentGrcUserEmail(),
              );
          showSuccessDialog(
            context: context,
            title: 'Successful'.tr,
            subtitle: widget.item.tab == MyAuditTab.rejected
                ? 'You Successfully Rejected This Evidence'.tr
                : 'You Successfully Approved This Evidence'.tr,
          );
          Navigator.pop(context);
        } else if (state is MyAuditFailure) {
          showErrorDialog(context: context, subtitle: state.message);
        }
      },
      builder: (context, state) {
        final isSaving = state is MyAuditLoading;
        final style = MyAuditTabStyle.of(widget.item.tab);
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
                      'My Audit'.tr,
                      isArabic
                          ? control.controlsNameAr
                          : control.controlsNameEn,
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Expanded(
                    child: assignmentControl == null
                        ? _OverdueBody(
                            control: control,
                            policy: policy,
                            isArabic: isArabic)
                        : ListView(
                            children: [
                              Text('Policy Details'.tr,
                                  style: StyleText.fontSize16Weight600),
                              SizedBox(height: 8.h),
                              GrcSectionCard(children: [
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
                                      child: GrcLabelValueRow(
                                          'Policy Weight'.tr,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GrcLabelValueRow(
                                              'Start Date'.tr,
                                              _cardDateFormat
                                                  .format(policy.startDate)),
                                          SizedBox(height: 4.h),
                                          GrcLabelValueRow(
                                              'End Date'.tr,
                                              _cardDateFormat
                                                  .format(policy.endDate)),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Control Details'.tr,
                                      style: StyleText.fontSize16Weight600),
                                  if (assignmentControl.controlScore != null)
                                    GrcScoreBadge(
                                        score: assignmentControl.controlScore!),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              GrcSectionCard(children: [
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
                                        email: assignmentControl
                                            .controlChampionEmail,
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                              SizedBox(height: 15.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (widget.item.tab ==
                                          MyAuditTab.outstanding ||
                                      widget.item.tab == MyAuditTab.scored)
                                    isSaving
                                        ? GrcButtonLoadingPlaceholder(
                                            width: 120.w, height: 34.h)
                                        : SizedBox(
                                            width: 120.w,
                                            child: customButton(
                                              title: (widget.item.tab ==
                                                          MyAuditTab.scored
                                                      ? 'Edit Score'
                                                      : 'Add Score')
                                                  .tr,
                                              function: () =>
                                                  _onScorePressed(context),
                                              width: 120.w,
                                              color: AppColors.primary,
                                              textStyle: StyleText
                                                  .fontSize14Weight500
                                                  .copyWith(
                                                      color:
                                                          AppColors.textButton),
                                            ),
                                          ),
                                  // Text('Submission'.tr,
                                  //     style: StyleText.fontSize16Weight600),
                                  GrcSectionSubTabs(
                                    labels: ['Submission'.tr, 'Inquires'.tr],
                                    selected: _submissionTab,
                                    onChanged: (i) =>
                                        setState(() => _submissionTab = i),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              if (_submissionTab == 1)
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
                                            padding: EdgeInsets.symmetric(
                                                vertical: 24.h),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                  color: AppColors.primary),
                                            ),
                                          );
                                        }
                                        final entries = historyState.entries;
                                        return Column(
                                          children: [
                                            for (final entry in entries) ...[
                                              GrcSectionCard(children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    GrcSubmitterRow(
                                                        email: assignmentControl
                                                            .controlChampionEmail),
                                                    Text(
                                                      '${'Submission Date'.tr}: '
                                                      '${_cardDateFormat.format(entry.submittedDate)} '
                                                      '${'At'.tr} '
                                                      '${_cardTimeFormat.format(entry.submittedDate)}',
                                                      style:
                                                          CardStyles.label(12),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 12.h),
                                                if (entry.document.isNotEmpty)
                                                  ProductWarrantyCard(
                                                    fileName: entry.document
                                                        .split('/')
                                                        .last
                                                        .split('?')
                                                        .first,
                                                    onTapFile: () =>
                                                        openGrcDocument(
                                                            entry.document),
                                                  ),
                                                SizedBox(height: 12.h),
                                                if (entry.note.isNotEmpty) ...[
                                                  GrcLabelValueRow(
                                                      'Submission Notes'.tr,
                                                      entry.note),
                                                  SizedBox(height: 12.h),
                                                ],
                                                if (entry.status ==
                                                        AssignmentControlStatus
                                                            .rejected &&
                                                    (entry.rejectionReason
                                                            ?.isNotEmpty ??
                                                        false)) ...[
                                                  GrcLabelValueRow(
                                                    'Reasons of Rejection'.tr,
                                                    entry.rejectionReason!,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(height: 12.h),
                                                ],
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: GrcStatusPill(
                                                    label:
                                                        entry.status.label.tr,
                                                    color: AssignmentControlStatusStyle
                                                            .of(entry.status)
                                                        .color,
                                                    icon: AssignmentControlStatusStyle
                                                            .of(entry.status)
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
                                    SizedBox(height: 8.h),
                                    if (widget.item.tab == MyAuditTab.pending)
                                      isSaving
                                          ? Align(
                                              alignment: Alignment.centerRight,
                                              child: GrcButtonLoadingPlaceholder(
                                                width: 120.w,
                                                height: 44.h,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                customButton(
                                                  title: 'Reject'.tr,
                                                  function: () =>
                                                      _onRejectPressed(context),
                                                  width: 120.w,
                                                  color: AppColors.red,
                                                  textStyle: StyleText
                                                      .fontSize16Weight500
                                                      .copyWith(
                                                          color: AppColors
                                                              .textButton),
                                                ),
                                                SizedBox(width: 12.w),
                                                customButton(
                                                  title: 'Approve'.tr,
                                                  function: () =>
                                                      _onApprovePressed(
                                                          context),
                                                  width: 120.w,
                                                  color: AppColors.primary,
                                                  textStyle: StyleText
                                                      .fontSize16Weight500
                                                      .copyWith(
                                                          color: AppColors
                                                              .textButton),
                                                ),
                                              ],
                                            )
                                    else
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GrcStatusPill(
                                          label: widget.item.tab.label.tr,
                                          color: style.color,
                                          icon: style.icon,
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

/// Read-only body for a derived-Overdue row: the Champion never submitted,
/// so there is no Assignment Control / My Audit data to show — just an
/// informational message.
class _OverdueBody extends StatelessWidget {
  final dynamic control;
  final dynamic policy;
  final bool isArabic;

  const _OverdueBody(
      {required this.control, required this.policy, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text('Policy Details'.tr, style: StyleText.fontSize16Weight600),
        SizedBox(height: 8.h),
        GrcSectionCard(children: [
          Text(
            isArabic
                ? policy.policyNameAr as String
                : policy.policyNameEn as String,
            style: StyleText.fontSize16Weight600,
          ),
        ]),
        SizedBox(height: 15.h),
        Text('Control Details'.tr, style: StyleText.fontSize16Weight600),
        SizedBox(height: 8.h),
        GrcSectionCard(children: [
          Text(
            isArabic
                ? control.controlsNameAr as String
                : control.controlsNameEn as String,
            style: StyleText.fontSize16Weight600,
          ),
        ]),
        SizedBox(height: 15.h),
        GrcSectionCard(children: [
          Text('No submission was made before the deadline'.tr,
              style: CardStyles.value(12)),
        ]),
      ],
    );
  }
}
