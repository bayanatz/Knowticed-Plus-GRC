// [module-file:database] — deleted when the database module is split out
/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_database_data.dart
/// Purpose: The content of the Database Builder showcase: 25 databases with
///          their tables, columns and row generators, in English and Arabic.
///          The documents themselves are built in `showcase_database.dart`.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
library;

import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';

/// Where a database sits in the list tabs.
enum DbState { active, draft, deleted }

/// How a database is shared.
enum DbAccess { open, restricted, personal }

/// One column of a table template.
class DbCol {
  const DbCol(this.name, this.type);

  final Bi name;
  final TableColumnType type;
}

/// Helpers the row generators use: values come out in the app language and
/// always satisfy the column type (dates `d/m/yyyy`, percentages `85.5%`,
/// currency with at most two decimals).
class DbCtx {
  DbCtx({required this.ar, required this.now, required this.people});

  final bool ar;
  final DateTime now;
  final List<ShowcasePerson> people;

  static int h(int a, int b) {
    int x = (a * 73856093) ^ (b * 19349663) ^ 0x2545f491;
    x = (x ^ (x >> 15)) * 2246822519;
    x = x ^ (x >> 13);
    return x.abs();
  }

  String t(Bi b) => b.of(ar);

  String pick(List<Bi> list, int i, [int salt = 0]) =>
      t(list[h(i, salt) % list.length]);

  String person(int i, [int salt = 0]) =>
      people[h(i, salt) % people.length].name(ar);

  int n(int i, int salt, int lo, int hi) => lo + h(i, salt) % (hi - lo + 1);

  String date(int i, [int salt = 0]) {
    final int span = now.difference(DateTime(now.year)).inDays - 3;
    final DateTime d =
        DateTime(now.year).add(Duration(days: h(i, salt) % span));
    return '${d.day}/${d.month}/${d.year}';
  }

  String future(int i, [int salt = 0]) {
    final DateTime d = DateTime(now.year, now.month, now.day)
        .add(Duration(days: 12 + h(i, salt) % 420));
    return '${d.day}/${d.month}/${d.year}';
  }

  String pct(int i, int salt, int lo, int hi) =>
      '${n(i, salt, lo, hi)}.${h(i, salt + 5) % 10}%';

  String money(int i, int salt, int lo, int hi) =>
      '${n(i, salt, lo ~/ 100, hi ~/ 100) * 100}.00';

  String id(String prefix, int i, [int base = 1000]) => '$prefix-${base + i}';
}

typedef DbRowGen = List<String> Function(DbCtx x, int i);

/// A reusable table shape: columns and a generator for its rows.
class DbTemplate {
  const DbTemplate(this.columns, this.row);

  final List<DbCol> columns;
  final DbRowGen row;
}

/// A table of one database.
class DbTableRef {
  const DbTableRef(
    this.template,
    this.name,
    this.description, {
    this.rows = 12,
    this.shared = false,
    this.restricted = false,
  });

  final String template;
  final Bi name;
  final Bi description;
  final int rows;

  /// Comments are shared with everyone who can open the table.
  final bool shared;

  /// Only the people named in the table's own access list can open it.
  final bool restricted;
}

/// One database.
class DbSpec {
  const DbSpec({
    required this.title,
    required this.description,
    required this.access,
    required this.state,
    required this.byMe,
    required this.tables,
  });

  final Bi title;
  final Bi description;
  final DbAccess access;
  final DbState state;

  /// Created by the signed-in user (otherwise by a colleague who gave the
  /// signed-in user access).
  final bool byMe;
  final List<DbTableRef> tables;
}

abstract final class DatabaseShowcaseData {
  // ── Pools ─────────────────────────────────────────────────────────────
  static const List<Bi> _departments = <Bi>[
    Bi('Data Governance', 'حوكمة البيانات'),
    Bi('Information Technology', 'تقنية المعلومات'),
    Bi('Legal and Compliance', 'الشؤون القانونية والامتثال'),
    Bi('Internal Audit', 'التدقيق الداخلي'),
    Bi('Corporate Communications', 'الاتصال المؤسسي'),
    Bi('Finance', 'المالية'),
    Bi('Operations', 'العمليات'),
    Bi('Strategy and Planning', 'الاستراتيجية والتخطيط'),
  ];
  static const List<Bi> _regions = <Bi>[
    Bi('Riyadh', 'الرياض'),
    Bi('Makkah', 'مكة المكرمة'),
    Bi('Madinah', 'المدينة المنورة'),
    Bi('Eastern Province', 'المنطقة الشرقية'),
    Bi('Qassim', 'القصيم'),
    Bi('Asir', 'عسير'),
    Bi('Tabuk', 'تبوك'),
    Bi('Hail', 'حائل'),
  ];
  static const List<Bi> _classes = <Bi>[
    Bi('Public', 'عام'),
    Bi('Internal', 'داخلي'),
    Bi('Confidential', 'سري'),
    Bi('Restricted', 'مقيد'),
  ];
  static const List<Bi> _formats = <Bi>[
    Bi('CSV', 'CSV'),
    Bi('JSON', 'JSON'),
    Bi('XLSX', 'XLSX'),
    Bi('Parquet', 'Parquet'),
    Bi('XML', 'XML'),
  ];
  static const List<Bi> _freq = <Bi>[
    Bi('Daily', 'يومي'),
    Bi('Weekly', 'أسبوعي'),
    Bi('Monthly', 'شهري'),
    Bi('Quarterly', 'ربع سنوي'),
    Bi('Annually', 'سنوي'),
  ];
  static const List<Bi> _datasets = <Bi>[
    Bi('Citizen service requests', 'طلبات خدمة المواطنين'),
    Bi('Procurement contracts 2026', 'عقود المشتريات 2026'),
    Bi('Municipal licences', 'التراخيص البلدية'),
    Bi('National address points', 'نقاط العناوين الوطنية'),
    Bi('Public holidays calendar', 'تقويم الإجازات الرسمية'),
    Bi('Road traffic counts', 'إحصاءات حركة المرور'),
    Bi('Air quality readings', 'قراءات جودة الهواء'),
    Bi('School enrolment', 'القيد المدرسي'),
    Bi('Health facility register', 'سجل المنشآت الصحية'),
    Bi('Tourism arrivals', 'أعداد الوافدين السياحيين'),
    Bi('Energy consumption by sector', 'استهلاك الطاقة حسب القطاع'),
    Bi('Business registrations', 'تسجيل الأعمال'),
    Bi('Court case statistics', 'إحصاءات القضايا'),
    Bi('Water network assets', 'أصول شبكة المياه'),
    Bi('Media publications index', 'فهرس المطبوعات الإعلامية'),
    Bi('Press accreditation records', 'سجلات الاعتماد الصحفي'),
  ];
  static const List<Bi> _status = <Bi>[
    Bi('Active', 'نشط'),
    Bi('Under review', 'قيد المراجعة'),
    Bi('Pending approval', 'بانتظار الاعتماد'),
    Bi('Retired', 'متقاعد'),
  ];
  static const List<Bi> _severity = <Bi>[
    Bi('Low', 'منخفضة'),
    Bi('Medium', 'متوسطة'),
    Bi('High', 'عالية'),
    Bi('Critical', 'حرجة'),
  ];
  static const List<Bi> _issueStatus = <Bi>[
    Bi('Open', 'مفتوح'),
    Bi('In progress', 'قيد المعالجة'),
    Bi('Resolved', 'تمت المعالجة'),
    Bi('Closed', 'مغلق'),
  ];
  static const List<Bi> _dimensions = <Bi>[
    Bi('Completeness', 'الاكتمال'),
    Bi('Accuracy', 'الدقة'),
    Bi('Timeliness', 'الحداثة'),
    Bi('Consistency', 'الاتساق'),
    Bi('Uniqueness', 'التفرد'),
    Bi('Validity', 'الصلاحية'),
  ];
  static const List<Bi> _incidentCats = <Bi>[
    Bi('Access', 'الوصول'),
    Bi('Availability', 'التوافر'),
    Bi('Data quality', 'جودة البيانات'),
    Bi('Privacy', 'الخصوصية'),
    Bi('Process', 'الإجراءات'),
  ];
  static const List<Bi> _assetTypes = <Bi>[
    Bi('Photo', 'صورة'),
    Bi('Video', 'فيديو'),
    Bi('Audio', 'تسجيل صوتي'),
    Bi('Infographic', 'إنفوجرافيك'),
    Bi('Document', 'وثيقة'),
  ];
  static const List<Bi> _assetTitles = <Bi>[
    Bi('Opening ceremony', 'حفل الافتتاح'),
    Bi('Minister interview', 'مقابلة الوزير'),
    Bi('Annual report cover', 'غلاف التقرير السنوي'),
    Bi('Digital services launch', 'إطلاق الخدمات الرقمية'),
    Bi('National day highlights', 'أبرز مشاهد اليوم الوطني'),
    Bi('Statistics explainer', 'شرح الإحصاءات'),
    Bi('Press conference', 'المؤتمر الصحفي'),
    Bi('Regional visit', 'الزيارة الإقليمية'),
    Bi('Data week poster', 'ملصق أسبوع البيانات'),
    Bi('Award ceremony', 'حفل التكريم'),
    Bi('Podcast episode', 'حلقة بودكاست'),
    Bi('Technology summit', 'قمة التقنية'),
  ];
  static const List<Bi> _rights = <Bi>[
    Bi('In-house production', 'إنتاج داخلي'),
    Bi('Agency licence', 'ترخيص وكالة'),
    Bi('Contributor', 'مساهم'),
    Bi('Press office', 'المكتب الصحفي'),
  ];
  static const List<Bi> _pubCats = <Bi>[
    Bi('Annual report', 'تقرير سنوي'),
    Bi('Statistical bulletin', 'نشرة إحصائية'),
    Bi('Policy paper', 'ورقة سياسات'),
    Bi('Guide', 'دليل'),
    Bi('Newsletter', 'نشرة دورية'),
  ];
  static const List<Bi> _pubTitles = <Bi>[
    Bi('Digital transformation progress', 'تقدم التحول الرقمي'),
    Bi('Quarterly statistics bulletin', 'النشرة الإحصائية الربعية'),
    Bi('Data governance handbook', 'دليل حوكمة البيانات'),
    Bi('Open data annual review', 'المراجعة السنوية للبيانات المفتوحة'),
    Bi('Citizen satisfaction survey', 'مسح رضا المواطنين'),
    Bi('Records management guide', 'دليل إدارة السجلات'),
    Bi('Cybersecurity awareness newsletter', 'نشرة التوعية بالأمن السيبراني'),
    Bi('Media standards policy paper', 'ورقة سياسات المعايير الإعلامية'),
    Bi('Service quality report', 'تقرير جودة الخدمات'),
    Bi('National indicators summary', 'ملخص المؤشرات الوطنية'),
    Bi('Privacy practices guide', 'دليل ممارسات الخصوصية'),
    Bi('Innovation programme brief', 'موجز برنامج الابتكار'),
  ];
  static const List<Bi> _langs = <Bi>[
    Bi('Arabic', 'العربية'),
    Bi('English', 'الإنجليزية'),
    Bi('Bilingual', 'ثنائي اللغة'),
  ];
  static const List<Bi> _services = <Bi>[
    Bi('Business licence renewal', 'تجديد رخصة النشاط التجاري'),
    Bi('Identity data update', 'تحديث بيانات الهوية'),
    Bi('Property registration', 'تسجيل العقار'),
    Bi('Vehicle registration', 'تسجيل المركبة'),
    Bi('Birth certificate request', 'طلب شهادة ميلاد'),
    Bi('Event organising permit', 'تصريح تنظيم فعالية'),
    Bi('Press accreditation', 'الاعتماد الصحفي'),
    Bi('Statistical data request', 'طلب بيانات إحصائية'),
    Bi('Complaint submission', 'تقديم شكوى'),
    Bi('Document attestation', 'تصديق وثيقة'),
    Bi('Commercial register extract', 'مستخرج السجل التجاري'),
    Bi('Licence fee payment', 'سداد رسوم الترخيص'),
  ];
  static const List<Bi> _entities = <Bi>[
    Bi('Ministry of Commerce', 'وزارة التجارة'),
    Bi('Civil Affairs Authority', 'هيئة الأحوال المدنية'),
    Bi('Municipal Affairs', 'الشؤون البلدية'),
    Bi('Traffic Directorate', 'إدارة المرور'),
    Bi('Media Regulatory Authority', 'هيئة تنظيم الإعلام'),
    Bi('Statistics Authority', 'هيئة الإحصاء'),
  ];
  static const List<Bi> _channels = <Bi>[
    Bi('Web portal', 'البوابة الإلكترونية'),
    Bi('Mobile app', 'التطبيق'),
    Bi('Service centre', 'مركز الخدمة'),
    Bi('Call centre', 'مركز الاتصال'),
  ];
  static const List<Bi> _months = <Bi>[
    Bi('January', 'يناير'),
    Bi('February', 'فبراير'),
    Bi('March', 'مارس'),
    Bi('April', 'أبريل'),
    Bi('May', 'مايو'),
    Bi('June', 'يونيو'),
    Bi('July', 'يوليو'),
    Bi('August', 'أغسطس'),
    Bi('September', 'سبتمبر'),
    Bi('October', 'أكتوبر'),
    Bi('November', 'نوفمبر'),
    Bi('December', 'ديسمبر'),
  ];
  static const List<Bi> _suppliers = <Bi>[
    Bi('Al-Noor Technical Services', 'النور للخدمات الفنية'),
    Bi('Gulf Data Systems', 'الخليج لنظم البيانات'),
    Bi('Horizon Consulting', 'أفق للاستشارات'),
    Bi('Najd Facilities', 'نجد للمرافق'),
    Bi('Red Sea Media Production', 'البحر الأحمر للإنتاج الإعلامي'),
    Bi('Tamkeen Business Solutions', 'تمكين للحلول المهنية'),
    Bi('Alfa Cloud Hosting', 'ألفا للاستضافة السحابية'),
    Bi('Madar Print House', 'مدار للطباعة'),
    Bi('Rawafid Training', 'روافد للتدريب'),
    Bi('Summit Security Audit', 'القمة لتدقيق الأمن'),
  ];
  static const List<Bi> _contractCats = <Bi>[
    Bi('IT services', 'خدمات تقنية'),
    Bi('Consulting', 'استشارات'),
    Bi('Media production', 'إنتاج إعلامي'),
    Bi('Facilities', 'مرافق'),
    Bi('Training', 'تدريب'),
    Bi('Printing', 'طباعة'),
  ];
  static const List<Bi> _contractStatus = <Bi>[
    Bi('Active', 'ساري'),
    Bi('Completed', 'مكتمل'),
    Bi('Under renewal', 'قيد التجديد'),
    Bi('Suspended', 'معلق'),
  ];
  static const List<Bi> _budgetLines = <Bi>[
    Bi('Data platform operations', 'تشغيل منصة البيانات'),
    Bi('Software licences', 'تراخيص البرمجيات'),
    Bi('Training and development', 'التدريب والتطوير'),
    Bi('Consulting services', 'الخدمات الاستشارية'),
    Bi('Media production', 'الإنتاج الإعلامي'),
    Bi('Events and conferences', 'الفعاليات والمؤتمرات'),
    Bi('Infrastructure', 'البنية التحتية'),
    Bi('Audit and assurance', 'التدقيق والضمان'),
  ];
  static const List<Bi> _areas = <Bi>[
    Bi('Access control', 'التحكم في الوصول'),
    Bi('Records retention', 'الاحتفاظ بالسجلات'),
    Bi('Procurement', 'المشتريات'),
    Bi('Data quality', 'جودة البيانات'),
    Bi('Business continuity', 'استمرارية الأعمال'),
    Bi('Privacy', 'الخصوصية'),
  ];
  static const List<Bi> _findingStatus = <Bi>[
    Bi('Open', 'مفتوحة'),
    Bi('In progress', 'قيد المعالجة'),
    Bi('Closed', 'مغلقة'),
    Bi('Overdue', 'متأخرة'),
  ];
  static const List<Bi> _actions = <Bi>[
    Bi('Update the data owner register', 'تحديث سجل مالكي البيانات'),
    Bi('Review access for the finance datasets',
        'مراجعة الوصول إلى مجموعات بيانات المالية'),
    Bi('Publish the quality scorecard', 'نشر بطاقة قياس الجودة'),
    Bi('Confirm retention periods with Legal',
        'تأكيد فترات الاحتفاظ مع الشؤون القانونية'),
    Bi('Close duplicate supplier records', 'إغلاق سجلات الموردين المكررة'),
    Bi('Prepare the committee briefing', 'إعداد موجز اللجنة'),
    Bi('Agree metadata fields for media assets',
        'الاتفاق على حقول البيانات الوصفية للأصول الإعلامية'),
    Bi('Schedule the backup restoration test',
        'جدولة اختبار استعادة النسخ الاحتياطي'),
    Bi('Collect evidence for the audit request', 'جمع الأدلة لطلب التدقيق'),
    Bi('Share the lessons learned note', 'مشاركة مذكرة الدروس المستفادة'),
  ];
  static const List<Bi> _meetings = <Bi>[
    Bi('Governance council', 'مجلس الحوكمة'),
    Bi('Data quality weekly', 'اجتماع جودة البيانات الأسبوعي'),
    Bi('Steering committee', 'اللجنة التوجيهية'),
    Bi('Vendor review', 'مراجعة الموردين'),
    Bi('Audit kick-off', 'بدء التدقيق'),
  ];
  static const List<Bi> _todoStatus = <Bi>[
    Bi('Done', 'منجز'),
    Bi('In progress', 'قيد التنفيذ'),
    Bi('Not started', 'لم يبدأ'),
    Bi('Blocked', 'متوقف'),
  ];
  static const List<Bi> _topics = <Bi>[
    Bi('Data governance', 'حوكمة البيانات'),
    Bi('Data quality', 'جودة البيانات'),
    Bi('Metadata', 'البيانات الوصفية'),
    Bi('Privacy', 'الخصوصية'),
    Bi('Analytics', 'التحليلات'),
  ];
  static const List<Bi> _readings = <Bi>[
    Bi('DAMA data management body of knowledge',
        'الإطار المعرفي لإدارة البيانات'),
    Bi('National data management standards', 'معايير إدارة البيانات الوطنية'),
    Bi('Data quality measurement guide', 'دليل قياس جودة البيانات'),
    Bi('Metadata management primer', 'مقدمة في إدارة البيانات الوصفية'),
    Bi('Personal data protection regulations', 'لوائح حماية البيانات الشخصية'),
    Bi('Open data licensing guide', 'دليل ترخيص البيانات المفتوحة'),
    Bi('Dashboard design principles', 'مبادئ تصميم لوحات المؤشرات'),
    Bi('Master data management in practice', 'إدارة البيانات الرئيسية عملياً'),
    Bi('Records retention best practices', 'أفضل ممارسات الاحتفاظ بالسجلات'),
    Bi('Data sharing agreement templates', 'نماذج اتفاقيات مشاركة البيانات'),
  ];
  static const List<Bi> _sources = <Bi>[
    Bi('Internal library', 'المكتبة الداخلية'),
    Bi('Standards body', 'جهة المعايير'),
    Bi('Industry journal', 'مجلة متخصصة'),
    Bi('Training portal', 'بوابة التدريب'),
  ];
  static const List<Bi> _priority = <Bi>[
    Bi('High', 'عالية'),
    Bi('Medium', 'متوسطة'),
    Bi('Low', 'منخفضة'),
  ];
  static const List<Bi> _courses = <Bi>[
    Bi('Data stewardship fundamentals', 'أساسيات أمانة البيانات'),
    Bi('Advanced data quality', 'جودة البيانات المتقدمة'),
    Bi('Metadata and cataloguing', 'البيانات الوصفية والفهرسة'),
    Bi('Privacy impact assessment', 'تقييم الأثر على الخصوصية'),
    Bi('Risk and control self-assessment', 'التقييم الذاتي للمخاطر والضوابط'),
    Bi('Records management essentials', 'أساسيات إدارة السجلات'),
    Bi('Business continuity exercise design', 'تصميم تمارين استمرارية الأعمال'),
    Bi('Data storytelling', 'سرد القصص بالبيانات'),
  ];
  static const List<Bi> _providers = <Bi>[
    Bi('Rawafid Training', 'روافد للتدريب'),
    Bi('National Institute of Public Administration', 'معهد الإدارة العامة'),
    Bi('Internal academy', 'الأكاديمية الداخلية'),
    Bi('Online platform', 'منصة إلكترونية'),
  ];
  static const List<Bi> _ideas = <Bi>[
    Bi('Executive data quality summary', 'ملخص تنفيذي لجودة البيانات'),
    Bi('Department compliance heat map', 'خريطة حرارية لامتثال الإدارات'),
    Bi('Evidence submission timeliness', 'الالتزام بمواعيد رفع الأدلة'),
    Bi('Open data downloads trend', 'اتجاه تنزيلات البيانات المفتوحة'),
    Bi('Supplier spend overview', 'نظرة عامة على إنفاق الموردين'),
    Bi('Service request backlog', 'تراكم طلبات الخدمة'),
    Bi('Records retention calendar', 'تقويم الاحتفاظ بالسجلات'),
    Bi('Risk trend by quarter', 'اتجاه المخاطر حسب الربع'),
  ];
  static const List<Bi> _audiences = <Bi>[
    Bi('Leadership', 'القيادة'),
    Bi('Department heads', 'رؤساء الإدارات'),
    Bi('Data stewards', 'أمناء البيانات'),
    Bi('Public', 'الجمهور'),
  ];
  static const List<Bi> _levels = <Bi>[
    Bi('Low', 'منخفض'),
    Bi('Medium', 'متوسط'),
    Bi('High', 'مرتفع'),
  ];
  static const List<Bi> _observations = <Bi>[
    Bi('Missing postcodes in the address file',
        'رموز بريدية ناقصة في ملف العناوين'),
    Bi('Duplicate supplier names with different spellings',
        'أسماء موردين مكررة بصيغ إملائية مختلفة'),
    Bi('Date format differs between two source systems',
        'اختلاف صيغة التاريخ بين نظامين مصدرين'),
    Bi('Region names not aligned with the reference list',
        'أسماء المناطق غير متوافقة مع القائمة المرجعية'),
    Bi('Negative values found in the quantity column',
        'قيم سالبة في عمود الكمية'),
    Bi('Owner not assigned for two new datasets',
        'لم يُعيّن مالك لمجموعتي بيانات جديدتين'),
    Bi('Records older than the retention period still present',
        'سجلات أقدم من فترة الاحتفاظ ما زالت موجودة'),
    Bi('Late refresh of the daily extract', 'تأخر تحديث المستخرج اليومي'),
  ];
  static const List<Bi> _noteActions = <Bi>[
    Bi('Raise with the data owner', 'رفع الموضوع إلى مالك البيانات'),
    Bi('Add a validation rule', 'إضافة قاعدة تحقق'),
    Bi('Agree the standard format', 'الاتفاق على الصيغة الموحدة'),
    Bi('Update the reference list', 'تحديث القائمة المرجعية'),
    Bi('Clean and reload', 'التنظيف وإعادة التحميل'),
  ];
  static const List<Bi> _agreementsParties = <Bi>[
    Bi('Statistics Authority', 'هيئة الإحصاء'),
    Bi('Civil Affairs Authority', 'هيئة الأحوال المدنية'),
    Bi('Ministry of Commerce', 'وزارة التجارة'),
    Bi('Media Regulatory Authority', 'هيئة تنظيم الإعلام'),
  ];
  static const List<Bi> _retention = <Bi>[
    Bi('Procurement files', 'ملفات المشتريات'),
    Bi('Service requests', 'طلبات الخدمات'),
    Bi('Press accreditation', 'الاعتماد الصحفي'),
    Bi('Audit working papers', 'أوراق عمل التدقيق'),
    Bi('Board minutes', 'محاضر المجلس'),
    Bi('Access logs', 'سجلات الوصول'),
  ];
  static const List<Bi> _disposal = <Bi>[
    Bi('Secure deletion', 'حذف آمن'),
    Bi('Archive transfer', 'نقل إلى الأرشيف'),
    Bi('Shredding', 'إتلاف ورقي'),
  ];
  static const List<Bi> _legal = <Bi>[
    Bi('Records law, article 12', 'نظام السجلات، المادة 12'),
    Bi('Financial regulations', 'اللوائح المالية'),
    Bi('Internal policy', 'سياسة داخلية'),
    Bi('Data protection law', 'نظام حماية البيانات'),
  ];
  static const List<Bi> _fields = <Bi>[
    Bi('Customer ID', 'رقم العميل'),
    Bi('Postal code', 'الرمز البريدي'),
    Bi('Supplier name', 'اسم المورد'),
    Bi('Region', 'المنطقة'),
    Bi('Contract value', 'قيمة العقد'),
    Bi('Created date', 'تاريخ الإنشاء'),
    Bi('Owner email', 'بريد المالك'),
    Bi('Status code', 'رمز الحالة'),
  ];
  static const List<Bi> _transforms = <Bi>[
    Bi('Copy as is', 'نسخ كما هو'),
    Bi('Trim and upper case', 'إزالة المسافات وتحويل لأحرف كبيرة'),
    Bi('Map to reference list', 'مطابقة مع القائمة المرجعية'),
    Bi('Convert date format', 'تحويل صيغة التاريخ'),
    Bi('Split into two fields', 'تقسيم إلى حقلين'),
  ];
  static const List<Bi> _mapStatus = <Bi>[
    Bi('Agreed', 'متفق عليه'),
    Bi('To review', 'للمراجعة'),
    Bi('Rejected', 'مرفوض'),
  ];
  static const List<Bi> _surveyQuestions = <Bi>[
    Bi('The service was easy to find', 'كان من السهل الوصول إلى الخدمة'),
    Bi('The process was clear', 'كانت الإجراءات واضحة'),
    Bi('Staff were helpful', 'كان الموظفون متعاونين'),
    Bi('The result met my needs', 'حققت النتيجة احتياجي'),
    Bi('I would use the service again', 'سأستخدم الخدمة مرة أخرى'),
    Bi('Waiting time was acceptable', 'كان وقت الانتظار مقبولاً'),
    Bi('The information was accurate', 'كانت المعلومات دقيقة'),
    Bi('I trust how my data is handled', 'أثق في طريقة التعامل مع بياناتي'),
  ];
  static const List<Bi> _ageGroups = <Bi>[
    Bi('18 to 25', '18 إلى 25'),
    Bi('26 to 35', '26 إلى 35'),
    Bi('36 to 45', '36 إلى 45'),
    Bi('46 to 60', '46 إلى 60'),
    Bi('Over 60', 'أكثر من 60'),
  ];
  static const List<Bi> _gender = <Bi>[
    Bi('Female', 'أنثى'),
    Bi('Male', 'ذكر'),
  ];
  static const List<Bi> _regStatus = <Bi>[
    Bi('Verified', 'موثق'),
    Bi('Pending verification', 'بانتظار التوثيق'),
    Bi('Updated', 'محدّث'),
  ];
  static const List<Bi> _licenceTypes = <Bi>[
    Bi('Annual', 'سنوي'),
    Bi('Perpetual', 'دائم'),
    Bi('Per use', 'حسب الاستخدام'),
  ];
  static const List<Bi> _renewal = <Bi>[
    Bi('Renewed', 'تم التجديد'),
    Bi('Due soon', 'يحين قريباً'),
    Bi('Not required', 'غير مطلوب'),
  ];
  static const List<Bi> _countries = <Bi>[
    Bi('Saudi Arabia', 'السعودية'),
    Bi('United Arab Emirates', 'الإمارات'),
    Bi('Bahrain', 'البحرين'),
    Bi('Jordan', 'الأردن'),
  ];
  static const List<Bi> _reachCountries = <Bi>[
    Bi('Print', 'مطبوع'),
    Bi('Online', 'إلكتروني'),
    Bi('Broadcast', 'مرئي ومسموع'),
  ];
  static const List<Bi> _headlines = <Bi>[
    Bi('Launch of the unified services platform', 'إطلاق منصة الخدمات الموحدة'),
    Bi('New open data policy announced',
        'الإعلان عن سياسة البيانات المفتوحة الجديدة'),
    Bi('Annual statistics report released', 'صدور التقرير الإحصائي السنوي'),
    Bi('Partnership signed on data sharing', 'توقيع شراكة لمشاركة البيانات'),
    Bi('Results of the citizen satisfaction survey', 'نتائج مسح رضا المواطنين'),
    Bi('Cybersecurity awareness week begins',
        'انطلاق أسبوع التوعية بالأمن السيبراني'),
    Bi('Records digitisation milestone reached',
        'تحقيق مرحلة مهمة في رقمنة السجلات'),
    Bi('Statement on service availability', 'بيان بشأن توافر الخدمات'),
    Bi('Media accreditation window opens', 'فتح باب الاعتماد الإعلامي'),
    Bi('Data quality programme update', 'تحديث برنامج جودة البيانات'),
  ];

  // ── Templates ─────────────────────────────────────────────────────────
  static final Map<String, DbTemplate> templates = <String, DbTemplate>{
    'datasets': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Dataset ID', 'معرّف المجموعة'), TableColumnType.general),
        DbCol(Bi('Dataset name', 'اسم المجموعة'), TableColumnType.general),
        DbCol(
            Bi('Owner department', 'الإدارة المالكة'), TableColumnType.general),
        DbCol(Bi('Classification', 'التصنيف'), TableColumnType.general),
        DbCol(Bi('Format', 'الصيغة'), TableColumnType.general),
        DbCol(Bi('Update frequency', 'دورية التحديث'), TableColumnType.general),
        DbCol(Bi('Records', 'عدد السجلات'), TableColumnType.number),
        DbCol(Bi('Quality score', 'درجة الجودة'), TableColumnType.percentage),
      ],
      (DbCtx x, int i) => <String>[
        x.id('DS', i),
        x.pick(_datasets, i),
        x.pick(_departments, i, 1),
        x.pick(_classes, i, 2),
        x.pick(_formats, i, 3),
        x.pick(_freq, i, 4),
        '${x.n(i, 5, 1200, 4800000)}',
        x.pct(i, 6, 71, 98),
      ],
    ),
    'owners': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Data owner', 'مالك البيانات'), TableColumnType.general),
        DbCol(Bi('Department', 'الإدارة'), TableColumnType.general),
        DbCol(
            Bi('Datasets owned', 'المجموعات المملوكة'), TableColumnType.number),
        DbCol(Bi('Last review', 'آخر مراجعة'), TableColumnType.date),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.person(i),
        x.pick(_departments, i, 1),
        '${x.n(i, 2, 1, 14)}',
        x.date(i, 3),
        x.pick(_status, i, 4),
      ],
    ),
    'assets': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Asset ID', 'معرّف الأصل'), TableColumnType.general),
        DbCol(Bi('Title', 'العنوان'), TableColumnType.general),
        DbCol(Bi('Type', 'النوع'), TableColumnType.general),
        DbCol(Bi('Rights holder', 'صاحب الحقوق'), TableColumnType.general),
        DbCol(Bi('Added on', 'تاريخ الإضافة'), TableColumnType.date),
        DbCol(Bi('Licence expiry', 'انتهاء الترخيص'), TableColumnType.date),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.id('MA', i, 2000),
        x.pick(_assetTitles, i),
        x.pick(_assetTypes, i, 1),
        x.pick(_rights, i, 2),
        x.date(i, 3),
        x.future(i, 4),
        x.pick(_status, i, 5),
      ],
    ),
    'licences': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Asset ID', 'معرّف الأصل'), TableColumnType.general),
        DbCol(Bi('Rights holder', 'صاحب الحقوق'), TableColumnType.general),
        DbCol(Bi('Licence type', 'نوع الترخيص'), TableColumnType.general),
        DbCol(Bi('Expiry', 'تاريخ الانتهاء'), TableColumnType.date),
        DbCol(Bi('Cost (SAR)', 'التكلفة (ريال)'), TableColumnType.currency),
        DbCol(Bi('Renewal', 'التجديد'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.id('MA', i, 2000),
        x.pick(_rights, i, 1),
        x.pick(_licenceTypes, i, 2),
        x.future(i, 3),
        x.money(i, 4, 800, 24000),
        x.pick(_renewal, i, 5),
      ],
    ),
    'publications': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Reference', 'المرجع'), TableColumnType.general),
        DbCol(Bi('Title', 'العنوان'), TableColumnType.general),
        DbCol(Bi('Category', 'الفئة'), TableColumnType.general),
        DbCol(Bi('Language', 'اللغة'), TableColumnType.general),
        DbCol(Bi('Publish date', 'تاريخ النشر'), TableColumnType.date),
        DbCol(Bi('Pages', 'الصفحات'), TableColumnType.number),
        DbCol(Bi('Downloads', 'التنزيلات'), TableColumnType.number),
      ],
      (DbCtx x, int i) => <String>[
        x.id('PUB', i, 100),
        x.pick(_pubTitles, i),
        x.pick(_pubCats, i, 1),
        x.pick(_langs, i, 2),
        x.date(i, 3),
        '${x.n(i, 4, 8, 180)}',
        '${x.n(i, 5, 120, 9800)}',
      ],
    ),
    'metrics': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Month', 'الشهر'), TableColumnType.general),
        DbCol(
            Bi('Items published', 'العناصر المنشورة'), TableColumnType.number),
        DbCol(Bi('Downloads', 'التنزيلات'), TableColumnType.number),
        DbCol(Bi('Page views', 'مشاهدات الصفحات'), TableColumnType.number),
        DbCol(Bi('Active users', 'المستخدمون النشطون'), TableColumnType.number),
        DbCol(Bi('Growth', 'النمو'), TableColumnType.percentage),
      ],
      (DbCtx x, int i) => <String>[
        x.t(_months[i % 12]),
        '${x.n(i, 1, 8, 46)}',
        '${x.n(i, 2, 3200, 21000) + i * 450}',
        '${x.n(i, 3, 18000, 64000) + i * 900}',
        '${x.n(i, 4, 900, 4200) + i * 60}',
        x.pct(i, 5, 2, 14),
      ],
    ),
    'releases': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Reference', 'المرجع'), TableColumnType.general),
        DbCol(Bi('Headline', 'العنوان'), TableColumnType.general),
        DbCol(Bi('Date', 'التاريخ'), TableColumnType.date),
        DbCol(Bi('Department', 'الإدارة'), TableColumnType.general),
        DbCol(Bi('Language', 'اللغة'), TableColumnType.general),
        DbCol(Bi('Channel', 'القناة'), TableColumnType.general),
        DbCol(Bi('Reach', 'الوصول'), TableColumnType.number),
      ],
      (DbCtx x, int i) => <String>[
        x.id('PR', i, 300),
        x.pick(_headlines, i),
        x.date(i, 1),
        x.pick(_departments, i, 2),
        x.pick(_langs, i, 3),
        x.pick(_reachCountries, i, 4),
        '${x.n(i, 5, 4000, 380000)}',
      ],
    ),
    'services': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Service', 'الخدمة'), TableColumnType.general),
        DbCol(Bi('Entity', 'الجهة'), TableColumnType.general),
        DbCol(Bi('Main channel', 'القناة الرئيسية'), TableColumnType.general),
        DbCol(Bi('Target time (days)', 'المدة المستهدفة (أيام)'),
            TableColumnType.number),
        DbCol(Bi('Fee (SAR)', 'الرسوم (ريال)'), TableColumnType.currency),
        DbCol(Bi('Satisfaction', 'الرضا'), TableColumnType.percentage),
      ],
      (DbCtx x, int i) => <String>[
        x.t(_services[i % _services.length]),
        x.pick(_entities, i, 1),
        x.pick(_channels, i, 2),
        '${x.n(i, 3, 1, 14)}',
        x.money(i, 4, 0, 1500),
        x.pct(i, 5, 74, 97),
      ],
    ),
    'channels': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Channel', 'القناة'), TableColumnType.general),
        DbCol(
            Bi('Monthly requests', 'الطلبات الشهرية'), TableColumnType.number),
        DbCol(Bi('Average handling (days)', 'متوسط المعالجة (أيام)'),
            TableColumnType.number),
        DbCol(Bi('Satisfaction', 'الرضا'), TableColumnType.percentage),
        DbCol(Bi('Last review', 'آخر مراجعة'), TableColumnType.date),
      ],
      (DbCtx x, int i) => <String>[
        x.t(_channels[i % _channels.length]),
        '${x.n(i, 1, 3000, 90000)}',
        '${x.n(i, 2, 1, 6)}',
        x.pct(i, 3, 76, 96),
        x.date(i, 4),
      ],
    ),
    'citizens': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Registry number', 'رقم السجل'), TableColumnType.general),
        DbCol(Bi('Region', 'المنطقة'), TableColumnType.general),
        DbCol(Bi('Age group', 'الفئة العمرية'), TableColumnType.general),
        DbCol(Bi('Gender', 'الجنس'), TableColumnType.general),
        DbCol(Bi('Registered on', 'تاريخ التسجيل'), TableColumnType.date),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
        DbCol(Bi('Record completeness', 'اكتمال السجل'),
            TableColumnType.percentage),
      ],
      (DbCtx x, int i) => <String>[
        'CR-${100000 + DbCtx.h(i, 1) % 899999}',
        x.pick(_regions, i, 2),
        x.pick(_ageGroups, i, 3),
        x.pick(_gender, i, 4),
        x.date(i, 5),
        x.pick(_regStatus, i, 6),
        x.pct(i, 7, 82, 99),
      ],
    ),
    'regions': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Region', 'المنطقة'), TableColumnType.general),
        DbCol(Bi('Population', 'السكان'), TableColumnType.number),
        DbCol(Bi('Registered', 'المسجلون'), TableColumnType.number),
        DbCol(Bi('Coverage', 'التغطية'), TableColumnType.percentage),
        DbCol(Bi('Last sync', 'آخر مزامنة'), TableColumnType.date),
      ],
      (DbCtx x, int i) {
        final int pop = x.n(i, 1, 600000, 8200000);
        final int cov = x.n(i, 2, 88, 99);
        return <String>[
          x.t(_regions[i % _regions.length]),
          '$pop',
          '${pop * cov ~/ 100}',
          '$cov.${DbCtx.h(i, 3) % 10}%',
          x.date(i, 4),
        ];
      },
    ),
    'contracts': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Contract no.', 'رقم العقد'), TableColumnType.general),
        DbCol(Bi('Supplier', 'المورد'), TableColumnType.general),
        DbCol(Bi('Category', 'الفئة'), TableColumnType.general),
        DbCol(Bi('Value (SAR)', 'القيمة (ريال)'), TableColumnType.currency),
        DbCol(Bi('Start date', 'تاريخ البداية'), TableColumnType.date),
        DbCol(Bi('End date', 'تاريخ النهاية'), TableColumnType.date),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.id('CT-26', i, 100),
        x.pick(_suppliers, i, 1),
        x.pick(_contractCats, i, 2),
        x.money(i, 3, 45000, 1900000),
        x.date(i, 4),
        x.future(i, 5),
        x.pick(_contractStatus, i, 6),
      ],
    ),
    'suppliers': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Supplier', 'المورد'), TableColumnType.general),
        DbCol(Bi('Category', 'الفئة'), TableColumnType.general),
        DbCol(Bi('Performance rating', 'تقييم الأداء'),
            TableColumnType.percentage),
        DbCol(Bi('Active contracts', 'العقود السارية'), TableColumnType.number),
        DbCol(Bi('Country', 'الدولة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.t(_suppliers[i % _suppliers.length]),
        x.pick(_contractCats, i, 1),
        x.pct(i, 2, 68, 97),
        '${x.n(i, 3, 1, 6)}',
        x.pick(_countries, i, 4),
      ],
    ),
    'scorecards': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Dataset', 'مجموعة البيانات'), TableColumnType.general),
        DbCol(Bi('Completeness', 'الاكتمال'), TableColumnType.percentage),
        DbCol(Bi('Accuracy', 'الدقة'), TableColumnType.percentage),
        DbCol(Bi('Timeliness', 'الحداثة'), TableColumnType.percentage),
        DbCol(Bi('Consistency', 'الاتساق'), TableColumnType.percentage),
        DbCol(Bi('Overall score', 'الدرجة الإجمالية'),
            TableColumnType.percentage),
        DbCol(Bi('Last run', 'آخر تشغيل'), TableColumnType.date),
      ],
      (DbCtx x, int i) {
        final int a = x.n(i, 1, 78, 99);
        final int b = x.n(i, 2, 74, 99);
        final int c = x.n(i, 3, 70, 99);
        final int d = x.n(i, 4, 76, 99);
        return <String>[
          x.t(_datasets[i % _datasets.length]),
          '$a.${DbCtx.h(i, 5) % 10}%',
          '$b.${DbCtx.h(i, 6) % 10}%',
          '$c.${DbCtx.h(i, 7) % 10}%',
          '$d.${DbCtx.h(i, 8) % 10}%',
          '${((a + b + c + d) / 4).toStringAsFixed(1)}%',
          x.date(i, 9),
        ];
      },
    ),
    'dqissues': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Issue ID', 'معرّف المشكلة'), TableColumnType.general),
        DbCol(Bi('Dataset', 'مجموعة البيانات'), TableColumnType.general),
        DbCol(Bi('Dimension', 'البُعد'), TableColumnType.general),
        DbCol(Bi('Severity', 'الخطورة'), TableColumnType.general),
        DbCol(Bi('Owner', 'المسؤول'), TableColumnType.general),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
        DbCol(Bi('Opened', 'تاريخ الفتح'), TableColumnType.date),
      ],
      (DbCtx x, int i) => <String>[
        x.id('DQ', i, 400),
        x.pick(_datasets, i, 1),
        x.pick(_dimensions, i, 2),
        x.pick(_severity, i, 3),
        x.person(i, 4),
        x.pick(_issueStatus, i, 5),
        x.date(i, 6),
      ],
    ),
    'incidents': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Incident ID', 'معرّف الحادثة'), TableColumnType.general),
        DbCol(Bi('Date', 'التاريخ'), TableColumnType.date),
        DbCol(Bi('Category', 'الفئة'), TableColumnType.general),
        DbCol(Bi('Severity', 'الخطورة'), TableColumnType.general),
        DbCol(Bi('Owner', 'المسؤول'), TableColumnType.general),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
        DbCol(Bi('Days to close', 'أيام الإغلاق'), TableColumnType.number),
      ],
      (DbCtx x, int i) => <String>[
        x.id('INC', i, 700),
        x.date(i, 1),
        x.pick(_incidentCats, i, 2),
        x.pick(_severity, i, 3),
        x.person(i, 4),
        x.pick(_issueStatus, i, 5),
        '${x.n(i, 6, 1, 28)}',
      ],
    ),
    'actions': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Reference', 'المرجع'), TableColumnType.general),
        DbCol(Bi('Action', 'الإجراء'), TableColumnType.general),
        DbCol(Bi('Owner', 'المسؤول'), TableColumnType.general),
        DbCol(Bi('Due date', 'تاريخ الاستحقاق'), TableColumnType.date),
        DbCol(Bi('Source', 'المصدر'), TableColumnType.general),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.id('ACT', i, 500),
        x.t(_actions[i % _actions.length]),
        x.person(i, 2),
        x.future(i, 3),
        x.pick(_meetings, i, 4),
        x.pick(_todoStatus, i, 5),
      ],
    ),
    'budget': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Budget line', 'بند الميزانية'), TableColumnType.general),
        DbCol(Bi('Department', 'الإدارة'), TableColumnType.general),
        DbCol(Bi('Allocated (SAR)', 'المخصص (ريال)'), TableColumnType.currency),
        DbCol(Bi('Spent (SAR)', 'المصروف (ريال)'), TableColumnType.currency),
        DbCol(Bi('Utilisation', 'نسبة الاستخدام'), TableColumnType.percentage),
      ],
      (DbCtx x, int i) {
        final int allocated = x.n(i, 1, 300, 4200) * 1000;
        final int pct = x.n(i, 2, 38, 94);
        return <String>[
          x.t(_budgetLines[i % _budgetLines.length]),
          x.pick(_departments, i, 3),
          '$allocated.00',
          '${allocated * pct ~/ 100}.00',
          '$pct.${DbCtx.h(i, 4) % 10}%',
        ];
      },
    ),
    'spend': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Month', 'الشهر'), TableColumnType.general),
        DbCol(Bi('Planned (SAR)', 'المخطط (ريال)'), TableColumnType.currency),
        DbCol(Bi('Actual (SAR)', 'الفعلي (ريال)'), TableColumnType.currency),
        DbCol(Bi('Variance', 'الانحراف'), TableColumnType.percentage),
      ],
      (DbCtx x, int i) {
        final int planned = (480 + x.n(i, 1, 0, 180)) * 1000;
        final int variance = x.n(i, 2, 1, 12);
        final int actual = planned * (100 - variance) ~/ 100;
        return <String>[
          x.t(_months[i % 12]),
          '$planned.00',
          '$actual.00',
          '$variance.${DbCtx.h(i, 3) % 10}%',
        ];
      },
    ),
    'findings': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Finding ID', 'معرّف الملاحظة'), TableColumnType.general),
        DbCol(Bi('Area', 'المجال'), TableColumnType.general),
        DbCol(Bi('Rating', 'التقييم'), TableColumnType.general),
        DbCol(Bi('Owner', 'المسؤول'), TableColumnType.general),
        DbCol(Bi('Raised on', 'تاريخ الرصد'), TableColumnType.date),
        DbCol(Bi('Due date', 'تاريخ الاستحقاق'), TableColumnType.date),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.id('AF', i, 200),
        x.pick(_areas, i, 1),
        x.pick(_severity, i, 2),
        x.person(i, 3),
        x.date(i, 4),
        x.future(i, 5),
        x.pick(_findingStatus, i, 6),
      ],
    ),
    'notes': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Date', 'التاريخ'), TableColumnType.date),
        DbCol(Bi('Dataset', 'مجموعة البيانات'), TableColumnType.general),
        DbCol(Bi('Observation', 'الملاحظة'), TableColumnType.general),
        DbCol(Bi('Next step', 'الخطوة التالية'), TableColumnType.general),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.date(i, 1),
        x.pick(_datasets, i, 2),
        x.pick(_observations, i, 3),
        x.pick(_noteActions, i, 4),
        x.pick(_todoStatus, i, 5),
      ],
    ),
    'reading': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Title', 'العنوان'), TableColumnType.general),
        DbCol(Bi('Source', 'المصدر'), TableColumnType.general),
        DbCol(Bi('Topic', 'الموضوع'), TableColumnType.general),
        DbCol(Bi('Priority', 'الأولوية'), TableColumnType.general),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.t(_readings[i % _readings.length]),
        x.pick(_sources, i, 1),
        x.pick(_topics, i, 2),
        x.pick(_priority, i, 3),
        x.pick(_todoStatus, i, 4),
      ],
    ),
    'training': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Course', 'الدورة'), TableColumnType.general),
        DbCol(Bi('Provider', 'الجهة المقدمة'), TableColumnType.general),
        DbCol(Bi('Hours', 'الساعات'), TableColumnType.number),
        DbCol(Bi('Date', 'التاريخ'), TableColumnType.date),
        DbCol(Bi('Cost (SAR)', 'التكلفة (ريال)'), TableColumnType.currency),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.t(_courses[i % _courses.length]),
        x.pick(_providers, i, 1),
        '${x.n(i, 2, 6, 40)}',
        i % 3 == 0 ? x.date(i, 3) : x.future(i, 3),
        x.money(i, 4, 0, 6500),
        x.pick(_todoStatus, i, 5),
      ],
    ),
    'ideas': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Idea', 'الفكرة'), TableColumnType.general),
        DbCol(Bi('Audience', 'الجمهور'), TableColumnType.general),
        DbCol(Bi('Effort', 'الجهد'), TableColumnType.general),
        DbCol(Bi('Impact', 'الأثر'), TableColumnType.general),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.t(_ideas[i % _ideas.length]),
        x.pick(_audiences, i, 1),
        x.pick(_levels, i, 2),
        x.pick(_levels, i, 3),
        x.pick(_todoStatus, i, 4),
      ],
    ),
    'retention': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Record series', 'سلسلة السجلات'), TableColumnType.general),
        DbCol(
            Bi('Owner department', 'الإدارة المالكة'), TableColumnType.general),
        DbCol(Bi('Retention (years)', 'مدة الاحتفاظ (سنوات)'),
            TableColumnType.number),
        DbCol(Bi('Legal basis', 'السند النظامي'), TableColumnType.general),
        DbCol(Bi('Disposal method', 'طريقة التصرف'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.t(_retention[i % _retention.length]),
        x.pick(_departments, i, 1),
        '${x.n(i, 2, 2, 15)}',
        x.pick(_legal, i, 3),
        x.pick(_disposal, i, 4),
      ],
    ),
    'survey': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Statement', 'العبارة'), TableColumnType.general),
        DbCol(Bi('Responses', 'عدد الردود'), TableColumnType.number),
        DbCol(Bi('Positive', 'إيجابي'), TableColumnType.percentage),
        DbCol(Bi('Neutral', 'محايد'), TableColumnType.percentage),
        DbCol(Bi('Negative', 'سلبي'), TableColumnType.percentage),
      ],
      (DbCtx x, int i) {
        final int pos = x.n(i, 1, 62, 88);
        final int neg = x.n(i, 2, 2, 8);
        return <String>[
          x.t(_surveyQuestions[i % _surveyQuestions.length]),
          '${x.n(i, 3, 1200, 5400)}',
          '$pos.0%',
          '${100 - pos - neg}.0%',
          '$neg.0%',
        ];
      },
    ),
    'mapping': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Source field', 'الحقل المصدر'), TableColumnType.general),
        DbCol(Bi('Target field', 'الحقل الهدف'), TableColumnType.general),
        DbCol(Bi('Transformation', 'التحويل'), TableColumnType.general),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.t(_fields[i % _fields.length]),
        x.t(_fields[(i + 3) % _fields.length]),
        x.pick(_transforms, i, 1),
        x.pick(_mapStatus, i, 2),
      ],
    ),
    'agreements': DbTemplate(
      const <DbCol>[
        DbCol(Bi('Agreement', 'الاتفاقية'), TableColumnType.general),
        DbCol(Bi('Counterparty', 'الطرف الآخر'), TableColumnType.general),
        DbCol(Bi('Signed on', 'تاريخ التوقيع'), TableColumnType.date),
        DbCol(Bi('Expires on', 'تاريخ الانتهاء'), TableColumnType.date),
        DbCol(Bi('Status', 'الحالة'), TableColumnType.general),
      ],
      (DbCtx x, int i) => <String>[
        x.id('DSA', i, 10),
        x.pick(_agreementsParties, i, 1),
        x.date(i, 2),
        x.future(i, 3),
        x.pick(_status, i, 4),
      ],
    ),
  };

  // ── The databases ─────────────────────────────────────────────────────
  static const List<DbSpec> specs = <DbSpec>[
    // Open access (6)
    DbSpec(
      title: Bi('Dataset Catalogue', 'فهرس مجموعات البيانات'),
      description: Bi(
          'The register of every dataset the organisation publishes or consumes, with its owner, classification and quality score.',
          'سجل جميع مجموعات البيانات التي تنشرها المنظمة أو تستهلكها، مع مالكها وتصنيفها ودرجة جودتها.'),
      access: DbAccess.open,
      state: DbState.active,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef(
            'datasets',
            Bi('Datasets', 'مجموعات البيانات'),
            Bi('One row per dataset with its owner department, format and update frequency.',
                'صف لكل مجموعة بيانات مع الإدارة المالكة والصيغة ودورية التحديث.'),
            rows: 16,
            shared: true),
        DbTableRef(
            'owners',
            Bi('Data Owners', 'مالكو البيانات'),
            Bi('Named owners and the date of their last review.',
                'المالكون المعتمدون وتاريخ آخر مراجعة لكل منهم.'),
            rows: 10),
      ],
    ),
    DbSpec(
      title: Bi('Media Assets Library', 'مكتبة الأصول الإعلامية'),
      description: Bi(
          'Photos, videos and infographics held by the communications team, with the rights holder and licence expiry.',
          'الصور ومقاطع الفيديو والإنفوجرافيك لدى فريق الاتصال، مع صاحب الحقوق وتاريخ انتهاء الترخيص.'),
      access: DbAccess.open,
      state: DbState.active,
      byMe: false,
      tables: <DbTableRef>[
        DbTableRef(
            'assets',
            Bi('Asset Register', 'سجل الأصول'),
            Bi('Every media asset with its type and rights holder.',
                'كل أصل إعلامي مع نوعه وصاحب حقوقه.'),
            rows: 18),
        DbTableRef(
            'licences',
            Bi('Rights and Licences', 'الحقوق والتراخيص'),
            Bi('Licence type, expiry and renewal status per asset.',
                'نوع الترخيص وتاريخ انتهائه وحالة التجديد لكل أصل.'),
            rows: 12),
      ],
    ),
    DbSpec(
      title: Bi('Publications Register', 'سجل المنشورات'),
      description: Bi(
          'Reports, bulletins and guides published this year, with language, length and download counts.',
          'التقارير والنشرات والأدلة المنشورة هذا العام، مع اللغة وعدد الصفحات والتنزيلات.'),
      access: DbAccess.open,
      state: DbState.active,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('publications', Bi('Publications', 'المنشورات'),
            Bi('One row per publication.', 'صف لكل منشور.'),
            rows: 15),
        DbTableRef(
            'metrics',
            Bi('Monthly Statistics', 'الإحصاءات الشهرية'),
            Bi('Items published, downloads and visitors by month.',
                'العناصر المنشورة والتنزيلات والزوار حسب الشهر.'),
            rows: 10),
      ],
    ),
    DbSpec(
      title: Bi('Public Services Directory', 'دليل الخدمات الحكومية'),
      description: Bi(
          'Services offered to citizens and businesses with target time, fee and satisfaction.',
          'الخدمات المقدمة للمواطنين والأعمال مع المدة المستهدفة والرسوم ومستوى الرضا.'),
      access: DbAccess.open,
      state: DbState.active,
      byMe: false,
      tables: <DbTableRef>[
        DbTableRef(
            'services',
            Bi('Services', 'الخدمات'),
            Bi('Service catalogue with the responsible entity.',
                'دليل الخدمات مع الجهة المسؤولة.'),
            rows: 12),
        DbTableRef(
            'channels',
            Bi('Channels', 'القنوات'),
            Bi('Request volume and satisfaction by channel.',
                'حجم الطلبات والرضا حسب القناة.'),
            rows: 4),
      ],
    ),
    DbSpec(
      title: Bi('Open Data Portal Metrics', 'مؤشرات بوابة البيانات المفتوحة'),
      description: Bi(
          'Usage of the open data portal: downloads, page views and active users each month.',
          'استخدام بوابة البيانات المفتوحة: التنزيلات ومشاهدات الصفحات والمستخدمون النشطون كل شهر.'),
      access: DbAccess.open,
      state: DbState.active,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('metrics', Bi('Monthly Metrics', 'المؤشرات الشهرية'),
            Bi('Portal usage by month.', 'استخدام البوابة حسب الشهر.'),
            rows: 10),
        DbTableRef(
            'datasets',
            Bi('Most Downloaded Datasets', 'الأكثر تنزيلاً'),
            Bi('The datasets that attract the most downloads.',
                'مجموعات البيانات الأكثر تنزيلاً.'),
            rows: 10),
      ],
    ),
    DbSpec(
      title: Bi('Press Releases Archive', 'أرشيف البيانات الصحفية'),
      description: Bi(
          'All press releases issued in 2026 with the issuing department, language and reach.',
          'جميع البيانات الصحفية الصادرة في 2026 مع الإدارة المصدِرة واللغة والوصول.'),
      access: DbAccess.open,
      state: DbState.active,
      byMe: false,
      tables: <DbTableRef>[
        DbTableRef('releases', Bi('Releases', 'البيانات الصحفية'),
            Bi('One row per press release.', 'صف لكل بيان صحفي.'),
            rows: 18, shared: true),
      ],
    ),

    // Restricted access (6)
    DbSpec(
      title: Bi('Citizens Registry', 'سجل المواطنين'),
      description: Bi(
          'Registry records by region with completeness checks. Access is limited to the registry team and the data quality leads.',
          'سجلات المواطنين حسب المنطقة مع فحوصات الاكتمال. الوصول مقصور على فريق السجل وقادة جودة البيانات.'),
      access: DbAccess.restricted,
      state: DbState.active,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef(
            'citizens',
            Bi('Registry Records', 'سجلات المواطنين'),
            Bi('Masked registry numbers with region, age group and record completeness.',
                'أرقام سجل مخفية مع المنطقة والفئة العمرية واكتمال السجل.'),
            rows: 20,
            shared: true,
            restricted: true),
        DbTableRef(
            'regions',
            Bi('Regional Coverage', 'التغطية الإقليمية'),
            Bi('Population, registered citizens and coverage by region.',
                'عدد السكان والمسجلين ونسبة التغطية حسب المنطقة.'),
            rows: 8),
      ],
    ),
    DbSpec(
      title: Bi('Procurement Contracts', 'عقود المشتريات'),
      description: Bi(
          'Active and completed contracts with supplier, value and dates, shared with Finance and Legal.',
          'العقود السارية والمكتملة مع المورد والقيمة والتواريخ، مشتركة مع المالية والشؤون القانونية.'),
      access: DbAccess.restricted,
      state: DbState.active,
      byMe: false,
      tables: <DbTableRef>[
        DbTableRef('contracts', Bi('Contracts', 'العقود'),
            Bi('One row per contract.', 'صف لكل عقد.'),
            rows: 16, shared: true),
        DbTableRef(
            'suppliers',
            Bi('Suppliers', 'الموردون'),
            Bi('Supplier performance and active contracts.',
                'أداء الموردين والعقود السارية.'),
            rows: 10),
      ],
    ),
    DbSpec(
      title: Bi('Data Quality Scorecards', 'بطاقات قياس جودة البيانات'),
      description: Bi(
          'Monthly quality results per dataset across completeness, accuracy, timeliness and consistency, with the open issues.',
          'نتائج الجودة الشهرية لكل مجموعة بيانات في الاكتمال والدقة والحداثة والاتساق، مع المشكلات المفتوحة.'),
      access: DbAccess.restricted,
      state: DbState.active,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef(
            'scorecards',
            Bi('Dataset Scorecards', 'بطاقات المجموعات'),
            Bi('Quality dimensions and the overall score for each dataset.',
                'أبعاد الجودة والدرجة الإجمالية لكل مجموعة بيانات.'),
            rows: 14,
            shared: true),
        DbTableRef(
            'dqissues',
            Bi('Quality Issues', 'مشكلات الجودة'),
            Bi('Issues found by the scorecard run with severity and owner.',
                'المشكلات المرصودة في تشغيل البطاقة مع الخطورة والمسؤول.'),
            rows: 16,
            shared: true),
      ],
    ),
    DbSpec(
      title: Bi('Incident and Risk Log', 'سجل الحوادث والمخاطر'),
      description: Bi(
          'Incidents reported by the departments, how long they took to close and the corrective actions agreed.',
          'الحوادث المبلّغ عنها من الإدارات ومدة إغلاقها والإجراءات التصحيحية المتفق عليها.'),
      access: DbAccess.restricted,
      state: DbState.active,
      byMe: false,
      tables: <DbTableRef>[
        DbTableRef('incidents', Bi('Incidents', 'الحوادث'),
            Bi('One row per reported incident.', 'صف لكل حادثة مبلّغ عنها.'),
            rows: 14, shared: true, restricted: true),
        DbTableRef(
            'actions',
            Bi('Corrective Actions', 'الإجراءات التصحيحية'),
            Bi('Actions agreed after each incident.',
                'الإجراءات المتفق عليها بعد كل حادثة.'),
            rows: 10),
      ],
    ),
    DbSpec(
      title:
          Bi('Budget and Expenditure Tracker', 'متابعة الميزانية والمصروفات'),
      description: Bi(
          'Budget lines with the amount allocated, spent and the utilisation rate, plus monthly planned against actual spend.',
          'بنود الميزانية بالمبلغ المخصص والمصروف ونسبة الاستخدام، مع الإنفاق الشهري المخطط والفعلي.'),
      access: DbAccess.restricted,
      state: DbState.active,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef(
            'budget',
            Bi('Budget Lines', 'بنود الميزانية'),
            Bi('Allocated and spent amounts by line.',
                'المبالغ المخصصة والمصروفة حسب البند.'),
            rows: 8),
        DbTableRef(
            'spend',
            Bi('Monthly Spend', 'الإنفاق الشهري'),
            Bi('Planned against actual spend each month.',
                'الإنفاق المخطط مقابل الفعلي كل شهر.'),
            rows: 10),
      ],
    ),
    DbSpec(
      title: Bi('Audit Findings Register', 'سجل ملاحظات التدقيق'),
      description: Bi(
          'Findings raised by internal and external audits, their owners, due dates and follow-up actions.',
          'ملاحظات التدقيق الداخلي والخارجي ومسؤولوها وتواريخ استحقاقها وإجراءات المتابعة.'),
      access: DbAccess.restricted,
      state: DbState.active,
      byMe: false,
      tables: <DbTableRef>[
        DbTableRef('findings', Bi('Findings', 'الملاحظات'),
            Bi('One row per audit finding.', 'صف لكل ملاحظة تدقيق.'),
            rows: 14, shared: true),
        DbTableRef('actions', Bi('Follow-up Actions', 'إجراءات المتابعة'),
            Bi('Actions to close the findings.', 'إجراءات إغلاق الملاحظات.'),
            rows: 10),
      ],
    ),

    // Personal (5)
    DbSpec(
      title: Bi('My Weekly Data Quality Notes',
          'ملاحظاتي الأسبوعية على جودة البيانات'),
      description: Bi(
          'Observations I collect during the weekly data quality review.',
          'ملاحظات أجمعها خلال مراجعة جودة البيانات الأسبوعية.'),
      access: DbAccess.personal,
      state: DbState.active,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef(
            'notes',
            Bi('Notes', 'الملاحظات'),
            Bi('Dated observations with the next step.',
                'ملاحظات مؤرخة مع الخطوة التالية.'),
            rows: 12),
      ],
    ),
    DbSpec(
      title: Bi('Meeting Action Tracker', 'متابعة إجراءات الاجتماعات'),
      description: Bi('Actions agreed in governance and steering meetings.',
          'الإجراءات المتفق عليها في اجتماعات الحوكمة واللجان التوجيهية.'),
      access: DbAccess.personal,
      state: DbState.active,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('actions', Bi('Actions', 'الإجراءات'),
            Bi('Open and completed actions.', 'الإجراءات المفتوحة والمنجزة.'),
            rows: 10),
      ],
    ),
    DbSpec(
      title: Bi('Reading List and References', 'قائمة القراءة والمراجع'),
      description: Bi('Standards, guides and articles to read, by priority.',
          'المعايير والأدلة والمقالات المطلوب قراءتها حسب الأولوية.'),
      access: DbAccess.personal,
      state: DbState.active,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef(
            'reading',
            Bi('Reading List', 'قائمة القراءة'),
            Bi('Titles with source, topic and priority.',
                'العناوين مع المصدر والموضوع والأولوية.'),
            rows: 10),
      ],
    ),
    DbSpec(
      title: Bi('Training Plan 2026', 'خطة التدريب 2026'),
      description: Bi(
          'Courses planned and completed this year with hours and cost.',
          'الدورات المخططة والمنجزة هذا العام مع الساعات والتكلفة.'),
      access: DbAccess.personal,
      state: DbState.active,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('training', Bi('Courses', 'الدورات'),
            Bi('Course plan.', 'خطة الدورات.'),
            rows: 8),
      ],
    ),
    DbSpec(
      title: Bi('Dashboard Ideas Backlog', 'قائمة أفكار لوحات المؤشرات'),
      description: Bi(
          'Ideas for new dashboards, with audience, effort and impact.',
          'أفكار لوحات مؤشرات جديدة مع الجمهور والجهد والأثر.'),
      access: DbAccess.personal,
      state: DbState.active,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('ideas', Bi('Ideas', 'الأفكار'),
            Bi('Backlog of dashboard ideas.', 'قائمة الأفكار المقترحة.'),
            rows: 8),
      ],
    ),

    // Drafts (5)
    DbSpec(
      title: Bi('Open Data Licence Mapping', 'مطابقة تراخيص البيانات المفتوحة'),
      description: Bi(
          'Mapping of each open dataset to the licence it will use.',
          'مطابقة كل مجموعة بيانات مفتوحة مع الترخيص الذي ستستخدمه.'),
      access: DbAccess.restricted,
      state: DbState.draft,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('licences', Bi('Licences', 'التراخيص'),
            Bi('Draft mapping.', 'مطابقة أولية.'),
            rows: 6),
      ],
    ),
    DbSpec(
      title: Bi(
          'Supplier Master Data Clean-up', 'تنقية البيانات الرئيسية للموردين'),
      description: Bi(
          'Duplicate and incomplete supplier records found in the last quality scan.',
          'سجلات الموردين المكررة وغير المكتملة في آخر فحص للجودة.'),
      access: DbAccess.restricted,
      state: DbState.draft,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('suppliers', Bi('Suppliers to clean', 'موردون للتنقية'),
            Bi('Records to merge or complete.', 'سجلات للدمج أو الاستكمال.'),
            rows: 7),
      ],
    ),
    DbSpec(
      title: Bi('Records Retention Matrix', 'مصفوفة الاحتفاظ بالسجلات'),
      description: Bi(
          'Retention period, legal basis and disposal method for each record series.',
          'مدة الاحتفاظ والسند النظامي وطريقة التصرف لكل سلسلة سجلات.'),
      access: DbAccess.restricted,
      state: DbState.draft,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('retention', Bi('Record Series', 'سلاسل السجلات'),
            Bi('Retention rules by series.', 'قواعد الاحتفاظ حسب السلسلة.'),
            rows: 6),
      ],
    ),
    DbSpec(
      title: Bi('Metadata Standards Inventory', 'جرد معايير البيانات الوصفية'),
      description: Bi(
          'Which metadata fields each dataset already has and what is missing.',
          'حقول البيانات الوصفية الموجودة لكل مجموعة بيانات والناقص منها.'),
      access: DbAccess.personal,
      state: DbState.draft,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('datasets', Bi('Datasets in scope', 'المجموعات المشمولة'),
            Bi('Initial list.', 'القائمة الأولية.'),
            rows: 5),
      ],
    ),
    DbSpec(
      title: Bi(
          'Data Sharing Agreements Tracker', 'متابعة اتفاقيات مشاركة البيانات'),
      description: Bi(
          'Agreements signed or in negotiation with other entities. Tables will be added after the legal review.',
          'الاتفاقيات الموقعة أو قيد التفاوض مع الجهات الأخرى. ستُضاف الجداول بعد المراجعة القانونية.'),
      access: DbAccess.restricted,
      state: DbState.draft,
      byMe: true,
      tables: <DbTableRef>[],
    ),

    // Deleted (5)
    DbSpec(
      title: Bi('2025 Survey Results', 'نتائج استبيان 2025'),
      description: Bi(
          'Citizen satisfaction survey of the previous year, archived.',
          'استبيان رضا المواطنين للعام الماضي، تمت أرشفته.'),
      access: DbAccess.restricted,
      state: DbState.deleted,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('survey', Bi('Responses', 'الردود'),
            Bi('Summary by statement.', 'ملخص حسب العبارة.'),
            rows: 8),
      ],
    ),
    DbSpec(
      title: Bi('Old Contact List', 'قائمة جهات الاتصال القديمة'),
      description: Bi('Owners and stewards before the reorganisation.',
          'المالكون والأمناء قبل إعادة التنظيم.'),
      access: DbAccess.open,
      state: DbState.deleted,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('owners', Bi('Contacts', 'جهات الاتصال'),
            Bi('Previous contact list.', 'قائمة جهات الاتصال السابقة.'),
            rows: 8),
      ],
    ),
    DbSpec(
      title: Bi('Pilot Dataset Inventory', 'جرد مجموعات البيانات التجريبية'),
      description: Bi('Inventory used in the pilot phase of the catalogue.',
          'الجرد المستخدم في المرحلة التجريبية للفهرس.'),
      access: DbAccess.restricted,
      state: DbState.deleted,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('datasets', Bi('Pilot datasets', 'المجموعات التجريبية'),
            Bi('Pilot list.', 'القائمة التجريبية.'),
            rows: 6),
      ],
    ),
    DbSpec(
      title: Bi('Migration Mapping v1', 'مطابقة الترحيل - النسخة الأولى'),
      description: Bi(
          'First field mapping for the records migration, replaced by version 2.',
          'المطابقة الأولى للحقول لترحيل السجلات، استُبدلت بالنسخة الثانية.'),
      access: DbAccess.personal,
      state: DbState.deleted,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('mapping', Bi('Field mapping', 'مطابقة الحقول'),
            Bi('Source to target fields.', 'من الحقول المصدر إلى الهدف.'),
            rows: 8),
      ],
    ),
    DbSpec(
      title: Bi('Legacy Reports Index', 'فهرس التقارير القديمة'),
      description: Bi(
          'Index of reports issued before the new publications register.',
          'فهرس التقارير الصادرة قبل سجل المنشورات الجديد.'),
      access: DbAccess.open,
      state: DbState.deleted,
      byMe: true,
      tables: <DbTableRef>[
        DbTableRef('publications', Bi('Reports', 'التقارير'),
            Bi('Old index.', 'الفهرس القديم.'),
            rows: 8),
      ],
    ),
  ];

  // ── Table comments (one language per run, picked in order) ────────────
  static const List<Bi> comments = <Bi>[
    Bi('Completeness of the address column dropped after the last import. Can we check the source file?',
        'انخفض اكتمال عمود العنوان بعد آخر استيراد. هل يمكننا فحص الملف المصدر؟'),
    Bi('The source file is correct. Two regions were loaded with a different spelling.',
        'الملف المصدر سليم. تم تحميل منطقتين بصيغة إملائية مختلفة.'),
    Bi('Thank you. I will add them to the reference list this week.',
        'شكراً لك. سأضيفهما إلى القائمة المرجعية هذا الأسبوع.'),
    Bi('Please review the highlighted rows before the committee meeting.',
        'يرجى مراجعة الصفوف المميزة قبل اجتماع اللجنة.'),
    Bi('Reviewed. Rows 8 and 11 need the owner confirmation.',
        'تمت المراجعة. الصفان 8 و11 يحتاجان إلى تأكيد المالك.'),
    Bi('I have asked the owner to confirm by Thursday.',
        'طلبت من المالك التأكيد قبل يوم الخميس.'),
    Bi('The quality score improved compared with last month.',
        'تحسنت درجة الجودة مقارنة بالشهر الماضي.'),
    Bi('Yes, mainly because the duplicate records were merged.',
        'نعم، بشكل رئيسي بسبب دمج السجلات المكررة.'),
    Bi('Can we add a column for the last review date?',
        'هل يمكننا إضافة عمود لتاريخ آخر مراجعة؟'),
    Bi('Added. Please fill it in for your datasets.',
        'تمت الإضافة. يرجى تعبئته لمجموعات بياناتكم.'),
    Bi('Exported a copy for the audit request. The file is in the shared folder.',
        'صدّرت نسخة لطلب التدقيق. الملف في المجلد المشترك.'),
    Bi('Received, thank you.', 'تم الاستلام، شكراً لك.'),
  ];
}
