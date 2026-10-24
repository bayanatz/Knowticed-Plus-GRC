// [module-file:services] — deleted when the services module is split out
/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_services.dart
/// Purpose: Showcase Services data: a catalogue of 24 services (as a bulk
///          upload creates them, with SLAs), 124 service requests spread over
///          the year in every status the module supports (pending, approved,
///          in progress, done, rejected, cancelled, breached SLA), and a
///          comment thread on two thirds of the requests.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Same document shapes the module itself writes:
///   * services  -> `Modules/services/CreateServices/{id}` (the map of
///     `ServicesHistoryModel.toJson`, like `UploadFileDetailsCubit` builds),
///   * requests  -> `Modules/services/RequestServices/{id}` (the same map,
///     every field a revision history; `state` and `timestamps` carry the
///     whole life of the request, the approval cycle one revision per step),
///   * comments  -> `Modules/services/Comments` keyed by `Request_Id`, as
///     `UniversalCommentSection` reads them.
///
/// Who is who: index 0 of the roster is the signed-in user. The catalogue is
/// built so that every screen of the signed-in user has data:
///   * services 1-6   -> the user is an APPROVER (Approvals page),
///   * services 7-12  -> the user is a PROVIDER (Provider view),
///   * services 13-24 -> the user only REQUESTS (My Requests).
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

/// Every request state the module's screens understand.
enum _St { pending, approved, inprogress, done, rejected, cancel, branchsla }

/// One catalogue service. [creator], [providers] and [approvers] are roster
/// positions (0 = the signed-in user).
class _Svc {
  const _Svc(this.nameEn, this.nameAr, this.descEn, this.descAr, this.duration,
      this.unit, this.creator, this.providers, this.approvers,
      {this.active = true, this.draft = false});

  final String nameEn;
  final String nameAr;
  final String descEn;
  final String descAr;
  final int duration;
  final String unit;
  final int creator;
  final List<int> providers;
  final List<int> approvers;
  final bool active;

  /// A draft the signed-in user has not published yet.
  final bool draft;
}

/// One planned request, before its dates and documents are built.
class _Req {
  _Req(this.month, this.k, this.n, this.status);

  final int month;
  final int k;
  final int n;
  final _St status;
  bool mine = false;

  /// 'prov' (user is the provider), 'app' (user is an approver) or 'none'.
  String role = 'none';
  int service = 0;
  int requester = 0;
  int number = 0;
  int indexInStatus = 0;
  DateTime created = DateTime(2026);
}

/// A person the documents name, taken from the employee directory when it is
/// loaded (so the profile, department and photo resolve) and from the
/// showcase people otherwise.
class _Emp {
  const _Emp({
    required this.email,
    required this.id,
    required this.firstEn,
    required this.middleEn,
    required this.lastEn,
    required this.firstAr,
    required this.middleAr,
    required this.lastAr,
    required this.titleEn,
    required this.titleAr,
    required this.deptId,
    required this.gender,
    required this.phone,
    required this.countryCode,
    required this.countryApp,
    required this.role,
    required this.photo,
    required this.peopleIndex,
  });

  final String email;
  final String id;
  final String firstEn;
  final String middleEn;
  final String lastEn;
  final String firstAr;
  final String middleAr;
  final String lastAr;
  final String titleEn;
  final String titleAr;
  final String deptId;
  final String gender;
  final String phone;
  final String countryCode;
  final String countryApp;
  final String role;
  final String photo;

  /// Position in [ShowcaseCommon.people] (what `addThread` speaks by).
  final int peopleIndex;

  String get emailLower => email.toLowerCase();

  /// The provider / approver entry stored in the JSON lists.
  EmployeeEntityModell toEntity({String? state}) => EmployeeEntityModell(
        id: id,
        state: state,
        firstName: firstEn,
        middleName: middleEn,
        lastName: lastEn,
        firstNameInArabic: firstAr,
        middleNameInArabic: middleAr,
        lastNameInArabic: lastAr,
        email: email,
        mobilePhone: ServicesMobilePhoneEntity(
            phone: phone, countryCode: countryCode, countryApp: countryApp),
        gender: gender,
        departmentId: deptId,
        role: role,
        title: titleEn,
        titleInArabic: titleAr,
        photo: photo.isEmpty ? null : photo,
        status: 'active',
      );
}

/// Collects the writes and commits them in batches of at most 400.
class _Writer {
  _Writer(this.firestore) : batch = firestore.batch();

  final FirebaseFirestore firestore;
  WriteBatch batch;
  int ops = 0;
  int total = 0;

  /// Makes room for [n] more operations (commits first when the batch is
  /// nearly full), so a request and its whole thread land in one batch.
  Future<void> reserve(int n) async {
    if (ops + n > 400) await flush();
  }

  void set(
      DocumentReference<Map<String, dynamic>> ref, Map<String, dynamic> data) {
    batch.set(ref, data);
    ops++;
    total++;
  }

  /// Counts [n] operations done directly on [batch] (comment threads).
  void counted(int n) {
    ops += n;
    total += n;
  }

  Future<void> flush() async {
    if (ops == 0) return;
    await batch.commit();
    batch = firestore.batch();
    ops = 0;
  }
}

abstract final class ShowcaseServices {
  // ── Catalogue ──────────────────────────────────────────────────────────
  static const List<_Svc> _base = <_Svc>[
    // 1-6: the signed-in user approves.
    _Svc(
        'Data Access Request',
        'طلب الوصول إلى البيانات',
        'Request read access to a governed dataset with the business justification and the name of the data owner.',
        'طلب صلاحية قراءة لمجموعة بيانات خاضعة للحوكمة مع المبرر الوظيفي واسم مالك البيانات.',
        3,
        'days',
        1,
        <int>[2, 3],
        <int>[0]),
    _Svc(
        'Dataset Publication Request',
        'طلب نشر مجموعة بيانات',
        'Publish a reviewed dataset to the internal data catalogue or to the open data portal.',
        'نشر مجموعة بيانات تمت مراجعتها في فهرس البيانات الداخلي أو في بوابة البيانات المفتوحة.',
        5,
        'days',
        2,
        <int>[4, 5],
        <int>[1, 0]),
    _Svc(
        'Retention Exception Request',
        'طلب استثناء من الاحتفاظ بالسجلات',
        'Request to keep records beyond the approved retention period for legal or audit reasons.',
        'طلب الاحتفاظ بالسجلات بعد انتهاء مدة الاحتفاظ المعتمدة لأسباب قانونية أو رقابية.',
        7,
        'days',
        3,
        <int>[6],
        <int>[2, 0]),
    _Svc(
        'Dashboard Access Request',
        'طلب الوصول إلى لوحة معلومات',
        'Access to an executive or operational dashboard for a named employee.',
        'منح موظف محدد صلاحية الوصول إلى لوحة معلومات تنفيذية أو تشغيلية.',
        4,
        'hours',
        4,
        <int>[3, 7],
        <int>[0]),
    _Svc(
        'Data Sharing Agreement Review',
        'مراجعة اتفاقية مشاركة البيانات',
        'Legal and classification review of a data sharing agreement with an external entity.',
        'مراجعة قانونية ومراجعة تصنيف لاتفاقية مشاركة بيانات مع جهة خارجية.',
        10,
        'days',
        5,
        <int>[1, 2],
        <int>[0, 4]),
    _Svc(
        'Data Breach Notification',
        'الإبلاغ عن تسرب بيانات',
        'Report a suspected data leak so the response team can contain it and notify the regulator.',
        'الإبلاغ عن اشتباه بتسرب بيانات ليتمكن فريق الاستجابة من احتوائه وإبلاغ الجهة التنظيمية.',
        4,
        'hours',
        6,
        <int>[5, 7],
        <int>[0]),
    // 7-12: the signed-in user provides.
    _Svc(
        'Metadata Change Request',
        'طلب تعديل البيانات الوصفية',
        'Correct or enrich the business and technical metadata of a registered data asset.',
        'تصحيح أو إثراء البيانات الوصفية الإدارية والفنية لأصل بيانات مسجل.',
        2,
        'days',
        0,
        <int>[0, 3],
        <int>[]),
    _Svc(
        'Data Quality Incident Report',
        'الإبلاغ عن حادثة جودة بيانات',
        'Report incomplete, duplicated or inaccurate records so the data quality team can investigate.',
        'الإبلاغ عن سجلات ناقصة أو مكررة أو غير دقيقة ليقوم فريق جودة البيانات بالتحقيق.',
        8,
        'hours',
        8,
        <int>[0, 2],
        <int>[4]),
    _Svc(
        'Data Catalogue Registration',
        'تسجيل أصل بيانات في الفهرس',
        'Register a new data asset in the catalogue with its owner, steward and classification.',
        'تسجيل أصل بيانات جديد في الفهرس مع مالكه وأمينه وتصنيفه.',
        2,
        'days',
        0,
        <int>[0],
        <int>[]),
    _Svc(
        'Master Data Change Request',
        'طلب تعديل البيانات الرئيسية',
        'Create or update a master data record such as a supplier, a customer or an organisation unit.',
        'إنشاء أو تحديث سجل في البيانات الرئيسية مثل مورد أو عميل أو وحدة تنظيمية.',
        3,
        'days',
        3,
        <int>[0, 5],
        <int>[1, 6]),
    _Svc(
        'Data Classification Review',
        'مراجعة تصنيف البيانات',
        'Review and confirm the classification level of a dataset or a report.',
        'مراجعة مستوى تصنيف مجموعة بيانات أو تقرير واعتماده.',
        3,
        'days',
        4,
        <int>[0, 6],
        <int>[2]),
    _Svc(
        'Data Quality Rule Request',
        'طلب قاعدة جودة بيانات',
        'Define a new data quality rule with its threshold, owner and monitoring frequency.',
        'تعريف قاعدة جودة بيانات جديدة مع حدها ومالكها وتكرار المراقبة.',
        5,
        'days',
        0,
        <int>[0, 7],
        <int>[3]),
    // 13-24: the signed-in user only requests.
    _Svc(
        'Media Asset Request',
        'طلب أصل إعلامي',
        'Request photos, videos or graphics from the media library for an approved campaign.',
        'طلب صور أو مقاطع فيديو أو تصاميم من المكتبة الإعلامية لحملة معتمدة.',
        24,
        'hours',
        5,
        <int>[3, 4],
        <int>[2]),
    _Svc(
        'Press Release Metadata Review',
        'مراجعة البيانات الوصفية للبيانات الصحفية',
        'Check the tags, dates and source references of a press release before publication.',
        'التحقق من الوسوم والتواريخ ومراجع المصدر في بيان صحفي قبل نشره.',
        6,
        'hours',
        6,
        <int>[2],
        <int>[]),
    _Svc(
        'Video Content Publishing Approval',
        'اعتماد نشر محتوى مرئي',
        'Approval to publish a video on the official channels after the compliance check.',
        'اعتماد نشر مقطع فيديو على القنوات الرسمية بعد التحقق من الامتثال.',
        12,
        'hours',
        7,
        <int>[4, 5],
        <int>[1, 2]),
    _Svc(
        'Open Data Request',
        'طلب بيانات مفتوحة',
        'Request a dataset to be released as open data under the national open data policy.',
        'طلب إتاحة مجموعة بيانات كبيانات مفتوحة وفق سياسة البيانات المفتوحة الوطنية.',
        4,
        'days',
        8,
        <int>[6, 7],
        <int>[3]),
    _Svc(
        'Data Lineage Report',
        'تقرير تتبع مسار البيانات',
        'Produce an end to end lineage report showing where a critical data element comes from.',
        'إعداد تقرير شامل لتتبع مسار البيانات يوضح مصدر عنصر بيانات حرج.',
        3,
        'days',
        1,
        <int>[4],
        <int>[5]),
    _Svc(
        'Access Rights Review',
        'مراجعة صلاحيات الوصول',
        'Periodic review of who can access a system and removal of access that is no longer needed.',
        'مراجعة دورية لمن يملك صلاحية الوصول إلى نظام وإزالة الصلاحيات غير اللازمة.',
        2,
        'days',
        2,
        <int>[1, 6],
        <int>[7]),
    _Svc(
        'Media Archive Retrieval',
        'استرجاع مواد من الأرشيف الإعلامي',
        'Retrieve archived broadcasts, articles or images from the media archive.',
        'استرجاع مواد مؤرشفة من بث أو مقالات أو صور من الأرشيف الإعلامي.',
        2,
        'days',
        3,
        <int>[5, 6],
        <int>[]),
    _Svc(
        'API Access Request',
        'طلب الوصول إلى واجهة برمجية',
        'Obtain credentials for an internal data service interface for an approved application.',
        'الحصول على بيانات الاعتماد لواجهة خدمة بيانات داخلية لتطبيق معتمد.',
        2,
        'days',
        4,
        <int>[7, 1],
        <int>[3, 5]),
    _Svc(
        'Statistical Report Request',
        'طلب تقرير إحصائي',
        'Request a statistical report based on the validated national indicators.',
        'طلب تقرير إحصائي مبني على المؤشرات الوطنية المعتمدة.',
        5,
        'days',
        5,
        <int>[2, 6],
        <int>[4]),
    _Svc(
        'Records Disposal Request',
        'طلب إتلاف سجلات',
        'Authorise the secure destruction of records that passed their retention period.',
        'اعتماد الإتلاف الآمن للسجلات التي انتهت مدة الاحتفاظ بها.',
        7,
        'days',
        0,
        <int>[3],
        <int>[2],
        active: false),
    _Svc(
        'Data Steward Assignment',
        'تعيين أمين بيانات',
        'Assign or replace the data steward of a business domain.',
        'تعيين أمين بيانات لمجال عمل أو استبداله.',
        24,
        'hours',
        0,
        <int>[5],
        <int>[1],
        active: false),
    _Svc(
        'Training Session Booking',
        'حجز جلسة تدريبية على حوكمة البيانات',
        'Book a data governance awareness session for a team or a department.',
        'حجز جلسة توعوية عن حوكمة البيانات لفريق أو إدارة.',
        7,
        'days',
        0,
        <int>[4],
        <int>[],
        active: false),
  ];

  /// More of the signed-in user's own services: three more inactive ones and
  /// six drafts, so the Services page shows Active, Inactive and Draft.
  static const List<_Svc> _mine = <_Svc>[
    _Svc(
        'Legacy Report Request',
        'طلب تقرير من النظام القديم',
        'Request a report from the legacy reporting system that is being retired.',
        'طلب تقرير من نظام التقارير القديم الذي يجري إيقافه.',
        5,
        'days',
        0,
        <int>[2],
        <int>[1],
        active: false),
    _Svc(
        'Paper Archive Retrieval',
        'طلب استرجاع ملف من الأرشيف الورقي',
        'Retrieve a physical file from the paper archive; replaced by the digital archive.',
        'استرجاع ملف مادي من الأرشيف الورقي؛ استبدلت بالأرشيف الرقمي.',
        3,
        'days',
        0,
        <int>[3],
        <int>[],
        active: false),
    _Svc(
        'Manual Data Extract',
        'طلب استخراج بيانات يدوي',
        'Manual extract from the data warehouse; replaced by the self-service portal.',
        'استخراج يدوي من مستودع البيانات؛ استبدل ببوابة الخدمة الذاتية.',
        2,
        'days',
        0,
        <int>[4],
        <int>[1],
        active: false),
    _Svc(
        'Data Sharing Agreement Review',
        'مراجعة اتفاقية مشاركة بيانات',
        'Legal and governance review of a data sharing agreement with an external entity.',
        'مراجعة قانونية وحوكمية لاتفاقية مشاركة بيانات مع جهة خارجية.',
        10,
        'days',
        0,
        <int>[2, 3],
        <int>[1],
        draft: true),
    _Svc(
        'Metadata Quality Audit',
        'طلب تدقيق جودة البيانات الوصفية',
        'Audit the completeness of metadata for a selected set of datasets.',
        'تدقيق اكتمال البيانات الوصفية لمجموعة مختارة من مجموعات البيانات.',
        7,
        'days',
        0,
        <int>[5],
        <int>[1],
        draft: true),
    _Svc(
        'Media Asset Licensing Request',
        'طلب ترخيص أصل إعلامي',
        'Obtain the licence and usage terms for a photo or video from the media archive.',
        'الحصول على الترخيص وشروط الاستخدام لصورة أو مقطع فيديو من الأرشيف الإعلامي.',
        4,
        'days',
        0,
        <int>[4],
        <int>[],
        draft: true),
    _Svc(
        'Data Breach Notification',
        'إشعار بحادثة تسرب بيانات',
        'Report a suspected data breach to the governance office for triage.',
        'الإبلاغ عن اشتباه بتسرب بيانات إلى مكتب الحوكمة للفرز.',
        1,
        'days',
        0,
        <int>[2],
        <int>[1],
        draft: true),
    _Svc(
        'Dataset Retirement Request',
        'طلب إيقاف مجموعة بيانات',
        'Retire a dataset from the catalogue and archive its documentation.',
        'إيقاف مجموعة بيانات من الفهرس وأرشفة توثيقها.',
        6,
        'days',
        0,
        <int>[3],
        <int>[1],
        draft: true),
    _Svc(
        'Reference Data Change',
        'طلب تغيير بيانات مرجعية',
        'Change a reference code list used across several systems.',
        'تغيير قائمة رموز مرجعية تستخدم في عدة أنظمة.',
        5,
        'days',
        0,
        <int>[5],
        <int>[1],
        draft: true),
  ];

  /// All catalogue services: the 24 of [_base] first (the requests point at
  /// their positions), then the user's own extras.
  static final List<_Svc> _services = <_Svc>[..._base, ..._mine];

  /// "When service SLA is about to be breached" / second threshold, in %.
  static const List<List<String>> _sla = <List<String>>[
    <String>['70', '90'],
    <String>['80', '100'],
    <String>['75', '95'],
    <String>['85', '100'],
  ];

  // Service pools by what the signed-in user does in them.
  static const List<int> _approverPool = <int>[0, 1, 2, 3, 4, 5];
  static const List<int> _providerPool = <int>[6, 7, 8, 9, 10, 11];
  static const List<int> _requesterPool = <int>[
    12, 13, 14, 15, 16, 17, 18, 19, 20 // the active services 13-21
  ];

  /// Requests per month, in the order of [_order].
  static const List<_St> _order = <_St>[
    _St.approved,
    _St.done,
    _St.rejected,
    _St.cancel,
    _St.branchsla,
    _St.pending,
    _St.inprogress,
  ];
  static const List<List<int>> _months = <List<int>>[
    <int>[2, 3, 2, 2, 1, 0, 0], // Jan
    <int>[2, 3, 2, 2, 1, 0, 0], // Feb
    <int>[2, 3, 2, 2, 1, 0, 0], // Mar
    <int>[2, 3, 2, 2, 1, 0, 0], // Apr
    <int>[2, 3, 2, 2, 1, 0, 0], // May
    <int>[2, 3, 2, 2, 1, 0, 0], // Jun
    <int>[2, 3, 2, 2, 1, 0, 0], // Jul
    <int>[3, 3, 1, 1, 1, 3, 4], // Aug
    <int>[3, 2, 2, 1, 2, 4, 4], // Sep
    <int>[3, 2, 1, 1, 2, 8, 3], // Oct
  ];

  /// How many requests of each status the signed-in user raised himself.
  static const Map<_St, int> _mineQuota = <_St, int>{
    _St.approved: 5,
    _St.done: 6,
    _St.rejected: 5,
    _St.cancel: 5,
    _St.branchsla: 5,
    _St.pending: 5,
    _St.inprogress: 5,
  };

  /// For the colleagues' requests of each status: how many have the signed-in
  /// user as provider / as approver / in neither role.
  static const Map<_St, List<int>> _roleCounts = <_St, List<int>>{
    _St.approved: <int>[6, 6, 6],
    _St.done: <int>[7, 7, 8],
    _St.rejected: <int>[0, 6, 7],
    _St.cancel: <int>[5, 6, 1],
    _St.branchsla: <int>[5, 2, 0],
    _St.pending: <int>[0, 6, 4],
    _St.inprogress: <int>[5, 0, 1],
  };

  // ── Texts ──────────────────────────────────────────────────────────────
  static const Map<_St, List<Bi>> _threads = <_St, List<Bi>>{
    _St.pending: <Bi>[
      Bi('Hello, I have submitted this request and attached the required details.',
          'مرحباً، قدمت هذا الطلب وأرفقت التفاصيل المطلوبة.'),
      Bi('Received. It is now with the approver for review.',
          'تم الاستلام، والطلب الآن لدى المعتمد للمراجعة.'),
      Bi('Could you confirm the expected completion date?',
          'هل يمكن تأكيد تاريخ الإنجاز المتوقع؟'),
      Bi('Once approved, it will be completed within the agreed service level.',
          'بعد الموافقة سيُنجز الطلب ضمن مستوى الخدمة المتفق عليه.'),
      Bi('Thank you, I will wait for the decision.', 'شكراً، سأنتظر القرار.'),
    ],
    _St.approved: <Bi>[
      Bi('Submitted for this quarter, the supporting documents are attached.',
          'قُدم الطلب لهذا الربع والمستندات الداعمة مرفقة.'),
      Bi('Reviewed and approved. I am passing it to the service team.',
          'تمت المراجعة والموافقة، وسأحيله إلى فريق الخدمة.'),
      Bi('Thank you. Please tell me if anything else is needed.',
          'شكراً، يرجى إبلاغي إن لزم أي شيء آخر.'),
      Bi('The service team has acknowledged the request and will start shortly.',
          'أكد فريق الخدمة استلام الطلب وسيبدأ العمل قريباً.'),
      Bi('Great, I will follow the progress here.',
          'ممتاز، سأتابع التقدم من هنا.'),
    ],
    _St.inprogress: <Bi>[
      Bi('Work has started on this request.', 'بدأ العمل على هذا الطلب.'),
      Bi('Thank you, please share an update when the first step is complete.',
          'شكراً، يرجى مشاركة تحديث عند اكتمال الخطوة الأولى.'),
      Bi('The first step is complete, we are now validating the result.',
          'اكتملت الخطوة الأولى ونتحقق الآن من النتيجة.'),
      Bi('Noted. We are still within the service level.',
          'تم العلم، ما زلنا ضمن مستوى الخدمة.'),
      Bi('Perfect, thank you for the update.', 'ممتاز، شكراً على التحديث.'),
    ],
    _St.done: <Bi>[
      Bi('The request has been completed. Please review the result.',
          'تم إنجاز الطلب، يرجى مراجعة النتيجة.'),
      Bi('Checked, everything is as expected. Thank you.',
          'تمت المراجعة وكل شيء كما هو متوقع، شكراً لكم.'),
      Bi('Closing the request now.', 'سيتم إغلاق الطلب الآن.'),
      Bi('The completion summary has been added to the record.',
          'أضيف ملخص الإنجاز إلى السجل.'),
      Bi('Thank you for the quick service.', 'شكراً على سرعة الخدمة.'),
    ],
    _St.rejected: <Bi>[
      Bi('The request does not meet the requirements of the policy.',
          'الطلب لا يستوفي متطلبات السياسة.'),
      Bi('Could you clarify which requirement is missing?',
          'هل يمكن توضيح المتطلب الناقص؟'),
      Bi('The business justification and the approval of the data owner are missing.',
          'المبرر الوظيفي وموافقة مالك البيانات غير متوفرين.'),
      Bi('Understood, I will submit it again with the missing documents.',
          'مفهوم، سأعيد تقديم الطلب مع المستندات الناقصة.'),
      Bi('Thank you, we will review it again when it is resubmitted.',
          'شكراً، سنراجعه مجدداً عند إعادة تقديمه.'),
    ],
    _St.cancel: <Bi>[
      Bi('I no longer need this service, so I am cancelling the request.',
          'لم أعد بحاجة إلى هذه الخدمة، لذلك ألغي الطلب.'),
      Bi('Noted, no action is required from the service team.',
          'تم العلم، لا يلزم أي إجراء من فريق الخدمة.'),
      Bi('Thank you for letting us know.', 'شكراً على إبلاغنا.'),
      Bi('The request is now closed.', 'تم إغلاق الطلب.'),
      Bi('Please raise a new request whenever it is needed again.',
          'يرجى رفع طلب جديد متى احتجتم إلى الخدمة مجدداً.'),
    ],
    _St.branchsla: <Bi>[
      Bi('This request has passed its service level target.',
          'تجاوز هذا الطلب المدة المستهدفة لمستوى الخدمة.'),
      Bi('Apologies for the delay, the team is giving it priority.',
          'نعتذر عن التأخير، والفريق يعطيه الأولوية.'),
      Bi('Please share the new expected completion time.',
          'يرجى مشاركة موعد الإنجاز المتوقع الجديد.'),
      Bi('We expect to complete it by the end of tomorrow.',
          'نتوقع إنجازه بنهاية يوم غد.'),
      Bi('Thank you, noted.', 'شكراً، تم العلم.'),
    ],
  };

  static const List<Bi> _approveComments = <Bi>[
    Bi('Approved. The request is compliant with the policy.',
        'تمت الموافقة. الطلب متوافق مع السياسة.'),
    Bi('Approved after checking the justification and the data owner.',
        'تمت الموافقة بعد التحقق من المبرر ومالك البيانات.'),
    Bi('Approved. Please proceed within the service level.',
        'تمت الموافقة. يرجى المتابعة ضمن مستوى الخدمة.'),
  ];

  static const List<Bi> _rejectComments = <Bi>[
    Bi('The request does not meet the policy. Please resubmit with the approval of the data owner.',
        'الطلب لا يستوفي السياسة. يرجى إعادة التقديم مع موافقة مالك البيانات.'),
    Bi('The business justification is not sufficient. Please add more detail and submit again.',
        'المبرر الوظيفي غير كاف. يرجى إضافة تفاصيل أكثر وإعادة التقديم.'),
    Bi('The dataset classification requires a higher approval level.',
        'تصنيف مجموعة البيانات يتطلب مستوى اعتماد أعلى.'),
  ];

  static const List<Bi> _cancelReasons = <Bi>[
    Bi('The service is no longer required.', 'لم تعد الخدمة مطلوبة.'),
    Bi('Submitted twice by mistake.', 'قُدم الطلب مرتين بالخطأ.'),
    Bi('The need was covered by another request.',
        'تمت تغطية الحاجة بطلب آخر.'),
  ];

  /// Function Name: [seed]
  ///
  /// Purpose: Writes the showcase services, requests and comment threads;
  /// returns how many documents were written.
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required bool isArabic,
    required DateTime now,
  }) async {
    final List<_Emp> roster = _buildRoster(me);
    final Map<String, Bi> departments = await _loadDepartments(firestore);
    final _Writer w = _Writer(firestore);

    final CollectionReference<Map<String, dynamic>> servicesCol = firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot));
    final CollectionReference<Map<String, dynamic>> requestsCol = firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot));
    final String commentsPath = getBaseUrl(FirestoreCollections.commentsRoot);

    // ── Catalogue ──
    final List<String> serviceIds = <String>[
      for (int i = 0; i < _services.length; i++)
        ShowcaseCommon.id('service', i + 1),
    ];
    for (int i = 0; i < _services.length; i++) {
      await w.reserve(1);
      w.set(servicesCol.doc(serviceIds[i]),
          _serviceDoc(i, serviceIds[i], roster, departments, isArabic, now));
    }

    // ── Requests ──
    final List<_Req> plan = _plan(roster, now);
    for (final _Req r in plan) {
      final _Svc svc = _services[r.service];
      final bool threaded = r.indexInStatus % 3 != 2;
      final int lines = 3 + r.number % 3;
      await w.reserve(1 + (threaded ? lines : 0));

      final String id = ShowcaseCommon.id('request', r.number);
      final _RequestParts parts = _requestDoc(
        r,
        id,
        serviceIds[r.service],
        svc,
        roster,
        departments,
        isArabic,
        now,
      );
      w.set(requestsCol.doc(id), parts.data);

      if (threaded) {
        final _Emp requester = roster[r.requester];
        final _Emp other = _otherSpeaker(r, svc, roster);
        ShowcaseCommon.addThread(
          batch: w.batch,
          firestore: firestore,
          collectionPath: commentsPath,
          filterFields: <String, dynamic>{'Request_Id': id},
          threadKey: 'svcreq_${r.number}',
          lines: _threads[r.status]!.take(lines).toList(),
          speakers: <int>[requester.peopleIndex, other.peopleIndex],
          start: r.created,
          isArabic: isArabic,
        );
        w.counted(lines);
      }
    }

    await w.flush();
    return w.total;
  }

  // ── Roster ─────────────────────────────────────────────────────────────

  /// The signed-in user first, then the colleagues.
  static List<_Emp> _buildRoster(ShowcasePerson me) {
    final Map<String, EmployeeEntityPro> byEmail = _employeesByEmail();
    final List<ShowcasePerson> people = ShowcaseCommon.people;
    final List<ShowcasePerson> ordered = <ShowcasePerson>[
      me,
      ...people.where((ShowcasePerson p) =>
          p.email.toLowerCase() != me.email.toLowerCase()),
    ];
    return <_Emp>[
      for (final ShowcasePerson p in ordered) _empOf(p, people, byEmail),
    ];
  }

  static Map<String, EmployeeEntityPro> _employeesByEmail() {
    final Map<String, EmployeeEntityPro> out = <String, EmployeeEntityPro>{};
    try {
      final c = AppControllers.employee;
      void add(EmployeeEntityPro? e) {
        final String email = (e?.email ?? '').trim().toLowerCase();
        if (e != null && email.isNotEmpty) out.putIfAbsent(email, () => e);
      }

      add(c.employeeEntity);
      for (final EmployeeEntityPro e
          in c.allEmployeesEntities ?? <EmployeeEntityPro>[]) {
        add(e);
      }
      c.mapOfEmployeesWithEmailKey.values.forEach(add);
    } catch (_) {
      // Employee directory not available: the showcase people are used.
    }
    return out;
  }

  static _Emp _empOf(ShowcasePerson p, List<ShowcasePerson> people,
      Map<String, EmployeeEntityPro> byEmail) {
    final EmployeeEntityPro? e = byEmail[p.email.toLowerCase()];
    final List<String> en = _split(p.nameEn);
    final List<String> ar = _split(p.nameAr);
    final int at = people.indexWhere(
        (ShowcasePerson x) => x.email.toLowerCase() == p.email.toLowerCase());
    String pick(String? a, String b) =>
        (a ?? '').trim().isNotEmpty ? a!.trim() : b;
    return _Emp(
      email: pick(e?.email, p.email),
      id: pick(e?.id, p.id),
      firstEn: pick(e?.firstName, en[0]),
      middleEn: (e?.middleName ?? '').trim(),
      lastEn: pick(e?.lastName, en[1]),
      firstAr: pick(e?.firstNameInArabic, ar[0]),
      middleAr: (e?.middleNameInArabic ?? '').trim(),
      lastAr: pick(e?.lastNameInArabic, ar[1]),
      titleEn: pick(e?.title, p.titleEn),
      titleAr: pick(e?.titleInArabic, p.titleAr),
      deptId: (e?.departmentId ?? '').trim(),
      gender: (e?.gender ?? '').trim(),
      phone: e?.mobilePhone?.phone ?? '',
      countryCode: e?.mobilePhone?.countryCode ?? '',
      countryApp: e?.mobilePhone?.countryApp ?? '',
      role: (e?.role ?? '').trim(),
      photo: (e?.photo ?? '').trim(),
      peopleIndex: at < 0 ? 0 : at,
    );
  }

  /// `[first, rest]` of a full name.
  static List<String> _split(String full) {
    final List<String> parts =
        full.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return <String>['', ''];
    return <String>[parts.first, parts.skip(1).join(' ')];
  }

  /// Roster position for a catalogue position (0 = the signed-in user).
  static int _ri(int idx, int rosterSize) {
    if (idx == 0 || rosterSize < 2) return 0;
    return 1 + (idx - 1) % (rosterSize - 1);
  }

  static List<int> _resolve(List<int> idxs, int rosterSize) {
    final List<int> out = <int>[];
    for (final int i in idxs) {
      final int r = _ri(i, rosterSize);
      if (!out.contains(r)) out.add(r);
    }
    return out;
  }

  /// The Departments collection as id -> names (empty if it cannot be read).
  static Future<Map<String, Bi>> _loadDepartments(
      FirebaseFirestore firestore) async {
    final Map<String, Bi> out = <String, Bi>{};
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await firestore
          .collection(getBaseUrl(ApiConstants.departmentDocumentKey))
          .get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs) {
        final DepartmentModelPro m = DepartmentModelPro.fromMap(d.data());
        final String id = m.departmentID ?? '';
        if (id.isNotEmpty) {
          out[id] = Bi(m.departmentName ?? '', m.departmentNameInArabic ?? '');
        }
      }
    } catch (_) {
      // Department names are an enhancement only.
    }
    return out;
  }

  // ── Services ───────────────────────────────────────────────────────────

  static Map<String, dynamic> _serviceDoc(
    int i,
    String id,
    List<_Emp> roster,
    Map<String, Bi> departments,
    bool isArabic,
    DateTime now,
  ) {
    final _Svc s = _services[i];
    final List<_Emp> creator = <_Emp>[roster[_ri(s.creator, roster.length)]];
    final List<_Emp> providers = <_Emp>[
      for (final int r in _resolve(s.providers, roster.length)) roster[r],
    ];
    final List<_Emp> approvers = <_Emp>[
      for (final int r in _resolve(s.approvers, roster.length)) roster[r],
    ];
    final DateTime created =
        DateTime(now.year, 1, 1, 8, 0).add(Duration(minutes: 25 * i));
    final List<String> sla = _sla[i % _sla.length];
    final ServicesHistoryModel model = _model(
      timestamps: <int>[created.millisecondsSinceEpoch],
      id: id,
      states: <String>[s.draft ? 'draft' : 'active'],
      status: s.active ? 'active' : 'inactive',
      parentServiceId: id,
      requester: creator.first,
      departments: departments,
      assignedProviderEmail:
          providers.isEmpty ? '' : providers.first.emailLower,
      svc: s,
      durationStamp: created.millisecondsSinceEpoch,
      providers: providers.map((_Emp e) => e.toEntity()).toList(),
      approvalRevisions: <List<EmployeeEntityModell>>[
        approvers.map((_Emp e) => e.toEntity(state: 'pending')).toList(),
      ],
      sla: sla,
      requireApproval: approvers.isNotEmpty,
    );
    return model.toJson();
  }

  // ── Requests ───────────────────────────────────────────────────────────

  /// Builds the list of requests: month and status from [_months], who raised
  /// it and the signed-in user's role from the quotas, the service from the
  /// pools. Sorted by date and numbered 1..N.
  static List<_Req> _plan(List<_Emp> roster, DateTime now) {
    final int rs = roster.length;
    final List<_Req> reqs = <_Req>[];
    for (int m = 0; m < _months.length; m++) {
      final int n = _months[m].fold(0, (int a, int b) => a + b);
      int k = 0;
      for (int si = 0; si < _order.length; si++) {
        for (int j = 0; j < _months[m][si]; j++) {
          reqs.add(_Req(m + 1, k++, n, _order[si]));
        }
      }
    }

    // Who raised each request, and the user's role in the others.
    for (final _St st in _order) {
      final List<_Req> ofSt = reqs.where((_Req r) => r.status == st).toList();
      final int n = ofSt.length;
      final int q = _mineQuota[st]!;
      final Set<int> mine = <int>{
        for (int t = 0; t < q; t++) ((2 * t + 1) * n) ~/ (2 * q),
      };
      final List<int> rc = _roleCounts[st]!;
      final List<String> roles = _interleave(<String, int>{
        'prov': rc[0],
        'app': rc[1],
        'none': rc[2],
      });
      int o = 0;
      for (int i = 0; i < n; i++) {
        ofSt[i].indexInStatus = i;
        if (mine.contains(i)) {
          ofSt[i].mine = true;
        } else {
          ofSt[i].role = o < roles.length ? roles[o] : 'none';
          o++;
        }
      }
    }

    // Dates, then numbering in date order.
    for (final _Req r in reqs) {
      r.created = _createdOf(r, now);
    }
    reqs.sort((_Req a, _Req b) => a.created.compareTo(b.created));

    // Service and requester.
    int ap = 0, pp = 0, zp = 0, rq = 0;
    for (int i = 0; i < reqs.length; i++) {
      final _Req r = reqs[i];
      r.number = i + 1;
      final bool needsApprovers =
          r.status == _St.pending || r.status == _St.rejected;
      final List<int> pool = r.mine
          ? _requesterPool
          : r.role == 'app'
              ? _approverPool
              : r.role == 'prov'
                  ? _providerPool
                  : _requesterPool;
      int counter;
      if (!r.mine && r.role == 'app') {
        counter = ap++;
      } else if (!r.mine && r.role == 'prov') {
        counter = pp++;
      } else {
        counter = zp++;
      }
      int chosen = pool[counter % pool.length];
      for (int t = 0; t < pool.length; t++) {
        final int cand = pool[(counter + t) % pool.length];
        if (!needsApprovers || _services[cand].approvers.isNotEmpty) {
          chosen = cand;
          break;
        }
      }
      r.service = chosen;

      if (r.mine) {
        r.requester = 0;
      } else {
        final _Svc svc = _services[chosen];
        final Set<int> busy = <int>{
          ..._resolve(svc.providers, rs),
          ..._resolve(svc.approvers, rs),
          0,
        };
        final List<int> cands = <int>[
          for (int c = 1; c < rs; c++)
            if (!busy.contains(c)) c,
        ];
        r.requester = cands.isEmpty
            ? (rs > 1 ? 1 + rq % (rs - 1) : 0)
            : cands[rq % cands.length];
        rq++;
      }
    }
    return reqs;
  }

  /// `{prov: 2, app: 1}` -> prov, app, prov (round robin).
  static List<String> _interleave(Map<String, int> counts) {
    final Map<String, int> left = Map<String, int>.of(counts);
    final List<String> out = <String>[];
    while (left.values.any((int v) => v > 0)) {
      for (final String key in left.keys) {
        if (left[key]! > 0) {
          out.add(key);
          left[key] = left[key]! - 1;
        }
      }
    }
    return out;
  }

  /// When the request was raised: spread over its month, never later than two
  /// days before [now] (room for its own history and comment thread).
  static DateTime _createdOf(_Req r, DateTime now) {
    final int dim = DateTime(now.year, r.month + 1, 0).day;
    final int maxDay =
        r.month == now.month ? (now.day - 2 < 4 ? 4 : now.day - 2) : dim - 4;
    final int day = 2 + (r.k * 7 + r.month * 3) % (maxDay - 1);
    final int hour = 8 + (r.k * 3 + r.month * 5) % 9;
    final int minute = (r.k * 17 + r.month * 11) % 60;
    return DateTime(now.year, r.month, day, hour, minute);
  }

  static _RequestParts _requestDoc(
    _Req r,
    String id,
    String serviceId,
    _Svc svc,
    List<_Emp> roster,
    Map<String, Bi> departments,
    bool isArabic,
    DateTime now,
  ) {
    final int rs = roster.length;
    final int seed = r.number;
    final _Emp requester = roster[r.requester];
    final List<_Emp> providers = <_Emp>[
      for (final int p in _resolve(svc.providers, rs)) roster[p],
    ];
    final List<_Emp> approvers = <_Emp>[
      for (final int p in _resolve(svc.approvers, rs)) roster[p],
    ];
    final int k = approvers.length;
    final int mePos = approvers.indexWhere((_Emp e) => identical(e, roster[0]));

    // Approval cycle: state of every approver.
    final List<String> cs = _cycleStates(r, k, mePos, seed);
    final int acted = cs.where((String s) => s != 'pending').length;
    final bool allApproved = k == 0 || cs.every((String s) => s == 'approved');

    // History of the request: state, timestamps and approval-cycle revisions.
    final List<DateTime> times = <DateTime>[r.created];
    DateTime t = r.created;
    for (int i = 0; i < acted; i++) {
      t = t.add(Duration(hours: 4 + ((seed + i) % 5) * 5, minutes: seed % 40));
      times.add(t);
    }
    final List<String> states =
        k == 0 ? <String>['approved'] : <String>['pending'];
    final bool closedAfterApproval = allApproved &&
        (r.status == _St.approved ||
            r.status == _St.inprogress ||
            r.status == _St.done ||
            r.status == _St.branchsla ||
            (r.status == _St.cancel && r.role == 'prov'));
    if (k > 0 && closedAfterApproval) states.add('approved');
    switch (r.status) {
      case _St.inprogress:
        t = t.add(Duration(hours: 6 + seed % 18));
        times.add(t);
        states.add('inprogress');
      case _St.done:
        t = t.add(Duration(hours: 6 + seed % 18));
        times.add(t);
        states.add('inprogress');
        t = t.add(Duration(days: 1 + seed % 3, hours: seed % 9));
        times.add(t);
        states.add('done');
      case _St.branchsla:
        t = t.add(Duration(hours: 6 + seed % 18));
        times.add(t);
        states.add('inprogress');
        t = t.add(Duration(days: 2 + seed % 3, hours: seed % 7));
        times.add(t);
        states.add('branchsla');
      case _St.cancel:
        t = t.add(Duration(hours: 3 + seed % 30));
        times.add(t);
        states.add('cancel');
      case _St.rejected:
        states.add('rejected');
      case _St.approved:
      case _St.pending:
        break;
    }

    // Nothing may happen in the future: shift a recent request's whole
    // history back so that it ends before [now].
    final DateTime latest = now.subtract(const Duration(hours: 3));
    if (times.last.isAfter(latest)) {
      final Duration shift = times.last.difference(latest);
      for (int i = 0; i < times.length; i++) {
        times[i] = times[i].subtract(shift);
      }
      r.created = times.first;
    }

    // Approval-cycle revisions: all pending, then one per approver action.
    final List<List<EmployeeEntityModell>> revisions =
        <List<EmployeeEntityModell>>[];
    if (k > 0) {
      for (int step = 0; step <= acted; step++) {
        revisions.add(<EmployeeEntityModell>[
          for (int i = 0; i < k; i++)
            approvers[i].toEntity(state: i < step ? cs[i] : 'pending'),
        ]);
      }
    }

    // Provider: assigned once the approvals are complete.
    final bool assigned = allApproved &&
        r.status != _St.pending &&
        r.status != _St.rejected &&
        !(r.status == _St.cancel && r.role != 'prov');
    _Emp? assignee;
    if (providers.isNotEmpty) {
      assignee = (r.role == 'prov' && !r.mine)
          ? roster[0]
          : providers[seed % providers.length];
    }
    final List<EmployeeEntityModell> providerList = assigned && assignee != null
        ? <EmployeeEntityModell>[assignee.toEntity()]
        : providers.map((_Emp e) => e.toEntity()).toList();

    final int createdMs = r.created.millisecondsSinceEpoch;
    final List<String> sla = _sla[r.service % _sla.length];
    final ServicesHistoryModel model = _model(
      timestamps: times.map((DateTime d) => d.millisecondsSinceEpoch).toList(),
      id: id,
      states: states,
      status: 'active',
      parentServiceId: serviceId,
      requester: requester,
      departments: departments,
      assignedProviderEmail:
          assigned && assignee != null ? assignee.emailLower : '',
      svc: svc,
      durationStamp: createdMs,
      providers: providerList,
      approvalRevisions: revisions,
      sla: sla,
      requireApproval: k > 0,
    );

    final Map<String, dynamic> data = model.toJson();

    // Legacy single-value copies some detail screens read (names only, in
    // the language the data was filled in).
    final Bi? dept = departments[requester.deptId];
    data['firstNameRequester'] = requester.firstEn;
    data['lastNameRequester'] = requester.lastEn;
    data['jobTitleRequester'] = requester.titleEn;
    data['firstNameRequesterArabic'] = requester.firstAr;
    data['lastNameRequesterArabic'] = requester.lastAr;
    data['jobTitleRequesterArabic'] = requester.titleAr;
    if (dept != null && dept.of(isArabic).isNotEmpty) {
      data['departmentRequester'] = dept.of(isArabic);
    }

    // The decision texts the details pages show.
    if (acted > 0 && r.status != _St.rejected && r.status != _St.pending) {
      data['approveComment'] =
          _approveComments[seed % _approveComments.length].of(isArabic);
    }
    if (r.status == _St.rejected) {
      data['rejectComment'] =
          _rejectComments[seed % _rejectComments.length].of(isArabic);
    }
    if (r.status == _St.cancel) {
      data['Cancel_Reason'] =
          _cancelReasons[seed % _cancelReasons.length].of(isArabic);
    }
    return _RequestParts(data);
  }

  /// State of every approver for a request in status [r.status].
  static List<String> _cycleStates(_Req r, int k, int mePos, int seed) {
    if (k == 0) return <String>[];
    final bool app = !r.mine && r.role == 'app' && mePos >= 0;
    switch (r.status) {
      case _St.approved:
      case _St.inprogress:
      case _St.done:
      case _St.branchsla:
        return List<String>.filled(k, 'approved');
      case _St.pending:
        final int j = app ? mePos : seed % k;
        return <String>[
          for (int i = 0; i < k; i++) i < j ? 'approved' : 'pending',
        ];
      case _St.rejected:
        final int j = app ? mePos : seed % k;
        return <String>[
          for (int i = 0; i < k; i++)
            i < j ? 'approved' : (i == j ? 'rejected' : 'pending'),
        ];
      case _St.cancel:
        if (r.role == 'prov' && !r.mine) {
          return List<String>.filled(k, 'approved');
        }
        final int j = app ? mePos : seed % k;
        return <String>[
          for (int i = 0; i < k; i++) i < j ? 'approved' : 'pending',
        ];
    }
  }

  /// The second voice of a thread: the approver while the request is being
  /// decided, the provider once it is being delivered.
  static _Emp _otherSpeaker(_Req r, _Svc svc, List<_Emp> roster) {
    final int rs = roster.length;
    final List<int> approvers = _resolve(svc.approvers, rs);
    final List<int> providers = _resolve(svc.providers, rs);
    final bool deciding = r.status == _St.pending ||
        r.status == _St.approved ||
        r.status == _St.rejected;
    if (deciding && approvers.isNotEmpty) {
      final int me = approvers.indexOf(0);
      return roster[(!r.mine && r.role == 'app' && me >= 0)
          ? 0
          : approvers[r.number % approvers.length]];
    }
    if (providers.isEmpty) return roster[0];
    if (!r.mine && r.role == 'prov') return roster[0];
    return roster[providers[r.number % providers.length]];
  }

  // ── Document builder ───────────────────────────────────────────────────

  /// The module's own model, filled the way the app fills it, with
  /// [approvalRevisions] as the revision history of the approval cycle.
  static ServicesHistoryModel _model({
    required List<int> timestamps,
    required String id,
    required List<String> states,
    required String status,
    required String parentServiceId,
    required _Emp requester,
    required Map<String, Bi> departments,
    required String assignedProviderEmail,
    required _Svc svc,
    required int durationStamp,
    required List<EmployeeEntityModell> providers,
    required List<List<EmployeeEntityModell>> approvalRevisions,
    required List<String> sla,
    required bool requireApproval,
  }) {
    String json(List<EmployeeEntityModell> l) =>
        jsonEncode(l.map((EmployeeEntityModell e) => e.toJson()).toList());
    final Bi? dept = departments[requester.deptId];
    return ServicesHistoryModel(
      timestamps: timestamps,
      id: <String>[id],
      state: states,
      status: <String>[status],
      parentServiceId: <String>[parentServiceId],
      firstNameRequester: <String>[requester.firstEn],
      lastNameRequester: <String>[requester.lastEn],
      departmentRequester: <String>[requester.deptId],
      jobTitleRequester: <String>[requester.titleEn],
      emailRequester: <String>[requester.email],
      phoneRequester: <String>[requester.phone],
      genderRequester: <String>[requester.gender],
      assignedProviderEmail: assignedProviderEmail.isEmpty
          ? <String>[]
          : <String>[assignedProviderEmail],
      firstNameRequesterArabic: <String>[requester.firstAr],
      lastNameRequesterArabic: <String>[requester.lastAr],
      jobTitleRequesterArabic: <String>[requester.titleAr],
      departmentRequesterArabic: <String>[dept?.ar ?? ''],
      serviceNameEnglish: <String>[svc.nameEn],
      serviceNameArabic: <String>[svc.nameAr],
      serviceDescriptionEnglish: <String>[svc.descEn],
      serviceDescriptionArabic: <String>[svc.descAr],
      durationOfServices: <String>['${svc.duration}'],
      selectedDurationUnit: <String>[svc.unit],
      durationOfServicesTimestamp: <Timestamp>[
        Timestamp.fromMillisecondsSinceEpoch(durationStamp),
      ],
      imageUrl: <String>[''],
      providerServices: <String>[json(providers)],
      limitAvailability: <bool>[false],
      requireApproval: <bool>[requireApproval],
      selectDepartment: <String>['[]'],
      approvalCycle: approvalRevisions.isEmpty
          ? <String>['[]']
          : approvalRevisions.map(json).toList(),
      slaOneControllerEnglish: <String>[sla[0]],
      slaTwoControllerEnglish: <String>[sla[1]],
      notifyRequesterChecked: <bool>[true],
      notifyProviderChecked: <bool>[true],
      notifyManagerChecked: <bool>[true],
      notifyRequesterSwitch0: <bool>[true],
      notifyManagerSwitch1: <bool>[true],
    );
  }
}

class _RequestParts {
  const _RequestParts(this.data);

  final Map<String, dynamic> data;
}
