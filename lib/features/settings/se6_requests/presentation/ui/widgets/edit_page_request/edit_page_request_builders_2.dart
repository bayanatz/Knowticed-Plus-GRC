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
  Widget _buildPhoneField({double? dialCodeWidth}) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final mobilePhoneList = employee!.mobilePhone;
    final mobilePhone =
        mobilePhoneList.isNotEmpty == true ? mobilePhoneList.first : null;

    final countryCode = mobilePhone?.countryCode?.lastOrNull ?? "EG";
    final currentCountryCode = selectedCountryCode ?? countryCode;

    final flag = PhoneCountryLookup.flagOf(currentCountryCode);
    final dialCode = PhoneCountryLookup.dialCodeOf(currentCountryCode);
    final displayDialCode =
        isArabic ? _convertToArabicDigits(dialCode) : dialCode;
    final flagAndCode = '$flag $displayDialCode';

    Future<void> pickCountry() async {
      final result = await showCountryPickerDialog(context);
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
        SizedBox(height: 6.h),
        Row(
          children: [
            // Country code — read-only, opens the picker on tap.
            // Keyed by the value so the internal controller refreshes when the
            // user picks a different country (no controller built in build()).
            SizedBox(
              width: dialCodeWidth ?? _dialCodeWidth,
              child: CustomTextField(
                height: _EditPageRequestState._kFieldHeight,
                key: ValueKey('dial_code_$flagAndCode'),
                initialValue: flagAndCode,
                hint: flagAndCode,
                textDirection:
                    isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                readOnly: true,
                borderRadius: BorderRadius.circular(4.r),
                onTap: pickCountry,
              ),
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
      child: isPortrait
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhoneField(),
                SizedBox(height: 15.sp),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columnWidth = (constraints.maxWidth - _gridGap * 2) / 3;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CHANGED 24/8/2026: email used to hold column 1 with
                        // the phone block spanning columns 2 + 3. With email
                        // removed the phone block starts at the left gridline
                        // and keeps the same two-column span, so the dial code
                        // stays its own small fixed width and the number field
                        // takes the rest.
                        SizedBox(
                          width: columnWidth,
                          child: _buildPhoneField(),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.sp),
                  ],
                );
              },
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
      hint: S.of(context).enterYourCountry,
      value: _selectedCountryIso,
      borderRadius: BorderRadius.circular(4.r),
      items: options
          .map((o) =>
              DropdownItem<String>(value: o.code, label: o.label(isArabic)))
          .toList(),
      onChanged: (iso) {
        final picked = options.firstWhere((o) => o.code == iso);
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
        fallback: S.of(context).enterYourStateOrProvince,
      ),
      value: _selectedStateCode,
      enabled: options.isNotEmpty,
      borderRadius: BorderRadius.circular(4.r),
      items: options
          .map((o) =>
              DropdownItem<String>(value: o.code, label: o.label(isArabic)))
          .toList(),
      onChanged: (code) {
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
        fallback: S.of(context).enterYourCity,
      ),
      value: options.any((o) => o.label(isArabic) == current) ? current : null,
      enabled: options.isNotEmpty,
      borderRadius: BorderRadius.circular(4.r),
      items: options
          .map((o) => DropdownItem<String>(
                value: o.label(isArabic),
                label: o.label(isArabic),
              ))
          .toList(),
      onChanged: (label) {
        rebuild(() => cityController.text = label);
        _trackChange('city', employee?.city.lastOrNull, label);
      },
    );
  }

  Widget _buildLocationSection(bool isPortrait, bool lightMode, bool isTablet) {
    var isPhone = ContextExtension(context).isPhone;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPortrait) ...[
            _buildCountryDropdown(),
            SizedBox(height: 10.sp),
            _buildProvinceDropdown(),
            SizedBox(height: 10.sp),
            _buildCityDropdown(),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCountryDropdown()),
                SizedBox(width: 12.sp),
                Expanded(child: _buildProvinceDropdown()),
                SizedBox(width: 12.sp),
                Expanded(child: _buildCityDropdown()),
              ],
            ),
          ],
          isPhone ? SizedBox(height: 16.h) : SizedBox(height: 16.h),
          CustomTextField(
            height: _EditPageRequestState._kFieldHeight,
            label: S.of(context).streetName,
            hint: S.of(context).enterYourStreetAddress,
            controller: streetController,
            onChanged: (value) {
              _markFieldAsTouched('street');
              _trackChange(
                'street',
                employee?.street.lastOrNull,
                value,
              );
            },
          ),
          isPhone ? SizedBox(height: 16.h) : SizedBox(),
        ],
      ),
    );
  }
}
