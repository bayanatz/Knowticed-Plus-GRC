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
      if (oldInsuranceName != newInsuranceName) {
        changes['insuranceName'] = {
          'oldValue': oldInsuranceName,
          'newValue': newInsuranceName,
        };
      }

      String oldPolicyNumber = getLastValue(
        currentEmployeeHistory!.insurancePolicyNumber,
      );
      String newPolicyNumber = insurancePolicyNumberController.text.trim();
      if (oldPolicyNumber != newPolicyNumber) {
        changes['insurancePolicyNumber'] = {
          'oldValue': oldPolicyNumber,
          'newValue': newPolicyNumber,
        };
      }

      // 1st Emergency Contact Changes
      if (getLastValue(currentEmployeeHistory!.firstContactFirstName) !=
          firstContactFirstNameController.text.trim()) {
        changes['firstContact_firstName'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.firstContactFirstName,
          ),
          'newValue': firstContactFirstNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactLastName) !=
          firstContactLastNameController.text.trim()) {
        changes['firstContact_lastName'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.firstContactLastName,
          ),
          'newValue': firstContactLastNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactRelationship) !=
          firstContactRelationshipController.text.trim()) {
        changes['firstContact_relationship'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.firstContactRelationship,
          ),
          'newValue': firstContactRelationshipController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactEmail) !=
          firstContactEmailController.text.trim()) {
        changes['firstContact_email'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactEmail),
          'newValue': firstContactEmailController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactPhone) !=
          firstContactPhoneController.text.trim()) {
        changes['firstContact_phone'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactPhone),
          'newValue': firstContactPhoneController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactLanguage) !=
          firstContactLanguageController.text.trim()) {
        changes['firstContact_language'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.firstContactLanguage,
          ),
          'newValue': firstContactLanguageController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactCountry) !=
          firstContactCountryController.text.trim()) {
        changes['firstContact_country'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactCountry),
          'newValue': firstContactCountryController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactProvince) !=
          firstContactProvinceController.text.trim()) {
        changes['firstContact_province'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.firstContactProvince,
          ),
          'newValue': firstContactProvinceController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactCity) !=
          firstContactCityController.text.trim()) {
        changes['firstContact_city'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactCity),
          'newValue': firstContactCityController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactStreet) !=
          firstContactStreetController.text.trim()) {
        changes['firstContact_street'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactStreet),
          'newValue': firstContactStreetController.text.trim(),
        };
      }

      // 2nd Emergency Contact Changes
      if (getLastValue(currentEmployeeHistory!.secondContactFirstName) !=
          secondContactFirstNameController.text.trim()) {
        changes['secondContact_firstName'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactFirstName,
          ),
          'newValue': secondContactFirstNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactLastName) !=
          secondContactLastNameController.text.trim()) {
        changes['secondContact_lastName'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactLastName,
          ),
          'newValue': secondContactLastNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactRelationship) !=
          secondContactRelationshipController.text.trim()) {
        changes['secondContact_relationship'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactRelationship,
          ),
          'newValue': secondContactRelationshipController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactEmail) !=
          secondContactEmailController.text.trim()) {
        changes['secondContact_email'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactEmail),
          'newValue': secondContactEmailController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactPhone) !=
          secondContactPhoneController.text.trim()) {
        changes['secondContact_phone'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactPhone),
          'newValue': secondContactPhoneController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactLanguage) !=
          secondContactLanguageController.text.trim()) {
        changes['secondContact_language'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactLanguage,
          ),
          'newValue': secondContactLanguageController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactCountry) !=
          secondContactCountryController.text.trim()) {
        changes['secondContact_country'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactCountry,
          ),
          'newValue': secondContactCountryController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactProvince) !=
          secondContactProvinceController.text.trim()) {
        changes['secondContact_province'] = {
          'oldValue': getLastValue(
            currentEmployeeHistory!.secondContactProvince,
          ),
          'newValue': secondContactProvinceController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactCity) !=
          secondContactCityController.text.trim()) {
        changes['secondContact_city'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactCity),
          'newValue': secondContactCityController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactStreet) !=
          secondContactStreetController.text.trim()) {
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

      // Navigate to Preview Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewHealthInsuranceChangesPage(
            changes: changes,
            insuranceNameController: TextEditingController(
              text: FormatHelper.capitalize(insuranceNameController.text),
            ),
            insurancePolicyNumberController: TextEditingController(
              text: FormatHelper.capitalize(
                insurancePolicyNumberController.text,
              ),
            ),
            firstContactFirstNameController: TextEditingController(
              text: FormatHelper.capitalize(
                firstContactFirstNameController.text,
              ),
            ),
            firstContactLastNameController: TextEditingController(
              text: FormatHelper.capitalize(
                firstContactLastNameController.text,
              ),
            ),
            firstContactRelationshipController: TextEditingController(
              text: FormatHelper.capitalize(
                firstContactRelationshipController.text,
              ),
            ),
            firstContactEmailController: TextEditingController(
              text: FormatHelper.capitalize(firstContactEmailController.text),
            ),
            firstContactPhoneController: TextEditingController(
              text: FormatHelper.capitalize(firstContactPhoneController.text),
            ),
            firstContactLanguageController: TextEditingController(
              text: FormatHelper.capitalize(
                firstContactLanguageController.text,
              ),
            ),
            firstContactCountryController: TextEditingController(
              text: FormatHelper.capitalize(
                firstContactCountryController.text,
              ),
            ),
            firstContactProvinceController: TextEditingController(
              text: FormatHelper.capitalize(
                firstContactProvinceController.text,
              ),
            ),
            firstContactCityController: TextEditingController(
              text: FormatHelper.capitalize(firstContactCityController.text),
            ),
            firstContactStreetController: TextEditingController(
              text: FormatHelper.capitalize(firstContactStreetController.text),
            ),
            secondContactFirstNameController: TextEditingController(
              text: FormatHelper.capitalize(
                secondContactFirstNameController.text,
              ),
            ),
            secondContactLastNameController: TextEditingController(
              text: FormatHelper.capitalize(
                secondContactLastNameController.text,
              ),
            ),
            secondContactRelationshipController: TextEditingController(
              text: FormatHelper.capitalize(
                secondContactRelationshipController.text,
              ),
            ),
            secondContactEmailController: TextEditingController(
              text: FormatHelper.capitalize(secondContactEmailController.text),
            ),
            secondContactPhoneController: TextEditingController(
              text: FormatHelper.capitalize(secondContactPhoneController.text),
            ),
            secondContactLanguageController: TextEditingController(
              text: FormatHelper.capitalize(
                secondContactLanguageController.text,
              ),
            ),
            secondContactCountryController: TextEditingController(
              text: FormatHelper.capitalize(
                secondContactCountryController.text,
              ),
            ),
            secondContactProvinceController: TextEditingController(
              text: FormatHelper.capitalize(
                secondContactProvinceController.text,
              ),
            ),
            secondContactCityController: TextEditingController(
              text: FormatHelper.capitalize(secondContactCityController.text),
            ),
            secondContactStreetController: TextEditingController(
              text: FormatHelper.capitalize(
                secondContactStreetController.text,
              ),
            ),
          ),
        ),
      );
    }
  }
}
