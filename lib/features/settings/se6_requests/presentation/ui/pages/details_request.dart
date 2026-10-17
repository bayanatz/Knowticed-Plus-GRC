/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: details_request.dart
/// Description: One request: what changed, by whom, and the approve/cancel actions.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 23/8/2026 - Inquiries and comments block added under the request
///          note card, backed by `UniversalCommentSection` and the new
///          `Employees_Request_Comments` collection.
/// Updated: 11/8/2026 - CR-SKEL-SE6-N01/N02/N06/N12/N14: the four Firestore chains and the four
///          try/catch blocks moved into RequestsCubit/RequestsRepository, the
///          field-name table into RequestFieldMapping; raw colours and the two
///          hex literals route through AppColors; `Get.locale` replaced with
///          `Localizations.localeOf(context)`.
library;

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/navigation/custom_side_frame_master.dart';
// REMOVED 8/9/2026: `6-custom_button_with_svg.dart` — its only caller was the
// old Cancel button, now built inline to match the services module's.
import 'package:grc_module/features/settings/se6_requests/presentation/ui/pages/request_section_label.dart';
import 'package:grc_module/core/helper/arabic_number_format.dart';
import 'package:grc_module/core/helper/access/main_core_employee_controller.dart';
import 'package:grc_module/core/custom/inputs/custom_textfield.dart';
import 'package:grc_module/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:intl/intl.dart';

import 'dart:ui' as ui;

import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/settings/se6_requests/data/utils/flexible_date_parser.dart';
import 'package:grc_module/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:grc_module/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:grc_module/features/settings/se6_requests/domain/enums/request_status.dart';
import 'package:grc_module/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import '../../../../../external/knowledge_hub_module/knowledge_hub/presentation/ui/widgets/customed_text_field.dart';

import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/custom/inputs/custom_comment_widget.dart';
import 'package:grc_module/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:grc_module/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:grc_module/core/custom/feedback/circle_progress.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

part '../widgets/details_request/details_request_settings_builders.dart';
part '../widgets/details_request/details_request_settings_logic.dart';

// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/mobile/dashBoard_master_mobile/widget/dialog.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/core/custom_textformfield.dart';

class DetailsRequestSettings extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String? requestId;

  const DetailsRequestSettings({
    super.key,
    required this.requestData,
    this.requestId,
  });

  @override
  State<DetailsRequestSettings> createState() => _DetailsRequestSettingsState();
}

class _DetailsRequestSettingsState extends State<DetailsRequestSettings> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  late TextEditingController requestNoteController;
  bool submitted = false;
  bool isProcessing = false;
  bool isLoading = true;

  String status = 'pending';
  int requestTime = 0;
  String createdByID = '';
  String createdByEmail = '';
  String section = '';

  List<Map<String, String>> changes = [];

  /// The loaded request. Replaces the raw `completeRequestData` map the page
  /// used to hold and re-parse.
  ChangeRequest? _request;

  /// Owned by this page.
  final RequestsCubit _requestsCubit = RequestsCubit();

  @override
  void initState() {
    super.initState();

    // Created here rather than in [_loadRequest]: a request that never loads
    // (no id, or a deleted document) used to leave this `late` field unset,
    // and `dispose` then threw a LateInitializationError on the way out.
    requestNoteController = TextEditingController();

    _loadRequest();
  }

  /// Key carrying the country code that belongs with a phone change. Present
  /// only on the row [_mergeCountryCodeIntoPhone] merged, which is what tells
  /// [_buildFieldCell] to draw the split code + number pair.
  static const String _oldCountryCodeKey = 'oldCountryCode';
  static const String _newCountryCodeKey = 'newCountryCode';

  /// Width of the country-code box in the split phone row. Matches
  /// `_dialCodeWidth` on the edit screen so the request reads at the same
  /// proportions the employee filled it in at.
  double get _dialCodeWidth => 60.sp;

  /// Function Name: [_mergeCountryCodeIntoPhone]
  ///
  /// Purpose: Fold the Country Code change into the Phone Number change so the
  ///          reviewer sees one row instead of two to cross-reference.
  ///
  /// Asked for in the Settings and Org Chart bug report, p.14: the standalone
  /// Country Code row is struck out and the code belongs with the number.
  ///
  /// UPDATED 23/8/2026: the two values used to be joined into one string
  /// ("+20 1012345678") and rendered in a single box. They are kept SEPARATE
  /// now — code under [_oldCountryCodeKey] / [_newCountryCodeKey], number in
  /// the usual `oldValue` / `newValue` — so the row can be drawn as the same
  /// narrow-code + wide-number pair the edit screen uses. Joining them also
  /// meant the Arabic-digit pass in `_displayValue` ran over the dial code,
  /// which is not a number to read but a prefix to dial.
  ///
  /// Only the top-level `country_code` / `phone` pair is touched. An emergency
  /// contact's `firstContact_phone` keeps its own row, and a country-code
  /// change that arrives WITHOUT a phone change keeps its row too — otherwise
  /// that edit would silently vanish from the request.
  ///
  /// Parameters:
  /// - [raw]: The changes exactly as they came off the request.
  ///
  /// Returns: [List<Map<String, String>>] the rows to render.
  static List<Map<String, String>> _mergeCountryCodeIntoPhone(
    List<Map<String, String>> raw,
  ) {
    int indexOf(Set<String> names) => raw.indexWhere(
          (Map<String, String> c) =>
              names.contains((c['fieldName'] ?? '').toLowerCase()),
        );

    final int codeIndex = indexOf(<String>{'country_code', 'countrycode'});
    final int phoneIndex = indexOf(<String>{'phone'});
    if (codeIndex == -1 || phoneIndex == -1) return raw;

    final Map<String, String> code = raw[codeIndex];
    final Map<String, String> phone = raw[phoneIndex];

    final List<Map<String, String>> merged = List<Map<String, String>>.from(
      raw,
    );
    merged[phoneIndex] = <String, String>{
      'fieldName': phone['fieldName'] ?? 'phone',
      'oldValue': (phone['oldValue'] ?? '').trim(),
      'newValue': (phone['newValue'] ?? '').trim(),
      _oldCountryCodeKey: (code['oldValue'] ?? '').trim(),
      _newCountryCodeKey: (code['newValue'] ?? '').trim(),
    };
    merged.removeAt(codeIndex);
    return merged;
  }

  @override
  void dispose() {
    requestNoteController.dispose();
    _requestsCubit.close();
    super.dispose();
  }

  String _translateSectionTitle(String englishTitle) {
    // FIXED 13/8/2026: hardcoded Arabic replaced by the existing l10n keys,
    // shared with request_page.dart so the two cannot drift again.
    return RequestSectionLabel.of(context, englishTitle);
  }

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  /// Function Name: [_localizeDigits]
  ///
  /// Purpose: Render Western digits as Arabic-Indic ones while the app is in
  ///          Arabic, so a request never mixes ٠١٢ labels with 012 values.
  ///
  /// Reads the locale from the tree rather than `Get.locale` — the same reason
  /// this page already avoids the global in [_buildRequestNoteSection]. That
  /// rules out `localizeNumber()` from core/custom/76, which uses `Get.locale`.
  ///
  /// Parameters:
  /// - [value]: Any display string.
  ///
  /// Returns: [String] the value with its digits localized.
  String _localizeDigits(String value) =>
      _isArabic ? value.toArabicNumbers() : value;

  String _formatDate(int timestamp) {
    if (timestamp == 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return _localizeDigits(
      DateFormat('dd MMM yyyy', _isArabic ? 'ar' : 'en').format(date),
    );
  }

  /// True for a field whose value is a date, whatever spelling the key uses.
  bool _isDateField(String bareKey) =>
      bareKey.contains('date') || bareKey.contains('birth');

  /// Function Name: [_displayValue]
  ///
  /// Purpose: Turn a stored value into what the reviewer should read.
  ///
  /// Two problems this fixes, both from the bug report p.14: a date of birth
  /// arrived as a raw ISO timestamp on the "New Details" side
  /// (`2000-11-08T00:00:00.000`) while the current side showed `12/11/1977`,
  /// and every number stayed in Western digits under an Arabic UI.
  ///
  /// Email is deliberately exempt: an address is not prose, and Arabic-Indic
  /// digits inside one would make it wrong to read back or copy.
  ///
  /// Parameters:
  /// - [fieldName]: The change's field key.
  /// - [value]: The stored value.
  ///
  /// Returns: [String] the display string, or '-' when there is nothing.
  String _displayValue(String fieldName, String value) {
    if (value.trim().isEmpty) return '-';

    final String bareKey = _toSnakeCase(_stripContactPrefix(fieldName));
    if (bareKey == 'email') return value;

    if (_isDateField(bareKey)) {
      final DateTime? parsed = FlexibleDateParser.parse(value);
      // Numeric dd/MM/yyyy, matching how the current-details side already
      // reads, and needing no month-name locale data.
      if (parsed != null) {
        return _localizeDigits(DateFormat('dd/MM/yyyy').format(parsed));
      }
    }

    return _localizeDigits(value);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      // Kept in step with request_page.dart's _getStatusColor — the badge here
      // and the filter chip there describe the same status and must match.
      case 'approved':
        return AppColors.lightGreen;
      case 'pending':
        return AppColors.statusPending;
      case 'rejected':
        return AppColors.red;
      case 'cancelled':
      case 'canceled':
        return AppColors.darkRed;
      default:
        return AppColors.secondaryText;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'assets/icons_assets/main_icons_assets/ic_status_approved_circle.svg';
      case 'pending':
        return 'assets/icons_assets/main_icons_assets/ic_status_pending.svg';
      case 'rejected':
        return 'assets/icons_assets/main_icons_assets/ic_status_rejected.svg';
      case 'cancelled':
      case 'canceled':
        return 'assets/icons_assets/main_icons_assets/ic_status_cancelled.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/ic_status_rejected.svg';
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return S.of(context).Approved;
      case 'pending':
        return S.of(context).Pending;
      case 'rejected':
        return S.of(context).Rejected;
      case 'cancelled':
      case 'canceled':
        return S.of(context).Canceled;
      default:
        return status;
    }
  }

  /// ✅ Get human-readable field labels with translations
  String _getFieldLabel(String fieldKey) {
    final labelMap = {
      // Basic fields
      'first_name': S.of(context).firstName,
      'middle_name': S.of(context).middleName,
      'last_name': S.of(context).lastName,
      'street': S.of(context).streetName,
      'city': S.of(context).city,
      'province': S.of(context).stateOrProvince,
      'country': S.of(context).country,
      'email': S.of(context).email,
      'phone': S.of(context).phoneNumber,
      'gender': S.of(context).gender,
      'date_of_birth': S.of(context).birthday,
      'marital_status': S.of(context).maritalStatus,

      // ✅ Emergency Contact — the firstContact/secondContact prefix is
      // stripped below, so these are keyed on the bare field name.
      'name': 'Name',
      'relationship': S.of(context).relationship,
      'language': S.of(context).language,

      // ✅ Health Insurance
      'insurance_name': 'Insurance Name',
      'insurance_policy_number': 'Insurance Policy Number',
    };

    // The contact these fields belong to is already clear from the section
    // header, so the prefix is dropped for EVERY field rather than spelled out
    // in the label ("Secondcontact Street" → "Street").
    final String bareKey = _toSnakeCase(_stripContactPrefix(fieldKey));

    return labelMap[bareKey] ?? _formatFieldName(bareKey);
  }

  /// Removes a leading firstContact / secondContact marker in any of the
  /// spellings the data uses: `secondContact_street`, `secondContactStreet`,
  /// `second_contact_street`.
  String _stripContactPrefix(String fieldKey) {
    final match = RegExp(
      r'^(first|second)_?contact_?',
      caseSensitive: false,
    ).firstMatch(fieldKey);

    if (match == null) return fieldKey;

    final stripped = fieldKey.substring(match.end);
    // Guard against a key that is nothing but the prefix.
    return stripped.isEmpty ? fieldKey : stripped;
  }

  /// `InsurancePolicyNumber` / `insurancePolicyNumber` → `insurance_policy_number`
  /// so camelCase and snake_case keys hit the same map entry.
  String _toSnakeCase(String value) => value
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase();

  /// ✅ Format field name as fallback (converts "secondContact_email" → "Second Contact Email")
  String _formatFieldName(String fieldKey) {
    return fieldKey
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  /// Function Name: [_buildCommentsSection]
  ///
  /// Purpose: The inquiries-and-comments thread for this request, sitting under
  ///          the request note card.
  ///
  /// Reuses `UniversalCommentSection` (core/custom/36) rather than growing a
  /// second comment implementation: it already carries the Firestore stream,
  /// the attachment upload, the RTL handling and the expand/collapse header.
  ///
  /// The thread is keyed by the request id, so it is hidden entirely when the
  /// page was opened without one — there would be nothing to attach a comment
  /// to, and every request without an id would otherwise share one thread.
  ///
  /// Parameters:
  /// - [isMobile]: Phone layout, which gets a shorter collapsed thread.
  ///
  /// Returns: [Widget] the card, or an empty box when there is no request id.
  Widget _buildCommentsSection(bool isMobile) {
    final String requestId = widget.requestId ?? '';
    if (requestId.isEmpty) return const SizedBox.shrink();

    return UniversalCommentSection(
      collectionPath: RequestCollectionPaths.requestCommentsCollection,
      // Written onto every new comment as well as filtering the stream —
      // `UniversalCommentSection` spreads these fields into the document.
      filterFields: <String, dynamic>{
        RequestCollectionPaths.commentRequestIdField: requestId,
      },
      currentUserId: _currentUserEmail,
      collapsedHeight: isMobile ? 320.h : 400.h,
    );
  }

  /// Who is writing. Comments are attributed by email — the same identifier
  /// [_decide] sends as the notification's sender, and the one
  /// `MainCoreEmployeeController` resolves names and departments from.
  String get _currentUserEmail {
    try {
      return Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? '';
    } catch (_) {
      // The controller is not registered on every entry into this page.
      return '';
    }
  }

  Widget _buildHeader(bool lightMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          S.of(context).requestDetails,
          style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
        ),
        Spacer(),
        Text(
          "${S.of(context).requestedDate}: ",
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          _formatDate(requestTime),
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  /// One side of the comparison: a title plus every changed field's value.
  Widget _buildValueColumn({
    required bool lightMode,
    required String title,
    required Color titleColor,
    required bool isNew,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: StyleText.fontSize16Weight600.copyWith(color: titleColor),
        ),
        SizedBox(height: 15.h),
        for (int i = 0; i < changes.length; i++) ...[
          _buildFieldCell(
            lightMode: lightMode,
            change: changes[i],
            isNew: isNew,
          ),
          if (i != changes.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }

  /// One changed field, on one side of the comparison.
  ///
  /// Takes the whole change rather than a bare value: a phone row carries its
  /// country code alongside the number (see [_mergeCountryCodeIntoPhone]) and
  /// is drawn as two boxes, so the cell has to see both.
  ///
  /// Keyed by its contents so the internal controller refreshes when the
  /// request data reloads — this used to build a TextEditingController on
  /// every paint, which was never disposed.
  Widget _buildFieldCell({
    required bool lightMode,
    required Map<String, String> change,
    required bool isNew,
  }) {
    final String fieldName = change['fieldName'] ?? '';
    final String value =
        (isNew ? change['newValue'] : change['oldValue']) ?? '';

    final String? countryCode =
        change[isNew ? _newCountryCodeKey : _oldCountryCodeKey];
    if (countryCode != null) {
      return _buildPhoneFieldCell(
        fieldName: fieldName,
        countryCode: countryCode,
        number: value,
        isNew: isNew,
      );
    }

    return _buildValueBox(fieldName: fieldName, value: value, isNew: isNew);
  }

  /// One read-only box. The default rendering for every field that is not the
  /// split phone row, and the number half of the row that is.
  Widget _buildValueBox({
    required String fieldName,
    required String value,
    required bool isNew,
    bool showLabel = true,
  }) {
    final String display = _displayValue(fieldName, value);
    final String label = _getFieldLabel(fieldName);

    return CustomTextField(
      key: ValueKey('$fieldName-$isNew-$display-$showLabel'),
      label: showLabel ? label : null,
      hint: label,
      initialValue: display,
      enabled: false,
      fillColor: isNew ? null : AppColors.background,
    );
  }

  Widget _buildSectionHeader(bool lightMode, String sectionTitle) {
    bool isInsuranceSection =
        sectionTitle.contains('Insurance') || sectionTitle.contains('التأمين');

    return Row(
      children: [
        Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            // Container, not a field — 8.r like the cards around it.
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.primary.withValues(alpha: .15),
          ),
          child: Center(
            child: CustomSvgImage(
              assetPath: isInsuranceSection
                  ? "assets/icons_assets/main_icons_assets/ic_hr_insurance_document.svg"
                  : "assets/icons_assets/main_icons_assets/ic_user_emergency_contact.svg",
              width: 16.w,
              height: 16.h,
              fit: BoxFit.fill,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          sectionTitle,
          style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  /// Cancels the request. Only offered while it is still pending — an already
  /// approved or rejected request has been acted on and must not be withdrawn.
  Future<void> _cancelRequest() async {
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json',
      confirmTitle: S.of(context).CancelRequest,
      confirmSubtitle: S.of(context).AreYousureYouWanttoCancelThisRequest,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        await _decide(RequestStatus.cancelled);
        // _decide surfaces its own error snackbar; report success to the dialog
        // only when the status actually changed.
        return status == RequestStatus.cancelled.wireValue;
      },
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: S.of(context).Successful,
      successSubtitle: S.of(context).YouSuccessfullyCanceledThisRequest,
    );
  }

  /// Only a request still awaiting a decision can be withdrawn. Hidden while a
  /// write is in flight so it can't be submitted twice.
  bool get _canCancel =>
      RequestStatus.fromWire(status).isPending && !isProcessing;

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final contentWidget = _buildContent(lightMode, isMobile);

    if (isMobile) {
      return Scaffold(
        body: SideFrameMasterServices(
          titleText: S.of(context).settings,
          onFirstTap: () {},
          secondTitle: S.of(context).requestDetails,
          child: SingleChildScrollView(child: contentWidget),
        ),
      );
    }

    return SideFrameMasterServices(
      titleText: S.of(context).settings,
      onFirstTap: () {
        Navigator.pop(context);
      },
      secondTitle: S.of(context).requestDetails,
      onSecondTap: () {},
      child: SingleChildScrollView(child: contentWidget),
    );
  }
}
