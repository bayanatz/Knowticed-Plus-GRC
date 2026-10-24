/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: edit_page_request_health_logic.dart
/// Description: Logic and event handlers of `_EditPageRequestHealthState` — split out of `edit_page_request_health.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/edit_page_request_health.dart';

// Split from edit_page_request_health.dart to keep every file under 700 lines.

extension _EditPageRequestHealthStateLogic on _EditPageRequestHealthState {
  void _loadEmployeeData() {
    // Get current employee's history data
    // CHANGED 9/10/2026 — null-safe read (was `employee!.email?.last`, which
    // throws if the settings employee has not loaded yet). An unknown email
    // leaves `currentEmployeeHistory` null, which `_submitRequest` already
    // reports with `errorOccurred` instead of crashing.
    String currentUserEmail =
        Get.find<EmployeeController>().employee?.email.lastOrNull ?? '';

    // Find the current employee from the history model
    currentEmployeeHistory =
        employeeController.allNewEmployees?.firstWhereOrNull(
      (emp) => emp.email.isNotEmpty && emp.email.last == currentUserEmail,
    );

    // Initialize Health Insurance Controllers
    String insuranceName = '';
    String policyNumber = '';

    if (currentEmployeeHistory != null) {
      if (currentEmployeeHistory!.insuranceName.isNotEmpty) {
        insuranceName = currentEmployeeHistory!.insuranceName.last;
      }
      if (currentEmployeeHistory!.insurancePolicyNumber.isNotEmpty) {
        policyNumber = currentEmployeeHistory!.insurancePolicyNumber.last;
      }
    }

    insuranceNameController = TextEditingController(text: insuranceName);
    insurancePolicyNumberController = TextEditingController(text: policyNumber);

    // Initialize 1st Emergency Contact Controllers
    String firstContactFirstName = '';
    String firstContactLastName = '';
    String firstContactRelationship = '';
    String firstContactEmail = '';
    String firstContactPhone = '';
    String firstContactLanguage = '';
    String firstContactCountry = '';
    String firstContactProvince = '';
    String firstContactCity = '';
    String firstContactStreet = '';

    if (currentEmployeeHistory != null) {
      if (currentEmployeeHistory!.firstContactFirstName.isNotEmpty) {
        firstContactFirstName =
            currentEmployeeHistory!.firstContactFirstName.last;
      }
      if (currentEmployeeHistory!.firstContactLastName.isNotEmpty) {
        firstContactLastName =
            currentEmployeeHistory!.firstContactLastName.last;
      }
      if (currentEmployeeHistory!.firstContactRelationship.isNotEmpty) {
        firstContactRelationship =
            currentEmployeeHistory!.firstContactRelationship.last;
      }
      if (currentEmployeeHistory!.firstContactEmail.isNotEmpty) {
        firstContactEmail = currentEmployeeHistory!.firstContactEmail.last;
      }
      if (currentEmployeeHistory!.firstContactPhone.isNotEmpty) {
        firstContactPhone = currentEmployeeHistory!.firstContactPhone.last;
      }
      if (currentEmployeeHistory!.firstContactLanguage.isNotEmpty) {
        firstContactLanguage =
            currentEmployeeHistory!.firstContactLanguage.last;
      }
      if (currentEmployeeHistory!.firstContactCountry.isNotEmpty) {
        firstContactCountry = currentEmployeeHistory!.firstContactCountry.last;
      }
      if (currentEmployeeHistory!.firstContactProvince.isNotEmpty) {
        firstContactProvince =
            currentEmployeeHistory!.firstContactProvince.last;
      }
      if (currentEmployeeHistory!.firstContactCity.isNotEmpty) {
        firstContactCity = currentEmployeeHistory!.firstContactCity.last;
      }
      if (currentEmployeeHistory!.firstContactStreet.isNotEmpty) {
        firstContactStreet = currentEmployeeHistory!.firstContactStreet.last;
      }
    }

    firstContactFirstNameController = TextEditingController(
      text: firstContactFirstName,
    );
    firstContactLastNameController = TextEditingController(
      text: firstContactLastName,
    );
    firstContactRelationshipController = TextEditingController(
      text: firstContactRelationship,
    );
    firstContactEmailController = TextEditingController(
      text: firstContactEmail,
    );
    firstContactPhoneController = TextEditingController(
      text: firstContactPhone,
    );
    firstContactLanguageController = TextEditingController(
      text: firstContactLanguage,
    );
    firstContactCountryController = TextEditingController(
      text: firstContactCountry,
    );
    firstContactProvinceController = TextEditingController(
      text: firstContactProvince,
    );
    firstContactCityController = TextEditingController(text: firstContactCity);
    firstContactStreetController = TextEditingController(
      text: firstContactStreet,
    );

    // Initialize 2nd Emergency Contact Controllers
    String secondContactFirstName = '';
    String secondContactLastName = '';
    String secondContactRelationship = '';
    String secondContactEmail = '';
    String secondContactPhone = '';
    String secondContactLanguage = '';
    String secondContactCountry = '';
    String secondContactProvince = '';
    String secondContactCity = '';
    String secondContactStreet = '';

    if (currentEmployeeHistory != null) {
      if (currentEmployeeHistory!.secondContactFirstName.isNotEmpty) {
        secondContactFirstName =
            currentEmployeeHistory!.secondContactFirstName.last;
      }
      if (currentEmployeeHistory!.secondContactLastName.isNotEmpty) {
        secondContactLastName =
            currentEmployeeHistory!.secondContactLastName.last;
      }
      if (currentEmployeeHistory!.secondContactRelationship.isNotEmpty) {
        secondContactRelationship =
            currentEmployeeHistory!.secondContactRelationship.last;
      }
      if (currentEmployeeHistory!.secondContactEmail.isNotEmpty) {
        secondContactEmail = currentEmployeeHistory!.secondContactEmail.last;
      }
      if (currentEmployeeHistory!.secondContactPhone.isNotEmpty) {
        secondContactPhone = currentEmployeeHistory!.secondContactPhone.last;
      }
      if (currentEmployeeHistory!.secondContactLanguage.isNotEmpty) {
        secondContactLanguage =
            currentEmployeeHistory!.secondContactLanguage.last;
      }
      if (currentEmployeeHistory!.secondContactCountry.isNotEmpty) {
        secondContactCountry =
            currentEmployeeHistory!.secondContactCountry.last;
      }
      if (currentEmployeeHistory!.secondContactProvince.isNotEmpty) {
        secondContactProvince =
            currentEmployeeHistory!.secondContactProvince.last;
      }
      if (currentEmployeeHistory!.secondContactCity.isNotEmpty) {
        secondContactCity = currentEmployeeHistory!.secondContactCity.last;
      }
      if (currentEmployeeHistory!.secondContactStreet.isNotEmpty) {
        secondContactStreet = currentEmployeeHistory!.secondContactStreet.last;
      }
    }

    secondContactFirstNameController = TextEditingController(
      text: secondContactFirstName,
    );
    secondContactLastNameController = TextEditingController(
      text: secondContactLastName,
    );
    secondContactRelationshipController = TextEditingController(
      text: secondContactRelationship,
    );
    secondContactEmailController = TextEditingController(
      text: secondContactEmail,
    );
    secondContactPhoneController = TextEditingController(
      text: secondContactPhone,
    );
    secondContactLanguageController = TextEditingController(
      text: secondContactLanguage,
    );
    secondContactCountryController = TextEditingController(
      text: secondContactCountry,
    );
    secondContactProvinceController = TextEditingController(
      text: secondContactProvince,
    );
    secondContactCityController = TextEditingController(
      text: secondContactCity,
    );
    secondContactStreetController = TextEditingController(
      text: secondContactStreet,
    );
  }

  void _submitRequest() async {
    // Block the preview until the REQUIRED fields are filled (9/10/2026: the
    // 2nd emergency contact is optional — empty, or complete once started).
    // Marking as submitted turns the empty fields red so the user
    // can see exactly what is missing.
    if (!_canPreview) {
      rebuild(() => _submitted = true);
      final bool onlySecondContact =
          HealthRequestFormRules.isComplete(_insuranceValues) &&
              HealthRequestFormRules.isComplete(_firstContactValues) &&
              HealthRequestFormRules.isSecondContactIncomplete(
                _secondContactValues,
              );
      _showError(
        onlySecondContact
            ? S.of(context).secondContactIncomplete
            : S.of(context).fillAllRequiredFields,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Collect all changes by comparing old vs new values
      Map<String, dynamic> changes = {};

      if (currentEmployeeHistory == null) {
        _showError(S.of(context).errorOccurred);
        return;
      }

      // Helper function to get last value safely
      String getLastValue(List<String> list) =>
          list.isNotEmpty ? list.last : '';

      // Health Insurance Changes
      String oldInsuranceName = getLastValue(
        currentEmployeeHistory!.insuranceName,
      );
      String newInsuranceName = insuranceNameController.text.trim();
      if (!HealthValueCompare.same(
          'insuranceName', oldInsuranceName, newInsuranceName)) {
        changes['insuranceName'] = {
          'oldValue': oldInsuranceName,
          'newValue': newInsuranceName,
        };
      }

      String oldPolicyNumber = getLastValue(
        currentEmployeeHistory!.insurancePolicyNumber,
      );
      String newPolicyNumber = insurancePolicyNumberController.text.trim();
      if (!HealthValueCompare.same(
          'insurancePolicyNumber', oldPolicyNumber, newPolicyNumber)) {
        changes['insurancePolicyNumber'] = {
          'oldValue': oldPolicyNumber,
          'newValue': newPolicyNumber,
        };
      }

      // 1st Emergency Contact Changes
      if (!HealthValueCompare.same(
          'firstContactFirstName',
          getLastValue(currentEmployeeHistory!.firstContactFirstName),
          firstContactFirstNameController.text.trim())) {
        changes['firstContact_firstName'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.firstContactFirstName,
          ),
          'newValue': firstContactFirstNameController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'firstContactLastName',
          getLastValue(currentEmployeeHistory!.firstContactLastName),
          firstContactLastNameController.text.trim())) {
        changes['firstContact_lastName'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.firstContactLastName,
          ),
          'newValue': firstContactLastNameController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'firstContactRelationship',
          getLastValue(currentEmployeeHistory!.firstContactRelationship),
          firstContactRelationshipController.text.trim())) {
        changes['firstContact_relationship'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.firstContactRelationship,
          ),
          'newValue': firstContactRelationshipController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'firstContactEmail',
          getLastValue(currentEmployeeHistory!.firstContactEmail),
          firstContactEmailController.text.trim())) {
        changes['firstContact_email'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactEmail),
          'newValue': firstContactEmailController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'firstContactPhone',
          getLastValue(currentEmployeeHistory!.firstContactPhone),
          firstContactPhoneController.text.trim())) {
        changes['firstContact_phone'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactPhone),
          'newValue': firstContactPhoneController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'firstContactLanguage',
          getLastValue(currentEmployeeHistory!.firstContactLanguage),
          firstContactLanguageController.text.trim())) {
        changes['firstContact_language'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.firstContactLanguage,
          ),
          'newValue': firstContactLanguageController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'firstContactCountry',
          getLastValue(currentEmployeeHistory!.firstContactCountry),
          firstContactCountryController.text.trim())) {
        changes['firstContact_country'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactCountry),
          'newValue': firstContactCountryController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'firstContactProvince',
          getLastValue(currentEmployeeHistory!.firstContactProvince),
          firstContactProvinceController.text.trim())) {
        changes['firstContact_province'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.firstContactProvince,
          ),
          'newValue': firstContactProvinceController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'firstContactCity',
          getLastValue(currentEmployeeHistory!.firstContactCity),
          firstContactCityController.text.trim())) {
        changes['firstContact_city'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactCity),
          'newValue': firstContactCityController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'firstContactStreet',
          getLastValue(currentEmployeeHistory!.firstContactStreet),
          firstContactStreetController.text.trim())) {
        changes['firstContact_street'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactStreet),
          'newValue': firstContactStreetController.text.trim(),
        };
      }

      // 2nd Emergency Contact Changes
      if (!HealthValueCompare.same(
          'secondContactFirstName',
          getLastValue(currentEmployeeHistory!.secondContactFirstName),
          secondContactFirstNameController.text.trim())) {
        changes['secondContact_firstName'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactFirstName,
          ),
          'newValue': secondContactFirstNameController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'secondContactLastName',
          getLastValue(currentEmployeeHistory!.secondContactLastName),
          secondContactLastNameController.text.trim())) {
        changes['secondContact_lastName'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactLastName,
          ),
          'newValue': secondContactLastNameController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'secondContactRelationship',
          getLastValue(currentEmployeeHistory!.secondContactRelationship),
          secondContactRelationshipController.text.trim())) {
        changes['secondContact_relationship'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactRelationship,
          ),
          'newValue': secondContactRelationshipController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'secondContactEmail',
          getLastValue(currentEmployeeHistory!.secondContactEmail),
          secondContactEmailController.text.trim())) {
        changes['secondContact_email'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactEmail),
          'newValue': secondContactEmailController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'secondContactPhone',
          getLastValue(currentEmployeeHistory!.secondContactPhone),
          secondContactPhoneController.text.trim())) {
        changes['secondContact_phone'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactPhone),
          'newValue': secondContactPhoneController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'secondContactLanguage',
          getLastValue(currentEmployeeHistory!.secondContactLanguage),
          secondContactLanguageController.text.trim())) {
        changes['secondContact_language'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactLanguage,
          ),
          'newValue': secondContactLanguageController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'secondContactCountry',
          getLastValue(currentEmployeeHistory!.secondContactCountry),
          secondContactCountryController.text.trim())) {
        changes['secondContact_country'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactCountry,
          ),
          'newValue': secondContactCountryController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'secondContactProvince',
          getLastValue(currentEmployeeHistory!.secondContactProvince),
          secondContactProvinceController.text.trim())) {
        changes['secondContact_province'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactProvince,
          ),
          'newValue': secondContactProvinceController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'secondContactCity',
          getLastValue(currentEmployeeHistory!.secondContactCity),
          secondContactCityController.text.trim())) {
        changes['secondContact_city'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactCity),
          'newValue': secondContactCityController.text.trim(),
        };
      }

      if (!HealthValueCompare.same(
          'secondContactStreet',
          getLastValue(currentEmployeeHistory!.secondContactStreet),
          secondContactStreetController.text.trim())) {
        changes['secondContact_street'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactStreet),
          'newValue': secondContactStreetController.text.trim(),
        };
      }

      // Check if there are any changes
      if (changes.isEmpty) {
        showAppDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            var lightMode = Theme.of(context).brightness == Brightness.light;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Container(
                width: 411.w,
                padding: EdgeInsets.all(20.sp),
                decoration: BoxDecoration(
                  color: lightMode ? AppColors.white : AppColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lottie Animation
                    Lottie.asset(
                      'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json',
                      width: 100.w,
                      height: 100.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 16.h),
                    // Error Message
                    Text(
                      S.of(context).noChangeFound,
                      style: StyleText.fontSize18Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
        return;
      }

      // Owner 21/10/2026: the preview's controllers are made once (not per
      // route rebuild) and disposed after the preview route has closed.
      final List<TextEditingController> previewControllers =
          <TextEditingController>[];
      TextEditingController copyOf(TextEditingController source) {
        final TextEditingController copy = TextEditingController(
          text: FormatHelper.capitalize(source.text),
        );
        previewControllers.add(copy);
        return copy;
      }

      // Navigate to Preview Page
      final Widget previewPage = PreviewHealthInsuranceChangesPage(
        changes: changes,
        insuranceNameController: copyOf(insuranceNameController),
        insurancePolicyNumberController:
            copyOf(insurancePolicyNumberController),
        firstContactFirstNameController:
            copyOf(firstContactFirstNameController),
        firstContactLastNameController: copyOf(firstContactLastNameController),
        firstContactRelationshipController:
            copyOf(firstContactRelationshipController),
        firstContactEmailController: copyOf(firstContactEmailController),
        firstContactPhoneController: copyOf(firstContactPhoneController),
        firstContactLanguageController: copyOf(firstContactLanguageController),
        firstContactCountryController: copyOf(firstContactCountryController),
        firstContactProvinceController: copyOf(firstContactProvinceController),
        firstContactCityController: copyOf(firstContactCityController),
        firstContactStreetController: copyOf(firstContactStreetController),
        secondContactFirstNameController:
            copyOf(secondContactFirstNameController),
        secondContactLastNameController:
            copyOf(secondContactLastNameController),
        secondContactRelationshipController:
            copyOf(secondContactRelationshipController),
        secondContactEmailController: copyOf(secondContactEmailController),
        secondContactPhoneController: copyOf(secondContactPhoneController),
        secondContactLanguageController:
            copyOf(secondContactLanguageController),
        secondContactCountryController: copyOf(secondContactCountryController),
        secondContactProvinceController:
            copyOf(secondContactProvinceController),
        secondContactCityController: copyOf(secondContactCityController),
        secondContactStreetController: copyOf(secondContactStreetController),
      );
      final MaterialPageRoute<void> previewRoute =
          MaterialPageRoute<void>(builder: (_) => previewPage);
      await Navigator.push(context, previewRoute);
      // `completed` resolves after the exit animation, when nothing reads
      // these controllers any more.
      await previewRoute.completed;
      for (final TextEditingController c in previewControllers) {
        c.dispose();
      }
    }
  }
}
