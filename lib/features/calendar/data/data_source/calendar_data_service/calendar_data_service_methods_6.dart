/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_data_service_methods_6.dart
/// Description: Methods of `CalendarDataService` — split out of `calendar_data_service.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../calendar_data_service.dart';

// Split from calendar_data_service.dart to keep every file under 700 lines.

extension CalendarDataServiceMethods6 on CalendarDataService {
  /// Function Name: [getServicesCalendarEvents]
  ///
  /// Purpose: Every calendar entry the Service Management module raises for
  /// one signed-in user — as provider, as requester, or as the middle manager
  /// over either.
  ///
  /// Colour, title and status all come from [ServicesCalendarEvent]; nothing
  /// here passes a literal for them.
  ///
  /// TIDIED 30/8/2026: the doc comment above this was five verbatim copies of
  /// the same two lines, and the body ended with two `for` loops that read
  /// `events[i]` into a variable and did nothing with it — the remains of
  /// removed debug printing.
  Future<List<CalendarEventModel>> getServicesCalendarEvents({
    required String currentUserEmail,
  }) async {
    if (currentUserEmail.isEmpty) {
      return [];
    }

    List<CalendarEventModel> events = [];

    try {
      // ⚠️ Same wrong path as [getApprovalCalendarEvents] had — see the note
      // there. `Demo/<companyId>/RequestServices` does not exist; the module
      // stores requests under `Modules/services/RequestServices`.
      final snapshot = await FirebaseFirestore.instance
          .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
          .get();

      final now = DateTime.now();

      // ✅ Get current locale to determine language
      final currentLocale = languageCode();
      final isArabic = currentLocale == 'ar';

      // ✅ Get main core controllers
      final mainCoreController = currentEmployee();
      final departmentController = departmentCubit;

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final model = ServicesHistoryModel.fromJson(data, doc.id);

          // ✅ Get service names in both languages
          final serviceNameEnglish = model.currentServiceNameEnglish.isNotEmpty
              ? model.currentServiceNameEnglish
              : 'Service';

          final serviceNameArabic = model.currentServiceNameArabic.isNotEmpty
              ? model.currentServiceNameArabic
              : 'خدمة';

          // ✅ Create bilingual task name
          final taskName = '$serviceNameEnglish / $serviceNameArabic';

          // Get final state
          // 22/10/2026: 'breached sla' (with a space) is the same state as
          // 'branchsla'; it got no cards at all.
          final String rawState = _getFinalStateFromModel(model);
          final String state = rawState.toLowerCase().trim() == 'breached sla'
              ? 'branchsla'
              : rawState;

          // Get user involvement
          final assignedEmail =
              model.currentAssignedProviderEmail.toLowerCase().trim();
          final requesterEmails = model.currentEmailRequester;
          final isAssignedToUser =
              assignedEmail == currentUserEmail.toLowerCase().trim();
          // 22/10/2026: was a substring test (`contains`) on the requester
          // string, so one address could match another that contains it.
          final isRequestedByUser = requesterEmails.toLowerCase().trim() ==
              currentUserEmail.toLowerCase().trim();

          // ✅ Get provider and requester details for manager check
          final providerEmployee = mainCoreController.getLocaleEmployee(
            assignedEmail,
          );
          final requesterEmail = requesterEmails.isNotEmpty
              ? requesterEmails.toLowerCase().trim()
              : '';
          final requesterEmployee = requesterEmail.isNotEmpty
              ? mainCoreController.getLocaleEmployee(requesterEmail)
              : null;

          // ✅ Check if current user is Middle Management in relevant departments
          bool isMiddleManagementForService = false;
          String managerDepartment = '';

          final currentEmployee = mainCoreController.getLocaleEmployee(
            currentUserEmail,
          );
          if (currentEmployee != null &&
              currentEmployee.role?.toLowerCase() == 'middle management') {
            if (providerEmployee != null &&
                currentEmployee.departmentId == providerEmployee.departmentId) {
              isMiddleManagementForService = true;
              managerDepartment = currentEmployee.departmentId ?? '';
            } else if (requesterEmployee != null &&
                currentEmployee.departmentId ==
                    requesterEmployee.departmentId) {
              isMiddleManagementForService = true;
              managerDepartment = currentEmployee.departmentId ?? '';
            }
          }

          // Skip if not relevant to current user
          if (!isAssignedToUser &&
              !isRequestedByUser &&
              !isMiddleManagementForService) {
            continue;
          }

          // ✅ Get timestamps array
          final timestampsArray = data['timestamps'] as List?;
          if (timestampsArray == null || timestampsArray.isEmpty) {
            continue;
          }

          // ✅ Get status history array to find when it moved to InProgress
          final statusHistoryArray = data['status'] as List?;

          // ✅ STAGE 1: APPROVED - Add "Assigned" card (for provider only)
          if ([
            'approved',
            'inprogress',
            'branchsla',
            'done',
          ].contains(state.toLowerCase())) {
            if (isAssignedToUser) {
              final approvedTimestamp = timestampsArray.first;
              final eventDate = DateTime.fromMillisecondsSinceEpoch(
                approvedTimestamp is int
                    ? approvedTimestamp
                    : int.parse(approvedTimestamp.toString()),
              );

              events.add(
                CalendarEventModel.fromType(
                  ServicesCalendarEvent.assignedToProvider,
                  sourceDate: eventDate,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: DateFormat('hh:mm a').format(eventDate),
                ),
              );
            }
          }

          // ✅ STAGE 2: INPROGRESS — the start date and the SLA deadline
          //
          // Cards raised here: "Due" on the deadline (provider), and
          // "In Progress" on the actual start date for BOTH the requester and
          // — since 1/9/2026 — the provider, plus the SLA breach cards for
          // every party while the request is still open.
          // 22/10/2026: 'branchsla' is the app's own "Breached SLA" state — a
          // request that is still open past its deadline. It was ignored here,
          // so breached requests had no Assigned / Due / SLA card at all (the
          // "SLA 0" chip). It now follows the in-progress path.
          if (['inprogress', 'branchsla', 'done']
              .contains(state.toLowerCase())) {
            DateTime? dueDate;

            // The ACTUAL moment work started — the timestamp paired with the
            // first `InProgress` entry, falling back to the second timestamp
            // on documents written before the two arrays were kept in step.
            // CHANGED 1/9/2026 — this lookup was written out here and again in
            // STAGE 3, where the fallback was missing; both now call
            // [_inProgressStart].
            final DateTime? inProgressStartTime = _inProgressStart(
              statusHistory: statusHistoryArray,
              timestamps: timestampsArray,
            );

            if (inProgressStartTime != null) {
              // The SLA deadline runs from the moment work actually started.
              // CHANGED 1/9/2026 — this was thirty lines of inline duration
              // arithmetic, duplicated verbatim in STAGE 3 below. Both copies
              // are now one call to [_serviceDueDate], so the two stages can
              // no longer disagree about when a request was due.
              dueDate = _serviceDueDate(data: data, from: inProgressStartTime);

              // ✅ Add Due event for provider
              // 22/10/2026: only while the request is still open. For a done or
              // breached request "Complete it by then" is stale action text.
              if (isAssignedToUser &&
                  dueDate != null &&
                  state.toLowerCase() == 'inprogress') {
                final dueDateStr =
                    DateFormat('MMM dd, yyyy hh:mm a').format(dueDate);

                events.add(
                  CalendarEventModel.fromType(
                    ServicesCalendarEvent.dueForProvider,
                    sourceDate: dueDate,
                    isArabic: isArabic,
                    taskName: taskName,
                    time: DateFormat('hh:mm a').format(dueDate),
                    variables: {TemplateVariable.dueDate: dueDateStr},
                  ),
                );
              }

              // ✅ Add "In Progress" event for REQUESTER
              if (isRequestedByUser && dueDate != null) {
                final completionDateStr =
                    DateFormat('MMM dd, yyyy hh:mm a').format(dueDate);

                events.add(
                  CalendarEventModel.fromType(
                    ServicesCalendarEvent.inProgressForRequester,
                    sourceDate: inProgressStartTime,
                    isArabic: isArabic,
                    taskName: taskName,
                    time: DateFormat('hh:mm a').format(inProgressStartTime),
                    variables: {TemplateVariable.dueDate: completionDateStr},
                  ),
                );
              }

              // ✅ Add "In Progress" event for the PROVIDER
              //
              // ADDED 1/9/2026 — §2 "Service Status Changed to In Progress":
              // "The event records the actual start date."
              //
              // The provider is the person who MAKES that status change, and
              // they were the one party with no card on the day it happened.
              // The card immediately above gives the requester the start date;
              // the provider only had `dueForProvider`, which sits on the
              // DEADLINE. So the calendar could tell a provider when a job was
              // assigned and when it was due, but never when work on it began
              // — the one date the spec row is actually about.
              if (isAssignedToUser && dueDate != null) {
                final providerDueStr =
                    DateFormat('MMM dd, yyyy hh:mm a').format(dueDate);

                events.add(
                  CalendarEventModel.fromType(
                    ServicesCalendarEvent.inProgressForProvider,
                    sourceDate: inProgressStartTime,
                    isArabic: isArabic,
                    taskName: taskName,
                    time: DateFormat('hh:mm a').format(inProgressStartTime),
                    variables: {TemplateVariable.dueDate: providerDueStr},
                  ),
                );
              }

              // ✅ Check for SLA breach (only if InProgress)
              if ((state.toLowerCase() == 'inprogress' ||
                      state.toLowerCase() == 'branchsla') &&
                  dueDate != null) {
                if (state.toLowerCase() == 'branchsla' ||
                    now.isAfter(dueDate)) {
                  final period = dueDate.hour >= 12 ? 'PM' : 'AM';
                  final displayHour = dueDate.hour > 12
                      ? dueDate.hour - 12
                      : (dueDate.hour == 0 ? 12 : dueDate.hour);
                  final displayTime =
                      '${displayHour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')} $period';

                  // Add SLA card for provider
                  if (isAssignedToUser) {
                    events.add(
                      CalendarEventModel.fromType(
                        ServicesCalendarEvent.slaBreachedProvider,
                        sourceDate: dueDate,
                        isArabic: isArabic,
                        taskName: taskName,
                        time: displayTime,
                      ),
                    );
                  }

                  // Add SLA card for requester
                  if (isRequestedByUser) {
                    events.add(
                      CalendarEventModel.fromType(
                        ServicesCalendarEvent.slaBreachedRequester,
                        sourceDate: dueDate,
                        isArabic: isArabic,
                        taskName: taskName,
                        time: displayTime,
                      ),
                    );
                  }

                  // Add SLA card for middle management
                  if (isMiddleManagementForService &&
                      !isAssignedToUser &&
                      !isRequestedByUser) {
                    String departmentName = departmentController
                        .getDepartmentName(managerDepartment, true);
                    String departmentNameAr = departmentController
                        .getDepartmentName(managerDepartment, false);

                    events.add(
                      CalendarEventModel.fromType(
                        ServicesCalendarEvent.slaBreachedManagement,
                        sourceDate: dueDate,
                        isArabic: isArabic,
                        taskName: taskName,
                        time: displayTime,
                        variables: {
                          TemplateVariable.departmentName:
                              isArabic ? departmentNameAr : departmentName,
                        },
                      ),
                    );
                  }
                } else {}
              }
            }
          }

          // ✅ STAGE 3: DONE — completion cards for EVERY relevant party
          //
          // REWRITTEN 1/9/2026 — §2 of the revised spec, two rows:
          //
          //   "Service Completion Date Reached → Completion date reached; all
          //    relevant parties are notified simultaneously."
          //   "Service Status Changed to Done → Service Completed."
          //
          // This whole stage used to sit inside `if (isRequestedByUser)`, so
          // completion was a requester-only event. The provider who did the
          // work watched the request disappear from their calendar the moment
          // they closed it, and a middle manager saw completions not at all —
          // management appeared in this builder for exactly one thing, an SLA
          // breach, which made the calendar a list of that department's
          // failures with none of its deliveries.
          //
          // The SLA comparison is now computed once, above the audience
          // branches, instead of inside the requester branch. It also drove
          // thirty lines of duplicated duration arithmetic, which is now the
          // same [_serviceDueDate] helper STAGE 2 uses — the two stages could
          // previously disagree about when a request was due.
          if (state.toLowerCase() == 'done') {
            final doneTimestamp = timestampsArray.last;
            final eventDate = DateTime.fromMillisecondsSinceEpoch(
              doneTimestamp is int
                  ? doneTimestamp
                  : int.parse(doneTimestamp.toString()),
            );

            // Did it land after the SLA deadline? Needed by the requester's
            // wording, and by the retained breach record below.
            final DateTime? inProgressStart = _inProgressStart(
              statusHistory: statusHistoryArray,
              timestamps: timestampsArray,
            );
            final DateTime? slaDeadline = inProgressStart == null
                ? null
                : _serviceDueDate(data: data, from: inProgressStart);
            final bool exceededSLA =
                slaDeadline != null && eventDate.isAfter(slaDeadline);

            final String doneTime = DateFormat('hh:mm a').format(eventDate);

            // ── Requester ────────────────────────────────────────────────
            if (isRequestedByUser) {
              events.add(
                CalendarEventModel.fromType(
                  exceededSLA
                      ? ServicesCalendarEvent.doneAfterSlaForRequester
                      : ServicesCalendarEvent.doneForRequester,
                  sourceDate: eventDate,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: doneTime,
                ),
              );
            }

            // ── Provider ─────────────────────────────────────────────────
            if (isAssignedToUser) {
              events.add(
                CalendarEventModel.fromType(
                  ServicesCalendarEvent.doneForProvider,
                  sourceDate: eventDate,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: doneTime,
                ),
              );
            }

            // ── Middle management ────────────────────────────────────────
            //
            // Only when the manager is neither party, matching the guard the
            // SLA branch already uses — otherwise a manager who raised or
            // fulfilled the request themselves would get two cards for one
            // completion.
            if (isMiddleManagementForService &&
                !isAssignedToUser &&
                !isRequestedByUser) {
              final String departmentName = departmentController
                  .getDepartmentName(managerDepartment, true);
              final String departmentNameAr = departmentController
                  .getDepartmentName(managerDepartment, false);

              events.add(
                CalendarEventModel.fromType(
                  ServicesCalendarEvent.doneForManagement,
                  sourceDate: eventDate,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: doneTime,
                  variables: {
                    TemplateVariable.departmentName:
                        isArabic ? departmentNameAr : departmentName,
                  },
                ),
              );
            }

            // ── The breach itself, retained ──────────────────────────────
            //
            // ADDED 1/9/2026. §2 row 1 says an SLA breach is "Visible to
            // Manager, Service Provider, and Requester. Escalation action
            // recommended." The breach cards in STAGE 2 are gated on
            // `state == 'inprogress'`, so the moment the provider marked a
            // late request Done, every trace of the breach left the calendar
            // — for the provider and the manager, the two people escalation
            // is aimed at, it vanished entirely. Closing a ticket late is
            // exactly the case a manager needs to still be able to see.
            //
            // The requester is deliberately excluded: their
            // [doneAfterSlaForRequester] card above already says the deadline
            // was missed, and a second card would say it twice.
            if (exceededSLA) {
              final String breachTime =
                  DateFormat('hh:mm a').format(slaDeadline);

              if (isAssignedToUser) {
                events.add(
                  CalendarEventModel.fromType(
                    ServicesCalendarEvent.slaBreachedProvider,
                    sourceDate: slaDeadline,
                    isArabic: isArabic,
                    taskName: taskName,
                    time: breachTime,
                  ),
                );
              }

              if (isMiddleManagementForService &&
                  !isAssignedToUser &&
                  !isRequestedByUser) {
                final String departmentName = departmentController
                    .getDepartmentName(managerDepartment, true);
                final String departmentNameAr = departmentController
                    .getDepartmentName(managerDepartment, false);

                events.add(
                  CalendarEventModel.fromType(
                    ServicesCalendarEvent.slaBreachedManagement,
                    sourceDate: slaDeadline,
                    isArabic: isArabic,
                    taskName: taskName,
                    time: breachTime,
                    variables: {
                      TemplateVariable.departmentName:
                          isArabic ? departmentNameAr : departmentName,
                    },
                  ),
                );
              }
            }
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      debugPrint('Ignored error: $e');
    }

    return events;
  }

  /// Function Name: [_serviceDueDate]
  ///
  /// Purpose: The SLA deadline for a service request, measured from [from]
  /// using the request's own `durationOfServices` + `selectedDurationUnit`.
  ///
  /// ADDED 1/9/2026. This switch was written out twice inside
  /// [getServicesCalendarEvents] — once to place the provider's Due card and
  /// the breach cards, once to decide whether a completed request had
  /// overrun. Two copies of the same arithmetic deciding "was this late?" in
  /// two different places is a drift waiting to happen, and the completion
  /// branch is the one a manager relies on.
  ///
  /// Parameters:
  /// - [data]: the raw request document.
  /// - [from]: the point the clock starts — the in-progress timestamp.
  ///
  /// Returns: the deadline, or null when the request carries no usable
  /// duration (nothing recorded, unparseable, or zero) — callers treat that
  /// as "no SLA to breach" rather than as an immediate breach.
  DateTime? _serviceDueDate({
    required Map<String, dynamic> data,
    required DateTime from,
  }) {
    // 22/10/2026: stored requests use `Duration_Of_Services` /
    // `Selected_Duration_Unit`; only legacy documents use the camelCase names.
    // Reading only the camelCase ones found no duration, so no deadline was
    // ever built — no Due card and no SLA card (the "SLA 0" chip).
    final List? durationArray =
        (data['Duration_Of_Services'] ?? data['durationOfServices']) as List?;
    final List? durationUnitArray = (data['Selected_Duration_Unit'] ??
        data['selectedDurationUnit']) as List?;

    if (durationArray == null ||
        durationArray.isEmpty ||
        durationUnitArray == null ||
        durationUnitArray.isEmpty) {
      return null;
    }

    final int durationValue = int.tryParse(durationArray.first.toString()) ?? 0;
    if (durationValue <= 0) return null;

    switch (durationUnitArray.first.toString().toLowerCase()) {
      case 'minutes':
        return from.add(Duration(minutes: durationValue));
      case 'hours':
        return from.add(Duration(hours: durationValue));
      case 'days':
        return from.add(Duration(days: durationValue));
      case 'weeks':
        return from.add(Duration(days: durationValue * 7));
      case 'months':
        return DateTime(
          from.year,
          from.month + durationValue,
          from.day,
          from.hour,
          from.minute,
        );
      default:
        // Unrecognised unit — the original code fell back to hours rather
        // than dropping the deadline, and that is kept: a request with a
        // duration but a typo'd unit should still have an SLA.
        return from.add(Duration(hours: durationValue));
    }
  }
}
