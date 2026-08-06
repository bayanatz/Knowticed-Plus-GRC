/// ************************ FILE INFO ********************************///
/// File Name: company_cubit.dart
/// Author: Amr Mesbah
/// refactored at: 11/12/2024
/// Updated by: Amr Mesbah - Added employee personal branding support
/// Merged: add_company_controller.dart + company_controller_personal.dart
///         (the latter was a strict superset; nothing was lost), then
///         converted from GetxController+StateMixin to Cubit<CompanyState>.
///
/// NOTE ON LIFECYCLE: this cubit is created in main() and provided at the app
/// root via BlocProvider.value, because ThemeController is constructed before
/// runApp and depends on it. Same pattern as ThemeAndLocalizationsCubit.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:grc_module/features/settings/se3_company/data/models/company_model/company_model.dart';
import 'package:grc_module/features/settings/se3_company/data/repository/employee_branding_repository.dart';
import 'package:grc_module/features/settings/se3_company/domain/entities/employee_branding_model.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_state.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/restart_widget.dart';

class CompanyCubit extends Cubit<CompanyState> {
  CompanyCubit() : super(CompanyState.initial());

  /// Guard against emit-after-close when the user navigates away mid-await.
  /// Matches the convention in DashboardAdminCubit.
  @override
  void emit(CompanyState state) {
    if (isClosed) return;
    super.emit(state);
  }

  final SystemLogsController systemLogsController = Get.find<SystemLogsController>();
  final EmployeeBrandingRepository employeeBrandingRepository =
      EmployeeBrandingRepository();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final storage = GetStorage();

  /// Convenience accessor — a lot of call sites still want the raw model.
  CompanyModel? get company => state.company;

  // ───────────────────────────── Bootstrap ──────────────────────────────────

  /// Replaces GetxController.onInit(). Called once from main() after the cubit
  /// is created, so the first frame already has company data in flight.
  Future<void> bootstrap() async {
    await getCompany(shouldRestart: false);
  }

  // ─────────────────────────── Form field setters ───────────────────────────
  // Every text field is state now; widgets push edits through these.

  void setCompanyName(String v) => emit(state.copyWith(companyName: v));
  void setTaxNumber(String v) => emit(state.copyWith(taxNumber: v));
  void setBirthDate(String v) => emit(state.copyWith(birthDate: v));
  void setCountry(String v) => emit(state.copyWith(country: v));
  void setCity(String v) => emit(state.copyWith(city: v));
  void setStateOrProvince(String v) => emit(state.copyWith(stateOrProvince: v));
  void setEmail(String v) => emit(state.copyWith(email: v));
  void setPhone(String v) => emit(state.copyWith(phone: v));
  void setStreetAddress(String v) => emit(state.copyWith(streetAddress: v));
  void setCode(String v) => emit(state.copyWith(code: v));
  void setContactFirstName(String v) => emit(state.copyWith(contactFirstName: v));
  void setContactLastName(String v) => emit(state.copyWith(contactLastName: v));
  void setContactEmail(String v) => emit(state.copyWith(contactEmail: v));
  void setContactPhone(String v) => emit(state.copyWith(contactPhone: v));

  // ───────────────────────── Branding selection setters ─────────────────────

  void setBrandingSelectedIndex(int v) =>
      emit(state.copyWith(brandingSelectedIndex: v));
  void setSelectedEnglishFont(String? v) =>
      emit(state.copyWith(selectedEnglishFont: v));
  void setSelectedArabicFont(String? v) =>
      emit(state.copyWith(selectedArabicFont: v));
  void setPrimaryColor(Color? v) => emit(state.copyWith(primaryColor: v));
  void setSecondaryColor(Color? v) => emit(state.copyWith(secondaryColor: v));
  void setImageUrl(String? v) => emit(state.copyWith(imageUrl: v));

  /// Clears the unsaved branding selections (company_branding_screen's reset).
  void clearBrandingSelections() => emit(state.copyWith(
        imageUrl: null,
        selectedEnglishFont: null,
        selectedArabicFont: null,
        primaryColor: null,
        secondaryColor: null,
      ));

  /// Drops one-shot feedback after a BlocListener has displayed it.
  void clearMessages() => emit(state.consumed());

  // ─────────────────────────── Employee branding ────────────────────────────

  /// Initialize Employee_Data collection (call once on app start).
  Future<void> initializeEmployeeDataCollection() async {
    if (await employeeBrandingRepository.isInitialized()) return;

    final c = state.company;
    await employeeBrandingRepository.initializeEmployeeDataCollection(
      companyLogo: c?.companyLogo?.companyLogo?.lastOrNull,
      companyPrimaryColor: c?.primaryColor?.primaryColor?.lastOrNull,
      companySecondaryColor: c?.secondaryColor?.secondaryColor?.lastOrNull,
      companyFontEnglish: c?.englishFont?.englishFont?.lastOrNull,
      companyFontArabic: c?.arabicFont?.arabicFont?.lastOrNull,
    );
  }

  /// Load employee branding (call on login).
  Future<void> loadEmployeeBranding(String employeeId) async {
    try {
      final branding =
          await employeeBrandingRepository.getEmployeeBranding(employeeId);
      emit(state.copyWith(employeeBranding: branding));

      if (branding != null) {
        _applyEmployeeBrandingToStorage();
      } else {
        _applyCompanyBrandingToStorage();
      }
    } catch (e) {
      debugPrint('❌ ERROR loading employee branding: $e');
      _applyCompanyBrandingToStorage();
    }
  }

  void _applyEmployeeBrandingToStorage() {
    final branding = state.employeeBranding;
    if (branding == null) return;

    storage.write('logo', branding.logo);
    storage.write('primaryColor', branding.primaryColor);
    storage.write('secondaryColor', branding.secondaryColor);
    storage.write('font', branding.fontEnglish?.capitalize);
    storage.write('font_arabic', branding.fontArabic?.capitalize);
  }

  void _applyCompanyBrandingToStorage() {
    if (!state.isCompanyActive) {
      _clearBrandingStorage();
      return;
    }
    _syncStorageFromFirebase();
  }

  Future<void> saveEmployeeBranding({
    required String employeeId,
    String? logo,
    String? primaryColor,
    String? secondaryColor,
    String? fontEnglish,
    String? fontArabic,
  }) async {
    showLoadingIndicator();
    emit(state.copyWith(status: CompanyStatus.loading));

    try {
      final branding = EmployeeBrandingModel(
        employeeId: employeeId,
        logo: logo,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        fontEnglish: fontEnglish,
        fontArabic: fontArabic,
      );

      await employeeBrandingRepository.saveEmployeeBranding(branding);
      emit(state.copyWith(employeeBranding: branding));
      _applyEmployeeBrandingToStorage();

      themeController.updatePrimaryColor();
      themeController.updateSecondaryColor();
      themeController.updateFonts();

      hideLoadingIndicator();
      emit(state.copyWith(
        status: CompanyStatus.success,
        successMessage: 'Personal branding saved successfully',
      ));

      // Restart app to apply font changes.
      if (fontEnglish != null || fontArabic != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        RestartWidget.restartApp(Get.context!);
      }
    } catch (e) {
      hideLoadingIndicator();
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: 'Failed to save personal branding: $e',
      ));
    }
  }

  Future<void> resetEmployeeBrandingToCompany(String employeeId) async {
    showLoadingIndicator();
    emit(state.copyWith(status: CompanyStatus.loading));

    try {
      final c = state.company;
      await employeeBrandingRepository.resetToCompanyBranding(
        employeeId: employeeId,
        companyLogo: c?.companyLogo?.companyLogo?.lastOrNull,
        companyPrimaryColor: c?.primaryColor?.primaryColor?.lastOrNull,
        companySecondaryColor: c?.secondaryColor?.secondaryColor?.lastOrNull,
        companyFontEnglish: c?.englishFont?.englishFont?.lastOrNull,
        companyFontArabic: c?.arabicFont?.arabicFont?.lastOrNull,
      );

      await loadEmployeeBranding(employeeId);

      themeController.updatePrimaryColor();
      themeController.updateSecondaryColor();
      themeController.updateFonts();

      hideLoadingIndicator();
      emit(state.copyWith(
        status: CompanyStatus.success,
        successMessage: 'Personal branding reset to company defaults',
      ));

      await Future.delayed(const Duration(milliseconds: 500));
      RestartWidget.restartApp(Get.context!);
    } catch (e) {
      hideLoadingIndicator();
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: 'Failed to reset branding: $e',
      ));
    }
  }

  // ───────────────────────────── Company CRUD ───────────────────────────────

  Future<void> addCompany(CompanyModel companyModel, String companyId) async {
    final CollectionReference companyCollection =
        db.collection(ApiConstants.company);

    await companyCollection
        .doc(companyId)
        .set(companyModel.toMap(), SetOptions(merge: true));

    systemLogsController.systemLogsAction("update company info");

    emit(state.copyWith(
      company: companyModel,
      status: CompanyStatus.success,
    ));
  }

  Future<CompanyModel?> getCompany({
    String? companyName,
    bool shouldRestart = false,
  }) async {
    emit(state.copyWith(status: CompanyStatus.loading));

    try {
      String companyId = companyName ?? ApiConstants.baseUri.split("/").last;
      if (companyId.isEmpty) companyId = "70843020";

      final CollectionReference companyCollection =
          db.collection(ApiConstants.company);
      final DocumentSnapshot companySnapshot =
          await companyCollection.doc(companyId).get();

      if (!companySnapshot.exists) {
        emit(state.copyWith(status: CompanyStatus.failure));
        return null;
      }

      final data = companySnapshot.data() as Map<String, dynamic>;
      final loaded = CompanyModel.fromMap(data);

      emit(state.copyWith(company: loaded, status: CompanyStatus.success));

      // Mirror the loaded company into the form fields.
      _populateFormFields(loaded);

      if (loaded.status == 'active') {
        _syncStorageFromFirebase();

        themeController.updatePrimaryColor();
        themeController.updateSecondaryColor();
        themeController.updateFonts();

        if (shouldRestart) {
          await Future.delayed(const Duration(milliseconds: 300));
          RestartWidget.restartApp(Get.context!);
        }
      } else {
        _clearBrandingStorage();
      }

      return loaded;
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in getCompany: $e\n$stackTrace');
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: 'Failed to load company: $e',
      ));
      return null;
    }
  }

  // ───────────────────────────── Storage sync ───────────────────────────────

  void _syncStorageFromFirebase() {
    final c = state.company;
    if (c == null) return;

    storage.write('font', c.englishFont?.englishFont?.lastOrNull?.capitalize);
    storage.write('font_arabic', c.arabicFont?.arabicFont?.lastOrNull?.capitalize);
    storage.write('primaryColor', c.primaryColor?.primaryColor?.lastOrNull);
    storage.write('secondaryColor', c.secondaryColor?.secondaryColor?.lastOrNull);
    storage.write('logo', c.companyLogo?.companyLogo?.lastOrNull);
  }

  void _clearBrandingStorage() {
    storage.write('font', null);
    storage.write('font_arabic', null);
    storage.write('primaryColor', null);
    storage.write('secondaryColor', null);
    storage.write('logo', null);
  }

  /// Mirrors the loaded company into the form-field slice of state.
  /// (Was `_populateControllers()`, which wrote into TextEditingControllers.)
  void _populateFormFields(CompanyModel c) {
    emit(state.copyWith(
      companyName: c.companyName?.companyName?.lastOrNull ?? '',
      taxNumber: c.taxNumber?.taxNumber?.lastOrNull ?? '',
      country: c.country?.country?.lastOrNull ?? '',
      city: c.city?.city?.lastOrNull ?? '',
      stateOrProvince: c.province?.province?.lastOrNull ?? '',
      email: c.email?.emails?.lastOrNull ?? '',
      phone: c.phone?.phones?.lastOrNull ?? '',
      streetAddress: c.companyAddress?.address?.lastOrNull ?? '',
      code: c.zipCode?.zipCode?.lastOrNull ?? '',
      contactFirstName: c.firstName?.firstNames?.lastOrNull ?? '',
      contactLastName: c.lastName?.lastNames?.lastOrNull ?? '',
      // Contact email/phone share the company's fields in this model shape.
      contactEmail: c.email?.emails?.lastOrNull ?? '',
      contactPhone: c.phone?.phones?.lastOrNull ?? '',
    ));
  }

  // ─────────────────────────────── Mutations ────────────────────────────────

  /// Persists the unsaved branding selections (logo, colors, fonts).
  Future<void> updateCompanyModel() async {
    if (state.company == null) {
      await getCompany(shouldRestart: false);
      if (state.company == null) {
        emit(state.copyWith(
          status: CompanyStatus.failure,
          errorMessage: 'Company data not loaded. Please try again.',
        ));
        return;
      }
    }

    showLoadingIndicator();
    emit(state.copyWith(status: CompanyStatus.loading));

    try {
      final c = state.company!;

      if (state.imageUrl != null) {
        c.companyLogo!.companyLogo!.add(state.imageUrl);
        c.companyLogo!.timestamps!.add(Timestamp.now());
      }

      c.status = 'active';

      if (state.primaryColor != null) {
        c.primaryColor!.primaryColor!
            .add('0x${state.primaryColor!.value.toRadixString(16)}');
        c.primaryColor!.timestamps!.add(Timestamp.now());
      }

      if (state.secondaryColor != null) {
        c.secondaryColor!.secondaryColor!
            .add('0x${state.secondaryColor!.value.toRadixString(16)}');
        c.secondaryColor!.timestamps!.add(Timestamp.now());
      }

      if (state.selectedEnglishFont != null) {
        c.englishFont!.englishFont!.add(state.selectedEnglishFont!.toLowerCase());
        c.englishFont!.timestamps!.add(Timestamp.now());
      }

      if (state.selectedArabicFont != null) {
        c.arabicFont!.arabicFont!.add(state.selectedArabicFont!.toLowerCase());
        c.arabicFont!.timestamps!.add(Timestamp.now());
      }

      await addCompany(c, ApiConstants.baseUri.split("/").last);
      await getCompany(shouldRestart: true);

      hideLoadingIndicator();
      emit(state.copyWith(
        status: CompanyStatus.success,
        successMessage: 'Company branding updated successfully',
      ));
    } catch (e, stackTrace) {
      hideLoadingIndicator();
      debugPrint('❌ updateCompanyModel: $e\n$stackTrace');
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: 'Failed to update company branding: $e',
      ));
    }
  }

  /// Persists the company-information form. Reads the form values straight out
  /// of state (was `companyName.text`, etc.).
  Future<void> updateCompanyInformation() async {
    final c = state.company;
    if (c == null) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: 'Company data not loaded. Please try again.',
      ));
      return;
    }

    showLoadingIndicator();
    emit(state.copyWith(status: CompanyStatus.loading));

    try {
      final now = Timestamp.now();

      void put(String value, List<String?>? target, List<Timestamp?>? stamps) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return;
        target?.add(trimmed);
        stamps?.add(now);
      }

      put(state.companyName, c.companyName?.companyName, c.companyName?.timestamps);
      put(state.taxNumber, c.taxNumber?.taxNumber, c.taxNumber?.timestamps);
      put(state.country, c.country?.country, c.country?.timestamps);
      put(state.city, c.city?.city, c.city?.timestamps);
      put(state.stateOrProvince, c.province?.province, c.province?.timestamps);
      put(state.email, c.email?.emails, c.email?.timestamps);
      put(state.phone, c.phone?.phones, c.phone?.timestamps);
      put(state.streetAddress, c.companyAddress?.address,
          c.companyAddress?.timestamps);
      put(state.code, c.zipCode?.zipCode, c.zipCode?.timestamps);
      put(state.contactFirstName, c.firstName?.firstNames, c.firstName?.timestamps);
      put(state.contactLastName, c.lastName?.lastNames, c.lastName?.timestamps);

      await addCompany(c, ApiConstants.baseUri.split("/").last);
      await getCompany(shouldRestart: false);

      hideLoadingIndicator();
      emit(state.copyWith(
        status: CompanyStatus.success,
        successMessage: 'Company information updated successfully',
      ));
    } catch (e, stackTrace) {
      hideLoadingIndicator();
      debugPrint('❌ updateCompanyInformation: $e\n$stackTrace');
      emit(state.copyWith(
        status: CompanyStatus.failure,
        errorMessage: 'Failed to update company information: $e',
      ));
    }
  }
}
