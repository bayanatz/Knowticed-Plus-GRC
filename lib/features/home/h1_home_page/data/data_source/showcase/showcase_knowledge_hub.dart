// [module-file:knowledge_hub] — deleted when the knowledge_hub module is split out
/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_knowledge_hub.dart
/// Purpose: Showcase Knowledge Hub data: 59 documents across the year in
///          every status (published, expiring soon, approved and waiting for
///          its start date, pending approval, rejected, removed, archived),
///          the approval records, a 3–5 comment thread on every document and
///          view / download records for every month of the year (hub,
///          Submissions, Approvals and Dashboard charts).
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Same shape as `KnowledgeSeedService`: `CreateKnowledgeModel.toJson()` for
/// the documents (history lists + the flat `currentStatus` / `isPublic` /
/// `accessDepartments` fields), `ApprovalModel.toJson()` for the Approvals
/// collection, `DocumentUtilizationModel` for the usage records and the
/// shared comment fields (`knowledgeId` + `Request_Id`) for the threads. The
/// sample files are the ones the debug seed button already uploads to
/// `knowledge_documents/seed_samples/`.
///
/// Who sees what: the Submissions tab lists the documents the signed-in user
/// authored (32); the Approvals queue lists the documents authored by the
/// user's DIRECT REPORTS (27, found through the employees' supervisor). With
/// no direct report the 27 are written under other colleagues and the queue
/// stays empty. No calendar events or notifications are written by this
/// seed, so the `documentName` placeholder warning does not apply here.
library;

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/approval_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/utils/knowledge_departments_codec.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

/// One document of the library.
class _Topic {
  const _Topic(this.title, this.desc, this.type, this.ext);

  final Bi title;
  final Bi desc;

  /// A key of the create screen's document-type list.
  final String type;
  final String ext;
}

/// Where a document is in its life.
enum _Kind { published, archived, removed, approved, pending, rejected }

class _Item {
  const _Item(this.topic, this.kind, this.order,
      {required this.mine, this.expiring = false});

  /// Index in [ShowcaseKnowledgeHub._topics].
  final int topic;
  final _Kind kind;

  /// Position among the documents of the same kind.
  final int order;

  /// Authored by the signed-in user (else by one of the direct reports).
  final bool mine;

  /// Published and ending within the next two weeks.
  final bool expiring;
}

class _SampleFile {
  const _SampleFile(this.url, this.size);

  final String url;
  final int size;
}

/// Writes in WriteBatch chunks of at most 400 operations.
class _Writer {
  _Writer(this._db) : _batch = _db.batch();

  final FirebaseFirestore _db;
  WriteBatch _batch;
  int _inBatch = 0;
  int total = 0;

  Future<WriteBatch> reserve(int ops) async {
    if (_inBatch + ops > 400) {
      await _batch.commit();
      _batch = _db.batch();
      _inBatch = 0;
    }
    _inBatch += ops;
    total += ops;
    return _batch;
  }

  Future<void> set(DocumentReference<Map<String, dynamic>> ref,
      Map<String, dynamic> data) async {
    (await reserve(1)).set(ref, data);
  }

  Future<void> finish() async {
    if (_inBatch > 0) {
      await _batch.commit();
      _batch = _db.batch();
      _inBatch = 0;
    }
  }
}

abstract final class ShowcaseKnowledgeHub {
  // ── Plan ──────────────────────────────────────────────────────────────────

  /// The 30 documents that went live, in publishing order: A = archived,
  /// P = published, R = removed.
  static const String _liveKinds = 'APRAPRAPRAPRAPRAPRAPRAPR' 'PRPRPP';

  /// Authored by the signed-in user (m) or a direct report (r), per live slot.
  static const String _liveMine = 'mmmmrrrmmmmrmrmrmrmmmrrrmmrrmr';

  /// The published slots that end within two weeks.
  static const Set<int> _expiringSlots = <int>{7, 10, 13, 16, 19, 22, 24};

  static const String _approvedMine = '10110101';
  static const String _pendingMine = '10100101001';
  static const String _rejectedMine = '1010101010';

  // ── Library (the order = live slots 0–29, approved 8, pending 11,
  //    rejected 10) ──────────────────────────────────────────────────────────

  static const List<_Topic> _topics = <_Topic>[
    // Live slots 0–29.
    _Topic(
        Bi('Annual Data Strategy Review 2025',
            'مراجعة استراتيجية البيانات السنوية 2025'),
        Bi('Results against the 2025 data strategy targets.',
            'النتائج مقابل مستهدفات استراتيجية البيانات لعام 2025.'),
        'Report',
        'pdf'),
    _Topic(
        Bi('Data Governance Policy 2026', 'سياسة حوكمة البيانات 2026'),
        Bi('Defines roles, decision rights and escalation paths for managing organisational data.',
            'تحدد الأدوار وصلاحيات القرار ومسارات التصعيد لإدارة بيانات المؤسسة.'),
        'Policy',
        'pdf'),
    _Topic(
        Bi('Press Release Approval Workflow', 'مسار اعتماد البيانات الصحفية'),
        Bi('Who reviews, approves and publishes official statements.',
            'من يراجع البيانات الرسمية ويعتمدها وينشرها.'),
        'Policy',
        'pdf'),
    _Topic(
        Bi('Quarterly Data Quality Scorecard Q2',
            'بطاقة أداء جودة البيانات للربع الثاني'),
        Bi('Completeness, accuracy and timeliness scores by department.',
            'درجات الاكتمال والدقة والحداثة حسب الإدارة.'),
        'Report',
        'xlsx'),
    _Topic(
        Bi('Records Retention Schedule', 'جدول الاحتفاظ بالسجلات'),
        Bi('Retention periods and disposal rules for every record category.',
            'فترات الاحتفاظ وقواعد الإتلاف لكل فئة من فئات السجلات.'),
        'Policy',
        'pdf'),
    _Topic(
        Bi('Email Retention Guideline', 'إرشادات الاحتفاظ بالبريد الإلكتروني'),
        Bi('How long business email is kept and when it is deleted.',
            'مدة الاحتفاظ بالبريد الرسمي ومتى يحذف.'),
        'Guidelines',
        'pdf'),
    _Topic(
        Bi('Business Continuity Drill Report', 'تقرير تمرين استمرارية الأعمال'),
        Bi('Recovery times and lessons learned from the September drill.',
            'أزمنة الاستعادة والدروس المستفادة من تمرين سبتمبر.'),
        'Report',
        'pdf'),
    _Topic(
        Bi('Metadata Standards for Media Assets',
            'معايير البيانات الوصفية للأصول الإعلامية'),
        Bi('Mandatory metadata fields for photos, video, audio and press releases.',
            'الحقول الوصفية الإلزامية للصور والفيديو والمواد الصوتية والبيانات الصحفية.'),
        'Guidelines',
        'docx'),
    _Topic(
        Bi('Document Naming Convention', 'اتفاقية تسمية المستندات'),
        Bi('Naming pattern for files, versions and folders.',
            'نمط تسمية الملفات والإصدارات والمجلدات.'),
        'Guidelines',
        'pdf'),
    _Topic(
        Bi('Supplier Data Cleansing Report', 'تقرير تنقية بيانات الموردين'),
        Bi('Results of merging 214 duplicate supplier records.',
            'نتائج دمج 214 سجلا مكررا للموردين.'),
        'Report',
        'xlsx'),
    _Topic(
        Bi('Data Quality Playbook', 'دليل جودة البيانات'),
        Bi('Step-by-step method to profile, score and remediate data quality issues.',
            'منهجية تفصيلية لتحليل مشكلات جودة البيانات وقياسها ومعالجتها.'),
        'Guidelines',
        'docx'),
    _Topic(
        Bi('Data Steward Onboarding Kit', 'حزمة تهيئة أمناء البيانات'),
        Bi('Orientation material for new data stewards.',
            'مواد تعريفية لأمناء البيانات الجدد.'),
        'Presentation',
        'pptx'),
    _Topic(
        Bi('Workshop Recording: Data Governance Basics',
            'تسجيل ورشة: أساسيات حوكمة البيانات'),
        Bi('Recording of the introductory session for all departments.',
            'تسجيل الجلسة التعريفية لجميع الإدارات.'),
        'Recording',
        'mp3'),
    _Topic(
        Bi('Media Asset Management Guidelines',
            'إرشادات إدارة الأصول الإعلامية'),
        Bi('How to name, tag, store and retire editorial photos and video.',
            'كيفية تسمية الصور والفيديو التحريري ووسمه وتخزينه وسحبه من التداول.'),
        'Guidelines',
        'pdf'),
    _Topic(
        Bi('Photo Library Migration Plan', 'خطة ترحيل مكتبة الصور'),
        Bi('Moving 1.2 million photos to the new media platform.',
            'نقل 1.2 مليون صورة إلى منصة الوسائط الجديدة.'),
        'Presentation',
        'pptx'),
    _Topic(
        Bi('Annual Records Disposal Authorisation',
            'تفويض الإتلاف السنوي للسجلات'),
        Bi('Approval to destroy records that reached the end of retention.',
            'الموافقة على إتلاف السجلات التي انتهت مدة الاحتفاظ بها.'),
        'Letter',
        'docx'),
    _Topic(
        Bi('NDMO Compliance Self-Assessment 2026',
            'التقييم الذاتي للامتثال لمكتب إدارة البيانات الوطني 2026'),
        Bi('Control-by-control results of the annual national data management assessment.',
            'نتائج ضوابط التقييم الوطني السنوي لإدارة البيانات ضابطا بضابط.'),
        'Report',
        'xlsx'),
    _Topic(
        Bi('Data Sharing Agreement Template', 'نموذج اتفاقية مشاركة البيانات'),
        Bi('Standard clauses for sharing data with government entities.',
            'بنود قياسية لمشاركة البيانات مع الجهات الحكومية.'),
        'Form',
        'docx'),
    _Topic(
        Bi('Data Protection Officer Report 2026',
            'تقرير مسؤول حماية البيانات 2026'),
        Bi('Half-year report on requests, breaches and awareness.',
            'تقرير نصف سنوي عن الطلبات والاختراقات والتوعية.'),
        'Report',
        'pdf'),
    _Topic(
        Bi('Data Classification Framework', 'إطار تصنيف البيانات'),
        Bi('Four classification levels with handling rules for each level.',
            'أربعة مستويات للتصنيف مع قواعد التعامل لكل مستوى.'),
        'Frame Work',
        'pdf'),
    _Topic(
        Bi('Service Catalogue Data Dictionary', 'قاموس بيانات دليل الخدمات'),
        Bi('Field definitions for the service catalogue.',
            'تعريفات الحقول لدليل الخدمات.'),
        'Report',
        'xlsx'),
    _Topic(
        Bi('Risk Treatment Plans Q2', 'خطط معالجة المخاطر للربع الثاني'),
        Bi('Updated plans for the high risks on the register.',
            'الخطط المحدثة للمخاطر العالية في السجل.'),
        'Report',
        'xlsx'),
    _Topic(
        Bi('Personal Data Protection Procedure',
            'إجراء حماية البيانات الشخصية'),
        Bi('Handling of consent, access requests and breach notification.',
            'التعامل مع الموافقات وطلبات الاطلاع والإبلاغ عن الاختراقات.'),
        'Policy',
        'pdf'),
    _Topic(
        Bi('Interview Recording Handling Procedure',
            'إجراء التعامل مع تسجيلات المقابلات'),
        Bi('Storage, consent and retention for recorded interviews.',
            'التخزين والموافقة والاحتفاظ بالمقابلات المسجلة.'),
        'Policy',
        'pdf'),
    _Topic(
        Bi('Data Incident Response Procedure',
            'إجراء الاستجابة لحوادث البيانات'),
        Bi('Roles, timelines and communication steps during a data incident.',
            'الأدوار والمدد الزمنية وخطوات التواصل أثناء حادثة بيانات.'),
        'Policy',
        'pdf'),
    _Topic(
        Bi('Content Takedown Procedure', 'إجراء إزالة المحتوى'),
        Bi('Steps for removing published content after a legal or editorial request.',
            'خطوات إزالة المحتوى المنشور بعد طلب قانوني أو تحريري.'),
        'Policy',
        'pdf'),
    _Topic(
        Bi('Access Control Matrix 2026', 'مصفوفة صلاحيات الوصول 2026'),
        Bi('Role-based access rights for core systems, reviewed twice a year.',
            'صلاحيات الوصول حسب الدور للأنظمة الأساسية وتراجع مرتين سنويا.'),
        'Report',
        'xlsx'),
    _Topic(
        Bi('Broadcast Archive Digitisation Plan', 'خطة رقمنة أرشيف البث'),
        Bi('Phased plan to digitise 40,000 hours of broadcast tapes.',
            'خطة مرحلية لرقمنة 40 ألف ساعة من أشرطة البث.'),
        'Report',
        'pdf'),
    _Topic(
        Bi('Business Glossary v2.0', 'القاموس المؤسسي للمصطلحات الإصدار 2.0'),
        Bi('Approved definitions of 320 business terms with owners and stewards.',
            'التعريفات المعتمدة لـ 320 مصطلحا مؤسسيا مع المالكين والأمناء.'),
        'Booklet',
        'pdf'),
    _Topic(
        Bi('Data Governance Maturity Assessment', 'تقييم نضج حوكمة البيانات'),
        Bi('Maturity scores across the 14 data management domains.',
            'درجات النضج في مجالات إدارة البيانات الأربعة عشر.'),
        'Report',
        'xlsx'),
    // Approved, waiting for the start date (8).
    _Topic(
        Bi('Master Data Management Strategy',
            'استراتيجية إدارة البيانات الرئيسية'),
        Bi('Target operating model for customer, supplier and employee master data.',
            'نموذج التشغيل المستهدف لبيانات العملاء والموردين والموظفين الرئيسية.'),
        'Presentation',
        'pptx'),
    _Topic(
        Bi('Data Lineage Mapping Guide', 'دليل رسم مسار البيانات'),
        Bi('Documenting the journey of critical data from source to report.',
            'توثيق رحلة البيانات الحرجة من المصدر إلى التقرير.'),
        'Guidelines',
        'docx'),
    _Topic(
        Bi('Critical Data Elements Register', 'سجل عناصر البيانات الحرجة'),
        Bi('Register of 148 critical data elements with owners and quality rules.',
            'سجل يضم 148 عنصر بيانات حرج مع المالكين وقواعد الجودة.'),
        'Report',
        'xlsx'),
    _Topic(
        Bi('Cloud Data Residency Guidelines',
            'إرشادات إقامة البيانات في السحابة'),
        Bi('Rules for storing government data in cloud services.',
            'قواعد تخزين البيانات الحكومية في الخدمات السحابية.'),
        'Guidelines',
        'pdf'),
    _Topic(
        Bi('Data Literacy Programme Outline', 'مخطط برنامج الثقافة البيانية'),
        Bi('Courses and learning paths for different staff groups.',
            'الدورات والمسارات التعليمية لفئات الموظفين المختلفة.'),
        'Presentation',
        'pptx'),
    _Topic(
        Bi('Media Rights Register 2026', 'سجل الحقوق الإعلامية 2026'),
        Bi('Rights holders, licences and expiry dates for third-party content.',
            'أصحاب الحقوق والتراخيص وتواريخ انتهاء محتوى الأطراف الخارجية.'),
        'Report',
        'xlsx'),
    _Topic(
        Bi('Digital Signature Usage Policy', 'سياسة استخدام التوقيع الرقمي'),
        Bi('When and how electronic signatures may replace wet signatures.',
            'متى وكيف يمكن للتوقيع الإلكتروني أن يحل محل التوقيع الخطي.'),
        'Policy',
        'pdf'),
    _Topic(
        Bi('Master Supplier Data Standard', 'معيار بيانات الموردين الرئيسية'),
        Bi('Mandatory fields and validation for supplier records.',
            'الحقول الإلزامية والتحقق لسجلات الموردين.'),
        'Frame Work',
        'pdf'),
    // Pending approval (11).
    _Topic(
        Bi('Data Catalogue User Guide', 'دليل مستخدم فهرس البيانات'),
        Bi('How to search, request and document datasets in the catalogue.',
            'كيفية البحث عن مجموعات البيانات وطلبها وتوثيقها في الفهرس.'),
        'Guidelines',
        'docx'),
    _Topic(
        Bi('Image Metadata Quality Checklist',
            'قائمة فحص جودة بيانات الصور الوصفية'),
        Bi('Checklist used before photos enter the media library.',
            'قائمة فحص تستخدم قبل إدخال الصور إلى مكتبة الوسائط.'),
        'Form',
        'docx'),
    _Topic(
        Bi('Data Quality Rules Library', 'مكتبة قواعد جودة البيانات'),
        Bi('Reusable validation rules grouped by data domain.',
            'قواعد تحقق قابلة لإعادة الاستخدام مصنفة حسب مجال البيانات.'),
        'Report',
        'xlsx'),
    _Topic(
        Bi('Sensitive Data Masking Standard', 'معيار إخفاء البيانات الحساسة'),
        Bi('Masking and anonymisation techniques for test and analytics data.',
            'أساليب الإخفاء وإخفاء الهوية لبيانات الاختبار والتحليلات.'),
        'Frame Work',
        'pdf'),
    _Topic(
        Bi('Knowledge Hub Contributor Guide', 'دليل المساهمين في مركز المعرفة'),
        Bi('How to submit, update and withdraw documents.',
            'كيفية تقديم المستندات وتحديثها وسحبها.'),
        'Guidelines',
        'docx'),
    _Topic(
        Bi('Document Control Procedure', 'إجراء ضبط الوثائق'),
        Bi('Version, review and approval control for controlled documents.',
            'ضبط الإصدارات والمراجعة والاعتماد للوثائق الخاضعة للرقابة.'),
        'Policy',
        'pdf'),
    _Topic(
        Bi('Reference Data Management Standard',
            'معيار إدارة البيانات المرجعية'),
        Bi('Ownership and change control of code lists used across systems.',
            'الملكية وضبط التغيير لقوائم الرموز المستخدمة عبر الأنظمة.'),
        'Guidelines',
        'pdf'),
    _Topic(
        Bi('Editorial Photo Licensing Guide', 'دليل ترخيص الصور التحريرية'),
        Bi('Usage rights, credits and expiry rules for agency and staff photos.',
            'حقوق الاستخدام وقواعد الإسناد والانتهاء لصور الوكالات وصور المصورين.'),
        'Guidelines',
        'pdf'),
    _Topic(
        Bi('Data Privacy Impact Assessment Template',
            'نموذج تقييم أثر الخصوصية'),
        Bi('Questionnaire for new projects that process personal data.',
            'استبيان للمشاريع الجديدة التي تعالج بيانات شخصية.'),
        'Form',
        'docx'),
    _Topic(
        Bi('Information Security Awareness Booklet',
            'كتيب التوعية بأمن المعلومات'),
        Bi('Practical rules for staff on passwords, email and devices.',
            'قواعد عملية للموظفين حول كلمات المرور والبريد والأجهزة.'),
        'Booklet',
        'pdf'),
    _Topic(
        Bi('Open Data Publication Standard', 'معيار نشر البيانات المفتوحة'),
        Bi('Criteria for releasing datasets on the national open data portal.',
            'معايير إتاحة مجموعات البيانات في بوابة البيانات المفتوحة الوطنية.'),
        'Frame Work',
        'pdf'),
    // Rejected (10).
    _Topic(
        Bi('Data Owner Mandate Letter', 'خطاب تكليف مالكي البيانات'),
        Bi('Formal appointment of data owners for each business domain.',
            'التكليف الرسمي لمالكي البيانات في كل مجال عمل.'),
        'Letter',
        'docx'),
    _Topic(
        Bi('Data Governance Council Charter', 'ميثاق مجلس حوكمة البيانات'),
        Bi('Mandate, membership and meeting rules of the council.',
            'تفويض المجلس وعضويته وقواعد اجتماعاته.'),
        'Mandate',
        'pdf'),
    _Topic(
        Bi('Video Production Metadata Template',
            'نموذج البيانات الوصفية لإنتاج الفيديو'),
        Bi('Template for describing shots, rights and subjects in video projects.',
            'نموذج لوصف اللقطات والحقوق والموضوعات في مشاريع الفيديو.'),
        'Form',
        'csv'),
    _Topic(
        Bi('Training Video: Classifying Documents',
            'فيديو تدريبي: تصنيف المستندات'),
        Bi('Ten-minute walkthrough of the classification labels.',
            'شرح مدته عشر دقائق لعلامات التصنيف.'),
        'Video',
        'mp4'),
    _Topic(
        Bi('Internal Audit Observations Response',
            'الرد على ملاحظات التدقيق الداخلي'),
        Bi('Management responses and action dates for the audit observations.',
            'ردود الإدارة وتواريخ الإجراءات لملاحظات التدقيق.'),
        'Letter',
        'docx'),
    _Topic(
        Bi('Statistics Authority Data Exchange Protocol',
            'بروتوكول تبادل البيانات مع هيئة الإحصاء'),
        Bi('Technical and legal terms for the periodic data exchange.',
            'الشروط الفنية والقانونية للتبادل الدوري للبيانات.'),
        'Mandate',
        'pdf'),
    _Topic(
        Bi('Digital Transformation Standard Evidence Pack',
            'حزمة أدلة معيار التحول الرقمي'),
        Bi('Evidence for the controls of the digital transformation measurement.',
            'أدلة ضوابط قياس التحول الرقمي.'),
        'Report',
        'pdf'),
    _Topic(
        Bi('Archive Box Transfer Procedure', 'إجراء نقل صناديق الأرشيف'),
        Bi('Steps for transferring physical records to the central archive.',
            'خطوات نقل السجلات الورقية إلى الأرشيف المركزي.'),
        'Form',
        'docx'),
    _Topic(
        Bi('Archive Access Request Form', 'نموذج طلب الاطلاع على الأرشيف'),
        Bi('Request to view or borrow archived records.',
            'طلب الاطلاع على السجلات المؤرشفة أو استعارتها.'),
        'Form',
        'docx'),
    _Topic(
        Bi('Newsroom Style Guide 2026', 'دليل الأسلوب التحريري 2026'),
        Bi('Language, tone and fact-checking rules for published content.',
            'قواعد اللغة والأسلوب والتحقق من الحقائق للمحتوى المنشور.'),
        'Booklet',
        'pdf'),
  ];

  static const List<Bi> _rejectReasons = <Bi>[
    Bi('The retention periods do not match the approved schedule. Please align them and resubmit.',
        'فترات الاحتفاظ لا تتوافق مع الجدول المعتمد، يرجى مواءمتها وإعادة التقديم.'),
    Bi('The legal review note is missing. Attach it and resubmit.',
        'مذكرة المراجعة القانونية غير مرفقة، يرجى إرفاقها وإعادة التقديم.'),
    Bi('The document has no owner or review date on the first page.',
        'لا يتضمن المستند اسم المالك أو تاريخ المراجعة في الصفحة الأولى.'),
    Bi('Section 4 contradicts the data classification policy. Please revise it.',
        'القسم الرابع يتعارض مع سياسة تصنيف البيانات، يرجى تعديله.'),
    Bi('The file is an unapproved draft. Submit the signed version.',
        'الملف مسودة غير معتمدة، يرجى تقديم النسخة الموقعة.'),
    Bi('Duplicate of a document already published on the Knowledge Hub.',
        'نسخة مكررة من مستند منشور بالفعل في مركز المعرفة.'),
  ];

  static const List<Bi> _removeReasons = <Bi>[
    Bi('Superseded by a newer version.', 'حل محله إصدار أحدث.'),
    Bi('Withdrawn by the owner after a policy change.',
        'سحبه المالك بعد تغيير في السياسة.'),
    Bi('Merged into the consolidated procedure.', 'دمج في الإجراء الموحد.'),
    Bi('Contains outdated figures and is being rewritten.',
        'يحتوي على أرقام قديمة وتجري إعادة كتابته.'),
    Bi('Replaced by the new departmental guideline.',
        'استبدل بالإرشاد الجديد للإدارة.'),
  ];

  static const List<Bi> _justifications = <Bi>[
    Bi('Content reviewed and consistent with the approved governance policy.',
        'تمت مراجعة المحتوى وهو متسق مع سياسة الحوكمة المعتمدة.'),
    Bi('Approved after review with Legal and Compliance.',
        'معتمد بعد المراجعة مع الشؤون القانونية والامتثال.'),
    Bi('Accurate and complete. Approved for publication.',
        'دقيق ومكتمل، ومعتمد للنشر.'),
    Bi('Approved for the stated validity period.',
        'معتمد لفترة الصلاحية المذكورة.'),
    Bi('Meets the metadata and naming standards.',
        'يستوفي معايير البيانات الوصفية والتسمية.'),
  ];

  /// Comment threads per kind; the first line is the reviewer's / reader's,
  /// the next is the author's, and so on.
  static const Map<_Kind, List<List<Bi>>> _threads = <_Kind, List<List<Bi>>>{
    _Kind.published: <List<Bi>>[
      <Bi>[
        Bi('Thank you for publishing this. Does it replace the previous edition?',
            'شكرا على النشر. هل تحل هذه النسخة محل النسخة السابقة؟'),
        Bi('Yes. The previous edition is archived and this one is the only valid reference.',
            'نعم، النسخة السابقة مؤرشفة وهذه هي المرجع الوحيد المعتمد.'),
        Bi('Noted. I will update the links in the induction pack.',
            'علم، سأحدث الروابط في حزمة التهيئة.'),
        Bi('Thanks. Please send me any feedback before the next review.',
            'شكرا لك، يرجى إرسال أي ملاحظات قبل المراجعة القادمة.'),
        Bi('Will do. The department heads are asked to comment by the end of the quarter.',
            'سيتم ذلك، ورؤساء الإدارات مطالبون بالتعليق قبل نهاية الربع.'),
      ],
      <Bi>[
        Bi('Good to see this live. Which departments are covered by the scope?',
            'جميل أن أراه منشورا. ما الإدارات التي يشملها النطاق؟'),
        Bi('All departments. Section 2 lists the exceptions for the media production teams.',
            'جميع الإدارات، ويبين القسم الثاني الاستثناءات الخاصة بفرق الإنتاج الإعلامي.'),
        Bi('Understood. I will brief my team in the next staff meeting.',
            'مفهوم، وسأعرض الموضوع على فريقي في الاجتماع القادم.'),
        Bi('Please do. A short summary slide is attached to the document for that purpose.',
            'يرجى ذلك، وقد أرفقت شريحة ملخصة بالمستند لهذا الغرض.'),
        Bi('Received, thank you. I will share any questions that come up.',
            'تم الاستلام، شكرا لك. وسأشاركك الأسئلة التي تظهر.'),
      ],
    ],
    _Kind.archived: <List<Bi>>[
      <Bi>[
        Bi('Is this version still valid? The validity period ends soon.',
            'هل ما زالت هذه النسخة سارية؟ فترة الصلاحية تنتهي قريبا.'),
        Bi('Yes, until the end date. I will request a renewal if the content is unchanged.',
            'نعم، حتى تاريخ الانتهاء، وسأطلب التجديد إذا لم يتغير المحتوى.'),
        Bi('Please renew before expiry so readers do not lose access.',
            'يرجى التجديد قبل الانتهاء حتى لا يفقد القراء الوصول.'),
        Bi('Understood. If it expires, please keep it in the archive for audit reference.',
            'مفهوم، وإذا انتهت الصلاحية يرجى إبقاؤه في الأرشيف للرجوع إليه عند التدقيق.'),
        Bi('Agreed. Archived documents stay searchable for reviewers.',
            'اتفقنا، فالمستندات المؤرشفة تبقى قابلة للبحث للمراجعين.'),
      ],
      <Bi>[
        Bi('Which edition does this document belong to?',
            'إلى أي إصدار ينتمي هذا المستند؟'),
        Bi('It belongs to the previous reporting cycle, and a new edition will follow.',
            'ينتمي إلى دورة التقارير السابقة، وسيتبعه إصدار جديد.'),
        Bi('Thanks. Please link the new edition here once it is ready.',
            'شكرا، يرجى ربط الإصدار الجديد هنا عند جاهزيته.'),
        Bi('Will do. The new edition is planned for the next quarter.',
            'سيتم ذلك، والإصدار الجديد مخطط للربع القادم.'),
        Bi('Noted for the audit calendar.', 'تم تسجيل ذلك في جدول التدقيق.'),
      ],
    ],
    _Kind.removed: <List<Bi>>[
      <Bi>[
        Bi('This overlaps with the newer procedure. Can we merge the two?',
            'يتداخل هذا مع الإجراء الأحدث. هل يمكن دمج الاثنين؟'),
        Bi('Yes. I will withdraw this one and point readers to the new document.',
            'نعم، سأسحب هذا المستند وأحيل القراء إلى المستند الجديد.'),
        Bi('Agreed. Please add the reason when you withdraw it.',
            'اتفقنا، يرجى إضافة السبب عند السحب.'),
        Bi('Done. The reason is recorded and the owners are informed.',
            'تم، وسجل السبب وأبلغ المالكون.'),
        Bi('Thank you. I will update the index page accordingly.',
            'شكرا لك، وسأحدث صفحة الفهرس وفقا لذلك.'),
      ],
      <Bi>[
        Bi('Some figures here are outdated. Are you planning a new version?',
            'بعض الأرقام هنا قديمة. هل تخططون لإصدار جديد؟'),
        Bi('Yes, it is being rewritten. I prefer to withdraw it until then.',
            'نعم، تجري إعادة كتابته، وأفضل سحبه إلى ذلك الحين.'),
        Bi('Good decision. Please notify the teams that used it.',
            'قرار جيد، يرجى إبلاغ الفرق التي استخدمته.'),
        Bi('I have sent them a note with the expected date of the new version.',
            'أرسلت إليهم مذكرة بالموعد المتوقع للإصدار الجديد.'),
        Bi('Appreciated.', 'شكرا لك.'),
      ],
    ],
    _Kind.approved: <List<Bi>>[
      <Bi>[
        Bi('Approved. It goes live on the start date, so please inform the department heads.',
            'تمت الموافقة، وسينشر في تاريخ البدء، يرجى إبلاغ رؤساء الإدارات.'),
        Bi('Thank you. A circular is prepared for that day.',
            'شكرا لك، والتعميم جاهز لذلك اليوم.'),
        Bi('Please also update the intranet banner.',
            'يرجى أيضا تحديث لافتة الشبكة الداخلية.'),
        Bi('Already scheduled with the communications team.',
            'تمت جدولته مع فريق الاتصال.'),
        Bi('Perfect. Let me know if the date changes.',
            'ممتاز، أخبرني إذا تغير الموعد.'),
      ],
      <Bi>[
        Bi('Approved for the stated period. Please confirm the owner who will maintain it.',
            'معتمد للفترة المذكورة. يرجى تأكيد المالك المسؤول عن صيانته.'),
        Bi('The owner is the head of the department and the steward is listed on page 2.',
            'المالك هو رئيس الإدارة والأمين مذكور في الصفحة الثانية.'),
        Bi('Thanks. I will add both names to the register.',
            'شكرا، سأضيف الاسمين إلى السجل.'),
        Bi('Please keep the review date in the calendar.',
            'يرجى إبقاء تاريخ المراجعة في التقويم.'),
        Bi('Done.', 'تم.'),
      ],
    ],
    _Kind.pending: <List<Bi>>[
      <Bi>[
        Bi('Please attach the legal review note before this can be approved.',
            'يرجى إرفاق مذكرة المراجعة القانونية قبل أن يتسنى اعتماده.'),
        Bi('Attached. I also updated section 4 as discussed.',
            'تم الإرفاق، وحدثت القسم الرابع كما اتفقنا.'),
        Bi('Thank you. I will complete the review this week.',
            'شكرا لك، وسأنهي المراجعة هذا الأسبوع.'),
        Bi('Much appreciated. The department is waiting to use it.',
            'أقدر ذلك كثيرا، فالإدارة بانتظار استخدامه.'),
        Bi('Understood. You will get the decision by Thursday.',
            'مفهوم، وستصلك النتيجة يوم الخميس.'),
      ],
      <Bi>[
        Bi('Is the owner mentioned on the first page the final approver?',
            'هل المالك المذكور في الصفحة الأولى هو المعتمد النهائي؟'),
        Bi('Yes, and his sign-off is already on the last page.',
            'نعم، وتوقيعه موجود في الصفحة الأخيرة.'),
        Bi('Good. I noticed the glossary links are broken. Please fix them.',
            'جيد، لاحظت أن روابط القاموس لا تعمل، يرجى إصلاحها.'),
        Bi('Fixed and uploaded again.', 'تم الإصلاح وأعيد الرفع.'),
        Bi('Thanks. I will review it in the morning.',
            'شكرا لك، وسأراجعه صباحا.'),
      ],
    ],
    _Kind.rejected: <List<Bi>>[
      <Bi>[
        Bi('I am returning this one. The content needs to follow the approved schedule.',
            'أعيد هذا المستند، فالمحتوى يجب أن يتبع الجدول المعتمد.'),
        Bi('Understood. I will align it and resubmit.',
            'مفهوم، سأواءمه وأعيد التقديم.'),
        Bi('Please add the owner and the review date on the first page as well.',
            'يرجى أيضا إضافة المالك وتاريخ المراجعة في الصفحة الأولى.'),
        Bi('Done in the new draft. I will resubmit shortly.',
            'تم ذلك في المسودة الجديدة، وسأعيد التقديم قريبا.'),
        Bi('Thank you. It will be reviewed again on submission.',
            'شكرا لك، وستتم مراجعته مجددا عند التقديم.'),
      ],
      <Bi>[
        Bi('The attachment is a draft. We need the signed version.',
            'المرفق مسودة، ونحتاج إلى النسخة الموقعة.'),
        Bi('Sorry about that. The signed copy is with the director and I will upload it tomorrow.',
            'أعتذر عن ذلك، فالنسخة الموقعة لدى المدير وسأرفعها غدا.'),
        Bi('No problem. Please mention the signing date in the description.',
            'لا مشكلة، يرجى ذكر تاريخ التوقيع في الوصف.'),
        Bi('Noted.', 'علم.'),
        Bi('Thank you for the quick response.', 'شكرا على الاستجابة السريعة.'),
      ],
    ],
  };

  static const List<String> _fallbackDepartments = <String>[
    'Data Governance',
    'Information Technology',
    'Media Production',
    'Legal Affairs',
    'Risk and Compliance',
    'Human Resources',
  ];

  // ── Seed ──────────────────────────────────────────────────────────────────

  /// Function Name: [seed]
  ///
  /// Purpose: Writes the showcase Knowledge Hub documents, approvals,
  /// comments and usage records; returns how many documents were written.
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required bool isArabic,
    required DateTime now,
  }) async {
    final CollectionReference<Map<String, dynamic>> knowledge =
        firestore.collection(getBaseUrl(FirebaseCollections.createKnowledge));
    final CollectionReference<Map<String, dynamic>> approvals = firestore
        .collection(getBaseUrl(FirebaseCollections.knowledgeApprovals));
    final CollectionReference<Map<String, dynamic>> usage =
        firestore.collection(
            getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization));
    final String commentsPath =
        getBaseUrl(FirebaseCollections.knowledgeComments);

    final Map<String, _SampleFile> files = await _sampleFiles();
    final List<String> departments = _departments();
    final List<ShowcasePerson> authors = _otherAuthors(me);
    final List<ShowcasePerson> people = ShowcaseCommon.people;
    final _Writer w = _Writer(firestore);
    final List<_Item> items = _plan();
    int usageNumber = 0;
    int liveNumber = 0;

    for (int n = 0; n < items.length; n++) {
      final _Item item = items[n];
      final _Topic topic = _topics[item.topic];
      final String id = ShowcaseCommon.id('kh', n + 1);
      final ShowcasePerson author =
          item.mine ? me : authors[n % authors.length];
      final String department = departments[item.topic % departments.length];
      final _SampleFile file = files[topic.ext] ?? const _SampleFile('', 0);

      // ── Timeline ──
      final List<String> statuses = <String>[];
      final List<DateTime> times = <DateTime>[];
      final List<String> reasons = <String>[];
      DateTime start = now;
      DateTime end = now;
      DateTime threadStart = now;
      DateTime? liveFrom;
      DateTime? liveTo;
      String? approvalStatus;
      String approvalReason = '';
      String approvalJustification = '';
      final bool viaApproval = item.order % 3 != 0;

      void add(String status, DateTime at, [String reason = '']) {
        statuses.add(status);
        times.add(at);
        reasons.add(reason);
      }

      switch (item.kind) {
        case _Kind.published:
          final DateTime pub = _publishAt(item.topic, now);
          if (viaApproval) {
            add('pending_approval', pub.subtract(const Duration(days: 2)));
            approvalStatus = 'approved';
          }
          add('published', pub);
          start = DateTime(pub.year, pub.month, pub.day, 9);
          final DateTime ends = item.expiring
              ? now.add(Duration(days: 2 + (item.order * 3) % 12))
              : now.add(Duration(days: 90 + (item.order * 17) % 240));
          end = DateTime(ends.year, ends.month, ends.day, 17);
          threadStart = pub;
          liveFrom = pub;
          liveTo = now.subtract(const Duration(hours: 1));
        case _Kind.archived:
          final DateTime pub = _publishAt(item.topic, now);
          final DateTime cap = now.subtract(Duration(days: 3 + item.order % 4));
          DateTime archived =
              pub.add(Duration(days: 45 + (item.order * 13) % 50));
          if (archived.isAfter(cap)) archived = cap;
          if (viaApproval) {
            add('pending_approval', pub.subtract(const Duration(days: 2)));
            approvalStatus = 'approved';
          }
          add('published', pub);
          add('archived', archived);
          start = DateTime(pub.year, pub.month, pub.day, 9);
          end = DateTime(archived.year, archived.month, archived.day, 17);
          if (end.isAfter(archived)) end = archived;
          threadStart = pub.add(const Duration(days: 1));
          liveFrom = pub;
          liveTo = archived;
        case _Kind.removed:
          final DateTime pub = _publishAt(item.topic, now);
          final DateTime cap = now.subtract(const Duration(days: 2));
          DateTime removed =
              pub.add(Duration(days: 20 + (item.order * 11) % 60));
          if (removed.isAfter(cap)) removed = cap;
          if (viaApproval) {
            add('pending_approval', pub.subtract(const Duration(days: 2)));
            approvalStatus = 'approved';
          }
          add('published', pub);
          add('removed', removed,
              _removeReasons[item.order % _removeReasons.length].of(isArabic));
          start = DateTime(pub.year, pub.month, pub.day, 9);
          final DateTime ends = pub.add(const Duration(days: 300));
          end = DateTime(ends.year, ends.month, ends.day, 17);
          threadStart = pub.add(const Duration(days: 1));
          liveFrom = pub;
          liveTo = removed;
        case _Kind.approved:
          final DateTime base = DateTime(now.year, now.month, now.day, 10);
          final DateTime submitted =
              base.subtract(Duration(days: 5 + 3 * item.order));
          add('pending_approval', submitted);
          add('approved', submitted.add(const Duration(days: 1, hours: 4)));
          approvalStatus = 'approved';
          final DateTime go = base.add(Duration(days: 3 + 4 * item.order));
          start = DateTime(go.year, go.month, go.day, 9);
          final DateTime ends = go.add(Duration(days: 120 + 20 * item.order));
          end = DateTime(ends.year, ends.month, ends.day, 17);
          threadStart = submitted;
        case _Kind.pending:
          final DateTime base = DateTime(now.year, now.month, now.day, 11, 20);
          final DateTime submitted =
              base.subtract(Duration(days: 3 + 5 * item.order));
          add('pending_approval', submitted);
          final DateTime go = base.add(Duration(days: 7 + 2 * item.order));
          start = DateTime(go.year, go.month, go.day, 9);
          final DateTime ends = go.add(const Duration(days: 180));
          end = DateTime(ends.year, ends.month, ends.day, 17);
          threadStart = submitted;
        case _Kind.rejected:
          final DateTime submitted = ShowcaseCommon.spread(item.order, 10, now,
              endGap: const Duration(days: 14));
          add('pending_approval', submitted);
          final Bi why = _rejectReasons[item.order % _rejectReasons.length];
          add('rejected', submitted.add(const Duration(days: 2, hours: 3)),
              why.of(isArabic));
          approvalStatus = 'rejected';
          approvalReason = why.of(isArabic);
          final DateTime go = submitted.add(const Duration(days: 30));
          start = DateTime(go.year, go.month, go.day, 9);
          final DateTime ends = go.add(const Duration(days: 365));
          end = DateTime(ends.year, ends.month, ends.day, 17);
          threadStart = submitted;
      }
      if (approvalStatus == 'approved') {
        approvalJustification =
            _justifications[item.topic % _justifications.length].of(isArabic);
      }

      final String fileName = '${_slug(topic.title.en)}.${topic.ext}';
      final CreateKnowledgeModel model = CreateKnowledgeModel(
        firestoreDocumentId: id,
        timestamps: <int>[
          for (final DateTime t in times) t.millisecondsSinceEpoch
        ],
        knowledgeId: <String>[id],
        knowledgeImage: const <String>[''],
        nameEnglish: <String>[topic.title.en],
        nameArabic: <String>[topic.title.ar],
        descriptionEnglish: <String>[topic.desc.en],
        descriptionArabic: <String>[topic.desc.ar],
        knowledgeDocumentType: <String>[topic.type],
        owningDepartment: <String>[department],
        limitedDepartments: <String>[
          KnowledgeDepartmentsCodec.encode(const [])
        ],
        schedulePublishing: const <bool>[true],
        startDateTime: <Timestamp>[Timestamp.fromDate(start)],
        endDateTime: <Timestamp>[Timestamp.fromDate(end)],
        startTime: const <String>['09:00'],
        endTime: const <String>['17:00'],
        imageUrl: const <String>[''],
        documentUrl: <String>[file.url],
        documentFileName: <String>[fileName],
        documentExtension: <String>[topic.ext],
        documentSize: <int>[file.size],
        createdByEmail: <String>[author.email],
        timeStamp: <String>[
          for (final DateTime t in times) t.toIso8601String()
        ],
        status: statuses,
        statusReason: reasons,
      );
      await w.set(knowledge.doc(id), model.toJson());

      // ── Approval record ──
      if (approvalStatus != null) {
        final ApprovalModel approval = ApprovalModel(
          timestamps: <int>[times.last.millisecondsSinceEpoch],
          knowledgeId: <String>[id],
          status: <String>[approvalStatus],
          rejectionReason: <String>[approvalReason],
          approvalJustification: <String>[approvalJustification],
        );
        await w.set(approvals.doc(id), approval.toJson());
      }

      // ── Comment thread (3–5): reviewer first, then the author ──
      final List<List<Bi>> variants = _threads[item.kind]!;
      final List<Bi> lines = variants[n % variants.length];
      final int count = 3 + n % 3;
      final int authorIdx =
          people.indexWhere((ShowcasePerson x) => x.email == author.email);
      final ShowcasePerson reviewer = item.mine
          ? people[1 +
              (n % (people.length > 1 ? people.length - 1 : 1)) % people.length]
          : me;
      final String threadKey = 'kh_${(n + 1).toString().padLeft(2, '0')}';
      final Map<String, dynamic> filter = <String, dynamic>{
        'knowledgeId': id,
        'Request_Id': id,
      };
      final WriteBatch commentBatch = await w.reserve(count);
      if (authorIdx >= 0) {
        ShowcaseCommon.addThread(
          batch: commentBatch,
          firestore: firestore,
          collectionPath: commentsPath,
          filterFields: filter,
          threadKey: threadKey,
          lines: lines.take(count).toList(),
          speakers: <int>[
            people.indexWhere((ShowcasePerson x) => x.email == reviewer.email),
            authorIdx,
          ],
          start: threadStart,
          isArabic: isArabic,
        );
      } else {
        // A direct report who is not in the shared people list: same
        // document shape as `ShowcaseCommon.addThread`, with the real author.
        DateTime at = threadStart;
        for (int i = 0; i < count; i++) {
          at =
              at.add(Duration(hours: 2 + (i * 5) % 19, minutes: (i * 23) % 60));
          final String commentId = '${ShowcaseCommon.idPrefix}${threadKey}_c$i';
          commentBatch.set(
            firestore.collection(commentsPath).doc(commentId),
            <String, dynamic>{
              ...filter,
              'Comment_Id': commentId,
              'Comment_Text': lines[i].of(isArabic),
              'Commenter_Id': i.isEven ? reviewer.email : author.email,
              'Comment_Date': Timestamp.fromDate(at),
              'Comment_Link': null,
              'File_Name': null,
              'File_Size': null,
            },
          );
        }
      }

      // ── Views and downloads over the life of the document ──
      if (liveFrom != null && liveTo != null) {
        usageNumber = await _writeUsage(
          w: w,
          usage: usage,
          id: id,
          from: liveFrom,
          to: liveTo,
          docNumber: liveNumber,
          firstNumber: usageNumber,
          now: now,
        );
        liveNumber++;
      }
    }

    await w.finish();
    return items.length;
  }

  // ── Plan helpers ──────────────────────────────────────────────────────────

  static List<_Item> _plan() {
    final List<_Item> items = <_Item>[];
    final Map<String, int> seen = <String, int>{'A': 0, 'P': 0, 'R': 0};
    for (int s = 0; s < _liveKinds.length; s++) {
      final String k = _liveKinds[s];
      final int order = seen[k]!;
      seen[k] = order + 1;
      items.add(_Item(
        s,
        k == 'A'
            ? _Kind.archived
            : (k == 'P' ? _Kind.published : _Kind.removed),
        order,
        mine: _liveMine[s] == 'm',
        expiring: k == 'P' && _expiringSlots.contains(s),
      ));
    }
    int topic = _liveKinds.length;
    for (int k = 0; k < _approvedMine.length; k++) {
      items.add(
          _Item(topic++, _Kind.approved, k, mine: _approvedMine[k] == '1'));
    }
    for (int k = 0; k < _pendingMine.length; k++) {
      items.add(_Item(topic++, _Kind.pending, k, mine: _pendingMine[k] == '1'));
    }
    for (int k = 0; k < _rejectedMine.length; k++) {
      items.add(
          _Item(topic++, _Kind.rejected, k, mine: _rejectedMine[k] == '1'));
    }
    return items;
  }

  /// When the live document in [slot] was published: spread over the year.
  static DateTime _publishAt(int slot, DateTime now) =>
      ShowcaseCommon.spread(slot, _liveKinds.length, now,
          endGap: const Duration(days: 6));

  static String _slug(String title) => title
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  /// The department names of the company (English), or a fixed fallback.
  static List<String> _departments() {
    if (Get.isRegistered<MainCoreDepartmentCubit>()) {
      final List<String> names = Get.find<MainCoreDepartmentCubit>()
          .departmentsEnglishName
          .map((String e) => e.trim())
          .where((String e) => e.isNotEmpty && e.toLowerCase() != 'other')
          .toSet()
          .toList();
      if (names.length >= 3) return names.take(8).toList();
    }
    return _fallbackDepartments;
  }

  /// The people who author the documents that reach the signed-in user's
  /// Approvals queue: employees whose supervisor is [me]; with none, the
  /// other colleagues (the queue then stays empty).
  static List<ShowcasePerson> _otherAuthors(ShowcasePerson me) {
    final List<ShowcasePerson> reports = <ShowcasePerson>[];
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final List<EmployeeEntityPro> all =
          Get.find<MainCoreEmployeeController>().allEmployeesEntities ??
              <EmployeeEntityPro>[];
      for (final EmployeeEntityPro e in all) {
        final String email = (e.email ?? '').trim().toLowerCase();
        if (email.isEmpty || email == me.email) continue;
        if ((e.supervisor ?? '').trim().toLowerCase() != me.email) continue;
        reports.add(ShowcasePerson(
          '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim(),
          '${e.firstNameInArabic ?? e.firstName ?? ''} '
                  '${e.lastNameInArabic ?? e.lastName ?? ''}'
              .trim(),
          email,
          '',
          '',
          id: e.id ?? '',
        ));
        if (reports.length == 8) break;
      }
    }
    if (reports.isNotEmpty) return reports;
    final List<ShowcasePerson> others = <ShowcasePerson>[
      for (final ShowcasePerson p in ShowcaseCommon.people)
        if (p.email != me.email) p,
    ];
    return others.isEmpty ? <ShowcasePerson>[me] : others;
  }

  // ── Files ─────────────────────────────────────────────────────────────────

  static const Map<String, String> _contentTypes = <String, String>{
    'pdf': 'application/pdf',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'pptx':
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'csv': 'text/csv',
    'mp4': 'video/mp4',
    'mp3': 'audio/mpeg',
  };

  /// The bundled sample of each file type, at the fixed Storage path the
  /// debug seed button uses (uploaded here when it is not there yet). A file
  /// that cannot be uploaded gets an empty link instead of failing the seed.
  static Future<Map<String, _SampleFile>> _sampleFiles() async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Map<String, _SampleFile> out = <String, _SampleFile>{};
    for (final MapEntry<String, String> entry in _contentTypes.entries) {
      final String ext = entry.key;
      try {
        final List<int> bytes = (await rootBundle
                .load('assets/knowledge_hub_demo_files/demo_file.$ext'))
            .buffer
            .asUint8List();
        final Reference ref = storage.ref(
            '${getBaseUrl(FirebaseCollections.knowledgeHubRoot)}/knowledge_documents/seed_samples/sample.$ext');
        String url = '';
        try {
          url = await ref.getDownloadURL();
        } catch (_) {
          try {
            await ref.putData(Uint8List.fromList(bytes),
                SettableMetadata(contentType: entry.value));
            url = await ref.getDownloadURL();
          } catch (_) {
            url = '';
          }
        }
        out[ext] = _SampleFile(url, bytes.length);
      } catch (_) {
        out[ext] = const _SampleFile('', 0);
      }
    }
    return out;
  }

  // ── Usage records ─────────────────────────────────────────────────────────

  static String _stamp(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} '
        '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  /// Writes the views (and every fifth a download) of one document between
  /// [from] and [to], spread over the period; returns the next record number.
  static Future<int> _writeUsage({
    required _Writer w,
    required CollectionReference<Map<String, dynamic>> usage,
    required String id,
    required DateTime from,
    required DateTime to,
    required int docNumber,
    required int firstNumber,
    required DateTime now,
  }) async {
    final int minutes = to.difference(from).inMinutes;
    if (minutes <= 0) return firstNumber;
    final int days = minutes ~/ (24 * 60);
    final int count = (6 + (days * 15) ~/ 100).clamp(8, 45);
    final List<ShowcasePerson> people = ShowcaseCommon.people;
    int number = firstNumber;
    for (int k = 0; k < count; k++) {
      DateTime at = from.add(Duration(
          minutes:
              (minutes * (2 * k + 1)) ~/ (2 * count) + ((k * 37) % 11) * 20));
      if (at.isAfter(to)) at = to.subtract(Duration(minutes: k + 1));
      if (at.isAfter(now)) at = now.subtract(Duration(minutes: k + 5));
      final bool download = k % 5 == 3;
      final ShowcasePerson who = people[(docNumber * 3 + k) % people.length];
      final DocumentUtilizationModel record = DocumentUtilizationModel(
        timestamp: <String>[_stamp(at)],
        fileId: <String>[id],
        typeOfAction: <String>[download ? 'download' : 'view'],
        // KH-CREATE-14 (Amr 23/10): the usage row carries the employee ID.
        employeeId: <String>[who.id.isNotEmpty ? who.id : who.email],
      );
      number++;
      await w.set(
        usage.doc(
            '${ShowcaseCommon.idPrefix}khu_${number.toString().padLeft(4, '0')}'),
        <String, dynamic>{
          ...record.toJson(),
          'actionTimestamp': Timestamp.fromDate(at),
        },
      );
    }
    return number;
  }
}
