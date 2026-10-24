/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_data_service_methods.dart
/// Description: Methods of `CalendarDataService` — split out of `calendar_data_service.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../calendar_data_service.dart';

// Split from calendar_data_service.dart to keep every file under 700 lines.

extension CalendarDataServiceMethods on CalendarDataService {
  Future<List<CalendarEventModel>> getApprovalCalendarEvents({
    required String currentUserEmail,
  }) async {
    List<CalendarEventModel> events = [];

    try {
      // The hand-rolled companyId extraction that stood here
      // (`getBaseUrl('').split('/')[1]`) is gone with the path fix below —
      // `getBaseUrl` already prefixes the tenant, so nothing needs to take it
      // apart.

      // ✅ Get current locale to determine language
      final currentLocale = languageCode();
      final isArabic = currentLocale == 'ar';

      try {
        // ⚠️ FIXED 30/8/2026 — THE COLLECTION PATH WAS WRONG, and this alone
        // is why the Services module never put a single card on the calendar.
        //
        // This built `Demo/<companyId>/RequestServices`. Service requests are
        // not stored there. Every writer and reader in the Services module
        // itself goes through
        // `getBaseUrl(FirestoreCollections.requestServicesRoot)`, which is
        // `Modules/services/RequestServices` — so the real collection is
        // `Demo/<companyId>/Modules/services/RequestServices`, confirmed
        // against the module's own log line:
        //
        //     getMyRequestServices → path=Demo/75440689/Modules/services/
        //     RequestServices → 10 docs
        //
        // The path this used resolves to an empty collection: no error, no
        // exception, `docs` simply empty, and the `isEmpty` guard below
        // returned an empty list. Nothing anywhere reported a problem.
        //
        // Built from the shared constant rather than reassembled here, so the
        // calendar cannot drift from the module again.
        final exactPath = _firestore.collection(
          getBaseUrl(FirestoreCollections.requestServicesRoot),
        );

        final requestsSnapshot = await exactPath.get().timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Approval query timeout after 15 seconds');
          },
        );

        if (requestsSnapshot.docs.isEmpty) {
          return events;
        }

        for (var requestDoc in requestsSnapshot.docs) {
          try {
            final data = requestDoc.data();
            final requestId = requestDoc.id;

            // ✅ Get service name
            String? serviceNameEnglish = _getArrayValue(
              data['serviceNameEnglish'],
            );
            String? serviceNameArabic = _getArrayValue(
              data['serviceNameArabic'],
            );

            // Fallback to alternative fields
            if (serviceNameEnglish == null ||
                serviceNameEnglish.isEmpty ||
                serviceNameEnglish.toLowerCase() == 'approval') {
              serviceNameEnglish =
                  _getArrayValue(data['currentServiceNameEnglish']) ??
                      'Service Request';
            }

            if (serviceNameArabic == null ||
                serviceNameArabic.isEmpty ||
                serviceNameArabic == 'موافقة') {
              serviceNameArabic =
                  _getArrayValue(data['currentServiceNameArabic']) ??
                      'طلب خدمة';
            }

            final taskName = isArabic ? serviceNameArabic : serviceNameEnglish;

            // Parse approval cycle.
            //
            // FIXED: read the canonical `Approval_Cycle` key.
            // Request documents store the cycle under `Approval_Cycle`
            // (ServicesHistoryModel.kApprovalCycle = 'Approval_Cycle'); this
            // read the lowercase `approvalCycle`, which never exists, so
            // `approvalCycleRaw` was always null, the parsed cycle stayed
            // empty, and every request was skipped by the `isEmpty` guard
            // below — no approver ever saw a "Pending Approval" (or approved /
            // rejected) entry on their calendar. Falls back to the lowercase
            // key for any legacy document that used it.
            // ⚠️ FIXED 30/8/2026 — this is why approving or rejecting a
            // request never changed anything on the calendar.
            //
            // `Approval_Cycle` is a REVISION HISTORY, not a cycle.
            // `ServicesHistoryModel.updateApprovalCycle` appends a whole new
            // JSON-encoded cycle every time a decision is taken, and
            // `ServicesHistoryModel.currentApprovalCycle` reads `.last`. The
            // loop that stood here decoded EVERY revision and flattened them
            // into one list, so after a single approval the list held the same
            // approvers twice — the original revision (everyone `pending`)
            // first, the decided revision second. `indexWhere` returns the
            // FIRST match, so `myState` was read out of the OLDEST revision
            // and stayed 'pending' forever: CASE 2 (approved) and CASE 3
            // (rejected) below could never fire, no matter how many times the
            // request was decided. The `timestampsArray[myIndex]` lookups were
            // wrong for the same reason — a cross-revision position indexed
            // into an unrelated array.
            //
            // Only the last revision is the live cycle, so only the last
            // revision is decoded.
            final approvalCycleRaw =
                data['Approval_Cycle'] ?? data['approvalCycle'];
            final List<Map<String, String>> approvalCycle =
                CalendarDataService._decodeCurrentApprovalCycle(
              approvalCycleRaw,
            );

            if (approvalCycle.isEmpty) {
              continue;
            }

            // Get timestamps
            final timestampsArray = data['timestamps'] as List?;
            if (timestampsArray == null || timestampsArray.isEmpty) {
              continue;
            }

            // ── Dates ────────────────────────────────────────────────────
            //
            // `timestamps` is appended to by EVERY mutation of the document
            // (status, provider list, department, approval cycle), so no index
            // into it maps to "my step in the cycle". The two ENDS are
            // meaningful and the middle is not: the first entry is when the
            // request was raised, the last is when it was most recently acted
            // on — which, for a request whose cycle has just been decided, is
            // that decision.
            final DateTime submittedAt = CalendarDataService._epochMs(
              timestampsArray.first,
            );
            final DateTime lastActionAt = CalendarDataService._epochMs(
              timestampsArray.last,
            );

            final List<String> requesterEmails =
                CalendarDataService._historyList(data['Email_Requester'])
                    .where((String e) => e.trim().isNotEmpty)
                    .toList();
            final String requesterEmail = requesterEmails.isEmpty
                ? ''
                : requesterEmails.last.trim().toLowerCase();
            final bool isRequester = requesterEmail.isNotEmpty &&
                requesterEmail == currentUserEmail.trim().toLowerCase();

            // Check if user is in approval cycle
            final myIndex = approvalCycle.indexWhere(
              (e) => e['email'] == currentUserEmail.trim().toLowerCase(),
            );

            if (myIndex == -1 && !isRequester) {
              continue;
            }

            final String myState =
                myIndex == -1 ? '' : (approvalCycle[myIndex]['state'] ?? '');

            // ── APPROVER'S OWN STEP ──────────────────────────────────────
            if (myIndex != -1) {
              // ✅ CASE 1: Pending Approval (show if currently pending)
              if (<String>['pending', 'normal', ''].contains(myState)) {
                final isMyTurn = _isMyTurnToApprove(
                  approvalCycle: approvalCycle,
                  currentUserEmail: currentUserEmail,
                  myIndex: myIndex,
                );

                if (isMyTurn) {
                  events.add(
                    CalendarEventModel.fromType(
                      ServicesCalendarEvent.pendingApproval,
                      sourceDate: submittedAt,
                      isArabic: isArabic,
                      taskName: taskName,
                      time: DateFormat('hh:mm a').format(submittedAt),
                      requestId: requestId,
                      userEmail: currentUserEmail,
                    ),
                  );
                }
              }

              // ✅ CASE 2: Approved (always show, even after approval)
              if (myState == 'approved') {
                events.add(
                  CalendarEventModel.fromType(
                    ServicesCalendarEvent.approvalApproved,
                    sourceDate: lastActionAt,
                    isArabic: isArabic,
                    taskName: taskName,
                    time: DateFormat('hh:mm a').format(lastActionAt),
                    requestId: requestId,
                    userEmail: currentUserEmail,
                  ),
                );
              }

              // ✅ CASE 3: Rejected (always show)
              if (myState == 'rejected') {
                events.add(
                  CalendarEventModel.fromType(
                    ServicesCalendarEvent.approvalRejected,
                    sourceDate: lastActionAt,
                    isArabic: isArabic,
                    taskName: taskName,
                    time: DateFormat('hh:mm a').format(lastActionAt),
                    requestId: requestId,
                    userEmail: currentUserEmail,
                  ),
                );
              }
            }

            // ── THE REQUESTER'S OWN REQUEST ──────────────────────────────
            //
            // ADDED 30/8/2026. Every branch above is keyed on the signed-in
            // user being IN the approval cycle, and the loop `continue`d when
            // they were not — so the person who RAISED the request saw
            // nothing on their calendar at any point: not while it waited, not
            // when it was approved, not when it was rejected. The Services
            // builder does not cover the gap either; it starts at
            // `assignedToProvider` (provider only) and its requester cards
            // need a duration and an InProgress status, so a request that is
            // still in, or was refused by, the approval cycle produces no
            // calendar entry for its own author.
            //
            // The outcome is read from the live cycle as a whole, the same
            // rule `_getFinalStateFromModel` applies: any rejection decides
            // the request, otherwise it is approved only once every step has
            // approved.
            if (isRequester) {
              final List<String> states = approvalCycle
                  .map((Map<String, String> e) => e['state'] ?? '')
                  .toList();

              final bool anyRejected = states.contains('rejected');
              final bool allApproved = states.isNotEmpty &&
                  states.every((String state) => state == 'approved');

              if (anyRejected) {
                events.add(
                  CalendarEventModel.fromType(
                    ServicesCalendarEvent.approvalRejected,
                    sourceDate: lastActionAt,
                    isArabic: isArabic,
                    taskName: taskName,
                    time: DateFormat('hh:mm a').format(lastActionAt),
                    requestId: requestId,
                    userEmail: currentUserEmail,
                  ),
                );
              } else if (allApproved) {
                events.add(
                  CalendarEventModel.fromType(
                    ServicesCalendarEvent.approvalApproved,
                    sourceDate: lastActionAt,
                    isArabic: isArabic,
                    taskName: taskName,
                    time: DateFormat('hh:mm a').format(lastActionAt),
                    requestId: requestId,
                    userEmail: currentUserEmail,
                  ),
                );
              } else {
                // Still moving through the cycle: the requester gets the
                // submission itself, dated when they raised it, so an
                // outstanding request is visible to the person waiting on it.
                events.add(
                  CalendarEventModel.fromType(
                    ServicesCalendarEvent.pendingApproval,
                    sourceDate: submittedAt,
                    isArabic: isArabic,
                    taskName: taskName,
                    time: DateFormat('hh:mm a').format(submittedAt),
                    requestId: requestId,
                    userEmail: currentUserEmail,
                  ),
                );
              }
            }
          } catch (e) {
            debugPrint('Ignored error: $e');
          }
        }
      } catch (timeoutError) {
        return events;
      }
    } catch (e) {
      debugPrint('Ignored error: $e');
    }

    return events;
  }

  Future<List<CalendarEventModel>> getRoleManagementCalendarEvents({
    required String currentUserEmail,
  }) async {
    final events = <CalendarEventModel>[];

    // ── WHY THIS BUILDER LOGS AT ALL ─────────────────────────────────────
    //
    // ADDED 1/9/2026, answering "the role calendar doesn't work".
    //
    // Every branch below ends in a bare `return events`, and there are SIX of
    // them: no signed-in email, no directory record, no permission document,
    // null data, no role, and — the quiet one — a role whose From_Date and
    // To_Date are both unparseable. All six produce an identical, correct,
    // completely silent empty list. From the calendar all six look the same as
    // "this module is broken", and none of them could be told apart from the
    // outside.
    //
    // Nothing about the logic changed here; each exit just says which gate it
    // was. One run with the debug console open now names the cause instead of
    // leaving it to be guessed at.
    //
    // Worth knowing before reading a log: all seven §2 Role Management rows
    // hang off {AccessGrantedDate} or {AccessRevokedDate}. A role held with no
    // dates set produces no cards AND no error — that is the spec working as
    // written, not a fault. Equally, a role granted last year puts its single
    // `accessGrantedImmediate` card on last year's date, so an empty CURRENT
    // month is not the same thing as an empty source. The summary line at the
    // end prints the dates the cards were placed on for exactly that reason.
    if (currentUserEmail.isEmpty) {
      return events;
    }

    try {
      final currentLocale = languageCode();
      final isArabic = currentLocale == 'ar';

      // The permission document is keyed by employee id, so resolve the id
      // for the signed-in email first. See [_employeeDocForEmail] for why this
      // is a query and not a scan.
      final employeeDoc = await CalendarDataService._employeeDocForEmail(
        currentUserEmail,
      );
      if (employeeDoc == null) {
        return events;
      }
      final String employeeId = employeeDoc.id;

      final permissionDoc = await FirebaseFirestore.instance
          .collection(getBaseUrl('User_Management'))
          .doc(employeeId)
          .get()
          .timeout(CalendarDataService._employeeLookupTimeout);

      if (!permissionDoc.exists) {
        return events;
      }
      final data = permissionDoc.data();
      if (data == null) {
        return events;
      }

      final roles = CalendarDataService._historyList(data['Role']);
      final fromDates = CalendarDataService._historyList(data['From_Date']);
      final toDates = CalendarDataService._historyList(data['To_Date']);
      if (roles.isEmpty) {
        return events;
      }

      final roleName = roles.last;
      final from = CalendarDataService._parseAccessDate(
        fromDates.isNotEmpty ? fromDates.last : '',
      );
      final to = CalendarDataService._parseAccessDate(
        toDates.isNotEmpty ? toDates.last : '',
      );

      if (from == null && to == null) {
        // The quiet one. Both dates missing is normal (a role granted with no
        // window); both dates PRESENT but unparseable is a data problem, and
        // the two are indistinguishable without seeing the raw strings — so
        // the raw strings are what gets printed.
        fromDates.isEmpty ? '(none)' : '"${fromDates.last}"';
        toDates.isEmpty ? '(none)' : '"${toDates.last}"';
        return events;
      }

      void add(RoleManagementCalendarEvent type, DateTime source) {
        events.add(
          CalendarEventModel.fromType(
            type,
            sourceDate: source,
            isArabic: isArabic,
            taskName: roleName,
            time: DateFormat('hh:mm a').format(source),
            userEmail: currentUserEmail,
            variables: {
              TemplateVariable.accessGrantedDate:
                  DateTimeHelper.formatDateTimeMMMDDYYYY(from),
              TemplateVariable.accessRevokedDate:
                  DateTimeHelper.formatDateTimeMMMDDYYYY(to),
            },
          ),
        );
      }

      final DateTime now = DateTime.now();

      if (from != null) {
        // ── The access window opens ──────────────────────────────────────
        //
        // FIXED 30/8/2026. `accessGrantedImmediate` and `accessStartsToday`
        // were BOTH added unconditionally, on the same `from` date — so every
        // user with a role saw two cards saying the same thing on the same
        // day. The spec separates them by how the access was granted:
        //
        //   "Access Granted (Immediate)"  — access is live now; the entry is
        //                                   created the moment it is granted.
        //   "Access Starts Today"         — a SCHEDULED start date has been
        //                                   reached and the access becomes
        //                                   active today.
        //
        // so they are mutually exclusive, and only one can be true of a given
        // start date. A future start date is neither yet: it is the scheduled
        // reminder, and nothing else.
        final bool startsInFuture = from.isAfter(now);
        final bool startsToday = CalendarDataService._isSameDay(from, now);

        if (startsInFuture) {
          // Only the advance reminder. The enum applies the -14 day offset
          // itself (`CalendarEventTypeX.dateFor`), so the source date passed
          // here is the start date, not the reminder date.
          add(
            RoleManagementCalendarEvent.accessScheduled14DaysBeforeStart,
            from,
          );
        } else if (startsToday) {
          add(RoleManagementCalendarEvent.accessStartsToday, from);
        } else {
          add(RoleManagementCalendarEvent.accessGrantedImmediate, from);
        }

        // More than one entry means the start date was moved.
        if (fromDates.length > 1 &&
            fromDates.last != fromDates[fromDates.length - 2]) {
          add(RoleManagementCalendarEvent.accessGrantedDateUpdated, from);
        }
      }

      if (to != null) {
        // The expiry reminder is an ADVANCE warning — it says "expiring
        // soon", so it is meaningless once the date has passed. The expiry
        // itself always lands.
        if (to.isAfter(now)) {
          add(RoleManagementCalendarEvent.accessExpiringIn14Days, to);
        }
        add(RoleManagementCalendarEvent.accessRevokedExpiryDateReached, to);
        if (toDates.length > 1 && toDates.last != toDates[toDates.length - 2]) {
          add(RoleManagementCalendarEvent.accessRevokedDateUpdated, to);
        }
      }

      // What actually got built, and WHERE. The dates matter as much as the
      // count: these entries are placed on the access dates themselves, so a
      // role granted a year ago puts its card a year back and the current
      // month is legitimately empty. A non-zero count here with nothing on
      // screen means the cards are outside the month being viewed — a
      // different problem from this source returning nothing.
      final List<String> placed = <String>[];
      for (final CalendarEventModel event in events) {
        final String key = event.type?.key ?? event.status;
        placed.add('$key@${DateFormat('yyyy-MM-dd').format(event.date)}');
      }
    } catch (e) {
      // WAS `catch (e) {}`. An empty catch here is why this builder could
      // return an empty list for months without anyone being able to tell an
      // employee with no role apart from a query that threw.
    }
    return events;
  }
}
