/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_org_chart.dart
/// Purpose: Showcase Organization Chart data: a 37-person leadership and
///          department roster with a real reporting tree (one chief
///          executive, ten department heads, staff under each head) spread
///          over eleven departments, in every account state the Org Chart and
///          User Access screens can show.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// The Org Chart is built from `Employees_Info` (name, title, `Supervisor`
/// email, `Department_Id`) and `Departments`, so that is what is written:
///   - `Employees_Info/showcase_emp_NN` through `NewEmployeeModelHistory.toMap`
///     (the module's own model, history lists with one entry each);
///   - `Departments/<id>` through `DepartmentModelPro.toMap`, only for the
///     departments the company does not already have (matched by English or
///     Arabic name, so the department tabs never show a duplicate).
///
/// The roster is also the people source for the Roles and Messages showcase
/// files ([ShowcaseOrgChart.roster]): access lines, account states and chats
/// all point at these same employees, so the three screens agree.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

/// The state an employee account is in (User Access chips).
enum ShowcaseAccount {
  active,
  deactivated,
  locked,
  lockedWithRequest,

  /// Active now, with a deactivation date still ahead.
  willDeactivate,

  /// Deactivated now, with an activation date still ahead.
  willActivate,
}

/// The state of an employee's role access line (User Management chips).
enum ShowcaseAccess {
  none,
  active,

  /// Granted, starts in the future.
  scheduled,

  /// Ends within the next 12 days.
  expiringSoon,

  /// Ended in the past.
  ended,
}

/// The six active showcase roles users are assigned to (the same names
/// `ShowcaseRoles` creates), indexed by [ShowcaseStaff.accessRole].
abstract final class ShowcaseRoleNames {
  static const List<String> active = <String>[
    'Department Manager',
    'Data Governance Lead',
    'Service Desk Supervisor',
    'Knowledge Management Specialist',
    'Compliance Reviewer',
    'Operations Coordinator',
  ];
}

/// One showcase employee.
class ShowcaseStaff {
  const ShowcaseStaff(
    this.n,
    this.first,
    this.last,
    this.firstAr,
    this.lastAr,
    this.female,
    this.titleEn,
    this.titleAr,
    this.dept,
    this.manager, {
    this.account = ShowcaseAccount.active,
    this.accessRole = 0,
    this.access = ShowcaseAccess.none,
  });

  /// 1-based position in the roster; the document id is
  /// `ShowcaseCommon.id('emp', n)`.
  final int n;
  final String first;
  final String last;
  final String firstAr;
  final String lastAr;
  final bool female;
  final String titleEn;
  final String titleAr;

  /// English department name (one of [ShowcaseOrgChart.departments]).
  final String dept;

  /// Roster number of the manager, 0 for the chief executive.
  final int manager;
  final ShowcaseAccount account;

  /// Index into [ShowcaseRoleNames.active] (used when [access] is not none).
  final int accessRole;
  final ShowcaseAccess access;

  String get id => ShowcaseCommon.id('emp', n);
  String get nameEn => '$first $last';
  String get nameAr => '$firstAr $lastAr';

  /// Work email, lower case: `first.lastname@<domain>`.
  String email(String domain) =>
      '${first.toLowerCase()}.${last.replaceAll('-', '').toLowerCase()}@$domain';

  String? get roleName => access == ShowcaseAccess.none
      ? null
      : ShowcaseRoleNames.active[accessRole];
}

/// A department the roster uses.
class _Dept {
  const _Dept(this.en, this.ar);

  final String en;
  final String ar;
}

abstract final class ShowcaseOrgChart {
  /// Same names as the app's own department filter translations.
  static const List<_Dept> _depts = <_Dept>[
    _Dept('Executive', 'الإدارة التنفيذية'),
    _Dept('Information Technology', 'تقنية المعلومات'),
    _Dept('Data Management', 'إدارة البيانات'),
    _Dept('Finance', 'المالية'),
    _Dept('Operations', 'العمليات'),
    _Dept('Human Resources', 'الموارد البشرية'),
    _Dept('Marketing', 'التسويق'),
    _Dept('Sales', 'المبيعات'),
    _Dept('Customer Support', 'دعم العملاء'),
    _Dept('Compliance & Legal', 'الامتثال والشؤون القانونية'),
    _Dept('Software', 'البرمجيات'),
  ];

  static List<String> get departments =>
      <String>[for (final _Dept d in _depts) d.en];

  static String _deptAr(String en) =>
      _depts.firstWhere((_Dept d) => d.en == en).ar;

  /// The roster. Account states: 5 deactivated, 6 locked (3 plain + 3 with an
  /// unlock request), 5 with a deactivation scheduled, 5 with an activation
  /// scheduled, the rest active. Access lines: 11 active, 5 scheduled, 5
  /// expiring soon, 5 ended.
  static const List<ShowcaseStaff> roster = <ShowcaseStaff>[
    ShowcaseStaff(1, 'Abdulaziz', 'Al-Rashid', 'عبدالعزيز', 'الراشد', false,
        'Chief Executive Officer', 'الرئيس التنفيذي', 'Executive', 0,
        access: ShowcaseAccess.active, accessRole: 0),
    ShowcaseStaff(2, 'Hessa', 'Al-Mansour', 'هيا', 'المنصور', true,
        'Chief of Staff', 'رئيسة مكتب الرئيس التنفيذي', 'Executive', 1),
    ShowcaseStaff(
        3,
        'Tariq',
        'Al-Anazi',
        'طارق',
        'العنزي',
        false,
        'Director of Information Technology',
        'مدير تقنية المعلومات',
        'Information Technology',
        1,
        access: ShowcaseAccess.active,
        accessRole: 0),
    ShowcaseStaff(
        4,
        'Maha',
        'Al-Qahtani',
        'مها',
        'القحطاني',
        true,
        'Director of Data Management',
        'مديرة إدارة البيانات',
        'Data Management',
        1,
        access: ShowcaseAccess.active,
        accessRole: 1),
    ShowcaseStaff(5, 'Saud', 'Al-Harbi', 'سعود', 'الحربي', false,
        'Director of Finance', 'مدير الإدارة المالية', 'Finance', 1,
        access: ShowcaseAccess.active, accessRole: 0),
    ShowcaseStaff(6, 'Bandar', 'Al-Ghamdi', 'بندر', 'الغامدي', false,
        'Director of Operations', 'مدير العمليات', 'Operations', 1,
        access: ShowcaseAccess.active, accessRole: 5),
    ShowcaseStaff(
        7,
        'Dalal',
        'Al-Shehri',
        'دلال',
        'الشهري',
        true,
        'Director of Human Resources',
        'مديرة الموارد البشرية',
        'Human Resources',
        1,
        access: ShowcaseAccess.active,
        accessRole: 0),
    ShowcaseStaff(
        8,
        'Joud',
        'Al-Dosari',
        'جود',
        'الدوسري',
        true,
        'Director of Marketing and Communications',
        'مديرة التسويق والاتصال',
        'Marketing',
        1,
        access: ShowcaseAccess.active,
        accessRole: 3),
    ShowcaseStaff(9, 'Nasser', 'Al-Zahrani', 'ناصر', 'الزهراني', false,
        'Director of Government Sales', 'مدير المبيعات الحكومية', 'Sales', 1,
        access: ShowcaseAccess.active, accessRole: 0),
    ShowcaseStaff(10, 'Amal', 'Al-Mutairi', 'أمل', 'المطيري', true,
        'Head of Customer Support', 'رئيسة دعم العملاء', 'Customer Support', 1,
        access: ShowcaseAccess.active, accessRole: 2),
    ShowcaseStaff(
        11,
        'Majed',
        'Al-Subaie',
        'ماجد',
        'السبيعي',
        false,
        'Director of Compliance and Legal Affairs',
        'مدير الامتثال والشؤون القانونية',
        'Compliance & Legal',
        1,
        access: ShowcaseAccess.active,
        accessRole: 4),
    ShowcaseStaff(
        12,
        'Yousef',
        'Al-Shammari',
        'يوسف',
        'الشمري',
        false,
        'Director of Software Engineering',
        'مدير هندسة البرمجيات',
        'Software',
        1,
        access: ShowcaseAccess.active,
        accessRole: 0),
    ShowcaseStaff(13, 'Fahad', 'Al-Dossary', 'فهد', 'الدوسري', false,
        'Network Engineer', 'مهندس شبكات', 'Information Technology', 3,
        access: ShowcaseAccess.scheduled, accessRole: 5),
    ShowcaseStaff(
        14,
        'Ghada',
        'Al-Harthi',
        'غادة',
        'الحارثي',
        true,
        'Information Security Analyst',
        'محللة أمن المعلومات',
        'Information Technology',
        3,
        account: ShowcaseAccount.willDeactivate,
        access: ShowcaseAccess.expiringSoon,
        accessRole: 4),
    ShowcaseStaff(15, 'Ziyad', 'Al-Juhani', 'زياد', 'الجهني', false,
        'Systems Administrator', 'مدير أنظمة', 'Information Technology', 3,
        account: ShowcaseAccount.deactivated,
        access: ShowcaseAccess.ended,
        accessRole: 5),
    ShowcaseStaff(16, 'Rawan', 'Al-Otaibi', 'روان', 'العتيبي', true,
        'Data Quality Lead', 'قائدة جودة البيانات', 'Data Management', 4,
        access: ShowcaseAccess.scheduled, accessRole: 1),
    ShowcaseStaff(
        17,
        'Hamad',
        'Al-Tamimi',
        'حمد',
        'التميمي',
        false,
        'Data Governance Specialist',
        'أخصائي حوكمة البيانات',
        'Data Management',
        4,
        account: ShowcaseAccount.locked),
    ShowcaseStaff(18, 'Layan', 'Al-Rajhi', 'ليان', 'الراجحي', true,
        'Master Data Analyst', 'محللة البيانات الرئيسية', 'Data Management', 4,
        account: ShowcaseAccount.willDeactivate,
        access: ShowcaseAccess.expiringSoon,
        accessRole: 1),
    ShowcaseStaff(19, 'Mishal', 'Al-Maliki', 'مشعل', 'المالكي', false,
        'Data Steward', 'أمين بيانات', 'Data Management', 4,
        account: ShowcaseAccount.deactivated,
        access: ShowcaseAccess.ended,
        accessRole: 1),
    ShowcaseStaff(20, 'Abeer', 'Al-Khaldi', 'عبير', 'الخالدي', true,
        'Senior Accountant', 'محاسبة أولى', 'Finance', 5,
        account: ShowcaseAccount.willActivate),
    ShowcaseStaff(21, 'Waleed', 'Al-Balawi', 'وليد', 'البلوي', false,
        'Budget Analyst', 'محلل ميزانيات', 'Finance', 5,
        account: ShowcaseAccount.locked),
    ShowcaseStaff(22, 'Shahad', 'Al-Salem', 'شهد', 'السالم', true,
        'Procurement Specialist', 'أخصائية مشتريات', 'Finance', 5,
        account: ShowcaseAccount.willDeactivate,
        access: ShowcaseAccess.expiringSoon,
        accessRole: 5),
    ShowcaseStaff(23, 'Turki', 'Al-Rasheed', 'تركي', 'الرشيد', false,
        'Operations Coordinator', 'منسق عمليات', 'Operations', 6,
        account: ShowcaseAccount.lockedWithRequest,
        access: ShowcaseAccess.scheduled,
        accessRole: 5),
    ShowcaseStaff(24, 'Hanan', 'Al-Yami', 'حنان', 'اليامي', true,
        'Service Delivery Manager', 'مديرة تقديم الخدمة', 'Operations', 6,
        account: ShowcaseAccount.willActivate),
    ShowcaseStaff(25, 'Sultan', 'Al-Mutlaq', 'سلطان', 'المطلق', false,
        'Facilities Supervisor', 'مشرف مرافق', 'Operations', 6,
        account: ShowcaseAccount.deactivated,
        access: ShowcaseAccess.ended,
        accessRole: 5),
    ShowcaseStaff(
        26,
        'Najla',
        'Al-Fahad',
        'نجلاء',
        'الفهد',
        true,
        'Talent Acquisition Specialist',
        'أخصائية استقطاب المواهب',
        'Human Resources',
        7,
        account: ShowcaseAccount.willActivate),
    ShowcaseStaff(
        27,
        'Ibrahim',
        'Al-Sudairi',
        'إبراهيم',
        'السديري',
        false,
        'Learning and Development Officer',
        'مسؤول التعلم والتطوير',
        'Human Resources',
        7,
        account: ShowcaseAccount.locked,
        access: ShowcaseAccess.scheduled,
        accessRole: 3),
    ShowcaseStaff(28, 'Lujain', 'Al-Hamad', 'لجين', 'الحمد', true,
        'Media Relations Officer', 'مسؤولة العلاقات الإعلامية', 'Marketing', 8,
        account: ShowcaseAccount.willDeactivate),
    ShowcaseStaff(29, 'Rakan', 'Al-Bishi', 'راكان', 'البيشي', false,
        'Content Strategist', 'مخطط محتوى', 'Marketing', 8,
        account: ShowcaseAccount.deactivated,
        access: ShowcaseAccess.ended,
        accessRole: 3),
    ShowcaseStaff(30, 'Atheer', 'Al-Qarni', 'أثير', 'القرني', true,
        'Government Account Manager', 'مديرة حسابات حكومية', 'Sales', 9,
        account: ShowcaseAccount.willActivate),
    ShowcaseStaff(31, 'Mansour', 'Al-Jabri', 'منصور', 'الجابري', false,
        'Business Development Manager', 'مدير تطوير الأعمال', 'Sales', 9,
        account: ShowcaseAccount.lockedWithRequest),
    ShowcaseStaff(32, 'Reema', 'Al-Zamil', 'ريما', 'الزامل', true,
        'Service Desk Supervisor', 'مشرفة مكتب الخدمة', 'Customer Support', 10,
        access: ShowcaseAccess.scheduled, accessRole: 2),
    ShowcaseStaff(
        33,
        'Hatem',
        'Al-Najjar',
        'حاتم',
        'النجار',
        false,
        'Customer Success Specialist',
        'أخصائي نجاح العملاء',
        'Customer Support',
        10,
        account: ShowcaseAccount.deactivated,
        access: ShowcaseAccess.ended,
        accessRole: 2),
    ShowcaseStaff(34, 'Dana', 'Al-Amoudi', 'دانة', 'العمودي', true,
        'Legal Counsel', 'مستشارة قانونية', 'Compliance & Legal', 11,
        account: ShowcaseAccount.willDeactivate,
        access: ShowcaseAccess.expiringSoon,
        accessRole: 4),
    ShowcaseStaff(35, 'Ayman', 'Al-Zayed', 'أيمن', 'الزايد', false,
        'Internal Auditor', 'مدقق داخلي', 'Compliance & Legal', 11,
        account: ShowcaseAccount.lockedWithRequest,
        access: ShowcaseAccess.expiringSoon,
        accessRole: 4),
    ShowcaseStaff(36, 'Hind', 'Al-Sharif', 'هند', 'الشريف', true,
        'Senior Software Engineer', 'مهندسة برمجيات أولى', 'Software', 12),
    ShowcaseStaff(37, 'Osama', 'Al-Ahmadi', 'أسامة', 'الأحمدي', false,
        'Release Manager', 'مدير الإصدارات', 'Software', 12,
        account: ShowcaseAccount.willActivate),
  ];

  static const List<String> _publicMailDomains = <String>[
    'gmail.com',
    'outlook.com',
    'hotmail.com',
    'yahoo.com',
    'icloud.com',
    'live.com',
  ];

  /// The company mail domain, taken from the signed-in user's address
  /// (`bayanatz.com` when that address is on a public mail provider).
  static String domainOf(ShowcasePerson me) {
    final int at = me.email.indexOf('@');
    final String domain = at < 0 ? '' : me.email.substring(at + 1).trim();
    if (domain.isEmpty || _publicMailDomains.contains(domain)) {
      return 'bayanatz.com';
    }
    return domain;
  }

  static ShowcaseStaff staff(int n) => roster[n - 1];

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// "Oct 21, 2026" — the format the Roles module stores its dates in
  /// (`Constants.userAccessDateFormat`).
  static String accessDate(DateTime d) =>
      '${_months[d.month - 1]} ${_two(d.day)}, ${d.year}';

  /// "2026-10-21 09:14:00.000" — what the app stores for first / last login.
  static String stamp(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}:00.000';

  /// Function Name: [departmentIds]
  ///
  /// Purpose: The id each roster department is stored under — the company's
  /// own department when one with the same English or Arabic name exists,
  /// otherwise a fixed `showcase_dept_NN` id. Reads only.
  static Future<Map<String, String>> departmentIds(
      FirebaseFirestore firestore) async {
    final Map<String, String> ids = <String, String>{};
    final QuerySnapshot<Map<String, dynamic>> existing =
        await firestore.collection(getBaseUrl('Departments')).get();
    final Map<String, String> byName = <String, String>{};
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in existing.docs) {
      if (doc.id.startsWith(ShowcaseCommon.idPrefix)) continue;
      final Map<String, dynamic> data = doc.data();
      final String id = '${data['Department_ID'] ?? doc.id}';
      for (final Object? name in <Object?>[
        data['Department_Name'],
        data['Department_Name_In_Arabic'],
      ]) {
        final String key = '$name'.trim().toLowerCase();
        if (key.isNotEmpty && key != 'null') byName[key] = id;
      }
    }
    for (int i = 0; i < _depts.length; i++) {
      final _Dept d = _depts[i];
      ids[d.en] = byName[d.en.toLowerCase()] ??
          byName[d.ar.toLowerCase()] ??
          ShowcaseCommon.id('dept', i + 1);
    }
    return ids;
  }

  static const List<String> _universities = <String>[
    'King Saud University',
    'King Abdulaziz University',
    'Prince Sultan University',
    'Imam Mohammad ibn Saud Islamic University',
    'King Fahd University of Petroleum and Minerals',
  ];

  static const Map<String, List<String>> _skills = <String, List<String>>{
    'Executive': <String>['Strategic Planning', 'Public Sector Governance'],
    'Information Technology': <String>[
      'Network Security',
      'Cloud Infrastructure',
      'ITIL Service Management'
    ],
    'Data Management': <String>[
      'Data Governance',
      'Data Profiling',
      'SQL',
      'Master Data Management'
    ],
    'Finance': <String>['Budgeting', 'Financial Reporting', 'Procurement'],
    'Operations': <String>[
      'Service Delivery',
      'Process Improvement',
      'Facilities Planning'
    ],
    'Human Resources': <String>[
      'Talent Acquisition',
      'Learning Design',
      'Workforce Planning'
    ],
    'Marketing': <String>['Media Relations', 'Content Strategy', 'Publishing'],
    'Sales': <String>[
      'Government Accounts',
      'Proposal Writing',
      'Stakeholder Management'
    ],
    'Customer Support': <String>[
      'Service Desk',
      'Incident Management',
      'Customer Success'
    ],
    'Compliance & Legal': <String>[
      'Regulatory Compliance',
      'Contract Review',
      'Internal Audit'
    ],
    'Software': <String>[
      'Software Architecture',
      'Release Management',
      'API Design'
    ],
  };

  static const List<List<String>> _hobbies = <List<String>>[
    <String>['Reading', 'Football'],
    <String>['Photography', 'Travel'],
    <String>['Cycling', 'Calligraphy'],
    <String>['Chess', 'Hiking'],
    <String>['Swimming', 'Cooking'],
  ];

  static const List<List<String>> _cities = <List<String>>[
    <String>['Riyadh', 'Riyadh Province', '12244'],
    <String>['Riyadh', 'Riyadh Province', '11564'],
    <String>['Jeddah', 'Makkah Province', '21442'],
    <String>['Dammam', 'Eastern Province', '32241'],
    <String>['Riyadh', 'Riyadh Province', '13315'],
  ];

  static DateTime _hireDate(ShowcaseStaff s, DateTime now) {
    if (s.n == 1) return DateTime(2016, 3, 1);
    if (s.n % 9 == 0) {
      // A few joiners this year, so "new this year" looks alive.
      final int month = 1 + (s.n * 2) % (now.month - 1 < 1 ? 1 : now.month - 1);
      return DateTime(now.year, month, 1 + (s.n * 5) % 25);
    }
    final int year = s.manager == 1 ? 2017 + s.n % 5 : 2020 + s.n % 6;
    return DateTime(year, 1 + s.n % 12, 1 + (s.n * 5) % 27);
  }

  /// Function Name: [employeeDoc]
  ///
  /// Purpose: The `Employees_Info` document of [s], written through the
  /// module's own `NewEmployeeModelHistory.toMap` (every history list has its
  /// one current entry). No password is set: these records are directory
  /// entries, not sign-in accounts.
  static Map<String, dynamic> employeeDoc({
    required ShowcaseStaff s,
    required String domain,
    required Map<String, String> departmentIds,
    required DateTime now,
  }) {
    final DateTime hire = _hireDate(s, now);
    final String manager = s.manager == 0 ? '' : staff(s.manager).email(domain);
    final List<String> city = _cities[s.n % _cities.length];
    final int years = (now.year - hire.year).clamp(1, 20) + 4;
    final String deptEn = s.dept.toLowerCase();

    String status;
    String? deactivation;
    String? activation;
    DateTime lastLogin;
    switch (s.account) {
      case ShowcaseAccount.active:
        status = 'active';
        lastLogin = now.subtract(Duration(hours: 3 + s.n % 40));
      case ShowcaseAccount.willDeactivate:
        status = 'active';
        deactivation = accessDate(now.add(Duration(days: 4 + (s.n * 7) % 26)));
        lastLogin = now.subtract(Duration(hours: 5 + s.n % 30));
      case ShowcaseAccount.deactivated:
        status = 'deactivated';
        lastLogin = now.subtract(Duration(days: 40 + (s.n * 3) % 90));
      case ShowcaseAccount.willActivate:
        status = 'deactivated';
        activation = accessDate(now.add(Duration(days: 3 + (s.n * 5) % 28)));
        lastLogin = now.subtract(Duration(days: 12 + s.n % 25));
      case ShowcaseAccount.locked:
        status = 'locked';
        lastLogin = now.subtract(Duration(days: 2 + s.n % 8));
      case ShowcaseAccount.lockedWithRequest:
        status = 'lockedWithRequest';
        lastLogin = now.subtract(Duration(days: 3 + s.n % 9));
    }

    final String mobile =
        '5${(10000000 + (s.n * 7919117) % 89999999).toString().padLeft(8, '0')}';
    final NewEmployeeModelHistory model = NewEmployeeModelHistory(
      id: s.id,
      timestamps: <int>[hire.millisecondsSinceEpoch],
      firstName: <String>[s.first],
      middleName: <String>[''],
      lastName: <String>[s.last],
      firstNameInArabic: <String>[s.firstAr],
      middleNameInArabic: <String>[''],
      lastNameInArabic: <String>[s.lastAr],
      nationalId: <String>['10${(20000000 + s.n * 3300317) % 89999999}'],
      nationalIdExpirationDate: <String>['${now.year + 2 + s.n % 4}/06/15'],
      nationality: <String>['Saudi'],
      passport: <String>[''],
      passportExpirationDate: <String>[''],
      email: <String>[s.email(domain)],
      mobilePhone: <MobilePhone>[
        MobilePhone(
          phones: <String>[mobile],
          countryCode: <String>['+966'],
          countryApp: <String>['SA'],
          timestamps: <Timestamp>[Timestamp.fromDate(hire)],
        ),
      ],
      officePhone: <String>['011${(4000000 + s.n * 1117) % 8999999}'],
      homePhone: <String>[''],
      extension: <String>['${1100 + s.n * 7}'],
      birthDay: <String>[
        '${1974 + (s.n * 7) % 24}/${_two(1 + s.n % 12)}/${_two(1 + (s.n * 3) % 27)}'
      ],
      gender: <String>[s.female ? 'female' : 'male'],
      country: <String>['Saudi Arabia'],
      province: <String>[city[1]],
      city: <String>[city[0]],
      postalCode: <String>[city[2]],
      street: <String>['${40 + s.n * 3} King Fahd Road'],
      maritalStatus: <String>[s.n % 4 == 0 ? 'single' : 'married'],
      language: <String>['Arabic'],
      departmentId: <String>[departmentIds[s.dept] ?? ''],
      supervisor: <String>[manager],
      role: <String>[s.roleName ?? ''],
      title: <String>[s.titleEn],
      titleInArabic: <String>[s.titleAr],
      workLocation: <String>[
        s.n % 5 == 0 ? 'Riyadh - Regional Office' : 'Riyadh - Head Office'
      ],
      drivingLicenseId: <String>[''],
      carPlates: <List<String>>[<String>[]],
      academicHistory: <Map<String, dynamic>>[
        <String, dynamic>{
          'Graduate_From': <String>[s.n % 3 == 0 ? 'master' : 'bachelor'],
          'University': <String>[_universities[s.n % _universities.length]],
          'Year_Of_Graduation': <String>['${hire.year - 4 - s.n % 5}'],
          'GPA': <String>[(3.4 + (s.n % 6) / 10).toStringAsFixed(1)],
        },
      ],
      bio: <String>[
        'Over $years years of experience in $deptEn, supporting national digital transformation programs.'
      ],
      bioInArabic: <String>[
        'خبرة تزيد على $years سنوات في مجال ${_deptAr(s.dept)}، ودعم برامج التحول الرقمي الوطني.'
      ],
      photo: <String>[''],
      skills: <List<String>>[_skills[s.dept] ?? <String>[]],
      hobbies: <List<String>>[_hobbies[s.n % _hobbies.length]],
      status: <String>[status],
      jobType: <String?>['Full-time'],
      workArrangement: <String?>[s.n % 3 == 0 ? 'Hybrid' : 'On-site'],
      employeeGrade: <String?>[s.manager <= 1 ? 'Senior' : 'Professional'],
      startDate: <String?>[accessDate(hire)],
      startTime: <String?>['8:00 AM'],
      endTime: <String?>['4:00 PM'],
      daysOff: <String?>['friday, saturday'],
      passwordExpirationTime: '12',
      passwordExpirationUnit: 'Week',
      firstLogin: stamp(hire.add(const Duration(days: 2, hours: 9))),
      lastLogin: stamp(lastLogin),
      deactivationDate: deactivation,
      activationDate: activation,
    );
    return model.toMap();
  }

  /// Function Name: [seedEmployees]
  ///
  /// Purpose: Writes the roster's `Employees_Info` documents (overwriting the
  /// same fixed ids on a re-run). The Roles and Messages showcase files call
  /// this first so their records always point at employees that exist.
  /// Returns how many documents were written.
  static Future<int> seedEmployees({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required DateTime now,
  }) async {
    final String domain = domainOf(me);
    final Map<String, String> deptIds = await departmentIds(firestore);
    final CollectionReference<Map<String, dynamic>> col =
        firestore.collection(getBaseUrl('Employees_Info'));
    int count = 0;
    WriteBatch batch = firestore.batch();
    for (final ShowcaseStaff s in roster) {
      batch.set(
        col.doc(s.id),
        employeeDoc(s: s, domain: domain, departmentIds: deptIds, now: now),
      );
      count++;
      if (count % 400 == 0) {
        await batch.commit();
        batch = firestore.batch();
      }
    }
    await batch.commit();
    return count;
  }

  /// Function Name: [seed]
  ///
  /// Purpose: Writes the missing departments and the employee roster; returns
  /// how many documents were written.
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required bool isArabic,
    required DateTime now,
  }) async {
    final Map<String, String> deptIds = await departmentIds(firestore);
    final CollectionReference<Map<String, dynamic>> deptCol =
        firestore.collection(getBaseUrl('Departments'));
    final WriteBatch batch = firestore.batch();
    int count = 0;
    for (int i = 0; i < _depts.length; i++) {
      final _Dept d = _depts[i];
      final String id = deptIds[d.en]!;
      if (!id.startsWith(ShowcaseCommon.idPrefix)) continue; // already there
      batch.set(
        deptCol.doc(id),
        DepartmentModelPro(
          departmentID: id,
          departmentName: d.en,
          departmentNameInArabic: d.ar,
          creationDate:
              Timestamp.fromDate(DateTime(now.year - 1, 1 + i % 6, 3)),
          addedBy: me.email,
        ).toMap(),
      );
      count++;
    }
    await batch.commit();
    count += await seedEmployees(firestore: firestore, me: me, now: now);
    return count;
  }
}
