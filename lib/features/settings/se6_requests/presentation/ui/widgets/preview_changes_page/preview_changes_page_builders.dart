/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: preview_changes_page_builders.dart
/// Description: UI builder methods of `_PreviewChangesPageState` — split out of `preview_changes_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/preview_changes_page.dart';

// Split from preview_changes_page.dart to keep every file under 700 lines.

extension _PreviewChangesPageStateBuilders on _PreviewChangesPageState {
  Widget _buildDetailsColumn(
    BuildContext context,
    bool lightMode, {
    required bool isCurrentColumn,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Helper function to check if field should be shown
    // X-127 (20/10/2026): the preview shows ONLY the fields that changed, on
    // every device (was: every field on tablet / desktop).
    bool shouldShowField(String fieldKey) =>
        widget.changes.containsKey(fieldKey);

    // PAIRED MODE — mobile only, added 8/9/2026.
    //
    // On mobile this method is called ONCE and every field renders both of its
    // values: the current one, then the new one directly under it. On wider
    // screens it is still called twice, once per column, and each call renders
    // only the side it was asked for.
    //
    // That is why the builders below now receive BOTH values instead of
    // `isCurrentColumn ? old : new` — the paired layout needs the pair, and the
    // two-column layout picks its half here rather than at fifteen call sites.
    // X-127: only the changed fields, as Before → After pairs. On iPad and
    // the large screen the pair is two columns side by side (Current | New);
    // on the phone the two boxes stack (Moataz 20 Oct 23:30).
    const bool pairValues = true;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Local wrapper so every call below can keep passing "did this field
    // change?" without also having to know which column it is in. The green
    // highlight marks the NEW value — on the Current Details side it just
    // outlined the old value the user is replacing, and in paired mode it
    // marks the lower of the two boxes for the same reason.
    Widget buildFieldDisplay(
      BuildContext context,
      bool lightMode,
      String label,
      String currentValue,
      String newValue,
      bool hasChanged,
    ) {
      // D-224 (21/10/2026): the shared Current → New pair — grey "Current"
      // box, green-bordered "New" box, stacked on the phone (8 between),
      // side by side under "Current Details | New Details" otherwise.
      return CurrentNewValuePair(
        label: label,
        current: currentValue,
        next: newValue,
        changed: hasChanged,
        stacked: isMobile,
      );
    }

    // Helper to check if any personal info fields should be shown
    bool hasPersonalInfoFields = shouldShowField('photo') ||
        shouldShowField('first_name') ||
        shouldShowField('middle_name') ||
        shouldShowField('last_name') ||
        shouldShowField('gender') ||
        shouldShowField('date_of_birth') ||
        shouldShowField('marital_status');

    // Check if any contact fields changed
    bool hasContactChanges =
        shouldShowField('phone') || shouldShowField('country_code');

    // Check if any location fields changed
    bool hasLocationChanges = shouldShowField('country') ||
        shouldShowField('province') ||
        shouldShowField('city') ||
        shouldShowField('street');

    return Column(
      children: [
        // Personal Information Container - only show if there are fields to display
        if (hasPersonalInfoFields) ...[
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 21/10/2026 (Moataz): the card gets its own icon + title,
                // like Contact and Location.
                SettingsHeader(
                  horizontalPadding: 0,
                  imagePath:
                      'assets/icons_assets/settings_assets/ic_personal_information.svg',
                  text: S.of(context).personalInformation,
                ),
                SizedBox(height: 12.sp),
                // Profile Photo - only show if changed on mobile
                if (shouldShowField('photo'))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CHANGED 24/8/2026: was a hand-rolled
                      // CircleAvatar + ClipRRect + Image.network stack with
                      // its own error builder. `CustomImagePicker` is the
                      // shared control the rest of the app uses, so the
                      // avatar here now matches everywhere else — in
                      // `readOnly`, since a preview must not let anyone
                      // change the photo.
                      //
                      // Paired mode stacks the two avatars for the same reason
                      // the value boxes stack: the old photo, then the one
                      // replacing it. `imageFile: null` falls back to
                      // `imageUrl`, which is what makes the first one the
                      // current photo.
                      Builder(builder: (BuildContext context) {
                        final Widget before = CustomImagePicker(
                          radius: 32.r,
                          readOnly: true,
                          imageFile: null,
                          imageUrl: (employee?.photo.isNotEmpty ?? false)
                              ? employee!.photo.last
                              : null,
                          onImagePicked: (_) {},
                        );
                        final Widget after = CustomImagePicker(
                          radius: 32.r,
                          readOnly: true,
                          imageFile: widget.selectedImage,
                          imageUrl: (employee?.photo.isNotEmpty ?? false)
                              ? employee!.photo.last
                              : null,
                          onImagePicked: (_) {},
                        );
                        if (isMobile) {
                          // D-224: the "Current" / "New" marks on the photo pair.
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(children: <Widget>[before]),
                              SizedBox(height: 8.sp),
                              Row(children: <Widget>[after]),
                            ],
                          );
                        }
                        return Row(
                          children: <Widget>[
                            Expanded(child: Row(children: <Widget>[before])),
                            SizedBox(width: 16.sp),
                            Expanded(child: Row(children: <Widget>[after])),
                          ],
                        );
                      }),
                      SizedBox(height: 12.sp),
                    ],
                  ),

                // Personal Information — each name is TWO rows now, English
                // and Arabic, because the form edits both. Previously one row
                // showed whichever spelling matched the UI language, which made
                // an edit to the other one invisible in the preview.
                if (shouldShowField('first_name')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    _PreviewChangesPageState._labelFirstNameEn,
                    FormatHelper.capitalize(
                        employee?.firstName.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.firstNameController.text),
                    widget.changes.containsKey('first_name'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('first_name_arabic')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    // The Arabic label stays Arabic in both languages, same as
                    // on the edit form, so the two boxes are never ambiguous.
                    _PreviewChangesPageState._labelFirstNameAr,
                    employee?.firstNameInArabic.lastOrNull ?? '',
                    widget.firstNameArController.text,
                    widget.changes.containsKey('first_name_arabic'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('middle_name')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    _PreviewChangesPageState._labelMiddleNameEn,
                    FormatHelper.capitalize(
                        employee?.middleName.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.middleNameController.text),
                    widget.changes.containsKey('middle_name'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('middle_name_arabic')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    _PreviewChangesPageState._labelMiddleNameAr,
                    employee?.middleNameInArabic.lastOrNull ?? '',
                    widget.middleNameArController.text,
                    widget.changes.containsKey('middle_name_arabic'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('last_name')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    _PreviewChangesPageState._labelLastNameEn,
                    FormatHelper.capitalize(
                        employee?.lastName.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.lastNameController.text),
                    widget.changes.containsKey('last_name'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('last_name_arabic')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    _PreviewChangesPageState._labelLastNameAr,
                    employee?.lastNameInArabic.lastOrNull ?? '',
                    widget.lastNameArController.text,
                    widget.changes.containsKey('last_name_arabic'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('gender')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).gender,
                    // Both columns go through _getGenderValue now. The Current
                    // side used to print `employee.gender` straight from
                    // Firestore, which is the raw key — so it was English (and
                    // sometimes lower case) even in Arabic.
                    FormatHelper.capitalize(
                        _getGenderValue(employee?.gender.lastOrNull)),
                    FormatHelper.capitalize(
                        _getGenderValue(widget.selectedGender)),
                    widget.changes.containsKey('gender'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('date_of_birth')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).birthday,
                    FormatHelper.capitalize(
                        _formatDate(employee?.birthDay.lastOrNull)),
                    FormatHelper.capitalize(widget.dateOfBirthController.text),
                    widget.changes.containsKey('date_of_birth'),
                  ),
                  if (shouldShowField('marital_status'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('marital_status'))
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).maritalStatus,
                    FormatHelper.capitalize(_getMaritalStatusValue(
                        employee?.maritalStatus.lastOrNull)),
                    FormatHelper.capitalize(
                        _getMaritalStatusValue(widget.selectedMaritalStatus)),
                    widget.changes.containsKey('marital_status'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12.sp), // D-204
        ],

        // Contact Section - only show if any contact field changed
        if (hasContactChanges) ...[
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Contact Section Header
                // D-212 (20/10/2026): the shared header (24 icon box), like the view page.
                SettingsHeader(
                  horizontalPadding: 0,
                  imagePath:
                      'assets/icons_assets/settings_assets/ic_comms_phone_call.svg',
                  text: S.of(context).contact,
                ),
                SizedBox(height: 12.sp),

                // Country code and number are two boxes, not one string. Each
                // half carries its own highlight, so changing the country
                // without touching the digits outlines only the code box.
                if (shouldShowField('phone') || shouldShowField('country_code'))
                  // Two code+number rows under one label, matching how the
                  // plain fields pair. Each row keeps its own two boxes, so
                  // changing the country without touching the digits still
                  // outlines only the code half of the lower row.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _fieldLabel(S.of(context).phoneNumber),
                      SizedBox(height: 10.h),
                      Builder(builder: (BuildContext context) {
                        final Widget before = _phoneValueRow(
                          code: _getCurrentPhoneCode(),
                          number: _getCurrentPhoneNumber(),
                          highlightCode: false,
                          highlightNumber: false,
                        );
                        final Widget after = _phoneValueRow(
                          code: _getNewPhoneCode(),
                          number: _getNewPhoneNumber(),
                          highlightCode:
                              widget.changes.containsKey('country_code'),
                          highlightNumber: widget.changes.containsKey('phone'),
                        );
                        if (isMobile) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CurrentNewValuePair.mark(
                                before,
                                S.of(context).currentTag,
                                AppColors.secondaryText,
                              ),
                              SizedBox(height: 8.sp),
                              CurrentNewValuePair.mark(
                                after,
                                S.of(context).newTag,
                                AppColors.statusApproved,
                              ),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: before),
                            SizedBox(width: 16.sp),
                            Expanded(child: after),
                          ],
                        );
                      }),
                    ],
                  )
              ],
            ),
          ),
          SizedBox(height: 12.sp), // D-204
        ],

        // Location Section - only show if any location field changed
        if (hasLocationChanges)
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Location Section Header
                // D-212 (20/10/2026): the shared header (24 icon box), like the view page.
                SettingsHeader(
                  horizontalPadding: 0,
                  imagePath:
                      'assets/icons_assets/settings_assets/ic_place_city.svg',
                  text: S.of(context).location,
                ),
                SizedBox(height: 12.sp),

                if (shouldShowField('country')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).country,
                    FormatHelper.capitalize(employee?.country.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.countryController.text),
                    widget.changes.containsKey('country'),
                  ),
                  if (shouldShowField('province') ||
                      shouldShowField('city') ||
                      shouldShowField('street'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('province')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).stateOrProvince,
                    FormatHelper.capitalize(
                        employee?.province.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.provinceController.text),
                    widget.changes.containsKey('province'),
                  ),
                  if (shouldShowField('city') || shouldShowField('street'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('city')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).city,
                    FormatHelper.capitalize(employee?.city.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.cityController.text),
                    widget.changes.containsKey('city'),
                  ),
                  if (shouldShowField('street')) SizedBox(height: 12.sp),
                ],

                if (shouldShowField('street'))
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).streetName,
                    FormatHelper.capitalize(employee?.street.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.streetController.text),
                    widget.changes.containsKey('street'),
                  ),
              ],
            ),
          ),
        // Request Note — once per page.
        //
        // MOVED 29/9/2026 (Settings mobile bug p.3/p.5): it used to sit INSIDE
        // the Location card, which mobile only shows when a location field
        // changed. A contact-only or gender-only request therefore had no note
        // field — and Submit, which needs the note, could never be enabled.
        //
        // On tablet/desktop that means the New Details column only.
        // In paired mode there is a single column, built with
        // `isCurrentColumn: true`, so it has to be allowed through
        // here or the note (and with it the enabled Submit button)
        // would vanish on mobile.
        if (!isCurrentColumn || pairValues) ...[
          SizedBox(height: 12.sp),
          // D-207 / C-18 (20/10/2026): the note sits in its own white section
          // like the others (grey field on white), with the 0/500 counter.
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomTextField(
              label: S.of(context).request_note,
              hint: S.of(context).textHere,
              controller: requestNoteController,
              // Draws the required marker next to the label, so the rule
              // is visible before the user reaches a disabled button.
              required: true,
              maxLength: 500,
              textDirection:
                  isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              maxLines: 3,
              onChanged: (_) {
                rebuild(() {});
              },
            ),
          ),
        ],
      ],
    );
  }
}
