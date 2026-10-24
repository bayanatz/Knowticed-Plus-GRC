/// Module: services / sv2_create_single_services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: provider_selection_cubit_ext.dart
/// Purpose: Declares ProviderSelectionCubitPart.
/// Author: Amr Mesbah
/// Created At: 18/10/2026

part of 'provider_selection_cubit.dart';

// Methods extracted from provider_selection_cubit.dart to keep it <700 LOC.
extension ProviderSelectionCubitPart on ProviderSelectionCubit {
  Future<void> handleSaveForLater() async {
    final currentState = state as ProviderSelectionLoaded;

    try {
      // S2: the save above is awaited, so no fixed wait is needed here.
      await _saveSelectionToPrefsAndCubit();

      // ✅ FIX: Pass required parameters
      final completeModel = await _getCompleteServiceModel(
        data: currentState.data,
        allEmployees: currentState.allEmployees,
      );

      final data = currentState.data;

      if (data.editingModel != null &&
          data.editingModel!.currentId.isNotEmpty) {
        final updatedModel = completeModel.copyWith(
          id: data.editingModel!.currentId,
        );

        await SharedPrefsServiceMaster.updateDraft(
          data.editingModel!,
          updatedModel,
        );
      } else {
        final cubitModel = servicesManagerCubit.docService;

        if (cubitModel != null && cubitModel.currentId.startsWith('draft_')) {
          final updatedModel = completeModel.copyWith(id: cubitModel.currentId);
          await SharedPrefsServiceMaster.updateDraft(cubitModel, updatedModel);
        } else {
          await SharedPrefsServiceMaster.saveDraft(completeModel);
        }
      }

      emit(const ProviderSelectionSaved());
    } catch (error) {
      emit(
        ProviderSelectionError(
          ProviderSelectionIssue.draftSaveFailed,
          '$error',
        ),
      );
    }
  }

  // ==================== MODEL BUILDING ====================

  // ==================== HELPER METHODS ====================

  // CHANGED: Made public from private (_normalizeEmail -> normalizeEmail)
  String normalizeEmail(String? email) {
    if (email == null || email.isEmpty) return '';
    return email.trim().toLowerCase();
  }

  ServiceEmployeeModel _mapToServiceEmployeeModel(EmployeeEntityPro e) {
    return ServiceEmployeeModel(
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
      departmentId: e.departmentId,
      language: e.language,
      maritalStatus: e.maritalStatus,
      middleNameInArabic: e.middleNameInArabic,
      lastNameInArabic: e.lastNameInArabic,
      firstNameInArabic: e.firstNameInArabic,
      homePhone: e.homePhone,
      drivingLicenseId: e.drivingLicenseId,
      country: e.country,
      city: e.city,
      postalCode: e.postalCode,
      province: e.province,
      role: e.role,
      status: e.status,
      supervisor: e.supervisor,
      workLocation: e.workLocation,
      mobilePhone: (e.mobilePhone != null)
          ? ServicesMobilePhoneEntity.fromMobilePhoneEntity(e.mobilePhone!)
          : null,
    );
  }

  // ==================== UI HELPERS ====================
}
