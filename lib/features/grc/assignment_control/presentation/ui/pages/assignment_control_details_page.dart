import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
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
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
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

  /// Compact "Label: [avatar] Name [Message]" row used inline inside the
  /// Policy/Control Details cards — deliberately not the full ContactCard
  /// widget, which renders as its own bordered/shadowed card and doesn't
  /// match the flat inline look these two cards need.
  Widget _ownerInlineRow(BuildContext context, String label, String? email) {
    if (email == null || email.isEmpty) return const SizedBox.shrink();
    final employee = findEmployeeByEmail(email);
    final name = employeeDisplayName(context, email);
    final photo = employee.displayPhoto;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: CardStyles.label(12)),
        CircleAvatar(
          radius: 16.r,
          backgroundColor: AppColors.barrierColor,
          backgroundImage:
              photo.startsWith('http') ? NetworkImage(photo) : null,
        ),
        SizedBox(width: 8.w),
        Text(name, style: CardStyles.value(12)),
        SizedBox(width: 16.w),
        customButtonWithSvg(
          title: 'Message'.tr,
          function: () {},
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
          color: AppColors.primary,
          image: CardSvg.message,
          widthImage: 18.r,
          heightImage: 18.r,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton,
        ),
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
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _labelValueRow(String label, String value, {Color? color}) {
    return Row(
      children: [
        Text('$label: ', style: CardStyles.label(12).copyWith(color: color)),
        Expanded(
          child:
              Text(value, style: CardStyles.value(12).copyWith(color: color)),
        ),
      ],
    );
  }

  /// Avatar + name + job title for whoever last touched this submission
  /// ([AssignmentControlEntity.lastModifier]'s email).
  Widget _submitterRow(BuildContext context, String email) {
    final employee = findEmployeeByEmail(email);
    final name = employeeDisplayName(context, email);
    final role = employee.localizedJobTitle(context);
    final photo = employee.displayPhoto;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: AppColors.barrierColor,
          backgroundImage:
              photo.startsWith('http') ? NetworkImage(photo) : null,
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: CardStyles.value(14)),
            if (role.isNotEmpty) Text(role, style: CardStyles.label(12)),
          ],
        ),
      ],
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

  /// Bordered, colored pill showing [tab]'s status (icon + label), matching
  /// the status pill already used on the list page's cards.
  Widget _statusPill(AssignmentControlTab tab) {
    final style = AssignmentControlTabStyle.of(tab);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: style.color),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 16.sp, color: style.color),
          SizedBox(width: 6.w),
          Text(tab.label.tr,
              style: CardStyles.value(14).copyWith(color: style.color)),
        ],
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
                        _sectionCard(children: [
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
                            _ownerInlineRow(
                                context, 'Module Owner'.tr, moduleOwnerEmail),
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
                                    _labelValueRow(
                                        'Start Date'.tr,
                                        _cardDateFormat
                                            .format(policy.startDate)),
                                    SizedBox(height: 4.h),
                                    _labelValueRow('End Date'.tr,
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
                                  onTapFile: () {},
                                ),
                            ],
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Text('Control Details'.tr,
                            style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        _sectionCard(children: [
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
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${'Score'.tr}: ',
                                          style: CardStyles.label(12)),
                                      Text(
                                        assignment!.controlScore!
                                            .toInt()
                                            .toString(),
                                        style: CardStyles.value(12)
                                            .copyWith(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
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
                                _ownerInlineRow(context, 'Control Owner'.tr,
                                    widget.item.ownerEmail),
                            ],
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Submissions'.tr,
                                style: StyleText.fontSize16Weight600),
                            _SubmissionsSubTabs(
                              selected: _submissionsTab,
                              onChanged: (i) =>
                                  setState(() => _submissionsTab = i),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        if (_submissionsTab == 1)
                          _sectionCard(children: [
                            Text('Inquiries coming soon'.tr,
                                style: CardStyles.value(12)),
                          ])
                        else
                          _sectionCard(children: [
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
                                          AppColors.text.withOpacity(0.4),
                                          BlendMode.srcIn),
                                    ),
                                    SizedBox(height: 16.h),
                                    _submitButton(context, isSaving),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ] else ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _submitterRow(
                                      context, assignment.lastModifier),
                                  Text(
                                    '${'Submission Date'.tr}: '
                                    '${_cardDateFormat.format(assignment.lastModificationDate)} '
                                    '${'At'.tr} '
                                    '${_cardTimeFormat.format(assignment.lastModificationDate)}',
                                    style: CardStyles.label(12),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              if (assignment.submissionDocument.isNotEmpty)
                                ProductWarrantyCard(
                                  fileName: assignment.submissionDocument
                                      .split('/')
                                      .last
                                      .split('?')
                                      .first,
                                  onTapFile: () {},
                                ),
                              SizedBox(height: 12.h),
                              if (assignment.submissionNote.isNotEmpty) ...[
                                _labelValueRow('Submission Notes'.tr,
                                    assignment.submissionNote),
                                SizedBox(height: 12.h),
                              ],
                              if (rejectionReason != null &&
                                  rejectionReason.isNotEmpty) ...[
                                _labelValueRow(
                                  'Reasons of Rejection'.tr,
                                  rejectionReason,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 12.h),
                              ],
                              if (_isRejected)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _submitButton(context, isSaving),
                                    _statusPill(widget.item.tab),
                                  ],
                                )
                              else
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _statusPill(widget.item.tab),
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
