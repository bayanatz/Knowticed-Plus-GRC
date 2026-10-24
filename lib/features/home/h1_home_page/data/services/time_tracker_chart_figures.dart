// [module-file:time_tracker] — deleted when the time_tracker module is split out
/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_chart_figures.dart
/// Purpose: Declares `timeTrackerChartFigures` — the real counters behind the
///          Time Tracker entries of the Chart & Graph catalog — and
///          `TimeTrackerChartLive`, which keeps them current.
///
///          The status counts are the SAME numbers the Home Time Tracker cards
///          show (`TimeTrackerHomeStatsRules`, this month, the employee's own
///          attendance and requests), so a chart never disagrees with a card.
/// Author: Knowticed Plus team
/// Created at: 24/10/2026
library;

import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_chart_live.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/time_tracker_home_cards_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/hr_dashboard_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_type_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_scope.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/home_widget_stats.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';

/// Function Name: [attendanceRatePerMonth]
///
/// Purpose: For each of the last six months, oldest first: the share (0–100)
///   of counted days the employee was present or late. Absent days count
///   against; leave days (vacation, sick, excused) and days with no stored
///   status do not count at all. A month with nothing counted reads 0.
List<double> attendanceRatePerMonth(List<AttendanceDay> days, DateTime now) {
  return <double>[
    for (int back = 5; back >= 0; back--)
      () {
        final DateTime month = DateTime(now.year, now.month - back);
        int attended = 0;
        int counted = 0;
        for (final AttendanceDay d in days) {
          if (d.date.year != month.year || d.date.month != month.month) {
            continue;
          }
          switch (d.status) {
            case AttendanceStatus.present:
            case AttendanceStatus.late:
              attended++;
              counted++;
            case AttendanceStatus.absent:
              counted++;
            default:
              break;
          }
        }
        return counted == 0 ? 0.0 : (attended * 100 / counted).roundToDouble();
      }(),
  ];
}

/// Function Name: [timeTrackerChartFigures]
///
/// Purpose: One list per wired catalog value, in the catalog's series order.
///   - `attendance`: Present · Absent · Late (this month, as the Home card).
///   - `requests`: Approved · Pending (incl. under review) · Rejected — the
///     employee's own requests, as the My Requests card counts them.
///   - `attendance_rate`: [attendanceRatePerMonth].
Map<String, List<double>> timeTrackerChartFigures(
    TimeTrackerHomeStats stats, List<AttendanceDay> days, DateTime now) {
  return <String, List<double>>{
    'attendance': <double>[
      stats.present.toDouble(),
      stats.absent.toDouble(),
      stats.late.toDouble(),
    ],
    'requests': <double>[
      stats.myCount(RequestBucket.approved).toDouble(),
      (stats.myCount(RequestBucket.pending) +
              stats.myCount(RequestBucket.underReview))
          .toDouble(),
      stats.myCount(RequestBucket.rejected).toDouble(),
    ],
    'attendance_rate': attendanceRatePerMonth(days, now),
  };
}

/// Function Name: [requestsByType]
///
/// Purpose: The five request types with the most requests, most first, named
///   from [types]; requests of a type that no longer exists (and
///   transactions without one) are counted together as "Other". Canceled
///   requests do not count.
List<HomeChartLiveSeries> requestsByType(
    List<TimeTrackerRequest> requests, Map<String, RequestType> types) {
  final Map<String, int> counts = <String, int>{};
  int other = 0;
  for (final TimeTrackerRequest r in requests) {
    if (r.status == RequestStatus.canceled ||
        r.status == RequestStatus.canceledByHr) {
      continue;
    }
    if (types.containsKey(r.requestTypeId)) {
      counts[r.requestTypeId] = (counts[r.requestTypeId] ?? 0) + 1;
    } else {
      other++;
    }
  }
  final List<MapEntry<String, int>> top = counts.entries.toList()
    ..sort((MapEntry<String, int> a, MapEntry<String, int> b) {
      final int c = b.value.compareTo(a.value);
      return c != 0 ? c : a.key.compareTo(b.key);
    });
  return <HomeChartLiveSeries>[
    for (final MapEntry<String, int> e in top.take(5))
      HomeChartLiveSeries(types[e.key]!.name(isArabic: false),
          types[e.key]!.name(isArabic: true), e.value.toDouble()),
    if (other > 0) HomeChartLiveSeries('Other', 'أخرى', other.toDouble()),
  ];
}

/// Function Name: [attendanceByDepartment]
///
/// Purpose: This month's attended days (present or late) per department of
///   the [employees] given, the five busiest first. A department with no
///   attended day is left out.
List<HomeChartLiveSeries> attendanceByDepartment(
    List<TimeTrackerEmployee> employees,
    List<AttendanceDay> days,
    DateTime now) {
  final Map<String, TimeTrackerEmployee> byEmail =
      <String, TimeTrackerEmployee>{
    for (final TimeTrackerEmployee e in employees) e.email.toLowerCase(): e,
  };
  final Map<String, int> counts = <String, int>{};
  final Map<String, TimeTrackerEmployee> sample =
      <String, TimeTrackerEmployee>{};
  for (final AttendanceDay d in days) {
    if (d.date.year != now.year || d.date.month != now.month) continue;
    if (d.status != AttendanceStatus.present &&
        d.status != AttendanceStatus.late) {
      continue;
    }
    final TimeTrackerEmployee? e = byEmail[d.employeeEmail.toLowerCase()];
    if (e == null) continue;
    final String key =
        e.departmentId.isEmpty ? e.departmentName : e.departmentId;
    counts[key] = (counts[key] ?? 0) + 1;
    sample[key] = e;
  }
  final List<MapEntry<String, int>> top = counts.entries.toList()
    ..sort((MapEntry<String, int> a, MapEntry<String, int> b) {
      final int c = b.value.compareTo(a.value);
      return c != 0 ? c : a.key.compareTo(b.key);
    });
  String pick(String a, String b) => a.isNotEmpty ? a : b;
  return <HomeChartLiveSeries>[
    for (final MapEntry<String, int> e in top.take(5))
      HomeChartLiveSeries(
        pick(sample[e.key]!.departmentNameEn, sample[e.key]!.departmentName),
        pick(sample[e.key]!.departmentNameAr, sample[e.key]!.departmentName),
        e.value.toDouble(),
      ),
  ];
}

/// Keeps the Time Tracker figures of [HomeChartLive] current while Home is open.
class TimeTrackerChartLive {
  TimeTrackerChartLive._();

  static TimeTrackerHomeCardsCubit? _cubit;
  static StreamSubscription<TimeTrackerHomeCardsState>? _cubitSub;
  static StreamSubscription<List<AttendanceDay>>? _daysSub;
  static String _owner = '';
  static List<AttendanceDay> _days = const <AttendanceDay>[];
  static TimeTrackerHomeStats? _stats;

  static void _publish() {
    final TimeTrackerHomeStats? stats = _stats;
    if (stats == null) return;
    HomeChartLive.instance.publish(
        'timeTracker', timeTrackerChartFigures(stats, _days, DateTime.now()));
  }

  /// Start listening (once per signed-in employee). Does nothing when Time
  /// Tracker is not set up or the employee cannot view it.
  static void ensureStarted() {
    final GetIt sl = GetIt.instance;
    if (!sl.isRegistered<TimeTrackerAccess>() ||
        !sl.isRegistered<AttendanceBaseRepository>()) {
      return;
    }
    final TimeTrackerAccess access = sl<TimeTrackerAccess>();
    final String owner = access.currentUserEmail;
    if (owner.isEmpty || !access.canView) return;
    if (_cubit != null && _owner == owner) return;
    _cubitSub?.cancel();
    _daysSub?.cancel();
    _cubit?.close();
    _owner = owner;
    _stats = null;
    final TimeTrackerHomeCardsCubit cubit = TimeTrackerHomeCardsCubit()
      ..init(TimeTrackerHomeCard.totals);
    _cubit = cubit;
    _cubitSub = cubit.stream.listen((TimeTrackerHomeCardsState s) {
      if (!s.isReady) return;
      _stats = s.stats;
      _publish();
    });
    _daysSub = sl<AttendanceBaseRepository>()
        .watchEmployeeAttendance(employeeEmail: owner)
        .listen((List<AttendanceDay> days) {
      _days = days;
      _publish();
      if (!access.canViewHrDashboard) _publishOwnDepartment(access);
    }, onError: (Object _) {});
    _startByType(sl, access);
    unawaited(_loadByDepartment(sl, access));
  }

  /// Without the HR dashboard: the employee's own department, from their own days.
  static void _publishOwnDepartment(TimeTrackerAccess access) {
    final TimeTrackerIdentity me = access.identity;
    HomeChartLive.instance.publishLabelled(
        'timeTracker',
        'attendance_by_department',
        attendanceByDepartment(<TimeTrackerEmployee>[
          TimeTrackerEmployee(
            email: me.email,
            nameEn: me.nameEn,
            nameAr: me.nameAr,
            departmentId: me.departmentId,
            departmentName: me.departmentName,
          ),
        ], _days, DateTime.now()));
  }

  static StreamSubscription<List<TimeTrackerRequest>>? _typeReqSub;
  static StreamSubscription<List<RequestType>>? _typeSub;
  static List<TimeTrackerRequest> _reqs = const <TimeTrackerRequest>[];
  static Map<String, RequestType> _types = const <String, RequestType>{};
  static bool _reqsLoaded = false;
  static bool _typesLoaded = false;

  static void _publishByType() {
    if (!_reqsLoaded || !_typesLoaded) return;
    HomeChartLive.instance.publishLabelled(
        'timeTracker', 'requests_by_type', requestsByType(_reqs, _types));
  }

  /// Requests by type: the whole company's for an approver / HR dashboard
  /// holder, the employee's own for everyone else — the same scope the
  /// Time Tracker lists use.
  static void _startByType(GetIt sl, TimeTrackerAccess access) {
    _typeReqSub?.cancel();
    _typeSub?.cancel();
    _reqsLoaded = false;
    _typesLoaded = false;
    if (!sl.isRegistered<RequestBaseRepository>() ||
        !sl.isRegistered<RequestTypeBaseRepository>()) {
      return;
    }
    final RequestBaseRepository requests = sl<RequestBaseRepository>();
    final Stream<List<TimeTrackerRequest>> feed = access.readsCompanyRequests
        ? requests.watchRequests()
        : requests.watchRequestsOf(email: access.currentUserEmail);
    _typeReqSub = feed.listen((List<TimeTrackerRequest> list) {
      _reqs = list;
      _reqsLoaded = true;
      _publishByType();
    }, onError: (Object _) {});
    _typeSub = sl<RequestTypeBaseRepository>().watchRequestTypes().listen(
        (List<RequestType> list) {
      _types = <String, RequestType>{for (final RequestType t in list) t.id: t};
      _typesLoaded = true;
      _publishByType();
    }, onError: (Object _) {});
  }

  /// Attendance by department: every department the HR dashboard shows the
  /// employee (all, or their own), read once per start; without the HR
  /// dashboard only the employee's own days and department.
  static Future<void> _loadByDepartment(
      GetIt sl, TimeTrackerAccess access) async {
    final DateTime now = DateTime.now();
    List<HomeChartLiveSeries> series = const <HomeChartLiveSeries>[];
    try {
      if (access.canViewHrDashboard &&
          sl.isRegistered<EmployeeDirectoryBaseRepository>() &&
          sl.isRegistered<HrDashboardBaseRepository>()) {
        final List<TimeTrackerEmployee> all =
            await sl<EmployeeDirectoryBaseRepository>()
                .fetchEmployees(isArabic: false);
        final List<TimeTrackerEmployee> people = HrDashboardScope.permitted(
          all,
          allDepartments: access.hrDashboardAllDepartments,
          ownDepartmentId: access.identity.departmentId,
        );
        final List<AttendanceDay> days = await sl<HrDashboardBaseRepository>()
            .fetchAttendance(
                employeeEmails: HrDashboardScope.emailsOf(people),
                span: DateSpan.of(DashboardRange.month, now));
        series = attendanceByDepartment(people, days, now);
      }
    } catch (_) {
      return; // keep what the card has; the next start tries again
    }
    HomeChartLive.instance
        .publishLabelled('timeTracker', 'attendance_by_department', series);
  }
}
