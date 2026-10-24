/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: edit_page_request_logic.dart
/// Description: Logic and event handlers of `_EditPageRequestState` — split out of `edit_page_request.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/edit_page_request.dart';

// Split from edit_page_request.dart to keep every file under 700 lines.

extension _EditPageRequestStateLogic on _EditPageRequestState {
  /// Reads the country/state/city asset, then turns whatever the employee record
  /// already holds ("Kuwait", "Salmiya") back into dropdown selections.
  Future<void> _loadLocationData() async {
    await LocationDataService.instance.load();
    if (!mounted) return;
    rebuild(() {
      _locationDataReady = true;
      _resolveSavedLocation();
    });
  }

  /// Matching is deliberately loose (see `LocationOption.matchesLoose`) because
  /// these values were typed by hand for years — "Mubarak Al-kabeer
  /// Governorate" has to find "Mubarak Al-Kabeer".
  ///
  /// A value that matches nothing leaves that dropdown unselected rather than
  /// guessing. It is NOT written back as a change: `_trackChange` is not called
  /// here, so opening the page never invents an edit the user did not make.
  void _resolveSavedLocation() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final service = LocationDataService.instance;

    final country =
        _firstMatch(service.countries(context), countryController.text);
    _selectedCountryIso = country?.code;
    // K-50 (20/10/2026): a saved value the list doesn't know is KEPT, never
    // blanked (City "New Administrative Capital" opened empty).
    countryController.text = country?.label(isArabic) ?? countryController.text;

    final state = _firstMatch(
      service.statesOf(_selectedCountryIso),
      provinceController.text,
    );
    _selectedStateCode = state?.code;
    provinceController.text = state?.label(isArabic) ?? provinceController.text;

    final city = _firstMatch(
      service.citiesOf(_selectedCountryIso, _selectedStateCode),
      cityController.text,
    );
    cityController.text = city?.label(isArabic) ?? cityController.text;
  }

  LocationOption? _firstMatch(List<LocationOption> options, String? saved) {
    for (final option in options) {
      if (option.matchesLoose(saved)) return option;
    }
    return null;
  }

  void _initializeControllers() {
    if (employee == null) {}

    Localizations.localeOf(context).languageCode == 'ar';

    // Get the current mobile phone object
    // Owner 21/10/2026: newest phone entry (history is newest last), not the oldest.
    final mobilePhone = employee!.mobilePhone.lastOrNull;

    // Extract phone data from MobilePhone object
    final phoneNumber = mobilePhone?.phones?.lastOrNull ?? "";
    final countryCode = mobilePhone?.countryCode?.lastOrNull ?? "EG";

    // Both spellings are loaded, independent of the UI language. Only the
    // English ones are capitalized — `FormatHelper.capitalize` is an ASCII
    // upper-casing helper and has nothing to do on Arabic text.
    firstNameController = TextEditingController(
      text: FormatHelper.capitalize(employee?.firstName.lastOrNull ?? ''),
    );
    firstNameArController = TextEditingController(
      text: employee?.firstNameInArabic.lastOrNull ?? '',
    );

    middleNameController = TextEditingController(
      text: FormatHelper.capitalize(employee?.middleName.lastOrNull ?? ''),
    );
    middleNameArController = TextEditingController(
      text: employee?.middleNameInArabic.lastOrNull ?? '',
    );

    lastNameController = TextEditingController(
      text: FormatHelper.capitalize(employee?.lastName.lastOrNull ?? ''),
    );
    lastNameArController = TextEditingController(
      text: employee?.lastNameInArabic.lastOrNull ?? '',
    );

    // Initialize phone controller with the actual phone number
    phoneController = TextEditingController(
      text: phoneNumber,
    );

    nationalityController = TextEditingController(
      text: FormatHelper.capitalize(employee?.nationality.lastOrNull ?? ''),
    );

    countryController = TextEditingController(
      text: FormatHelper.capitalize(employee?.country.lastOrNull ?? ''),
    );

    provinceController = TextEditingController(
      text: FormatHelper.capitalize(employee?.province.lastOrNull ?? ''),
    );

    cityController = TextEditingController(
      text: FormatHelper.capitalize(employee?.city.lastOrNull ?? ''),
    );

    streetController = TextEditingController(
      text: FormatHelper.capitalize(employee?.street.lastOrNull ?? ''),
    );

    // Set initial selected values for gender
    final genderValue = employee?.gender.lastOrNull?.toLowerCase();
    selectedGender = genderItems.firstWhere(
      (item) => item['key'] == genderValue,
      orElse: () => {'key': '', 'value': ''},
    )['key'];

    if (selectedGender?.isEmpty ?? true) {
      selectedGender = null;
    }

    // Set initial selected values for marital status
    final maritalValue = employee?.maritalStatus.lastOrNull?.toLowerCase();
    selectedMaritalStatus = maritalStatusItems.firstWhere(
      (item) => item['key'] == maritalValue,
      orElse: () => {'key': '', 'value': ''},
    )['key'];

    if (selectedMaritalStatus?.isEmpty ?? true) {
      selectedMaritalStatus = null;
    }

    // Set country code - use the extracted country code from MobilePhone
    selectedCountryCode = countryCode;

    // Parse birthday with improved error handling
    final birthdayString = employee?.birthDay.lastOrNull;

    // Only attempt to parse if we have a non-null, non-empty string
    if (birthdayString != null && birthdayString.trim().isNotEmpty) {
      selectedDateOfBirth = _parseDate(birthdayString);
    } else {
      selectedDateOfBirth = null;
    }
    // Initialize date controller with formatted date (localized if Arabic)
    dateOfBirthController = TextEditingController(
      text: selectedDateOfBirth != null
          ? _formatDateForDisplay(selectedDateOfBirth!)
          : '',
    );
  }

  /// 21/10/2026 "Edit And Resend": put the rejected request's new values in
  /// the form and record each one as a change, so Preview opens with them.
  /// The photo is not carried over — its file lives on the device that sent
  /// the first request.
  void _applyResendChanges() {
    final Map<String, TextEditingController> textFields =
        <String, TextEditingController>{
      'first_name': firstNameController,
      'first_name_arabic': firstNameArController,
      'middle_name': middleNameController,
      'middle_name_arabic': middleNameArController,
      'last_name': lastNameController,
      'last_name_arabic': lastNameArController,
      'phone': phoneController,
      'country': countryController,
      'province': provinceController,
      'city': cityController,
      'street': streetController,
    };
    for (final FieldChange change in widget.resendChanges) {
      final String field = change.fieldName;
      final String value = change.newValue;
      final TextEditingController? controller = textFields[field];
      if (controller != null) {
        controller.text = value;
      } else if (field == 'gender') {
        selectedGender = value.toLowerCase();
      } else if (field == 'marital_status') {
        selectedMaritalStatus = value.toLowerCase();
      } else if (field == 'country_code') {
        selectedCountryCode = value;
      } else if (field == 'date_of_birth') {
        selectedDateOfBirth = _parseDate(value);
        dateOfBirthController.text = selectedDateOfBirth != null
            ? _formatDateForDisplay(selectedDateOfBirth!)
            : value;
      } else {
        continue; // photo, or a field this form does not edit
      }
      _trackChange(field, change.oldValue, value);
    }
    _resendSnapshot = _changeValues();
  }

  Map<String, String> _changeValues() => <String, String>{
        for (final MapEntry<String, dynamic> e in changes.entries)
          e.key: '${(e.value as Map)['newValue'] ?? ''}',
      };

  /// True while the form still holds exactly the rejected request's values.
  bool get _isUntouchedResend {
    if (_resendSnapshot.isEmpty) return false;
    final Map<String, String> now = _changeValues();
    if (now.length != _resendSnapshot.length) return false;
    for (final MapEntry<String, String> e in now.entries) {
      final String? was = _resendSnapshot[e.key];
      if (was == null || !_sameValue(e.key, was, e.value)) return false;
    }
    return true;
  }

  void _initializeDropdownItems() {
    // Initialize gender items with localized values
    genderItems = [
      {'key': 'male', 'value': S.of(context).male},
      {'key': 'female', 'value': S.of(context).female},
    ];

    // Initialize marital status items with localized values
    maritalStatusItems = [
      {'key': 'single', 'value': S.of(context).single},
      {'key': 'married', 'value': S.of(context).married},
      {'key': 'divorced', 'value': S.of(context).divorced},
      {'key': 'widowed', 'value': S.of(context).widowed},
    ];
  }

  /// Display format for a date field: `29 Aug 2023`.
  ///
  /// CHANGED 8/9/2026 — was `dd/MM/yyyy` in English and `yyyy/M/dd` in Arabic.
  /// An all-numeric date is ambiguous at a glance — `12/11/1977` reads as 12
  /// November to one reader and December 11 to another — and having the two
  /// locales disagree on field order made it worse. A named month can only be
  /// read one way.
  ///
  /// The month name follows the app language, so Arabic renders as
  /// `٢٩ أغسطس ٢٠٢٣`. Passing the locale explicitly is safe: main() calls
  /// `AppBarDate.ensureDateFormattingInitialized()` at start-up, which loads
  /// intl date symbols for every supported locale.
  ///
  /// DISPLAY ONLY. What gets stored is `picked.toIso8601String()` (see
  /// [_buildDateOfBirthField]), so this touches neither saved data nor
  /// `FlexibleDateParser`, which still reads whatever the record holds.
  String _formatDateForDisplay(DateTime date) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String formatted =
        DateFormat('dd MMM yyyy', isArabic ? 'ar' : 'en').format(date);

    if (isArabic) {
      return ArabicDigits(formatted).toArabicNumbers();
    }
    return formatted;
  }

  // Helper method to convert English numbers to Arabic

  /// Delegates to `FlexibleDateParser`, which is where the four dead
  /// try/catch blocks this method used to hold now do not exist
  /// (CR-SKEL-SE6-N02).
  // K-50 (20/10/2026): the stored birthday is in the Employees_Info format
  // the VIEW page parses with EmployeeDateFormatter; the edit page used only
  // FlexibleDateParser and opened with an empty Birthday.
  DateTime? _parseDate(String? dateString) =>
      EmployeeDateFormatter.parse(dateString) ??
      FlexibleDateParser.parse(dateString);

  void _markFieldAsTouched(String fieldName) {
    rebuild(() {
      touchedFields.add(fieldName);
    });
  }

  void _trackChange(String field, dynamic oldValue, dynamic newValue) {
    if (!_sameValue(field, oldValue?.toString(), newValue?.toString())) {
      changes[field] = {
        'oldValue': oldValue,
        'newValue': newValue,
      };
    } else {
      changes.remove(field);
    }
  }

  /// 21/10/2026 (Moataz: picking the SAME birthday enabled Preview): a
  /// field is unchanged when it MEANS the same as the stored value, not only
  /// when the text is identical. The stored and the picked forms differ for
  /// most fields — birthday `1986/04/12` vs `1986-04-12T00:00:00`, gender
  /// `Male` vs key `male`, country `egypt` vs label `Egypt` (or the Arabic
  /// name), phone country `EG` vs dial code `20`, names `bayanatz` vs the
  /// capitalised `Bayanatz` the form shows.
  bool _sameValue(String field, String? oldValue, String? newValue) {
    final String a = (oldValue ?? '').trim();
    final String b = (newValue ?? '').trim();
    if (a == b) return true;
    switch (field) {
      case 'date_of_birth':
        final DateTime? da = _parseDate(a);
        final DateTime? db = _parseDate(b);
        return da != null &&
            db != null &&
            da.year == db.year &&
            da.month == db.month &&
            da.day == db.day;
      case 'country_code':
        String digits(String v) => v.replaceAll(RegExp(r'[^0-9]'), '');
        return digits(PhoneCountryLookup.dialCodeOf(a)) ==
            digits(PhoneCountryLookup.dialCodeOf(b));
      case 'country':
      case 'province':
      case 'city':
        final LocationDataService service = LocationDataService.instance;
        final List<LocationOption> options = field == 'country'
            ? service.countries(context)
            : field == 'province'
                ? service.statesOf(_selectedCountryIso)
                : service.citiesOf(_selectedCountryIso, _selectedStateCode);
        if (options.any(
            (LocationOption o) => o.matchesLoose(a) && o.matchesLoose(b))) {
          return true;
        }
        return a.toLowerCase() == b.toLowerCase();
      case 'photo':
        return false;
      default:
        return a.toLowerCase() == b.toLowerCase();
    }
  }

  Future<void> _submitChanges() async {
    rebuild(() {
      submitted = true;
    });

    // A first and a last name are still required, but EITHER spelling
    // satisfies it — someone filling in only Arabic is not blocked.
    final hasFirstName = firstNameController.text.trim().isNotEmpty ||
        firstNameArController.text.trim().isNotEmpty;
    final hasLastName = lastNameController.text.trim().isNotEmpty ||
        lastNameArController.text.trim().isNotEmpty;

    if (!hasFirstName || !hasLastName) {
      _showValidationErrorDialog(S.of(context).pleaseFillInAllRequiredFields);
      return;
    }

    if (changes.isEmpty) {
      _showValidationErrorDialog(S.of(context).youHavenTMadeAnyChangesToSubmit);
      return;
    }

    navigateTo(
      context,
      PreviewChangesPage(
        changes: changes,
        selectedImage: _selectedImage,
        firstNameController: firstNameController,
        firstNameArController: firstNameArController,
        middleNameController: middleNameController,
        middleNameArController: middleNameArController,
        lastNameController: lastNameController,
        lastNameArController: lastNameArController,
        phoneController: phoneController,
        countryController: countryController,
        provinceController: provinceController,
        cityController: cityController,
        streetController: streetController,
        dateOfBirthController: dateOfBirthController,
        selectedGender: selectedGender,
        selectedMaritalStatus: selectedMaritalStatus,
        selectedCountryCode: selectedCountryCode,
      ),
    );
  }

  void _showValidationErrorDialog(String errorMessage) {
    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return GestureDetector(
          onTapDown: (_) => HapticController.low(),
          onTap: () => Navigator.of(dialogContext).pop(),
          child: Material(
            color: AppColors.barrierColor,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 411.w,
                  padding: EdgeInsets.all(24.sp),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                          'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json',
                          width: 70.w,
                          height: 70.h,
                          fit: BoxFit.scaleDown,
                          repeat: true),
                      SizedBox(height: 20.h),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Grid ──────────────────────────────────────────────────────────────────
  // R-1 (21/10/2026): the gap between fields in a row is 16.sp, the same as
  // the name / gender / location rows. Keep the unit as .sp — the other Rows
  // in this file use .sp, and .sp / .w scale differently once minTextAdapt
  // kicks in, which would drift the columns apart.
  double get _gridGap => 16.sp;

  TextStyle get _kFieldValueStyle =>
      StyleText.fontSize14Weight400.copyWith(color: AppColors.text);

  /// Tells the user WHY a dropdown is empty instead of showing a hint that
  /// promises options it does not have.
  String _locationHint({
    required bool hasCountry,
    required bool isEmpty,
    required String fallback,
  }) {
    if (!hasCountry) return S.of(context).country;
    if (isEmpty && _locationDataReady) return '—';
    return fallback;
  }
}
