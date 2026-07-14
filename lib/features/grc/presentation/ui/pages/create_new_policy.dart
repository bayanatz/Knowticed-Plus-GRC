/// Module: GRC Policy Management
/// Description: Three-step page for creating a new GRC policy.
///              Step 0: Policy info form.
///              Step 1: Add / edit controls.
///              Step 2: Full preview with controls table, weight validation,
///                      Equal Weight, and Publish action.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-06
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyCubit,
///               PolicyControlsTableWidget
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-06 - Added step 2 preview, Draft/Publish status,
///                                Equal Weight, weight validation (Mohamed Elrashidy)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: create_new_policy.dart
/// Purpose: Contains CreateNewPolicyPage, the three-step form for policy
///          creation — step 0: policy info, step 1: controls, step 2: preview.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'dart:io';

import 'package:demo_app/core/custom/10_custom_upload_document.dart';
// 11's own showUploadDialog is a near-duplicate of 10's — hidden here to
// avoid an ambiguous-import error; section 10 already demos the dedicated one.
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart' hide showUploadDialog;
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_control_usecase.dart';
import 'package:demo_app/features/grc/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/add_policy_controls.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_controls_table_widget.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_header_widget.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';

/// class name: [CreateNewPolicyPage]
///
/// purpose: three-step page that collects policy info (step 0), manages
///          controls (step 1), then shows a full preview with the controls
///          table (step 2). The body switches in-place via [_step]; no new
///          routes are pushed.
///
///          Supported actions:
///           - Save For Later  → persists as [PolicyStatus.draft]
///           - Preview         → advances from step 1 to step 2
///           - Equal Weight    → distributes 100 equally across all controls
///           - Publish         → persists as [PolicyStatus.active] (requires
///                               total weight == 100)
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class CreateNewPolicyPage extends StatefulWidget {
  final String moduleId;

  const CreateNewPolicyPage({super.key, required this.moduleId});

  @override
  State<CreateNewPolicyPage> createState() => _CreateNewPolicyPageState();
}

class _CreateNewPolicyPageState extends State<CreateNewPolicyPage> {
  // ----------------------------------------------------------------
  // State
  // ----------------------------------------------------------------
  int _step = 0; // 0 = info, 1 = controls, 2 = preview
  bool _isArabicEnabled = true;
  bool _step0Submitted = false;

  // Step 0 controllers
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _numberController = TextEditingController();
  final _numberArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _weightController = TextEditingController();

  final List<PolicyControlModel> _controls = [PolicyControlModel()];

  DateTime? _startDate;
  DateTime? _endDate;
  File? _imageFile;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;

  // ----------------------------------------------------------------
  // Lifecycle
  // ----------------------------------------------------------------
  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _numberController.dispose();
    _numberArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _weightController.dispose();
    for (final c in _controls) c.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------------

  /// function name: [_totalControlWeight]
  ///
  /// purpose: sum up the weight values entered for all controls.
  ///
  /// parameters: none
  ///
  /// return type: [double] - the current total control weight
  double get _totalControlWeight => _controls.fold(
        0,
        (sum, c) =>
            sum + (double.tryParse(c.weightController.text.trim()) ?? 0),
      );

  bool get _isWeightValid => _totalControlWeight == 100;

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

  /// function name: [_onStartDateChanged]
  ///
  /// purpose: update the start date and, if the previously selected end
  ///          date now falls before it, clear the end date so the user must
  ///          pick a new one.
  ///
  /// parameters:
  ///            [DateTime?] date: the newly selected start date
  ///
  /// return type: void
  void _onStartDateChanged(DateTime? date) {
    setState(() {
      _startDate = date;
      if (_endDate != null && date != null && _endDate!.isBefore(date)) {
        _endDate = null;
      }
    });
  }

  /// function name: [_validateStep0]
  ///
  /// purpose: verify that all required policy-info fields have been filled
  ///          before allowing the user to advance to step 1.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if all required fields are non-empty
  bool _validateStep0() {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return _nameController.text.trim().isNotEmpty &&
        _numberController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _startDate != null &&
        _endDate != null &&
        !_startDate!.isBefore(startOfToday) &&
        !_endDate!.isBefore(_startDate!) &&
        _weightController.text.trim().isNotEmpty &&
        (!_isArabicEnabled ||
            (_nameArController.text.trim().isNotEmpty &&
                _numberArController.text.trim().isNotEmpty &&
                _descriptionArController.text.trim().isNotEmpty));
  }

  
  // ----------------------------------------------------------------
  // Cubit actions
  // ----------------------------------------------------------------

  /// function name: [_onSaveForLater]
  ///
  /// purpose: persist the policy as a Draft regardless of the current step.
  ///          Controls are included if any have been filled in; an empty
  ///          list is valid for a draft.
  ///
  /// parameters:
  ///            [PolicyCubit] cubit: the cubit instance from the BlocProvider
  ///
  /// return type: void
  List<PendingControlInput> _buildPendingControls(ControlStatus status) {
    return _controls
        .where((c) => c.nameController.text.trim().isNotEmpty)
        .map((c) => PendingControlInput(
              controlsNameEn: c.nameController.text.trim(),
              controlsNameAr: c.nameArController.text.trim(),
              controlsNumberEn: c.numberController.text.trim(),
              controlsNumberAr: c.numberArController.text.trim(),
              controlsDescriptionEn: c.descriptionController.text.trim(),
              controlsDescriptionAr: c.descriptionArController.text.trim(),
              controlsWeight: double.tryParse(c.weightController.text.trim()) ?? 0,
              frequency: c.frequency ?? '',
              startDate: c.startDate ?? _startDate ?? DateTime.now(),
              endDate: c.endDate ?? _endDate ?? DateTime.now(),
              departments: const [],
              equalWeights: false,
              score: 0,
              status: status,
              controlsDocumentFileEn: c.documentEn?.file,
              controlsDocumentFileAr: c.documentAr?.file,
            ))
        .toList();
  }

  void _onSaveForLater(PolicyCubit cubit) {
    cubit.saveAsDraft(
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      moduleId: widget.moduleId,
      controls: _buildPendingControls(ControlStatus.draft),
      imageFile: _imageFile,
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentFileAr: _documentAr?.file,
    );
  }

  /// function name: [_onPublish]
  ///
  /// purpose: validate that the total control weight equals 100 then
  ///          persist the policy with [PolicyStatus.active].
  ///
  /// parameters:
  ///            [PolicyCubit] cubit: the cubit instance from the BlocProvider
  ///
  /// return type: void
  void _onPublish(PolicyCubit cubit) {
    if (!_isWeightValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total Weight should be 100'.tr),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    cubit.createPolicy(
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      moduleId: widget.moduleId,
      controls: _buildPendingControls(ControlStatus.active),
      imageFile: _imageFile,
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentFileAr: _documentAr?.file,
    );
  }

  // ----------------------------------------------------------------
  // BlocListener callback
  // ----------------------------------------------------------------

  /// function name: [_onStateChange]
  ///
  /// purpose: react to [PolicyState] changes emitted by [PolicyCubit]:
  ///          show / hide the loading indicator, display success dialogs,
  ///          and show error snackbars.
  ///
  /// parameters:
  ///            [BuildContext] context: the current build context
  ///            [PolicyState] state: the newly emitted state
  ///
  /// return type: void
  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyActionSuccess) {
      final isDraft = state.policy.status.value == 'Draft';
      showSuccessDialog(
        context: context,
        title: isDraft ? 'Saved as Draft'.tr : 'Policy Created'.tr,
        subtitle: isDraft
            ? 'Policy saved as draft successfully'.tr
            : 'You Successfully Created This Policy'.tr,
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is PolicyFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  // ----------------------------------------------------------------
  // Build
  // ----------------------------------------------------------------
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
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaginationAppBar(
                      screensTitles: ['GRC'.tr, 'Create New Policy'.tr],
                    ),
                    Expanded(child: _buildCurrentStep()),
                    SizedBox(height: 16.h),
                    _buildButtons(cubit),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      default:
        return _buildStep0();
    }
  }

  // ----------------------------------------------------------------
  // Step 0: Policy Info
  // ----------------------------------------------------------------
  Widget _buildStep0() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PolicyHeaderWidget(
                isArabicEnabled: _isArabicEnabled,
                onArabicToggle: (v) => setState(() => _isArabicEnabled = v),
                imageFile: _imageFile,
                onImagePicked: (file) => setState(() => _imageFile = file),
              ),
              SizedBox(height: 15.h),
              PolicyInfoFormWidget(
                isArabicEnabled: _isArabicEnabled,
                submitted: _step0Submitted,
                nameController: _nameController,
                nameArController: _nameArController,
                numberController: _numberController,
                numberArController: _numberArController,
                descriptionController: _descriptionController,
                descriptionArController: _descriptionArController,
                weightController: _weightController,
                startDate: _startDate,
                endDate: _endDate,
                onStartDateChanged: _onStartDateChanged,
                onEndDateChanged: (d) => setState(() => _endDate = d),
                documentEn: _documentEn,
                documentAr: _documentAr,
                onUploadDocumentEn: _onUploadDocumentEn,
                onUploadDocumentAr: _onUploadDocumentAr,
                onRemoveDocumentEn: () => setState(() => _documentEn = null),
                onRemoveDocumentAr: () => setState(() => _documentAr = null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Step 1: Controls
  // ----------------------------------------------------------------
  Widget _buildStep1() {
    return AddPolicyControlsPage(
      isArabicEnabled: _isArabicEnabled,
      controls: _controls,
      policyStartDate: _startDate,
      policyEndDate: _endDate,
    );
  }

  // ----------------------------------------------------------------
  // Step 2: Preview — policy summary + controls table
  // ----------------------------------------------------------------
  Widget _buildStep2() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Policy info summary (read-only) --
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15.sp),
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: PolicyInfoFormWidget(
                isArabicEnabled: _isArabicEnabled,
                nameController: _nameController,
                nameArController: _nameArController,
                numberController: _numberController,
                numberArController: _numberArController,
                descriptionController: _descriptionController,
                descriptionArController: _descriptionArController,
                weightController: _weightController,
                startDate: _startDate,
                endDate: _endDate,
                onStartDateChanged: (_) {},
                onEndDateChanged: (_) {},
                documentEn: _documentEn,
                documentAr: _documentAr,
                onUploadDocumentEn: () {},
                onUploadDocumentAr: () {},
                onRemoveDocumentEn: () {},
                onRemoveDocumentAr: () {},
              ),
            ),
            SizedBox(height: 16.h),
            // -- Controls table --
            PolicyControlsTableWidget(
              controls: _controls,
              onSave: () => setState(() {}),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Buttons row per step
  // ----------------------------------------------------------------

  /// function name: [_buildButtons]
  ///
  /// purpose: render the correct bottom-action buttons depending on the
  ///          current step.
  ///
  /// parameters:
  ///            [PolicyCubit] cubit: the cubit instance from the BlocProvider
  ///
  /// return type: [Widget]
  Widget _buildButtons(PolicyCubit cubit) {
    switch (_step) {
      case 0:
        return _buildStep0Buttons();
      case 1:
        return _buildStep1Buttons(cubit);
      case 2:
        return _buildStep2Buttons(cubit);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep0Buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: 'Discard'.tr,
          function: () => showConfirmDialog(
            context: context,
            title: 'Discard Policy'.tr,
            subtitle:
                'Are you sure you want to discard this policy? Any unsaved changes will be lost.'
                    .tr,
            confirmLabel: 'Discard'.tr,
            cancelLabel: 'Cancel'.tr,
            onConfirm: () => Navigator.of(context).pop(),
          ),
          height: 38.h,
          width: 150.w,
          color: AppColors.grey,
          textStyle:
              StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        customButton(
          title: 'Next'.tr,
          function: () {
            setState(() => _step0Submitted = true);
            if (!_validateStep0()) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please fill all required fields'.tr),
                  backgroundColor: AppColors.red,
                ),
              );
              return;
            }
            setState(() => _step = 1);
          },
          height: 38.h,
          width: 150.w,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }

  Widget _buildStep1Buttons(PolicyCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: 'Save For Later'.tr,
          function: () => showConfirmDialog(
            context: context,
            title: 'Save As Draft'.tr,
            subtitle:
                'Are you sure you want to save this policy as a draft?'.tr,
            confirmLabel: 'Save'.tr,
            cancelLabel: 'Cancel'.tr,
            onConfirm: () => _onSaveForLater(cubit),
          ),
          height: 38.h,
          width: 150.w,
          color: AppColors.grey,
          textStyle:
              StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        customButton(
          title: 'Preview'.tr,
          function: () => setState(() => _step = 2),
          height: 38.h,
          width: 150.w,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }

  Widget _buildStep2Buttons(PolicyCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: 'Save For Later'.tr,
          function: () => showConfirmDialog(
            context: context,
            title: 'Save As Draft'.tr,
            subtitle:
                'Are you sure you want to save this policy as a draft?'.tr,
            confirmLabel: 'Save'.tr,
            cancelLabel: 'Cancel'.tr,
            onConfirm: () => _onSaveForLater(cubit),
          ),
          height: 38.h,
          width: 150.w,
          color: AppColors.grey,
          textStyle:
              StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        customButton(
          title: 'Publish'.tr,
          function: () {
            if (!_isWeightValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Total Weight should be 100'.tr),
                  backgroundColor: AppColors.red,
                ),
              );
              return;
            }
            showConfirmDialog(
              context: context,
              title: 'Publish Policy'.tr,
              subtitle:
                  'Are you sure you want to publish this policy? This will make it active.'
                      .tr,
              confirmLabel: 'Publish'.tr,
              cancelLabel: 'Cancel'.tr,
              onConfirm: () => _onPublish(cubit),
            );
          },
          height: 38.h,
          width: 150.w,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }
}
