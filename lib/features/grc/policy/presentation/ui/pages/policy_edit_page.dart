/// Module: GRC Policy Management
/// Description: Full-page form for editing an existing Policy, opened from
///              the Policy Details page's Edit action. Mirrors the
///              AddEditControlPage pattern: its own route, its own
///              [PolicyCubit] instance, pops `true` on a successful save so
///              the Details page can refresh.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-18
/// Dependencies: flutter_bloc, PolicyCubit, PolicyEntity, get_it,
///               PolicyEditModeWidget
/// Revision History: 2026-07-18 - Split out of policy_details_page.dart's
///                                in-place edit mode into its own page.
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_edit_page.dart
/// Purpose: Contains PolicyEditPage, the full-page edit form for a single
///          Policy.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 18/7/2026

import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_edit_mode_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';

/// class name: [PolicyEditPage]
///
/// purpose: full-page form to edit an existing Policy's fields and its
///          Active/Inactive status. Prefills every field from [policy] on
///          open; pops `true` after a successful save so the caller can
///          refresh its own copy of the policy.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 18/7/2026
class PolicyEditPage extends StatefulWidget {
  final String moduleId;
  final PolicyEntity policy;

  const PolicyEditPage({
    super.key,
    required this.moduleId,
    required this.policy,
  });

  @override
  State<PolicyEditPage> createState() => _PolicyEditPageState();
}

class _PolicyEditPageState extends State<PolicyEditPage> {
  bool _submitted = false;

  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _numberController = TextEditingController();
  final _numberArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;
  bool _statusInactive = false;
  bool _initialStatusInactive = false;

  @override
  void initState() {
    super.initState();
    final policy = widget.policy;
    _nameController.text = policy.policyNameEn;
    _nameArController.text = policy.policyNameAr;
    _numberController.text = policy.policyNumberEn;
    _numberArController.text = policy.policyNumberAr;
    _descriptionController.text = policy.policyDescriptionEn;
    _descriptionArController.text = policy.policyDescriptionAr;
    _weightController.text = policy.policyWeight.toStringAsFixed(0);
    _startDate = policy.startDate;
    _endDate = policy.endDate;
    _documentEn = policy.policyDocumentEn != null
        ? PolicyDocumentInfo.fromUrl(policy.policyDocumentEn!)
        : null;
    _documentAr = policy.policyDocumentAr != null
        ? PolicyDocumentInfo.fromUrl(policy.policyDocumentAr!)
        : null;
    _statusInactive = policy.status == PolicyStatus.inactive;
    _initialStatusInactive = _statusInactive;
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

  bool _validate() {
    setState(() => _submitted = true);
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
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
        _startDate != null &&
        !_startDate!.isBefore(startOfToday) &&
        _endDate != null &&
        !endBeforeStart &&
        double.tryParse(_weightController.text.trim()) != null;
  }

  void _onUploadDocumentEn() {
    showUploadDialog(
      context: context,
      dialogTitle: 'Upload Policy Document (English)'.tr,
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
      dialogTitle: 'رفع مستند السياسة (عربي)',
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

  // Removing only clears the pending replacement shown on screen — the
  // update API has no explicit "clear stored document" signal, so if the
  // user removes without picking a replacement, Save keeps the original.
  void _onRemoveDocumentEn() => setState(() => _documentEn = null);
  void _onRemoveDocumentAr() => setState(() => _documentAr = null);

  /// function name: [_statusOverride]
  ///
  /// purpose: only the "Inactive" toggle can change a Policy's status from
  ///          this page, and only when the user actually flips it — a plain
  ///          field edit must never silently overwrite Draft/Scheduled/
  ///          Expired/Active with a stale literal status. Returns null
  ///          (leave status untouched) unless the toggle moved since load.
  PolicyStatus? _statusOverride() {
    if (_statusInactive == _initialStatusInactive) return null;
    return _statusInactive ? PolicyStatus.inactive : PolicyStatus.active;
  }

  void _onSave(PolicyCubit cubit) {
    cubit.updatePolicy(
      id: widget.policy.id,
      moduleId: widget.moduleId,
      status: _statusOverride(),
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      policyWeight: double.tryParse(_weightController.text.trim()),
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentUrlEn: _documentEn?.file == null ? _documentEn?.url : null,
      policyDocumentFileAr: _documentAr?.file,
      policyDocumentUrlAr: _documentAr?.file == null ? _documentAr?.url : null,
    );
  }

  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyActionSuccess) {
      showSuccessDialog(
        context: context,
        title: 'Policy Updated'.tr,
        subtitle: 'You successfully updated this policy.'.tr,
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

  Widget _buildBottomButtons(PolicyCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: 'Discard Changes'.tr,
          function: () => Navigator.of(context).pop(),
          height: 38.h,
          width: 150.w,
          color: AppColors.grey,
          textColor: AppColors.text,
          borderColor: AppColors.border,
        ),
        customButton(
          title: 'Save'.tr,
          function: () {
            if (!_validate()) return;
            showConfirmDialog(
              context: context,
              title: 'Editing Policy'.tr,
              cancelLabel: 'No'.tr,
              confirmLabel: 'Yes'.tr,
              subtitle: 'Are You Sure You Want To Edit This Policy ?'.tr,
              onConfirm: () => _onSave(cubit),
            );
          },
          height: 38.h,
          width: 150.w,
          color: AppColors.primary,
          textColor: AppColors.textButton,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        screensTitles: ['GRC'.tr, 'Edit Policy'.tr],
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
                              child: PolicyEditModeWidget(
                                statusInactive: _statusInactive,
                                onStatusToggle: (v) =>
                                    setState(() => _statusInactive = v),
                                submitted: _submitted,
                                nameController: _nameController,
                                nameArController: _nameArController,
                                numberController: _numberController,
                                numberArController: _numberArController,
                                descriptionController: _descriptionController,
                                descriptionArController:
                                    _descriptionArController,
                                weightController: _weightController,
                                startDate: _startDate,
                                endDate: _endDate,
                                onStartDateChanged: (d) =>
                                    setState(() => _startDate = d),
                                onEndDateChanged: (d) =>
                                    setState(() => _endDate = d),
                                documentEn: _documentEn,
                                documentAr: _documentAr,
                                onUploadDocumentEn: _onUploadDocumentEn,
                                onUploadDocumentAr: _onUploadDocumentAr,
                                onRemoveDocumentEn: _onRemoveDocumentEn,
                                onRemoveDocumentAr: _onRemoveDocumentAr,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildBottomButtons(cubit),
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
