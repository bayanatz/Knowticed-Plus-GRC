import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/21-custom_contact_card.dart';
import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_item.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';

final DateFormat _cardDateFormat = DateFormat('d MMM yyyy');

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

  bool get _isRejected => widget.item.tab == AssignmentControlTab.rejected;

  bool get _canAct =>
      widget.item.tab == AssignmentControlTab.pending ||
      widget.item.tab == AssignmentControlTab.overdue ||
      _isRejected;

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

  Widget _ownerRow(BuildContext context, String? email) {
    if (email == null || email.isEmpty) return const SizedBox.shrink();
    final employee = findEmployeeByEmail(email);
    final name = employeeDisplayName(context, email);
    final photo = employee.displayPhoto;
    return ContactCard(
      name: name,
      avatar: photo.startsWith('http') ? NetworkImage(photo) : null,
      onMessage: () {},
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

  Widget _labelValueRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: CardStyles.label(12)),
        Expanded(child: Text(value, style: CardStyles.value(12))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.item.control;
    final policy = widget.item.policy;
    final assignment = widget.item.assignment;
    final isArabic = context.isArabic;
    final moduleOwnerEmail =
        widget.module.moduleOwners.isNotEmpty ? widget.module.moduleOwners.first : null;
    final policyDocument = isArabic ? policy.policyDocumentAr : policy.policyDocumentEn;
    final rejectionReason = (assignment?.departmentManagerRejectionReason
                ?.isNotEmpty ==
            true)
        ? assignment!.departmentManagerRejectionReason
        : assignment?.controlOwnerRejectionReason;

    return BlocConsumer<AssignmentControlCubit, AssignmentControlState>(
      listener: (context, state) {
        if (state is AssignmentControlActionSuccess) {
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
                          Text('Policy Description'.tr, style: CardStyles.label(12)),
                          SizedBox(height: 4.h),
                          Text(
                            isArabic
                                ? policy.policyDescriptionAr
                                : policy.policyDescriptionEn,
                            style: CardStyles.value(12),
                          ),
                          SizedBox(height: 12.h),
                          if (moduleOwnerEmail != null) ...[
                            Text('Module Owner'.tr, style: CardStyles.label(12)),
                            SizedBox(height: 4.h),
                            _ownerRow(context, moduleOwnerEmail),
                            SizedBox(height: 12.h),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: _labelValueRow('Policy Weight'.tr,
                                    policy.policyWeight.toString()),
                              ),
                              Expanded(
                                child: _labelValueRow(
                                  'Policy Number'.tr,
                                  isArabic ? policy.policyNumberAr : policy.policyNumberEn,
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
                                    _labelValueRow('Start Date'.tr,
                                        _cardDateFormat.format(policy.startDate)),
                                    SizedBox(height: 4.h),
                                    _labelValueRow('End Date'.tr,
                                        _cardDateFormat.format(policy.endDate)),
                                  ],
                                ),
                              ),
                              if (policyDocument != null && policyDocument.isNotEmpty)
                                ProductWarrantyCard(
                                  fileName:
                                      policyDocument.split('/').last.split('?').first,
                                  onTapFile: () {},
                                ),
                            ],
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
                          SizedBox(height: 12.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _labelValueRow(
                                  'Control Weight'.tr,
                                  control.controlsWeight.toString(),
                                ),
                              ),
                              if (widget.item.ownerEmail != null)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Control Owner'.tr, style: CardStyles.label(12)),
                                      SizedBox(height: 4.h),
                                      _ownerRow(context, widget.item.ownerEmail),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Submissions'.tr, style: StyleText.fontSize16Weight600),
                            _SubmissionsSubTabs(
                              selected: _submissionsTab,
                              onChanged: (i) => setState(() => _submissionsTab = i),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        if (_submissionsTab == 1)
                          _sectionCard(children: [
                            Text('Inquiries coming soon'.tr, style: CardStyles.value(12)),
                          ])
                        else
                          _sectionCard(children: [
                            if (assignment == null)
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.cloud_upload_outlined,
                                        size: 48.sp, color: AppColors.text.withOpacity(0.4)),
                                    SizedBox(height: 8.h),
                                  ],
                                ),
                              )
                            else ...[
                              Text(
                                '${'Submission Date'.tr}: ${_cardDateFormat.format(assignment.lastModificationDate)}',
                                style: CardStyles.label(12),
                              ),
                              SizedBox(height: 8.h),
                              if (assignment.submissionDocument.isNotEmpty)
                                ProductWarrantyCard(
                                  fileName: assignment.submissionDocument
                                      .split('/')
                                      .last
                                      .split('?')
                                      .first,
                                  onTapFile: () {},
                                ),
                              SizedBox(height: 8.h),
                              if (assignment.submissionNote.isNotEmpty) ...[
                                Text('Submission Notes'.tr, style: CardStyles.label(12)),
                                SizedBox(height: 4.h),
                                Text(assignment.submissionNote, style: CardStyles.value(12)),
                                SizedBox(height: 8.h),
                              ],
                              if (rejectionReason != null && rejectionReason.isNotEmpty) ...[
                                Text(
                                  'Reasons of Rejection'.tr,
                                  style: CardStyles.label(12).copyWith(color: Colors.red),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  rejectionReason,
                                  style: CardStyles.value(12).copyWith(color: Colors.red),
                                ),
                                SizedBox(height: 8.h),
                              ],
                            ],
                            SizedBox(height: 8.h),
                            if (_canAct)
                              customButton(
                                title: _actionLabel.tr,
                                function:
                                    isSaving ? () {} : () => _onActionPressed(context),
                                width: double.infinity,
                                height: 44.h,
                                color: AppColors.primary,
                                textStyle: StyleText.fontSize16Weight500
                                    .copyWith(color: AppColors.textButton),
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

/// "Submission | Inquires" toggle shown at the top-right of the Submissions
/// section. Inquires is a placeholder — the full comment-thread feature is a
/// separate, future spec.
class _SubmissionsSubTabs extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _SubmissionsSubTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, int index) {
      final isSelected = selected == index;
      return InkWell(
        onTap: () => onChanged(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : null,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            label,
            style: StyleText.fontSize12Weight400.copyWith(
              color: isSelected ? AppColors.textButton : AppColors.text,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        tab('Submission'.tr, 0),
        SizedBox(width: 8.w),
        tab('Inquires'.tr, 1),
      ],
    );
  }
}
