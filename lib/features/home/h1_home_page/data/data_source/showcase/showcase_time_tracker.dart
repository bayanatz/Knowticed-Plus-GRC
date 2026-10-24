// [module-file:time_tracker] — deleted when the time_tracker module is split out
/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_time_tracker.dart
/// Purpose: Showcase Time Tracker data for the whole year (1 Jan → today):
///          attendance days of a nine-person team (present, late with
///          minutes, absent, vacation, sick leave, excused, corrected by a
///          transaction, breaks, pauses, alerts, an automatic check-out),
///          leave requests, business missions, workshop permissions and
///          attendance transactions in EVERY status (pending at the manager,
///          pending at HR, approved, rejected, canceled, canceled by HR, under
///          review) with comment threads, the request types, locations,
///          group, assignments and the yearly vacation balances.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// This module is attendance + requests (there are no projects or
/// timesheets), so the year charts are attendance hours, lateness, leave and
/// requests per month.
///
/// Built with the module's OWN rules and models — `ApprovalRouter`,
/// `RequestCycleRules`, `AttendanceCalculator`, `VacationBalanceRules`, the
/// `*Model.row` encoders and `TimeTrackerHistoryCodec` — so every stored value
/// is what the app itself would have written. Dates are back-dated in the
/// audit fields.
///
/// Safe to run again and never replaces real data:
/// - requests, comments, locations, group and request types carry fixed
///   `showcase_` ids (overwritten by a re-run);
/// - a request type or location that already exists under the same name is
///   REUSED instead of duplicated;
/// - documents whose id the schema fixes (`Attendance/{email}_{date}`,
///   `Vacation_Balances/{email}_{year}`, `Location_Assignments/{email}`) are
///   written only when absent, and carry the extra history field
///   `Is_Showcase`;
/// - with the HR module the locations belong to HR: the real ones are used and
///   nothing is created for them. No attachments are uploaded.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/company_modules_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/employee_directory_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/hr_work_setup_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/attendance_day_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/employee_group_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/location_assignment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/request_comment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/request_type_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_request_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/vacation_balance_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/employee_directory_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/hr_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/org_chart_manager_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/company_modules_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_plan.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_setup.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_texts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/approval_router.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_calculator.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_rules.dart';
import 'package:knowticed_plus/features/time_tracker/helpers/constants/time_tracker_firestore_paths.dart';

/// What happens to a request after it is submitted.
enum _Fate {
  pending,
  pendingHr,
  approved,
  rejected,
  canceled,
  canceledByHr,
  underReview
}

/// The request types of the showcase (keys of [ShowcaseTimeTracker._types]).
enum _Type { annual, sick, mission, workshop, emergency }

/// One request ready to be written.
class _Req {
  const _Req({
    required this.request,
    required this.submittedAt,
    required this.lastAt,
    required this.actor,
    this.comments = const <RequestComment>[],
  });

  final TimeTrackerRequest request;
  final DateTime submittedAt;

  /// When the last action (decision, cancellation…) happened.
  final DateTime lastAt;

  /// Who did the last action.
  final String actor;
  final List<RequestComment> comments;
}

/// One document to write.
class _Doc {
  const _Doc(this.path, this.id, this.data);

  final String path;
  final String id;
  final Map<String, dynamic> data;
}

/// The work set-up the showcase uses (real locations, or its own).
class _Setup {
  _Setup(this.team, this.locations);

  final List<TimeTrackerEmployee> team;
  final List<WorkLocation> locations;

  WorkLocation get main => locations.first;
  WorkLocation get second =>
      locations.length > 1 ? locations[1] : locations.first;

  late final List<String> _departments = <String>{
    for (final TimeTrackerEmployee e in team)
      if (e.departmentId.isNotEmpty) e.departmentId,
  }.toList();

  /// The second department works at the second location, everyone else at
  /// the first.
  WorkLocation locationOf(TimeTrackerEmployee e) =>
      _departments.indexOf(e.departmentId) == 1 ? second : main;

  /// A schedule with a known working week (Sunday–Thursday when the
  /// location does not say which days are working days).
  WorkSchedule scheduleOf(TimeTrackerEmployee e) {
    final WorkSchedule s = locationOf(e).schedule;
    return s.workingDays.length >= 7
        ? s.withWorkingDays(WorkSchedule.sundayToThursday)
        : s;
  }
}

abstract final class ShowcaseTimeTracker {
  /// Tags every history row of a document this seed wrote.
  static const String _tag = 'Is_Showcase';

  /// People in the team (the signed-in user and up to eight colleagues).
  static const int _teamSize = 9;

  static const TtDemoText _txRejected = TtDemoText(
    'The check-out time does not match the building access log. Please attach the supporting record.',
    'وقت الانصراف لا يطابق سجل الدخول للمبنى، يرجى إرفاق السجل المؤيد.',
  );

  // ── Seed ──────────────────────────────────────────────────────────────────

  /// Function Name: [seed]
  ///
  /// Purpose: Writes the showcase Time Tracker data; returns how many
  /// documents were written.
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required bool isArabic,
    required DateTime now,
  }) async {
    final TimeTrackerRemoteDataSource remote =
        TimeTrackerRemoteDataSource(firestore: firestore);
    await remote.ensureModuleDocument();
    final String actor = me.email.trim().toLowerCase();

    // ── Work set-up and people ──
    final WorkSetupSourceResolver resolver = WorkSetupSourceResolver(
      companyModules: CompanyModulesService(
          dataSource: CompanyModulesRemoteDataSource(firestore: firestore)),
      timeTrackerSource: TimeTrackerWorkSetupSource(remoteDataSource: remote),
      hrSource: HrWorkSetupSource(
          remoteDataSource: HrWorkSetupRemoteDataSource(firestore: firestore)),
    );
    final bool hasHr = await resolver.hasHrModule();
    final WorkSetupSource source = await resolver.resolve();
    final List<WorkLocation> existing = <WorkLocation>[
      for (final WorkLocation l in await source.loadLocations())
        if (l.status == LocationStatus.active) l,
    ];
    final bool createsLocations = !hasHr && existing.length < 2;
    final DateTime setupAt = DateTime(now.year, 1, 4, 9);
    final List<WorkLocation> locations = createsLocations
        ? <WorkLocation>[
            for (int i = 0; i < TtDemoSetup.demoLocations.length; i++)
              TtDemoSetup.demoLocations[i]
                  .copyWith(id: ShowcaseCommon.id('tt_location', i + 1)),
          ]
        : (existing.isEmpty ? TtDemoSetup.demoLocations : existing);

    final List<TimeTrackerEmployee> team = await _team(me, isArabic: isArabic);
    final _Setup setup = _Setup(team, locations);
    final Map<String, String> managerOf = await _managers(firestore, team);

    // ── Request types: reuse a type that exists under the same name ──
    final List<RequestType> existingTypes = <RequestType>[];
    for (final TimeTrackerDocument d in await remote
        .fetchCollection(TimeTrackerFirestorePaths.requestTypes)) {
      try {
        existingTypes.add(RequestTypeModel.fromMap(d.id, d.data));
      } catch (_) {
        continue;
      }
    }
    final Map<_Type, RequestType> types = <_Type, RequestType>{};
    final List<RequestType> newTypes = <RequestType>[];
    for (final MapEntry<_Type, RequestType> e
        in _types(setup.main, setup.second).entries) {
      RequestType? found;
      for (final RequestType t in existingTypes) {
        if (t.status != RequestTypeStatus.removed &&
            t.nameEn.trim().toLowerCase() == e.value.nameEn.toLowerCase()) {
          found = t;
          break;
        }
      }
      types[e.key] = found ?? e.value;
      if (found == null) newTypes.add(e.value);
    }

    // ── Requests ──
    final _RequestBuilder builder = _RequestBuilder(
      team: team,
      setup: setup,
      types: types,
      managerOf: managerOf,
      hrApprover: actor,
      now: now,
      isArabic: isArabic,
    )..build();
    final List<_Req> requests = builder.out;

    // ── Attendance (never over an existing day) ──
    final Set<String> takenDays = await _existingDays(firestore, team, now);
    final List<TtDemoDay> days = _AttendanceBuilder(
      team: team,
      setup: setup,
      requests: <TimeTrackerRequest>[
        for (final _Req r in requests) r.request,
      ],
      typeOfId: <String, _Type>{
        for (final MapEntry<_Type, RequestType> e in types.entries)
          e.value.id: e.key,
      },
      now: now,
    ).build();

    // ── Documents ──
    final List<_Doc> docs = <_Doc>[];
    TimeTrackerAudit audit(String by, DateTime at, [String? modifiedBy]) =>
        TimeTrackerAudit(
            createdBy: by,
            createdAt: Timestamp.fromDate(at),
            modifiedBy: modifiedBy ?? actor);
    Map<String, dynamic> encode(Map<String, Object?> row, DateTime at) =>
        TimeTrackerHistoryCodec.append(
          old: null,
          values: <String, Object?>{...row, _tag: true},
          now: at,
        );

    for (final RequestType t in newTypes) {
      docs.add(_Doc(
          TimeTrackerFirestorePaths.requestTypes,
          t.id,
          encode(
              RequestTypeModel.row(t, id: t.id, audit: audit(actor, setupAt)),
              setupAt)));
    }
    if (createsLocations) {
      for (final WorkLocation l in locations) {
        docs.add(_Doc(
            TimeTrackerFirestorePaths.locations,
            l.id,
            encode(
                WorkLocationModel.row(l,
                    id: l.id, audit: audit(actor, setupAt)),
                setupAt)));
      }
      final EmployeeGroup? group = _group(setup, setupAt);
      final Set<String> assigned = <String>{
        for (final TimeTrackerDocument d in await remote
            .fetchCollection(TimeTrackerFirestorePaths.locationAssignments))
          d.id,
      };
      if (group != null) {
        docs.add(_Doc(
            TimeTrackerFirestorePaths.groups,
            group.id,
            encode(
                EmployeeGroupModel.row(group,
                    id: group.id, audit: audit(actor, setupAt)),
                setupAt)));
      }
      for (int i = 0; i < team.length; i++) {
        final TimeTrackerEmployee e = team[i];
        if (assigned.contains(e.email)) continue;
        final bool inGroup =
            group != null && group.memberEmails.contains(e.email);
        final LocationAssignment a = LocationAssignment(
          employeeEmail: e.email,
          locationId: setup.locationOf(e).id,
          startDate: setupAt,
          groupId: inGroup ? group.id : '',
          rules: const AttendanceRules(isCustom: false),
        );
        docs.add(_Doc(
            TimeTrackerFirestorePaths.locationAssignments,
            e.email,
            encode(
                LocationAssignmentModel.row(a,
                    id: e.email, audit: audit(actor, setupAt)),
                setupAt)));
      }
    }

    // Vacation balances: 21 days a year, minus what the year's requests hold.
    final Set<String> balanceIds = <String>{
      for (final TimeTrackerDocument d in await remote
          .fetchCollection(TimeTrackerFirestorePaths.vacationBalances))
        d.id,
    };
    for (final TimeTrackerEmployee e in team) {
      double used = 0;
      for (final _Req r in requests) {
        final RequestStatus s = r.request.status;
        if (r.request.requesterEmail != e.email ||
            (s != RequestStatus.approved && s != RequestStatus.underReview) ||
            r.request.startAt.year != now.year) {
          continue;
        }
        used += r.request.deductedVacationDays ?? 0;
      }
      final VacationBalance b = VacationBalance(
          employeeEmail: e.email,
          year: now.year,
          totalDays: 21,
          usedDays: used);
      final String id = VacationBalanceModel.docIdOf(b);
      if (balanceIds.contains(id)) continue;
      final DateTime at = DateTime(now.year, 1, 1, 8);
      docs.add(_Doc(
          TimeTrackerFirestorePaths.vacationBalances,
          id,
          encode(VacationBalanceModel.row(b, id: id, audit: audit(actor, at)),
              at)));
    }

    // Requests and their comments.
    for (final _Req r in requests) {
      docs.add(_Doc(
          TimeTrackerFirestorePaths.requests,
          r.request.id,
          encode(
              TimeTrackerRequestModel.row(r.request,
                  id: r.request.id,
                  audit:
                      audit(r.request.requesterEmail, r.submittedAt, r.actor)),
              r.lastAt)));
      for (final RequestComment c in r.comments) {
        final DateTime at = c.createdAt ?? r.submittedAt;
        docs.add(_Doc(
            TimeTrackerFirestorePaths.requestComments(r.request.id),
            c.id,
            encode(
                RequestCommentModel.row(c,
                    id: c.id, audit: audit(c.authorEmail, at, c.authorEmail)),
                at)));
      }
    }

    // Attendance days.
    for (final TtDemoDay d in days) {
      if (takenDays.contains(d.day.id)) continue;
      docs.add(_attendanceDoc(d, actor));
    }

    // ── Write ──
    WriteBatch batch = firestore.batch();
    int inBatch = 0;
    for (final _Doc d in docs) {
      if (inBatch == 400) {
        await batch.commit();
        batch = firestore.batch();
        inBatch = 0;
      }
      batch.set(firestore.collection(getBaseUrl(d.path)).doc(d.id), d.data);
      inBatch++;
    }
    if (inBatch > 0) await batch.commit();
    return docs.length;
  }

  // ── People ────────────────────────────────────────────────────────────────

  /// The signed-in user and up to eight colleagues as Time Tracker employees
  /// (the real directory entry when there is one).
  static Future<List<TimeTrackerEmployee>> _team(ShowcasePerson me,
      {required bool isArabic}) async {
    List<TimeTrackerEmployee> directory = const <TimeTrackerEmployee>[];
    try {
      directory = await const EmployeeDirectoryRepositoryImpl()
          .fetchEmployees(isArabic: isArabic);
    } catch (_) {
      directory = const <TimeTrackerEmployee>[];
    }
    final Map<String, TimeTrackerEmployee> byEmail =
        <String, TimeTrackerEmployee>{
      for (final TimeTrackerEmployee e in directory) e.email: e,
    };
    TimeTrackerEmployee employeeOf(ShowcasePerson p) =>
        byEmail[p.email] ??
        TimeTrackerEmployee(
          email: p.email,
          nameEn: p.nameEn,
          nameAr: p.nameAr,
          jobTitleEn: p.titleEn,
          jobTitleAr: p.titleAr,
          employeeId: p.id,
        );
    final List<TimeTrackerEmployee> team = <TimeTrackerEmployee>[
      employeeOf(me),
      for (final ShowcasePerson p in ShowcaseCommon.people)
        if (p.email != me.email) employeeOf(p),
    ];
    return team.take(_teamSize).toList();
  }

  /// E-mail → direct manager's e-mail ('' when there is none).
  static Future<Map<String, String>> _managers(
      FirebaseFirestore firestore, List<TimeTrackerEmployee> team) async {
    final OrgChartManagerResolver resolver = OrgChartManagerResolver(
        remoteDataSource:
            EmployeeDirectoryRemoteDataSource(firestore: firestore));
    final Map<String, String> out = <String, String>{};
    for (final TimeTrackerEmployee e in team) {
      try {
        out[e.email] = await resolver.managerEmailOf(
            employeeEmail: e.email, employeeId: e.employeeId);
      } catch (_) {
        out[e.email] = '';
      }
    }
    return out;
  }

  /// The ids of the attendance days of the team that already exist.
  static Future<Set<String>> _existingDays(FirebaseFirestore firestore,
      List<TimeTrackerEmployee> team, DateTime now) async {
    final CollectionReference<Map<String, dynamic>> col =
        firestore.collection(getBaseUrl(TimeTrackerFirestorePaths.attendance));
    final Set<String> ids = <String>{};
    for (final TimeTrackerEmployee e in team) {
      final String from = TimeTrackerFirestorePaths.attendanceDocId(
          e.email, DateTime(now.year));
      final String to = TimeTrackerFirestorePaths.attendanceDocId(
          e.email, DateTime(now.year, 12, 31));
      try {
        final QuerySnapshot<Map<String, dynamic>> snap = await col
            .orderBy(FieldPath.documentId)
            .startAt(<Object>[from]).endAt(<Object>[to]).get();
        for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs) {
          ids.add(d.id);
        }
      } catch (_) {
        continue;
      }
    }
    return ids;
  }

  // ── Set-up documents ──────────────────────────────────────────────────────

  static Map<_Type, RequestType> _types(
          WorkLocation main, WorkLocation second) =>
      <_Type, RequestType>{
        _Type.annual: RequestType(
          id: ShowcaseCommon.id('tt_type', 1),
          nameEn: TtDemoTexts.annual.en,
          nameAr: TtDemoTexts.annual.ar,
          descriptionEn: TtDemoTexts.annualDescription.en,
          descriptionAr: TtDemoTexts.annualDescription.ar,
          isDeductedFromVacationBalance: true,
        ),
        _Type.sick: RequestType(
          id: ShowcaseCommon.id('tt_type', 2),
          nameEn: TtDemoTexts.sick.en,
          nameAr: TtDemoTexts.sick.ar,
          descriptionEn: TtDemoTexts.sickDescription.en,
          descriptionAr: TtDemoTexts.sickDescription.ar,
          isAttachmentRequired: true,
        ),
        _Type.mission: RequestType(
          id: ShowcaseCommon.id('tt_type', 3),
          nameEn: TtDemoTexts.mission.en,
          nameAr: TtDemoTexts.mission.ar,
          descriptionEn: TtDemoTexts.missionDescription.en,
          descriptionAr: TtDemoTexts.missionDescription.ar,
          isHrApprovalRequired: false,
          isDescriptionRequired: true,
        ),
        _Type.workshop: RequestType(
          id: ShowcaseCommon.id('tt_type', 4),
          nameEn: TtDemoTexts.workshop.en,
          nameAr: TtDemoTexts.workshop.ar,
          descriptionEn: TtDemoTexts.workshopDescription.en,
          descriptionAr: TtDemoTexts.workshopDescription.ar,
          isManagerApprovalRequired: false,
          isDescriptionRequired: true,
        ),
        _Type.emergency: RequestType(
          id: ShowcaseCommon.id('tt_type', 5),
          nameEn: TtDemoTexts.emergency.en,
          nameAr: TtDemoTexts.emergency.ar,
          descriptionEn: TtDemoTexts.emergencyDescription.en,
          descriptionAr: TtDemoTexts.emergencyDescription.ar,
          status: RequestTypeStatus.inactive,
        ),
      };

  /// "Records Digitisation Team" at the first location (up to three
  /// colleagues, never the signed-in user).
  static EmployeeGroup? _group(_Setup setup, DateTime at) {
    final List<TimeTrackerEmployee> members = <TimeTrackerEmployee>[
      for (final TimeTrackerEmployee e in setup.team.skip(1))
        if (setup.locationOf(e).id == setup.main.id) e,
    ].take(3).toList();
    if (members.isEmpty) return null;
    return EmployeeGroup(
      id: ShowcaseCommon.id('tt_group', 1),
      name: TtDemoTexts.groupName.en,
      nameAr: TtDemoTexts.groupName.ar,
      description: TtDemoTexts.groupDescription.en,
      descriptionAr: TtDemoTexts.groupDescription.ar,
      memberEmails: <String>[
        for (final TimeTrackerEmployee e in members) e.email
      ],
      locationId: setup.main.id,
      startDate: at,
      rules: const AttendanceRules(
        isBreakAllowed: true,
        breakMinutes: 45,
        isPauseAllowed: true,
        pauseMinutes: 20,
      ),
    );
  }

  // ── Attendance document ───────────────────────────────────────────────────

  /// One attendance day in the stored shape: alerts and the automatic
  /// check-out on the row; a corrected day also keeps its uncorrected first
  /// row.
  static _Doc _attendanceDoc(TtDemoDay d, String actor) {
    TimeTrackerAudit audit() => TimeTrackerAudit(
        createdBy: d.day.employeeEmail,
        createdAt: Timestamp.fromDate(
            DateTime(d.day.date.year, d.day.date.month, d.day.date.day, 9)),
        modifiedBy: actor);

    Map<String, Object?> row(AttendanceDay day, {required bool isFinal}) {
      final Map<String, Object?> values =
          AttendanceDayModel.row(day, id: day.id, audit: audit());
      if (isFinal && d.isAutoCheckOut) {
        final List<Map<String, dynamic>> sessions =
            TimeTrackerFieldCodec.maps(values[AttendanceDayModel.fSessions]);
        if (sessions.isNotEmpty) {
          sessions.last['Is_Auto_Check_Out'] = true;
          values[AttendanceDayModel.fSessions] =
              TimeTrackerFieldCodec.wrap(sessions);
        }
      }
      values['Alerts'] = TimeTrackerFieldCodec.wrap(<Object?>[
        if (isFinal)
          for (final TtDemoAlert a in d.alerts)
            <String, Object?>{
              'Alert_Type': a.type,
              'At': Timestamp.fromDate(a.at),
              'Minutes_Over': a.minutesOver,
            },
      ]);
      values[_tag] = true;
      return values;
    }

    final DateTime date = d.day.date;
    final DateTime first = DateTime(date.year, date.month, date.day, 18);
    final AttendanceDay? before = d.before;
    if (before == null) {
      return _Doc(
        TimeTrackerFirestorePaths.attendance,
        d.day.id,
        TimeTrackerHistoryCodec.append(
            old: null, values: row(d.day, isFinal: true), now: first),
      );
    }
    final Map<String, dynamic> uncorrected = TimeTrackerHistoryCodec.append(
        old: null, values: row(before, isFinal: false), now: first);
    final Map<String, Object?> corrected = row(d.day, isFinal: true)
      ..[TimeTrackerAudit.fCreationDate] = TimeTrackerHistoryCodec.lastOf(
          uncorrected, TimeTrackerAudit.fCreationDate);
    return _Doc(
      TimeTrackerFirestorePaths.attendance,
      d.day.id,
      TimeTrackerHistoryCodec.append(
          old: uncorrected,
          values: corrected,
          now: first.add(const Duration(days: 1, hours: 2))),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Requests
// ═════════════════════════════════════════════════════════════════════════════

class _RequestBuilder {
  _RequestBuilder({
    required this.team,
    required this.setup,
    required this.types,
    required this.managerOf,
    required this.hrApprover,
    required this.now,
    required this.isArabic,
  });

  final List<TimeTrackerEmployee> team;
  final _Setup setup;
  final Map<_Type, RequestType> types;
  final Map<String, String> managerOf;

  /// Decides the HR steps (the signed-in owner is an HR approver).
  final String hrApprover;
  final DateTime now;
  final bool isArabic;

  final List<_Req> out = <_Req>[];
  int _n = 0;
  int _c = 0;

  DateTime get _today => DateTime(now.year, now.month, now.day);

  TtDemoCalendar _cal(TimeTrackerEmployee e) =>
      TtDemoCalendar(setup.scheduleOf(e));

  /// The first working day of [e] on or after [month]/[day] of this year.
  DateTime _on(TimeTrackerEmployee e, int month, int day) =>
      _cal(e).ahead(DateTime(now.year, month, day - 1), 1);

  /// The [n]-th working day after today.
  DateTime _ahead(TimeTrackerEmployee e, int n) => _cal(e).ahead(_today, n);

  static DateTime _at(DateTime day, int offset, int hour, int minute) =>
      DateTime(day.year, day.month, day.day + offset, hour, minute);

  void build() {
    _mine();
    for (int i = 1; i < team.length; i++) {
      _colleague(i, team[i]);
    }
  }

  // ── The signed-in user: every status, at least five of each ───────────────

  void _mine() {
    final TimeTrackerEmployee me = team.first;
    TtDemoText d(TtDemoText t) => t;
    // Approved (14).
    _leave(me, _Type.annual, _on(me, 2, 9), 2, TtDemoTexts.personalMatters,
        _Fate.approved);
    _leave(me, _Type.annual, _on(me, 4, 12), 3, TtDemoTexts.familyTrip,
        _Fate.approved,
        comments: _handover(me, _on(me, 3, 30)));
    _leave(me, _Type.annual, _on(me, 6, 7), 2, TtDemoTexts.personalMatters,
        _Fate.approved);
    _leave(me, _Type.annual, _on(me, 8, 16), 3, TtDemoTexts.familyTrip,
        _Fate.approved);
    _leave(me, _Type.sick, _on(me, 3, 4), 2, TtDemoTexts.flu, _Fate.approved,
        comments: _report(me, _on(me, 3, 5)));
    _leave(
        me, _Type.sick, _on(me, 7, 13), 1, TtDemoTexts.checkup, _Fate.approved);
    _partial(me, _Type.mission, _on(me, 1, 14), 10 * 60, 14 * 60,
        TtDemoTexts.ministryMeeting, _Fate.approved);
    _partial(me, _Type.mission, _on(me, 5, 11), 11 * 60, 15 * 60,
        TtDemoTexts.siteVisit, _Fate.approved,
        comments: _mission(me, _on(me, 5, 11)));
    _partial(me, _Type.mission, _on(me, 9, 6), 10 * 60, 13 * 60 + 30,
        TtDemoTexts.ministryMeeting, _Fate.approved);
    _leave(me, _Type.workshop, _on(me, 4, 21), 1, TtDemoTexts.digitalWorkshop,
        _Fate.approved);
    _leave(me, _Type.workshop, _cal(me).back(_today, 8), 1,
        TtDemoTexts.archivingWorkshop, _Fate.approved);
    _transaction(
        me, _on(me, 1, 20), TtDemoTexts.forgotCheckOut, _Fate.approved);
    _transaction(me, _on(me, 4, 8), TtDemoTexts.deviceFailure, _Fate.approved);
    _transaction(
        me, _on(me, 7, 22), TtDemoTexts.forgotCheckOut, _Fate.approved);
    // Rejected (5).
    _leave(me, _Type.workshop, _on(me, 2, 3), 1, TtDemoTexts.digitalWorkshop,
        _Fate.rejected,
        reason: TtDemoTexts.rejectNoInvitation);
    _leave(me, _Type.annual, _on(me, 6, 22), 3, TtDemoTexts.yearEnd,
        _Fate.rejected,
        reason: TtDemoTexts.rejectWorkload);
    _partial(me, _Type.mission, _on(me, 8, 2), 11 * 60, 15 * 60,
        TtDemoTexts.siteVisit, _Fate.rejected,
        reason: TtDemoTexts.rejectWorkload);
    _transaction(me, _on(me, 9, 10), TtDemoTexts.deviceFailure, _Fate.rejected,
        reason: ShowcaseTimeTracker._txRejected);
    _leave(me, _Type.workshop, _on(me, 9, 23), 1, TtDemoTexts.archivingWorkshop,
        _Fate.rejected,
        reason: TtDemoTexts.rejectNoInvitation);
    // Canceled by the requester (5).
    _leave(me, _Type.annual, _on(me, 3, 24), 2, TtDemoTexts.familyTrip,
        _Fate.canceled,
        reason: TtDemoTexts.cancelPlansChanged);
    _leave(me, _Type.annual, _on(me, 5, 25), 2, TtDemoTexts.personalMatters,
        _Fate.canceled,
        reason: TtDemoTexts.cancelPlansChanged);
    _leave(me, _Type.annual, _on(me, 7, 28), 1, TtDemoTexts.yearEnd,
        _Fate.canceled,
        reason: TtDemoTexts.cancelPlansChanged);
    _partial(me, _Type.mission, _on(me, 8, 24), 9 * 60, 12 * 60,
        TtDemoTexts.ministryMeeting, _Fate.canceled,
        reason: TtDemoTexts.cancelPlansChanged);
    _leave(me, _Type.annual, _on(me, 9, 29), 2, TtDemoTexts.familyTrip,
        _Fate.canceled,
        reason: TtDemoTexts.cancelPlansChanged);
    // Canceled by HR (5).
    _leave(me, _Type.annual, _on(me, 1, 27), 2, TtDemoTexts.personalMatters,
        _Fate.canceledByHr,
        reason: TtDemoTexts.cancelByHrAudit);
    _leave(me, _Type.annual, _on(me, 3, 15), 1, TtDemoTexts.yearEnd,
        _Fate.canceledByHr,
        reason: TtDemoTexts.cancelByHrAudit);
    _leave(me, _Type.annual, _on(me, 5, 4), 2, TtDemoTexts.familyTrip,
        _Fate.canceledByHr,
        reason: TtDemoTexts.cancelByHrAudit);
    _partial(me, _Type.mission, _on(me, 7, 6), 10 * 60, 14 * 60,
        TtDemoTexts.siteVisit, _Fate.canceledByHr,
        reason: TtDemoTexts.cancelByHrAudit);
    _leave(me, _Type.annual, _on(me, 9, 15), 1, TtDemoTexts.personalMatters,
        _Fate.canceledByHr,
        reason: TtDemoTexts.cancelByHrAudit);
    // Cancellation asked, under review (5).
    _leave(me, _Type.annual, _ahead(me, 12), 1, TtDemoTexts.familyTrip,
        _Fate.underReview,
        reason: TtDemoTexts.cancelRequestReturn);
    _leave(me, _Type.annual, _ahead(me, 22), 1, TtDemoTexts.yearEnd,
        _Fate.underReview,
        reason: TtDemoTexts.cancelRequestReturn);
    _partial(me, _Type.mission, _ahead(me, 16), 10 * 60, 13 * 60,
        TtDemoTexts.ministryMeeting, _Fate.underReview,
        reason: TtDemoTexts.cancelRequestReturn);
    _leave(me, _Type.workshop, _ahead(me, 28), 1, TtDemoTexts.digitalWorkshop,
        _Fate.underReview,
        reason: TtDemoTexts.cancelRequestReturn);
    _leave(me, _Type.sick, _ahead(me, 9), 1, TtDemoTexts.checkup,
        _Fate.underReview,
        reason: TtDemoTexts.cancelRequestReturn);
    // Pending (5): at the manager, at HR, a workshop and a transaction.
    _leave(me, _Type.annual, _ahead(me, 38), 2, TtDemoTexts.familyTrip,
        _Fate.pending,
        comments: _handover(me, _today));
    _leave(me, _Type.annual, _ahead(me, 45), 3, TtDemoTexts.yearEnd,
        _Fate.pending);
    _leave(me, _Type.annual, _ahead(me, 33), 2, TtDemoTexts.personalMatters,
        _Fate.pendingHr);
    _leave(me, _Type.workshop, _ahead(me, 20), 1, TtDemoTexts.archivingWorkshop,
        _Fate.pending);
    _transaction(me, _cal(me).back(_today, 2), d(TtDemoTexts.forgotCheckOut),
        _Fate.pending);
  }

  // ── Colleagues: a rotating pattern across the year ────────────────────────

  void _colleague(int i, TimeTrackerEmployee e) {
    final int j = i - 1;
    _leave(e, _Type.annual, _on(e, 2 + j % 3, 8 + j), 2 + j % 3,
        TtDemoTexts.personalMatters, _Fate.approved);
    _leave(e, _Type.annual, _on(e, 6 + j % 3, 5 + j * 2), 2,
        TtDemoTexts.familyTrip, _Fate.approved,
        comments:
            j % 2 == 0 ? _handover(e, _on(e, 6 + j % 3, 3 + j * 2)) : null);
    _leave(e, _Type.sick, _on(e, 1 + j % 6, 4 + j * 2), 1 + j % 2,
        TtDemoTexts.flu, _Fate.approved,
        comments: j % 3 == 0 ? _report(e, _on(e, 1 + j % 6, 5 + j * 2)) : null);
    _partial(e, _Type.mission, _on(e, 4 + j % 5, 10 + j), 10 * 60, 13 * 60 + 30,
        TtDemoTexts.ministryMeeting, _Fate.approved,
        comments: j % 4 == 2 ? _mission(e, _on(e, 4 + j % 5, 10 + j)) : null);
    if (j.isEven) {
      _leave(e, _Type.workshop, _on(e, 9, 6 + j), 1,
          TtDemoTexts.digitalWorkshop, _Fate.approved);
    }
    _transaction(e, _on(e, 3 + j % 5, 14 + j), TtDemoTexts.forgotCheckOut,
        _Fate.approved);
    _transaction(e, _cal(e).back(_today, 1 + j % 3), TtDemoTexts.deviceFailure,
        _Fate.pending);
    if (j.isOdd) {
      _partial(e, _Type.mission, _on(e, 7 + j % 3, 17), 11 * 60, 15 * 60,
          TtDemoTexts.siteVisit, _Fate.rejected,
          reason: TtDemoTexts.rejectWorkload);
    } else {
      _leave(e, _Type.workshop, _on(e, 5 + j % 4, 18), 1,
          TtDemoTexts.archivingWorkshop, _Fate.rejected,
          reason: TtDemoTexts.rejectNoInvitation);
    }
    if (j.isEven) {
      _leave(e, _Type.annual, _ahead(e, 10 + j), 2, TtDemoTexts.yearEnd,
          _Fate.pendingHr);
    } else {
      _leave(e, _Type.annual, _ahead(e, 14 + j), 2, TtDemoTexts.familyTrip,
          _Fate.pending);
    }
    if (j % 3 == 0) {
      _leave(e, _Type.annual, _on(e, 8, 3 + j), 1, TtDemoTexts.personalMatters,
          _Fate.canceled,
          reason: TtDemoTexts.cancelPlansChanged);
    }
    if (j % 4 == 1) {
      _leave(e, _Type.annual, _ahead(e, 20 + j), 1, TtDemoTexts.yearEnd,
          _Fate.canceledByHr,
          reason: TtDemoTexts.cancelByHrAudit);
    }
    if (j % 4 == 2) {
      _leave(e, _Type.annual, _ahead(e, 18 + j), 2, TtDemoTexts.familyTrip,
          _Fate.underReview,
          reason: TtDemoTexts.cancelRequestReturn);
    }
  }

  // ── Builders ──────────────────────────────────────────────────────────────

  void _leave(
    TimeTrackerEmployee e,
    _Type type,
    DateTime start,
    int workingDays,
    TtDemoText description,
    _Fate fate, {
    TtDemoText? reason,
    List<RequestComment>? comments,
  }) {
    final TtDemoCalendar c = _cal(e);
    final DateTime first = TtDemoCalendar.dayOf(start);
    final DateTime last = c.spanEnd(first, workingDays);
    _add(
      e,
      type: type,
      from: DateTime(first.year, first.month, first.day),
      to: DateTime(last.year, last.month, last.day, 23, 59),
      allDay: true,
      totalMinutes: (DateTime.utc(last.year, last.month, last.day)
                  .difference(DateTime.utc(first.year, first.month, first.day))
                  .inDays +
              1) *
          24 *
          60,
      description: description,
      fate: fate,
      reason: reason,
      comments: comments,
    );
  }

  void _partial(
    TimeTrackerEmployee e,
    _Type type,
    DateTime day,
    int startMinutes,
    int endMinutes,
    TtDemoText description,
    _Fate fate, {
    TtDemoText? reason,
    List<RequestComment>? comments,
  }) {
    _add(
      e,
      type: type,
      from: DateTime(day.year, day.month, day.day, 0, startMinutes),
      to: DateTime(day.year, day.month, day.day, 0, endMinutes),
      allDay: false,
      totalMinutes: endMinutes - startMinutes,
      description: description,
      fate: fate,
      reason: reason,
      comments: comments,
    );
  }

  /// A check-in / check-out correction for [day].
  void _transaction(
    TimeTrackerEmployee e,
    DateTime day,
    TtDemoText description,
    _Fate fate, {
    TtDemoText? reason,
  }) {
    final WorkSchedule s = setup.scheduleOf(e);
    final int roll =
        TtDemoDice.roll('${e.email}_tx_${day.month}_${day.day}', 12);
    final DateTime checkIn =
        DateTime(day.year, day.month, day.day, 0, s.startMinutes - 6 + roll);
    final DateTime checkOut =
        DateTime(day.year, day.month, day.day, 0, s.endMinutes + 25 + roll * 3);
    final List<RequestApprovalStep> steps = ApprovalRouter.transactionSteps(
      managerEmail: _manager(e),
      requesterEmail: e.email,
    );
    final DateTime submitted =
        DateTime(day.year, day.month, day.day + 1, 9, 10 + roll);
    final TimeTrackerRequest base = TimeTrackerRequest(
      id: ShowcaseCommon.id('tt_request', ++_n),
      requesterEmail: e.email,
      requesterDepartmentId: e.departmentId,
      isTransaction: true,
      description: description.of(isArabic: isArabic),
      startAt: checkIn,
      endAt: checkOut,
      totalMinutes: checkOut.difference(checkIn).inMinutes,
      status: ApprovalRouter.initialStatus(steps),
      approvalSteps: steps,
      currentStep: ApprovalRouter.currentStepOf(steps)?.step,
    );
    _push(base, fate, submitted, reason: reason, deducts: false);
  }

  void _add(
    TimeTrackerEmployee e, {
    required _Type type,
    required DateTime from,
    required DateTime to,
    required bool allDay,
    required int totalMinutes,
    required TtDemoText description,
    required _Fate fate,
    TtDemoText? reason,
    List<RequestComment>? comments,
  }) {
    final RequestType t = types[type]!;
    final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
      isManagerApprovalRequired: t.isManagerApprovalRequired,
      isHrApprovalRequired: t.isHrApprovalRequired,
      managerEmail: _manager(e),
      requesterEmail: e.email,
    );
    // Submitted a week or two before the leave starts (never in the future).
    DateTime submitted =
        _at(from, -(5 + from.day % 8), 9 + from.day % 6, (from.day * 7) % 60);
    if (submitted.isAfter(now)) {
      submitted = now.subtract(Duration(days: 1 + from.day % 6, hours: 2));
    }
    final TimeTrackerRequest base = TimeTrackerRequest(
      id: ShowcaseCommon.id('tt_request', ++_n),
      requesterEmail: e.email,
      requesterDepartmentId: e.departmentId,
      requestTypeId: t.id,
      description: description.of(isArabic: isArabic),
      startAt: from,
      endAt: to,
      isAllDay: allDay,
      totalMinutes: totalMinutes,
      status: ApprovalRouter.initialStatus(steps),
      approvalSteps: steps,
      currentStep: ApprovalRouter.currentStepOf(steps)?.step,
    );
    _push(base, fate, submitted,
        reason: reason,
        deducts: t.isDeductedFromVacationBalance,
        comments: comments);
  }

  void _push(
    TimeTrackerRequest base,
    _Fate fate,
    DateTime submitted, {
    TtDemoText? reason,
    required bool deducts,
    List<RequestComment>? comments,
  }) {
    if (submitted.isAfter(now)) {
      submitted = now.subtract(const Duration(hours: 3));
    }
    final (TimeTrackerRequest request, DateTime lastAt, String actor) moved;
    try {
      moved = _move(base, fate, submitted, reason: reason, deducts: deducts);
    } on StateError {
      // A request type of the company that approves by itself cannot be
      // pending, rejected or canceled: leave that request out.
      return;
    }
    final List<RequestComment> thread = <RequestComment>[
      for (final RequestComment c in comments ?? const <RequestComment>[])
        RequestComment(
          id: '${ShowcaseCommon.idPrefix}ttc_${(++_c).toString().padLeft(3, '0')}',
          authorEmail: c.authorEmail,
          text: c.text,
          createdAt: _clamp(c.createdAt ?? submitted),
        ),
    ];
    out.add(_Req(
      request: moved.$1,
      submittedAt: submitted,
      lastAt: _clamp(moved.$2),
      actor: moved.$3,
      comments: thread,
    ));
  }

  DateTime _clamp(DateTime t) => t.isAfter(now) ? now : t;

  /// Moves [r] through its cycle to [fate] with the module's own rules.
  (TimeTrackerRequest, DateTime, String) _move(
    TimeTrackerRequest r,
    _Fate fate,
    DateTime submitted, {
    required TtDemoText? reason,
    required bool deducts,
  }) {
    final String why =
        (reason ?? TtDemoTexts.rejectWorkload).of(isArabic: isArabic);
    DateTime at = submitted.add(const Duration(hours: 3));
    String actor = r.requesterEmail;
    TimeTrackerRequest approveAll(TimeTrackerRequest x) {
      TimeTrackerRequest y = x;
      while (RequestCycleRules.actionableStep(y) != null) {
        actor = _deciderFor(y);
        y = RequestCycleRules.approve(y, approverEmail: actor, at: at).after;
        at = at.add(const Duration(hours: 20));
      }
      return y;
    }

    TimeTrackerRequest approved() {
      final TimeTrackerRequest y = approveAll(r);
      final double days = deducts
          ? VacationBalanceRules.requestedDays(y,
              schedule: setup.scheduleOf(_person(y.requesterEmail)))
          : 0;
      return y
          .copyWith(deductedDaysByYear: <int, double>{y.startAt.year: days});
    }

    switch (fate) {
      case _Fate.pending:
        return (r, submitted, r.requesterEmail);
      case _Fate.pendingHr:
        final RequestApprovalStep? step = RequestCycleRules.actionableStep(r);
        final bool hrFollows = r.approvalSteps.length > 1 &&
            step?.step == ApprovalStepKind.manager;
        if (!hrFollows) return (r, submitted, r.requesterEmail);
        actor = _deciderFor(r);
        return (
          RequestCycleRules.approve(r, approverEmail: actor, at: at).after,
          at,
          actor
        );
      case _Fate.approved:
        final TimeTrackerRequest y = approved();
        return (y, at, actor);
      case _Fate.rejected:
        actor = _deciderFor(r);
        return (
          RequestCycleRules.reject(r, approverEmail: actor, reason: why, at: at)
              .after,
          at,
          actor
        );
      case _Fate.canceled:
        return (
          RequestCycleRules.cancelPending(r, reason: why),
          submitted.add(const Duration(days: 1, hours: 5)),
          r.requesterEmail
        );
      case _Fate.canceledByHr:
        final TimeTrackerRequest y = approved();
        return (
          RequestCycleRules.cancelByHr(y, reason: why),
          at.add(const Duration(days: 2)),
          hrApprover
        );
      case _Fate.underReview:
        final TimeTrackerRequest y = approved();
        return (
          RequestCycleRules.requestCancellation(y, reason: why),
          at.add(const Duration(days: 1)),
          r.requesterEmail
        );
    }
  }

  /// Who decides the waiting step: the manager stored on a manager step; on
  /// an HR step the signed-in HR approver, or a colleague when that person is
  /// the requester or already decided an earlier step.
  String _deciderFor(TimeTrackerRequest r) {
    final RequestApprovalStep? step = RequestCycleRules.actionableStep(r);
    if (step != null &&
        step.step == ApprovalStepKind.manager &&
        step.approverEmail.isNotEmpty) {
      return step.approverEmail;
    }
    final Set<String> taken = <String>{
      r.requesterEmail,
      for (final RequestApprovalStep s in r.approvalSteps)
        if (!s.isPending && !s.isSkipped) s.approverEmail,
    };
    if (!taken.contains(hrApprover)) return hrApprover;
    for (final TimeTrackerEmployee p in team) {
      if (!taken.contains(p.email)) return p.email;
    }
    return hrApprover;
  }

  String _manager(TimeTrackerEmployee e) =>
      (managerOf[e.email] ?? '').trim().toLowerCase();

  TimeTrackerEmployee _person(String email) =>
      team.firstWhere((TimeTrackerEmployee p) => p.email == email,
          orElse: () => team.first);

  // ── Comments ──────────────────────────────────────────────────────────────

  RequestComment _comment(String author, TtDemoText text, DateTime at) =>
      RequestComment(
        id: 'x',
        authorEmail: author.isEmpty ? hrApprover : author,
        text: text.of(isArabic: isArabic),
        createdAt: at,
      );

  String _reviewerFor(TimeTrackerEmployee e) {
    final String manager = _manager(e);
    if (manager.isNotEmpty) return manager;
    return e.email == hrApprover && team.length > 1
        ? team[1].email
        : hrApprover;
  }

  List<RequestComment> _handover(TimeTrackerEmployee e, DateTime day) =>
      <RequestComment>[
        _comment(
            _reviewerFor(e), TtDemoTexts.commentHandover, _at(day, 0, 11, 20)),
        _comment(e.email, TtDemoTexts.commentHandoverReply, _at(day, 0, 12, 5)),
      ];

  List<RequestComment> _report(TimeTrackerEmployee e, DateTime day) =>
      <RequestComment>[
        _comment(e.email == hrApprover ? _reviewerFor(e) : hrApprover,
            TtDemoTexts.commentReport, _at(day, 0, 10, 15)),
      ];

  List<RequestComment> _mission(TimeTrackerEmployee e, DateTime day) =>
      <RequestComment>[
        _comment(_reviewerFor(e), TtDemoTexts.commentMissionLetter,
            _at(day, 0, 15, 0)),
      ];
}

// ═════════════════════════════════════════════════════════════════════════════
// Attendance
// ═════════════════════════════════════════════════════════════════════════════

class _AttendanceBuilder {
  _AttendanceBuilder({
    required this.team,
    required this.setup,
    required this.requests,
    required this.typeOfId,
    required this.now,
  });

  final List<TimeTrackerEmployee> team;
  final _Setup setup;
  final List<TimeTrackerRequest> requests;

  /// Request type id → which showcase type it is (a reused company type
  /// keeps its own id).
  final Map<String, _Type> typeOfId;
  final DateTime now;

  DateTime get _today => DateTime(now.year, now.month, now.day);

  List<TtDemoDay> build() {
    final List<TtDemoDay> out = <TtDemoDay>[];
    for (int k = 0; k < team.length; k++) {
      out.addAll(_employee(k, team[k]));
    }
    return out;
  }

  List<TtDemoDay> _employee(int k, TimeTrackerEmployee e) {
    final WorkLocation loc = setup.locationOf(e);
    final WorkSchedule s = setup.scheduleOf(e);
    final TtDemoCalendar cal = TtDemoCalendar(s);
    final List<TimeTrackerRequest> mine = <TimeTrackerRequest>[
      for (final TimeTrackerRequest r in requests)
        if (r.requesterEmail == e.email) r,
    ];
    final Set<DateTime> autoDays = <DateTime>{
      for (int m = 1; m < now.month; m += 2)
        cal.back(DateTime(now.year, m + 1, 1), 4 + k % 3),
    };
    final Set<DateTime> longBreakDays = <DateTime>{
      for (int m = 2; m < now.month; m += 3)
        cal.back(DateTime(now.year, m + 1, 1), 6 + k % 2),
    };
    // One colleague has three absences this month (Needs Attention).
    final Set<DateTime> absent = <DateTime>{};
    if (k == 3) {
      for (DateTime d = DateTime(_today.year, _today.month);
          d.isBefore(_today);
          d = TtDemoCalendar.addDays(d, 1)) {
        if (s.isWorkingDay(d) &&
            _leaveOn(mine, d) == null &&
            _transactionOn(mine, d) == null) {
          absent.add(d);
        }
        if (absent.length == 3) break;
      }
    }
    final List<TtDemoDay> out = <TtDemoDay>[];
    for (DateTime d = DateTime(now.year);
        d.isBefore(_today);
        d = TtDemoCalendar.addDays(d, 1)) {
      if (!s.isWorkingDay(d)) continue;
      final AttendanceStatus? leave = _leaveOn(mine, d);
      final TimeTrackerRequest? tx = _transactionOn(mine, d);
      final String id = TimeTrackerFirestorePaths.attendanceDocId(e.email, d);
      if (leave != null) {
        out.add(TtDemoDay(
            day: AttendanceDay(
                id: id, employeeEmail: e.email, date: d, status: leave)));
      } else if (tx != null) {
        out.add(_transactionDay(e, d, tx, s, loc));
      } else if (absent.contains(d) ||
          TtDemoDice.roll('${e.email}_absent_${d.month}_${d.day}', 100) <
              (k == 0 ? 1 : 3)) {
        out.add(TtDemoDay(
            day: AttendanceDay(
                id: id,
                employeeEmail: e.email,
                date: d,
                status: AttendanceStatus.absent)));
      } else {
        out.add(_workDay(e, d, s, loc,
            auto: autoDays.any((DateTime x) => _same(x, d)),
            longBreak: longBreakDays.any((DateTime x) => _same(x, d))));
      }
    }
    // Today: a few colleagues are checked in right now (one of them late).
    if (k >= 1 &&
        k <= 4 &&
        s.isWorkingDay(_today) &&
        _leaveOn(mine, _today) == null &&
        _transactionOn(mine, _today) == null) {
      out.add(_liveToday(e, s, loc, late: k == 4));
    }
    return out;
  }

  static bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// The leave status of [d] from an approved / under-review all-day request.
  AttendanceStatus? _leaveOn(List<TimeTrackerRequest> mine, DateTime d) {
    for (final TimeTrackerRequest r in mine) {
      if (r.isTransaction || !r.isAllDay) continue;
      if (r.status != RequestStatus.approved &&
          r.status != RequestStatus.underReview) {
        continue;
      }
      final DateTime from = TtDemoCalendar.dayOf(r.startAt);
      final DateTime to = TtDemoCalendar.dayOf(r.endAt);
      if (d.isBefore(from) || d.isAfter(to)) continue;
      final _Type? type = typeOfId[r.requestTypeId];
      if (type == _Type.sick) return AttendanceStatus.sickLeave;
      if (type == _Type.workshop) return AttendanceStatus.excused;
      return AttendanceStatus.vacation;
    }
    return null;
  }

  TimeTrackerRequest? _transactionOn(
      List<TimeTrackerRequest> mine, DateTime d) {
    for (final TimeTrackerRequest r in mine) {
      if (!r.isTransaction) continue;
      if (r.status != RequestStatus.approved &&
          r.status != RequestStatus.pending) {
        continue;
      }
      if (_same(TtDemoCalendar.dayOf(r.startAt), d)) return r;
    }
    return null;
  }

  /// Where the session was checked in (office most days).
  (WorkLocationType, String) _where(
      TimeTrackerEmployee e, DateTime d, WorkLocation loc) {
    final int day = d.day % 14;
    if (day == 3) return (WorkLocationType.remote, '');
    if (day == 10) return (WorkLocationType.clientSite, '');
    final int roll =
        TtDemoDice.roll('${e.email}_where_${d.month}_${d.day}', 100);
    if (roll < 12) return (WorkLocationType.remote, '');
    if (roll < 20) return (WorkLocationType.clientSite, '');
    return (WorkLocationType.office, loc.id);
  }

  TtDemoDay _workDay(
    TimeTrackerEmployee e,
    DateTime d,
    WorkSchedule s,
    WorkLocation loc, {
    required bool auto,
    required bool longBreak,
  }) {
    final String key = '${e.email}_${d.month}_${d.day}';
    final bool late = TtDemoDice.roll('${key}_late', 100) < 13;
    final int inOffset = late
        ? s.lateAfterMinutes + 6 + TtDemoDice.roll('${key}_lm', 50)
        : -14 +
            TtDemoDice.roll('${key}_in',
                14 + (s.lateAfterMinutes > 0 ? s.lateAfterMinutes : 1));
    final DateTime checkIn =
        DateTime(d.year, d.month, d.day, 0, s.startMinutes + inOffset);
    final DateTime checkOut = auto
        ? DateTime(d.year, d.month, d.day, 0, s.endMinutes)
        : DateTime(d.year, d.month, d.day, 0,
            s.endMinutes + TtDemoDice.roll('${key}_out', 40));
    final List<AttendancePause> pauses = <AttendancePause>[];
    final List<TtDemoAlert> alerts = <TtDemoAlert>[];
    if (loc.isBreakAllowed &&
        (longBreak || TtDemoDice.roll('${key}_break', 100) < 70)) {
      final int allowed = loc.breakMinutes > 0 ? loc.breakMinutes : 30;
      final int length =
          longBreak ? allowed + 22 : allowed - TtDemoDice.roll('${key}_bl', 8);
      final DateTime start = DateTime(
          d.year, d.month, d.day, 12, 30 + TtDemoDice.roll('${key}_bs', 15));
      pauses.add(AttendancePause(
          startAt: start, endAt: start.add(Duration(minutes: length))));
      if (longBreak) {
        alerts.add(TtDemoAlert(
          type: 'break_exceeded',
          at: start.add(Duration(minutes: allowed)),
          minutesOver: length - allowed,
        ));
      }
    }
    if (loc.isPauseAllowed && TtDemoDice.roll('${key}_pause', 100) < 30) {
      final DateTime start = DateTime(
          d.year, d.month, d.day, 10, 20 + TtDemoDice.roll('${key}_ps', 25));
      pauses.insert(
          0,
          AttendancePause(
              startAt: start,
              endAt: start.add(
                  Duration(minutes: 8 + TtDemoDice.roll('${key}_pl', 8)))));
    }
    final (WorkLocationType type, String locationId) = _where(e, d, loc);
    final AttendanceSession session = AttendanceSession(
      checkInAt: checkIn,
      checkOutAt: checkOut,
      workLocationId: locationId,
      workLocationType: type,
      latitude: type == WorkLocationType.office ? loc.latitude : null,
      longitude: type == WorkLocationType.office ? loc.longitude : null,
      pauses: pauses,
    );
    final AttendanceDay day = AttendanceCalculator.apply(
      AttendanceDay(
          id: TimeTrackerFirestorePaths.attendanceDocId(e.email, d),
          employeeEmail: e.email,
          date: d,
          sessions: <AttendanceSession>[session]),
      schedule: s,
      now: now,
    );
    if (day.lateMinutes > 0) {
      alerts.insert(
          0,
          TtDemoAlert(
              type: 'late_arrival', at: checkIn, minutesOver: day.lateMinutes));
    }
    if (auto) {
      alerts.add(TtDemoAlert(
          type: 'auto_check_out',
          at: checkOut.add(const Duration(minutes: 120))));
    }
    return TtDemoDay(day: day, alerts: alerts, isAutoCheckOut: auto);
  }

  /// A transaction's day: still open (pending) or corrected (approved).
  TtDemoDay _transactionDay(TimeTrackerEmployee e, DateTime d,
      TimeTrackerRequest tx, WorkSchedule s, WorkLocation loc) {
    final String id = TimeTrackerFirestorePaths.attendanceDocId(e.email, d);
    final AttendanceSession open = AttendanceSession(
      checkInAt: tx.startAt,
      workLocationId: loc.id,
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
    final AttendanceDay openDay = AttendanceCalculator.apply(
      AttendanceDay(
          id: id,
          employeeEmail: e.email,
          date: d,
          sessions: <AttendanceSession>[open]),
      schedule: s,
      now: tx.startAt,
    );
    final List<TtDemoAlert> missed = <TtDemoAlert>[
      TtDemoAlert(
          type: 'missed_check_out',
          at: s.endOn(d).add(const Duration(minutes: 30))),
    ];
    if (tx.status != RequestStatus.approved) {
      return TtDemoDay(day: openDay, alerts: missed);
    }
    final AttendanceDay corrected = AttendanceCalculator.apply(
      openDay.copyWith(
        sessions: <AttendanceSession>[open.copyWith(checkOutAt: tx.endAt)],
        isCorrectedByTransaction: true,
        sourceRequestId: tx.id,
      ),
      schedule: s,
      now: now,
    );
    return TtDemoDay(day: corrected, alerts: missed, before: openDay);
  }

  /// Checked in this morning and still working.
  TtDemoDay _liveToday(TimeTrackerEmployee e, WorkSchedule s, WorkLocation loc,
      {required bool late}) {
    final DateTime d = _today;
    final int offset = late
        ? s.lateAfterMinutes + 55
        : -9 + TtDemoDice.roll('${e.email}_today', 12);
    DateTime checkIn =
        DateTime(d.year, d.month, d.day, 0, s.startMinutes + offset);
    if (checkIn.isAfter(now)) {
      checkIn = now.subtract(const Duration(minutes: 35));
    }
    final AttendanceDay day = AttendanceCalculator.apply(
      AttendanceDay(
          id: TimeTrackerFirestorePaths.attendanceDocId(e.email, d),
          employeeEmail: e.email,
          date: d,
          sessions: <AttendanceSession>[
            AttendanceSession(
              checkInAt: checkIn,
              workLocationId: loc.id,
              latitude: loc.latitude,
              longitude: loc.longitude,
            ),
          ]),
      schedule: s,
      now: now,
    );
    return TtDemoDay(
      day: day,
      alerts: <TtDemoAlert>[
        if (day.lateMinutes > 0)
          TtDemoAlert(
              type: 'late_arrival', at: checkIn, minutesOver: day.lateMinutes),
      ],
    );
  }
}
