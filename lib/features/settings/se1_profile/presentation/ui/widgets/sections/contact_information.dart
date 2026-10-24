/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: contact_information.dart
/// Purpose: The Contact card of the personal-information page — email and
///          phone, both read-only.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE1-N06/N12/N13/N17/N18: the two try/catch
///          blocks left presentation/ui/ (they now live in PhoneCountryLookup);
///          the widget takes a [PersonalProfile] instead of force-unwrapping
///          the `employee` global; the hand-rolled ArabicDigits conversion was
///          replaced with intl's locale-aware NumberFormat; the duplicated
///          `@override`, the dead `countryApp` local and the commented-out
///          REMOVED imports are gone.
library;

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart'
    show kFieldLabelGap;
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/phone_country_lookup.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/entities/personal_profile.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ContactInformation extends StatefulWidget {
  const ContactInformation({
    super.key,
    required this.isReadOnly,
    required this.profile,
  });

  final bool isReadOnly;

  /// Email and phone come from here rather than from the `employee` global, so
  /// an employee that has not loaded renders empty instead of throwing on
  /// `employee!.email!.last` (CR-SKEL-SE1-N17).
  final PersonalProfile profile;

  @override
  State<ContactInformation> createState() => _ContactInformationState();
}

class _ContactInformationState extends State<ContactInformation> {
  late final TextEditingController _emailController;
  late final TextEditingController _countryCodeController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.profile.email);
    _countryCodeController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Digit shapes are locale-dependent and the locale is only reachable from
    // the tree, so the phone fields are filled here rather than in initState.
    _syncPhoneFields();
  }

  @override
  void didUpdateWidget(covariant ContactInformation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _emailController.text = widget.profile.email;
      _syncPhoneFields();
    }
  }

  /// Renders the dial code and number in the active locale's numerals.
  /// Replaces `ArabicDigits(...).toArabicNumbers()`, a hand-rolled character
  /// substitution that reimplemented intl (CR-SKEL-SE1-N13).
  void _syncPhoneFields() {
    _countryCodeController.text =
        PhoneCountryLookup.flagAndCode(widget.profile.phoneCountryCode);
    // D-211 (20/10/2026): the view shows ONE field — flag + code + number.
    final String number = widget.profile.phoneNumber;
    _phoneController.text = number.isEmpty
        ? ''
        : '${PhoneCountryLookup.flagAndCode(widget.profile.phoneCountryCode)} $number';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Grid constants ────────────────────────────────────────────────────────
  // R-1: the Name / Location rows are three equal columns separated by a
  // 16.w gap. Email + Phone use the same 16.w gap but split the row in halves.
  double get _gridGap => 16.w;

  Widget _emailField(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return CustomTextField(
      label: S.of(context).email,
      hint: S.of(context).enterYourEmail,
      controller: _emailController,
      textDirection: TextDirection.ltr,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      enabled: !widget.isReadOnly,
    );
  }

  /// Label + dial code + number. Renders its own label so it matches the
  /// label CustomTextField draws (same style, same 6.sp gap) — otherwise the
  /// two columns sit at different heights.
  Widget _phoneSection(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final direction = isArabic ? TextDirection.rtl : TextDirection.ltr;
    final align = isArabic ? TextAlign.right : TextAlign.left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // RichText, not Text — StyleText styles have `inherit: true`, so a Text
        // merges them over the ambient DefaultTextStyle (picking up its
        // height/leading) while RichText does not. CustomTextField draws its
        // label with RichText; using Text here makes this label slightly taller
        // and pushes the phone boxes out of line with the email box.
        RichText(
          text: TextSpan(
            text: S.of(context).phoneNumber,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
        SizedBox(height: kFieldLabelGap.sp),
        // D-211 (20/10/2026): one field — flag, code and number together
        // (was a code box + a number box).
        CustomTextField(
          hint: S.of(context).enterThePhoneNumber,
          controller: _phoneController,
          textDirection: direction,
          textAlign: align,
          enabled: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // NOT `ContextExtension(context).isPhone`.
    //
    // This file imports core/helper/main_helper/extensions.dart, whose
    // extension is ALSO called ContextExtension — and its `isPhone` is
    //
    //     bool get isPhone => !kpIsPhoneLayout(this);
    //
    // i.e. true on WIDE screens, the exact inverse of
    // core/extensions/context_extensions.dart's `shortestSide < 600`. Same
    // name, same target type, opposite meaning, and that file's own comment
    // admits it. Every `isPhone` here was therefore reading FALSE on a phone.
    // Computed inline so it cannot bind to the wrong extension again.
    !kpIsPhoneLayout(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // REBUILT: this was an outer Container (card colour + 8.r + antiAlias)
    // wrapping a one-child Column wrapping ANOTHER Container with the same
    // colour and the same radius — two cards stacked to draw one. The clip
    // existed only to stop the inner one squaring off the outer one's corners.
    // One Container does the whole job.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      // All four sides equal: the space under the phone row now matches the
      // space at the sides, instead of being its own number.
      child: Padding(
        padding: EdgeInsets.only(
            // D-243: 24 before a new group title inside the one box.
            top: 24.sp,
            left: 16.sp,
            right: 16.sp,
            bottom: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsHeader(
                // 0: the Padding above already applies 16.sp on each side, and
                // SettingsHeader adds its own 16.sp on phone — the two stacked,
                // so the icon sat 30.sp in while Email sat at 16.sp.
                horizontalPadding: 0,
                imagePath:
                    'assets/icons_assets/settings_assets/ic_comms_phone_call.svg',
                text: S.of(context).contact),

            // Mobile only: 16.sp after a section title. Others keep 16.h.
            SizedBox(height: 12.sp),

            // ── Email + Phone ────────────────────────────────────────
            // Portrait: stacked, full width.
            // Landscape (21/10/2026, Moataz): email and phone split the row
            // equally, 16.w gap between them (R-1).
            isPortrait
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _emailField(context),
                      // Mobile only: 10.sp between fields.
                      SizedBox(height: 12.sp),
                      _phoneSection(context),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _emailField(context)),
                      SizedBox(width: _gridGap),
                      Expanded(child: _phoneSection(context)),
                    ],
                  ),

            // 20/10/2026 (Moataz "consistency in padding"): no trailing gap —
            // the card's own 15 bottom padding is the gap to Location, the
            // same 15 as Status → Contact.
          ],
        ),
      ),
    );
  }
}
