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
    var isPhone = ContextExtension(context).isPhone;

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: () {
          Navigator.pop(context);
        },
        secondTitle: S.of(context).editingMyPersonalData,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).current_details,
                      style: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.text),
                    ),
                    SizedBox(height: 10.sp),
                    Container(
                      padding: EdgeInsets.only(
                          top: 15.h, right: 15.w, left: 15.w, bottom: 15.sp),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isPortrait) ...[
                            _buildAvatarPicker(lightMode),
                            SizedBox(height: 20.sp),
                            // Portrait has no room for two boxes on a line, so
                            // the pairs stack: English then Arabic, per name.
                            _buildNameField(
                              label: _EditPageRequestState._labelFirstNameEn,
                              hint: S.of(context).enterYourFirstName,
                              controller: firstNameController,
                              field: 'first_name',
                              original: employee?.firstName.lastOrNull,
                              arabic: false,
                            ),
                            SizedBox(height: 12.h),
                            _buildNameField(
                              label: _EditPageRequestState._labelFirstNameAr,
                              hint: _EditPageRequestState._labelFirstNameAr,
                              controller: firstNameArController,
                              field: 'first_name_arabic',
                              original: employee?.firstNameInArabic.lastOrNull,
                              arabic: true,
                            ),
                            isPhone
                                ? SizedBox(height: 16.h)
                                : SizedBox(height: 12.h),
                            _buildNameField(
                              label: _EditPageRequestState._labelMiddleNameEn,
                              hint: S.of(context).enterYourMiddleName,
                              controller: middleNameController,
                              field: 'middle_name',
                              original: employee?.middleName.lastOrNull,
                              arabic: false,
                            ),
                            SizedBox(height: 12.h),
                            _buildNameField(
                              label: _EditPageRequestState._labelMiddleNameAr,
                              hint: _EditPageRequestState._labelMiddleNameAr,
                              controller: middleNameArController,
                              field: 'middle_name_arabic',
                              original: employee?.middleNameInArabic.lastOrNull,
                              arabic: true,
                            ),
                            isPhone
                                ? SizedBox(height: 16.h)
                                : SizedBox(height: 12.h),
                            _buildNameField(
                              label: _EditPageRequestState._labelLastNameEn,
                              hint: S.of(context).enterYourLastName,
                              controller: lastNameController,
                              field: 'last_name',
                              original: employee?.lastName.lastOrNull,
                              arabic: false,
                            ),
                            SizedBox(height: 12.h),
                            _buildNameField(
                              label: _EditPageRequestState._labelLastNameAr,
                              hint: _EditPageRequestState._labelLastNameAr,
                              controller: lastNameArController,
                              field: 'last_name_arabic',
                              original: employee?.lastNameInArabic.lastOrNull,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildNameField(
                                    label:
                                        _EditPageRequestState._labelFirstNameEn,
                                    hint: S.of(context).enterYourFirstName,
                                    controller: firstNameController,
                                    field: 'first_name',
                                    original: employee?.firstName.lastOrNull,
                                    arabic: false,
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: _buildNameField(
                                    label:
                                        _EditPageRequestState._labelFirstNameAr,
                                    hint:
                                        _EditPageRequestState._labelFirstNameAr,
                                    controller: firstNameArController,
                                    field: 'first_name_arabic',
                                    original:
                                        employee?.firstNameInArabic.lastOrNull,
                                    arabic: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isPhone ? 12.h : 16.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildNameField(
                                    label: _EditPageRequestState
                                        ._labelMiddleNameEn,
                                    hint: S.of(context).enterYourMiddleName,
                                    controller: middleNameController,
                                    field: 'middle_name',
                                    original: employee?.middleName.lastOrNull,
                                    arabic: false,
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: _buildNameField(
                                    label: _EditPageRequestState
                                        ._labelMiddleNameAr,
                                    hint: _EditPageRequestState
                                        ._labelMiddleNameAr,
                                    controller: middleNameArController,
                                    field: 'middle_name_arabic',
                                    original:
                                        employee?.middleNameInArabic.lastOrNull,
                                    arabic: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isPhone ? 12.h : 16.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildNameField(
                                    label:
                                        _EditPageRequestState._labelLastNameEn,
                                    hint: S.of(context).enterYourLastName,
                                    controller: lastNameController,
                                    field: 'last_name',
                                    original: employee?.lastName.lastOrNull,
                                    arabic: false,
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: _buildNameField(
                                    label:
                                        _EditPageRequestState._labelLastNameAr,
                                    hint:
                                        _EditPageRequestState._labelLastNameAr,
                                    controller: lastNameArController,
                                    field: 'last_name_arabic',
                                    original:
                                        employee?.lastNameInArabic.lastOrNull,
                                    arabic: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: isPhone ? 12.h : 16.h),
                          if (isPortrait) ...[
                            CustomDropdown<String>(
                              height: _EditPageRequestState._kFieldHeight,
                              enforceTypeScale: false,
                              valueStyle: _kFieldValueStyle,
                              label: S.of(context).gender,
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
                          ] else ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CustomDropdown<String>(
                                    height: _EditPageRequestState._kFieldHeight,
                                    enforceTypeScale: false,
                                    valueStyle: _kFieldValueStyle,
                                    label: S.of(context).gender,
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
                                SizedBox(width: 12.sp),
                                Expanded(
                                    child: _buildDateOfBirthField(lightMode)),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: CustomDropdown<String>(
                                    height: _EditPageRequestState._kFieldHeight,
                                    enforceTypeScale: false,
                                    valueStyle: _kFieldValueStyle,
                                    label: S.of(context).maritalStatus,
                                    borderRadius: BorderRadius.circular(4.r),
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
                                          employee?.maritalStatus.lastOrNull,
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
                    SizedBox(height: 20.sp),
                    Container(
                      padding:
                          EdgeInsets.only(top: 15.h, right: 15.w, left: 15.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CustomSvgImage(
                                assetPath:
                                    'assets/icons_assets/settings_assets/ic_comms_phone_call.svg',
                                width: 25.w,
                                height: 25.h,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(width: 8.sp),
                              Text(
                                S.of(context).contact,
                                style: StyleText.fontSize16Weight600.copyWith(
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.sp),
                          _buildContactSection(isPortrait, lightMode, isTablet),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Container(
                      padding:
                          EdgeInsets.only(top: 15.h, right: 15.w, left: 15.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CustomSvgImage(
                                assetPath:
                                    'assets/icons_assets/settings_assets/ic_place_city.svg',
                                width: 25.w,
                                height: 25.h,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(width: 8.sp),
                              Text(
                                S.of(context).location,
                                style: StyleText.fontSize16Weight600.copyWith(
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.sp),
                          _buildLocationSection(
                              isPortrait, lightMode, isTablet),
                          isPhone ? SizedBox() : SizedBox(height: 16.h),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.sp),
                // Replace the preview button section at the bottom of your build method with this:

                // Replace the preview button section at the bottom of your build method with this:

                Row(
                  textDirection: TextDirection
                      .ltr, // X-73: Cancel left, action right in both languages

                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    customButton(
                      title: S.of(context).discardChange,
                      function: () {
                        Navigator.pop(context);
                      },
                      height: 38.h,
                      width: 150.sp,
                      color: AppColors.darkGrey,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.text),
                    ),
                    Spacer(),
                    customButton(
                      title: S.of(context).preview,
                      function: changes.isEmpty
                          ? () {} // Empty function when disabled (or null if customButton supports it)
                          : () => _submitChanges(), // Wrap async function
                      height: 38.h,
                      width: 150.sp,
                      color: changes.isEmpty
                          ? AppColors.darkGrey
                          : AppColors.primary, // Gray if no changes
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: changes.isEmpty
                            ? AppColors.text // Lighter text when disabled
                            : AppColors.textButton,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Profile photo with the camera badge. Shared by the portrait (phone) and
  /// landscape layouts — bug report (Settings mobile p.2, "where is the
  /// image?"): portrait used to leave it out, so a phone could not see or
  /// change the photo at all.
  Widget _buildAvatarPicker(bool lightMode) {
    return Row(
      children: [
        Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            CircleAvatar(
              radius: 29.r,
              backgroundColor: AppColors.background,
              // (_selectedImage != null ||
              //     (employee?.photo != null && employee!.photo!.isNotEmpty))
              //     ? AppColors.transparent
              //     : AppColors.grey,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32.r),
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: 58.r,
                        height: 58.r,
                      )
                    : (employee?.photo != null && employee!.photo.isNotEmpty)
                        ? Image.network(
                            employee!.photo.last,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                padding: EdgeInsets.all(8.sp),
                                child: CustomSvgImage.natural(
                                  assetPath:
                                      'assets/icons_assets/main_icons_assets/ic_media_image.svg',
                                  width: 26.sp,
                                  height: 26.sp,
                                  color: AppColors.text,
                                ),
                              );
                            },
                          )
                        : Container(
                            padding: EdgeInsets.all(8.sp),
                            child: CustomSvgImage.natural(
                              assetPath:
                                  'assets/icons_assets/main_icons_assets/ic_media_image.svg',
                              width: 26.sp,
                              height: 26.sp,
                            ),
                          ),
              ),
            ),
            GestureDetector(
              onTapDown: (_) => HapticController.low(),
              onTap: () async {
                await _pickImage();
              },
              child: CircleAvatar(
                radius: 10.r,
                backgroundColor: AppColors.primary,
                child: CustomSvgImage.natural(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_media_camera_teal.svg',
                  width: 14.sp,
                  height: 14.sp,
                  fit: BoxFit.scaleDown,
                  color: AppColors.textButton,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
