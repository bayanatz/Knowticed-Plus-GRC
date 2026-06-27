/// ************************ FILE INFO ********************************///
/// File Name: add_company_controller.dart
/// Author: Mohamed Elrashidy
/// refactored at: 11/12/2024
/// Updated by: Amr Mesbah - Added employee personal branding support

import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:demo_app/core/constants/system_actions.dart';
import 'package:demo_app/core/network/api_constants.dart';
import 'package:demo_app/features/settings/data/models/company_model/company_model.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/restart_widget.dart';
import 'package:demo_app/features/roles/system_logs/controller/system_logs_controller.dart';
import 'package:demo_app/core/helper/employees/employee_branding/data/repo/employee_branding_repository.dart';
import 'package:demo_app/core/helper/employees/employee_branding/domain/model.dart';

class CompanyControllerPersonal extends GetxController with StateMixin {
  final SystemLogsController systemLogsController = Get.find<SystemLogsController>();
  int brandingSelectedIndex = 0;
  String? selectedEnglishFont;
  String? selectedArabicFont;
  Color? primaryColor;
  Color? secondaryColor;
  String? imageUrl;

  // Company information text fields controllers
  TextEditingController companyName = TextEditingController();
  TextEditingController taxNumber = TextEditingController();
  TextEditingController birthDate = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController stateOrProvince = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController streetAddress = TextEditingController();
  TextEditingController code = TextEditingController();

  // Contact information text fields controllers
  TextEditingController contactFirstName = TextEditingController();
  TextEditingController contactLastName = TextEditingController();
  TextEditingController contactEmail = TextEditingController();
  TextEditingController contactPhone = TextEditingController();

  // FirebaseFirestore instance for interacting with Firestore.
  FirebaseFirestore db = FirebaseFirestore.instance;
  Rx<CompanyModel> companyModel = CompanyModel().obs;
  CompanyModel? company;
  final storage = GetStorage();

  // ✅ NEW: Employee branding repository
  final EmployeeBrandingRepository employeeBrandingRepository = EmployeeBrandingRepository();

  // ✅ NEW: Current employee's branding
  EmployeeBrandingModel? employeeBranding;

  @override
  void onInit() {
    super.onInit();
    print('🔵 ===== CompanyController onInit START =====');
    print('🔵 Loading company without restart');

    // Load company data asynchronously after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getCompany(shouldRestart: false);
      print('🔵 Company loaded in onInit: ${company?.companyName?.companyName?.lastOrNull}');
      update(); // Notify listeners that data is ready
    });

    print('🔵 ===== CompanyController onInit END =====');
  }

  @override
  void onClose() {
    print('🔵 CompanyController onClose - disposing controllers');
    companyName.dispose();
    taxNumber.dispose();
    birthDate.dispose();
    country.dispose();
    city.dispose();
    stateOrProvince.dispose();
    email.dispose();
    phone.dispose();
    streetAddress.dispose();
    code.dispose();
    contactFirstName.dispose();
    contactLastName.dispose();
    contactEmail.dispose();
    contactPhone.dispose();
    super.onClose();
  }

  // ✅ NEW METHOD: Initialize Employee_Data collection (call once on app start)
  Future<void> initializeEmployeeDataCollection() async {
    print('🔄 ===== INITIALIZE EMPLOYEE DATA COLLECTION =====');

    // Check if already initialized
    bool isInitialized = await employeeBrandingRepository.isInitialized();

    if (isInitialized) {
      print('ℹ️ Employee_Data collection already initialized');
      return;
    }

    print('🔄 Initializing Employee_Data collection...');

    // Get company branding to use as defaults
    String? companyLogo = company?.companyLogo?.companyLogo?.lastOrNull;
    String? primaryColor = company?.primaryColor?.primaryColor?.lastOrNull;
    String? secondaryColor = company?.secondaryColor?.secondaryColor?.lastOrNull;
    String? fontEnglish = company?.englishFont?.englishFont?.lastOrNull;
    String? fontArabic = company?.arabicFont?.arabicFont?.lastOrNull;

    await employeeBrandingRepository.initializeEmployeeDataCollection(
      companyLogo: companyLogo,
      companyPrimaryColor: primaryColor,
      companySecondaryColor: secondaryColor,
      companyFontEnglish: fontEnglish,
      companyFontArabic: fontArabic,
    );

    print('✅ Employee_Data collection initialized');
  }

  // ✅ NEW METHOD: Load employee branding (call on login)
  Future<void> loadEmployeeBranding(String employeeId) async {
    print('🔄 ===== LOAD EMPLOYEE BRANDING =====');
    print('🔄 Employee ID: $employeeId');

    try {
      employeeBranding = await employeeBrandingRepository.getEmployeeBranding(employeeId);

      if (employeeBranding != null) {
        print('✅ Employee branding loaded');

        // Apply employee branding to storage
        _applyEmployeeBrandingToStorage();
      } else {
        print('ℹ️ No employee branding found, using company branding');

        // Use company branding as fallback
        _applyCompanyBrandingToStorage();
      }

      update();
    } catch (e) {
      print('❌ ERROR loading employee branding: $e');

      // Fallback to company branding
      _applyCompanyBrandingToStorage();
    }
  }

  // ✅ NEW METHOD: Apply employee branding to GetStorage
  void _applyEmployeeBrandingToStorage() {
    print('🔄 Applying employee branding to storage...');

    if (employeeBranding == null) return;

    storage.write('logo', employeeBranding!.logo);
    storage.write('primaryColor', employeeBranding!.primaryColor);
    storage.write('secondaryColor', employeeBranding!.secondaryColor);
    storage.write('font', employeeBranding!.fontEnglish?.capitalize);
    storage.write('font_arabic', employeeBranding!.fontArabic?.capitalize);

    print('✅ Employee branding applied to storage');
    print('   Logo: ${employeeBranding!.logo}');
    print('   Primary Color: ${employeeBranding!.primaryColor}');
    print('   Secondary Color: ${employeeBranding!.secondaryColor}');
    print('   Font English: ${employeeBranding!.fontEnglish}');
    print('   Font Arabic: ${employeeBranding!.fontArabic}');
  }

  // ✅ NEW METHOD: Apply company branding to GetStorage (fallback)
  void _applyCompanyBrandingToStorage() {
    print('🔄 Applying company branding to storage (fallback)...');

    if (company == null || company!.status != 'active') {
      _clearBrandingStorage();
      return;
    }

    _syncStorageFromFirebase();
  }

  // ✅ NEW METHOD: Save employee branding
  Future<void> saveEmployeeBranding({
    required String employeeId,
    String? logo,
    String? primaryColor,
    String? secondaryColor,
    String? fontEnglish,
    String? fontArabic,
  }) async {
    print('💾 ===== SAVE EMPLOYEE BRANDING =====');

    showLoadingIndicator();

    try {
      // Create or update employee branding
      EmployeeBrandingModel branding = EmployeeBrandingModel(
        employeeId: employeeId,
        logo: logo,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        fontEnglish: fontEnglish,
        fontArabic: fontArabic,
      );

      await employeeBrandingRepository.saveEmployeeBranding(branding);

      // Update local reference
      employeeBranding = branding;

      // Apply to storage
      _applyEmployeeBrandingToStorage();

      // Update theme
      themeController.updatePrimaryColor();
      themeController.updateSecondaryColor();
      themeController.updateFonts();

      hideLoadingIndicator();

      Get.snackbar(
        'Success',
        'Personal branding saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Restart app to apply font changes
      if (fontEnglish != null || fontArabic != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        RestartWidget.restartApp(Get.context!);
      }

      print('✅ Employee branding saved and applied');
    } catch (e) {
      hideLoadingIndicator();

      print('❌ ERROR saving employee branding: $e');

      Get.snackbar(
        'Error',
        'Failed to save personal branding: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ✅ NEW METHOD: Reset employee branding to company defaults
  Future<void> resetEmployeeBrandingToCompany(String employeeId) async {
    print('🔄 ===== RESET EMPLOYEE BRANDING =====');

    showLoadingIndicator();

    try {
      String? companyLogo = company?.companyLogo?.companyLogo?.lastOrNull;
      String? primaryColor = company?.primaryColor?.primaryColor?.lastOrNull;
      String? secondaryColor = company?.secondaryColor?.secondaryColor?.lastOrNull;
      String? fontEnglish = company?.englishFont?.englishFont?.lastOrNull;
      String? fontArabic = company?.arabicFont?.arabicFont?.lastOrNull;

      await employeeBrandingRepository.resetToCompanyBranding(
        employeeId: employeeId,
        companyLogo: companyLogo,
        companyPrimaryColor: primaryColor,
        companySecondaryColor: secondaryColor,
        companyFontEnglish: fontEnglish,
        companyFontArabic: fontArabic,
      );

      // Reload employee branding
      await loadEmployeeBranding(employeeId);

      // Update theme
      themeController.updatePrimaryColor();
      themeController.updateSecondaryColor();
      themeController.updateFonts();

      hideLoadingIndicator();

      Get.snackbar(
        'Success',
        'Personal branding reset to company defaults',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Restart app
      await Future.delayed(const Duration(milliseconds: 500));
      RestartWidget.restartApp(Get.context!);

      print('✅ Employee branding reset complete');
    } catch (e) {
      hideLoadingIndicator();

      print('❌ ERROR resetting employee branding: $e');

      Get.snackbar(
        'Error',
        'Failed to reset branding: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future addCompany(CompanyModel companyModel, String companyId) async {
    print('💾 ===== ADD COMPANY START =====');
    print('💾 Company ID: $companyId');
    print('💾 Company Name: ${companyModel.companyName?.companyName?.lastOrNull}');

    // Update the controller state.
    update();

    final CollectionReference companyCollection =
    db.collection(ApiConstants.company);

    await companyCollection
        .doc(companyId)
        .set((companyModel).toMap(), SetOptions(merge: true));

    update();
    systemLogsController.systemLogsAction(SystemActions.updateCompanyInfo);

    // Set the controller status to success.
    change(companyModel, status: RxStatus.success());

    print('💾 ===== ADD COMPANY END =====');
  }

  Future<CompanyModel?> getCompany({String? companyName, bool shouldRestart = false}) async {
    print('🔍 ===== GET COMPANY START =====');
    print('🔍 shouldRestart: $shouldRestart');

    try {
      // Get companyId with proper fallback
      String companyId = companyName ?? ApiConstants.baseUri.split("/").last;

      // If companyId is empty, use the default ID
      if (companyId.isEmpty) {
        companyId = "70843020";
        print('🔍 companyId was empty, using default: $companyId');
      } else {
        print('🔍 companyId: $companyId');
      }

      final CollectionReference companyCollection =
      db.collection(ApiConstants.company);

      print('🔍 Fetching document from Firestore...');
      DocumentSnapshot companySnapshot =
      await companyCollection.doc(companyId).get();

      print('🔍 Document exists: ${companySnapshot.exists}');

      if (companySnapshot.exists) {
        print('🔍 Document retrieved successfully');

        Map<String, dynamic> data = companySnapshot.data() as Map<String, dynamic>;

        // Debug: Check each field
        print('🔍 Document fields:');
        data.forEach((key, value) {
          print('🔍   - $key: ${value != null ? "✓" : "✗ (null)"}');
        });

        company = CompanyModel.fromMap(data);
        print('🔍 Company model created successfully');
        print('🔍 Company name: ${company!.companyName?.companyName?.lastOrNull}');
        print('🔍 Company status: ${company!.status}');
        print('🔍 English font: ${company!.englishFont?.englishFont?.lastOrNull}');
        print('🔍 Arabic font: ${company!.arabicFont?.arabicFont?.lastOrNull}');
        print('🔍 Primary color: ${company!.primaryColor?.primaryColor?.lastOrNull}');
        print('🔍 Secondary color: ${company!.secondaryColor?.secondaryColor?.lastOrNull}');

        // Populate text field controllers with company data
        _populateControllers();

        // ✅ FIXED: Always sync GetStorage from Firebase if company is active
        if (company!.status == 'active') {
          print('🔍 Company is active - syncing GetStorage from Firebase');
          _syncStorageFromFirebase();

          // Update theme
          print('🔍 Updating theme...');
          themeController.updatePrimaryColor();
          themeController.updateSecondaryColor();
          themeController.updateFonts();

          // Only restart if explicitly requested
          if (shouldRestart) {
            print('🔍 shouldRestart is true - preparing to restart app');
            await Future.delayed(const Duration(milliseconds: 300));
            print('🔍 Restarting app...');
            RestartWidget.restartApp(Get.context!);
          } else {
            print('🔍 shouldRestart is false - skipping app restart');
          }
        } else {
          print('🔍 Company is inactive - clearing branding from storage');
          _clearBrandingStorage();
        }

        // Notify listeners
        update();
        print('🔍 ===== GET COMPANY END (SUCCESS) =====');
        return company;
      } else {
        print('🔍 ⚠️ ERROR: Document does not exist!');
        print('🔍 ===== GET COMPANY END (NO DOCUMENT) =====');
        return null;
      }
    } catch (e, stackTrace) {
      print('🔍 ❌ ERROR in getCompany: $e');
      print('🔍 Stack trace: $stackTrace');
      print('🔍 ===== GET COMPANY END (ERROR) =====');
      return null;
    }
  }

  // ✅ Sync GetStorage from Firebase (company branding)
  void _syncStorageFromFirebase() {
    print('');
    print('🔄 ==========================================');
    print('🔄 SYNC STORAGE FROM FIREBASE START');
    print('🔄 ==========================================');

    // Sync English font
    String? englishFont = company!.englishFont?.englishFont?.lastOrNull?.capitalize;
    print('🔄 English font from company: $englishFont');
    storage.write('font', englishFont);
    print('🔄 ✅ Wrote to storage - font: ${storage.read('font')}');

    // Sync Arabic font
    String? arabicFont = company!.arabicFont?.arabicFont?.lastOrNull?.capitalize;
    print('🔄 Arabic font from company: $arabicFont');
    storage.write('font_arabic', arabicFont);
    print('🔄 ✅ Wrote to storage - font_arabic: ${storage.read('font_arabic')}');

    // Sync Primary color
    String? primaryColorValue = company!.primaryColor?.primaryColor?.lastOrNull;
    print('🔄 Primary color from company: $primaryColorValue');
    storage.write('primaryColor', primaryColorValue);
    print('🔄 ✅ Wrote to storage - primaryColor: ${storage.read('primaryColor')}');

    // Sync Secondary color
    String? secondaryColorValue = company!.secondaryColor?.secondaryColor?.lastOrNull;
    print('🔄 Secondary color from company: $secondaryColorValue');
    storage.write('secondaryColor', secondaryColorValue);
    print('🔄 ✅ Wrote to storage - secondaryColor: ${storage.read('secondaryColor')}');

    // Sync Logo
    String? logoUrl = company!.companyLogo?.companyLogo?.lastOrNull;
    print('🔄 Logo URL from company: $logoUrl');
    print('🔄 Logo is null: ${logoUrl == null}');
    print('🔄 Logo is empty: ${logoUrl?.isEmpty ?? true}');
    print('🔄 Logo length: ${logoUrl?.length ?? 0}');

    print('🔄 Writing logo to storage...');
    storage.write('logo', logoUrl);

    print('🔄 Reading back from storage to verify...');
    final verifyLogo = storage.read('logo');
    print('🔄 ✅ Verified - logo in storage: $verifyLogo');
    print('🔄 Verification - logo matches: ${verifyLogo == logoUrl}');

    print('🔄 Calling update() to trigger GetBuilder rebuild...');
    update();
    print('🔄 ✅ update() called - GetBuilder should rebuild now');

    print('🔄 ==========================================');
    print('🔄 SYNC STORAGE FROM FIREBASE END');
    print('🔄 ==========================================');
    print('');
  }

  // ✅ Clear branding from GetStorage
  void _clearBrandingStorage() {
    print('🗑️ ===== CLEAR BRANDING STORAGE START =====');

    storage.write('font', null);
    storage.write('font_arabic', null);
    storage.write('primaryColor', null);
    storage.write('secondaryColor', null);
    storage.write('logo', null);

    print('🗑️ ✅ Branding cleared from GetStorage');
    print('🗑️ ===== CLEAR BRANDING STORAGE END =====');
  }

  // ✅ Populate controllers using correct nested model structure
  void _populateControllers() {
    print('📝 ===== POPULATE CONTROLLERS START =====');

    if (company == null) {
      print('📝 ⚠️ Company is null, cannot populate controllers');
      return;
    }

    // Company Name (from CompanyName model)
    companyName.text = company!.companyName?.companyName?.lastOrNull ?? '';
    print('📝 Company Name: ${companyName.text}');

    // Tax Number (from TaxNumber model)
    taxNumber.text = company!.taxNumber?.taxNumber?.lastOrNull ?? '';
    print('📝 Tax Number: ${taxNumber.text}');

    // Country (from Country model)
    country.text = company!.country?.country?.lastOrNull ?? '';
    print('📝 Country: ${country.text}');

    // City (from City model)
    city.text = company!.city?.city?.lastOrNull ?? '';
    print('📝 City: ${city.text}');

    // State/Province (from Province model)
    stateOrProvince.text = company!.province?.province?.lastOrNull ?? '';
    print('📝 State/Province: ${stateOrProvince.text}');

    // Email (from Email model)
    email.text = company!.email?.emails?.lastOrNull ?? '';
    print('📝 Email: ${email.text}');

    // Phone (from MobilePhone model)
    phone.text = company!.phone?.phones?.lastOrNull ?? '';
    print('📝 Phone: ${phone.text}');

    // Street Address (from Address model)
    streetAddress.text = company!.companyAddress?.address?.lastOrNull ?? '';
    print('📝 Street Address: ${streetAddress.text}');

    // Postal Code (from ZipCode model)
    code.text = company!.zipCode?.zipCode?.lastOrNull ?? '';
    print('📝 Postal Code: ${code.text}');

    // Contact First Name (from FirstName model)
    contactFirstName.text = company!.firstName?.firstNames?.lastOrNull ?? '';
    print('📝 Contact First Name: ${contactFirstName.text}');

    // Contact Last Name (from LastName model)
    contactLastName.text = company!.lastName?.lastNames?.lastOrNull ?? '';
    print('📝 Contact Last Name: ${contactLastName.text}');

    // Contact Email (from Email model - same as company email in this structure)
    contactEmail.text = company!.email?.emails?.lastOrNull ?? '';
    print('📝 Contact Email: ${contactEmail.text}');

    // Contact Phone (from MobilePhone model - same as company phone in this structure)
    contactPhone.text = company!.phone?.phones?.lastOrNull ?? '';
    print('📝 Contact Phone: ${contactPhone.text}');

    print('📝 ✅ Controllers populated successfully');
    print('📝 ===== POPULATE CONTROLLERS END =====');
  }

  updateCompanyModel() async {
    print('========== UPDATE COMPANY MODEL START ==========');
    print('1. company is null? ${company == null}');
    print('2. imageUrl: $imageUrl');
    print('3. primaryColor: $primaryColor');
    print('4. secondaryColor: $secondaryColor');
    print('5. selectedEnglishFont: $selectedEnglishFont');
    print('6. selectedArabicFont: $selectedArabicFont');

    // Check if company is null before proceeding
    if (company == null) {
      print('ERROR: Company is null. Attempting to load company data...');
      await getCompany(shouldRestart: false);
      print('After getCompany(), company is null? ${company == null}');

      if (company == null) {
        print('ERROR: Still null after getCompany(). Cannot proceed.');
        Get.snackbar(
          'Error',
          'Company data not loaded. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    print('7. Company loaded successfully: ${company!.companyName?.companyName?.lastOrNull}');
    showLoadingIndicator();

    try {
      if (imageUrl != null) {
        print('8. Adding imageUrl to companyLogo');
        company!.companyLogo!.companyLogo!.add(imageUrl);
        company!.companyLogo!.timestamps!.add(Timestamp.now());
      }

      print('9. Setting company status to active');
      company!.status = 'active';

      if (primaryColor != null) {
        print('10. Adding primaryColor: ${primaryColor!.value.toRadixString(16)}');
        String colorHex = '0x${primaryColor!.value.toRadixString(16)}';
        print('10a. Color hex string: $colorHex');
        print('10b. Current primaryColor list before add: ${company!.primaryColor!.primaryColor}');

        company!.primaryColor!.primaryColor!.add(colorHex);
        company!.primaryColor!.timestamps!.add(Timestamp.now());

        print('10c. Current primaryColor list after add: ${company!.primaryColor!.primaryColor}');
      }

      if (secondaryColor != null) {
        print('11. Adding secondaryColor: ${secondaryColor!.value.toRadixString(16)}');
        String colorHex = '0x${secondaryColor!.value.toRadixString(16)}';
        print('11a. Color hex string: $colorHex');
        print('11b. Current secondaryColor list before add: ${company!.secondaryColor!.secondaryColor}');

        company!.secondaryColor!.secondaryColor!.add(colorHex);
        company!.secondaryColor!.timestamps!.add(Timestamp.now());

        print('11c. Current secondaryColor list after add: ${company!.secondaryColor!.secondaryColor}');
      }

      if (selectedEnglishFont != null) {
        print('12. Adding englishFont: $selectedEnglishFont');
        company!.englishFont!.englishFont!.add(selectedEnglishFont!.toLowerCase());
        company!.englishFont!.timestamps!.add(Timestamp.now());
        print('12a. Current englishFont list: ${company!.englishFont!.englishFont}');
      }

      if (selectedArabicFont != null) {
        print('13. Adding arabicFont: $selectedArabicFont');
        company!.arabicFont!.arabicFont!.add(selectedArabicFont!.toLowerCase());
        company!.arabicFont!.timestamps!.add(Timestamp.now());
        print('13a. Current arabicFont list: ${company!.arabicFont!.arabicFont}');
      }

      print('14. Calling addCompany to save to Firebase...');
      await addCompany(company!, ApiConstants.baseUri.split("/").last);
      print('15. addCompany completed');

      print('16. Calling getCompany to refresh data and restart...');
      await getCompany(shouldRestart: true);
      print('17. getCompany completed');

      // Check if list is not empty before accessing .last
      if (company!.primaryColor!.primaryColor!.isNotEmpty) {
        print('18. Final primaryColor: ${company!.primaryColor!.primaryColor!.last}');
      } else {
        print('18. Final primaryColor: No primary color set');
      }

      if (company!.secondaryColor!.secondaryColor!.isNotEmpty) {
        print('19. Final secondaryColor: ${company!.secondaryColor!.secondaryColor!.last}');
      } else {
        print('19. Final secondaryColor: No secondary color set');
      }

      hideLoadingIndicator();

      Get.snackbar(
        'Success',
        'Company branding updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('========== UPDATE COMPANY MODEL END (SUCCESS) ==========');
    } catch (e, stackTrace) {
      hideLoadingIndicator();
      print('========== UPDATE COMPANY MODEL END (ERROR) ==========');
      print('ERROR: $e');
      print('Stack trace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to update company branding: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ✅ Update company information using correct nested model structure
  Future<void> updateCompanyInformation() async {
    print('📝 ===== UPDATE COMPANY INFORMATION START =====');

    if (company == null) {
      print('📝 ERROR: Company is null');
      Get.snackbar(
        'Error',
        'Company data not loaded. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    showLoadingIndicator();

    try {
      // Update Company Name
      if (companyName.text.trim().isNotEmpty) {
        company!.companyName?.companyName?.add(companyName.text.trim());
        company!.companyName?.timestamps?.add(Timestamp.now());
        print('📝 Updated Company Name: ${companyName.text.trim()}');
      }

      // Update Tax Number
      if (taxNumber.text.trim().isNotEmpty) {
        company!.taxNumber?.taxNumber?.add(taxNumber.text.trim());
        company!.taxNumber?.timestamps?.add(Timestamp.now());
        print('📝 Updated Tax Number: ${taxNumber.text.trim()}');
      }

      // Update Country
      if (country.text.trim().isNotEmpty) {
        company!.country?.country?.add(country.text.trim());
        company!.country?.timestamps?.add(Timestamp.now());
        print('📝 Updated Country: ${country.text.trim()}');
      }

      // Update City
      if (city.text.trim().isNotEmpty) {
        company!.city?.city?.add(city.text.trim());
        company!.city?.timestamps?.add(Timestamp.now());
        print('📝 Updated City: ${city.text.trim()}');
      }

      // Update Province
      if (stateOrProvince.text.trim().isNotEmpty) {
        company!.province?.province?.add(stateOrProvince.text.trim());
        company!.province?.timestamps?.add(Timestamp.now());
        print('📝 Updated Province: ${stateOrProvince.text.trim()}');
      }

      // Update Email
      if (email.text.trim().isNotEmpty) {
        company!.email?.emails?.add(email.text.trim());
        company!.email?.timestamps?.add(Timestamp.now());
        print('📝 Updated Email: ${email.text.trim()}');
      }

      // Update Phone
      if (phone.text.trim().isNotEmpty) {
        company!.phone?.phones?.add(phone.text.trim());
        company!.phone?.timestamps?.add(Timestamp.now());
        print('📝 Updated Phone: ${phone.text.trim()}');
      }

      // Update Street Address
      if (streetAddress.text.trim().isNotEmpty) {
        company!.companyAddress?.address?.add(streetAddress.text.trim());
        company!.companyAddress?.timestamps?.add(Timestamp.now());
        print('📝 Updated Street Address: ${streetAddress.text.trim()}');
      }

      // Update Postal Code
      if (code.text.trim().isNotEmpty) {
        company!.zipCode?.zipCode?.add(code.text.trim());
        company!.zipCode?.timestamps?.add(Timestamp.now());
        print('📝 Updated Postal Code: ${code.text.trim()}');
      }

      // Update Contact First Name
      if (contactFirstName.text.trim().isNotEmpty) {
        company!.firstName?.firstNames?.add(contactFirstName.text.trim());
        company!.firstName?.timestamps?.add(Timestamp.now());
        print('📝 Updated Contact First Name: ${contactFirstName.text.trim()}');
      }

      // Update Contact Last Name
      if (contactLastName.text.trim().isNotEmpty) {
        company!.lastName?.lastNames?.add(contactLastName.text.trim());
        company!.lastName?.timestamps?.add(Timestamp.now());
        print('📝 Updated Contact Last Name: ${contactLastName.text.trim()}');
      }

      print('📝 Saving updated company information...');
      await addCompany(company!, ApiConstants.baseUri.split("/").last);

      print('📝 Refreshing company data...');
      await getCompany(shouldRestart: false);

      hideLoadingIndicator();

      Get.snackbar(
        'Success',
        'Company information updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('📝 ===== UPDATE COMPANY INFORMATION END (SUCCESS) =====');
    } catch (e, stackTrace) {
      hideLoadingIndicator();
      print('📝 ERROR: $e');
      print('📝 Stack trace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to update company information: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('📝 ===== UPDATE COMPANY INFORMATION END (ERROR) =====');
    }
  }
}