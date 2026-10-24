/// Module: settings / se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: section_change_request_page.dart
/// Description: Request Change for any Settings section that the employee
///              cannot edit directly (Company Information first). The page
///              lists the section's current values as editable fields,
///              grouped like the view page, and sends ONE change request
///              (section + changed fields + note).
/// Author: Knowticed Plus team
/// Created at: 18/10/2026
/// Updated: 20/10/2026 - Rebuilt to Moataz's Settings review (batch 2):
///          page title "Settings › Editing Company Information" (same
///          pattern as Personal Data); the fields are divided into the same
///          GROUPS as the view page (Company, Service, Contact) inside ONE
///          white box — 3 per row on landscape / large, 2 on iPad portrait, 1
///          on the phone (D-205); no 5-column mixed grid, no empty space on
///          the right; list values are dropdowns with their arrow (Country /
///          State / City from the location data, K-50 keeps a saved value
///          the list doesn't have); the phone uses the Settings phone field
///          (code picker + number); Request Note full width, multi-line,
///          0/500 (C-18); Discard / Submit pinned to the bottom, Submit GREY
///          while disabled (D-202, X-131); the shared confirm → success flow
///          and back to Settings afterwards (X-126, X-128).
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/inputs/phone_code_box.dart';
import 'package:knowticed_plus/core/helper/stored_value_ar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/countries_list.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/current_new_value_pair.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_country_picker.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/helper/location_data_service.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/phone_country_lookup.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/widgets/request_error_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// How a requestable field is edited.
enum RequestableFieldKind {
  /// Plain text.
  text,

  /// A dropdown over [RequestableField.options].
  dropdown,

  /// Country dropdown (the location data).
  country,

  /// State / Province dropdown, filtered by the chosen country.
  province,

  /// City dropdown, filtered by the chosen country and province.
  city,

  /// The Settings phone field: country-code picker + number.
  phone,
}

/// One value the employee may ask to change.
class RequestableField {
  const RequestableField({
    required this.key,
    required this.label,
    required this.currentValue,
    this.kind = RequestableFieldKind.text,
    this.options = const <String>[],
    this.optionLabelsAr = const <String, String>{},
  });

  /// The stored field name the reviewer applies (e.g. `companyName`).
  final String key;
  final String label;
  final String currentValue;
  final RequestableFieldKind kind;

  /// Choices for [RequestableFieldKind.dropdown].
  final List<String> options;

  /// Arabic label of an option (or of a saved value), by its stored text.
  final Map<String, String> optionLabelsAr;
}

/// A titled group of fields — the same groups as the view page.
class RequestableGroup {
  const RequestableGroup({
    required this.title,
    required this.iconPath,
    required this.fields,
  });

  final String title;
  final String iconPath;
  final List<RequestableField> fields;
}

class SectionChangeRequestPage extends StatefulWidget {
  const SectionChangeRequestPage({
    super.key,
    required this.section,
    required this.sectionTitle,
    required this.groups,
    this.pageTitle,
    this.previewTitle,
  });

  /// Stored section name (English, stable), e.g. `Company Information`.
  final String section;

  /// Localized section name, used in the request card.
  final String sectionTitle;

  /// The page title after "Settings ›" — e.g. "Editing Company Information".
  /// Null falls back to [sectionTitle].
  final String? pageTitle;

  /// "Settings › Preview <section>" — the Preview step's title (D-224).
  final String? previewTitle;

  final List<RequestableGroup> groups;

  @override
  State<SectionChangeRequestPage> createState() =>
      _SectionChangeRequestPageState();
}

class _SectionChangeRequestPageState extends State<SectionChangeRequestPage> {
  final RequestsCubit _requestsCubit = RequestsCubit();
  final TextEditingController _noteController = TextEditingController();

  /// Current value per field key (text fields and dropdowns alike).
  late final Map<String, String> _values = <String, String>{
    for (final RequestableGroup g in widget.groups)
      for (final RequestableField f in g.fields) f.key: f.currentValue,
  };
  late final Map<String, String> _original = Map<String, String>.of(_values);
  late final Map<String, TextEditingController> _textControllers =
      <String, TextEditingController>{
    for (final RequestableGroup g in widget.groups)
      for (final RequestableField f in g.fields)
        if (f.kind == RequestableFieldKind.text ||
            f.kind == RequestableFieldKind.phone)
          f.key: TextEditingController(text: _phoneNumberOnly(f))
            ..addListener(() => _onTextChanged(f.key)),
  };

  /// The dial code the phone field shows (with its "+"), per phone field.
  late final Map<String, String> _dialCodes = <String, String>{
    for (final RequestableGroup g in widget.groups)
      for (final RequestableField f in g.fields)
        if (f.kind == RequestableFieldKind.phone) f.key: _dialCodeOf(f),
  };

  bool _submitFailed = false;

  List<RequestableField> get _allFields => <RequestableField>[
        for (final RequestableGroup g in widget.groups) ...g.fields,
      ];

  /// The new value of [f] when it MEANS something else than the stored one,
  /// else null. 21/10/2026 (Moataz): was an exact text compare, so picking
  /// "Egypt" over a stored "egypt" (or the Arabic name) counted as a change.
  String? _changedValueOf(RequestableField f) {
    final String next = (_values[f.key] ?? '').trim();
    final String was = (_original[f.key] ?? '').trim();
    return _sameValue(f, was, next) ? null : next;
  }

  bool _sameValue(RequestableField f, String a, String b) {
    if (a == b || a.toLowerCase() == b.toLowerCase()) return true;
    switch (f.kind) {
      case RequestableFieldKind.phone:
        String digits(String v) => v.replaceAll(RegExp(r'[^0-9]'), '');
        return digits(a) == digits(b);
      case RequestableFieldKind.country:
      case RequestableFieldKind.province:
      case RequestableFieldKind.city:
        final LocationDataService svc = LocationDataService.instance;
        final List<LocationOption> options =
            f.kind == RequestableFieldKind.country
                ? svc.countries(context)
                : <LocationOption>[
                    for (final LocationOption c in svc.countries(context))
                      ...svc.statesOf(c.code),
                  ];
        return options
            .any((LocationOption o) => o.matchesLoose(a) && o.matchesLoose(b));
      case RequestableFieldKind.text:
      case RequestableFieldKind.dropdown:
        return false;
    }
  }

  /// R-6 (21/10/2026): set by a Preview press with an empty field — only then
  /// do empty fields show "required".
  bool _submitted = false;

  bool _isEmpty(RequestableField f) => (f.kind == RequestableFieldKind.phone
          ? (_textControllers[f.key]?.text ?? '')
          : (_values[f.key] ?? ''))
      .trim()
      .isEmpty;

  String? _requiredError(RequestableField f) =>
      _submitted && _isEmpty(f) ? S.of(context).thisFieldIsRequired : null;

  /// Every field is required (21/10/2026): an emptied field is not sent.
  void _onPreviewPressed() {
    if (_allFields.any(_isEmpty)) {
      setState(() => _submitted = true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(S.of(context).fillAllRequiredFields),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }
    _openPreview();
  }

  List<FieldChange> get _changes => <FieldChange>[
        for (final RequestableField f in _allFields)
          if (_changedValueOf(f) != null)
            FieldChange(
              fieldName: f.key,
              oldValue: _original[f.key]!,
              newValue: _changedValueOf(f)!,
            ),
      ];

  @override
  void initState() {
    super.initState();
    _noteController.addListener(() => setState(() {}));
    // Country / State / City lists come from the location data file.
    LocationDataService.instance.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    for (final TextEditingController c in _textControllers.values) {
      c.dispose();
    }
    _noteController.dispose();
    _requestsCubit.close();
    super.dispose();
  }

  // ── phone helpers ─────────────────────────────────────────────────────

  /// A stored phone may already carry its code ("+20 1501503767"); the edit
  /// field shows the code in its own box and the number alone.
  static String _phoneNumberOnly(RequestableField f) {
    if (f.kind != RequestableFieldKind.phone) return f.currentValue;
    final String v = f.currentValue.trim();
    if (v.startsWith('+')) {
      final int space = v.indexOf(' ');
      return space == -1 ? '' : v.substring(space + 1).trim();
    }
    return v;
  }

  static String _dialCodeOf(RequestableField f) {
    final String v = f.currentValue.trim();
    if (v.startsWith('+')) {
      final int space = v.indexOf(' ');
      return space == -1 ? v : v.substring(0, space);
    }
    return PhoneCountryLookup.dialCodeOf('EG');
  }

  void _onTextChanged(String key) {
    final RequestableField f = _allFields.firstWhere((x) => x.key == key);
    final String text = _textControllers[key]!.text;
    setState(() {
      _values[key] = f.kind == RequestableFieldKind.phone
          ? (text.trim().isEmpty ? '' : '${_dialCodes[key]} ${text.trim()}')
          : text;
    });
  }

  Future<void> _pickCountryCode(String key) async {
    final Country? picked = await showCountryPickerDialog(
      context,
      selectedDialCode: _dialCodes[key]?.replaceAll('+', ''),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dialCodes[key] = '+${picked.dialCode}';
      _onTextChanged(key);
    });
  }

  // ── location helpers ──────────────────────────────────────────────────

  String? _isoOfCountryLabel(String label) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    for (final LocationOption o
        in LocationDataService.instance.countries(context)) {
      if (o.label(isArabic) == label || o.name == label) return o.code;
    }
    return null;
  }

  String? _codeOfProvinceLabel(String? iso, String label) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    for (final LocationOption o in LocationDataService.instance.statesOf(iso)) {
      if (o.label(isArabic) == label || o.name == label) return o.code;
    }
    return null;
  }

  String? _valueOfKind(RequestableFieldKind kind) {
    for (final RequestableField f in _allFields) {
      if (f.kind == kind) return _values[f.key];
    }
    return null;
  }

  // ── submit ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    _submitFailed = false;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json',
      confirmTitle: S.of(context).requesting_a_change,
      confirmSubtitle: S.of(context).are_you_sure_submit_request,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      confirmWidth: 411,
      successWidth: 411,
      onConfirm: () => _performSubmit(isArabic),
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: S.of(context).request_submitted,
      successSubtitle: S.of(context).successfully_submitted_request,
      onSuccessComplete: () {
        final String? warning = _requestsCubit.state.warning;
        _requestsCubit.clearMessages();
        if (warning != null) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(warning),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ));
        }
        // X-128: back to Settings › <section> — pops the Preview step and
        // this edit page.
        for (int i = 0; i < 2; i++) {
          if (navigator.canPop()) navigator.pop();
        }
      },
    );

    if (!_submitFailed || !mounted) return;
    _requestsCubit.clearMessages();
    await RequestErrorDialog.show(context);
  }

  Future<bool> _performSubmit(bool isArabic) async {
    final employee = AppControllers.employee.employeeEntity;
    final bool ok = await _requestsCubit.submit(
      section: widget.section,
      employeeId: employee?.id ?? '',
      employeeName:
          '${employee?.firstName ?? ''} ${employee?.lastName ?? ''}'.trim(),
      employeeEmail: employee?.email ?? '',
      requestNote: _noteController.text.trim(),
      changes: _changes,
      isArabic: isArabic,
    );
    if (!ok) _submitFailed = true;
    return ok;
  }

  // ── build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isPhone = kpIsPhoneLayout(context);
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    // D-205: 3 per row on landscape / large, 2 on iPad portrait, 1 on phone.
    final int perRow = isPhone ? 1 : (isPortrait ? 2 : 3);
    final bool canPreview = _changes.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.of(context).settings,
        secondTitle: widget.pageTitle ?? widget.sectionTitle,
        onFirstTap: () => Navigator.of(context).maybePop(),
        onSecondTap: () => Navigator.of(context).maybePop(),
        child: SideFrameBoundedBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // ONE white box with the view page's groups.
                        // D-223 / MOATAZ_RULES 6.2 (21/10/2026): an EDIT page
                        // gives each group its OWN section box, 16 between.
                        for (int g = 0;
                            g < widget.groups.length;
                            g++) ...<Widget>[
                          if (g > 0) SizedBox(height: 16.sp),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.sp),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SettingsHeader(
                                  horizontalPadding: 0,
                                  imagePath: widget.groups[g].iconPath,
                                  text: widget.groups[g].title,
                                ),
                                SizedBox(height: 12.sp),
                                _grid(widget.groups[g].fields, perRow),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 16.sp),
                        // Request Note: own white section, full width,
                        // multi-line, 0/500 (D-207, C-18).
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.sp),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: CustomTextField(
                            label: S.of(context).requestNote,
                            hint: S.of(context).textHere,
                            controller: _noteController,
                            required: true,
                            maxLength: 500,
                            maxLines: 3,
                            fillColor: AppColors.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.sp),
              _actionButtons(context, isPhone, canPreview),
              SizedBox(height: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  /// Fields laid out [perRow] per row, every row's boxes level (D-12); the
  /// last row is padded with empty cells so nothing stretches.
  Widget _grid(List<RequestableField> fields, int perRow) {
    // 21/10/2026 (Moataz, R-1): a group of two fields splits the row in
    // halves (Service: Industry | Company Size), not thirds with a gap.
    if (perRow > 2 && fields.length == 2) perRow = 2;
    // R-2: a field left alone on the last row takes half the width.
    final int lone = perRow > 1 ? fields.length % perRow : 0;
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < fields.length; i += perRow) {
      final List<Widget> cells = <Widget>[];
      final bool lastLone = lone == 1 && i == fields.length - 1;
      final int cols = lastLone ? 2 : perRow;
      for (int j = 0; j < cols; j++) {
        if (j > 0) cells.add(SizedBox(width: 16.sp));
        final int idx = i + j;
        cells.add(Expanded(
          child: idx < fields.length
              ? _field(fields[idx])
              : const SizedBox.shrink(),
        ));
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: 12.sp));
      rows.add(
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: cells));
    }
    return Column(children: rows);
  }

  Widget _field(RequestableField f) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    switch (f.kind) {
      case RequestableFieldKind.text:
        return CustomTextField(
          label: f.label,
          hint: S.of(context).textHere,
          controller: _textControllers[f.key],
          fillColor: AppColors.background,
          errorText: _requiredError(f),
        );
      case RequestableFieldKind.dropdown:
        return _dropdown(f, f.options, labelsAr: f.optionLabelsAr);
      case RequestableFieldKind.country:
        return _dropdown(
          f,
          LocationDataService.instance
              .countries(context)
              .map((LocationOption o) => o.label(isArabic))
              .toList(),
          labelsAr: _locationLabelsAr(
              LocationDataService.instance.countries(context)),
          onPicked: () {
            // A new country clears the dependent lists' values.
            for (final RequestableField x in _allFields) {
              if (x.kind == RequestableFieldKind.province ||
                  x.kind == RequestableFieldKind.city) {
                _values[x.key] = '';
              }
            }
          },
        );
      case RequestableFieldKind.province:
        final List<LocationOption> states = LocationDataService.instance
            .statesOf(_isoOfCountryLabel(
                _valueOfKind(RequestableFieldKind.country) ?? ''));
        return _dropdown(
          f,
          states.map((LocationOption o) => o.label(isArabic)).toList(),
          labelsAr: _locationLabelsAr(states),
          onPicked: () {
            for (final RequestableField x in _allFields) {
              if (x.kind == RequestableFieldKind.city) _values[x.key] = '';
            }
          },
        );
      case RequestableFieldKind.city:
        final String? iso = _isoOfCountryLabel(
            _valueOfKind(RequestableFieldKind.country) ?? '');
        final List<LocationOption> cities = LocationDataService.instance
            .citiesOf(
                iso,
                _codeOfProvinceLabel(
                    iso, _valueOfKind(RequestableFieldKind.province) ?? ''));
        return _dropdown(
          f,
          cities.map((LocationOption o) => o.label(isArabic)).toList(),
          labelsAr: _locationLabelsAr(cities),
        );
      case RequestableFieldKind.phone:
        return _phoneField(f, isArabic);
    }
  }

  /// English or Arabic spelling of a place → its Arabic label.
  Map<String, String> _locationLabelsAr(List<LocationOption> options) =>
      <String, String>{
        for (final LocationOption o in options)
          if (o.nameAr != null && o.nameAr!.isNotEmpty) ...<String, String>{
            o.name: o.nameAr!,
            o.nameAr!: o.nameAr!,
          },
      };

  /// Arabic for common saved values the lists do not hold.
  static const Map<String, String> _commonAr = <String, String>{
    'Egypt': 'مصر',
    'Cairo': 'القاهرة',
    'Giza': 'الجيزة',
    'Alexandria': 'الإسكندرية',
    'New Administrative Capital': 'العاصمة الإدارية الجديدة',
    'Government': 'حكومي',
    'Private': 'قطاع خاص',
    'Technology': 'التقنية',
    'Retail': 'التجزئة',
    'Healthcare': 'الرعاية الصحية',
    'Finance': 'المالية',
    'Education': 'التعليم',
    'Real Estate': 'العقارات',
    'Manufacturing': 'الصناعة',
    'Other': 'أخرى',
  };

  /// A dropdown with its arrow; a saved value the list doesn't have is still
  /// shown and kept (K-50).
  Widget _dropdown(RequestableField f, List<String> options,
      {VoidCallback? onPicked, Map<String, String> labelsAr = const {}}) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    // 23/10/2026 (Moataz: "why is it not translated?"): the stored text is
    // kept as the value, but on the Arabic screen it is SHOWN in Arabic.
    String shown(String v) => isAr
        ? (labelsAr[v] ?? _commonAr[v] ?? StoredValueAr.of(context, v))
        : StoredValueAr.of(context, v);
    final String current = _values[f.key] ?? '';
    final List<String> items = <String>[
      ...options,
      if (current.isNotEmpty && !options.contains(current)) current,
    ];
    return CustomDropdown<String>(
      label: f.label,
      hint: '${S.of(context).select} ${f.label}',
      value: current.isEmpty ? null : current,
      enabled: items.isNotEmpty,
      errorText: _requiredError(f),
      borderRadius: BorderRadius.circular(4.r),
      items: items
          .map((String v) => DropdownItem<String>(value: v, label: shown(v)))
          .toList(),
      onChanged: (String v) {
        setState(() {
          _values[f.key] = v;
          onPicked?.call();
        });
      },
    );
  }

  /// The Settings phone field: the country-code box opens the shared picker,
  /// the number is typed beside it (the same block as Personal Information).
  Widget _phoneField(RequestableField f, bool isArabic) {
    final String code = _dialCodes[f.key] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // RichText, not Text (21/10/2026): a Text merges the ambient
        // DefaultTextStyle height and comes out taller than the label
        // CustomTextField draws, pushing the phone pair out of line with the
        // field beside it (same fix as the Personal Information edit page).
        RichText(
          text: TextSpan(
            text: f.label,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.text, fontSize: 14.sp),
          ),
        ),
        SizedBox(height: kFieldLabelGap.sp),
        Row(
          children: <Widget>[
            PhoneCodeBox(
              codeOrDialCode: code.replaceAll('+', ''),
              fillColor: AppColors.background,
              onTap: () => _pickCountryCode(f.key),
            ),
            SizedBox(width: 16.sp),
            Expanded(
              child: CustomTextField(
                hint: S.of(context).enterThePhoneNumber,
                controller: _textControllers[f.key],
                keyboardType: TextInputType.phone,
                // 21/10/2026: digits only, like Personal / Health.
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                errorText: _requiredError(f),
                fillColor: AppColors.background,
                textDirection: ui.TextDirection.ltr,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// D-202 / X-131: Discard at the left edge, Preview at the right edge, the
  /// same width, Preview GREY until something changed. The flow is
  /// Edit → Preview (Current / New) → Submit (item 134, 21/10/2026).
  Widget _actionButtons(BuildContext context, bool isPhone, bool canPreview) {
    final Widget discard = customButton(
      title: S.of(context).discardChange,
      function: () => Navigator.of(context).maybePop(),
      color: AppColors.darkGrey,
      width: isPhone ? double.infinity : 150.w,
      height: 38.h,
      radius: 8.r,
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
    );
    // R-3: disabled = grey, black text, 50%.
    final Widget preview = Opacity(
      opacity: canPreview ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !canPreview,
        child: customButton(
          title: S.of(context).preview,
          function: _onPreviewPressed,
          color: canPreview ? AppColors.primary : AppColors.grey,
          width: isPhone ? double.infinity : 150.w,
          height: 38.h,
          radius: 8.r,
          textStyle: StyleText.fontSize16Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ),
    );
    return Row(
      children: isPhone
          ? <Widget>[
              Expanded(child: discard),
              SizedBox(width: 16.sp),
              Expanded(child: preview),
            ]
          : <Widget>[discard, const Spacer(), preview],
    );
  }

  /// One Current → New row per changed field, for the Preview step.
  List<_PreviewChange> get _previewChanges => <_PreviewChange>[
        for (final RequestableField f in _allFields)
          if (_changedValueOf(f) != null)
            _PreviewChange(
              label: f.label,
              current: f.kind == RequestableFieldKind.phone
                  ? _phoneDisplay(f, _phoneNumberOnly(f), _dialCodes[f.key])
                  : f.currentValue,
              next: f.kind == RequestableFieldKind.phone
                  ? _phoneDisplay(
                      f, _textControllers[f.key]?.text ?? '', _dialCodes[f.key])
                  : (_changedValueOf(f) ?? ''),
            ),
      ];

  static String _phoneDisplay(RequestableField f, String number, String? code) {
    final String n = number.trim();
    if (n.isEmpty) return '';
    return code == null || code.isEmpty ? n : '$code $n';
  }

  void _openPreview() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _SectionChangesPreviewPage(
        title: widget.previewTitle ?? widget.pageTitle ?? widget.sectionTitle,
        changes: _previewChanges,
        noteController: _noteController,
        onSubmit: _submit,
      ),
    ));
  }
}

class _PreviewChange {
  const _PreviewChange(
      {required this.label, required this.current, required this.next});
  final String label;
  final String current;
  final String next;
}

/// The Preview step of a section change request (Company, Social …):
/// "Settings › Preview <section>", only the changed fields as Current → New
/// (D-224), the Request Note (editable, 0/500), Discard | Submit pinned
/// (D-202), Submit GREY until the note is written (X-131).
class _SectionChangesPreviewPage extends StatefulWidget {
  const _SectionChangesPreviewPage({
    required this.title,
    required this.changes,
    required this.noteController,
    required this.onSubmit,
  });

  final String title;
  final List<_PreviewChange> changes;
  final TextEditingController noteController;
  final Future<void> Function() onSubmit;

  @override
  State<_SectionChangesPreviewPage> createState() =>
      _SectionChangesPreviewPageState();
}

class _SectionChangesPreviewPageState
    extends State<_SectionChangesPreviewPage> {
  @override
  void initState() {
    super.initState();
    widget.noteController.addListener(_onNote);
  }

  @override
  void dispose() {
    widget.noteController.removeListener(_onNote);
    super.dispose();
  }

  void _onNote() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final bool isPhone = kpIsPhoneLayout(context);
    final bool canSubmit = widget.noteController.text.trim().isNotEmpty;
    final S l = S.of(context);

    Widget box(Widget child) => Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: child,
        );

    final Widget discard = customButton(
      title: l.discardChange,
      function: () => Navigator.of(context).maybePop(),
      color: AppColors.darkGrey,
      width: isPhone ? double.infinity : 150.w,
      height: 38.h,
      radius: 8.r,
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
    );
    // Owner 21/10/2026: R-3 — disabled Submit = grey fill, black text, 50% opacity.
    final Widget submit = Opacity(
      opacity: canSubmit ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !canSubmit,
        child: customButton(
          title: l.submit,
          function: canSubmit ? widget.onSubmit : () {},
          color: canSubmit ? AppColors.primary : AppColors.grey,
          width: isPhone ? double.infinity : 150.w,
          height: 38.h,
          radius: 8.r,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: l.settings,
        secondTitle: widget.title,
        onFirstTap: () => Navigator.of(context).maybePop(),
        onSecondTap: () => Navigator.of(context).maybePop(),
        child: SideFrameBoundedBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        box(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (!isPhone) ...<Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      l.current_details,
                                      style: StyleText.fontSize16Weight600
                                          .copyWith(color: AppColors.text),
                                    ),
                                  ),
                                  SizedBox(width: 16.sp),
                                  Expanded(
                                    child: Text(
                                      l.new_details,
                                      style: StyleText.fontSize16Weight600
                                          .copyWith(
                                              color: AppColors.statusApproved),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.sp),
                            ],
                            for (int i = 0;
                                i < widget.changes.length;
                                i++) ...<Widget>[
                              if (i > 0) SizedBox(height: 16.sp),
                              CurrentNewValuePair(
                                label: widget.changes[i].label,
                                current: widget.changes[i].current,
                                next: widget.changes[i].next,
                                stacked: isPhone,
                              ),
                            ],
                          ],
                        )),
                        SizedBox(height: 12.sp),
                        box(CustomTextField(
                          label: l.requestNote,
                          hint: l.textHere,
                          controller: widget.noteController,
                          required: true,
                          maxLength: 500,
                          maxLines: 3,
                          fillColor: AppColors.background,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.sp),
              Row(
                children: isPhone
                    ? <Widget>[
                        Expanded(child: discard),
                        SizedBox(width: 16.sp),
                        Expanded(child: submit),
                      ]
                    : <Widget>[discard, const Spacer(), submit],
              ),
              SizedBox(height: 16.sp),
            ],
          ),
        ),
      ),
    );
  }
}
