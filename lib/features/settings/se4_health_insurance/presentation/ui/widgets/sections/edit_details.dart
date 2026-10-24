/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: edit_details.dart
/// Purpose: The editable emergency-contact fields used by the request form.
/// Author: Amr Mesbah
/// Created at: 12/11/2024
/// Updated: 11/8/2026 - Added the standard header (Docs).
library;

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/inputs/field_sizing.dart';
import 'package:knowticed_plus/core/custom/inputs/phone_code_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/countries_list.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_country_picker.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/helper/location_data_service.dart';
import 'package:knowticed_plus/core/helper/stored_value_ar.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class EditableEmergencyContactInformationSection extends StatelessWidget {
  final bool isFirstContact; // true for 1st contact, false for 2nd contact

  // Controllers passed from parent
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController relationshipController;

  /// X-133: set for an optional section — draws the red minus on the title row.
  final VoidCallback? onRemove;
  final TextEditingController emailController;
  final TextEditingController mobilePhoneController;
  final TextEditingController languageController;
  final TextEditingController countryController;
  final TextEditingController provinceController;
  final TextEditingController cityController;
  final TextEditingController streetController;

  /// Set to true after the user taps Preview so empty fields show
  /// the "required" error state.
  final bool submitted;

  /// ADDED 9/10/2026 — shown under the header of an OPTIONAL contact (the
  /// 2nd emergency contact): "optional; if you add it, fill every field".
  final String? optionalHint;

  const EditableEmergencyContactInformationSection({
    super.key,
    this.isFirstContact = true,
    this.submitted = false,
    this.optionalHint,
    required this.firstNameController,
    required this.lastNameController,
    required this.relationshipController,
    this.onRemove,
    required this.emailController,
    required this.mobilePhoneController,
    required this.languageController,
    required this.countryController,
    required this.provinceController,
    required this.cityController,
    required this.streetController,
  });

  /// Shared look of every dropdown on this page: the value and the hint are
  /// 14 / 400 like the text fields beside them (Moataz 23/10/2026).
  TextStyle get _valueStyle =>
      StyleText.fontSize14Weight400.copyWith(color: AppColors.text);
  TextStyle get _hintStyle => StyleText.fontSize14Weight400
      .copyWith(color: AppColors.text.withValues(alpha: 0.4));

  /// Relationship is a DROPDOWN with an arrow (item 148, 21/10/2026). The
  /// value saved is the English word (Spouse…), the label follows the screen
  /// language. A saved value the list doesn't have is still shown and kept
  /// (K-50).
  Widget _relationshipDropdown(BuildContext context) {
    final S l = S.of(context);
    final Map<String, String> labels = <String, String>{
      'Spouse': l.spouse,
      'Parent': l.parent,
      'Child': l.child,
      'Sibling': l.sibling,
      'Relative': l.relative,
      'Friend': l.friend,
      'Other': l.other,
    };
    return ListenableBuilder(
      listenable: relationshipController,
      builder: (BuildContext context, _) {
        String current = relationshipController.text.trim();
        // A value saved in the screen language ("الأب", "Spouse") → English key.
        for (final MapEntry<String, String> e in labels.entries) {
          if (current.toLowerCase() == e.key.toLowerCase() ||
              current == e.value) {
            current = e.key;
          }
        }
        return CustomDropdown<String>(
          label: l.relationship,
          hint: l.enterContactRelation,
          hintStyle: _hintStyle,
          value: current.isEmpty ? null : current,
          fillColor: AppColors.background,
          enforceTypeScale: false,
          valueStyle: _valueStyle,
          errorText:
              submitted && current.isEmpty ? l.thisFieldIsRequired : null,
          items: <DropdownItem<String>>[
            ...labels.entries.map((MapEntry<String, String> e) =>
                DropdownItem<String>(value: e.key, label: e.value)),
            if (current.isNotEmpty && !labels.containsKey(current))
              DropdownItem<String>(
                  value: current, label: StoredValueAr.of(context, current)),
          ],
          onChanged: (String v) => relationshipController.text = v,
        );
      },
    );
  }

  static const List<String> _languages = <String>[
    'English',
    'Arabic',
    'French',
    'German',
    'Spanish',
    'Italian',
    'Turkish',
    'Urdu',
    'Hindi',
    'Chinese',
  ];

  Widget _languageDropdown(BuildContext context) {
    return ListenableBuilder(
      listenable: languageController,
      builder: (BuildContext context, _) {
        String current = languageController.text.trim();
        for (final String l in _languages) {
          if (StoredValueAr.of(context, l) == current ||
              l.toLowerCase() == current.toLowerCase()) {
            current = l;
          }
        }
        return CustomDropdown<String>(
          label: S.of(context).language,
          hint: S.of(context).enterLanguage,
          hintStyle: _hintStyle,
          value: current.isEmpty ? null : current,
          fillColor: AppColors.background,
          enforceTypeScale: false,
          valueStyle: _valueStyle,
          errorText: submitted && current.isEmpty
              ? S.of(context).thisFieldIsRequired
              : null,
          items: <DropdownItem<String>>[
            ..._languages.map((String l) => DropdownItem<String>(
                value: l, label: StoredValueAr.of(context, l))),
            if (current.isNotEmpty && !_languages.contains(current))
              DropdownItem<String>(
                  value: current, label: StoredValueAr.of(context, current)),
          ],
          onChanged: (String v) => languageController.text = v,
        );
      },
    );
  }

  /// The option whose English or Arabic name is [text], else null.
  LocationOption? _match(List<LocationOption> options, String text) {
    for (final LocationOption o in options) {
      if (o.matches(text)) return o;
    }
    return null;
  }

  /// A place dropdown: the value is the English name, the label follows the
  /// screen language; an unknown saved text is kept and shown translated.
  Widget _placeDropdown(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required List<LocationOption> options,
    required bool enabled,
    VoidCallback? onPicked,
  }) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final String raw = controller.text.trim();
    final LocationOption? hit = _match(options, raw);
    final String current = hit?.name ?? raw;
    return CustomDropdown<String>(
      label: label,
      hint: hint,
      hintStyle: _hintStyle,
      value: current.isEmpty ? null : current,
      fillColor: AppColors.background,
      enforceTypeScale: false,
      valueStyle: _valueStyle,
      enabled: enabled || current.isNotEmpty,
      errorText: submitted && current.isEmpty
          ? S.of(context).thisFieldIsRequired
          : null,
      items: <DropdownItem<String>>[
        ...options.map((LocationOption o) =>
            DropdownItem<String>(value: o.name, label: o.label(isAr))),
        if (current.isNotEmpty && hit == null)
          DropdownItem<String>(
              value: current, label: StoredValueAr.of(context, current)),
      ],
      onChanged: (String v) {
        controller.text = v;
        onPicked?.call();
      },
    );
  }

  /// The location data is read from an asset; rebuild once it is in.
  Widget _withLocations(Widget Function() build) => FutureBuilder<void>(
        future: LocationDataService.instance.load(),
        builder: (BuildContext _, AsyncSnapshot<void> __) => build(),
      );

  Widget _countryDropdown(BuildContext context) {
    return _withLocations(() => ListenableBuilder(
          listenable: countryController,
          builder: (BuildContext context, _) => _placeDropdown(
            context,
            label: S.of(context).country,
            hint: S.of(context).enterYourCountry,
            controller: countryController,
            options: LocationDataService.instance.countries(context),
            enabled: true,
            onPicked: () {
              provinceController.clear();
              cityController.clear();
            },
          ),
        ));
  }

  String? _iso(BuildContext context) => _match(
          LocationDataService.instance.countries(context),
          countryController.text.trim())
      ?.code;

  String? _stateCode(BuildContext context) {
    final String? iso = _iso(context);
    return _match(LocationDataService.instance.statesOf(iso),
            provinceController.text.trim())
        ?.code;
  }

  Widget _provinceDropdown(BuildContext context) {
    return _withLocations(() => ListenableBuilder(
          listenable: Listenable.merge(
              <Listenable>[countryController, provinceController]),
          builder: (BuildContext context, _) {
            final List<LocationOption> options =
                LocationDataService.instance.statesOf(_iso(context));
            return _placeDropdown(
              context,
              label: S.of(context).province,
              hint: S.of(context).enterYourStateOrProvince,
              controller: provinceController,
              options: options,
              enabled: options.isNotEmpty,
              onPicked: cityController.clear,
            );
          },
        ));
  }

  Widget _cityDropdown(BuildContext context) {
    return _withLocations(() => ListenableBuilder(
          listenable: Listenable.merge(<Listenable>[
            countryController,
            provinceController,
            cityController,
          ]),
          builder: (BuildContext context, _) {
            final List<LocationOption> options = LocationDataService.instance
                .citiesOf(_iso(context), _stateCode(context));
            return _placeDropdown(
              context,
              label: S.of(context).city,
              hint: S.of(context).enterYourCity,
              controller: cityController,
              options: options,
              enabled: options.isNotEmpty,
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;

    // Header text based on which contact
    final headerText = isFirstContact
        ? S.of(context).emergencyContact
        : S.of(context).secondEmergencyContact;

    return Column(
      children: [
        isMobile ? SizedBox(height: 0.sp) : SizedBox(),

        // X-133 (21/10/2026): an OPTIONAL section carries a red minus at the
        // right end of its title row; tapping it clears the fields and hides
        // the section (the caller owns both).
        Row(
          children: <Widget>[
            Expanded(
              child: SettingsHeader(
                // 0: the card around this section already applies 16.sp on
                // each side (FIXED 8/9/2026).
                horizontalPadding: 0,
                imagePath:
                    'assets/icons_assets/main_icons_assets/ic_user_emergency_contact.svg',
                text: headerText,
              ),
            ),
            if (onRemove != null)
              InkWell(
                onTapDown: (_) => HapticController.high(),
                onTap: onRemove,
                child: CustomSvgImage(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg',
                  width: 18.sp,
                  height: 18.sp,
                  fit: BoxFit.fill,
                ),
              ),
          ],
        ),
        // 9/10/2026 — the optional-contact note (2nd emergency contact).
        if (optionalHint != null && optionalHint!.isNotEmpty) ...[
          SizedBox(height: 6.sp),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              optionalHint!,
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
          ),
        ],
        SizedBox(height: 16.sp),

        // First Row/Column: First Name, Last Name, Relationship
        isMobile
            ? Column(
                children: [
                  CustomTextField(
                    label: S.of(context).firstName,
                    hint: S.of(context).enterYourFirstName,
                    fillColor: AppColors.background,
                    controller: firstNameController,
                    enabled: true,
                    submitted: submitted,
                    required: true,
                  ),
                  SizedBox(height: 12.sp),
                  CustomTextField(
                    label: S.of(context).lastName,
                    fillColor: AppColors.background,
                    hint: S.of(context).enterYourLastName,
                    controller: lastNameController,
                    enabled: true,
                    submitted: submitted,
                    required: true,
                  ),
                  SizedBox(height: 12.sp),
                  _relationshipDropdown(context),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).firstName,
                      hint: S.of(context).enterYourFirstName,
                      controller: firstNameController,
                      fillColor: AppColors.background,
                      enabled: true,
                      submitted: submitted,
                      required: true,
                    ),
                  ),
                  SizedBox(width: 16.sp), // R-1
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).lastName,
                      hint: S.of(context).enterYourLastName,
                      controller: lastNameController,
                      fillColor: AppColors.background,
                      enabled: true,
                      submitted: submitted,
                      required: true,
                    ),
                  ),
                  SizedBox(width: 16.sp), // R-1
                  Expanded(
                    child: _relationshipDropdown(context),
                  ),
                ],
              ),
        SizedBox(height: 12.sp),

        // Second Row/Column: Email, Mobile Phone, Language
        isMobile
            ? Column(
                children: [
                  CustomTextField(
                    label: S.of(context).email,
                    hint: S.of(context).enterYourEmail,
                    controller: emailController,
                    enabled: true,
                    submitted: submitted,
                    required: true,
                    fillColor: AppColors.background,
                  ),
                  SizedBox(height: 12.sp),
                  // Bug report (Settings mobile p.4): the number had no separate
                  // country-code box — see EmergencyPhoneField.
                  EmergencyPhoneField(
                    label: S.of(context).phoneNumber,
                    hint: S.of(context).enterYourMobilePhone,
                    controller: mobilePhoneController,
                    submitted: submitted,
                  ),
                  SizedBox(height: 12.sp),
                  _languageDropdown(context),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).email,
                      hint: S.of(context).enterYourEmail,
                      controller: emailController,
                      fillColor: AppColors.background,
                      enabled: true,
                      submitted: submitted,
                      required: true,
                    ),
                  ),
                  SizedBox(width: 16.sp), // R-1
                  Expanded(
                    child: EmergencyPhoneField(
                      label: S.of(context).phoneNumber,
                      hint: S.of(context).enterPhoneNumber,
                      controller: mobilePhoneController,
                      submitted: submitted,
                    ),
                  ),
                  SizedBox(width: 16.sp), // R-1
                  Expanded(
                    child: _languageDropdown(context),
                  ),
                ],
              ),
        SizedBox(height: 12.sp),

        // Third Row/Column: Country, Province, City
        isMobile
            ? Column(
                children: [
                  _countryDropdown(context),
                  SizedBox(height: 12.sp),
                  _provinceDropdown(context),
                  SizedBox(height: 12.sp),
                  _cityDropdown(context),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _countryDropdown(context),
                  ),
                  SizedBox(width: 16.sp), // R-1
                  Expanded(
                    child: _provinceDropdown(context),
                  ),
                  SizedBox(width: 16.sp), // R-1
                  Expanded(
                    child: _cityDropdown(context),
                  ),
                ],
              ),
        SizedBox(height: 12.sp),

        // Fourth Row: Street (full width on both mobile and desktop)
        CustomTextField(
          label: S.of(context).street,
          hint: S.of(context).enterYourStreetAddress,
          controller: streetController,
          fillColor: AppColors.background,
          enabled: true,
          submitted: submitted,
          required: true,
        ),
      ],
    );
  }
}

/// Emergency-contact phone with its own country-code box.
///
/// ADDED 29/9/2026 (Settings mobile bug p.4 — "add the field of the code").
/// The contact's phone is stored as ONE string ("+20 10 2456 7316"), so this
/// widget splits it into a dial code (picked from the app's country picker)
/// and the number, and writes "+<code> `<number>`" back into [controller]. The
/// edit page keeps comparing [controller] with the stored value exactly as
/// before, so change tracking and the request payload are unchanged.
class EmergencyPhoneField extends StatefulWidget {
  const EmergencyPhoneField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.submitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool submitted;

  @override
  State<EmergencyPhoneField> createState() => _EmergencyPhoneFieldState();
}

class _EmergencyPhoneFieldState extends State<EmergencyPhoneField> {
  static const String _defaultDialCode = '20';

  late String _dialCode;
  late final TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    final String raw = widget.controller.text.trim();
    String dial = _defaultDialCode;
    String number = raw;
    if (raw.startsWith('+')) {
      final String digits = raw.substring(1);
      // Longest dial code that the stored value starts with ("+20…", "+965…").
      String? best;
      for (final Country c in countries) {
        if (c.dialCode.isNotEmpty &&
            digits.startsWith(c.dialCode) &&
            (best == null || c.dialCode.length > best.length)) {
          best = c.dialCode;
        }
      }
      if (best != null) {
        dial = best;
        number = digits.substring(best.length).trim();
      }
    }
    _dialCode = dial;
    _numberController = TextEditingController(text: number);
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  String get _isoCode {
    for (final Country c in countries) {
      if (c.dialCode == _dialCode) return c.code;
    }
    return '';
  }

  void _sync() {
    final String number = _numberController.text.trim();
    widget.controller.text = number.isEmpty ? '' : '+$_dialCode $number';
  }

  Future<void> _pickCountry() async {
    final Country? picked = await showCountryPickerDialog(context);
    if (picked == null || !mounted) return;
    setState(() => _dialCode = picked.dialCode);
    _sync();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 21/10/2026 (Moataz: phone boxes sat higher than Email): the label
        // is drawn like CustomTextField's own — RichText (a Text picks up the
        // ambient line height) + kFieldLabelGap — and both boxes take the
        // shared field height, so the row lines up with Email beside it.
        RichText(
          text: TextSpan(
            text: widget.label,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
        SizedBox(height: kFieldLabelGap.sp),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // 23/10/2026 (Moataz): in Arabic the code sits on the RIGHT and the
          // number on the left, so the row follows the screen direction (the
          // number itself still reads left to right).
          children: [
            // Country code — opens the picker; the shared box (R-39).
            PhoneCodeBox(
              codeOrDialCode: _isoCode,
              height: FieldSizing.height,
              fillColor: AppColors.background,
              onTap: _pickCountry,
            ),
            SizedBox(width: 16.sp), // R-1
            Expanded(
              child: CustomTextField(
                height: FieldSizing.height,
                hint: widget.hint,
                controller: _numberController,
                fillColor: AppColors.background,
                keyboardType: TextInputType.phone,
                // 21/10/2026: digits only, like the Personal phone.
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textDirection: TextDirection.ltr,
                textAlign: Localizations.localeOf(context).languageCode == 'ar'
                    ? TextAlign.right
                    : TextAlign.left,
                enabled: true,
                submitted: widget.submitted,
                required: true,
                onChanged: (_) => _sync(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
