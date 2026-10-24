// [module-file:time_tracker] — deleted when the time_tracker module is split out
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/services/time_tracker_chart_figures.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_chart_live.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/home_widget_stats.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';

AttendanceDay _d(DateTime date, AttendanceStatus? s) => AttendanceDay(
    id: date.toIso8601String(), employeeEmail: 'a@b.c', date: date, status: s);

void main() {
  final DateTime now = DateTime(2026, 10, 24);

  test('attendance rate is present+late over present+late+absent per month',
      () {
    final List<double> r = attendanceRatePerMonth(<AttendanceDay>[
      _d(DateTime(2026, 10, 1), AttendanceStatus.present),
      _d(DateTime(2026, 10, 2), AttendanceStatus.late),
      _d(DateTime(2026, 10, 3), AttendanceStatus.absent),
      _d(DateTime(2026, 10, 4), AttendanceStatus.vacation),
      _d(DateTime(2026, 10, 5), null),
      _d(DateTime(2026, 9, 1), AttendanceStatus.absent),
      _d(DateTime(2026, 9, 2), AttendanceStatus.absent),
    ], now);
    expect(r.length, 6);
    expect(r.last, 67); // 2 of 3
    expect(r[4], 0); // September: only absent days
    expect(r.first, 0); // nothing counted
  });

  test('status counts come from the same stats the Home cards use', () {
    final Map<String, List<double>> f = timeTrackerChartFigures(
      const TimeTrackerHomeStats(
        present: 12,
        absent: 1,
        late: 2,
        myCounts: <RequestBucket, int>{
          RequestBucket.approved: 5,
          RequestBucket.pending: 3,
          RequestBucket.underReview: 1,
          RequestBucket.rejected: 2,
        },
      ),
      const <AttendanceDay>[],
      now,
    );
    expect(f['attendance'], <double>[12, 1, 2]);
    expect(f['requests'], <double>[5, 4, 2]);
    expect(f['attendance_rate'], hasLength(6));
  });

  test('requests by type: named, most first, canceled and unknown handled', () {
    TimeTrackerRequest r(String id, String type, RequestStatus st) =>
        TimeTrackerRequest(
          id: id,
          requesterEmail: 'a@b.c',
          requestTypeId: type,
          startAt: now,
          endAt: now,
          status: st,
        );
    final List<HomeChartLiveSeries> out = requestsByType(<TimeTrackerRequest>[
      r('1', 'leave', RequestStatus.approved),
      r('2', 'leave', RequestStatus.pending),
      r('3', 'perm', RequestStatus.approved),
      r('4', 'perm', RequestStatus.canceled),
      r('5', 'gone', RequestStatus.approved),
    ], <String, RequestType>{
      'leave': const RequestType(id: 'leave', nameEn: 'Leave', nameAr: 'إجازة'),
      'perm':
          const RequestType(id: 'perm', nameEn: 'Permission', nameAr: 'إذن'),
    });
    expect(out.map((HomeChartLiveSeries s) => s.en),
        <String>['Leave', 'Permission', 'Other']);
    expect(out.map((HomeChartLiveSeries s) => s.value), <double>[2, 1, 1]);
    expect(out.first.ar, 'إجازة');
  });

  test('attendance by department counts attended days of this month', () {
    TimeTrackerEmployee e(String mail, String dep, String en, String ar) =>
        TimeTrackerEmployee(
            email: mail,
            departmentId: dep,
            departmentNameEn: en,
            departmentNameAr: ar);
    final List<HomeChartLiveSeries> out = attendanceByDepartment(
      <TimeTrackerEmployee>[
        e('a@x.c', 'd1', 'HR', 'الموارد'),
        e('b@x.c', 'd2', 'IT', 'تقنية'),
        e('c@x.c', 'd2', 'IT', 'تقنية'),
      ],
      <AttendanceDay>[
        _d(DateTime(2026, 10, 1), AttendanceStatus.present),
        AttendanceDay(
            id: '2',
            employeeEmail: 'b@x.c',
            date: DateTime(2026, 10, 1),
            status: AttendanceStatus.present),
        AttendanceDay(
            id: '3',
            employeeEmail: 'c@x.c',
            date: DateTime(2026, 10, 2),
            status: AttendanceStatus.late),
        AttendanceDay(
            id: '4',
            employeeEmail: 'c@x.c',
            date: DateTime(2026, 10, 3),
            status: AttendanceStatus.absent),
        AttendanceDay(
            id: '5',
            employeeEmail: 'c@x.c',
            date: DateTime(2026, 9, 3),
            status: AttendanceStatus.present),
      ],
      now,
    );
    expect(out.map((HomeChartLiveSeries s) => s.en), <String>['IT']);
    expect(out.first.value, 2);
  });
}
