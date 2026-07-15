/// Module: GRC Policy Management
/// Description: Details page for a single Policy — view its fields, edit
///              them in place, and delete the Policy (soft-delete). Task 5
///              extends this file to add the Controls section.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter_bloc, PolicyCubit, PolicyEntity, GRCModuleEntity,
///               get_it
/// Revision History: 2026-07-15 - Initial creation (Policy view/edit/delete)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_details_page.dart
/// Purpose: Contains PolicyDetailsPage, the read/edit/delete details screen
///          for a single Policy, opened by tapping a policy card on the GRC
///          Module details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 15/7/2026

import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/add_edit_control_page.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/control_card_widget.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_preview_widget.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' hide TextDirection;

enum _PolicyPageMode { view, edit }

/// class name: [PolicyDetailsPage]
///
/// purpose: entry-point widget for the Policy Details screen. Provides a
///          [PolicyCubit] and fetches [policyId] fresh from Firestore so the
///          page always reflects the latest saved state.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 15/7/2026
class PolicyDetailsPage extends StatelessWidget {
  final String policyId;
  final String moduleId;
  final GRCModuleEntity module;

  const PolicyDetailsPage({
    super.key,
    required this.policyId,
    required this.moduleId,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<PolicyCubit>(),
      child: _PolicyDetailsBody(
        policyId: policyId,
        moduleId: moduleId,
        module: module,
      ),
    );
  }
}

class _PolicyDetailsBody extends StatefulWidget {
  final String policyId;
  final String moduleId;
  final GRCModuleEntity module;

  const _PolicyDetailsBody({
    required this.policyId,
    required this.moduleId,
    required this.module,
  });

  @override
  State<_PolicyDetailsBody> createState() => _PolicyDetailsBodyState();
}

class _PolicyDetailsBodyState extends State<_PolicyDetailsBody> {
  PolicyEntity? _policy;
  _PolicyPageMode _mode = _PolicyPageMode.view;
  bool _submitted = false;
  bool _pendingDelete = false;

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

  List<ControlEntity> _controls = [];
  String _selectedControlStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final cubit = context.read<PolicyCubit>();
    await cubit.getPolicy(widget.policyId, moduleId: widget.moduleId);
    await cubit.getAllControls(
      moduleId: widget.moduleId,
      policyId: widget.policyId,
    );
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

  void _prefillControllers(PolicyEntity policy) {
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

  void _onSave(PolicyCubit cubit) {
    cubit.updatePolicy(
      id: _policy!.id,
      moduleId: widget.moduleId,
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

  void _onDelete(PolicyCubit cubit) {
    _pendingDelete = true;
    cubit.deletePolicy(id: _policy!.id, moduleId: widget.moduleId);
  }

  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      if (_policy != null) showLoadingIndicator();
      return;
    }
    if (_policy != null) hideLoadingIndicator();

    if (state is PolicySingleLoaded) {
      setState(() => _policy = state.policy);
      return;
    }

    if (state is PolicyControlsListLoaded) {
      setState(() => _controls = state.controls);
      return;
    }

    if (state is PolicyActionSuccess) {
      if (_pendingDelete) {
        showSuccessDialog(
          context: context,
          title: 'Policy Deleted'.tr,
          subtitle: 'You successfully deleted this policy.'.tr,
        );
        Navigator.of(context).pop(true);
        return;
      }
      showSuccessDialog(
        context: context,
        title: 'Policy Updated'.tr,
        subtitle: 'You successfully updated this policy.'.tr,
      );
      setState(() {
        _policy = state.policy;
        _mode = _PolicyPageMode.view;
        _submitted = false;
      });
      return;
    }

    if (state is PolicyFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
      );
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text.rich(
        TextSpan(
          text: '$label ',
          style: CardStyles.label(14),
          children: [TextSpan(text: value, style: CardStyles.value(14))],
        ),
      ),
    );
  }

  ControlStatus? _statusForControlKey(String key) {
    switch (key) {
      case 'Active':
        return ControlStatus.active;
      case 'Inactive':
        return ControlStatus.inactive;
      case 'Expired':
        return ControlStatus.expired;
      case 'Unassigned':
        return ControlStatus.unassigned;
      case 'Draft':
        return ControlStatus.draft;
      default:
        return null;
    }
  }

  List<ControlEntity> _applyControlStatusFilter(List<ControlEntity> controls) {
    final status = _statusForControlKey(_selectedControlStatusFilter);
    if (status == null) return controls;
    return controls.where((c) => c.status == status).toList();
  }

  Map<String, int> _countControlsByStatus(List<ControlEntity> controls) {
    return {
      'all': controls.length,
      'Active': controls.where((c) => c.status == ControlStatus.active).length,
      'Inactive':
          controls.where((c) => c.status == ControlStatus.inactive).length,
      'Expired':
          controls.where((c) => c.status == ControlStatus.expired).length,
      'Unassigned':
          controls.where((c) => c.status == ControlStatus.unassigned).length,
      'Draft': controls.where((c) => c.status == ControlStatus.draft).length,
    };
  }

  List<MapEntry<String, Map<String, dynamic>>> _controlStatusEntries(
      List<ControlEntity> controls) {
    final counts = _countControlsByStatus(controls);
    return [
      MapEntry('all', {'num': counts['all'] ?? 0, 'color': AppColors.text}),
      MapEntry(
          'Active', {'num': counts['Active'] ?? 0, 'color': AppColors.green}),
      MapEntry('Inactive',
          {'num': counts['Inactive'] ?? 0, 'color': AppColors.orange}),
      MapEntry(
          'Expired', {'num': counts['Expired'] ?? 0, 'color': AppColors.red}),
      MapEntry('Unassigned',
          {'num': counts['Unassigned'] ?? 0, 'color': AppColors.blue}),
      MapEntry(
          'Draft', {'num': counts['Draft'] ?? 0, 'color': AppColors.colorGrey}),
    ];
  }

  Future<void> _openAddEditControl({ControlEntity? existing}) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddEditControlPage(
          moduleId: widget.moduleId,
          policyId: widget.policyId,
          existingControl: existing,
          siblingControls: _controls,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      context
          .read<PolicyCubit>()
          .getAllControls(moduleId: widget.moduleId, policyId: widget.policyId);
    }
  }

  Widget _buildBottomButtons(PolicyCubit cubit) {
    if (_mode != _PolicyPageMode.edit) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: 'Discard Changes'.tr,
          function: () => setState(() => _mode = _PolicyPageMode.view),
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
    final cubit = context.read<PolicyCubit>();
    final isArabic = context.isArabic;
    final dateFormat = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');

    return BlocListener<PolicyCubit, PolicyState>(
      listener: _onStateChange,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _policy == null
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaginationAppBar(
                        screensTitles: [
                          'GRC'.tr,
                          isArabic
                              ? widget.module.moduleNameAr
                              : widget.module.moduleNameEn,
                          isArabic ? _policy!.policyNameAr : _policy!.policyNameEn,
                        ],
                      ),
                      if (_mode == _PolicyPageMode.view)
                        GrcActionButtons(
                          onEditTap: () {
                            _prefillControllers(_policy!);
                            setState(() => _mode = _PolicyPageMode.edit);
                          },
                          onDeleteTap: () => _onDelete(cubit),
                          deleteDialogTitle: 'Deleting Policy',
                          deleteDialogSubtitle:
                              'Are You Sure You Want To Delete This Policy ?',
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
                                  if (_mode == _PolicyPageMode.view) ...[
                                    Text(
                                      'Policy Details'.tr,
                                      style: StyleText.fontSize16Weight600
                                          .copyWith(color: AppColors.text),
                                    ),
                                    SizedBox(height: 12.h),
                                    _infoRow(
                                        'Policy Number:'.tr,
                                        isArabic
                                            ? _policy!.policyNumberAr
                                            : _policy!.policyNumberEn),
                                    Text(
                                      'Policy Description'.tr,
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(color: AppColors.text),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      isArabic
                                          ? _policy!.policyDescriptionAr
                                          : _policy!.policyDescriptionEn,
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(
                                              color: AppColors.secondaryText),
                                    ),
                                    SizedBox(height: 12.h),
                                    _infoRow('Policy Weight:'.tr,
                                        _policy!.policyWeight.toStringAsFixed(0)),
                                    _infoRow('Start Date:'.tr,
                                        dateFormat.format(_policy!.startDate)),
                                    _infoRow('End Date:'.tr,
                                        dateFormat.format(_policy!.endDate)),
                                    _infoRow(
                                        'Last Edit:'.tr,
                                        dateFormat
                                            .format(_policy!.lastModifiedDate)),
                                    SizedBox(height: 12.h),
                                    if (_policy!.policyDocumentEn != null)
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8.h),
                                        child: PolicyDocumentPreviewWidget(
                                          document: PolicyDocumentInfo.fromUrl(
                                              _policy!.policyDocumentEn!),
                                          readOnly: true,
                                        ),
                                      ),
                                    if (_policy!.policyDocumentAr != null)
                                      PolicyDocumentPreviewWidget(
                                        document: PolicyDocumentInfo.fromUrl(
                                            _policy!.policyDocumentAr!),
                                        readOnly: true,
                                      ),
                                    SizedBox(height: 20.h),
                                    GrcOwnerSection(
                                      isViewMode: true,
                                      initialOwnerEmails:
                                          widget.module.moduleOwners,
                                    ),
                                    SizedBox(height: 20.h),
                                    Text(
                                      'Controls'.tr,
                                      style: StyleText.fontSize16Weight600
                                          .copyWith(color: AppColors.text),
                                    ),
                                    SizedBox(height: 12.h),
                                    ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(scrollbars: false),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          spacing: 24.sp,
                                          children: [
                                            for (final entry
                                                in _controlStatusEntries(
                                                    _controls))
                                              FilterBarItem(
                                                title: entry.key,
                                                numberOfItems:
                                                    entry.value['num'],
                                                color: entry.value['color'],
                                                isSelected: entry.key ==
                                                    _selectedControlStatusFilter,
                                                onTap: () => setState(() =>
                                                    _selectedControlStatusFilter =
                                                        entry.key),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: customButtonWithSvg(
                                        colorBorder: AppColors.primary,
                                        space: 10.w,
                                        radius: 8.r,
                                        widthImage: 16.w,
                                        heightImage: 16.h,
                                        function: () => _openAddEditControl(),
                                        title: 'Control'.tr,
                                        textStyle: StyleText.fontSize14Weight500
                                            .copyWith(
                                                color: AppColors.textButton),
                                        image:
                                            'assets/icons_assets/database_builder_assets/plus_head.svg',
                                        color: AppColors.primary,
                                        svgColor: AppColors.textButton,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    if (_applyControlStatusFilter(_controls)
                                        .isEmpty)
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16.h),
                                        child: Center(
                                          child: Text(
                                            'No Controls found'.tr,
                                            style: StyleText.fontSize14Weight500
                                                .copyWith(
                                                    color:
                                                        AppColors.secondaryText),
                                          ),
                                        ),
                                      )
                                    else
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            _applyControlStatusFilter(_controls)
                                                .length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: 10.h),
                                        itemBuilder: (_, index) =>
                                            ControlCardWidget(
                                          control: _applyControlStatusFilter(
                                              _controls)[index],
                                          onTap: () => _openAddEditControl(
                                            existing: _applyControlStatusFilter(
                                                _controls)[index],
                                          ),
                                        ),
                                      ),
                                  ] else ...[
                                    PolicyInfoFormWidget(
                                      isArabicEnabled: true,
                                      submitted: _submitted,
                                      nameController: _nameController,
                                      nameArController: _nameArController,
                                      numberController: _numberController,
                                      numberArController: _numberArController,
                                      descriptionController:
                                          _descriptionController,
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
                                  ],
                                ],
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
  }
}
