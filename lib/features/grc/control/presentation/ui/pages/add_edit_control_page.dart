/// Module: GRC Policy Management
/// Description: Full-page form for creating or editing a single standalone
///              Control under an existing Policy, opened from the Policy
///              Details page's Controls section.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter_bloc, PolicyCubit, ControlEntity, ControlStatus, get_it
/// Revision History: 2026-07-15 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: add_edit_control_page.dart
/// Purpose: Contains AddEditControlPage, the create/edit form for a single
///          Control. Enforces that this control's weight plus every sibling
///          control's weight sums to 100.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 15/7/2026

import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_preview_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';

/// class name: [AddEditControlPage]
///
/// purpose: full-page form to create a new Control or edit an existing one,
///          scoped to one Policy. Validates that this control's weight plus
///          every entry in [siblingControls] sums to exactly 100.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 15/7/2026
class AddEditControlPage extends StatefulWidget {
  final String moduleId;
  final String policyId;
  final List<ControlEntity> siblingControls;
  final ControlEntity? existingControl;

  const AddEditControlPage({
    super.key,
    required this.moduleId,
    required this.policyId,
    required this.siblingControls,
    this.existingControl,
  });

  @override
  State<AddEditControlPage> createState() => _AddEditControlPageState();
}

class _AddEditControlPageState extends State<AddEditControlPage> {
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _numberController = TextEditingController();
  final _numberArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _weightController = TextEditingController();

  String? _frequency;
  DateTime? _startDate;
  DateTime? _endDate;
  ControlStatus _status = ControlStatus.draft;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;
  bool _submitted = false;

  bool get _isEdit => widget.existingControl != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingControl;
    if (existing == null) return;
    _nameController.text = existing.controlsNameEn;
    _nameArController.text = existing.controlsNameAr;
    _numberController.text = existing.controlsNumberEn;
    _numberArController.text = existing.controlsNumberAr;
    _descriptionController.text = existing.controlsDescriptionEn;
    _descriptionArController.text = existing.controlsDescriptionAr;
    _weightController.text = existing.controlsWeight.toStringAsFixed(0);
    _frequency = existing.frequency.isEmpty ? null : existing.frequency;
    _startDate = existing.startDate;
    _endDate = existing.endDate;
    _status = existing.status;
    _documentEn = existing.controlsDocumentEn != null
        ? PolicyDocumentInfo.fromUrl(existing.controlsDocumentEn!)
        : null;
    _documentAr = existing.controlsDocumentAr != null
        ? PolicyDocumentInfo.fromUrl(existing.controlsDocumentAr!)
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _numberController.dispose();
    _numberArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  double get _siblingsWeight => widget.siblingControls
      .where((c) => c.id != widget.existingControl?.id)
      .fold<double>(0, (sum, c) => sum + c.controlsWeight);

  double get _thisWeight => double.tryParse(_weightController.text.trim()) ?? 0;

  bool _validate() {
    setState(() => _submitted = true);
    final endBeforeStart = _endDate != null &&
        _startDate != null &&
        _endDate!.isBefore(_startDate!);
    return _nameController.text.trim().isNotEmpty &&
        _nameArController.text.trim().isNotEmpty &&
        _numberController.text.trim().isNotEmpty &&
        _numberArController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _descriptionArController.text.trim().isNotEmpty &&
        !containsArabicLetters(_nameController.text) &&
        !containsEnglishLetters(_nameArController.text) &&
        !containsArabicLetters(_numberController.text) &&
        !containsEnglishLetters(_numberArController.text) &&
        !containsArabicLetters(_descriptionController.text) &&
        !containsEnglishLetters(_descriptionArController.text) &&
        _frequency != null &&
        _startDate != null &&
        _endDate != null &&
        !endBeforeStart &&
        double.tryParse(_weightController.text.trim()) != null;
  }

  void _onUploadDocumentEn() {
    showUploadDialog(
      context: context,
      dialogTitle: 'Upload Control Document (English)'.tr,
      titleFieldLabel: 'Document Title'.tr,
      titleFieldHint: 'Text here'.tr,
      browseLabel: 'Browse Files'.tr,
      submitLabel: 'Submit'.tr,
      discardLabel: 'Discard'.tr,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onSubmit: (file, title) {
        setState(() => _documentEn = PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  void _onUploadDocumentAr() {
    showUploadDialog(
      context: context,
      dialogTitle: 'رفع مستند الضابط (عربي)',
      titleFieldLabel: 'عنوان المستند',
      titleFieldHint: 'اكتب هنا',
      browseLabel: 'تصفح الملفات',
      submitLabel: 'إرسال',
      discardLabel: 'إلغاء',
      textDirection: TextDirection.rtl,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onSubmit: (file, title) {
        setState(() => _documentAr = PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  void _onRemoveDocumentEn() => setState(() => _documentEn = null);
  void _onRemoveDocumentAr() => setState(() => _documentAr = null);

  void _onSave(PolicyCubit cubit) {
    if (_isEdit) {
      cubit.updateControl(
        id: widget.existingControl!.id,
        moduleId: widget.moduleId,
        policyId: widget.policyId,
        controlsNameEn: _nameController.text.trim(),
        controlsNameAr: _nameArController.text.trim(),
        controlsNumberEn: _numberController.text.trim(),
        controlsNumberAr: _numberArController.text.trim(),
        controlsDescriptionEn: _descriptionController.text.trim(),
        controlsDescriptionAr: _descriptionArController.text.trim(),
        controlsWeight: _thisWeight,
        frequency: _frequency,
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
        controlsDocumentFileEn: _documentEn?.file,
        controlsDocumentUrlEn:
            _documentEn?.file == null ? _documentEn?.url : null,
        controlsDocumentFileAr: _documentAr?.file,
        controlsDocumentUrlAr:
            _documentAr?.file == null ? _documentAr?.url : null,
      );
    } else {
      cubit.createControl(
        moduleId: widget.moduleId,
        policyId: widget.policyId,
        controlsNameEn: _nameController.text.trim(),
        controlsNameAr: _nameArController.text.trim(),
        controlsNumberEn: _numberController.text.trim(),
        controlsNumberAr: _numberArController.text.trim(),
        controlsDescriptionEn: _descriptionController.text.trim(),
        controlsDescriptionAr: _descriptionArController.text.trim(),
        controlsWeight: _thisWeight,
        frequency: _frequency!,
        startDate: _startDate!,
        endDate: _endDate!,
        departments: const [],
        equalWeights: false,
        score: 0,
        status: _status,
        controlsDocumentFileEn: _documentEn?.file,
        controlsDocumentFileAr: _documentAr?.file,
      );
    }
  }

  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyControlActionSuccess) {
      showSuccessDialog(
        context: context,
        title: _isEdit ? 'Control Updated'.tr : 'Control Created'.tr,
        subtitle: _isEdit
            ? 'You successfully updated this control.'.tr
            : 'You successfully created this control.'.tr,
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is PolicyFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
      );
    }
  }

  Widget _documentButton({required VoidCallback onTap, required String title}) {
    return customButtonWithSvg(
      colorBorder: AppColors.primary,
      space: 10.w,
      radius: 8.r,
      widthImage: 16.w,
      heightImage: 16.h,
      function: onTap,
      title: title,
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
      image: 'assets/hrAsset/Upload.svg',
      color: AppColors.primary,
      width: 220.w,
      height: 36.h,
      svgColor: AppColors.textButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return BlocProvider(
      create: (_) => GetIt.instance<PolicyCubit>(),
      child: Builder(
        builder: (ctx) {
          final cubit = ctx.read<PolicyCubit>();
          return BlocListener<PolicyCubit, PolicyState>(
            listener: _onStateChange,
            child: Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaginationAppBar(
                        screensTitles: [
                          'GRC'.tr,
                          _isEdit ? 'Edit Control'.tr : 'Add Control'.tr,
                        ],
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15.sp),
                          decoration: BoxDecoration(
                            color: AppColors.field,
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isTablet
                                      ? Row(children: [
                                          Expanded(
                                            child: CustomTextField(
                                              label: 'Control Name'.tr,
                                              hint: 'Text here'.tr,
                                              controller: _nameController,
                                              required: true,
                                              submitted: _submitted,
                                              fillColor: AppColors.background,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: CustomTextField(
                                                label: 'اسم ضابط',
                                                hint: 'اكتب هنا',
                                                controller: _nameArController,
                                                required: true,
                                                submitted: _submitted,
                                                fillColor: AppColors.background,
                                                onChanged: (_) =>
                                                    setState(() {}),
                                              ),
                                            ),
                                          ),
                                        ])
                                      : Column(children: [
                                          CustomTextField(
                                            label: 'Control Name'.tr,
                                            hint: 'Text here'.tr,
                                            controller: _nameController,
                                            required: true,
                                            submitted: _submitted,
                                            fillColor: AppColors.background,
                                            onChanged: (_) => setState(() {}),
                                          ),
                                          SizedBox(height: 15.h),
                                          Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: CustomTextField(
                                              label: 'اسم ضابط',
                                              hint: 'اكتب هنا',
                                              controller: _nameArController,
                                              required: true,
                                              submitted: _submitted,
                                              fillColor: AppColors.background,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ]),
                                  SizedBox(height: 15.h),
                                  isTablet
                                      ? Row(children: [
                                          Expanded(
                                            child: CustomTextField(
                                              label: 'Control Number'.tr,
                                              hint: 'Text here'.tr,
                                              controller: _numberController,
                                              required: true,
                                              submitted: _submitted,
                                              fillColor: AppColors.background,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: CustomTextField(
                                                label: 'رقم ضابط',
                                                hint: 'اكتب هنا',
                                                controller: _numberArController,
                                                required: true,
                                                submitted: _submitted,
                                                fillColor: AppColors.background,
                                                onChanged: (_) =>
                                                    setState(() {}),
                                              ),
                                            ),
                                          ),
                                        ])
                                      : Column(children: [
                                          CustomTextField(
                                            label: 'Control Number'.tr,
                                            hint: 'Text here'.tr,
                                            controller: _numberController,
                                            required: true,
                                            submitted: _submitted,
                                            fillColor: AppColors.background,
                                            onChanged: (_) => setState(() {}),
                                          ),
                                          SizedBox(height: 15.h),
                                          Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: CustomTextField(
                                              label: 'رقم ضابط',
                                              hint: 'اكتب هنا',
                                              controller: _numberArController,
                                              required: true,
                                              submitted: _submitted,
                                              fillColor: AppColors.background,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ]),
                                  SizedBox(height: 15.h),
                                  CustomTextField(
                                    label: 'Control Description'.tr,
                                    hint: 'Text here'.tr,
                                    controller: _descriptionController,
                                    required: true,
                                    submitted: _submitted,
                                    maxLines: 3,
                                    minLines: 3,
                                    maxLength: 500,
                                    showCharCount: true,
                                    fillColor: AppColors.background,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  SizedBox(height: 15.h),
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: CustomTextField(
                                      label: 'وصف ضابط',
                                      hint: 'اكتب وصف',
                                      controller: _descriptionArController,
                                      required: true,
                                      submitted: _submitted,
                                      maxLines: 3,
                                      minLines: 3,
                                      maxLength: 500,
                                      showCharCount: true,
                                      fillColor: AppColors.background,
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                  isTablet
                                      ? Row(children: [
                                          Expanded(
                                            child: CustomDropdownCalendar(
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                              label: 'Start Date'.tr,
                                              hint: 'Select Start Date'.tr,
                                              value: _startDate,
                                              onChanged: (d) => setState(
                                                  () => _startDate = d),
                                              fillColor: AppColors.background,
                                              errorText: _submitted &&
                                                      _startDate == null
                                                  ? 'This field is required.'.tr
                                                  : null,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: CustomDropdownCalendar(
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                              label: 'End Date'.tr,
                                              hint: 'Select End Date'.tr,
                                              value: _endDate,
                                              onChanged: (d) =>
                                                  setState(() => _endDate = d),
                                              fillColor: AppColors.background,
                                              firstDate: _startDate,
                                              errorText: _submitted &&
                                                      _endDate == null
                                                  ? 'This field is required.'.tr
                                                  : (_endDate != null &&
                                                          _startDate != null &&
                                                          _endDate!.isBefore(
                                                              _startDate!)
                                                      ? 'End date cannot be before start date.'
                                                          .tr
                                                      : null),
                                            ),
                                          ),
                                        ])
                                      : Column(children: [
                                          CustomDropdownCalendar(
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                            label: 'Start Date'.tr,
                                            hint: 'Select Start Date'.tr,
                                            value: _startDate,
                                            onChanged: (d) =>
                                                setState(() => _startDate = d),
                                            fillColor: AppColors.background,
                                            errorText: _submitted &&
                                                    _startDate == null
                                                ? 'This field is required.'.tr
                                                : null,
                                          ),
                                          SizedBox(height: 15.h),
                                          CustomDropdownCalendar(
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                            label: 'End Date'.tr,
                                            hint: 'Select End Date'.tr,
                                            value: _endDate,
                                            onChanged: (d) =>
                                                setState(() => _endDate = d),
                                            fillColor: AppColors.background,
                                            firstDate: _startDate,
                                            errorText: _submitted &&
                                                    _endDate == null
                                                ? 'This field is required.'.tr
                                                : (_endDate != null &&
                                                        _startDate != null &&
                                                        _endDate!.isBefore(
                                                            _startDate!)
                                                    ? 'End date cannot be before start date.'
                                                        .tr
                                                    : null),
                                          ),
                                        ]),
                                  SizedBox(height: 15.h),
                                  isTablet
                                      ? Row(children: [
                                          Expanded(
                                            child: CustomDropdown<String>(
                                              label: 'Frequency'.tr,
                                              hint: 'Choose Here'.tr,
                                              items: const [
                                                'Weekly',
                                                'Bi weekly',
                                                'Monthly',
                                                'Quarterly',
                                                'Semi Annual',
                                                'Annually',
                                              ]
                                                  .map((d) =>
                                                      DropdownItem<String>(
                                                          value: d, label: d))
                                                  .toList(),
                                              value: _frequency,
                                              onChanged: (v) => setState(
                                                  () => _frequency = v),
                                              fillColor: AppColors.background,
                                              errorText: _submitted &&
                                                      _frequency == null
                                                  ? 'This field is required.'.tr
                                                  : null,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: CustomTextField(
                                              label: 'Control Weight'.tr,
                                              hint: 'Text Here'.tr,
                                              controller: _weightController,
                                              required: true,
                                              submitted: _submitted,
                                              fillColor: AppColors.background,
                                              // errorText: _submitted &&
                                              //         double.tryParse(
                                              //                 _weightController
                                              //                     .text
                                              //                     .trim()) !=
                                              //             null &&
                                              //         !_isWeightValid
                                              //     ? '${'All controls under this policy must add up to 100 (currently'.tr} ${(_thisWeight + _siblingsWeight).toStringAsFixed(0)}).'
                                              //     : null,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ])
                                      : Column(children: [
                                          CustomDropdown<String>(
                                            label: 'Frequency'.tr,
                                            hint: 'Choose Here'.tr,
                                            items: const [
                                              'Weekly',
                                              'Bi weekly',
                                              'Monthly',
                                              'Quarterly',
                                              'Semi Annual',
                                              'Annually',
                                            ]
                                                .map((d) =>
                                                    DropdownItem<String>(
                                                        value: d, label: d))
                                                .toList(),
                                            value: _frequency,
                                            onChanged: (v) =>
                                                setState(() => _frequency = v),
                                            fillColor: AppColors.background,
                                            errorText: _submitted &&
                                                    _frequency == null
                                                ? 'This field is required.'.tr
                                                : null,
                                          ),
                                          SizedBox(height: 15.h),
                                          CustomTextField(
                                            label: 'Control Weight'.tr,
                                            hint: 'Text Here'.tr,
                                            controller: _weightController,
                                            required: true,
                                            submitted: _submitted,
                                            fillColor: AppColors.background,
                                            // errorText: _submitted &&
                                            //         double.tryParse(
                                            //                 _weightController
                                            //                     .text
                                            //                     .trim()) !=
                                            //             null &&
                                            //         !_isWeightValid
                                            //     ? '${'All controls under this policy must add up to 100 (currently'.tr} ${(_thisWeight + _siblingsWeight).toStringAsFixed(0)}).'
                                            //     : null,
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ]),
                                  SizedBox(height: 15.h),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Control Document'.tr,
                                          style: StyleText.fontSize16Weight500
                                              .copyWith(color: AppColors.text)),
                                      const Spacer(),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            _documentEn != null
                                                ? PolicyDocumentPreviewWidget(
                                                    document: _documentEn!,
                                                    onRemove:
                                                        _onRemoveDocumentEn)
                                                : _documentButton(
                                                    onTap: _onUploadDocumentEn,
                                                    title:
                                                        'Upload Document'.tr),
                                            SizedBox(height: 10.h),
                                            _documentAr != null
                                                ? PolicyDocumentPreviewWidget(
                                                    document: _documentAr!,
                                                    onRemove:
                                                        _onRemoveDocumentAr)
                                                : _documentButton(
                                                    onTap: _onUploadDocumentAr,
                                                    title: ' Upload Document'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customButton(
                            title: 'Discard'.tr,
                            function: () => Navigator.of(context).pop(),
                            height: 38.h,
                            width: 150.w,
                            color: AppColors.grey,
                            textColor: AppColors.text,
                            borderColor: AppColors.border,
                          ),
                          customButton(
                            title: _isEdit ? 'Save'.tr : 'Add'.tr,
                            function: () {
                              // if (!_validate()) return;
                              showConfirmDialog(
                                context: context,
                                title: _isEdit
                                    ? 'Editing Control'.tr
                                    : 'Creating Control'.tr,
                                cancelLabel: 'No'.tr,
                                confirmLabel: 'Yes'.tr,
                                subtitle: _isEdit
                                    ? 'Are You Sure You Want To Edit This Control ?'
                                        .tr
                                    : 'Are You Sure You Want To Create This Control ?'
                                        .tr,
                                onConfirm: () => _onSave(cubit),
                              );
                            },
                            height: 38.h,
                            width: 150.w,
                            color: AppColors.primary,
                            textColor: AppColors.textButton,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
