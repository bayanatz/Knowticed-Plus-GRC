/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: preview_health_insurance_changes_page_builders.dart
/// Description: UI builder methods of `_PreviewHealthInsuranceChangesPageState` — split out of `preview_health_changes_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/preview_health_changes_page.dart';

// Split from preview_health_changes_page.dart to keep every file under 700 lines.

extension _PreviewHealthInsuranceChangesPageStateBuilders
    on _PreviewHealthInsuranceChangesPageState {
  Widget _buildDetailsColumn(
    BuildContext context,
    bool lightMode, {
    required bool isCurrentColumn,
  }) {
    var isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Helper function to check if field should be shown
    bool shouldShowField(String fieldKey) {
      if (!isMobile) return true; // Show all fields on tablet/desktop
      return widget.changes
          .containsKey(fieldKey); // Show only changed fields on mobile
    }

    // Local wrapper so every call below can keep passing "did this field
    // change?" without also having to know which column it is in. The green
    // highlight marks the NEW value — on the Current Details side it just
    // outlined the old value the user is replacing.
    /// The value of one field, for whichever column is being built.
    ///
    /// FIXED 24/8/2026 — the whole Current Details column showed "-".
    ///
    /// It used to read `insuranceController.healthInsuranceEntity` and
    /// `.emergencyContactEntity`. Nothing in the app ever populates those two,
    /// so they were always null; `?? ''` turned every current value into an
    /// empty string and `_fieldDisplay` prints '-' for empty. Meanwhile the
    /// real previous values were sitting right here the whole time: the edit
    /// page builds `changes[key]['oldValue']` from `currentEmployeeHistory`.
    ///
    /// A field the user did NOT touch has no entry in `changes` — and its
    /// controller still holds the value the edit page loaded it with, so the
    /// controller is the correct fallback for BOTH columns.
    String valueFor(String fieldKey, TextEditingController controller) {
      if (!isCurrentColumn) return controller.text;

      final change = widget.changes[fieldKey];
      if (change is Map && change['oldValue'] != null) {
        return change['oldValue'].toString();
      }
      return controller.text;
    }

    Widget buildFieldDisplay(
      BuildContext context,
      bool lightMode,
      String label,
      String value,
      bool hasChanged,
    ) {
      return _fieldDisplay(
        label: label,
        value: value,
        showHighlight: hasChanged && !isCurrentColumn,
      );
    }

    // Helper to check if any insurance fields should be shown
    bool hasInsuranceFields = shouldShowField('insuranceName') ||
        shouldShowField('insurancePolicyNumber');

    // Helper to check if any first contact fields should be shown
    bool hasFirstContactFields = shouldShowField('firstContact_firstName') ||
        shouldShowField('firstContact_lastName') ||
        shouldShowField('firstContact_relationship') ||
        shouldShowField('firstContact_email') ||
        shouldShowField('firstContact_phone') ||
        shouldShowField('firstContact_language') ||
        shouldShowField('firstContact_country') ||
        shouldShowField('firstContact_province') ||
        shouldShowField('firstContact_city') ||
        shouldShowField('firstContact_street');

    // Helper to check if any second contact fields should be shown
    bool hasSecondContactFields = shouldShowField('secondContact_firstName') ||
        shouldShowField('secondContact_lastName') ||
        shouldShowField('secondContact_relationship') ||
        shouldShowField('secondContact_email') ||
        shouldShowField('secondContact_phone') ||
        shouldShowField('secondContact_language') ||
        shouldShowField('secondContact_country') ||
        shouldShowField('secondContact_province') ||
        shouldShowField('secondContact_city') ||
        shouldShowField('secondContact_street');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Health Insurance Section
        if (hasInsuranceFields || !isMobile) ...[
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Insurance Section Header
                Row(
                  children: [
                    CustomSvgImage(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_hr_insurance_document.svg',
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).healthInsurance,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                // Insurance Name
                if (shouldShowField('insuranceName')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).insuranceName,
                    valueFor('insuranceName', widget.insuranceNameController),
                    widget.changes.containsKey('insuranceName'),
                  ),
                  if (shouldShowField('insurancePolicyNumber'))
                    SizedBox(height: 12.sp),
                ],

                // Insurance Policy Number
                if (shouldShowField('insurancePolicyNumber'))
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).insurancePolicyNumber,
                    valueFor('insurancePolicyNumber',
                        widget.insurancePolicyNumberController),
                    widget.changes.containsKey('insurancePolicyNumber'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.sp),
        ],

        // 1st Emergency Contact Section
        if (hasFirstContactFields || !isMobile) ...[
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // 1st Emergency Contact Section Header
                Row(
                  children: [
                    CustomSvgImage(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_user_emergency_contact.svg',
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).emergencyContact,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                if (shouldShowField('firstContact_firstName')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).firstName,
                    valueFor('firstContact_firstName',
                        widget.firstContactFirstNameController),
                    widget.changes.containsKey('firstContact_firstName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_lastName')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).lastName,
                    valueFor('firstContact_lastName',
                        widget.firstContactLastNameController),
                    widget.changes.containsKey('firstContact_lastName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_relationship')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).relationship,
                    valueFor('firstContact_relationship',
                        widget.firstContactRelationshipController),
                    widget.changes.containsKey('firstContact_relationship'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_email')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).email,
                    valueFor('firstContact_email',
                        widget.firstContactEmailController),
                    widget.changes.containsKey('firstContact_email'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_phone')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).phoneNumber,
                    valueFor('firstContact_phone',
                        widget.firstContactPhoneController),
                    widget.changes.containsKey('firstContact_phone'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_language')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).language,
                    valueFor('firstContact_language',
                        widget.firstContactLanguageController),
                    widget.changes.containsKey('firstContact_language'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_country')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).country,
                    valueFor('firstContact_country',
                        widget.firstContactCountryController),
                    widget.changes.containsKey('firstContact_country'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_province')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).province,
                    valueFor('firstContact_province',
                        widget.firstContactProvinceController),
                    widget.changes.containsKey('firstContact_province'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_city')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).city,
                    valueFor('firstContact_city',
                        widget.firstContactCityController),
                    widget.changes.containsKey('firstContact_city'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_street'))
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).street,
                    valueFor('firstContact_street',
                        widget.firstContactStreetController),
                    widget.changes.containsKey('firstContact_street'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.sp),
        ],

        // 2nd Emergency Contact Section
        if (hasSecondContactFields || !isMobile)
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // 2nd Emergency Contact Section Header
                Row(
                  children: [
                    CustomSvgImage(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_user_emergency_contact.svg',
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).secondEmergencyContact,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                if (shouldShowField('secondContact_firstName')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).firstName,
                    valueFor('secondContact_firstName',
                        widget.secondContactFirstNameController),
                    widget.changes.containsKey('secondContact_firstName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_lastName')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).lastName,
                    valueFor('secondContact_lastName',
                        widget.secondContactLastNameController),
                    widget.changes.containsKey('secondContact_lastName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_relationship')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).relationship,
                    valueFor('secondContact_relationship',
                        widget.secondContactRelationshipController),
                    widget.changes.containsKey('secondContact_relationship'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_email')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).email,
                    valueFor('secondContact_email',
                        widget.secondContactEmailController),
                    widget.changes.containsKey('secondContact_email'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_phone')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).phoneNumber,
                    valueFor('secondContact_phone',
                        widget.secondContactPhoneController),
                    widget.changes.containsKey('secondContact_phone'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_language')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).language,
                    valueFor('secondContact_language',
                        widget.secondContactLanguageController),
                    widget.changes.containsKey('secondContact_language'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_country')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).country,
                    valueFor('secondContact_country',
                        widget.secondContactCountryController),
                    widget.changes.containsKey('secondContact_country'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_province')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).province,
                    valueFor('secondContact_province',
                        widget.secondContactProvinceController),
                    widget.changes.containsKey('secondContact_province'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_city')) ...[
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).city,
                    valueFor('secondContact_city',
                        widget.secondContactCityController),
                    widget.changes.containsKey('secondContact_city'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_street'))
                  buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).street,
                    valueFor('secondContact_street',
                        widget.secondContactStreetController),
                    widget.changes.containsKey('secondContact_street'),
                  ),
              ],
            ),
          ),
        // Request Note (only in New Details column).
        //
        // MOVED 29/9/2026 (Settings mobile bug p.10): it sat inside the 2nd
        // Emergency Contact card, which mobile hides unless that contact
        // changed — so an insurance-only request had no note field and Submit
        // (which needs the note) stayed grey for good.
        if (!isCurrentColumn) ...[
          SizedBox(height: 20.sp),
          CustomTextField(
            label: S.of(context).request_note,
            hint: S.of(context).textHere,
            controller: requestNoteController,
            required: true,
            maxLines: 3,
            // ADDED 8/9/2026 — the 0/500 counter was missing because
            // CustomTextField only renders one when a limit is asked
            // for: `maxLength`, or `showCharCount` (which implies 500).
            // This field passed neither, so there was nothing to show
            // and nothing capping the note either.
            maxLength: 500,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            textDirection:
                isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            onChanged: (_) {
              rebuild(() {});
            },
          )
        ],
      ],
    );
  }
}
