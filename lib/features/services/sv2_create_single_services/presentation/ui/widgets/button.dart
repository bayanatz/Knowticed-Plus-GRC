/// Module: services / sv2_create_single_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: button.dart
/// Purpose: Button — declares _buildCompleteModelForDraft,
///          _confirmSaveForLater, _saveDraftToFirebase, buttonFotter.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/widgets/select_approval_success_dialog.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/widgets/details_switch_widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services/data/utils/shared.dart';
import 'package:knowticed_plus/features/services/data/data_source/local_data_source/services_prefs_employee.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/features/services/data/repository/firebase_draft_repository.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/pages/sla_screen_page_toggle.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/pages/details_switch_screen_toggle.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_prefs_keys.dart';

/// 🔥 Helper: Build complete model from all sources
Future<ServicesHistoryModel> _buildCompleteModelForDraft({
  required List<String> selectedDepartments,
  required List<EmployeeEntityPro> selectedEmployees,
  required bool requireApproval,
  required bool limitAvailability,
  required ServicesHistoryModel? editingModel,
  required String? docId,
}) async {
  // Get data from SharedPrefs or editingModel
  final nameEn = editingModel?.currentServiceNameEnglish ??
      await SharedPrefsHelper.getString('service_name_en') ??
      '';
  final nameAr = editingModel?.currentServiceNameArabic ??
      await SharedPrefsHelper.getString('service_name_ar') ??
      '';
  final descEn = editingModel?.currentServiceDescriptionEnglish ??
      await SharedPrefsHelper.getString('service_description_en') ??
      '';
  final descAr = editingModel?.currentServiceDescriptionArabic ??
      await SharedPrefsHelper.getString('service_description_ar') ??
      '';
  final durationVal = editingModel?.currentDurationOfServices ??
      await SharedPrefsHelper.getString('duration_value') ??
      '';
  final durationUnit = editingModel?.currentSelectedDurationUnit ??
      await SharedPrefsHelper.getString('duration_unit') ??
      '';
  final imageUrl = editingModel?.currentImageUrl ??
      await SharedPrefsHelper.getString('service_image_url') ??
      '';

  // Get providers from SharedPrefs
  final providers = await SharedPrefsEmployeeHelper.getSelectedEmployees();

  // Convert approval employees
  final approvalModels = selectedEmployees
      .map(
        (e) => ServiceEmployeeModel(
          id: e.id,
          state: "pending",
          firstName: e.firstName,
          lastName: e.lastName,
          email: e.email,
          gender: e.gender,
          title: e.title,
          titleInArabic: e.titleInArabic,
          photo: e.photo,
          departmentId: e.departmentId,
          role: e.role,
          status: e.status,
          firstNameInArabic: e.firstNameInArabic,
          lastNameInArabic: e.lastNameInArabic,
          mobilePhone: (e.mobilePhone != null)
              ? ServicesMobilePhoneEntity.fromMobilePhoneEntity(e.mobilePhone!)
              : null,
        ),
      )
      .toList();

  return ServicesHistoryFactory.createNew(
    id: editingModel?.currentId ?? docId ?? '',
    state: "draft",
    status: "draft",
    serviceNameEnglish: nameEn,
    serviceNameArabic: nameAr,
    serviceDescriptionEnglish: descEn,
    serviceDescriptionArabic: descAr,
    durationOfServices: durationVal,
    selectedDurationUnit: durationUnit,
    imageUrl: imageUrl,
    providerServices: providers,
    selectDepartment: limitAvailability ? selectedDepartments : [],
    approvalCycle: approvalModels,
    limitAvailability: limitAvailability,
    requireApproval: requireApproval,
  );
}

/// 🔥 Helper: ask before saving, exactly like the select-provider step.
///
/// ✅ FIX: this step used to fire straight into [_saveDraftToFirebase] with no
/// confirmation, while SaveForLaterButton (the select-provider step) already
/// asked first via the shared [ConfirmationDialog]. Same button, same label,
/// two different behaviours. Reuse that component so both steps match.
void _confirmSaveForLater({
  required BuildContext stxContext,
  required List<String> selectedDepartments,
  required List<EmployeeEntityPro> selectedEmployees,
  required bool requireApproval,
  required bool limitAvailability,
  required ServicesHistoryModel? editingModel,
  required String? docId,
}) {
  showAppDialog(
    context: stxContext,
    barrierDismissible: true,
    builder: (dialogContext) => ConfirmationDialog(
      lottiePath: ServicesLottie.editDocument,
      title: S.of(dialogContext).saveForLater,
      message: S.of(dialogContext).areYouSureYouWantToSaveAsDraft,
      noText: S.of(dialogContext).no,
      yesText: S.of(dialogContext).yes,
      // ConfirmationDialog pops itself before invoking onConfirm, so the save
      // runs against the page context, not a dead dialog one.
      onConfirm: () async {
        await _saveDraftToFirebase(
          stxContext: stxContext,
          selectedDepartments: selectedDepartments,
          selectedEmployees: selectedEmployees,
          requireApproval: requireApproval,
          limitAvailability: limitAvailability,
          editingModel: editingModel,
          docId: docId,
        );
      },
    ),
  );
}

/// 🔥 Helper: Save draft to Firebase from Details page
Future<void> _saveDraftToFirebase({
  required BuildContext stxContext,
  required List<String> selectedDepartments,
  required List<EmployeeEntityPro> selectedEmployees,
  required bool requireApproval,
  required bool limitAvailability,
  required ServicesHistoryModel? editingModel,
  required String? docId,
}) async {
  // 031: no try/catch in the UI (§11.2). The cubit/repository own error
  // handling; saveDraftToFirebase rethrows so failures surface there.

  // ✅ FIX: resolve the navigator and the cubit BEFORE the first await.
  //
  // showDialog puts its route on the ROOT navigator, but this page sits under
  // a nested one (the toggle/layout screens). The old code closed the loader
  // with `Navigator.pop(stxContext)`, which resolves to the *nearest*
  // navigator — so it popped the page out from under the user instead of the
  // dialog, and `Navigator.canPop` guarded the wrong navigator too. Holding
  // the root NavigatorState makes every pop below unambiguous, and reading it
  // up front means it stays valid across the awaits.
  final rootNavigator = Navigator.of(stxContext, rootNavigator: true);
  final cubit = ServicesManagerCubit.get(stxContext);

  // Show loading
  showAppDialog(
    context: stxContext,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => const Center(child: CircleProgressMaster.inline()),
  );

  // Build complete model from all data sources
  final completeModel = await _buildCompleteModelForDraft(
    selectedDepartments: selectedDepartments,
    selectedEmployees: selectedEmployees,
    requireApproval: requireApproval,
    limitAvailability: limitAvailability,
    editingModel: editingModel,
    docId: docId,
  );

  // Save to Firebase with page 3 (DetailsToggleScreen)
  await cubit.saveDraftToFirebase(
    model: completeModel,
    currentPage: FirebaseDraftRepository.pageDetailsApproval, // Page 3
  );

  // Close loading — same navigator that opened it.
  rootNavigator.pop();

  if (!stxContext.mounted) return;

  // Show success using the imported SuccessDialog
  showAppDialog(
    context: stxContext,
    barrierDismissible: true,
    useRootNavigator: true,
    builder: (dialogContext) => SuccessDialogMaster(
      title: S.of(dialogContext).draftService,
      message: S.of(dialogContext).successfullyDraftedService,
      // ✅ FIX: SuccessDialogMaster does not pop itself — its own
      // `Navigator.pop` is commented out and it delegates entirely to
      // onDismiss. The old callback only pushed, so the success dialog stayed
      // on screen on top of the newly pushed page. Dismiss it first, then
      // replace the whole create-service flow rather than stacking onto it.
      onDismiss: () {
        rootNavigator.pop();
        rootNavigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LayoutScreenServices()),
          (route) => route.isFirst,
        );
      },
    ),
  );
}

Widget buttonFotter({
  required BuildContext context,
  required bool isEditingSubmittedService,
  required List<String> selectedDepartments,
  required List<EmployeeEntityPro> selectedEmployees,
  required bool requireApproval,
  required bool limitAvailability,
  required ServicesHistoryModel? editingModel,
  required String? docId,
  required bool navigated,
  required bool isDraft,
  required void Function() onNavigateBack,
  required void Function(ServicesHistoryModel model) onDraftSaved,
  required bool Function() onValidation,
}) {
  final shouldShowSaveForLaterButton = !isEditingSubmittedService || isDraft;

  return Column(
    children: [
      Row(
        children: [
          customButton(
            title: S.of(context).back,
            function: () {
              Navigator.pop(context);
            },
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.onSecondaryAction,
            ),
            width: 150.sp,
            height: 38.sp,
            radius: 8.r,
            color: AppColors.secondaryAction,
          ),
          const Spacer(),
          customButton(
            title: S.of(context).next,
            function: () async {
              if (!onValidation()) {
                return;
              }

              await SharedPrefsDepartmentsHelper.saveDepartments(
                selectedDepartments,
              );
              await SharedPrefsHelper.setBool(
                ServicesPrefsKeys.limitAvailability,
                limitAvailability,
              );
              await SharedPrefsHelper.setBool(
                ServicesPrefsKeys.requireApproval,
                requireApproval,
              );

              final selectedModels = selectedEmployees
                  .map(
                    (e) => ServiceEmployeeModel(
                      id: e.id,
                      state: "pending",
                      firstName: e.firstName,
                      middleName: e.middleName,
                      lastName: e.lastName,
                      email: e.email,
                      gender: e.gender,
                      title: e.title,
                      titleInArabic: e.titleInArabic,
                      photo: e.photo,
                      bio: e.bio,
                      departmentId: e.departmentId,
                      country: e.country,
                      extension: e.extension,
                      homePhone: e.homePhone,
                      maritalStatus: e.maritalStatus,
                      lastLogin: e.lastLogin,
                      activationDate: e.activationDate,
                      firstLogin: e.firstLogin,
                      firstNameInArabic: e.firstNameInArabic,
                      mobilePhone: (e.mobilePhone != null)
                          ? ServicesMobilePhoneEntity.fromMobilePhoneEntity(
                              e.mobilePhone!,
                            )
                          : null,
                      language: e.language,
                      middleNameInArabic: e.middleNameInArabic,
                      nationality: e.nationality,
                      officePhone: e.officePhone,
                      passport: e.passport,
                      passportExpirationDate: e.passportExpirationDate,
                      postalCode: e.postalCode,
                      province: e.province,
                      role: e.role,
                      status: e.status,
                      street: e.street,
                      supervisor: e.supervisor,
                      workLocation: e.workLocation,
                      nationalId: e.nationalId,
                      nationalIdExpirationDate: e.nationalIdExpirationDate,
                      lastNameInArabic: e.lastNameInArabic,
                      birthDay: e.birthDay,
                      carPlates: e.carPlates,
                      city: e.city,
                      drivingLicenseId: e.drivingLicenseId,
                      deactivationDate: e.deactivationDate,
                    ),
                  )
                  .toList();

              await SharedPrefsApprovalHelper.saveApprovalCycle(selectedModels);

              if (!context.mounted) return;
              navigateTo(context, ToggleSlaScreen(editingModel: editingModel));
            },
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.textButton,
            ),
            width: 150.sp,
            height: 38.sp,
            radius: 8.r,
            color: AppColors.primary,
          ),
        ],
      ),
      SizedBox(height: 10.sp),

      // Save For Later section
      if (shouldShowSaveForLaterButton)
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            customButton(
              title: isEditingSubmittedService && isDraft
                  ? S.of(context).saveForLater
                  : isEditingSubmittedService
                      ? S.of(context).discardChange
                      : S.of(context).saveForLater,
              function: () {
                if (isEditingSubmittedService && !isDraft) {
                  navigateTo(
                    context,
                    DetailsToggleScreen(
                      editingModel: editingModel,
                      docId: docId,
                    ),
                  );
                  return;
                }

                // 🔥 CONFIRM, then SAVE TO FIREBASE (not local) — mirrors
                // SaveForLaterButton on the select-provider step.
                _confirmSaveForLater(
                  stxContext: context,
                  selectedDepartments: selectedDepartments,
                  selectedEmployees: selectedEmployees,
                  requireApproval: requireApproval,
                  limitAvailability: limitAvailability,
                  editingModel: editingModel,
                  docId: docId,
                );
              },
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.onSecondaryAction,
              ),
              width: 150.sp,
              height: 38.sp,
              radius: 8.r,
              color: AppColors.secondaryAction,
            ),
          ],
        ),
      SizedBox(height: 20.sp),
    ],
  );
}
