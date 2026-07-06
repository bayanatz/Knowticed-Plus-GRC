/// Module: Settings · Company
/// Description: Controller for the company branding/information section. Reads
///              and writes the company document through the injected
///              [CompanyRepositoryInterface] (no direct Firestore access) and
///              keeps GetStorage / theme branding in sync.
/// Author: Mohamed Elrashidy
/// Date: 11/12/2024
/// Dependencies: bloc, get, CompanyRepository, CompanyModel, ThemeController
/// Revision History:
///   - 11/12/2024 (Mohamed Elrashidy): Initial creation.
///   - (Amr Mesbah): Fixed cross-device branding sync.
///   - 25/06/2026 (Amr Mesbah): Injected CompanyRepository (removed direct
///       Firestore), moved form TextEditingControllers to the page widgets,
///       moved async work out of onInit into init(), surfaced swallowed errors,
///       added explicit return types and headers.
///   - 01/07/2026 (Amr Mesbah): Migrated from GetxController+StateMixin to
///       Cubit (team standard, §16). Nothing external read the StateMixin
///       `.status`/`change()` API (verified — every `.status` call site reads
///       `CompanyModel.status`, a plain string field, not RxStatus), so it
///       was dropped rather than reimplemented. `Rx<CompanyModel> companyModel`
///       is unaffected — Rx/.obs works on any class, not just GetxController.
///       `GetBuilder<CompanyController>` call sites (8, incl. 7 duplicated
///       custom_appbar_mobile.dart copies across features) were converted to
///       `BlocBuilder<CompanyController, CompanyState>(bloc:
///       Get.find<CompanyController>(), ...)`. `update()` → `refresh()`.
///
/// ************************ FILE INFO ********************************///
/// File Name: add_company_controller.dart
/// Purpose: Controller for company branding & information in settings.
/// Author: Mohamed Elrashidy
/// Created At: 11/12/2024
/// Dependencies: CompanyRepositoryInterface, CompanyModel
library;

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:demo_app/core/constants/system_actions.dart';
import 'package:demo_app/core/network/api_constants.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/company_model.dart';
import 'package:demo_app/core/helper/settings/domain/base_repository/company_repository_interface.dart';
import 'package:demo_app/core/helper/settings/data/repository/company_repository.dart';
import 'package:demo_app/core/helper/settings/data/data_source/remote_data_source/company_remote_data_source.dart';
import 'package:demo_app/features/onboarding/welcome_screen/views/mobile_view/nav_bar.dart';

import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/helper/settings/presentation/ui/widgets/restart_widget.dart';

part 'company_state.dart';

class CompanyController extends Cubit<CompanyState> {
  int brandingSelectedIndex = 0;
  String? selectedEnglishFont;
  String? selectedArabicFont;
  Color? primaryColor;
  Color? secondaryColor;
  String? imageUrl;

  /// Company repository. Inject for tests; defaults to the real implementation
  /// so existing `Get.put(CompanyController())` call sites keep working.
  final CompanyRepositoryInterface _repository;

  CompanyController({CompanyRepositoryInterface? repository})
      : _repository =
            repository ?? CompanyRepository(CompanyRemoteDataSource()),
        super(CompanyState());

  Rx<CompanyModel> companyModel = CompanyModel().obs;
  CompanyModel? company;
  final storage = GetStorage();

  /// Notifies BlocBuilder/BlocListener subscribers that a plain field above
  /// changed. Replaces GetX's `update()`.
  void refresh() => emit(CompanyState());

  // Guards the one-time startup load so init() can't re-trigger the branding +
  // forceAppUpdate cascade if it happens to be called more than once.
  bool _initStarted = false;

  /// Explicit async initialization (replaces the old onInit postFrameCallback).
  Future<void> init() async {
    if (_initStarted) return;
    _initStarted = true;
    await getCompany(shouldRestart: false);
    refresh();
  }

  Future<void> addCompany(CompanyModel companyModel, String companyId) async {
    // Update the controller state.
    refresh();

    await _repository.setCompany(
      companyId: companyId,
      data: companyModel.toMap(),
    );

    refresh();
    systemLogsController.systemLogsAction(SystemActions.updateCompanyInfo);
  }

  /// Uploads a company logo file via the repository (no Firebase access in
  /// the widget layer) and stores the resulting URL in [imageUrl].
  Future<String?> uploadLogo({
    required File file,
    required String contentType,
    required String extension,
  }) async {
    try {
      final url = await _repository.uploadLogo(
        file: file,
        contentType: contentType,
        extension: extension,
      );
      imageUrl = url;
      refresh();
      return url;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('CompanyController.uploadLogo failed: $e\n$stackTrace');
      }
      return null;
    }
  }

  Future<CompanyModel?> getCompany({
    String? companyName,
    bool shouldRestart = false,
  }) async {
    try {
      // Get companyId with proper fallback
      String companyId = companyName ?? ApiConstants.baseUri.split("/").last;

      // If companyId is empty, use the default ID
      if (companyId.isEmpty) {
        companyId = "70843020";
      }

      final Map<String, dynamic>? data =
          await _repository.getCompany(companyId: companyId);

      if (data != null) {
        company = CompanyModel.fromMap(data);

        // ✅ Always sync GetStorage from Firebase if company is active
        if (company!.status == 'active') {
          _syncStorageFromFirebase();

          // Update theme
          themeController.updatePrimaryColor();
          themeController.updateSecondaryColor();
          themeController.updateFonts();

          // Only restart if explicitly requested
          if (shouldRestart) {
            await Future.delayed(const Duration(milliseconds: 300));
            RestartWidget.restartApp(Get.context!);
          }
        } else {
          _clearBrandingStorage();
        }

        // Notify listeners
        refresh();

        return company;
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      // Surface instead of swallowing.
      if (kDebugMode) {
        debugPrint('CompanyController.getCompany failed: $e\n$stackTrace');
      }
      return null;
    }
  }

  // ✅ Sync GetStorage from Firebase
  void _syncStorageFromFirebase() {
    // Sync English font
    String? englishFont =
        company!.englishFont?.englishFont?.lastOrNull?.capitalize;
    storage.write('font', englishFont);

    // Sync Arabic font
    String? arabicFont =
        company!.arabicFont?.arabicFont?.lastOrNull?.capitalize;
    storage.write('font_arabic', arabicFont);

    // Sync Primary color
    String? primaryColorValue = company!.primaryColor?.primaryColor?.lastOrNull;
    storage.write('primaryColor', primaryColorValue);

    // Sync Secondary color
    String? secondaryColorValue =
        company!.secondaryColor?.secondaryColor?.lastOrNull;
    storage.write('secondaryColor', secondaryColorValue);

    // Sync Logo
    String? logoUrl = company!.companyLogo?.companyLogo?.lastOrNull;
    storage.write('logo', logoUrl);

    refresh();
  }

  // ✅ Clear branding from GetStorage
  void _clearBrandingStorage() {
    storage.write('font', null);
    storage.write('font_arabic', null);
    storage.write('primaryColor', null);
    storage.write('secondaryColor', null);
    storage.write('logo', null);
  }

  Future<void> updateCompanyModel() async {
    // Check if company is null before proceeding
    if (company == null) {
      await getCompany(shouldRestart: false);

      if (company == null) {
        return;
      }
    }

    showLoadingIndicator();

    try {
      if (imageUrl != null) {
        company!.companyLogo!.companyLogo!.add(imageUrl);
        company!.companyLogo!.timestamps!.add(Timestamp.now());
      }

      company = company!.copyWith(status: 'active');

      if (primaryColor != null) {
        String colorHex = '0x${primaryColor!.value.toRadixString(16)}';
        company!.primaryColor!.primaryColor!.add(colorHex);
        company!.primaryColor!.timestamps!.add(Timestamp.now());
      }

      if (secondaryColor != null) {
        String colorHex = '0x${secondaryColor!.value.toRadixString(16)}';
        company!.secondaryColor!.secondaryColor!.add(colorHex);
        company!.secondaryColor!.timestamps!.add(Timestamp.now());
      }

      if (selectedEnglishFont != null) {
        company!.englishFont!.englishFont!
            .add(selectedEnglishFont!.toLowerCase());
        company!.englishFont!.timestamps!.add(Timestamp.now());
      }

      if (selectedArabicFont != null) {
        company!.arabicFont!.arabicFont!.add(selectedArabicFont!.toLowerCase());
        company!.arabicFont!.timestamps!.add(Timestamp.now());
      }

      await addCompany(company!, ApiConstants.baseUri.split("/").last);

      await getCompany(shouldRestart: true);

      hideLoadingIndicator();
    } catch (e, stackTrace) {
      hideLoadingIndicator();
      // Surface instead of swallowing.
      if (kDebugMode) {
        debugPrint('CompanyController.updateCompanyModel failed: $e\n$stackTrace');
      }
    }
  }
}
