/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_information_fields.dart
/// Purpose: The company-information form fields, bound to CompanyCubit state.
/// Author: Amr Mesbah
/// Created at: 11/12/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N25: added the standard header.
///          21/10/2026 - D-15/D-205 grid (3/2/1 per row), phone with code.
library;

import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/stored_value_ar.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_state.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/phone_country_lookup.dart';

class CompanyInformationFields extends StatefulWidget {
  const CompanyInformationFields({super.key});

  @override
  State<CompanyInformationFields> createState() =>
      _CompanyInformationFieldsState();
}

class _CompanyInformationFieldsState extends State<CompanyInformationFields> {
  bool submitted = false;

  // Controllers for all fields
  late TextEditingController companyNameController;
  late TextEditingController taxNumberController;
  late TextEditingController countryController;
  late TextEditingController provinceController;
  late TextEditingController cityController;
  late TextEditingController streetController;
  late TextEditingController industryController;
  late TextEditingController companySizeController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;

  // Text direction states for each field
  TextDirection companyNameDirection = TextDirection.ltr;
  TextDirection countryDirection = TextDirection.ltr;
  TextDirection provinceDirection = TextDirection.ltr;
  TextDirection cityDirection = TextDirection.ltr;
  TextDirection streetDirection = TextDirection.ltr;
  TextDirection industryDirection = TextDirection.ltr;
  TextDirection firstNameDirection = TextDirection.ltr;
  TextDirection lastNameDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    // Seed from whatever the cubit already has. The company may still be
    // loading on first build, so _syncFromState() below refreshes these when
    // it arrives (every field here is read-only, so there is no user input to
    // clobber).
    final state = context.read<CompanyCubit>().state;
    // Initialize controllers with existing data
    companyNameController = TextEditingController(
        text: FormatHelper.capitalize(
            state.company?.companyName?.companyName?.lastOrNull ?? ''));
    taxNumberController = TextEditingController(
        text: FormatHelper.capitalize(
            state.company?.taxNumber?.taxNumber?.lastOrNull ?? ''));
    countryController = TextEditingController(
        text: StoredValueAr.of(
            context,
            FormatHelper.capitalize(
                state.company?.country?.country?.lastOrNull ?? '')));
    provinceController = TextEditingController(
        text: StoredValueAr.of(
            context,
            FormatHelper.capitalize(
                state.company?.province?.province?.lastOrNull ?? '')));
    cityController = TextEditingController(
        text: StoredValueAr.of(
            context,
            FormatHelper.capitalize(
                state.company?.city?.city?.lastOrNull ?? '')));
    streetController = TextEditingController(
        text: FormatHelper.capitalize(
            state.company?.companyAddress?.address?.lastOrNull ?? ''));
    industryController = TextEditingController(
        text: StoredValueAr.of(
            context,
            FormatHelper.capitalize(
                state.company?.companyIndustry?.companyIndustry?.lastOrNull ??
                    '')));
    companySizeController = TextEditingController(
        text: StoredValueAr.of(
            context,
            FormatHelper.capitalize(
                state.company?.companySize?.companySize?.lastOrNull ?? '')));
    firstNameController = TextEditingController(
        text: FormatHelper.capitalize(
            state.company?.firstName?.firstNames?.lastOrNull ?? ''));
    lastNameController = TextEditingController(
        text: FormatHelper.capitalize(
            state.company?.lastName?.lastNames?.lastOrNull ?? ''));
    emailController = TextEditingController(
        text: (state.company?.email?.emails?.lastOrNull ?? '')
            .trim()
            .toLowerCase());
    phoneNumberController =
        TextEditingController(text: _phoneText(state.company?.phone));

    // Set initial text directions based on content
    companyNameDirection = _detectTextDirection(companyNameController.text);
    countryDirection = _detectTextDirection(countryController.text);
    provinceDirection = _detectTextDirection(provinceController.text);
    cityDirection = _detectTextDirection(cityController.text);
    streetDirection = _detectTextDirection(streetController.text);
    industryDirection = _detectTextDirection(industryController.text);
    firstNameDirection = _detectTextDirection(firstNameController.text);
    lastNameDirection = _detectTextDirection(lastNameController.text);
  }

  @override
  void dispose() {
    companyNameController.dispose();
    taxNumberController.dispose();
    countryController.dispose();
    provinceController.dispose();
    cityController.dispose();
    streetController.dispose();
    industryController.dispose();
    companySizeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  /// D-219 (21/10/2026, item 58): the view shows the phone WITH its country
  /// code — flag + code + number in one field, like Personal Information.
  static String _phoneText(MobilePhone? phone) {
    final String number = (phone?.phones?.lastOrNull ?? '').trim();
    final String? iso = phone?.countryCode?.lastOrNull;
    if (number.isEmpty || iso == null || iso.isEmpty) return number;
    return '${PhoneCountryLookup.flagAndCode(iso)} $number';
  }

  /// Detects if text contains Arabic characters
  bool _containsArabic(String text) {
    if (text.isEmpty) return false;
    // Arabic Unicode range: U+0600 to U+06FF
    return text.runes.any((rune) => rune >= 0x0600 && rune <= 0x06FF);
  }

  /// Detects text direction based on content
  /// Returns RTL if contains Arabic, LTR otherwise
  TextDirection _detectTextDirection(String text) {
    if (text.isEmpty) return TextDirection.ltr;
    return _containsArabic(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Re-seeds the read-only controllers when the company finishes loading.
  void _syncFromState(CompanyState state) {
    companyNameController.text = FormatHelper.capitalize(
        state.company?.companyName?.companyName?.lastOrNull ?? '');
    taxNumberController.text = FormatHelper.capitalize(
        state.company?.taxNumber?.taxNumber?.lastOrNull ?? '');
    countryController.text = StoredValueAr.of(
        context,
        FormatHelper.capitalize(
            state.company?.country?.country?.lastOrNull ?? ''));
    provinceController.text = StoredValueAr.of(
        context,
        FormatHelper.capitalize(
            state.company?.province?.province?.lastOrNull ?? ''));
    cityController.text = StoredValueAr.of(context,
        FormatHelper.capitalize(state.company?.city?.city?.lastOrNull ?? ''));
    streetController.text = FormatHelper.capitalize(
        state.company?.companyAddress?.address?.lastOrNull ?? '');
    industryController.text = StoredValueAr.of(
        context,
        FormatHelper.capitalize(
            state.company?.companyIndustry?.companyIndustry?.lastOrNull ?? ''));
    companySizeController.text = StoredValueAr.of(
        context,
        FormatHelper.capitalize(
            state.company?.companySize?.companySize?.lastOrNull ?? ''));
    firstNameController.text = FormatHelper.capitalize(
        state.company?.firstName?.firstNames?.lastOrNull ?? '');
    lastNameController.text = FormatHelper.capitalize(
        state.company?.lastName?.lastNames?.lastOrNull ?? '');
    // Emails always read lowercase (18/10/2026).
    emailController.text =
        (state.company?.email?.emails?.lastOrNull ?? '').trim().toLowerCase();
    phoneNumberController.text = _phoneText(state.company?.phone);

    companyNameDirection = _detectTextDirection(companyNameController.text);
    countryDirection = _detectTextDirection(countryController.text);
    provinceDirection = _detectTextDirection(provinceController.text);
    cityDirection = _detectTextDirection(cityController.text);
    streetDirection = _detectTextDirection(streetController.text);
    industryDirection = _detectTextDirection(industryController.text);
    firstNameDirection = _detectTextDirection(firstNameController.text);
    lastNameDirection = _detectTextDirection(lastNameController.text);
  }

  /// One read-only field of the view.
  Widget _field(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    TextDirection? textDirection,
    ValueChanged<String>? onChanged,
  }) =>
      CustomTextField(
        label: label,
        hint: S.of(context).textHere,
        controller: controller,
        textDirection: textDirection,
        enabled: false,
        onChanged: onChanged ?? (_) => setState(() {}),
      );

  /// Lays [fields] out [perRow] per row (D-15 / D-205, 21/10/2026): 3 on iPad
  /// landscape, 2 on iPad portrait, 1 on the phone. A short last row is padded
  /// with empty cells so the columns keep the same width; nothing is cut.
  ///
  /// [fullWidth] (D-107, 21/10/2026): on iPad portrait emails and phone each
  /// get their own row, so those fields are listed here and span the row.
  Widget _grid(List<Widget> fields, int perRow,
      {Set<Widget> fullWidth = const <Widget>{}}) {
    if (perRow > 1 && fullWidth.isNotEmpty) {
      final List<Widget> out = <Widget>[];
      List<Widget> run = <Widget>[];
      void flush() {
        if (run.isEmpty) return;
        if (out.isNotEmpty) out.add(SizedBox(height: 12.sp));
        out.add(_grid(run, perRow));
        run = <Widget>[];
      }

      for (final Widget f in fields) {
        if (fullWidth.contains(f)) {
          flush();
          if (out.isNotEmpty) out.add(SizedBox(height: 12.sp));
          out.add(f);
        } else {
          run.add(f);
        }
      }
      flush();
      return Column(children: out);
    }
    if (perRow <= 1) {
      return Column(
        children: <Widget>[
          for (int i = 0; i < fields.length; i++) ...<Widget>[
            if (i > 0) SizedBox(height: 12.sp),
            fields[i],
          ],
        ],
      );
    }
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < fields.length; i += perRow) {
      final List<Widget> cells = <Widget>[];
      for (int j = 0; j < perRow; j++) {
        if (j > 0) cells.add(SizedBox(width: 16.sp)); // R-1
        cells.add(Expanded(
          child: i + j < fields.length ? fields[i + j] : const SizedBox(),
        ));
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: 12.sp));
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cells,
      ));
    }
    return Column(children: rows);
  }

  /// 21/10/2026 (Moataz, R-11): the SAME header widget as Personal / Health
  /// (it draws the icon in its own grey + yellow). This page used its own
  /// row, whose icon widget recoloured the Company icon flat grey.
  Widget _sectionHeader(BuildContext context, String icon, String title) =>
      SettingsHeader(horizontalPadding: 0, imagePath: icon, text: title);

  /// One block of fields under its own heading.
  ///
  /// ADDED 8/9/2026. On a phone each block is its own rounded card, like the
  /// personal page; on tablet the sections stay flush inside the one container.
  Widget _sectionCard(bool isMobile, List<Widget> children) {
    // D-223 / 21/10/2026 (Moataz): the VIEW page is ONE box with the groups
    // inside it, like Personal / Health / Social (the edit page has a card
    // per group).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = kpIsPhoneLayout(context);
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    // D-15 / D-205 (21/10/2026): 3 per row on iPad landscape, 2 on iPad
    // portrait, 1 on the phone — labels never wrap, values never truncate.
    // Item 178 (21/10/2026): ONE per row on iPad portrait, like Personal
    // Information (the menu leaves the panel too narrow for two).
    final int perRow = (isMobile || isPortrait) ? 1 : 3;
    final S l = S.of(context);

    return BlocListener<CompanyCubit, CompanyState>(
      listenWhen: (prev, curr) => prev.company != curr.company,
      listener: (context, state) => setState(() => _syncFromState(state)),
      // The page area scrolls; the cards never scroll inside themselves.
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          // The page scrolls; the one box grows with its content and never
          // scrolls inside itself (21/10/2026).
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _sectionCard(isMobile, <Widget>[
                  _sectionHeader(
                    context,
                    'assets/icons_assets/main_icons_assets/ic_org_company_building.svg',
                    l.company,
                  ),
                  SizedBox(height: 12.sp),
                  _grid(<Widget>[
                    _field(context,
                        label: l.companyName,
                        controller: companyNameController,
                        textDirection: companyNameDirection,
                        onChanged: (String v) => setState(() =>
                            companyNameDirection = _detectTextDirection(v))),
                    _field(context,
                        label: l.taxNumber, controller: taxNumberController),
                    _field(context,
                        label: l.country,
                        controller: countryController,
                        textDirection: countryDirection,
                        onChanged: (String v) => setState(
                            () => countryDirection = _detectTextDirection(v))),
                    _field(context,
                        label: l.stateOrProvince,
                        controller: provinceController,
                        textDirection: provinceDirection,
                        onChanged: (String v) => setState(
                            () => provinceDirection = _detectTextDirection(v))),
                    _field(context,
                        label: l.city,
                        controller: cityController,
                        textDirection: cityDirection,
                        onChanged: (String v) => setState(
                            () => cityDirection = _detectTextDirection(v))),
                    // 20/10/2026 (Moataz): Street in the third column, so
                    // Province, City and Street are one row on landscape.
                    _field(context,
                        label: l.street,
                        controller: streetController,
                        textDirection: streetDirection,
                        onChanged: (String v) => setState(
                            () => streetDirection = _detectTextDirection(v))),
                  ], perRow),
                ]),
                // D-243: 24 before a new group title inside the one box.
                SizedBox(height: 24.sp),
                _sectionCard(isMobile, <Widget>[
                  _sectionHeader(
                    context,
                    'assets/icons_assets/main_icons_assets/ic_module_services.svg',
                    l.service,
                  ),
                  SizedBox(height: 12.sp),
                  _grid(<Widget>[
                    _field(context,
                        label: l.industry,
                        controller: industryController,
                        textDirection: industryDirection,
                        onChanged: (String v) => setState(
                            () => industryDirection = _detectTextDirection(v))),
                    _field(context,
                        label: l.companySize,
                        controller: companySizeController),
                    // R-1: two fields share the row in halves.
                  ], perRow == 3 ? 2 : perRow),
                ]),
                // D-243: 24 before a new group title inside the one box.
                SizedBox(height: 24.sp),
                _sectionCard(isMobile, <Widget>[
                  _sectionHeader(
                    context,
                    'assets/icons_assets/settings_assets/ic_comms_phone_call.svg',
                    l.contact,
                  ),
                  SizedBox(height: 12.sp),
                  Builder(builder: (BuildContext context) {
                    final Widget email = _field(context,
                        label: l.email, controller: emailController);
                    final Widget phone = _field(context,
                        label: l.phoneNumber,
                        controller: phoneNumberController);
                    final Widget names = _grid(<Widget>[
                      _field(context,
                          label: l.firstName,
                          controller: firstNameController,
                          textDirection: firstNameDirection,
                          onChanged: (String v) => setState(() =>
                              firstNameDirection = _detectTextDirection(v))),
                      _field(context,
                          label: l.lastName,
                          controller: lastNameController,
                          textDirection: lastNameDirection,
                          onChanged: (String v) => setState(() =>
                              lastNameDirection = _detectTextDirection(v))),
                      email,
                    ], perRow);
                    // R-2: the phone alone in its row takes half the width.
                    return Column(children: <Widget>[
                      names,
                      SizedBox(height: 12.sp),
                      perRow > 1
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(child: phone),
                                SizedBox(width: 16.sp),
                                const Expanded(child: SizedBox.shrink()),
                              ],
                            )
                          : phone,
                    ]);
                  }),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
