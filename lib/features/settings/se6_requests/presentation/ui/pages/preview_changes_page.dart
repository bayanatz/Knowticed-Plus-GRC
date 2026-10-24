/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: preview_changes_page.dart
/// Description: Reviews personal-information edits before they are submitted.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE6-N01/N02/N06: the Firestore submit and its try/catch moved into
///          RequestsCubit/RequestsRepository; the country lookups now use the
///          shared PhoneCountryLookup; raw colours route through AppColors.
///
/// REMAINING (N05): still ~1,100 LOC.
library;

///*************************** FILE INFO ****************************///
/// Description: Preview page for comparing old and new personal information
/// Modified: Mobile responsive layout - vertical stacking on mobile
import 'package:knowticed_plus/core/custom/inputs/current_new_value_pair.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:knowticed_plus/core/app_services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/helper/arabic_number_format.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/text_field.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/employee_date_formatter.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/phone_country_lookup.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/entities/personal_profile.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/widgets/request_error_dialog.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/pages/settings_screen.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';

part '../widgets/preview_changes_page/preview_changes_page_builders.dart';
part '../widgets/preview_changes_page/preview_changes_page_logic.dart';

class PreviewChangesPage extends StatefulWidget {
  final Map<String, dynamic> changes;
  final File? selectedImage;
  // NAMES 24/8/2026: six controllers, not three. The form now edits the
  // English and the Arabic spelling of each name at the same time instead of
  // editing whichever one matched the current UI language, so the preview has
  // to be handed both and show both.
  final TextEditingController firstNameController;
  final TextEditingController firstNameArController;
  final TextEditingController middleNameController;
  final TextEditingController middleNameArController;
  final TextEditingController lastNameController;
  final TextEditingController lastNameArController;
  // REMOVED 24/8/2026: email is no longer part of the edit form, so there is
  // no email controller to hand over and nothing to preview.
  final TextEditingController phoneController;
  final TextEditingController countryController;
  final TextEditingController provinceController;
  final TextEditingController cityController;
  final TextEditingController streetController;
  final TextEditingController dateOfBirthController;
  final String? selectedGender;
  final String? selectedMaritalStatus;
  final String? selectedCountryCode;

  const PreviewChangesPage({
    super.key,
    required this.changes,
    this.selectedImage,
    required this.firstNameController,
    required this.firstNameArController,
    required this.middleNameController,
    required this.middleNameArController,
    required this.lastNameController,
    required this.lastNameArController,
    required this.phoneController,
    required this.countryController,
    required this.provinceController,
    required this.cityController,
    required this.streetController,
    required this.dateOfBirthController,
    this.selectedGender,
    this.selectedMaritalStatus,
    this.selectedCountryCode,
  });

  @override
  State<PreviewChangesPage> createState() => _PreviewChangesPageState();
}

class _PreviewChangesPageState extends State<PreviewChangesPage> {
  /// Set by `_performSubmit` so `_submitChanges` can show the error dialog
  /// after the shared flow returns (20/10/2026).
  bool _submitFailed = false;

  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  late TextEditingController requestNoteController;

  /// Owned by this page: the request flow is entered from here and torn down
  /// with it, so there is nothing to provide higher up the tree.
  final RequestsCubit _requestsCubit = RequestsCubit();

  @override
  void initState() {
    super.initState();
    requestNoteController = TextEditingController();
  }

  /// The request note is MANDATORY (24/8/2026).
  ///
  /// An approver reading the request needs to know why the change is being
  /// asked for, and the note was the only place that says so — it was optional,
  /// so most requests arrived with nothing. Submit is now inert until it holds
  /// something other than whitespace.
  bool get _hasRequestNote => requestNoteController.text.trim().isNotEmpty;

  /// Submit, greyed out and untappable until the note is filled.
  ///
  /// Opacity + IgnorePointer, matching the Preview button on the health edit
  /// page, so a disabled action looks and behaves the same across settings.
  Widget _buildSubmitButton(BuildContext context,
      {required double width, bool fullWidth = false}) {
    final enabled = _hasRequestNote;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: customButton(
          title: S.of(context).submit,
          function: () => _submitChanges(context),
          height: 38.h,
          // FIXED 8/9/2026 — was a hardcoded `135.sp`, which ignored the
          // `width` this method is handed. Both call sites were passing a
          // width and neither of them had any effect.
          width: width,
          fullWidth: fullWidth,
          color: enabled ? AppColors.primary : AppColors.grey,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    requestNoteController.dispose();
    _requestsCubit.close();
    super.dispose();
  }

  // ── Phone ────────────────────────────────────────────────────────────────
  // SPLIT 23/8/2026. These used to be one `_getCurrentPhoneDisplay()` /
  // `_getNewPhoneDisplay()` pair returning "🇪🇬 +20 1012345678" as a single
  // string for a single box. The country code is now its own narrow box beside
  // the number — the same shape the edit screen collects it in — so each half
  // is read separately and each can carry its own change highlight.

  /// The flag + dial code the employee's profile currently holds.
  String _getCurrentPhoneCode() {
    // Owner 21/10/2026: newest phone entry (history is newest last), not the oldest.
    final mobilePhone = employee?.mobilePhone.lastOrNull;

    final String countryCode = mobilePhone?.countryCode?.lastOrNull ??
        PersonalProfile.defaultCountryCode;

    return _formatDialCode(countryCode);
  }

  /// The number the employee's profile currently holds, without its code.
  String _getCurrentPhoneNumber() {
    // Owner 21/10/2026: newest phone entry (history is newest last), not the oldest.
    final mobilePhone = employee?.mobilePhone.lastOrNull;

    return mobilePhone?.phones?.lastOrNull ?? '';
  }

  /// The flag + dial code this request would write.
  String _getNewPhoneCode() => _formatDialCode(
        widget.selectedCountryCode ?? PersonalProfile.defaultCountryCode,
      );

  /// The number this request would write.
  String _getNewPhoneNumber() => widget.phoneController.text;

  /// "🇪🇬 +20" for a country code, or an empty string when the code resolves
  /// to nothing — so the box falls back to the '-' placeholder rather than
  /// showing a lone flag.
  String _formatDialCode(String countryCode) {
    if (PhoneCountryLookup.dialCodeOf(countryCode).isEmpty) return '';
    return PhoneCountryLookup.flagAndCode(countryCode).trim();
  }

  // Country flag / dial code lookups moved to
  // se1_profile/data/utils/phone_country_lookup.dart: each held a try/catch,
  // which is forbidden in presentation/ui/ (§20/§21, CR-SKEL-SE6-N02). One copy
  // is shared rather than a third being written here.

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: () {
          Navigator.pop(context);
        },
        // X-137 (21/10/2026): "Editing Personal Information".
        // 21/10/2026: "Preview …", like Preview Health Insurance.
        secondTitle: S.of(context).previewPersonalInformation,
        // D-202 (20/10/2026): Discard / Submit PINNED at the bottom on every
        // device; the Before → After list scrolls above them. The old
        // "Current Details | New Details" two-column layout is gone — the
        // preview shows only what changed, as pairs (X-127).
        child: SideFrameBoundedBody(
          child: Column(
            children: [
              Expanded(
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: _buildDetailsColumn(
                      context,
                      lightMode,
                      isCurrentColumn: true,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.sp),
              _buildActionButtons(context, isMobile),
              SizedBox(height: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  /// D-202 (20/10/2026): Discard at the left edge, Submit at the right edge,
  /// same width; Submit grey until the note is written (X-02).
  Widget _buildActionButtons(BuildContext context, bool isMobile) {
    final Widget discard = customButton(
      title: S.of(context).discardChange,
      function: () => Navigator.pop(context),
      height: 38.h,
      width: 150.sp,
      fullWidth: isMobile,
      color: AppColors.darkGrey,
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
    );
    final Widget submit =
        _buildSubmitButton(context, width: 150.sp, fullWidth: isMobile);
    return Row(
// 23/10/2026 (Moataz): in Arabic the buttons mirror — yellow left, grey right.
      children: isMobile
          ? [
              Expanded(child: discard),
              SizedBox(width: 16.sp),
              Expanded(child: submit),
            ]
          : [discard, const Spacer(), submit],
    );
  }

  /// The code + number pair on its own, without a label.
  ///
  /// EXTRACTED 8/9/2026 so the mobile paired layout can stack two of these
  /// under a single "Phone Number" label — the same way the plain fields stack
  /// two value boxes.
  Widget _phoneValueRow({
    required String code,
    required String number,
    required bool highlightCode,
    required bool highlightNumber,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _dialCodeWidth,
          child: _valueBox(
            value: code,
            showHighlight: highlightCode,
            center: true,
          ),
        ),
        SizedBox(width: 16.sp),
        // Expanded, not a second fixed width: the number is the long half
        // and takes the rest of the column.
        Expanded(
          child: _valueBox(
            value: number,
            showHighlight: highlightNumber,
          ),
        ),
      ],
    );
  }

  /// Width of the country-code box. Kept in step with `_dialCodeWidth` on the
  /// edit screen.
  double get _dialCodeWidth => 100.sp;

  Widget _fieldLabel(String label) => Text(
        label,
        style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      );

  /// One read-only value box. Extracted from [_fieldDisplay] so the phone row
  /// can draw two of them side by side without restating the geometry.
  Widget _valueBox({
    required String value,
    required bool showHighlight,
    bool center = false,
  }) {
    return Container(
      // minHeight, not a fixed height: a BoxDecoration border is drawn
      // *inside* the box, so a fixed 36.h left only 36.h - 20.h padding - 4
      // border for the text and clipped it — but only on the changed
      // (green-bordered) fields, which is why those looked cut off.
      constraints: BoxConstraints(minHeight: 36.h),
      width: double.infinity,
      alignment: center ? Alignment.center : AlignmentDirectional.centerStart,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        // Always draw a 2px border — transparent when not highlighted — so
        // both columns keep identical inner geometry and the two sides of
        // the comparison stay row-for-row aligned.
        border: Border.all(
          color:
              showHighlight ? AppColors.statusApproved : AppColors.transparent,
          width: 2,
        ),
      ),
      child: Text(
        value.isEmpty ? '-' : value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.text,
        ),
      ),
    );
  }

  /// FIXED 24/8/2026 — "Male" stayed English on the Arabic preview.
  ///
  /// This used to be `{'male': 'Male', 'female': 'Female'}` — a hardcoded
  /// English map with no `S.of(context)` anywhere near it, so the Arabic UI got
  /// the English word. The edit page stores the KEY ('male'), never the label,
  /// so translating here is all that was missing.
  ///
  /// It is also lower-cased before matching, because the Current column feeds
  /// this the raw Firestore value, which is not guaranteed to be lower case.
  // NAME LABELS 24/8/2026 — deliberately NOT run through S.of(context).
  //
  // These label the SCRIPT of the value, not the UI. Localizing them would
  // print "الاسم الأول" on both rows in the Arabic UI (and "First Name" on both
  // in English), so the two boxes would be indistinguishable. Keeping each
  // label in its own language says exactly what belongs in the box, whichever
  // language the app is running in — which is what was asked for.
  static const String _labelFirstNameEn = 'First Name';
  static const String _labelMiddleNameEn = 'Middle Name';
  static const String _labelLastNameEn = 'Last Name';
  static const String _labelFirstNameAr = 'الاسم الأول';
  static const String _labelMiddleNameAr = 'الاسم الأوسط';
  static const String _labelLastNameAr = 'اسم العائلة';

  String _getGenderValue(String? key) {
    switch (key?.trim().toLowerCase()) {
      case 'male':
        return S.of(context).male;
      case 'female':
        return S.of(context).female;
      default:
        return key ?? '';
    }
  }

  /// FIXED 24/8/2026 — same story as [_getGenderValue]: a hardcoded English
  /// map is why "Married" stayed English in Arabic.
  String _getMaritalStatusValue(String? key) {
    switch (key?.trim().toLowerCase()) {
      case 'single':
        return S.of(context).single;
      case 'married':
        return S.of(context).married;
      case 'divorced':
        return S.of(context).divorced;
      case 'widowed':
        return S.of(context).widowed;
      default:
        return key ?? '';
    }
  }

  /// Renders a stored date for display, echoing the raw value back when it is
  /// not parseable. `tryParse` removes the try/catch this used to need.
  /// FIXED 24/8/2026 — the two columns disagreed: Current showed "12/11/1977"
  /// and New showed "١٩٧٧/١١/١٢" for the same date.
  ///
  /// The New side is the edit page's controller, filled by
  /// `_formatDateForDisplay` there, which switches format AND converts the
  /// digits in Arabic. This method did neither. It is now the same rule, so the
  /// two sides are comparable.
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    // 21/10/2026 (Moataz): was DateTime.tryParse, which cannot read the stored
    // `yyyy/MM/dd` shape, so the Current birthday showed raw ("1986/04/12").
    final DateTime? date = EmployeeDateFormatter.parse(dateString);
    if (date == null) return dateString;

    // CHANGED 8/9/2026 — `dd MMM yyyy` ("23 Aug 2023") in both locales, to
    // match `_formatDateForDisplay` on the edit page. The two must stay
    // identical or the Current / New columns go back to disagreeing about how
    // the same date looks, which is the bug this method was written to fix.
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String formatted =
        DateFormat('dd MMM yyyy', isArabic ? 'ar' : 'en').format(date);

    return isArabic ? ArabicDigits(formatted).toArabicNumbers() : formatted;
  }
}
