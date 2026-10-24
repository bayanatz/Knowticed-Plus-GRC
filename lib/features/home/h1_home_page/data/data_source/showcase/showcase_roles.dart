/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_roles.dart
/// Purpose: Showcase Roles / User Management data: 18 roles (6 active, 6
///          inactive, 6 draft) with their permission switches, 26 user
///          access lines (11 active, 5 scheduled, 5 expiring soon, 5 ended)
///          and 200 System Logs spread from 1 Jan to today. The matching
///          account states (User Access: active, deactivated, locked, locked
///          with request, scheduled deactivation, scheduled activation) live
///          on the employees written by `ShowcaseOrgChart`.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Same document shapes the module writes itself:
///   - `Roles/<id>` from `RoleHistoryModel.toMap` (history lists);
///   - `<module>_module_permissions/<roleId>` as `RoleRepository` writes them
///     (`{switch: [bool]}`), copied from a real role of the company so every
///     switch name is genuine, then varied per role;
///   - `Subscription_Permission_Admin/<roleId>` as `addNewRole` writes it;
///   - `User_Management/<employeeId>` from `UserPermissionHistoryModel.toMap`;
///   - `System Logs/<id>` from `SystemLogsModel.toMap`.
/// Employees come from [ShowcaseOrgChart.roster]; [seed] writes them first.
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_org_chart.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/new_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/models/system_logs_model.dart';

class _R {
  const _R(this.en, this.ar, this.descEn, this.descAr, this.status,
      {this.edited = false});

  final String en;
  final String ar;
  final String descEn;
  final String descAr;
  final RoleStatus status;

  /// Whether the role was edited after creation (a second history entry).
  final bool edited;
}

/// A real role of the company whose permission documents are copied.
class _Template {
  const _Template(this.modules, this.permissions);

  final List<String> modules;

  /// module -> (switch -> current value)
  final Map<String, Map<String, bool>> permissions;
}

class _Place {
  const _Place(this.country, this.city, this.lat, this.long);

  final String country;
  final String city;
  final String lat;
  final String long;
}

class _Op {
  const _Op(this.module, this.action);

  final Modules module;
  final String action;
}

abstract final class ShowcaseRoles {
  static const List<_R> _roles = <_R>[
    // ── Active (6) — the roles users are assigned to ──
    _R(
        'Department Manager',
        'مدير إدارة',
        'Approves requests, reviews team activity and follows departmental performance indicators.',
        'يعتمد الطلبات ويراجع نشاط الفريق ويتابع مؤشرات أداء الإدارة.',
        RoleStatus.active,
        edited: true),
    _R(
        'Data Governance Lead',
        'قائد حوكمة البيانات',
        'Owns data policies, stewardship assignments and the quality exception register.',
        'يمتلك سياسات البيانات وتكليفات أمناء البيانات وسجل استثناءات الجودة.',
        RoleStatus.active),
    _R(
        'Service Desk Supervisor',
        'مشرف مكتب الخدمة',
        'Assigns and escalates service requests and monitors response-time targets.',
        'يوزّع طلبات الخدمة ويصعّدها ويراقب مستهدفات زمن الاستجابة.',
        RoleStatus.active,
        edited: true),
    _R(
        'Knowledge Management Specialist',
        'أخصائي إدارة المعرفة',
        'Publishes and maintains knowledge articles, policies and approved procedures.',
        'ينشر المقالات المعرفية والسياسات والإجراءات المعتمدة ويحدّثها.',
        RoleStatus.active),
    _R(
        'Compliance Reviewer',
        'مراجع الامتثال',
        'Reviews controls, approvals and activity logs against regulatory requirements.',
        'يراجع الضوابط والموافقات وسجلات النشاط وفق المتطلبات التنظيمية.',
        RoleStatus.active,
        edited: true),
    _R(
        'Operations Coordinator',
        'منسق العمليات',
        'Coordinates daily operations, follows tasks across teams and reports progress.',
        'ينسق العمليات اليومية ويتابع المهام بين الفرق ويرفع تقارير الإنجاز.',
        RoleStatus.active),
    // ── Inactive (6) — created active, switched off later ──
    _R(
        'Regional Coordinator',
        'منسق إقليمي',
        'Coordinates regional office requests and follows field visits.',
        'ينسق طلبات المكاتب الإقليمية ويتابع الزيارات الميدانية.',
        RoleStatus.inactive),
    _R(
        'Training Coordinator',
        'منسق التدريب',
        'Schedules training sessions and tracks attendance and certificates.',
        'يجدول الدورات التدريبية ويتابع الحضور والشهادات.',
        RoleStatus.inactive),
    _R(
        'Facilities Supervisor',
        'مشرف المرافق',
        'Follows maintenance requests, building access and facility bookings.',
        'يتابع طلبات الصيانة وصلاحيات دخول المباني وحجوزات المرافق.',
        RoleStatus.inactive),
    _R(
        'Vendor Relations Officer',
        'مسؤول علاقات الموردين',
        'Maintains supplier records, contracts and performance reviews.',
        'يحتفظ بسجلات الموردين والعقود وتقييمات الأداء.',
        RoleStatus.inactive),
    _R(
        'Events Coordinator',
        'منسق الفعاليات',
        'Plans official events, invitations and guest registrations.',
        'يخطط للفعاليات الرسمية والدعوات وتسجيل الضيوف.',
        RoleStatus.inactive),
    _R(
        'Archive Clerk',
        'كاتب الأرشيف',
        'Registers incoming documents and maintains the physical and digital archive.',
        'يسجّل الوثائق الواردة ويحافظ على الأرشيف الورقي والرقمي.',
        RoleStatus.inactive),
    // ── Draft (6) — saved for later ──
    _R(
        'Risk Assessment Reviewer',
        'مراجع تقييم المخاطر',
        'Reviews risk assessments and mitigation plans before they reach the committee.',
        'يراجع تقييمات المخاطر وخطط المعالجة قبل رفعها إلى اللجنة.',
        RoleStatus.draft),
    _R(
        'Policy Compliance Officer',
        'مسؤول الامتثال للسياسات',
        'Checks departmental practice against published policies and reports gaps.',
        'يتحقق من ممارسات الإدارات مقابل السياسات المنشورة ويرفع الفجوات.',
        RoleStatus.draft),
    _R(
        'Business Continuity Planner',
        'مخطط استمرارية الأعمال',
        'Maintains continuity plans and coordinates readiness exercises.',
        'يحدّث خطط استمرارية الأعمال وينسق تمارين الجاهزية.',
        RoleStatus.draft),
    _R(
        'Performance Analyst',
        'محلل الأداء',
        'Builds performance dashboards and analyses indicator trends.',
        'يبني لوحات الأداء ويحلل اتجاهات المؤشرات.',
        RoleStatus.draft),
    _R(
        'Quality Auditor',
        'مدقق الجودة',
        'Audits service quality records and reports corrective actions.',
        'يدقق سجلات جودة الخدمة ويرفع الإجراءات التصحيحية.',
        RoleStatus.draft),
    _R(
        'Reporting Specialist',
        'أخصائي التقارير',
        'Prepares periodic management reports and statistical summaries.',
        'يعد التقارير الإدارية الدورية والملخصات الإحصائية.',
        RoleStatus.draft),
  ];

  /// Used only when the company has no role to copy permissions from.
  static const List<String> _fallbackModules = <String>[
    'settings',
    'todo',
    'time_tracker',
    'messages',
    'knowledge_hub',
    'services',
  ];

  static const List<_Place> _places = <_Place>[
    _Place('Saudi Arabia', 'Riyadh', '24.7136', '46.6753'),
    _Place('Saudi Arabia', 'Riyadh', '24.7136', '46.6753'),
    _Place('Saudi Arabia', 'Riyadh', '24.7136', '46.6753'),
    _Place('Saudi Arabia', 'Jeddah', '21.5433', '39.1728'),
    _Place('Saudi Arabia', 'Dammam', '26.4207', '50.0888'),
    _Place('Saudi Arabia', 'Madinah', '24.5247', '39.5692'),
    _Place('United Arab Emirates', 'Dubai', '25.2048', '55.2708'),
  ];

  static const List<_Op> _ops = <_Op>[
    _Op(Modules.roles, 'view role management home'),
    _Op(Modules.roles, 'view user management home'),
    _Op(Modules.roles, 'grant user access'),
    _Op(Modules.roles, 'update user access'),
    _Op(Modules.roles, 'create role'),
    _Op(Modules.roles, 'update role'),
    _Op(Modules.roles, 'export users'),
    _Op(Modules.roles, 'activate account'),
    _Op(Modules.roles, 'deactivate account'),
    _Op(Modules.roles, 'unlock account'),
    _Op(Modules.services, 'create service request'),
    _Op(Modules.services, 'approve service request'),
    _Op(Modules.timeTracker, 'check in'),
    _Op(Modules.timeTracker, 'check out'),
    _Op(Modules.timeTracker, 'create time tracker request'),
    _Op(Modules.todo, 'create task'),
    _Op(Modules.todo, 'complete task'),
    _Op(Modules.knowledgeHub, 'open knowledge document'),
    _Op(Modules.knowledgeHub, 'create knowledge article'),
    _Op(Modules.settings, 'update personal information'),
    _Op(Modules.settings, 'submit change request'),
    _Op(Modules.messages, 'view messages'),
    _Op(Modules.employees, 'view organization chart'),
    _Op(Modules.employees, 'view employee profile'),
    _Op(Modules.home, 'view home'),
  ];

  static const int _logCount = 200;

  static int _hash(String s) =>
      s.codeUnits.fold<int>(7, (int a, int b) => (a * 31 + b) & 0x7fffffff);

  static bool _isMeta(String key) => key == 'Role_Id' || key == 'timestamps';

  static bool _currentOf(Object? value) {
    if (value is List) {
      return value.isNotEmpty && value.last == true;
    }
    return value == true;
  }

  /// Function Name: [_findTemplate]
  ///
  /// Purpose: A real, active role of the company (not a showcase one) that
  /// has permission documents, so the switch names are the app's own.
  /// Reads only.
  static Future<_Template?> _findTemplate(FirebaseFirestore db) async {
    for (final String collection in <String>[
      RoleRepository.kRolesCollection,
      RoleRepository.kSubscriptionAdminCollection,
    ]) {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await db.collection(getBaseUrl(collection)).get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
        if (doc.id.startsWith(ShowcaseCommon.idPrefix)) continue;
        final RoleHistoryModel role;
        try {
          role = RoleHistoryModel.fromMap(
              <String, dynamic>{...doc.data(), '_documentId': doc.id});
        } catch (_) {
          continue;
        }
        if (role.currentStatus != RoleStatus.active) continue;
        final List<String> modules = <String>[
          for (final String m in role.currentSelectedModules)
            if (m != 'hr' && m != 'crm') m,
        ];
        if (modules.length < 3) continue;
        final Map<String, Map<String, bool>> permissions =
            <String, Map<String, bool>>{};
        for (final String module in modules) {
          final String permCollection =
              RoleRepository.permissionCollectionFor(module);
          if (permCollection.isEmpty) continue;
          final DocumentSnapshot<Map<String, dynamic>> perm = await db
              .collection(getBaseUrl(permCollection))
              .doc(role.roleId)
              .get();
          final Map<String, dynamic>? data = perm.data();
          if (data == null) continue;
          permissions[module] = <String, bool>{
            for (final MapEntry<String, dynamic> e in data.entries)
              if (!_isMeta(e.key)) e.key: _currentOf(e.value),
          };
        }
        if (permissions.isNotEmpty) {
          return _Template(
              modules.where(permissions.containsKey).toList(), permissions);
        }
      }
    }
    return null;
  }

  /// Function Name: [seed]
  ///
  /// Purpose: Writes the roles with their permissions, the user access lines
  /// and the System Logs; returns how many documents were written (the
  /// employees themselves are counted by the Org Chart showcase).
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required bool isArabic,
    required DateTime now,
  }) async {
    // The people the access lines and logs point at must exist first.
    await ShowcaseOrgChart.seedEmployees(
        firestore: firestore, me: me, now: now);

    final _Template? template = await _findTemplate(firestore);
    final String companyId =
        getBaseUrl('').split('/').where((String s) => s.isNotEmpty).last;
    final List<void Function(WriteBatch)> ops = <void Function(WriteBatch)>[];

    // ── 1. Roles + permission documents ──────────────────────────────────
    final CollectionReference<Map<String, dynamic>> rolesCol =
        firestore.collection(getBaseUrl(RoleRepository.kRolesCollection));
    final CollectionReference<Map<String, dynamic>> subAdminCol =
        firestore.collection(
            getBaseUrl(RoleRepository.kSubscriptionPermissionAdminCollection));
    for (int i = 0; i < _roles.length; i++) {
      final _R r = _roles[i];
      final String roleId = ShowcaseCommon.id('role', i + 1);
      final DateTime created = ShowcaseCommon.spread(i, _roles.length, now,
          endGap: const Duration(days: 45));
      final String creator = ShowcaseCommon.person(i).email;
      final String editor = ShowcaseCommon.person(i + 2).email;

      final List<String> allModules = template?.modules ?? _fallbackModules;
      final int keep =
          (allModules.length - (i % 4)).clamp(3, allModules.length);
      final List<String> modules = allModules.take(keep).toList();

      // History: [created] or [created, changed].
      final bool changed = r.status == RoleStatus.inactive || r.edited;
      final DateTime changedAt = created.add(Duration(days: 20 + (i * 5) % 40));
      final int entries = changed ? 2 : 1;
      final List<String> statuses = <String>[
        if (r.status == RoleStatus.inactive) RoleStatus.active.name,
        if (r.status != RoleStatus.inactive) r.status.name,
        if (changed) r.status.name,
      ];
      final RoleHistoryModel history = RoleHistoryModel(
        roleId: roleId,
        timestamps: <int>[
          created.millisecondsSinceEpoch,
          if (changed) changedAt.millisecondsSinceEpoch,
        ],
        roleName: List<String>.filled(entries, r.en),
        roleNameAr: List<String>.filled(entries, r.ar),
        roleDescription: List<String>.filled(entries, r.descEn),
        roleDescriptionAr: List<String>.filled(entries, r.descAr),
        roleImage: List<String>.filled(entries, ''),
        createdAt: List<Timestamp>.filled(entries, Timestamp.fromDate(created)),
        createdBy: List<String>.filled(entries, creator),
        status: statuses.take(entries).toList(),
        selectedModules: List<List<String>>.filled(entries, modules),
        editBy: <String>[
          jsonEncode(<String, dynamic>{
            'Editor_Email': <String>[],
            'Timestamp': <int>[],
          }),
          if (changed)
            jsonEncode(<String, dynamic>{
              'Editor_Email': <String>[editor],
              'Timestamp': <int>[changedAt.millisecondsSinceEpoch],
            }),
        ],
      );
      ops.add((WriteBatch b) => b.set(rolesCol.doc(roleId), history.toMap()));

      // Permission switches: the template's, with some switched off for
      // two of every three roles, so roles differ from each other.
      final Map<String, Map<String, bool>> adminData =
          <String, Map<String, bool>>{};
      if (template != null) {
        for (final String module in modules) {
          final Map<String, bool>? source = template.permissions[module];
          if (source == null) continue;
          final String collection =
              RoleRepository.permissionCollectionFor(module);
          if (collection.isEmpty) continue;
          final Map<String, bool> values = <String, bool>{
            for (final MapEntry<String, bool> e in source.entries)
              e.key: e.value && !(i % 3 != 0 && (_hash(e.key) + i) % 4 == 0),
          };
          adminData[module] = values;
          ops.add((WriteBatch b) => b.set(
                firestore.collection(getBaseUrl(collection)).doc(roleId),
                <String, dynamic>{
                  'Role_Id': roleId,
                  'timestamps': <int>[created.millisecondsSinceEpoch],
                  for (final MapEntry<String, bool> e in values.entries)
                    e.key: <bool>[e.value],
                },
              ));
        }
      }
      ops.add((WriteBatch b) => b.set(
            subAdminCol.doc(roleId),
            RoleRepository.buildSubscriptionPermissionAdminData(
              companyId: companyId,
              roleId: roleId,
              selectedModules: modules,
              validatedPermissions: adminData,
              timestamps: <int>[created.millisecondsSinceEpoch],
            ),
          ));
    }

    // ── 2. User Management: access lines ─────────────────────────────────
    final CollectionReference<Map<String, dynamic>> accessCol =
        firestore.collection(getBaseUrl('User_Management'));
    final List<ShowcaseStaff> holders = <ShowcaseStaff>[
      for (final ShowcaseStaff s in ShowcaseOrgChart.roster)
        if (s.access != ShowcaseAccess.none) s,
    ];
    for (int k = 0; k < holders.length; k++) {
      final ShowcaseStaff s = holders[k];
      final DateTime from;
      final DateTime to;
      switch (s.access) {
        case ShowcaseAccess.none:
          continue;
        case ShowcaseAccess.active:
          from = now.subtract(Duration(days: 40 + (s.n * 17) % 260));
          to = now.add(Duration(days: 150 + (s.n * 13) % 200));
        case ShowcaseAccess.scheduled:
          from = now.add(Duration(days: 4 + (s.n * 7) % 40));
          to = from.add(const Duration(days: 365));
        case ShowcaseAccess.expiringSoon:
          from = now.subtract(const Duration(days: 300));
          to = now.add(Duration(days: 2 + (s.n * 3) % 10));
        case ShowcaseAccess.ended:
          from = now.subtract(const Duration(days: 400));
          to = now.subtract(Duration(days: 9 + (s.n * 11) % 80));
      }
      final String role = ShowcaseRoleNames.active[s.accessRole];
      final String grantor = ShowcaseCommon.person(s.n % 5).email;
      final DateTime grantedAt = s.access == ShowcaseAccess.scheduled
          ? now.subtract(Duration(days: 2 + s.n % 9))
          : ShowcaseCommon.spread(k, holders.length, now,
              endGap: const Duration(days: 20));
      // Every third line was re-assigned once: an earlier role, then this.
      final bool reassigned = s.n % 3 == 0;
      final UserPermissionHistoryModel line = UserPermissionHistoryModel(
        employeeId: s.id,
        timestamps: <int>[
          if (reassigned)
            grantedAt.subtract(const Duration(days: 60)).millisecondsSinceEpoch,
          grantedAt.millisecondsSinceEpoch,
        ],
        role: <String>[
          if (reassigned) ShowcaseRoleNames.active[(s.accessRole + 1) % 6],
          role,
        ],
        fromDate: <String>[
          if (reassigned)
            ShowcaseOrgChart.accessDate(
                from.subtract(const Duration(days: 60))),
          ShowcaseOrgChart.accessDate(from),
        ],
        toDate: <String>[
          if (reassigned) ShowcaseOrgChart.accessDate(to),
          ShowcaseOrgChart.accessDate(to),
        ],
        editBy: <String>[
          if (reassigned) grantor,
          grantor,
        ],
      );
      ops.add((WriteBatch b) => b.set(accessCol.doc(s.id), line.toMap()));
    }

    // ── 3. System Logs: 200 entries, 1 Jan → today ───────────────────────
    final CollectionReference<Map<String, dynamic>> logsCol =
        firestore.collection(ApiConstants.systemLogs);
    final String domain = ShowcaseOrgChart.domainOf(me);
    for (int i = 0; i < _logCount; i++) {
      final _Op op = _ops[(i * 7 + i ~/ 5) % _ops.length];
      final _Place place = _places[(i * 3) % _places.length];
      final DateTime at = ShowcaseCommon.spread(i, _logCount, now,
          endGap: const Duration(hours: 2));
      String email;
      String first;
      String last;
      String firstAr;
      String lastAr;
      String role;
      if (i % 2 == 0) {
        final ShowcaseStaff s = ShowcaseOrgChart
            .roster[(i ~/ 2 * 5) % ShowcaseOrgChart.roster.length];
        email = s.email(domain);
        first = s.first;
        last = s.last;
        firstAr = s.firstAr;
        lastAr = s.lastAr;
        role = s.roleName ?? s.titleEn;
      } else {
        final ShowcasePerson p = ShowcaseCommon.person(i ~/ 2);
        email = p.email;
        final List<String> en = p.nameEn.split(' ');
        final List<String> ar = p.nameAr.split(' ');
        first = en.first;
        last = en.length > 1 ? en.sublist(1).join(' ') : '';
        firstAr = ar.first;
        lastAr = ar.length > 1 ? ar.sublist(1).join(' ') : '';
        role = p.titleEn.isNotEmpty
            ? p.titleEn
            : ShowcaseRoleNames.active[i % ShowcaseRoleNames.active.length];
      }
      final String id = ShowcaseCommon.id('syslog', i + 1);
      ops.add((WriteBatch b) => b.set(
            logsCol.doc(id),
            SystemLogsModel(
              module: op.module,
              userEmail: email,
              firstName: first,
              middleName: '',
              lastName: last,
              firstNameInArabic: firstAr,
              middleNameInArabic: '',
              lastNameInArabic: lastAr,
              role: role,
              country: place.country,
              city: place.city,
              lat: place.lat,
              long: place.long,
              action: op.action,
              timestamp: Timestamp.fromDate(DateTime(at.year, at.month, at.day,
                  at.hour, at.minute, (i * 13) % 60)),
            ).toMap(),
          ));
    }

    // ── commit in chunks of 400 ──────────────────────────────────────────
    for (int start = 0; start < ops.length; start += 400) {
      final WriteBatch batch = firestore.batch();
      final int end = start + 400 > ops.length ? ops.length : start + 400;
      for (final void Function(WriteBatch) op in ops.sublist(start, end)) {
        op(batch);
      }
      await batch.commit();
    }
    return ops.length;
  }
}
