/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: edit_page_request_builders_2.dart
/// Description: UI builder methods of `_EditPageRequestState` — split out of `edit_page_request.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/edit_page_request.dart';

// Split from edit_page_request.dart to keep every file under 700 lines.

extension _EditPageRequestStateBuilders2 on _EditPageRequestState {
  /// Birth date picker. NOTE: no outer Padding here — CustomDateField
  /// already draws its own label + 6.h gap, exactly like CustomTextField and
  /// CustomDropdown. Any extra top padding pushes this column out of line with
  /// Gender / Marital Status next to it.
  Widget _buildDateOfBirthField(bool lightMode) {
    return CustomDateField(
      height: _EditPageRequestState._kFieldHeight,
      key: ValueKey(
        'birthday_${selectedDateOfBirth?.toIso8601String() ?? "empty"}',
      ),
      value: selectedDateOfBirth,
      label: S.of(context).birthday,
      hint: S.of(context).selectdate,
      borderRadius: BorderRadius.circular(4.r),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      // Keeps the existing locale-aware dd/MM/yyyy + Arabic-numeral display.
      dateFormatter: _formatDateForDisplay,
      onChanged: (picked) {
        if (picked == null) return;
        rebuild(() {
          selectedDateOfBirth = picked;
          dateOfBirthController.text = _formatDateForDisplay(picked);
          _trackChange(
            'date_of_birth',
            employee?.birthDay.lastOrNull,
            picked.toIso8601String(),
          );
        });
      },
    );
  }

  /// Matches the label CustomTextField / CustomDropdown draw internally, so a
  /// hand-rolled label lines up with the generated ones.
  ///
  /// IMPORTANT: this must be a RichText, not a Text. StyleText styles have
  /// `inherit: true`, so a Text merges them over the ambient DefaultTextStyle
  /// (picking up its `height`/leading) while RichText does not. Using Text here
  /// makes the label a couple of pixels taller than the one CustomTextField
  /// draws, which pushes the phone boxes out of line with the email box.
  Widget _fieldLabel(String label) => RichText(
        text: TextSpan(
          text: label,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
      );

  /// Label + country picker + number, laid out to fill whatever width it is
  /// given. The label is drawn here (rather than on one of the two fields) so
  /// the block starts at the same height as the email column beside it.
  ///
  /// [dialCodeWidth] pins the country-code box. In landscape the caller passes
  /// one full grid column so the code and the number land on columns 2 and 3 —
  /// every box in the card then shares the same three gridlines.
  Widget _buildPhoneField() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Owner 21/10/2026: newest phone entry (history is newest last), not the oldest.
    final mobilePhone = employee!.mobilePhone.lastOrNull;

    final countryCode = mobilePhone?.countryCode?.lastOrNull ?? "EG";
    final currentCountryCode = selectedCountryCode ?? countryCode;

    final dialCode = PhoneCountryLookup.dialCodeOf(currentCountryCode);

    Future<void> pickCountry() async {
      final result = await showCountryPickerDialog(
        context,
        selectedDialCode: dialCode.replaceAll('+', ''),
      );
      if (result != null) {
        rebuild(() {
          selectedCountryCode = result.dialCode;
          _trackChange(
            'country_code',
            mobilePhone?.countryCode?.lastOrNull,
            result.dialCode,
          );
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(S.of(context).phoneNumber),
        SizedBox(height: kFieldLabelGap.sp), // D-209
        Row(
          children: [
            // Country code — the shared box (R-39); opens the picker on tap.
            PhoneCodeBox(
              codeOrDialCode: currentCountryCode,
              height: _EditPageRequestState._kFieldHeight,
              onTap: pickCountry,
            ),
            SizedBox(width: _gridGap),
            Expanded(
              child: CustomTextField(
                height: _EditPageRequestState._kFieldHeight,
                hint: S.of(context).enterThePhoneNumber,
                controller: phoneController,
                textDirection: ui.TextDirection.ltr,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                keyboardType: TextInputType.phone,
                // 21/10/2026 (Moataz): digits only — letters typed or pasted
                // in (e.g. "150150376Transformation") are dropped.
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                borderRadius: BorderRadius.circular(4.r),
                onChanged: (value) {
                  _trackChange('phone', mobilePhone?.phones?.lastOrNull, value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection(bool isPortrait, bool lightMode, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: (isPortrait && !isTablet)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhoneField(),
              ],
            )
          // D-205 (Moataz 20 Oct 23:30): on iPad portrait the phone is ONE
          // column of the two — never the full row. 21/10/2026 (Moataz): the
          // same half width in landscape (was one third).
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPhoneField()),
                    SizedBox(width: _gridGap),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
    );
  }

  // ── Location dropdowns ────────────────────────────────────────────────────
  //
  // Country -> State/Governorate -> City, each one feeding the next.
  //
  // Countries come from `country_picker` (already a dependency), so every
  // country in the world is listed and the Arabic names are the package's own.
  // States and cities come from `assets/data/location_data.json`; a country with
  // no entry there simply has an empty state list, and the hint says so instead
  // of leaving the user tapping a dead control.

  Widget _buildCountryDropdown() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final options = LocationDataService.instance.countries(context);

    return CustomDropdown<String>(
      height: _EditPageRequestState._kFieldHeight,
      enforceTypeScale: false,
      valueStyle: _kFieldValueStyle,
      label: S.of(context).country,
      hint: S.of(context).selectCountry,
      // K-50 (20/10/2026): a saved country that is not in the list is still
      // shown and kept (value = its text) instead of an empty field.
      value: _selectedCountryIso ??
          (countryController.text.trim().isEmpty
              ? null
              : countryController.text.trim()),
      borderRadius: BorderRadius.circular(4.r),
      items: [
        ...options.map((o) =>
            DropdownItem<String>(value: o.code, label: o.label(isArabic))),
        if (_selectedCountryIso == null &&
            countryController.text.trim().isNotEmpty)
          DropdownItem<String>(
              value: countryController.text.trim(),
              label: StoredValueAr.of(context, countryController.text.trim())),
      ],
      onChanged: (iso) {
        final picked = options.firstWhere((o) => o.code == iso,
            orElse: () => options.first);
        if (!options.any((o) => o.code == iso)) return; // the kept saved value
        rebuild(() {
          _selectedCountryIso = iso;
          countryController.text = picked.label(isArabic);

          // The cascade. A state and city chosen under the old country are
          // meaningless under the new one, so they are cleared — and their
          // entries are REMOVED from `changes` rather than recorded as an edit
          // to empty, which would submit a request to wipe the employee's
          // province and city.
          _selectedStateCode = null;
          provinceController.clear();
          cityController.clear();
          changes.remove('province');
          changes.remove('city');
        });

        _trackChange(
            'country', employee?.country.lastOrNull, countryController.text);
      },
    );
  }

  Widget _buildProvinceDropdown() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final options = LocationDataService.instance.statesOf(_selectedCountryIso);

    return CustomDropdown<String>(
      height: _EditPageRequestState._kFieldHeight,
      enforceTypeScale: false,
      valueStyle: _kFieldValueStyle,
      label: S.of(context).stateOrProvince,
      hint: _locationHint(
        hasCountry: _selectedCountryIso != null,
        isEmpty: options.isEmpty,
        fallback: S.of(context).selectStateOrProvince,
      ),
      // K-50 (20/10/2026): the saved province is shown even when it is not in
      // the list for the chosen country.
      value: _selectedStateCode ??
          (provinceController.text.trim().isEmpty
              ? null
              : provinceController.text.trim()),
      enabled: options.isNotEmpty || provinceController.text.trim().isNotEmpty,
      borderRadius: BorderRadius.circular(4.r),
      items: [
        ...options.map((o) =>
            DropdownItem<String>(value: o.code, label: o.label(isArabic))),
        if (_selectedStateCode == null &&
            provinceController.text.trim().isNotEmpty)
          DropdownItem<String>(
              value: provinceController.text.trim(),
              label: StoredValueAr.of(context, provinceController.text.trim())),
      ],
      onChanged: (code) {
        if (!options.any((o) => o.code == code)) return; // kept saved value
        final picked = options.firstWhere((o) => o.code == code);
        rebuild(() {
          _selectedStateCode = code;
          provinceController.text = picked.label(isArabic);
          cityController.clear();
          changes.remove('city');
        });

        _trackChange(
            'province', employee?.province.lastOrNull, provinceController.text);
      },
    );
  }

  Widget _buildCityDropdown() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final options = LocationDataService.instance
        .citiesOf(_selectedCountryIso, _selectedStateCode);

    // Cities carry no code in the data, so the dropdown's value IS the label.
    // That is also what goes into the controller, so no lookup is needed back.
    final current = cityController.text.trim();

    return CustomDropdown<String>(
      height: _EditPageRequestState._kFieldHeight,
      enforceTypeScale: false,
      valueStyle: _kFieldValueStyle,
      label: S.of(context).city,
      hint: _locationHint(
        hasCountry: _selectedStateCode != null,
        isEmpty: options.isEmpty,
        fallback: S.of(context).selectCity,
      ),
      // K-50 (20/10/2026): the saved city ("New Administrative Capital") is
      // shown and kept even when the list does not contain it.
      value: current.isEmpty ? null : current,
      enabled: options.isNotEmpty || current.isNotEmpty,
      borderRadius: BorderRadius.circular(4.r),
      items: [
        ...options.map((o) => DropdownItem<String>(
              value: o.label(isArabic),
              label: o.label(isArabic),
            )),
        if (current.isNotEmpty &&
            !options.any((o) => o.label(isArabic) == current))
          DropdownItem<String>(
              value: current,
              // 23/10/2026 (Moataz: "why is it not translated?"): a saved
              // city the list does not know has no Arabic name in the data,
              // so it showed in English on the Arabic screen.
              label: StoredValueAr.of(context, current)),
      ],
      onChanged: (label) {
        rebuild(() => cityController.text = label);
        _trackChange('city', employee?.city.lastOrNull, label);
      },
    );
  }

  Widget _buildLocationSection(bool isPortrait, bool lightMode, bool isTablet) {
    final bool isPhone = kpIsPhoneLayout(
        context); // 20/10/2026: the ContextExtension helper is inverted on some screens
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPortrait && isPhone) ...[
            _buildCountryDropdown(),
            SizedBox(height: 12.sp),
            _buildProvinceDropdown(),
            SizedBox(height: 12.sp),
            _buildCityDropdown(),
            SizedBox(height: 12.sp),
            _buildStreetField(),
            SizedBox(height: 12.sp),
          ] else if (isPortrait) ...[
            // D-205 (20/10/2026): iPad portrait — Country | State, City | Street.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCountryDropdown()),
                SizedBox(width: 16.sp),
                Expanded(child: _buildProvinceDropdown()),
              ],
            ),
            SizedBox(height: 12.sp),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCityDropdown()),
                SizedBox(width: 16.sp),
                Expanded(child: _buildStreetField()),
              ],
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCountryDropdown()),
                SizedBox(width: 16.sp),
                Expanded(child: _buildProvinceDropdown()),
                SizedBox(width: 16.sp),
                Expanded(child: _buildCityDropdown()),
              ],
            ),
            SizedBox(height: 12.sp),
            _buildStreetField(),
          ],
        ],
      ),
    );
  }

  Widget _buildStreetField() => CustomTextField(
        height: _EditPageRequestState._kFieldHeight,
        label: S.of(context).streetName,
        hint: S.of(context).enterYourStreetAddress,
        controller: streetController,
        onChanged: (value) {
          _markFieldAsTouched('street');
          _trackChange('street', employee?.street.lastOrNull, value);
        },
      );

  /// Gender dropdown — one builder for every layout (ADDED 20/10/2026, D-205).
  Widget _buildGenderDropdown() => CustomDropdown<String>(
        height: _EditPageRequestState._kFieldHeight,
        enforceTypeScale: false,
        valueStyle: _kFieldValueStyle,
        label: S.of(context).gender,
        hint: S.of(context).selectGender,
        value: selectedGender,
        items: genderItems
            .map((item) => DropdownItem<String>(
                  value: item['key']!,
                  label: item['value']!,
                ))
            .toList(),
        borderRadius: BorderRadius.circular(4.r),
        onChanged: (value) {
          rebuild(() {
            selectedGender = value;
            final selectedItem = genderItems.firstWhere(
              (item) => item['key'] == value,
              orElse: () => {'key': '', 'value': ''},
            );
            _trackChange(
                'gender', employee?.gender.lastOrNull, selectedItem['key']);
          });
        },
      );

  /// Marital Status dropdown — one builder for every layout (20/10/2026).
  Widget _buildMaritalDropdown() => CustomDropdown<String>(
        height: _EditPageRequestState._kFieldHeight,
        enforceTypeScale: false,
        valueStyle: _kFieldValueStyle,
        label: S.of(context).maritalStatus,
        hint: S.of(context).selectMaritalStatus,
        value: selectedMaritalStatus,
        items: maritalStatusItems
            .map((item) => DropdownItem<String>(
                  value: item['key']!,
                  label: item['value']!,
                ))
            .toList(),
        borderRadius: BorderRadius.circular(4.r),
        onChanged: (value) {
          rebuild(() {
            selectedMaritalStatus = value;
            final selectedItem = maritalStatusItems.firstWhere(
              (item) => item['key'] == value,
              orElse: () => {'key': '', 'value': ''},
            );
            _trackChange('marital_status', employee?.maritalStatus.lastOrNull,
                selectedItem['key']);
          });
        },
      );

  /// D-202 (20/10/2026): Discard at the left edge, Preview at the right edge,
  /// same width, Preview grey while there is nothing to preview. On the phone
  /// the two share the row (12 between); on iPad / desktop they keep 150.
  Widget _buildActionButtons(bool isPhone) {
    // 21/10/2026 (Moataz): on Edit And Resend the rejected values are the
    // starting point — Preview stays off until something differs from them.
    final bool enabled = changes.isNotEmpty && !_isUntouchedResend;
    final Widget discard = customButton(
      title: S.of(context).discardChange,
      function: () => Navigator.pop(context),
      height: 38.h,
      width: 150.sp,
      fullWidth: isPhone,
      color: AppColors.darkGrey,
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
    );
    // 21/10/2026 (Moataz): disabled = the disabled Submit look — grey
    // background, black (textButton) text, 50% opacity. Was dark grey with
    // white text.
    final Widget preview = Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: customButton(
          title: S.of(context).preview,
          function: () => _submitChanges(),
          height: 38.h,
          width: 150.sp,
          fullWidth: isPhone,
          color: enabled ? AppColors.primary : AppColors.grey,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ),
    );
    return Row(
// 23/10/2026 (Moataz): in Arabic the buttons mirror — yellow left, grey right.
      children: isPhone
          ? [
              Expanded(child: discard),
              SizedBox(width: 16.sp),
              Expanded(child: preview),
            ]
          : [discard, const Spacer(), preview],
    );
  }
}
