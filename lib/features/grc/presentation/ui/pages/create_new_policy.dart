/// Module: GRC Policy Management
/// Description: Multi-step page for creating a new GRC policy.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, AddPolicyControlsPage, PolicyInfoFormWidget
/// Revision History: 2026-07-01 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: create_new_policy.dart
/// Purpose: Contains CreateNewPolicyPage, the two-step form for policy
///          creation — step 0: policy info, step 1: policy controls.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';
import 'package:demo_app/features/grc/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/add_policy_controls.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
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
/// purpose: two-step page that first collects policy info (step 0) then
///          shows the controls widget (step 1) without navigating to a new
///          route — the body switches in-place via _step.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class CreateNewPolicyPage extends StatefulWidget {
  const CreateNewPolicyPage({super.key});

  @override
  State<CreateNewPolicyPage> createState() => _CreateNewPolicyPageState();
}

class _CreateNewPolicyPageState extends State<CreateNewPolicyPage> {
  int _step = 0;
  bool _isArabicEnabled = true;

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
  PolicyDocumentInfo? _document;

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _numberController.dispose();
    _numberArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _weightController.dispose();
    for (final control in _controls) {
      control.dispose();
    }
    super.dispose();
  }

  void _onUploadDocument() {
    setState(() {
      _document = const PolicyDocumentInfo(
        name: 'Submission 1.pdf',
        sizeLabel: '62 KB',
        dateLabel: '28 Dec 2023',
      );
    });
  }

  bool _validateStep0() {
    return _nameController.text.trim().isNotEmpty &&
        _numberController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _startDate != null &&
        _endDate != null &&
        _weightController.text.trim().isNotEmpty;
  }

  void _onCreate(PolicyCubit cubit) {
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
      controls: _controls
          .map(
            (c) => CreateControlParams(
              controlsNameEn: c.nameController.text.trim(),
              controlsNameAr: c.nameArController.text.trim(),
              controlsDescriptionEn: c.descriptionController.text.trim(),
              controlsDescriptionAr: c.descriptionArController.text.trim(),
              controlsWeight:
                  double.tryParse(c.weightController.text.trim()) ?? 0,
              frequency: c.frequency ?? '',
            ),
          )
          .toList(),
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
        title: 'Created Policy'.tr,
        subtitle: 'You Successfully Created This Policy'.tr,
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
                    Expanded(
                      child: _step == 0 ? _buildStep0() : _buildStep1(),
                    ),
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
                onArabicToggle: (value) =>
                    setState(() => _isArabicEnabled = value),
              ),
              SizedBox(height: 15.h),
              PolicyInfoFormWidget(
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
                onStartDateChanged: (d) => setState(() => _startDate = d),
                onEndDateChanged: (d) => setState(() => _endDate = d),
                document: _document,
                onUploadDocument: _onUploadDocument,
                onRemoveDocument: () => setState(() => _document = null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return AddPolicyControlsPage(
      isArabicEnabled: _isArabicEnabled,
      controls: _controls,
    );
  }

  Widget _buildButtons(PolicyCubit cubit) {
    if (_step == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          customButton(
            title: 'Discard'.tr,
            function: () {},
            height: 38.h,
            width: 150.w,
            color: AppColors.grey,
            textStyle:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
          customButton(
            title: 'Next'.tr,
            function: () {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: 'Save For Later'.tr,
          function: () {},
          height: 38.h,
          width: 150.w,
          color: AppColors.grey,
          textStyle:
              StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        customButton(
          title: 'Create Policy'.tr,
          function: () => _onCreate(cubit),
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
