/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_data_service.dart
/// Description: Fetches calendar events from every module that publishes them.
/// Author: Amr Mesbah
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N02-DATA/N04-DATA/N05-DATA: `package:flutter/material.dart` no
///          longer reaches the data layer; the 26 inline colour literals are
///          named tokens on AppColors; `Get.locale` and
///          `Get.find<MainCoreEmployeeController>()` are injected callbacks; the
///          dead `_capitalizeFirstLetter` is deleted.
/// Updated: 9/10/2026 - Time Tracker phase 6: `getTimeTrackerCalendarEvents`
///          + `timeTrackerCalendarEntries` (delegate to
///          `time_tracker_calendar_source.dart`); seeded Time Tracker cards
///          carry no request id.
///
/// REMAINING (CR-SKEL-CAL-N01-DATA): still ~2,900 LOC, over the 1,500 gate. The
/// seven public `get*CalendarEvents` methods are the natural split points, but
/// several private helpers (`_getArrayValue`, `_isMyTurnToApprove`) are shared
/// across them, so the split needs a shared base rather than a straight cut.
library;

import 'package:grc_module/features/calendar/domain/enums/calendar_event_type.dart';
import 'package:grc_module/features/calendar/domain/enums/grc_events/grc_module_calendar_events.dart';
import 'package:grc_module/features/calendar/domain/enums/grc_events/grc_policy_calendar_events.dart';
import 'package:grc_module/features/calendar/domain/enums/grc_events/grc_control_calendar_events.dart';
import 'package:grc_module/features/grc/grc4_assignment_control/data/models/assignment_control_model.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc5_control/data/models/control_model.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc5_control/domain/entities/assigning_control.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc5_control/domain/entities/control_entity.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc5_control/domain/entities/control_status.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc6_control_champion/data/models/champion_model.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc6_control_champion/domain/entities/champion_entity.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc6_control_champion/domain/entities/champion_status.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc7_control_owner/data/models/owner_model.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc7_control_owner/domain/entities/owner_entity.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc7_control_owner/domain/entities/owner_status.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc10_request/data/models/grc_request_model.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc10_request/domain/entities/grc_request_entity.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc10_request/domain/entities/grc_request_type.dart'; // [module:grc]
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/approval_status.dart';
import 'package:grc_module/core/helper/format_title.dart';
import 'package:grc_module/features/grc/grc13_policy/data/models/policy_model.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc13_policy/domain/entities/policy_entity.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc13_policy/domain/entities/policy_status.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc11_module/data/models/grc_module_model.dart'; // [module:grc]
import 'package:grc_module/features/grc/grc11_module/domain/entities/grc_module_entity.dart'; // [module:grc]
import 'package:grc_module/features/calendar/domain/enums/services_management_module.dart';
import 'package:grc_module/features/calendar/domain/enums/services_module/services_calendar_events.dart';
import 'package:grc_module/features/calendar/domain/enums/role_module/role_management_module/role_management_calendar_events.dart';
import 'package:grc_module/features/calendar/domain/enums/role_module/user_access_module/user_access_calendar_events.dart';
import 'package:grc_module/features/calendar/domain/enums/knowledge_hub_module/knowledge_hub_calendar_events.dart';
import 'package:grc_module/features/calendar/domain/enums/todo_module/todo_calendar_events.dart';
import 'package:grc_module/features/todo/data/models/todo_model.dart';
import 'package:grc_module/features/todo/helpers/constants/todo_firestore_paths.dart';
import 'package:grc_module/features/todo/domain/entities/todo_entity.dart';
// ADDED 9/10/2026 — Time Tracker phase 6 calendar source.
import 'package:grc_module/features/calendar/domain/enums/time_tracker_module/time_tracker_calendar_events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/calendar/domain/enums/settings_module/settings_calendar_events.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/user_management_permission.dart';
import 'package:grc_module/features/settings/se6_requests/data/models/change_request_mapper.dart';
import 'package:grc_module/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:grc_module/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:grc_module/features/settings/se6_requests/domain/enums/request_status.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

import 'dart:convert';
import 'dart:async';

// api_constants.dart is imported for FirestoreCollections (the request path
// constant). `FirebaseCollections` is hidden because a second class of that
// name lives in core/constants/firebase_collections.dart.
import 'package:grc_module/core/network/api_constants.dart'
    hide FirebaseCollections;
import 'package:grc_module/core/helper/access/modules_enum.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:grc_module/core/helper/access/main_core_employee_controller.dart';
import 'package:grc_module/features/calendar/data/models/calendar_event_model.dart';
import 'package:grc_module/core/helper/date_time_helper.dart';
import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/core/enums/template_variable.dart';
import 'package:grc_module/core/constants/firebase_collections.dart';
import 'package:grc_module/features/grc/helpers/constants/grc_firebase_paths.dart'; // [module:grc]
import 'package:grc_module/features/calendar/domain/enums/calendar_catalog.dart';
import 'package:grc_module/core/enums/template_variable_samples.dart';
import 'package:grc_module/features/calendar/domain/enums/form_builder_module/form_builder_calendar_events.dart';

part 'calendar_data_service/calendar_data_service_methods.dart';
part 'calendar_data_service/calendar_data_service_methods_2.dart';
part 'calendar_data_service/calendar_data_service_methods_3.dart';
part 'calendar_data_service/calendar_data_service_methods_4.dart';
part 'calendar_data_service/calendar_data_service_methods_5.dart';
part 'calendar_data_service/calendar_data_service_methods_6.dart';
part 'qiyas/calendar_data_service_qiyas_approvals.dart';
part 'qiyas/calendar_data_service_qiyas_assignments.dart';

class CalendarDataService {
  /// Department lookups are injected; this service has no service locator.
  final MainCoreDepartmentCubit departmentCubit;

  /// The active language code. Was `Get.locale?.languageCode ?? 'en'` read at
  /// six points inside this file — a banned service locator, in the data layer
  /// (CR-SKEL-CAL-N04-DATA). A callback, not a value, so a locale change while
  /// the app is running is picked up.
  final String Function() languageCode;

  /// The signed-in employee. Was `Get.find<MainCoreEmployeeController>()` at
  /// three points here.
  final MainCoreEmployeeController Function() currentEmployee;

  CalendarDataService({
    required this.departmentCubit,
    String Function()? languageCode,
    MainCoreEmployeeController Function()? currentEmployee,
  })  : languageCode = languageCode ?? _defaultLanguageCode,
        currentEmployee = currentEmployee ?? _defaultCurrentEmployee;

  /// Fallbacks so existing call sites keep working while the injection is
  /// threaded through. They are the only GetX left in this file and are the
  /// next thing to remove.
  static String _defaultLanguageCode() => Get.locale?.languageCode ?? 'en';
  static MainCoreEmployeeController _defaultCurrentEmployee() =>
      Get.find<MainCoreEmployeeController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ───────────────────────── seeded demo events ─────────────────────────
  // ADDED 27/9/2026 — the "Apply all modules" button on Home.

  /// Collection (under `getBaseUrl`) that `DemoAccountsSeeder` writes one
  /// document per (account, calendar event type) into.
  static const String seededEventsPath = 'Modules/calendar/Seeded_Events';

  /// Function Name: [getSeededCalendarEvents]
  ///
  /// Purpose: the calendar entries written by the Home "Apply all modules"
  /// button for [currentUserEmail]. Each document only stores the event type
  /// id and a source date; title, colour, status and description are rebuilt
  /// from the enum through `CalendarEventModel.fromType`, exactly like the
  /// real builders, so a seeded card looks identical to a real one.
  Future<List<CalendarEventModel>> getSeededCalendarEvents({
    required String currentUserEmail,
  }) async {
    final List<CalendarEventModel> events = <CalendarEventModel>[];
    final String email = currentUserEmail.trim().toLowerCase();
    if (email.isEmpty) return events;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(getBaseUrl(seededEventsPath))
        .where('receiverEmail', isEqualTo: email)
        .get();

    final bool isArabic = languageCode() == 'ar';
    final DateTime now = DateTime.now();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      final Map<String, dynamic> data = doc.data();
      final CalendarEventType? type = CalendarCatalog.findById(
        (data['typeId'] ?? '').toString(),
      );
      final dynamic rawDate = data['sourceDate'];
      if (type == null || rawDate is! Timestamp) continue;

      final DateTime sourceDate = rawDate.toDate();
      events.add(
        CalendarEventModel.fromType(
          type,
          sourceDate: sourceDate,
          isArabic: isArabic,
          variables: type.variables.toSampleValues(now: now),
          time: DateFormat('hh:mm a', 'en').format(sourceDate),
          // A seeded To-Do card has no real to-do behind it: a null id makes
          // the card open the To-Do list instead of a "not found" details page.
          // 9/10/2026 — same for a seeded Time Tracker card (opens the module).
          requestId:
              (type is TodoCalendarEvent || type is TimeTrackerCalendarEvent)
                  ? null
                  : doc.id,
          userEmail: email,
        ),
      );
    }
    return events;
  }

  // ══════════════════════════════════════════════════════════════════
  //  ROLE MANAGEMENT
  //
  //  Source: `User_Management/{employeeId}` - a UserPermissionHistoryModel.
  //  Role / From_Date / To_Date are HISTORY LISTS: the current value is the
  //  last entry, and a list longer than one entry means the date was moved,
  //  which is what the "... Date Updated" spec entries describe.
  //  Dates are stored as `MMM dd, yyyy` (Constants.userAccessDateFormat).
  // ══════════════════════════════════════════════════════════════════
  // ══════════════════════════════════════════════════════════════════════
  //  GRC MODULE  —  activation-date entries
  // ══════════════════════════════════════════════════════════════════════

  // [module:grc]
  /// The three GRC Module rows of the calendar spec, all driven by a module's
  /// activation date:
  ///
  ///   * [GrcModuleCalendarEvent.activationDateDefined]  on the date itself
  ///   * [GrcModuleCalendarEvent.activationIn14Days]     14 days before
  ///   * [GrcModuleCalendarEvent.activationDateUpdated]  when the date moved
  ///
  /// DERIVED, NEVER STORED — like every other source in this file. The spec
  /// says the calendar entry is "created immediately after saving the
  /// Activation Date" and that an existing entry "is updated automatically";
  /// deriving on read gives both for free, because the cards are recomputed
  /// from the module document each time the calendar opens. Nothing has to be
  /// written, found, or rescheduled.
  ///
  /// AUDIENCE: the module's current owners. A module nobody owns puts nothing
  /// on anybody's calendar, which is why an empty result is not necessarily a
  /// fault — see the logging below.
  Future<List<CalendarEventModel>> getGrcCalendarEvents({
    required String currentUserEmail,
  }) async {
    final List<CalendarEventModel> events = <CalendarEventModel>[];

    if (currentUserEmail.isEmpty) {
      debugPrint('[grc-cal] no signed-in email — nothing to build.');
      return events;
    }

    try {
      final bool isArabic = languageCode() == 'ar';
      final DateFormat fmt = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');
      final DateTime today = DateTime.now();
      final DateTime startOfToday = DateTime(
        today.year,
        today.month,
        today.day,
      );

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection(GrcFirebasePaths.modulesCollection)
              .get();

      int owned = 0;
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        final GRCModuleModel model;
        try {
          model = GRCModuleModel.fromJson(doc.data());
        } catch (e) {
          debugPrint('[grc-cal] skipped ${doc.id} — unreadable document: $e');
          continue;
        }

        final GRCModuleEntity entity = model.toEntity();

        // Only the people responsible for the module get its dates.
        if (!entity.moduleOwners.contains(currentUserEmail)) continue;

        // A removed module keeps its activation date, but it is not going to
        // activate — its cards would be noise.
        if (entity.isRemoved) continue;
        owned++;

        final String name =
            isArabic ? entity.moduleNameAr : entity.moduleNameEn;
        final DateTime activation = entity.moduleActivationDate;
        final String activationText = fmt.format(activation);

        // ── On the activation date ────────────────────────────────────────
        events.add(
          CalendarEventModel.fromType(
            GrcModuleCalendarEvent.activationDateDefined,
            sourceDate: activation,
            isArabic: isArabic,
            // The card's title is the module this event is about.
            taskName: name,
            // `time` was omitted here, so it defaulted to ''. DayTimelineView
            // buckets cards by parsing this string, and an unparseable one was
            // dropped — the day view showed "1 events" in its header (which
            // counts the list) with an empty hour grid, while the month view,
            // which only reads `date`, was fine. Every other builder in this
            // file passes hh:mm a; an activation date is date-only, so this
            // resolves to 12:00 AM exactly like the role-management cards.
            time: DateFormat('hh:mm a').format(activation),
            requestId: entity.moduleId,
            userEmail: currentUserEmail,
            variables: <TemplateVariable, String>{
              TemplateVariable.moduleName: name,
              TemplateVariable.activationDate: activationText,
            },
          ),
        );

        // ── 14 days before ────────────────────────────────────────────────
        //
        // Skipped once that day has passed: a module created inside its own
        // 14-day window would otherwise get a reminder dated in the past,
        // which reads as a missed deadline rather than advance notice.
        final DateTime reminderDay =
            GrcModuleCalendarEvent.activationIn14Days.dateFor(activation);
        if (!reminderDay.isBefore(startOfToday)) {
          events.add(
            CalendarEventModel.fromType(
              GrcModuleCalendarEvent.activationIn14Days,
              sourceDate: activation,
              isArabic: isArabic,
              taskName: name,
              time: DateFormat('hh:mm a').format(reminderDay),
              requestId: entity.moduleId,
              userEmail: currentUserEmail,
              variables: <TemplateVariable, String>{
                TemplateVariable.moduleName: name,
                TemplateVariable.activationDate: activationText,
              },
            ),
          );
        }

        // ── Date moved ────────────────────────────────────────────────────
        //
        // Module_Activation_Date is a history list, so a change is the last
        // two entries differing — the same comparison
        // getRoleManagementCalendarEvents makes on From_Date / To_Date.
        final List<DateTime> history = model.moduleActivationDate;
        if (history.length >= 2) {
          final DateTime previous = history[history.length - 2];
          if (!_isSameDay(previous, activation)) {
            events.add(
              CalendarEventModel.fromType(
                GrcModuleCalendarEvent.activationDateUpdated,
                sourceDate: activation,
                isArabic: isArabic,
                taskName: name,
                time: DateFormat('hh:mm a').format(activation),
                requestId: entity.moduleId,
                userEmail: currentUserEmail,
                variables: <TemplateVariable, String>{
                  TemplateVariable.moduleName: name,
                  TemplateVariable.oldActivationDate: fmt.format(previous),
                  TemplateVariable.newActivationDate: activationText,
                },
              ),
            );
          }
        }
      }

      // Same reasoning as the role builder: an empty list has several
      // innocent causes, and from the calendar they all look like a broken
      // module. Name which one it was.
      debugPrint(
        '[grc-cal] ${snapshot.docs.length} module(s) scanned, '
        '$owned owned by "$currentUserEmail", '
        '${events.length} card(s) built.',
      );
    } catch (e, stackTrace) {
      debugPrint('[grc-cal] build FAILED — $e\n$stackTrace');
    }

    return events;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  GRC POLICY  —  start / end date entries
  // ══════════════════════════════════════════════════════════════════════

  // [/module:grc]
  // [module:grc]
  /// The six GRC Policy rows of the calendar spec, all driven by a policy's
  /// Start Date and End Date:
  ///
  ///   * [GrcPolicyCalendarEvent.startDateReached]   on the start date
  ///   * [GrcPolicyCalendarEvent.startDateUpdated]   when that date moved
  ///   * [GrcPolicyCalendarEvent.endDateDefined]     on the end date
  ///   * [GrcPolicyCalendarEvent.expiresIn14Days]    14 days before it
  ///   * [GrcPolicyCalendarEvent.expiresToday]       on the end date
  ///   * [GrcPolicyCalendarEvent.endDateUpdated]     when THAT date moved
  ///
  /// DERIVED, NEVER STORED — same as [getGrcCalendarEvents]. The spec's
  /// "entry is created immediately" and "existing entry is updated
  /// automatically" both come free: the cards are recomputed from the policy
  /// document every time the calendar opens, so a moved date simply stops
  /// producing its old cards.
  ///
  /// AUDIENCE: the owners of the policy's MODULE. A policy has no owners of
  /// its own, and the module owners are exactly who [getGrcCalendarEvents]
  /// already shows module dates to — so GRC stays one audience.
  ///
  /// SHAPE: policies live in a subcollection under each module, so this walks
  /// the modules the user owns and reads each one's policies. That is one
  /// read per owned module rather than a collection-group query, which keeps
  /// the owner filter on the module document where it already works.
  Future<List<CalendarEventModel>> getGrcPolicyCalendarEvents({
    required String currentUserEmail,
  }) async {
    final List<CalendarEventModel> events = <CalendarEventModel>[];

    if (currentUserEmail.isEmpty) {
      debugPrint('[grc-policy-cal] no signed-in email — nothing to build.');
      return events;
    }

    try {
      final bool isArabic = languageCode() == 'ar';
      final DateFormat fmt = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');
      final DateFormat clock = DateFormat('hh:mm a');
      final DateTime today = DateTime.now();
      final DateTime startOfToday = DateTime(
        today.year,
        today.month,
        today.day,
      );

      final QuerySnapshot<Map<String, dynamic>> modules =
          await FirebaseFirestore.instance
              .collection(GrcFirebasePaths.modulesCollection)
              .get();

      int ownedModules = 0;
      int policiesScanned = 0;

      for (final QueryDocumentSnapshot<Map<String, dynamic>> moduleDoc
          in modules.docs) {
        final GRCModuleModel moduleModel;
        try {
          moduleModel = GRCModuleModel.fromJson(moduleDoc.data());
        } catch (e) {
          debugPrint(
            '[grc-policy-cal] skipped module ${moduleDoc.id} — unreadable: $e',
          );
          continue;
        }

        final GRCModuleEntity module = moduleModel.toEntity();
        if (!module.moduleOwners.contains(currentUserEmail)) continue;
        if (module.isRemoved) continue;
        ownedModules++;

        // 'Policies' — the same subcollection name PolicyFirebaseDataSource
        // writes to.
        final QuerySnapshot<Map<String, dynamic>> policies =
            await moduleDoc.reference.collection('Policies').get();

        for (final QueryDocumentSnapshot<Map<String, dynamic>> policyDoc
            in policies.docs) {
          final PolicyModel policyModel;
          try {
            policyModel = PolicyModel.fromJson(policyDoc.data());
          } catch (e) {
            debugPrint(
              '[grc-policy-cal] skipped policy ${policyDoc.id} — unreadable: $e',
            );
            continue;
          }

          final PolicyEntity policy = policyModel.toEntity();

          // A removed policy keeps its dates but is not going to activate or
          // expire; its cards would be noise. A draft has not been published
          // yet, so its dates are not commitments either.
          if (policy.status == PolicyStatus.removed ||
              policy.status == PolicyStatus.draft) {
            continue;
          }
          policiesScanned++;

          final String name =
              isArabic ? policy.policyNameAr : policy.policyNameEn;
          final DateTime start = policy.startDate;
          final DateTime end = policy.endDate;
          final String startText = fmt.format(start);
          final String endText = fmt.format(end);

          // ── Start date ────────────────────────────────────────────────
          events.add(
            CalendarEventModel.fromType(
              GrcPolicyCalendarEvent.startDateReached,
              sourceDate: start,
              isArabic: isArabic,
              taskName: name,
              // Date-only, so this resolves to 12:00 AM. DayTimelineView
              // buckets by parsing this string and drops an unparseable one —
              // see the note in getGrcCalendarEvents.
              time: clock.format(start),
              requestId: policy.id,
              userEmail: currentUserEmail,
              variables: <TemplateVariable, String>{
                TemplateVariable.policyName: name,
                TemplateVariable.startDate: startText,
              },
            ),
          );

          // ── Start date moved ──────────────────────────────────────────
          //
          // startDate is a history list, so a change is the last two entries
          // differing — the same comparison getGrcCalendarEvents makes on
          // Module_Activation_Date.
          final List<DateTime> startHistory = policyModel.startDate;
          if (startHistory.length >= 2) {
            final DateTime previousStart =
                startHistory[startHistory.length - 2];
            if (!_isSameDay(previousStart, start)) {
              events.add(
                CalendarEventModel.fromType(
                  GrcPolicyCalendarEvent.startDateUpdated,
                  sourceDate: start,
                  isArabic: isArabic,
                  taskName: name,
                  time: clock.format(start),
                  requestId: policy.id,
                  userEmail: currentUserEmail,
                  variables: <TemplateVariable, String>{
                    TemplateVariable.policyName: name,
                    TemplateVariable.oldStartDate: fmt.format(previousStart),
                    TemplateVariable.newStartDate: startText,
                  },
                ),
              );
            }
          }

          // ── End date defined ──────────────────────────────────────────
          events.add(
            CalendarEventModel.fromType(
              GrcPolicyCalendarEvent.endDateDefined,
              sourceDate: end,
              isArabic: isArabic,
              taskName: name,
              time: clock.format(end),
              requestId: policy.id,
              userEmail: currentUserEmail,
              variables: <TemplateVariable, String>{
                TemplateVariable.policyName: name,
                TemplateVariable.endDate: endText,
              },
            ),
          );

          // ── Expires today ─────────────────────────────────────────────
          //
          // Only on the day itself. Without this guard it would be a second
          // permanent card on the same square as endDateDefined, for every
          // policy, forever — the spec wants "it is today", not "it will be".
          if (_isSameDay(end, startOfToday)) {
            events.add(
              CalendarEventModel.fromType(
                GrcPolicyCalendarEvent.expiresToday,
                sourceDate: end,
                isArabic: isArabic,
                taskName: name,
                time: clock.format(end),
                requestId: policy.id,
                userEmail: currentUserEmail,
                variables: <TemplateVariable, String>{
                  TemplateVariable.policyName: name,
                  TemplateVariable.endDate: endText,
                },
              ),
            );
          }

          // ── 14 days before expiry ─────────────────────────────────────
          //
          // Skipped once that day has passed: a policy created inside its own
          // 14-day window would otherwise get a reminder dated in the past,
          // which reads as a missed deadline rather than advance notice.
          final DateTime expiryReminderDay =
              GrcPolicyCalendarEvent.expiresIn14Days.dateFor(end);
          if (!expiryReminderDay.isBefore(startOfToday)) {
            events.add(
              CalendarEventModel.fromType(
                GrcPolicyCalendarEvent.expiresIn14Days,
                sourceDate: end,
                isArabic: isArabic,
                taskName: name,
                time: clock.format(expiryReminderDay),
                requestId: policy.id,
                userEmail: currentUserEmail,
                variables: <TemplateVariable, String>{
                  TemplateVariable.policyName: name,
                  TemplateVariable.endDate: endText,
                },
              ),
            );
          }

          // ── End date moved ────────────────────────────────────────────
          final List<DateTime> endHistory = policyModel.endDate;
          if (endHistory.length >= 2) {
            final DateTime previousEnd = endHistory[endHistory.length - 2];
            if (!_isSameDay(previousEnd, end)) {
              events.add(
                CalendarEventModel.fromType(
                  GrcPolicyCalendarEvent.endDateUpdated,
                  sourceDate: end,
                  isArabic: isArabic,
                  taskName: name,
                  time: clock.format(end),
                  requestId: policy.id,
                  userEmail: currentUserEmail,
                  variables: <TemplateVariable, String>{
                    TemplateVariable.policyName: name,
                    TemplateVariable.oldEndDate: fmt.format(previousEnd),
                    TemplateVariable.newEndDate: endText,
                  },
                ),
              );
            }
          }
        }
      }

      // Same reasoning as the module builder: an empty list has several
      // innocent causes (no owned module, no policies, every policy draft or
      // removed) and from the calendar they all look identical. Name which.
      debugPrint(
        '[grc-policy-cal] ${modules.docs.length} module(s) scanned, '
        '$ownedModules owned by "$currentUserEmail", '
        '$policiesScanned policy(ies) eligible, '
        '${events.length} card(s) built.',
      );
    } catch (e, stackTrace) {
      debugPrint('[grc-policy-cal] build FAILED — $e\n$stackTrace');
    }

    return events;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  GRC CONTROL  —  control, champion, owner and reassignment entries
  // ══════════════════════════════════════════════════════════════════════

  // [/module:grc]
  // [module:grc]
  /// Every [GrcControlCalendarEvent] row of the calendar spec, derived on read
  /// (never stored) like the module and policy builders above:
  ///
  ///   MODULE OWNERS
  ///   * controlStartDateReached         a control's start date, that day
  ///   * champion/ownerReassignmentPending  a pending request's start date
  ///
  ///   ASSIGNED CHAMPION (Control Champions/{email})
  ///   * championStartDateDefined / championAssignmentStartDateReached
  ///   * championStartDateUpdated
  ///   * submissionDueDateDefined / DueIn14Days / DueToday / Overdue
  ///   * submissionDueDateUpdated
  ///
  ///   ASSIGNED OWNER (Control Owners/{email})
  ///   * ownerStartDateDefined / ownerAssignmentStartDateReached
  ///   * ownerStartDateUpdated
  ///
  ///   NEW ASSIGNEE OF AN APPROVED REASSIGNMENT REQUEST
  ///   * champion/ownerReassignmentApproved, …StartDateReached,
  ///     …AssignmentEndsToday
  ///
  /// SOURCE DATES: assignment start = control Start Date; submission due =
  /// control End Date (the rule computeAssignmentControlTab already uses);
  /// reassignments use the request's own Start / End Date.
  ///
  /// COST: per module — the user's champion doc, owner doc, the Requests
  /// collection and one Assignment Controls query; then one Controls read per
  /// policy the user owns or is assigned to.
  Future<List<CalendarEventModel>> getGrcControlCalendarEvents({
    required String currentUserEmail,
  }) async {
    final List<CalendarEventModel> events = <CalendarEventModel>[];

    if (currentUserEmail.isEmpty) {
      debugPrint('[grc-control-cal] no signed-in email — nothing to build.');
      return events;
    }

    try {
      final bool isArabic = languageCode() == 'ar';
      final DateFormat fmt = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');
      final DateFormat clock = DateFormat('hh:mm a');
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

      CalendarEventModel card(
        GrcControlCalendarEvent type, {
        required DateTime sourceDate,
        required String name,
        required String id,
        required Map<TemplateVariable, String> variables,
      }) =>
          CalendarEventModel.fromType(
            type,
            sourceDate: sourceDate,
            isArabic: isArabic,
            taskName: name,
            // Date-only → 12:00 AM. DayTimelineView drops an unparseable
            // time; see the note in getGrcCalendarEvents.
            time: clock.format(type.dateFor(sourceDate)),
            requestId: id,
            userEmail: currentUserEmail,
            variables: variables,
          );

      final QuerySnapshot<Map<String, dynamic>> modules =
          await FirebaseFirestore.instance
              .collection(GrcFirebasePaths.modulesCollection)
              .get();

      int modulesUsed = 0;

      for (final QueryDocumentSnapshot<Map<String, dynamic>> moduleDoc
          in modules.docs) {
        final GRCModuleEntity module;
        try {
          module = GRCModuleModel.fromJson(moduleDoc.data()).toEntity();
        } catch (e) {
          debugPrint(
            '[grc-control-cal] skipped module ${moduleDoc.id} — unreadable: $e',
          );
          continue;
        }
        if (module.isRemoved) continue;

        final bool isModuleOwner = module.moduleOwners.contains(
          currentUserEmail,
        );
        final DocumentReference<Map<String, dynamic>> moduleRef =
            moduleDoc.reference;

        // ── Who is the user in this module? ───────────────────────────────
        List<AssigningControlEntity> championPairs =
            const <AssigningControlEntity>[];
        List<AssigningControlEntity> ownerPairs =
            const <AssigningControlEntity>[];
        try {
          final championDoc = await moduleRef
              .collection('Control Champions')
              .doc(currentUserEmail)
              .get();
          final Map<String, dynamic>? data = championDoc.data();
          if (data != null) {
            final ChampionEntity champion =
                ChampionModel.fromJson(data).toEntity();
            if (champion.status != ChampionStatus.removed) {
              championPairs = champion.assigningControls;
            }
          }
          final ownerDoc = await moduleRef
              .collection('Control Owners')
              .doc(currentUserEmail)
              .get();
          final Map<String, dynamic>? ownerData = ownerDoc.data();
          if (ownerData != null) {
            final OwnerEntity owner = OwnerModel.fromJson(ownerData).toEntity();
            if (owner.status != OwnerStatus.removed) {
              ownerPairs = owner.assigningControls;
            }
          }
        } catch (e) {
          debugPrint(
            '[grc-control-cal] assignee read failed '
            '(${module.moduleId}): $e',
          );
        }

        // ── Reassignment requests ─────────────────────────────────────────
        final List<GrcRequestEntity> requests = <GrcRequestEntity>[];
        try {
          final snapshot = await moduleRef.collection('Requests').get();
          for (final doc in snapshot.docs) {
            try {
              final GrcRequestEntity request = GrcRequestModel.fromJson(
                doc.data(),
              ).toEntity();
              if (request.type.isReassignment) requests.add(request);
            } catch (_) {}
          }
        } catch (e) {
          debugPrint(
            '[grc-control-cal] requests read failed '
            '(${module.moduleId}): $e',
          );
        }

        final bool hasRequestForMe = requests.any(
          (GrcRequestEntity r) =>
              r.status == ApprovalStatus.approved &&
              (r.newChampionEmail == currentUserEmail ||
                  r.newOwnerEmail == currentUserEmail),
        );
        final bool hasPendingForApproval = isModuleOwner &&
            requests.any(
              (GrcRequestEntity r) =>
                  r.status == ApprovalStatus.pending &&
                  r.requestedBy != currentUserEmail,
            );

        if (!isModuleOwner &&
            championPairs.isEmpty &&
            ownerPairs.isEmpty &&
            !hasRequestForMe &&
            !hasPendingForApproval) {
          continue;
        }
        modulesUsed++;

        // ── Controls the user needs, keyed "<policy>/<control>" ───────────
        final Set<String> neededPolicies = <String>{
          ...championPairs.map((AssigningControlEntity a) => a.policyId),
          ...ownerPairs.map((AssigningControlEntity a) => a.policyId),
          for (final GrcRequestEntity r in requests)
            ...?r.controls?.map((AssigningControlEntity a) => a.policyId),
        };
        final Map<String, ControlModel> controlModels =
            <String, ControlModel>{};
        try {
          final policies = await moduleRef.collection('Policies').get();
          for (final policyDoc in policies.docs) {
            if (!isModuleOwner && !neededPolicies.contains(policyDoc.id)) {
              continue;
            }
            final PolicyEntity policy;
            try {
              policy = PolicyModel.fromJson(policyDoc.data()).toEntity();
            } catch (_) {
              continue;
            }
            if (policy.status == PolicyStatus.removed ||
                policy.status == PolicyStatus.draft) {
              continue;
            }
            final controls =
                await policyDoc.reference.collection('Controls').get();
            for (final controlDoc in controls.docs) {
              try {
                controlModels['${policyDoc.id}/${controlDoc.id}'] =
                    ControlModel.fromJson(controlDoc.data());
              } catch (_) {}
            }
          }
        } catch (e) {
          debugPrint(
            '[grc-control-cal] controls read failed '
            '(${module.moduleId}): $e',
          );
        }

        String nameOf(ControlEntity c) =>
            isArabic && c.controlsNameAr.isNotEmpty
                ? c.controlsNameAr
                : c.controlsNameEn;
        bool isLive(ControlEntity c) =>
            c.status != ControlStatus.draft &&
            c.status != ControlStatus.inactive;

        // ── Module owners: control start date ─────────────────────────────
        if (isModuleOwner) {
          for (final MapEntry<String, ControlModel> entry
              in controlModels.entries) {
            final ControlEntity control = entry.value.toEntity();
            if (!isLive(control)) continue;
            if (dayOf(control.startDate) != today) continue;
            events.add(
              card(
                GrcControlCalendarEvent.controlStartDateReached,
                sourceDate: control.startDate,
                name: nameOf(control),
                id: control.id,
                variables: <TemplateVariable, String>{
                  TemplateVariable.controlName: nameOf(control),
                },
              ),
            );
          }
        }

        // ── Submission status for the champion's controls ─────────────────
        final Set<String> submittedControls = <String>{};
        if (championPairs.isNotEmpty) {
          try {
            final snapshot = await moduleRef
                .collection('Assignment Controls')
                .where('Control_Champion_Email', isEqualTo: currentUserEmail)
                .get();
            for (final doc in snapshot.docs) {
              try {
                // Compared on the stored value rather than
                // AssignmentControlStatus, whose file pulls Material into
                // this data layer (CR-SKEL-CAL-N02-DATA).
                final AssignmentControlModel a =
                    AssignmentControlModel.fromJson(doc.data());
                final String status =
                    a.status.isEmpty ? '' : a.status.last.toLowerCase();
                if (status == 'submitted' ||
                    status == 'in review' ||
                    status == 'approved') {
                  submittedControls.add(a.controlId);
                }
              } catch (_) {}
            }
          } catch (e) {
            debugPrint(
              '[grc-control-cal] submissions read failed '
              '(${module.moduleId}): $e',
            );
          }
        }

        // ── Assigned champion / owner ─────────────────────────────────────
        void assignee(
          List<AssigningControlEntity> pairs, {
          required bool champion,
        }) {
          for (final AssigningControlEntity pair in pairs) {
            final ControlModel? model =
                controlModels['${pair.policyId}/${pair.controlId}'];
            if (model == null) continue;
            final ControlEntity control = model.toEntity();
            if (!isLive(control)) continue;
            final String name = nameOf(control);
            final DateTime start = control.startDate;
            final Map<TemplateVariable, String> nameOnly =
                <TemplateVariable, String>{TemplateVariable.controlName: name};

            // Start date defined — while the start is today or ahead.
            if (!dayOf(start).isBefore(today)) {
              events.add(
                card(
                  champion
                      ? GrcControlCalendarEvent.championStartDateDefined
                      : GrcControlCalendarEvent.ownerStartDateDefined,
                  sourceDate: start,
                  name: name,
                  id: control.id,
                  variables: <TemplateVariable, String>{
                    TemplateVariable.controlName: name,
                    TemplateVariable.startDate: fmt.format(start),
                  },
                ),
              );
            }
            // Start date reached — on that day only.
            if (dayOf(start) == today) {
              events.add(
                card(
                  champion
                      ? GrcControlCalendarEvent
                          .championAssignmentStartDateReached
                      : GrcControlCalendarEvent.ownerAssignmentStartDateReached,
                  sourceDate: start,
                  name: name,
                  id: control.id,
                  variables: nameOnly,
                ),
              );
            }
            // Start date moved — startDate is a history list.
            if (model.startDate.length >= 2) {
              final DateTime previous =
                  model.startDate[model.startDate.length - 2];
              if (!_isSameDay(previous, start)) {
                events.add(
                  card(
                    champion
                        ? GrcControlCalendarEvent.championStartDateUpdated
                        : GrcControlCalendarEvent.ownerStartDateUpdated,
                    sourceDate: start,
                    name: name,
                    id: control.id,
                    variables: <TemplateVariable, String>{
                      TemplateVariable.controlName: name,
                      TemplateVariable.oldStartDate: fmt.format(previous),
                      TemplateVariable.newStartDate: fmt.format(start),
                    },
                  ),
                );
              }
            }

            if (!champion) continue;

            // ── Submission due date (champions only) ────────────────────
            final DateTime due = control.endDate;
            final Map<TemplateVariable, String> dueVars =
                <TemplateVariable, String>{
              TemplateVariable.controlName: name,
              TemplateVariable.dueDate: fmt.format(due),
            };
            final bool submitted = submittedControls.contains(control.id);

            if (model.endDate.length >= 2) {
              final DateTime previousDue =
                  model.endDate[model.endDate.length - 2];
              if (!_isSameDay(previousDue, due)) {
                events.add(
                  card(
                    GrcControlCalendarEvent.submissionDueDateUpdated,
                    sourceDate: due,
                    name: name,
                    id: control.id,
                    variables: <TemplateVariable, String>{
                      TemplateVariable.controlName: name,
                      TemplateVariable.oldEndDate: fmt.format(previousDue),
                      TemplateVariable.newEndDate: fmt.format(due),
                    },
                  ),
                );
              }
            }
            if (submitted) continue;

            events.add(
              card(
                GrcControlCalendarEvent.submissionDueDateDefined,
                sourceDate: due,
                name: name,
                id: control.id,
                variables: dueVars,
              ),
            );
            final DateTime reminderDay = dayOf(
              GrcControlCalendarEvent.submissionDueIn14Days.dateFor(due),
            );
            if (!reminderDay.isBefore(today)) {
              events.add(
                card(
                  GrcControlCalendarEvent.submissionDueIn14Days,
                  sourceDate: due,
                  name: name,
                  id: control.id,
                  variables: dueVars,
                ),
              );
            }
            if (dayOf(due) == today) {
              events.add(
                card(
                  GrcControlCalendarEvent.submissionDueToday,
                  sourceDate: due,
                  name: name,
                  id: control.id,
                  variables: dueVars,
                ),
              );
            }
            if (dayOf(due).isBefore(today)) {
              events.add(
                card(
                  GrcControlCalendarEvent.submissionOverdue,
                  sourceDate: due,
                  name: name,
                  id: control.id,
                  variables: dueVars,
                ),
              );
            }
          }
        }

        assignee(championPairs, champion: true);
        assignee(ownerPairs, champion: false);

        // ── Reassignment requests ─────────────────────────────────────────
        for (final GrcRequestEntity request in requests) {
          final DateTime? start = request.startDate;
          if (start == null) continue;
          final bool isChampionRequest =
              request.type == GrcRequestType.reassignChampion;
          final List<AssigningControlEntity> pairs =
              request.controls ?? const <AssigningControlEntity>[];

          for (final AssigningControlEntity pair in pairs) {
            final ControlModel? model =
                controlModels['${pair.policyId}/${pair.controlId}'];
            if (model == null) continue;
            final ControlEntity control = model.toEntity();
            final String name = nameOf(control);

            // Approvers — while pending.
            if (request.status == ApprovalStatus.pending &&
                isModuleOwner &&
                request.requestedBy != currentUserEmail) {
              events.add(
                card(
                  isChampionRequest
                      ? GrcControlCalendarEvent.championReassignmentPending
                      : GrcControlCalendarEvent.ownerReassignmentPending,
                  sourceDate: start,
                  name: name,
                  id: request.id,
                  variables: <TemplateVariable, String>{
                    TemplateVariable.requesterName:
                        FormatHelper.formatEmailToName(request.requestedBy),
                    TemplateVariable.controlName: name,
                    TemplateVariable.startDate: fmt.format(start),
                  },
                ),
              );
            }

            // The incoming assignee — once approved.
            final String? incoming = isChampionRequest
                ? request.newChampionEmail
                : request.newOwnerEmail;
            if (request.status != ApprovalStatus.approved ||
                incoming != currentUserEmail) {
              continue;
            }
            if (!dayOf(start).isBefore(today)) {
              events.add(
                card(
                  isChampionRequest
                      ? GrcControlCalendarEvent.championReassignmentApproved
                      : GrcControlCalendarEvent.ownerReassignmentApproved,
                  sourceDate: start,
                  name: name,
                  id: request.id,
                  variables: <TemplateVariable, String>{
                    TemplateVariable.controlName: name,
                    TemplateVariable.startDate: fmt.format(start),
                  },
                ),
              );
            }
            if (dayOf(start) == today) {
              events.add(
                card(
                  isChampionRequest
                      ? GrcControlCalendarEvent.championStartDateReached
                      : GrcControlCalendarEvent.ownerStartDateReached,
                  sourceDate: start,
                  name: name,
                  id: request.id,
                  variables: <TemplateVariable, String>{
                    TemplateVariable.controlName: name,
                  },
                ),
              );
            }
            final DateTime? end = request.endDate;
            if (end != null && dayOf(end) == today) {
              events.add(
                card(
                  isChampionRequest
                      ? GrcControlCalendarEvent.championAssignmentEndsToday
                      : GrcControlCalendarEvent.ownerAssignmentEndsToday,
                  sourceDate: end,
                  name: name,
                  id: request.id,
                  variables: <TemplateVariable, String>{
                    TemplateVariable.controlName: name,
                  },
                ),
              );
            }
          }
        }
      }

      debugPrint(
        '[grc-control-cal] ${modules.docs.length} module(s) scanned, '
        '$modulesUsed relevant to "$currentUserEmail", '
        '${events.length} card(s) built.',
      );
    } catch (e, stackTrace) {
      debugPrint('[grc-control-cal] build FAILED — $e\n$stackTrace');
    }

    return events;
  }

  // [/module:grc]
  /// Function Name: [_isSameDay]
  ///
  /// Purpose: Calendar-day equality, ignoring the time of day.
  ///
  /// Access dates are parsed from `MMM dd, yyyy` and so land at midnight,
  /// while `DateTime.now()` does not — `isAfter`/`isBefore` alone would call
  /// a start date "in the past" from 00:01 on the day it starts.
  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── shared helpers for the two builders above ────────────────────────

  /// ══════════════════════════════════════════════════════════════════
  ///  EMPLOYEE LOOKUP BY EMAIL                       ADDED 30/8/2026
  ///
  ///  Both role-area builders used to resolve the signed-in user by pulling
  ///  the WHOLE `Employees_Info` collection and looping it in Dart, each with
  ///  its own `.timeout(const Duration(seconds: 15))`. Two problems, and
  ///  together they are why these two sources produced nothing on any tenant
  ///  with a real headcount:
  ///
  ///   1. `CalendarCubit._perSourceTimeout` is **12 seconds**. Role
  ///      Management then spent up to 15s on the scan and up to another 15s
  ///      on the permission document — 30s of budget inside a 12s window — so
  ///      the cubit abandoned the source, logged it under `failures`, and the
  ///      calendar rendered without a single role card. The inner timeouts
  ///      were never reachable; the outer one always won first.
  ///   2. A full-collection read to find one document is the wrong query. It
  ///      also grows with the tenant, so this got slower exactly as it got
  ///      more likely to matter.
  ///
  ///  `Email` is a history list, so `arrayContains` matches an employee whose
  ///  address is (or ever was) this one. Both the address as given and its
  ///  lowercased form are tried, because the collection is not consistently
  ///  cased; the old full scan stays as the last resort for a record whose
  ///  address is stored in some third casing, now time-boxed to fit the
  ///  budget.
  /// ══════════════════════════════════════════════════════════════════

  /// Everything the two builders need from the employee record.
  ///
  /// [Duration] is deliberately short: two of these can run inside one 12s
  /// source, and a slow answer is worth less than a partial calendar.
  static const Duration _employeeLookupTimeout = Duration(seconds: 5);

  /// Function Name: [_employeeDocForEmail]
  ///
  /// Purpose: The `Employees_Info` document for an address, or null.
  ///
  /// Parameters:
  /// - [email]: the signed-in user's address.
  ///
  /// Returns: [Future] of the snapshot, or null when no record matches.
  static Future<DocumentSnapshot<Map<String, dynamic>>?> _employeeDocForEmail(
    String email,
  ) async {
    final String trimmed = email.trim();
    if (trimmed.isEmpty) return null;

    final CollectionReference<Map<String, dynamic>> collection =
        FirebaseFirestore.instance.collection(getBaseUrl('Employees_Info'));

    for (final String candidate in <String>{trimmed, trimmed.toLowerCase()}) {
      final QuerySnapshot<Map<String, dynamic>> hit = await collection
          .where('Email', arrayContains: candidate)
          .limit(1)
          .get()
          .timeout(_employeeLookupTimeout);
      if (hit.docs.isNotEmpty) return hit.docs.first;
    }

    // Last resort: the old scan, for a record stored in some other casing.
    final QuerySnapshot<Map<String, dynamic>> all =
        await collection.get().timeout(_employeeLookupTimeout);
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in all.docs) {
      final List<String> emails = _historyList(doc.data()['Email']);
      if (emails.isEmpty) continue;
      if (emails.last.trim().toLowerCase() == trimmed.toLowerCase()) return doc;
    }
    return null;
  }

  /// Firestore stores most employee fields as a history list where the
  /// CURRENT value is the last entry. Normalises the several shapes seen in
  /// this database into a plain list of strings.
  static List<String> _historyList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value.map((e) => e?.toString() ?? '').toList();
    if (value is Map && value['values'] is List) {
      return (value['values'] as List).map((e) => e?.toString() ?? '').toList();
    }
    return [value.toString()];
  }

  /// Access dates are written with Constants.userAccessDateFormat
  /// ("MMM dd, yyyy"). A few older rows use ISO, so both are accepted.
  static DateTime? _parseAccessDate(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty || text == 'null' || text == '[]') return null;
    for (final pattern in const ['MMM dd, yyyy', 'MMM d, yyyy', 'yyyy-MM-dd']) {
      try {
        return DateFormat(pattern, 'en').parseStrict(text);
      } catch (_) {}
    }
    return DateTime.tryParse(text);
  }

  // ══════════════════════════════════════════════════════════════════
  // SETTINGS — profile / health insurance / emergency contact change
  // requests.
  //
  // ADDED 25/8/2026. The settings change-request flow raised notifications but
  // never a calendar entry, so a request waiting on a reviewer lived only in
  // the inbox and the Requests queue — neither of which answers "what needs me
  // this week".
  //
  // Two audiences off one collection, decided per document:
  //   • a signed-in user holding `Users_Requests` gets a pending-review card
  //     for every request still awaiting a decision;
  //   • the employee who raised a request gets its own lifecycle — submitted
  //     while pending, then approved or rejected on the decision date.
  // CHANGED 9/10/2026 (owner decision): a reviewer no longer gets the
  // pending-review card for their OWN request — they cannot approve or reject
  // it any more (SelfApprovalRule), so "someone has to answer" is not them.
  // They still get their own submitted / decided lifecycle cards.
  // ══════════════════════════════════════════════════════════════════

  /// How many requests one calendar load will read.
  ///
  /// The collection is unbounded and grows for the life of the tenant, while
  /// the calendar only ever renders a window of it. Newest-first with a cap
  /// keeps the read predictable; the cap is generous enough that reaching it
  /// means more history than any calendar view can show, and
  /// [getSettingsCalendarEvents] says so in the log rather than truncating
  /// silently.
  static const int _settingsRequestScanLimit = 300;

  /// Function Name: [_settingsDecisionDate]
  ///
  /// Purpose: When a request was decided.
  ///
  /// `updatedAt` is written as a server timestamp, but older documents predate
  /// the field and a few carry epoch milliseconds, so all three shapes are
  /// accepted. Anything else yields null and the caller falls back to the
  /// request date rather than dropping the card.
  static DateTime? _settingsDecisionDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  /// Helper method to check if it's user's turn to approve
  /// Function Name: [_decodeCurrentApprovalCycle]
  ///
  /// Purpose: The LIVE approval cycle out of the `Approval_Cycle` field.
  ///
  /// `Approval_Cycle` is a revision history: `ServicesHistoryModel
  /// .updateApprovalCycle` appends a whole new JSON-encoded cycle every time a
  /// decision is taken, and `currentApprovalCycle` reads `.last`. Only that
  /// last revision is decoded here, for the reason spelled out at the call
  /// site — flattening every revision put each approver in the list once per
  /// revision, and `indexWhere` then returned their state from the OLDEST one.
  ///
  /// Parameters:
  /// - [raw]: the field value, a list of JSON strings.
  ///
  /// Returns: one entry per approver with `email` and `state`, both
  /// lower-cased; empty when the field is absent, empty or unreadable.
  static List<Map<String, String>> _decodeCurrentApprovalCycle(dynamic raw) {
    if (raw is! List || raw.isEmpty) return const <Map<String, String>>[];

    // Skip trailing blanks: a cleared cycle is written as '' or '[]', and the
    // live revision is the last one that actually holds approvers.
    for (int i = raw.length - 1; i >= 0; i--) {
      final dynamic item = raw[i];
      if (item is! String) continue;
      final String text = item.trim();
      if (text.isEmpty || text == '[]' || text == '""') continue;

      try {
        final dynamic decoded = jsonDecode(text);
        if (decoded is! List) continue;

        final List<Map<String, String>> cycle = <Map<String, String>>[];
        for (final dynamic emp in decoded) {
          if (emp is! Map) continue;
          cycle.add(<String, String>{
            'email': (emp['email'] ?? '').toString().trim().toLowerCase(),
            'state': (emp['state'] ?? '').toString().trim().toLowerCase(),
          });
        }
        if (cycle.isNotEmpty) return cycle;
      } catch (_) {
        // Malformed revision — fall back to the one before it.
      }
    }
    return const <Map<String, String>>[];
  }

  /// Function Name: [_epochMs]
  ///
  /// Purpose: A `timestamps` entry as a [DateTime].
  ///
  /// The array holds epoch milliseconds, but written by several paths: as an
  /// `int`, as a `num` (a double epoch), or as a string. All three are
  /// accepted; anything else yields "now" rather than throwing, because one
  /// unreadable timestamp must not cost the whole calendar its service cards.
  static DateTime _epochMs(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    final int? parsed = int.tryParse(value.toString());
    return parsed == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(parsed);
  }

  bool _isMyTurnToApprove({
    required List<Map<String, String>> approvalCycle,
    required String currentUserEmail,
    required int myIndex,
  }) {
    // Check all previous approvers
    for (int i = 0; i < myIndex; i++) {
      final prevState = approvalCycle[i]['state'];

      // If previous approver rejected or canceled, not my turn
      if (['rejected', 'cancel'].contains(prevState)) {
        return false;
      }

      // If previous approver is still pending, not my turn
      if (['pending', 'normal', ''].contains(prevState)) {
        return false;
      }

      // Previous approver must be approved
      if (prevState != 'approved') {
        return false;
      }
    }

    // Check my state
    final myState = approvalCycle[myIndex]['state'];

    final isMyTurn = ['pending', 'normal', ''].contains(myState);

    return isMyTurn;
  }

  // Helper methods

  /// Function Name: [_inProgressStart]
  ///
  /// Purpose: When work on a service request ACTUALLY started — the timestamp
  /// paired with the first `InProgress` entry in the status history.
  ///
  /// ADDED 1/9/2026. This lookup existed twice, written out longhand in
  /// STAGE 2 and again in STAGE 3 of [getServicesCalendarEvents], and only one
  /// of the two copies had the fallback. §2 of the spec hangs the in-progress
  /// calendar entry off "the actual start date", so getting this wrong moves
  /// a card rather than dropping it, which is harder to notice.
  ///
  /// Parameters:
  /// - [statusHistory]: the document's `status` array, parallel to
  ///   [timestamps]. May be null on older documents.
  /// - [timestamps]: the document's `timestamps` array.
  ///
  /// Returns: [DateTime] of the transition, or null when neither the status
  /// history nor the two-entry fallback can place it.
  DateTime? _inProgressStart({
    required List<dynamic>? statusHistory,
    required List<dynamic> timestamps,
  }) {
    int? index;
    if (statusHistory != null) {
      for (int i = 0; i < statusHistory.length; i++) {
        if (statusHistory[i].toString().toLowerCase() == 'inprogress') {
          index = i;
          break;
        }
      }
    }

    // Fallback for documents written before the status history was kept in
    // step with the timestamps: the second entry is the first transition
    // after submission.
    final int? resolved = (index != null && timestamps.length > index)
        ? index
        : (timestamps.length >= 2 ? 1 : null);
    if (resolved == null) return null;

    final dynamic raw = timestamps[resolved];
    return DateTime.fromMillisecondsSinceEpoch(
      raw is int ? raw : int.parse(raw.toString()),
    );
  }

  String _getFinalStateFromModel(ServicesHistoryModel service) {
    final stateField = service.currentState.toLowerCase();

    if ([
      'cancel',
      'inprogress',
      'done',
      'branchsla',
      'breached sla',
    ].contains(stateField)) {
      return stateField;
    }

    final approvalCycle = service.currentApprovalCycle;
    final hasApprovalCycle = approvalCycle.isNotEmpty;

    if (!hasApprovalCycle) {
      if (stateField.isEmpty || stateField == 'pending') {
        return 'approved';
      }
      return stateField.isEmpty ? 'approved' : stateField;
    }

    final states = approvalCycle
        .where((e) => e.state != null && e.state!.isNotEmpty)
        .map((e) => e.state!.toLowerCase())
        .toList();

    if (states.contains('cancel')) return 'cancel';
    if (states.contains('rejected')) return 'rejected';
    if (states.every((s) => s == 'approved') && states.isNotEmpty) {
      return 'approved';
    }
    if (states.contains('pending')) return 'pending';

    if (stateField.isNotEmpty) {
      return stateField;
    }

    return 'approved';
  }

  String? _getArrayValue(dynamic field) {
    if (field == null) return null;
    if (field is List && field.isNotEmpty) {
      return field.first?.toString();
    }
    if (field is String) return field;
    return field.toString();
  }

  /// Function Name: [todoCalendarEntries]
  ///
  /// Purpose: The calendar cards ONE to-do raises — the pure half of
  /// [getTodoCalendarEvents], split out 7/10/2026 so it can be unit-tested
  /// without Firestore (test/features/calendar/todo/).
  ///
  /// REVISED 7/10/2026 (owner feedback): the DUE date (the to-do's end date)
  /// is "the day it must be done", so it carries its own entry.
  ///  • Task Scheduled — every day from the start date up to the day BEFORE
  ///    the due date, at the start time. Start and due on the same day → no
  ///    Scheduled card at all;
  ///  • Task Due — on the due date, at the end time, while it is not overdue
  ///    (a done to-do keeps it);
  ///  • Task Overdue — on the due date INSTEAD of Task Due, once the end time
  ///    has passed and the to-do is not done;
  ///  • Recurring Task Reminder — every later recurrence day (`occursOn`).
  ///    For a scheduled to-do the first occurrence is its own start → due
  ///    span above, so no recurring card lands on any day of that span.
  /// Deleted to-dos raise nothing; done to-dos keep their Scheduled / Due
  /// cards but raise no Overdue or recurrence cards. Days are limited to 60
  /// days back and 180 days ahead of [now]. Every card's `requestId` is the
  /// to-do id, so tapping it can open that to-do's details.
  ///
  /// Parameters:
  /// - [todo]: the to-do (current state of its history document).
  /// - [now]: the clock every rule is evaluated against.
  /// - [isArabic]: language of the catalog title / description.
  /// - [userEmail]: stored on each card (the owner).
  ///
  /// Returns: [List<CalendarEventModel>]
  static List<CalendarEventModel> todoCalendarEntries(
    TodoEntity todo, {
    required DateTime now,
    required bool isArabic,
    required String userEmail,
  }) {
    final List<CalendarEventModel> events = <CalendarEventModel>[];
    if (todo.isDeleted) return events;

    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime windowStart =
        DateTime(today.year, today.month, today.day - 60);
    final DateTime windowEnd =
        DateTime(today.year, today.month, today.day + 180);

    DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
    bool inWindow(DateTime d) =>
        !dayOf(d).isBefore(windowStart) && !dayOf(d).isAfter(windowEnd);
    String timeOf(DateTime d) => DateFormat('hh:mm a', 'en').format(d);

    final String? taskName = todo.name.trim().isEmpty ? null : todo.name;
    CalendarEventModel entry(
      TodoCalendarEvent type,
      DateTime sourceDate,
      String time,
    ) =>
        CalendarEventModel.fromType(
          type,
          sourceDate: sourceDate,
          isArabic: isArabic,
          taskName: taskName,
          time: time,
          requestId: todo.id,
          userEmail: userEmail,
        );

    // The scheduled span: start → due. A missing end falls back to the start
    // (that single day is then the due day), and a due day that sits before
    // the start day (bad data) is pulled up to the start day.
    final DateTime? start = todo.startAt ?? todo.endAt;
    final DateTime? due = todo.endAt ?? todo.startAt;
    final bool hasSpan = todo.isScheduled && start != null && due != null;
    final DateTime? spanFirstDay = hasSpan ? dayOf(start) : null;
    final DateTime? dueDay = hasSpan
        ? (dayOf(due).isBefore(dayOf(start)) ? dayOf(start) : dayOf(due))
        : null;

    // ── Task Scheduled: start → the day before the due date ──────────────
    if (hasSpan) {
      DateTime day =
          spanFirstDay!.isBefore(windowStart) ? windowStart : spanFirstDay;
      while (day.isBefore(dueDay!) && !day.isAfter(windowEnd)) {
        events.add(entry(
          TodoCalendarEvent.taskScheduled,
          DateTime(day.year, day.month, day.day, start.hour, start.minute),
          timeOf(start),
        ));
        day = DateTime(day.year, day.month, day.day + 1);
      }
    }

    // ── Task Overdue — Action Required: on the end date ──────────────────
    // Replaces Task Due once the end time has passed and it is not done.
    final DateTime? endAt = todo.endAt;
    final bool overdue = endAt != null && todo.isOverdue(now);
    if (overdue && inWindow(endAt)) {
      events.add(entry(TodoCalendarEvent.taskOverdue, endAt, timeOf(endAt)));
    }

    // ── Task Due — Action Required: on the due date ──────────────────────
    if (hasSpan && !overdue) {
      final DateTime dueAt = DateTime(
          dueDay!.year, dueDay.month, dueDay.day, due.hour, due.minute);
      if (inWindow(dueAt)) {
        events.add(entry(TodoCalendarEvent.taskDue, dueAt, timeOf(due)));
      }
    }

    // ── Recurring Task Reminder: each later occurrence in the window ─────
    final DateTime? anchor = todo.recurrenceAnchor;
    if (todo.hasFrequency && !todo.isDone && anchor != null) {
      final DateTime anchorDay = dayOf(anchor);
      bool inOwnSpan(DateTime day) =>
          spanFirstDay != null &&
          !day.isBefore(spanFirstDay) &&
          !day.isAfter(dueDay!);
      DateTime day = anchorDay.isBefore(windowStart) ? windowStart : anchorDay;
      while (!day.isAfter(windowEnd)) {
        if (!inOwnSpan(day) &&
            todo.frequency.occursOn(anchor: anchor, day: day)) {
          final DateTime at = DateTime(
              day.year, day.month, day.day, anchor.hour, anchor.minute);
          events.add(entry(
            TodoCalendarEvent.recurringTaskReminder,
            at,
            timeOf(at),
          ));
        }
        day = DateTime(day.year, day.month, day.day + 1);
      }
    }

    return events;
  }

  /// Helper method to check if it's user's turn to approve
}
