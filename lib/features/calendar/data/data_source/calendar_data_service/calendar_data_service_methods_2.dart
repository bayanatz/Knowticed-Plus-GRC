/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_data_service_methods_2.dart
/// Description: Methods of `CalendarDataService` — split out of `calendar_data_service.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../calendar_data_service.dart';

// Split from calendar_data_service.dart to keep every file under 700 lines.

extension CalendarDataServiceMethods2 on CalendarDataService {
  // ══════════════════════════════════════════════════════════════════
  //  USER ACCESS
  //
  //  Source: `Employees_Info/{id}` - `Activation_Date` and
  //  `Deactivation_Date`, both plain strings (NOT history lists).
  //
  //  ✅ COMPLETED 1/9/2026 — all eight spec entries are emitted.
  //
  //  The four that were missing were both documented here as impossible, and
  //  both notes were out of date:
  //
  //    • accountLocked / accountUnlocked — this said `Status` "records the
  //      state but no timestamp, so there is no date to place a card on".
  //      `Status` is a history LIST, and
  //      `NewEmployeeModelHistory.copyWithUpdateSynchronized` appends to it
  //      and to the shared `timestamps` list in the same call. `Status[i]` has
  //      always been dated by `timestamps[i]` — the same parallel-array
  //      pairing the Knowledge Hub and Services builders already rely on.
  //
  //    • scheduledActivationDateUpdated / scheduledDeactivationDateUpdated —
  //      this said the wiring was "not done here yet only because the catalog
  //      entries' `variables` sets have to be matched at the call site". That
  //      was the whole job: the builder now has an `addWith` that passes
  //      variables, and the two entries declare the old/new date pair they
  //      interpolate. `UserAccessRepository._recordScheduleChange` has been
  //      stamping `<field>_Changed_At` and `<field>_Previous` since 26/8/2026
  //      expressly so these cards could exist.
  // ══════════════════════════════════════════════════════════════════
  Future<List<CalendarEventModel>> getUserAccessCalendarEvents({
    required String currentUserEmail,
  }) async {
    final events = <CalendarEventModel>[];
    if (currentUserEmail.isEmpty) return events;

    try {
      final currentLocale = languageCode();
      final isArabic = currentLocale == 'ar';

      // CHANGED 30/8/2026: was a full read of `Employees_Info` followed by a
      // Dart-side loop with a `break` on the first match — a whole-collection
      // download to reach one document, inside a source the cubit only allows
      // 12 seconds. See [_employeeDocForEmail].
      final doc = await CalendarDataService._employeeDocForEmail(
        currentUserEmail,
      );
      if (doc == null) return events;

      final data = doc.data();
      if (data == null) return events;

      final emails = CalendarDataService._historyList(data['Email']);
      final names = CalendarDataService._historyList(data['First_Name']);
      final displayName = names.isNotEmpty
          ? names.last
          : (emails.isNotEmpty ? emails.last : currentUserEmail);

      void addWith(
        UserAccessCalendarEvent type,
        DateTime source, {
        Map<TemplateVariable, String> variables = const {},
      }) {
        events.add(
          CalendarEventModel.fromType(
            type,
            sourceDate: source,
            isArabic: isArabic,
            taskName: displayName,
            time: DateFormat('hh:mm a').format(source),
            userEmail: currentUserEmail,
            // The one builder whose taskName IS a person: `displayName` here is
            // the employee's first name, which the card upgrades to the full
            // name. See CalendarEventModel.titleIsPersonName.
            titleIsPersonName: true,
            variables: variables,
          ),
        );
      }

      void add(UserAccessCalendarEvent type, DateTime source) =>
          addWith(type, source);

      final now = DateTime.now();

      final activation = CalendarDataService._parseAccessDate(
        data['Activation_Date']?.toString(),
      );
      if (activation != null) {
        add(UserAccessCalendarEvent.accountActivationToday, activation);
        if (activation.isAfter(now)) {
          add(UserAccessCalendarEvent.accountActivationIn14Days, activation);
        }
      }

      final deactivation = CalendarDataService._parseAccessDate(
        data['Deactivation_Date']?.toString(),
      );
      if (deactivation != null) {
        add(UserAccessCalendarEvent.accountDeactivationToday, deactivation);
        if (deactivation.isAfter(now)) {
          add(
            UserAccessCalendarEvent.accountDeactivationIn14Days,
            deactivation,
          );
        }
      }

      // ── Locked / unlocked ────────────────────────────────────────────
      //
      // ADDED 1/9/2026 — §2 "Account Locked" and "Account Unlocked".
      //
      // The comment that used to head this method said `Status` "records the
      // state but no timestamp, so there is no date to place a card on", and
      // on that basis two spec rows were left unbuilt. It was wrong.
      // `Status` is a history LIST, and
      // `NewEmployeeModelHistory.copyWithUpdateSynchronized` appends to it and
      // to the shared `timestamps` list in one call — that is what
      // "synchronized" means in its name. `Status[i]` is dated by
      // `timestamps[i]`, exactly as the Knowledge Hub and Services builders
      // already read their own parallel arrays.
      final List<String> statuses = CalendarDataService._historyList(
        data['Status'],
      ).map((String s) => s.toLowerCase().trim()).toList();
      final List<dynamic> statusTimestamps =
          (data['timestamps'] as List?) ?? const <dynamic>[];

      DateTime? statusDateAt(int index) {
        if (index < 0 || index >= statusTimestamps.length) return null;
        final dynamic raw = statusTimestamps[index];
        final int? ms = raw is int ? raw : int.tryParse(raw.toString());
        return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
      }

      // Both spellings, for the reason `UserAccessRepository` documents: the
      // camel-case enum name is not what earlier builds wrote.
      bool isLocked(String status) =>
          status == 'locked' ||
          status == 'lockedwithrequest' ||
          status == 'locked with send request';

      // Only the most recent of each. `Status` holds every status change for
      // the life of the account; one card per historical lock would bury the
      // current state under years of churn. System Logs keeps the full run.
      int lastLock = -1;
      int lastUnlock = -1;
      for (int i = 0; i < statuses.length; i++) {
        if (isLocked(statuses[i])) {
          lastLock = i;
        } else if (statuses[i] == 'active' &&
            i > 0 &&
            isLocked(statuses[i - 1])) {
          // An unlock is a TRANSITION, not a status of its own: `active`
          // preceded by a locked state. Plain `active` with no lock behind it
          // is an ordinary activation and belongs to
          // [accountActivationToday], not here.
          lastUnlock = i;
        }
      }

      final DateTime? lockedAt = lastLock == -1 ? null : statusDateAt(lastLock);
      if (lockedAt != null) {
        add(UserAccessCalendarEvent.accountLocked, lockedAt);
      }

      final DateTime? unlockedAt =
          lastUnlock == -1 ? null : statusDateAt(lastUnlock);
      if (unlockedAt != null) {
        add(UserAccessCalendarEvent.accountUnlocked, unlockedAt);
      }

      // ── Rescheduled activation / deactivation ────────────────────────
      //
      // ADDED 1/9/2026 — §2 "Scheduled Activation Date Updated" and
      // "Scheduled Deactivation Date Updated".
      //
      // The old note said a change to these fields "cannot be detected"
      // because they are plain strings with no history. That stopped being
      // true on 26/8/2026, when `UserAccessRepository._recordScheduleChange`
      // started stamping `<field>_Changed_At` and `<field>_Previous` on the
      // edit branch of each scheduler — a method whose own doc comment says it
      // exists "so the calendar has a date to hang its '… Date Updated' card
      // on". The stamp shipped; the card never did. This is it.
      void addRescheduled({
        required String changedAtField,
        required String previousField,
        required String currentField,
        required UserAccessCalendarEvent type,
        required TemplateVariable oldVariable,
        required TemplateVariable newVariable,
      }) {
        final dynamic rawChangedAt = data[changedAtField];
        if (rawChangedAt == null) return;
        final int? changedMs = rawChangedAt is int
            ? rawChangedAt
            : int.tryParse(rawChangedAt.toString());
        if (changedMs == null) return;

        // The stored strings are already in the display format the schedulers
        // write ("MMM dd, yyyy"), so they are shown verbatim. An em dash
        // rather than an empty string when a side is missing: "changed from
        //  to Sep 20, 2026" reads like a rendering fault.
        final String previous = (data[previousField]?.toString().trim() ?? '');
        final String current = (data[currentField]?.toString().trim() ?? '');

        addWith(
          type,
          DateTime.fromMillisecondsSinceEpoch(changedMs),
          variables: <TemplateVariable, String>{
            oldVariable: previous.isEmpty ? '—' : previous,
            newVariable: current.isEmpty ? '—' : current,
          },
        );
      }

      addRescheduled(
        changedAtField: 'Activation_Date_Changed_At',
        previousField: 'Activation_Date_Previous',
        currentField: 'Activation_Date',
        type: UserAccessCalendarEvent.scheduledActivationDateUpdated,
        oldVariable: TemplateVariable.oldActivationDate,
        newVariable: TemplateVariable.newActivationDate,
      );

      addRescheduled(
        changedAtField: 'Deactivation_Date_Changed_At',
        previousField: 'Deactivation_Date_Previous',
        currentField: 'Deactivation_Date',
        type: UserAccessCalendarEvent.scheduledDeactivationDateUpdated,
        oldVariable: TemplateVariable.oldDeactivationDate,
        newVariable: TemplateVariable.newDeactivationDate,
      );
    } catch (e) {
      // WAS `catch (e) {}` — see the note on the role-management builder.
    }
    return events;
  }

  Future<List<CalendarEventModel>> getSettingsCalendarEvents({
    required String currentUserEmail,
  }) async {
    final events = <CalendarEventModel>[];
    if (currentUserEmail.isEmpty) return events;

    try {
      final bool isArabic = languageCode() == 'ar';
      final String myEmail = currentUserEmail.toLowerCase().trim();

      // Whether the signed-in user reviews requests. This is the one permission
      // question the local check can answer — it is about the current user — so
      // it uses MainCoreEmployeeController rather than the directory-wide
      // lookup the notification fan-out needs.
      final bool isReviewer = currentEmployee().isHasPermission(
        module: Modules.roles,
        section: RolePermissionsSections.userManagement,
        permission: UserManagement.usersRequests,
      );

      final snapshot = await _firestore
          .doc(RequestCollectionPaths.rolesDoc)
          .collection(RequestCollectionPaths.requestsCollection)
          .orderBy(ChangeRequestMapper.keyRequestDate, descending: true)
          .limit(CalendarDataService._settingsRequestScanLimit)
          .get()
          .timeout(const Duration(seconds: 15));

      if (snapshot.docs.length ==
          CalendarDataService._settingsRequestScanLimit) {}

      for (final doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();

        // Parsed through the shared mapper rather than by hand: it already
        // tolerates the several shapes `requestDate` has been written in, and
        // it is the same reading the request screens use.
        final ChangeRequest request = ChangeRequestMapper.fromDocument(
          doc.id,
          data,
        );

        final DateTime? requestDate = request.requestDate;
        if (requestDate == null) continue;

        final bool isMine =
            request.employeeEmail.toLowerCase().trim() == myEmail;

        // Nothing to draw for a request that is neither mine nor mine to
        // review — skip before doing any more work on it.
        // 9/10/2026: `isMine` requests are never review cards (see above).
        if (!isMine && !(isReviewer && request.status.isPending)) continue;

        final DateTime decidedOn = CalendarDataService._settingsDecisionDate(
              data[ChangeRequestMapper.keyUpdatedAt],
            ) ??
            requestDate;

        void add(
          SettingsCalendarEvent type,
          DateTime source, {
          Map<TemplateVariable, String> variables =
              const <TemplateVariable, String>{},
        }) {
          events.add(
            CalendarEventModel.fromType(
              type,
              sourceDate: source,
              isArabic: isArabic,
              // The section is the card's subject — `Personal Information`,
              // `Health Insurance`, `Emergency Contact`.
              taskName: request.section,
              time: DateFormat('hh:mm a').format(source),
              variables: variables,
              requestId: doc.id,
              userEmail: request.employeeEmail,
            ),
          );
        }

        if (request.status.isPending) {
          // 9/10/2026 — `&& !isMine`: no review card for your own request.
          if (isReviewer && !isMine) {
            add(
              SettingsCalendarEvent.changeRequestPendingReview,
              requestDate,
              variables: <TemplateVariable, String>{
                // Falls back to the address on a document written before
                // `employeeName` existed, so the sentence never opens with a
                // blank.
                // Title-cased: names are stored lower-case ("demo company").
                TemplateVariable.employeeName: request.employeeName.isNotEmpty
                    ? request.employeeName
                        .split(' ')
                        .map(
                          (String w) => w.isEmpty
                              ? w
                              : '${w[0].toUpperCase()}${w.substring(1)}',
                        )
                        .join(' ')
                    : request.employeeEmail,
                // The section the request changes — "Personal Information",
                // "Health Insurance", "Emergency Contact".
                TemplateVariable.documentName: request.section,
              },
            );
          }
          if (isMine) {
            add(SettingsCalendarEvent.changeRequestSubmitted, requestDate);
          }
          continue;
        }

        // Past this point the request is decided. The outcome belongs to the
        // person who asked; a reviewer's calendar is a queue of work, and work
        // that is done is not on it.
        if (!isMine) continue;

        if (request.status == RequestStatus.approved) {
          add(SettingsCalendarEvent.changeRequestApproved, decidedOn);
        } else if (request.status == RequestStatus.rejected) {
          add(SettingsCalendarEvent.changeRequestRejected, decidedOn);
        }
        // Cancelled draws nothing: it is the employee's own doing and the
        // catalog has no entry for it, matching the notification side.
      }
    } catch (e) {
      // Consistent with every other builder here: one source failing must not
      // empty the calendar. CalendarCubit records the failure by name.
    }
    return events;
  }
}
