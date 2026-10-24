/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: edit_page_request_builders.dart
/// Description: UI builder methods of `_EditPageRequestState` — split out of `edit_page_request.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/edit_page_request.dart';

// Split from edit_page_request.dart to keep every file under 700 lines.

extension _EditPageRequestStateBuilders on _EditPageRequestState {
  /// One name box.
  ///
  /// [arabic] picks which spelling this box edits: the Arabic one writes
  /// `<field>_arabic` and compares against `…InArabic`, the English one writes
  /// `<field>`. The text direction follows the SCRIPT of the box, not the UI
  /// language — an Arabic name is RTL even while the app is in English.
  Widget _buildNameField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String field,
    required String? original,
    required bool arabic,
  }) {
    // LABEL SIDE 24/8/2026.
    //
    // `textDirection` already put the VALUE on the correct side, but the label
    // stayed left: CustomTextField draws it in a
    // `Column(crossAxisAlignment: start)`, and `start` resolves against the
    // ambient Directionality — the app locale — not against the field's own
    // direction. So in the English UI "الاسم الأول" sat top-left while the
    // Arabic text it labelled sat bottom-right.
    //
    // Wrapping the field in its own Directionality makes `start` mean the same
    // side the text uses, so label and value line up. Done for BOTH scripts,
    // not just Arabic: in the Arabic UI an English field would otherwise have
    // the same mismatch mirrored.
    return Directionality(
      textDirection: arabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: CustomTextField(
        height: _EditPageRequestState._kFieldHeight,
        label: label,
        hint: hint,
        controller: controller,
        textDirection: arabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        textAlign: arabic ? TextAlign.right : TextAlign.left,
        onChanged: (value) => _trackChange(field, original, value),
      ),
    );
  }

  Widget _buildView(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';
    final bool isPhone = kpIsPhoneLayout(
        context); // 20/10/2026: the ContextExtension helper is inverted on some screens

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: () {
          Navigator.pop(context);
        },
        // X-137 (21/10/2026): "Editing Personal Information".
        secondTitle: S.of(context).editingPersonalInformation,
        // D-202 (20/10/2026): Discard / Preview are PINNED to the bottom on
        // every device; only the form scrolls above them.
        child: SideFrameBoundedBody(
          child: Column(
            children: [
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 21/10/2026 (Moataz): no "Current Details" label
                        // above the form — the page title says what it is.
                        Container(
                          // R-11 (21/10/2026): 16 on every side — .h top
                          // and .w sides scaled differently.
                          padding: EdgeInsets.all(16.sp),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // D-205 (20/10/2026): only the PHONE stacks EN then AR;
                              // iPad portrait keeps EN | AR side by side.
                              if (isPortrait && isPhone) ...[
                                _buildAvatarPicker(lightMode),
                                SizedBox(height: 16.sp),
                                // Portrait has no room for two boxes on a line, so
                                // the pairs stack: English then Arabic, per name.
                                _buildNameField(
                                  label:
                                      _EditPageRequestState._labelFirstNameEn,
                                  hint: S.of(context).enterYourFirstName,
                                  controller: firstNameController,
                                  field: 'first_name',
                                  original: employee?.firstName.lastOrNull,
                                  arabic: false,
                                ),
                                SizedBox(height: 12.sp),
                                _buildNameField(
                                  label:
                                      _EditPageRequestState._labelFirstNameAr,
                                  hint: _EditPageRequestState._labelFirstNameAr,
                                  controller: firstNameArController,
                                  field: 'first_name_arabic',
                                  original:
                                      employee?.firstNameInArabic.lastOrNull,
                                  arabic: true,
                                ),
                                SizedBox(height: 12.sp),
                                _buildNameField(
                                  label:
                                      _EditPageRequestState._labelMiddleNameEn,
                                  hint: S.of(context).enterYourMiddleName,
                                  controller: middleNameController,
                                  field: 'middle_name',
                                  original: employee?.middleName.lastOrNull,
                                  arabic: false,
                                ),
                                SizedBox(height: 12.sp),
                                _buildNameField(
                                  label:
                                      _EditPageRequestState._labelMiddleNameAr,
                                  hint:
                                      _EditPageRequestState._labelMiddleNameAr,
                                  controller: middleNameArController,
                                  field: 'middle_name_arabic',
                                  original:
                                      employee?.middleNameInArabic.lastOrNull,
                                  arabic: true,
                                ),
                                SizedBox(height: 12.sp),
                                _buildNameField(
                                  label: _EditPageRequestState._labelLastNameEn,
                                  hint: S.of(context).enterYourLastName,
                                  controller: lastNameController,
                                  field: 'last_name',
                                  original: employee?.lastName.lastOrNull,
                                  arabic: false,
                                ),
                                SizedBox(height: 12.sp),
                                _buildNameField(
                                  label: _EditPageRequestState._labelLastNameAr,
                                  hint: _EditPageRequestState._labelLastNameAr,
                                  controller: lastNameArController,
                                  field: 'last_name_arabic',
                                  original:
                                      employee?.lastNameInArabic.lastOrNull,
                                  arabic: true,
                                ),
                                isPhone ? SizedBox(height: 16.h) : SizedBox(),
                              ] else ...[
                                _buildAvatarPicker(lightMode),
                                SizedBox(height: 20.sp),
                                // Landscape: three rows of two. English on the
                                // left, Arabic on the right, so each name and its
                                // other spelling sit next to each other instead of
                                // one of them being unreachable in this language.
                                Row(
                                  // English on the LEFT and Arabic on the RIGHT
                                  // in both languages (Moataz 23/10/2026): the
                                  // row's own direction is fixed, the fields
                                  // keep their text direction.
                                  textDirection: TextDirection.ltr,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildNameField(
                                        label: _EditPageRequestState
                                            ._labelFirstNameEn,
                                        hint: S.of(context).enterYourFirstName,
                                        controller: firstNameController,
                                        field: 'first_name',
                                        original:
                                            employee?.firstName.lastOrNull,
                                        arabic: false,
                                      ),
                                    ),
                                    SizedBox(width: 16.sp),
                                    Expanded(
                                      child: _buildNameField(
                                        label: _EditPageRequestState
                                            ._labelFirstNameAr,
                                        hint: _EditPageRequestState
                                            ._labelFirstNameAr,
                                        controller: firstNameArController,
                                        field: 'first_name_arabic',
                                        original: employee
                                            ?.firstNameInArabic.lastOrNull,
                                        arabic: true,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isPhone ? 12.h : 16.h),
                                Row(
                                  // English on the LEFT and Arabic on the RIGHT
                                  // in both languages (Moataz 23/10/2026): the
                                  // row's own direction is fixed, the fields
                                  // keep their text direction.
                                  textDirection: TextDirection.ltr,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildNameField(
                                        label: _EditPageRequestState
                                            ._labelMiddleNameEn,
                                        hint: S.of(context).enterYourMiddleName,
                                        controller: middleNameController,
                                        field: 'middle_name',
                                        original:
                                            employee?.middleName.lastOrNull,
                                        arabic: false,
                                      ),
                                    ),
                                    SizedBox(width: 16.sp),
                                    Expanded(
                                      child: _buildNameField(
                                        label: _EditPageRequestState
                                            ._labelMiddleNameAr,
                                        hint: _EditPageRequestState
                                            ._labelMiddleNameAr,
                                        controller: middleNameArController,
                                        field: 'middle_name_arabic',
                                        original: employee
                                            ?.middleNameInArabic.lastOrNull,
                                        arabic: true,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isPhone ? 12.h : 16.h),
                                Row(
                                  // English on the LEFT and Arabic on the RIGHT
                                  // in both languages (Moataz 23/10/2026): the
                                  // row's own direction is fixed, the fields
                                  // keep their text direction.
                                  textDirection: TextDirection.ltr,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildNameField(
                                        label: _EditPageRequestState
                                            ._labelLastNameEn,
                                        hint: S.of(context).enterYourLastName,
                                        controller: lastNameController,
                                        field: 'last_name',
                                        original: employee?.lastName.lastOrNull,
                                        arabic: false,
                                      ),
                                    ),
                                    SizedBox(width: 16.sp),
                                    Expanded(
                                      child: _buildNameField(
                                        label: _EditPageRequestState
                                            ._labelLastNameAr,
                                        hint: _EditPageRequestState
                                            ._labelLastNameAr,
                                        controller: lastNameArController,
                                        field: 'last_name_arabic',
                                        original: employee
                                            ?.lastNameInArabic.lastOrNull,
                                        arabic: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(height: isPhone ? 12.h : 16.h),
                              if (isPortrait && isPhone) ...[
                                CustomDropdown<String>(
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
                                      final selectedItem =
                                          genderItems.firstWhere(
                                        (item) => item['key'] == value,
                                        orElse: () => {'key': '', 'value': ''},
                                      );
                                      _trackChange(
                                        'gender',
                                        employee?.gender.lastOrNull,
                                        selectedItem['key'],
                                      );
                                    });
                                  },
                                ),
                                SizedBox(height: isPhone ? 12.h : 16.h),
                                _buildDateOfBirthField(lightMode),
                                SizedBox(height: isPhone ? 12.h : 16.h),
                                CustomDropdown<String>(
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
                                      final selectedItem =
                                          maritalStatusItems.firstWhere(
                                        (item) => item['key'] == value,
                                        orElse: () => {'key': '', 'value': ''},
                                      );
                                      _trackChange(
                                        'marital_status',
                                        employee?.maritalStatus.lastOrNull,
                                        selectedItem['key'],
                                      );
                                    });
                                  },
                                ),
                              ] else if (isPortrait) ...[
                                // D-205: iPad portrait — 2 fields per row.
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildGenderDropdown()),
                                    SizedBox(width: 16.sp),
                                    Expanded(
                                        child:
                                            _buildDateOfBirthField(lightMode)),
                                  ],
                                ),
                                SizedBox(height: 12.sp),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildMaritalDropdown()),
                                    SizedBox(width: 16.sp),
                                    const Expanded(child: SizedBox()),
                                  ],
                                ),
                              ] else ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomDropdown<String>(
                                        height:
                                            _EditPageRequestState._kFieldHeight,
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
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                        onChanged: (value) {
                                          rebuild(() {
                                            selectedGender = value;
                                            final selectedItem =
                                                genderItems.firstWhere(
                                              (item) => item['key'] == value,
                                              orElse: () =>
                                                  {'key': '', 'value': ''},
                                            );
                                            _trackChange(
                                              'gender',
                                              employee?.gender.lastOrNull,
                                              selectedItem['key'],
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 16.sp),
                                    Expanded(
                                        child:
                                            _buildDateOfBirthField(lightMode)),
                                    SizedBox(width: 16.sp),
                                    Expanded(
                                      child: CustomDropdown<String>(
                                        height:
                                            _EditPageRequestState._kFieldHeight,
                                        enforceTypeScale: false,
                                        valueStyle: _kFieldValueStyle,
                                        label: S.of(context).maritalStatus,
                                        hint: S.of(context).selectMaritalStatus,
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                        value: selectedMaritalStatus,
                                        items: maritalStatusItems
                                            .map((item) => DropdownItem<String>(
                                                  value: item['key']!,
                                                  label: item['value']!,
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          rebuild(() {
                                            selectedMaritalStatus = value;
                                            final selectedItem =
                                                maritalStatusItems.firstWhere(
                                              (item) => item['key'] == value,
                                              orElse: () =>
                                                  {'key': '', 'value': ''},
                                            );
                                            _trackChange(
                                              'marital_status',
                                              employee
                                                  ?.maritalStatus.lastOrNull,
                                              selectedItem['key'],
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        // D-204 (20/10/2026): section gap halved (was 20).
                        SizedBox(height: 12.sp),
                        Container(
                          // R-11 (21/10/2026): 16 on every side.
                          padding: EdgeInsets.all(16.sp),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              // D-212 (20/10/2026): the same header widget (24 icon box) as the
                              // view page, so Contact and Location icons match by number and by eye.
                              SettingsHeader(
                                horizontalPadding: 0,
                                imagePath:
                                    'assets/icons_assets/settings_assets/ic_comms_phone_call.svg',
                                text: S.of(context).contact,
                              ),
                              SizedBox(height: 12.sp),
                              _buildContactSection(
                                  isPortrait, lightMode, isTablet),
                            ],
                          ),
                        ),
                        // D-204 (20/10/2026): section gap halved (was 20).
                        SizedBox(height: 12.sp),
                        Container(
                          // R-11 (21/10/2026): 16 on every side.
                          padding: EdgeInsets.all(16.sp),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              // D-212 (20/10/2026): the same header widget (24 icon box) as the
                              // view page, so Contact and Location icons match by number and by eye.
                              SettingsHeader(
                                horizontalPadding: 0,
                                imagePath:
                                    'assets/icons_assets/settings_assets/ic_place_city.svg',
                                text: S.of(context).location,
                              ),
                              SizedBox(height: 12.sp),
                              _buildLocationSection(
                                  isPortrait, lightMode, isTablet),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.sp),
              _buildActionButtons(isPhone),
              SizedBox(height: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  /// Profile photo with the camera badge. Shared by the portrait (phone) and
  /// landscape layouts — bug report (Settings mobile p.2, "where is the
  /// image?"): portrait used to leave it out, so a phone could not see or
  /// change the photo at all.
  /// D-213 (20/10/2026): the core picture picker at its one size (D-163)
  /// instead of a page-local avatar + camera badge.
  Widget _buildAvatarPicker(bool lightMode) {
    return Row(
      children: [
        CustomImagePicker(
          // Same diameter as the view page's avatar (64.r) — #28.
          radius: 32.r,
          // 21/10/2026 (Moataz): the profile photo opens Files, not Photos.
          fromFiles: true,
          imageFile: _selectedImage,
          imageUrl: (employee?.photo.isNotEmpty ?? false)
              ? employee!.photo.last
              : null,
          onImagePicked: (File file) {
            rebuild(() => _selectedImage = file);
            _trackChange('photo', employee?.photo.lastOrNull, file.path);
          },
          onError: (String message) {
            if (!mounted) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(message),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ));
          },
        ),
      ],
    );
  }
}
