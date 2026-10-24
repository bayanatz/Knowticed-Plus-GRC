/// Module: services / sv4_bulk_upload_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: create_new_services.dart
/// Purpose: Create new services — declares CreateServiceScreen,
///          _CreateServiceView, _FormContent, _StatusToggleSection.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/widgets/name_and_description_action_buttons_row.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/widgets/name_and_description_success_dialog.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/widgets/service_form_fields.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/widgets/status_toggle_widget.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';

import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/pages/select_services_provider_toggle.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/controller/create_service_cubit.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/controller/create_service_state.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/service_image_storage.dart';

class CreateServiceScreen extends StatelessWidget {
  final ServicesHistoryModel? editingModel;
  final String? docId;

  const CreateServiceScreen({super.key, this.editingModel, this.docId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateServiceCubit(
        ServicesManagerCubit.get(context),
        mediaPicker: context.read<MediaPickerService>(),
        imageStorage: context.read<ServiceImageStorage>(),
      )..initialize(editingModel: editingModel, docId: docId),
      child: _CreateServiceView(editingModel: editingModel),
    );
  }
}

class _CreateServiceView extends StatelessWidget {
  final ServicesHistoryModel? editingModel;

  const _CreateServiceView({required this.editingModel});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateServiceCubit, CreateServiceState>(
      // ✅ FIX: Don't re-fire listener when we restore Loaded→Loaded after navigation
      listenWhen: (previous, current) {
        if (current is CreateServiceLoaded && previous is CreateServiceLoaded) {
          return false;
        }
        return true;
      },
      listener: (context, state) => _handleStateChanges(context, state),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SideFrameMasterServices(
            titleText: S.of(context).services,
            onFirstTap: () => navigateTo(context, LayoutScreenServices()),
            secondTitle: _getSecondTitle(context),
            child: const SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: _FormContent(),
            ),
          ),
        ),
      ),
    );
  }

  String _getSecondTitle(BuildContext context) {
    final state = context.read<CreateServiceCubit>().state;
    if (state is! CreateServiceLoaded) return S.of(context).creatingNewService;

    final isDraft = editingModel != null &&
        (editingModel!.currentState == "draft" ||
            editingModel!.currentDurationOfServices == "-" ||
            editingModel!.currentDurationOfServices.isEmpty);

    if (editingModel != null) {
      final name = Localizations.localeOf(context).languageCode == 'ar'
          ? editingModel!.currentServiceNameArabic
          : editingModel!.currentServiceNameEnglish;
      return isDraft
          ? "${S.of(context).draft} $name"
          : "${S.of(context).Editing} $name";
    }
    return S.of(context).creatingNewService;
  }

  /// The translated text for a [CreateServiceIssue] (Create R3).
  String _errorText(BuildContext context, CreateServiceIssue issue) {
    final s = S.of(context);
    switch (issue) {
      case CreateServiceIssue.imagePickFailed:
        return s.svcImagePickFailed;
      case CreateServiceIssue.imageUploadFailed:
        return s.svcImageUploadFailed;
      case CreateServiceIssue.imageUploadInProgress:
        return s.svcImageUploadInProgress;
      case CreateServiceIssue.draftSaveFailed:
        return s.svcDraftNotSaved;
      case CreateServiceIssue.unexpected:
        return s.svcSomethingWentWrong;
    }
  }

  void _handleStateChanges(BuildContext context, CreateServiceState state) {
    if (state is CreateServiceError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorText(context, state.issue)),
          backgroundColor: AppColors.red,
        ),
      );
    } else if (state is CreateServiceDuplicateName) {
      final title = S.of(context).sm_duplicateInfoName;
      final message =
          S.of(context).svcServiceNameAlreadyExists(state.duplicateValue);

      showAppDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Container(
            width: 500.w,
            padding: EdgeInsets.all(24.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  width: 100.w,
                  height: 100.h,
                  ServicesLottie.rejected,
                  fit: BoxFit.fill,
                  repeat: false,
                ),
                SizedBox(height: 16.h),
                Text(
                  title,
                  style: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    customButton(
                      width: 100.w,
                      height: 38.h,
                      title: S.of(context).ok,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      function: () {
                        Navigator.pop(dialogContext);
                        context
                            .read<CreateServiceCubit>()
                            .resetToDuplicateState();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else if (state is CreateServiceImageUploaded) {
      _showSuccessDialog(context, S.of(context).imageUploadedSuccessfully);
    } else if (state is CreateServiceNavigateToProviders) {
      // ✅ FIX: Navigate to providers page
      // The cubit already restored loaded state after emitting this,
      // so when user presses back, the form is fully functional again.
      navigateTo(
        context,
        ServicesProviderLayout(
          docId: state.docId,
          editingModel: state.formData.isEditMode
              ? _buildModelFromState(state.formData)
              : null,
        ),
      );
    }
  }

  ServicesHistoryModel _buildModelFromState(dynamic formData) {
    return ServicesHistoryFactory.createNew(
      id: formData.docId ?? '',
      state: formData.state,
      status: formData.isActive ? "active" : "inactive",
      serviceNameEnglish: formData.serviceNameEn,
      serviceNameArabic: formData.serviceNameAr,
      serviceDescriptionEnglish: formData.descriptionEn,
      serviceDescriptionArabic: formData.descriptionAr,
      durationOfServices: formData.durationValue,
      selectedDurationUnit: formData.durationUnit,
      imageUrl: formData.imageUrl ?? '',
      providerServices: formData.providers,
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showAppDialog(
      context: context,
      builder: (context) => SuccessDialog(message: message),
    );
  }
}

class _FormContent extends StatelessWidget {
  const _FormContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section Title
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              S.of(context).serviceDetails,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.text,
              ),
            ),
            const Spacer(),
            const _StatusToggleSection(),
          ],
        ),
        SizedBox(height: 8.sp),

        const ServiceFormFields(),

        SizedBox(height: 20.sp),

        ActionButtonsRow(onDiscard: () => Navigator.pop(context)),

        SizedBox(height: 20.sp),
      ],
    );
  }
}

class _StatusToggleSection extends StatelessWidget {
  const _StatusToggleSection();

  @override
  Widget build(BuildContext context) {
    return SlideInContent(
      from: SlideFrom.bottom,
      child: BlocBuilder<CreateServiceCubit, CreateServiceState>(
        // ✅ Also rebuild when coming back from NavigateToProviders
        // since we now restore to Loaded state
        buildWhen: (previous, current) => current is CreateServiceLoaded,
        builder: (context, state) {
          if (state is! CreateServiceLoaded) return const SizedBox.shrink();

          // ✅ The active/inactive toggle belongs to EDIT mode only.
          //
          // A service does not have an availability to manage until it exists:
          // while creating, and while a draft is still being built, there is
          // nothing to activate or deactivate — the service goes live as active
          // when the wizard is completed. Showing the switch in those flows only
          // invites a value that the draft can't meaningfully carry.
          //
          // `isEditMode` alone is not enough: resuming a draft also runs through
          // the edit branch of CreateServiceCubit.initialize, so drafts are
          // excluded explicitly (by lifecycle state and by their `draft_` id).
          final formData = state.formData;
          final isDraft = formData.state.trim().toLowerCase() == 'draft' ||
              (formData.docId ?? '').startsWith('draft_');

          if (!formData.isEditMode || isDraft) {
            return const SizedBox.shrink();
          }

          return const StatusToggleWidget();
        },
      ),
    );
  }
}
