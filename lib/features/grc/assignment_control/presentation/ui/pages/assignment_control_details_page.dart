import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_item.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_document_launcher.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_contact_inline_row.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_label_value_row.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_score_badge.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_section_card.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_section_sub_tabs.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_status_pill.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_submitter_row.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';

final DateFormat _cardDateFormat = DateFormat('d MMM yyyy');
final DateFormat _cardTimeFormat = DateFormat('h:mm a');

class AssignmentControlDetailsPage extends StatefulWidget {
  final AssignmentControlItem item;
  final GRCModuleEntity module;

  const AssignmentControlDetailsPage({
    super.key,
    required this.item,
    required this.module,
  });

  @override
  State<AssignmentControlDetailsPage> createState() =>
      _AssignmentControlDetailsPageState();
}

class _AssignmentControlDetailsPageState
    extends State<AssignmentControlDetailsPage> {
  int _submissionsTab = 0; // 0 = Submission, 1 = Inquires
  late final SubmissionHistoryCubit _historyCubit;

  @override
  void initState() {
    super.initState();
    _historyCubit = GetIt.instance<SubmissionHistoryCubit>();
    final assignment = widget.item.assignment;
    if (assignment != null) {
      _historyCubit.loadHistory(
        moduleId: widget.module.moduleId,
        controlId: widget.item.control.id,
        championEmail: assignment.controlChampionEmail,
      );
    }
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }

  bool get _isRejected => widget.item.tab == AssignmentControlTab.rejected;

  String get _actionLabel {
    if (_isRejected) return 'Resubmit Evidence';
    return 'Upload Evidence';
  }

  void _onActionPressed(BuildContext context) {
    showUploadDialog(
      context: context,
      dialogTitle: _actionLabel.tr,
      titleFieldLabel: 'Submission Note'.tr,
      titleFieldHint: 'Text here'.tr,
      submitLabel: 'Submit'.tr,
      onSubmit: (file, note) => _confirmSubmit(context, file, note),
    );
  }

  void _confirmSubmit(BuildContext context, PlatformFile file, String note) {
    if (file.path == null) {
      showErrorDialog(
        context: context,
        subtitle: 'Could not read the selected file. Please try again.'.tr,
      );
      return;
    }
    final cubit = context.read<AssignmentControlCubit>();
    showConfirmDialog(
      context: context,
      title: 'Submit Evidence'.tr,
      subtitle: 'Are you sure you want to submit this evidence?'.tr,
      confirmLabel: 'Submit'.tr,
      cancelLabel: 'Cancel'.tr,
      onConfirm: () => cubit.submitEvidence(
        moduleId: widget.module.moduleId,
        policyId: widget.item.control.policyId,
        controlId: widget.item.control.id,
        championEmail: currentGrcUserEmail(),
        documentFile: File(file.path!),
        note: note,
      ),
    );
  }

  /// The Upload/Resubmit Evidence button, replaced with a small spinner
  /// while a submit is in flight so the user gets clear loading feedback.
  Widget _submitButton(BuildContext context, bool isSaving) {
    if (isSaving) {
      return SizedBox(
        width: 180.w,
        height: 44.h,
        child: Center(
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: 180.w,
      child: customButtonWithSvg(
        title: _actionLabel.tr,
        function: () => _onActionPressed(context),
        textStyle:
            StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
        color: AppColors.primary,
        image: 'assets/icons_assets/data_grc_assets/upload_minimalistic.svg',
        widthImage: 18.r,
        heightImage: 18.r,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.item.control;
    final policy = widget.item.policy;
    final assignment = widget.item.assignment;
    final isArabic = context.isArabic;
    final moduleOwnerEmail = widget.module.moduleOwners.isNotEmpty
        ? widget.module.moduleOwners.first
        : null;
    final policyDocument =
        isArabic ? policy.policyDocumentAr : policy.policyDocumentEn;
    final rejectionReason =
        (assignment?.departmentManagerRejectionReason?.isNotEmpty == true)
            ? assignment!.departmentManagerRejectionReason
            : assignment?.controlOwnerRejectionReason;

    return BlocConsumer<AssignmentControlCubit, AssignmentControlState>(
      listener: (context, state) {
        if (state is AssignmentControlActionSuccess) {
          // Refresh the shared list cubit now so the list page (already
          // underneath us) shows the new status/tab counts by the time we
          // pop back to it, instead of the stale pre-submit snapshot.
          context.read<AssignmentControlCubit>().getMyAssignmentControls(
                moduleId: widget.module.moduleId,
                championEmail: currentGrcUserEmail(),
              );
          showSuccessDialog(
            context: context,
            title: 'Evidence Submitted'.tr,
            subtitle: 'Your evidence was submitted successfully'.tr,
          );
          Navigator.pop(context);
        } else if (state is AssignmentControlFailure) {
          showErrorDialog(context: context, subtitle: state.message);
        }
      },
      builder: (context, state) {
        final isSaving = state is AssignmentControlLoading;
        final style = AssignmentControlTabStyle.of(widget.item.tab);
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
                      'Assignment Controls'.tr,
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
                                label: 'Module Owner'.tr, email: moduleOwnerEmail),
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
                                  onTapFile: () => openGrcDocument(policyDocument),
                                ),
                            ],
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Text('Control Details'.tr,
                            style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        GrcSectionCard(children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isArabic
                                      ? control.controlsNameAr
                                      : control.controlsNameEn,
                                  style: StyleText.fontSize16Weight600,
                                ),
                              ),
                              if (assignment?.controlScore != null)
                                GrcScoreBadge(score: assignment!.controlScore!),
                            ],
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
                                child: GrcLabelValueRow(
                                  'Control Weight'.tr,
                                  control.controlsWeight.toString(),
                                ),
                              ),
                              if (widget.item.ownerEmail != null)
                                GrcContactInlineRow(
                                    label: 'Control Owner'.tr,
                                    email: widget.item.ownerEmail),
                            ],
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Submissions'.tr,
                                style: StyleText.fontSize16Weight600),
                            GrcSectionSubTabs(
                              labels: ['Submission'.tr, 'Inquires'.tr],
                              selected: _submissionsTab,
                              onChanged: (i) =>
                                  setState(() => _submissionsTab = i),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        if (_submissionsTab == 1)
                          GrcSectionCard(children: [
                            Text('Inquiries coming soon'.tr,
                                style: CardStyles.value(12)),
                          ])
                        else
                          GrcSectionCard(children: [
                            if (assignment == null) ...[
                              SizedBox(height: 20.h),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons_assets/qiyas_assets/cloud_upload.svg',
                                      width: 56.w,
                                      height: 56.h,
                                      colorFilter: ColorFilter.mode(
                                          AppColors.text.withValues(alpha: 0.4),
                                          BlendMode.srcIn),
                                    ),
                                    SizedBox(height: 16.h),
                                    _submitButton(context, isSaving),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ] else ...[
                              BlocBuilder<SubmissionHistoryCubit,
                                  SubmissionHistoryState>(
                                bloc: _historyCubit,
                                builder: (context, historyState) {
                                  if (historyState
                                      is SubmissionHistoryFailure) {
                                    return Text(
                                      historyState.message,
                                      style: CardStyles.value(12)
                                          .copyWith(color: Colors.red),
                                    );
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
                                      for (final entry in entries) ...[
                                        GrcSectionCard(children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GrcSubmitterRow(
                                                  email: assignment
                                                      .controlChampionEmail),
                                              Text(
                                                '${'Submission Date'.tr}: '
                                                '${_cardDateFormat.format(entry.submittedDate)} '
                                                '${'At'.tr} '
                                                '${_cardTimeFormat.format(entry.submittedDate)}',
                                                style: CardStyles.label(12),
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
                                                  openGrcDocument(entry.document),
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
                                            alignment: Alignment.centerRight,
                                            child: GrcStatusPill(
                                              label: entry.status.label.tr,
                                              color:
                                                  AssignmentControlStatusStyle
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
                              if (_isRejected)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _submitButton(context, isSaving),
                                    GrcStatusPill(
                                      label: widget.item.tab.label.tr,
                                      color: style.color,
                                      icon: style.icon,
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
