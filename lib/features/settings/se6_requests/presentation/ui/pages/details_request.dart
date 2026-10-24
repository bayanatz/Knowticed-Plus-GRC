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

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
// REMOVED 8/9/2026: `6-custom_button_with_svg.dart` — its only caller was the
// old Cancel button, now built inline to match the services module's.
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/request_section_label.dart';
import 'package:knowticed_plus/core/helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/ui/pages/edit_page_request_health.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/edit_page_request.dart';
import 'package:knowticed_plus/core/custom/inputs/current_new_value_pair.dart';
import 'package:knowticed_plus/features/notification/data/repository/settings_notification_service.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/stored_value_ar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:intl/intl.dart';

import 'dart:ui' as ui;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/flexible_date_parser.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import '../../../../../external/knowledge_hub_module/knowledge_hub/presentation/ui/widgets/customed_text_field.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

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

  /// X-139 (21/10/2026): true while Inquiries And Comments is expanded — the
  /// request above it collapses to one summary row.
  bool _commentsExpanded = false;

  /// Owned by this page.
  final RequestsCubit _requestsCubit = RequestsCubit();

  /// 21/10/2026: ticks once a second so the Reminder countdown moves; only
  /// rebuilds while a countdown is actually running.
  Timer? _reminderTicker;

  /// True while a reminder is being sent, so extra taps do nothing (Moataz
  /// 23/10/2026: many taps opened the success dialog many times).
  bool _sendingReminder = false;

  @override
  void initState() {
    super.initState();
    _reminderTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final DateTime? last = _request?.lastReminderAt;
      if (!mounted || last == null) return;
      final bool waiting = DateTime.now().difference(last) <
          ChangeRequest.reminderInterval + const Duration(seconds: 1);
      if (waiting) setState(() {});
    });

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
    _reminderTicker?.cancel();
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
      // 21/10/2026 (Moataz): the app's one date format, "18 Apr 2021", in
      // the app language (was numeric dd/MM/yyyy).
      if (parsed != null) {
        return _localizeDigits(
            DateFormat('dd MMM yyyy', _isArabic ? 'ar' : 'en').format(parsed));
      }
    }

    // 21/10/2026 (Moataz): stored values may be lowercase ("cairo"); shown
    // capitalised like everywhere else on the page.
    // Moataz 23/10/2026: a country / city / relationship saved in the other
    // language is shown in the screen language (not names).
    final String shown = FormatHelper.capitalize(value);
    return _localizeDigits(
        bareKey.contains('name') ? shown : StoredValueAr.of(context, shown));
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
        return AppColors
            .secondaryText; // 21/10/2026: grey, so it reads apart from Rejected
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
        return 'assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg';
      case 'cancelled':
      case 'canceled':
        return 'assets/icons_assets/main_icons_assets/ic_action_close_circle_bold.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg';
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
      // X-139: Expand shrinks the request above to one summary row.
      onExpandChanged: (bool expanded) =>
          setState(() => _commentsExpanded = expanded),
      collectionPath: RequestCollectionPaths.requestCommentsCollection,
      // Written onto every new comment as well as filtering the stream —
      // `UniversalCommentSection` spreads these fields into the document.
      filterFields: <String, dynamic>{
        RequestCollectionPaths.commentRequestIdField: requestId,
      },
      currentUserId: _currentUserEmail,
      collapsedHeight: isMobile ? 320.h : 400.h,
      // 21/10/2026 (Moataz): expanded keeps the one-row request summary on
      // top and the input above the phone tab bar.
      fitBelowPageTopWhenExpanded: true,
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

  /// D-222 (21/10/2026): the title row carries Cancel at its end on every
  /// device; the requested date moved into the section (see
  /// `_buildRequestedDate`).
  Widget _buildHeader(bool lightMode, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Spacer(),
        if (_canCancel) _buildCancelButton(isMobile),
      ],
    );
  }

  /// "Requested Date: 20 Oct 2026" — inside the section, top-right (D-222).
  Widget _buildRequestedDate() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
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

  Widget _buildSectionHeader(bool lightMode, String sectionTitle,
      {Widget? subtitle}) {
    return Row(
      children: [
        Container(
          // 21/10/2026 (Moataz): the same dark tile + white icon as the
          // request cards in the list (was a yellow tint with a yellow icon).
          // Box 40 around the 20 icon (was 32 — too tight), the same
          // icon-to-box ratio as the list cards (24 in 50).
          width: 40.sp,
          height: 40.sp,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            // 23/10/2026 (Moataz): dark tile + white icon in DARK mode only;
            // light mode is a light tile with the grey icon.
            color: AppTheme.isDark ? AppColors.header : AppColors.background,
          ),
          child: Center(
            child: CustomSvgImage(
              // 21/10/2026: one mapping for list + details.
              assetPath: RequestSectionLabel.iconOf(section),
              width: 20.sp,
              height: 20.sp,
              fit: BoxFit.contain,
              color:
                  AppTheme.isDark ? AppColors.colorWhite : AppColors.infoIcon,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        // With a [subtitle] (the requested date) the title sits at the TOP
        // beside the icon and the date directly under it (Moataz 23/10/2026).
        if (subtitle == null)
          Text(
            sectionTitle,
            style:
                StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
          )
        else
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionTitle,
                  style: StyleText.fontSize18Weight500
                      .copyWith(color: AppColors.text, height: 1.1),
                ),
                SizedBox(height: 4.sp),
                subtitle,
              ],
            ),
          ),
      ],
    );
  }

  /// Cancels the request. Only offered while it is still pending — an already
  /// approved or rejected request has been acted on and must not be withdrawn.
  /// X-135 (21/10/2026): Cancel asks a REQUIRED reason (500) in the confirm
  /// dialog; no reason, no cancel. The reason is saved on the request
  /// (`decision_reason`) and shown under the note.
  Future<void> _cancelRequest() async {
    // 21/10/2026 (Moataz): the Services module's cancel flow
    // (`my_request_cancel_button.dart`) — confirm with the red animation,
    // then a REQUIRED reason with Discard / Submit, then success. Was one
    // input dialog with No / Yes.
    final TextEditingController reason = TextEditingController();
    await CustomDialogManager.showDialogFlow(
      confirmWidth: 411,
      context: context,
      customReasonTitle: S.of(context).reasonsOfCancellation,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_rejected.json',
      confirmTitle: S.of(context).cancelRequest,
      confirmSubtitle: S.of(context).AreYousureYouWanttoCancelThisRequest,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async => true,
      comment: true,
      commentRequired: true,
      commentController: reason,
      commentSubmitText: S.of(context).submit,
      commentDiscardText: S.of(context).discard,
      onCommentSubmit: () async {
        final String text = reason.text.trim();
        if (text.isEmpty) return false;
        await _decide(RequestStatus.cancelled, reason: text);
        return status == RequestStatus.cancelled.wireValue;
      },
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
      successTitle: S.of(context).CancelRequest,
      successSubtitle: S.of(context).YouSuccessfullyCanceledThisRequest,
    );
    reason.dispose();
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
