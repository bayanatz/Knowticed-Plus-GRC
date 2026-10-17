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
    countryController.text = country?.label(isArabic) ?? '';

    final state = _firstMatch(
      service.statesOf(_selectedCountryIso),
      provinceController.text,
    );
    _selectedStateCode = state?.code;
    provinceController.text = state?.label(isArabic) ?? '';

    final city = _firstMatch(
      service.citiesOf(_selectedCountryIso, _selectedStateCode),
      cityController.text,
    );
    cityController.text = city?.label(isArabic) ?? '';
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
    final mobilePhoneList = employee!.mobilePhone;
    final mobilePhone =
        mobilePhoneList.isNotEmpty == true ? mobilePhoneList.first : null;

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

  /// Function Name: [_pickImage]
  ///
  /// Purpose: Choose a new profile photo for the request.
  ///
  /// The picker call and its try/catch moved to `GalleryImagePicker`
  /// (CR-SKEL-SE6-N02). A denied permission now surfaces instead of looking
  /// identical to the user cancelling.
  Future<void> _pickImage() async {
    final ImagePickResult result = await _galleryPicker.pick();
    if (!mounted) return;

    switch (result.outcome) {
      case ImagePickOutcome.picked:
        rebuild(() => _selectedImage = result.file);
        _trackChange('photo', employee?.photo.lastOrNull, result.file!.path);
        break;
      case ImagePickOutcome.failed:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(S.of(context).failedToPickImage),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        break;
      case ImagePickOutcome.cancelled:
        break;
    }
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
  DateTime? _parseDate(String? dateString) =>
      FlexibleDateParser.parse(dateString);


  void _markFieldAsTouched(String fieldName) {
    rebuild(() {
      touchedFields.add(fieldName);
    });
  }

  void _trackChange(String field, dynamic oldValue, dynamic newValue) {
    if (oldValue != newValue) {
      changes[field] = {
        'oldValue': oldValue,
        'newValue': newValue,
      };
    } else {
      changes.remove(field);
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
  // The name / gender / location rows are three equal columns with a 12.sp
  // gutter. Contact uses the same grid: the phone block spans two columns
  // from the left gridline. Keep the unit as .sp — the other Rows in this file
  // use .sp, and .sp / .w scale differently once minTextAdapt kicks in, which
  // would drift the columns apart.
  double get _gridGap => 12.sp;

  TextStyle get _kFieldValueStyle =>
      StyleText.fontSize14Weight400.copyWith(color: AppColors.text);

  /// The country-code box. Fixed in BOTH orientations (23/8/2026): it holds a
  /// flag and three or four characters, so it needs a small pinned width and
  /// the number field takes every pixel left over.
  ///
  /// It used to be one full grid column in landscape, which put a 4-character
  /// dial code in a box as wide as the email field beside it.
  double get _dialCodeWidth => 100.sp;

  String _convertToArabicDigits(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

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
