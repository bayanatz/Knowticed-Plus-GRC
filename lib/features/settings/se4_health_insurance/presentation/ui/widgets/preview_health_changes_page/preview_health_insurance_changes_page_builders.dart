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
    // X-127 / D-224 (21/10/2026): ONLY the changed fields, on every device.
    bool shouldShowField(String fieldKey) =>
        widget.changes.containsKey(fieldKey);

    // D-224 (21/10/2026): one Current → New pair per changed field — the
    // shared core widget, stacked on the phone, side by side otherwise. The
    // current value is the edit page's `oldValue`; the controller holds the
    // new one.
    Widget buildFieldDisplay(
      BuildContext context,
      bool lightMode,
      String label,
      String key,
      TextEditingController controller,
    ) {
      final dynamic change = widget.changes[key];
      final String current = (change is Map && change['oldValue'] != null)
          ? change['oldValue'].toString()
          : controller.text;
      return CurrentNewValuePair(
        label: label,
        current: current,
        next: controller.text,
        changed: widget.changes.containsKey(key),
        stacked: isMobile,
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
        if (hasInsuranceFields) ...[
          Container(
            padding: EdgeInsets.all(16.sp),
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

                SizedBox(height: 16.sp),

                // Insurance Name
                if (shouldShowField('insuranceName')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).insuranceName,
                      'insuranceName',
                      widget.insuranceNameController),
                  if (shouldShowField('insurancePolicyNumber'))
                    SizedBox(height: 12.sp),
                ],

                // Insurance Policy Number
                if (shouldShowField('insurancePolicyNumber'))
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).insurancePolicyNumber,
                      'insurancePolicyNumber',
                      widget.insurancePolicyNumberController),
              ],
            ),
          ),
          SizedBox(height: 16.sp), // 21/10/2026: 16 between cards (was 20 + 12)
        ],

        // 1st Emergency Contact Section
        if (hasFirstContactFields) ...[
          Container(
            padding: EdgeInsets.all(16.sp),
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

                SizedBox(height: 16.sp),

                if (shouldShowField('firstContact_firstName')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).firstName,
                      'firstContact_firstName',
                      widget.firstContactFirstNameController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_lastName')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).lastName,
                      'firstContact_lastName',
                      widget.firstContactLastNameController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_relationship')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).relationship,
                      'firstContact_relationship',
                      widget.firstContactRelationshipController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_email')) ...[
                  buildFieldDisplay(context, lightMode, S.of(context).email,
                      'firstContact_email', widget.firstContactEmailController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_phone')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).phoneNumber,
                      'firstContact_phone',
                      widget.firstContactPhoneController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_language')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).language,
                      'firstContact_language',
                      widget.firstContactLanguageController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_country')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).country,
                      'firstContact_country',
                      widget.firstContactCountryController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_province')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).province,
                      'firstContact_province',
                      widget.firstContactProvinceController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_city')) ...[
                  buildFieldDisplay(context, lightMode, S.of(context).city,
                      'firstContact_city', widget.firstContactCityController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_street'))
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).street,
                      'firstContact_street',
                      widget.firstContactStreetController),
              ],
            ),
          ),
          SizedBox(height: 16.sp), // 21/10/2026: 16 between cards (was 20 + 12)
        ],

        // 2nd Emergency Contact Section
        if (hasSecondContactFields)
          Container(
            padding: EdgeInsets.all(16.sp),
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

                SizedBox(height: 16.sp),

                if (shouldShowField('secondContact_firstName')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).firstName,
                      'secondContact_firstName',
                      widget.secondContactFirstNameController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_lastName')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).lastName,
                      'secondContact_lastName',
                      widget.secondContactLastNameController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_relationship')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).relationship,
                      'secondContact_relationship',
                      widget.secondContactRelationshipController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_email')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).email,
                      'secondContact_email',
                      widget.secondContactEmailController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_phone')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).phoneNumber,
                      'secondContact_phone',
                      widget.secondContactPhoneController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_language')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).language,
                      'secondContact_language',
                      widget.secondContactLanguageController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_country')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).country,
                      'secondContact_country',
                      widget.secondContactCountryController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_province')) ...[
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).province,
                      'secondContact_province',
                      widget.secondContactProvinceController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_city')) ...[
                  buildFieldDisplay(context, lightMode, S.of(context).city,
                      'secondContact_city', widget.secondContactCityController),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_street'))
                  buildFieldDisplay(
                      context,
                      lightMode,
                      S.of(context).street,
                      'secondContact_street',
                      widget.secondContactStreetController),
              ],
            ),
          ),
        // Request Note (only in New Details column).
        //
        // MOVED 29/9/2026 (Settings mobile bug p.10): it sat inside the 2nd
        // Emergency Contact card, which mobile hides unless that contact
        // changed — so an insurance-only request had no note field and Submit
        // (which needs the note) stayed grey for good.
        if (!isCurrentColumn && !_isOnlySecondContactRemoval()) ...[
          // 21/10/2026 (Moataz: gap too big on the phone): 16 between the last
          // card and the note — the cards above already end with 16, so only
          // the 2nd-contact card (which has no trailing gap) adds one here.
          if (hasSecondContactFields) SizedBox(height: 16.sp),
          // 21/10/2026 (Moataz): the note sits in its own card, like the
          // Personal Information preview (D-207 / C-18).
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
            ),
          ),
        ],
      ],
    );
  }
}
