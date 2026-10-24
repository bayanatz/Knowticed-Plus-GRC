// [module-file:form_builder] — deleted when the form_builder module is split out
/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_form_builder.dart
/// Purpose: Showcase Form Builder data: 41 forms across the year (16
///          published, 6 drafts, 6 deleted, 6 shared with the user and
///          waiting for an answer, 7 the user already answered), the access
///          lists (open and restricted, ended, upcoming and revoked access)
///          and the submissions: answers in every field type, people who
///          have not answered yet and people who got a reminder.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Uses the module's own models: fields are built as the module's field
/// entities and converted with `PageEntity.toModel()`, forms are saved as
/// `FormModel`, access lists as `FormPrivacyModel` / `UsersModel` and the
/// answers as `ResponseModel` under
/// `Form Responses/{formId}/Responses/{email}`, exactly as the screens read
/// them. The per-person index `User Responses/{email}` (a document the app
/// keys by e-mail) is never replaced: only the showcase entries of its
/// `Form_Ids` / `Submission_Timestamp` lists are rebuilt, everything else in
/// it is kept.
///
/// Drafts and deleted forms use open or restricted access (with an access
/// document), never personal access: the Forms home adds every personal-access
/// form of the creator to the "Requested" tab as well.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder/data/models/users_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/data/mappers/form_entity_mapper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/date_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/description_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/email_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/link_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/terms_and_condition.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/time_selector_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/title_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/row_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/form_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/watermark_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/arrangement.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/orientation.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/models/response_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/models/user_responses_model.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';

/// What the form asks (decides its fields).
enum _Kind { request, survey, incident, registration, acknowledgement }

class _Spec {
  const _Spec(this.title, this.desc, this.kind, [this.options = const <Bi>[]]);

  final Bi title;
  final Bi desc;
  final _Kind kind;

  /// The choices of the form's check boxes (systems, sessions, topics…).
  final List<Bi> options;
}

/// One form of the plan.
class _Form {
  _Form(this.index, this.spec, this.group);

  final int index;
  final _Spec spec;

  /// 0 published, 1 draft, 2 deleted, 3 shared with the user (waiting),
  /// 4 shared with the user and answered.
  final int group;
  String id = '';
  DateTime createdAt = DateTime(2026);
  DateTime? deletedAt;
  DateTime? accessBegin;
  DateTime? accessEnd;
  bool open = true;
  ShowcasePerson? author;
  List<ShowcasePerson> recipients = <ShowcasePerson>[];
}

/// Writes in WriteBatch chunks of at most 400 operations.
class _Writer {
  _Writer(this._db) : _batch = _db.batch();

  final FirebaseFirestore _db;
  WriteBatch _batch;
  int _inBatch = 0;
  int total = 0;

  Future<void> set(
      DocumentReference<Map<String, dynamic>> ref, Map<String, dynamic> data,
      [SetOptions? options]) async {
    if (_inBatch >= 400) {
      await _batch.commit();
      _batch = _db.batch();
      _inBatch = 0;
    }
    _batch.set(ref, data, options);
    _inBatch++;
    total++;
  }

  Future<void> finish() async {
    if (_inBatch > 0) {
      await _batch.commit();
      _batch = _db.batch();
      _inBatch = 0;
    }
  }
}

abstract final class ShowcaseFormBuilder {
  // ── The forms (0–15 published, 16–21 drafts, 22–27 deleted, 28–33 shared
  //    and waiting, 34–40 shared and answered) ───────────────────────────────

  static const List<_Spec> _specs = <_Spec>[
    _Spec(
        Bi('Data Access Request', 'طلب الوصول إلى البيانات'),
        Bi('Request access to a data set or system with the business reason and the required date.',
            'تقديم طلب للوصول إلى مجموعة بيانات أو نظام مع سبب العمل والتاريخ المطلوب.'),
        _Kind.request,
        <Bi>[
          Bi('Finance system', 'النظام المالي'),
          Bi('HR system', 'نظام الموارد البشرية'),
          Bi('Document archive', 'أرشيف المستندات'),
          Bi('Media library', 'مكتبة الوسائط'),
        ]),
    _Spec(
        Bi('Data Quality Issue Report', 'بلاغ عن مشكلة في جودة البيانات'),
        Bi('Report duplicate, missing or incorrect data found in a system.',
            'الإبلاغ عن بيانات مكررة أو ناقصة أو غير صحيحة في أحد الأنظمة.'),
        _Kind.incident),
    _Spec(
        Bi('Metadata Change Request', 'طلب تغيير البيانات الوصفية'),
        Bi('Propose a change to a metadata field or a controlled vocabulary.',
            'اقتراح تغيير في حقل وصفي أو في قائمة المفردات المضبوطة.'),
        _Kind.request,
        <Bi>[
          Bi('Photos', 'الصور'),
          Bi('Video', 'الفيديو'),
          Bi('Audio', 'المواد الصوتية'),
          Bi('Press releases', 'البيانات الصحفية'),
        ]),
    _Spec(
        Bi('Records Disposal Authorisation Request', 'طلب تفويض إتلاف السجلات'),
        Bi('Ask for approval to destroy records that reached the end of their retention period.',
            'طلب الموافقة على إتلاف السجلات التي انتهت مدة الاحتفاظ بها.'),
        _Kind.request,
        <Bi>[
          Bi('Finance records', 'السجلات المالية'),
          Bi('HR records', 'سجلات الموارد البشرية'),
          Bi('Correspondence', 'المراسلات'),
          Bi('Project files', 'ملفات المشاريع'),
        ]),
    _Spec(
        Bi('Media Asset Request', 'طلب أصل إعلامي'),
        Bi('Request photos, video or audio from the media library for official use.',
            'طلب صور أو فيديو أو مواد صوتية من مكتبة الوسائط للاستخدام الرسمي.'),
        _Kind.request,
        <Bi>[
          Bi('Photos', 'الصور'),
          Bi('Video', 'الفيديو'),
          Bi('Audio', 'المواد الصوتية'),
          Bi('Graphics', 'الرسومات'),
        ]),
    _Spec(
        Bi('Policy Acknowledgement 2026', 'إقرار الاطلاع على السياسات 2026'),
        Bi('Confirm that you have read the 2026 data governance and security policies.',
            'تأكيد الاطلاع على سياسات حوكمة البيانات وأمن المعلومات لعام 2026.'),
        _Kind.acknowledgement),
    _Spec(
        Bi('Data Governance Training Registration',
            'التسجيل في تدريب حوكمة البيانات'),
        Bi('Register for the data governance training sessions of the quarter.',
            'التسجيل في جلسات تدريب حوكمة البيانات لهذا الربع.'),
        _Kind.registration,
        <Bi>[
          Bi('Foundations — morning', 'الأساسيات — صباحا'),
          Bi('Foundations — afternoon', 'الأساسيات — مساء'),
          Bi('Data quality workshop', 'ورشة جودة البيانات'),
          Bi('Metadata standards', 'معايير البيانات الوصفية'),
        ]),
    _Spec(
        Bi('Annual Staff Satisfaction Survey 2026',
            'استبيان رضا الموظفين السنوي 2026'),
        Bi('Tell us how you rate your work environment, tools and training.',
            'شاركنا تقييمك لبيئة العمل والأدوات والتدريب.'),
        _Kind.survey,
        <Bi>[
          Bi('Workplace', 'بيئة العمل'),
          Bi('Tools and systems', 'الأدوات والأنظمة'),
          Bi('Training', 'التدريب'),
          Bi('Communication', 'التواصل'),
        ]),
    _Spec(
        Bi('Data Steward Nomination Form', 'نموذج ترشيح أمناء البيانات'),
        Bi('Nominate a colleague as data steward for a business domain.',
            'ترشيح أحد الزملاء أمينا للبيانات في أحد مجالات العمل.'),
        _Kind.request,
        <Bi>[
          Bi('Customer data', 'بيانات العملاء'),
          Bi('Supplier data', 'بيانات الموردين'),
          Bi('Employee data', 'بيانات الموظفين'),
          Bi('Media content data', 'بيانات المحتوى الإعلامي'),
        ]),
    _Spec(
        Bi('Information Security Incident Notification',
            'إشعار حادثة أمن معلومات'),
        Bi('Notify the security team of a suspected incident as soon as it is noticed.',
            'إبلاغ فريق الأمن بأي حادثة مشتبه بها فور ملاحظتها.'),
        _Kind.incident),
    _Spec(
        Bi('Workshop Feedback — Metadata Standards',
            'تقييم الورشة — معايير البيانات الوصفية'),
        Bi('Share your feedback on the metadata standards workshop.',
            'شاركنا ملاحظاتك على ورشة معايير البيانات الوصفية.'),
        _Kind.survey,
        <Bi>[
          Bi('Content', 'المحتوى'),
          Bi('Presenter', 'المقدم'),
          Bi('Exercises', 'التمارين'),
          Bi('Materials', 'المواد'),
        ]),
    _Spec(
        Bi('Archive Visit Registration', 'التسجيل لزيارة الأرشيف'),
        Bi('Book a guided visit to the records archive.',
            'حجز زيارة إرشادية لأرشيف السجلات.'),
        _Kind.registration,
        <Bi>[
          Bi('Records hall', 'قاعة السجلات'),
          Bi('Digitisation lab', 'مختبر الرقمنة'),
          Bi('Cold storage', 'المخزن البارد'),
        ]),
    _Spec(
        Bi('Data Sharing Request — Government Entities',
            'طلب مشاركة البيانات — الجهات الحكومية'),
        Bi('Request to share a data set with another government entity.',
            'طلب مشاركة مجموعة بيانات مع جهة حكومية أخرى.'),
        _Kind.request,
        <Bi>[
          Bi('Statistics', 'الإحصاءات'),
          Bi('Service records', 'سجلات الخدمات'),
          Bi('Reference data', 'البيانات المرجعية'),
        ]),
    _Spec(
        Bi('NDMO Evidence Submission',
            'تقديم أدلة المكتب الوطني لإدارة البيانات'),
        Bi('Upload the evidence of a control for the national data management assessment.',
            'تقديم أدلة أحد الضوابط الخاصة بالتقييم الوطني لإدارة البيانات.'),
        _Kind.request,
        <Bi>[
          Bi('Policies', 'السياسات'),
          Bi('Procedures', 'الإجراءات'),
          Bi('Reports', 'التقارير'),
          Bi('Screenshots', 'لقطات الشاشة'),
        ]),
    _Spec(
        Bi('Business Continuity Drill Feedback',
            'ملاحظات تمرين استمرارية الأعمال'),
        Bi('Tell us how the September business continuity drill went for your team.',
            'أخبرنا كيف سار تمرين استمرارية الأعمال لشهر سبتمبر في فريقك.'),
        _Kind.survey,
        <Bi>[
          Bi('Communication', 'التواصل'),
          Bi('Recovery time', 'زمن الاستعادة'),
          Bi('Instructions', 'التعليمات'),
          Bi('Tools', 'الأدوات'),
        ]),
    _Spec(
        Bi('Records Officer Declaration', 'إقرار مسؤول السجلات'),
        Bi('Annual declaration of the records officers of each department.',
            'الإقرار السنوي لمسؤولي السجلات في كل إدارة.'),
        _Kind.acknowledgement),
    // Drafts.
    _Spec(
        Bi('Data Classification Review Checklist',
            'قائمة مراجعة تصنيف البيانات'),
        Bi('Checklist for the yearly review of the classification of data sets.',
            'قائمة فحص للمراجعة السنوية لتصنيف مجموعات البيانات.'),
        _Kind.request,
        <Bi>[
          Bi('Public', 'عام'),
          Bi('Internal', 'داخلي'),
          Bi('Confidential', 'سري'),
          Bi('Restricted', 'مقيد'),
        ]),
    _Spec(
        Bi('Quarterly Data Quality Self-Assessment',
            'التقييم الذاتي الربعي لجودة البيانات'),
        Bi('Each department rates the quality of its main data sets.',
            'تقيم كل إدارة جودة مجموعات بياناتها الرئيسية.'),
        _Kind.survey,
        <Bi>[
          Bi('Completeness', 'الاكتمال'),
          Bi('Accuracy', 'الدقة'),
          Bi('Timeliness', 'الحداثة'),
          Bi('Consistency', 'الاتساق'),
        ]),
    _Spec(
        Bi('Press Accreditation Request', 'طلب اعتماد صحفي'),
        Bi('Request press accreditation for an official event.',
            'طلب اعتماد صحفي لحضور فعالية رسمية.'),
        _Kind.request,
        <Bi>[
          Bi('Photographer', 'مصور'),
          Bi('Reporter', 'مراسل'),
          Bi('Camera crew', 'طاقم تصوير'),
        ]),
    _Spec(
        Bi('Open Data Release Request', 'طلب إتاحة بيانات مفتوحة'),
        Bi('Propose a data set for release on the open data portal.',
            'اقتراح مجموعة بيانات لإتاحتها في بوابة البيانات المفتوحة.'),
        _Kind.request,
        <Bi>[
          Bi('Statistics', 'الإحصاءات'),
          Bi('Geographic data', 'البيانات الجغرافية'),
          Bi('Budget data', 'بيانات الميزانية'),
        ]),
    _Spec(
        Bi('Vendor Data Handling Declaration',
            'إقرار تعامل المورد مع البيانات'),
        Bi('Vendors confirm how they store, process and return our data.',
            'يؤكد الموردون كيفية تخزين بياناتنا ومعالجتها وإعادتها.'),
        _Kind.acknowledgement),
    _Spec(
        Bi('Onboarding Questionnaire — New Employees',
            'استبيان التهيئة — الموظفون الجدد'),
        Bi('Short questionnaire after the first month at work.',
            'استبيان قصير بعد الشهر الأول في العمل.'),
        _Kind.survey,
        <Bi>[
          Bi('Welcome', 'الاستقبال'),
          Bi('Training', 'التدريب'),
          Bi('Equipment', 'المعدات'),
          Bi('Team support', 'دعم الفريق'),
        ]),
    // Deleted.
    _Spec(
        Bi('Equipment Loan Request', 'طلب استعارة معدات'),
        Bi('Borrow cameras and recorders for a field assignment.',
            'استعارة كاميرات ومسجلات لمهمة ميدانية.'),
        _Kind.request,
        <Bi>[
          Bi('Camera', 'كاميرا'),
          Bi('Recorder', 'مسجل صوت'),
          Bi('Tripod', 'حامل ثلاثي'),
        ]),
    _Spec(
        Bi('Meeting Room Booking', 'حجز قاعة اجتماعات'),
        Bi('Book a meeting room for the Data Governance Council.',
            'حجز قاعة اجتماعات لمجلس حوكمة البيانات.'),
        _Kind.registration,
        <Bi>[
          Bi('Main hall', 'القاعة الرئيسية'),
          Bi('Boardroom', 'قاعة مجلس الإدارة'),
          Bi('Training room', 'قاعة التدريب'),
        ]),
    _Spec(
        Bi('Visitor Pre-registration', 'التسجيل المسبق للزوار'),
        Bi('Register external visitors before they arrive.',
            'تسجيل الزوار الخارجيين قبل وصولهم.'),
        _Kind.registration,
        <Bi>[
          Bi('Meeting', 'اجتماع'),
          Bi('Audit', 'تدقيق'),
          Bi('Delivery', 'توصيل'),
        ]),
    _Spec(
        Bi('Training Needs Survey 2025', 'استبيان الاحتياجات التدريبية 2025'),
        Bi('Staff training needs for the 2025 plan.',
            'الاحتياجات التدريبية للموظفين لخطة 2025.'),
        _Kind.survey,
        <Bi>[
          Bi('Data skills', 'مهارات البيانات'),
          Bi('Leadership', 'القيادة'),
          Bi('Digital tools', 'الأدوات الرقمية'),
          Bi('Compliance', 'الامتثال'),
        ]),
    _Spec(
        Bi('Photo Shoot Request', 'طلب جلسة تصوير'),
        Bi('Request a photographer for an official occasion.',
            'طلب مصور لمناسبة رسمية.'),
        _Kind.request,
        <Bi>[
          Bi('Portraits', 'صور شخصية'),
          Bi('Event coverage', 'تغطية فعالية'),
          Bi('Product images', 'صور المنتجات'),
        ]),
    _Spec(
        Bi('Data Catalogue Feedback Form', 'نموذج ملاحظات فهرس البيانات'),
        Bi('Feedback on the first release of the data catalogue.',
            'ملاحظات على الإصدار الأول من فهرس البيانات.'),
        _Kind.survey,
        <Bi>[
          Bi('Search', 'البحث'),
          Bi('Descriptions', 'الأوصاف'),
          Bi('Speed', 'السرعة'),
          Bi('Design', 'التصميم'),
        ]),
    // Shared with the signed-in user, waiting for an answer.
    _Spec(
        Bi('Annual Disclosure of Interests', 'الإفصاح السنوي عن تعارض المصالح'),
        Bi('Every employee confirms there is no conflict of interest.',
            'يؤكد كل موظف عدم وجود تعارض في المصالح.'),
        _Kind.acknowledgement),
    _Spec(
        Bi('Remote Work Agreement', 'اتفاقية العمل عن بعد'),
        Bi('Terms of the remote work arrangement for eligible roles.',
            'شروط ترتيبات العمل عن بعد للوظائف المؤهلة.'),
        _Kind.acknowledgement),
    _Spec(
        Bi('IT Equipment Request', 'طلب أجهزة تقنية'),
        Bi('Request a laptop, monitor or accessories.',
            'طلب حاسب محمول أو شاشة أو ملحقات.'),
        _Kind.request,
        <Bi>[
          Bi('Laptop', 'حاسب محمول'),
          Bi('Monitor', 'شاشة'),
          Bi('Headset', 'سماعة'),
          Bi('Docking station', 'قاعدة توصيل'),
        ]),
    _Spec(
        Bi('Quarterly Risk Self-Assessment', 'التقييم الذاتي الربعي للمخاطر'),
        Bi('Department heads rate the main risks of the quarter.',
            'يقيم رؤساء الإدارات المخاطر الرئيسية للربع.'),
        _Kind.survey,
        <Bi>[
          Bi('Operational', 'التشغيلية'),
          Bi('Compliance', 'الامتثال'),
          Bi('Technology', 'التقنية'),
          Bi('Reputation', 'السمعة'),
        ]),
    _Spec(
        Bi('Data Day 2026 Registration', 'التسجيل في يوم البيانات 2026'),
        Bi('Register for the internal Data Day sessions.',
            'التسجيل في جلسات يوم البيانات الداخلي.'),
        _Kind.registration,
        <Bi>[
          Bi('Opening keynote', 'الكلمة الافتتاحية'),
          Bi('Data quality stories', 'قصص جودة البيانات'),
          Bi('Open data panel', 'جلسة البيانات المفتوحة'),
        ]),
    _Spec(
        Bi('Records Retention Confirmation', 'تأكيد الاحتفاظ بالسجلات'),
        Bi('Confirm the retention periods of your department records.',
            'تأكيد فترات الاحتفاظ بسجلات إدارتك.'),
        _Kind.acknowledgement),
    // Shared with the signed-in user and answered.
    _Spec(
        Bi('Employee Pulse Survey — Q3', 'استبيان نبض الموظفين — الربع الثالث'),
        Bi('Five quick questions on how the team feels this quarter.',
            'خمسة أسئلة سريعة عن شعور الفريق في هذا الربع.'),
        _Kind.survey,
        <Bi>[
          Bi('Workload', 'عبء العمل'),
          Bi('Team spirit', 'روح الفريق'),
          Bi('Management support', 'دعم الإدارة'),
          Bi('Growth', 'التطور'),
        ]),
    _Spec(
        Bi('Data Privacy Training Attestation',
            'إفادة إتمام تدريب خصوصية البيانات'),
        Bi('Confirm that you completed the data privacy training.',
            'تأكيد إتمام تدريب خصوصية البيانات.'),
        _Kind.acknowledgement),
    _Spec(
        Bi('Access Review Confirmation', 'تأكيد مراجعة الصلاحيات'),
        Bi('Confirm that the access of your team is still required.',
            'تأكيد أن صلاحيات فريقك ما زالت مطلوبة.'),
        _Kind.request,
        <Bi>[
          Bi('Finance system', 'النظام المالي'),
          Bi('Document archive', 'أرشيف المستندات'),
          Bi('Media library', 'مكتبة الوسائط'),
        ]),
    _Spec(
        Bi('Leadership Forum Registration', 'التسجيل في منتدى القيادات'),
        Bi('Register for the leadership forum.', 'التسجيل في منتدى القيادات.'),
        _Kind.registration, <Bi>[
      Bi('Morning session', 'الجلسة الصباحية'),
      Bi('Afternoon session', 'الجلسة المسائية'),
      Bi('Networking lunch', 'غداء التعارف'),
    ]),
    _Spec(
        Bi('Security Awareness Feedback', 'ملاحظات التوعية الأمنية'),
        Bi('Feedback on the security awareness campaign.',
            'ملاحظات على حملة التوعية الأمنية.'),
        _Kind.survey,
        <Bi>[
          Bi('Posters', 'الملصقات'),
          Bi('E-learning', 'التعلم الإلكتروني'),
          Bi('Phishing test', 'اختبار التصيد'),
          Bi('Emails', 'الرسائل'),
        ]),
    _Spec(
        Bi('Health and Safety Declaration 2026', 'إقرار الصحة والسلامة 2026'),
        Bi('Yearly declaration on workplace health and safety.',
            'الإقرار السنوي بشأن الصحة والسلامة في مكان العمل.'),
        _Kind.acknowledgement),
    _Spec(
        Bi('Records Inventory Update', 'تحديث جرد السجلات'),
        Bi('Update the list of records held by your department.',
            'تحديث قائمة السجلات التي تحتفظ بها إدارتك.'),
        _Kind.request,
        <Bi>[
          Bi('Paper records', 'السجلات الورقية'),
          Bi('Electronic records', 'السجلات الإلكترونية'),
          Bi('Audio and video', 'المواد الصوتية والمرئية'),
        ]),
  ];

  // Sample free texts.
  static const List<Bi> _requestDetails = <Bi>[
    Bi('Needed to prepare the quarterly compliance report.',
        'مطلوب لإعداد تقرير الامتثال الربعي.'),
    Bi('Required for the migration validation of the supplier records.',
        'مطلوب للتحقق من ترحيل سجلات الموردين.'),
    Bi('Requested by the audit team for the evidence review.',
        'مطلوب من فريق التدقيق لمراجعة الأدلة.'),
    Bi('For the onboarding of the new media library.',
        'لتهيئة مكتبة الوسائط الجديدة.'),
    Bi('To answer a request received from the Statistics Authority.',
        'للرد على طلب وارد من هيئة الإحصاء.'),
    Bi('Part of the annual review of the department data sets.',
        'ضمن المراجعة السنوية لمجموعات بيانات الإدارة.'),
  ];
  static const List<Bi> _surveyComments = <Bi>[
    Bi('Clear and well organised. More examples would help.',
        'واضح ومنظم، وإضافة أمثلة أكثر ستفيد.'),
    Bi('The tools are good but the response time could be faster.',
        'الأدوات جيدة لكن زمن الاستجابة يمكن أن يكون أسرع.'),
    Bi('Very useful session, please repeat it every quarter.',
        'جلسة مفيدة جدا، يرجى تكرارها كل ربع سنة.'),
    Bi('Communication between teams improved a lot this year.',
        'تحسن التواصل بين الفرق كثيرا هذا العام.'),
    Bi('I would like more practical training on the new systems.',
        'أرغب في تدريب عملي أكثر على الأنظمة الجديدة.'),
    Bi('No further comments, thank you.', 'لا توجد ملاحظات أخرى، شكرا لكم.'),
  ];
  static const List<Bi> _incidentTexts = <Bi>[
    Bi('Duplicate customer records were found after the last system update.',
        'ظهرت سجلات عملاء مكررة بعد آخر تحديث للنظام.'),
    Bi('Several supplier records have no tax number.',
        'عدة سجلات موردين بلا رقم ضريبي.'),
    Bi('A shared folder was open to all staff by mistake and was closed.',
        'كان مجلد مشترك مفتوحا لجميع الموظفين بالخطأ وتم إغلاقه.'),
    Bi('An email with a client list was sent to a wrong address.',
        'أرسل بريد يحتوي على قائمة العملاء إلى عنوان خاطئ.'),
    Bi('Dates in the archive index are shown in two different formats.',
        'تظهر التواريخ في فهرس الأرشيف بصيغتين مختلفتين.'),
    Bi('Photo captions are missing the photographer credit.',
        'تعليقات الصور تفتقد اسم المصور.'),
  ];

  static const List<String> _phones = <String>[
    '501234567',
    '552345678',
    '563456789',
    '504567890',
    '535678901',
    '556789012',
  ];

  // ── Seed ──────────────────────────────────────────────────────────────────

  /// Function Name: [seed]
  ///
  /// Purpose: Writes the showcase forms, access lists and submissions;
  /// returns how many documents were written.
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required bool isArabic,
    required DateTime now,
  }) async {
    final List<ShowcasePerson> others = <ShowcasePerson>[
      for (final ShowcasePerson p in ShowcaseCommon.people)
        if (p.email != me.email) p,
    ];
    if (others.isEmpty) return 0;

    final CollectionReference<Map<String, dynamic>> forms =
        firestore.collection(getBaseUrl(FormApiConstants.forms));
    final CollectionReference<Map<String, dynamic>> privacy =
        firestore.collection(getBaseUrl(FormApiConstants.formPrivacy));
    final _Writer w = _Writer(firestore);

    final List<_Form> plan = _plan(me, others, now);
    // E-mail → the showcase entries of the person's submission index.
    final Map<String, List<(String, Timestamp)>> index =
        <String, List<(String, Timestamp)>>{};

    for (final _Form f in plan) {
      final FormModel model = _formModel(f, me, isArabic, now);
      await w.set(forms.doc(f.id), model.toMap());
      await w.set(privacy.doc(f.id), _privacy(f, now).toMap());

      // ── Submissions ──
      if (f.group == 1 || f.group == 2) continue;
      final CollectionReference<
          Map<String,
              dynamic>> responses = firestore.collection(getBaseUrl(
          '${FormApiConstants.formResponses}/${f.id}/${FormApiConstants.responses}'));
      final List<ShowcasePerson> recipients = f.recipients;
      final int total = recipients.length;
      final bool notStarted =
          f.accessBegin != null && f.accessBegin!.isAfter(now);
      // Who answered: the first [done] recipients (the signed-in user decides
      // for the forms shared with them).
      int done = notStarted ? 0 : ((total * (45 + (f.index * 11) % 50)) ~/ 100);
      if (f.group == 0 && !notStarted && done < 2) done = 2;
      final DateTime from = f.createdAt.add(const Duration(days: 1));
      DateTime until = (f.accessEnd != null && f.accessEnd!.isBefore(now))
          ? f.accessEnd!
          : now.subtract(const Duration(days: 1));
      if (!until.isAfter(from.add(const Duration(days: 2)))) {
        until = from.add(const Duration(days: 3));
      }
      final int window = until.difference(from).inMinutes;
      for (int j = 0; j < total; j++) {
        final ShowcasePerson p = recipients[j];
        final bool isMe = p.email == me.email;
        bool answered = j < done;
        if (f.group == 3 && isMe) answered = false;
        if (f.group == 4 && isMe) answered = true;
        if (answered) {
          final DateTime at =
              from.add(Duration(minutes: (window * (j + 1)) ~/ (total + 1)));
          final ResponseModel r = ResponseModel(
            id: p.email,
            submittedBy: p.email,
            timestamps: <Timestamp>[Timestamp.fromDate(at)],
            reminder: const <Timestamp>[],
            pages: _pages(f, isArabic, answerFor: p, salt: f.index * 7 + j)
                .map((PageEntity e) => e.toModel())
                .toList(),
          );
          await w.set(responses.doc(p.email), r.toMap());
          index
              .putIfAbsent(p.email, () => <(String, Timestamp)>[])
              .add((f.id, Timestamp.fromDate(at)));
        } else if (!notStarted && !isMe && f.group == 0 && j % 2 == 0) {
          // A reminder was sent to someone who has not answered yet.
          final DateTime remindedAt =
              now.subtract(Duration(days: 2 + (f.index + j) % 9, hours: j));
          final ResponseModel r = ResponseModel(
            id: p.email,
            submittedBy: p.email,
            timestamps: const <Timestamp>[],
            reminder: <Timestamp>[Timestamp.fromDate(remindedAt)],
            pages: null,
          );
          await w.set(responses.doc(p.email), r.toMap());
        }
      }
    }

    // ── The per-person submission index: rebuild only the showcase entries ──
    for (final MapEntry<String, List<(String, Timestamp)>> e in index.entries) {
      final DocumentReference<Map<String, dynamic>> ref =
          firestore.collection(FormApiConstants.userResponses).doc(e.key);
      final List<String> ids = <String>[];
      final List<Timestamp> stamps = <Timestamp>[];
      final DocumentSnapshot<Map<String, dynamic>> existing = await ref.get();
      final Map<String, dynamic>? data = existing.data();
      if (data != null) {
        final List<String> oldIds = List<String>.from(
            data[UserResponsesModel.formIdsField] ?? const <String>[]);
        final List<Timestamp> oldStamps = List<Timestamp>.from(
            data[UserResponsesModel.submissionTimestampField] ??
                const <Timestamp>[]);
        final int n =
            oldIds.length < oldStamps.length ? oldIds.length : oldStamps.length;
        for (int i = 0; i < n; i++) {
          if (oldIds[i].startsWith(ShowcaseCommon.idPrefix)) continue;
          ids.add(oldIds[i]);
          stamps.add(oldStamps[i]);
        }
      }
      for (final (String, Timestamp) entry in e.value) {
        ids.add(entry.$1);
        stamps.add(entry.$2);
      }
      await w.set(
          ref,
          UserResponsesModel(
                  email: e.key, formIds: ids, submissionTimestamp: stamps)
              .toMap(),
          SetOptions(merge: true));
    }

    await w.finish();
    return w.total;
  }

  // ── Plan ──────────────────────────────────────────────────────────────────

  static List<_Form> _plan(
      ShowcasePerson me, List<ShowcasePerson> others, DateTime now) {
    final List<_Form> plan = <_Form>[];
    for (int i = 0; i < _specs.length; i++) {
      final int group = i < 16
          ? 0
          : i < 22
              ? 1
              : i < 28
                  ? 2
                  : i < 34
                      ? 3
                      : 4;
      final _Form f = _Form(i, _specs[i], group)
        ..id = ShowcaseCommon.id('form', i + 1)
        ..createdAt = ShowcaseCommon.spread(i, _specs.length, now,
            endGap: const Duration(days: 9));
      f.open = i % 2 == 0;
      f.author = group >= 3 ? others[i % others.length] : me;
      // Recipients: 6–12 colleagues of the user's forms; the user and a few
      // colleagues for the forms shared with them.
      if (group >= 3) {
        final List<ShowcasePerson> pool = <ShowcasePerson>[
          for (final ShowcasePerson p in others)
            if (p.email != f.author!.email) p,
        ];
        final int n = pool.isEmpty ? 0 : (3 + i % 3).clamp(1, pool.length);
        f.recipients = <ShowcasePerson>[
          for (int k = 0; k < n; k++) pool[(i + k) % pool.length],
          me,
        ];
        f.open = false;
        f.accessBegin = f.createdAt;
        f.accessEnd = now.add(Duration(days: 20 + (i * 7) % 60));
      } else {
        final int n = (6 + i % 7).clamp(1, others.length);
        f.recipients = group == 1
            ? const <ShowcasePerson>[]
            : <ShowcasePerson>[
                for (int k = 0; k < n; k++) others[(i + k) % others.length],
              ];
        f.accessBegin = f.createdAt;
        f.accessEnd = now.add(Duration(days: 25 + (i * 9) % 150));
        if (group == 0) {
          // Three forms whose access has ended, one that opens next week.
          if (i == 2 || i == 7 || i == 11) {
            final DateTime end = f.createdAt.add(Duration(days: 60 + i * 4));
            f.accessEnd = end.isAfter(now.subtract(const Duration(days: 5)))
                ? now.subtract(Duration(days: 5 + i))
                : end;
          }
          if (i == 13) {
            f.accessBegin = now.add(const Duration(days: 5));
            f.accessEnd = now.add(const Duration(days: 60));
          }
        }
        if (group == 2) {
          final DateTime d = f.createdAt.add(Duration(days: 12 + i * 3));
          f.deletedAt =
              d.isAfter(now) ? now.subtract(const Duration(days: 3)) : d;
        }
      }
      plan.add(f);
    }
    return plan;
  }

  static FormModel _formModel(
      _Form f, ShowcasePerson me, bool isArabic, DateTime now) {
    final bool edited = f.group == 0 && f.index % 3 == 1;
    final DateTime editedAt = f.createdAt.add(Duration(days: 20 + f.index * 2));
    final List<Timestamp> stamps = <Timestamp>[
      Timestamp.fromDate(f.createdAt),
      if (edited && editedAt.isBefore(now)) Timestamp.fromDate(editedAt),
      if (f.deletedAt != null) Timestamp.fromDate(f.deletedAt!),
    ];
    final String status = switch (f.group) {
      1 => FormStatus.drafts.name.toLowerCase(),
      2 => FormStatus.publish.name.toLowerCase(),
      _ => FormStatus.publish.name.toLowerCase(),
    };
    final String access = (f.open
            ? AccessManagement.openAccess
            : AccessManagement.restrictedAccess)
        .name
        .toLowerCase();
    return FormModel(
      id: f.id,
      timestamps: stamps,
      createdByEmail: f.author?.email ?? me.email,
      image: <String>[],
      title: <String>[f.spec.title.en],
      arabicTitle: <String>[f.spec.title.ar],
      description: <String>[
        f.spec.desc.en,
      ],
      arabicDescription: <String>[f.spec.desc.ar],
      accessMangement: <String>[access],
      orientation: <String>[OrientationEnum.portrait.name],
      horizontalPadding: <String>['16.0'],
      verticalPadding: <String>['16.0'],
      pages: _pages(f, isArabic).map((PageEntity e) => e.toModel()).toList(),
      formStatus: <String>[
        status,
        if (f.group == 2) FormStatus.deleted.name.toLowerCase(),
      ],
      watermark: WatermarkModel(
        imageName: <String>[],
        imageUrl: <String>[],
        size: <String>['100'],
        opacity: <String>['50'],
      ),
    );
  }

  /// The access list of the form (an empty one for a draft).
  static FormPrivacyModel _privacy(_Form f, DateTime now) {
    final List<ShowcasePerson> people = f.recipients;
    final int n = people.length;
    return FormPrivacyModel(
      timestamps: <Timestamp>[Timestamp.fromDate(f.createdAt)],
      usersModel: UsersModel(
        emails: <String>[for (final ShowcasePerson p in people) p.email],
        status: <String>[
          for (int k = 0; k < n; k++)
            // One person had their access withdrawn.
            (f.group == 0 && f.index == 4 && k == n - 1)
                ? 'inactive'
                : 'active',
        ],
        accessBegin: List<Timestamp?>.generate(
            n,
            (int k) => f.accessBegin == null
                ? null
                : Timestamp.fromDate(f.accessBegin!)),
        accessEnd: List<Timestamp?>.generate(
            n,
            (int k) =>
                f.accessEnd == null ? null : Timestamp.fromDate(f.accessEnd!)),
        editPermission:
            List<bool>.generate(n, (int k) => f.group == 0 && k == 0),
        shared: List<bool>.generate(n, (int k) => f.group == 0 && k >= n - 2),
      ),
    );
  }

  // ── Fields ────────────────────────────────────────────────────────────────

  static const String _noColor = 'Color(0xff000000)';

  /// The pages of [f] in the app language. With [answerFor] every field is
  /// answered as that person (the pages of a submission).
  static List<PageEntity> _pages(_Form f, bool isArabic,
      {ShowcasePerson? answerFor, int salt = 0}) {
    final bool ar = isArabic;
    String t(String en, String arText) => ar ? arText : en;
    final bool a = answerFor != null;
    T pick<T>(List<T> items, int s) => items[(salt + s) % items.length];
    final String left = AlignmentEnum.left.name;
    final String center = AlignmentEnum.center.name;
    final String vertical = Arrangement.vertical.name;
    final String horizontal = Arrangement.horizontal.name;
    final List<String> departments = <String>[
      t('Data Governance', 'حوكمة البيانات'),
      t('Information Technology', 'تقنية المعلومات'),
      t('Legal Affairs', 'الشؤون القانونية'),
      t('Media Production', 'الإنتاج الإعلامي'),
      t('Human Resources', 'الموارد البشرية'),
      t('Finance', 'المالية'),
    ];
    final List<String> options = <String>[
      for (final Bi o in f.spec.options) o.of(ar),
    ];

    TitleFieldModel heading() => TitleFieldModel(
          title: f.spec.title.of(ar),
          isRequired: false,
          alignment: center,
          textSize: 22,
          isUnderLine: false,
          isBold: true,
          titleColor: _noColor,
          isItalic: false,
        );
    TextFieldModel name() => TextFieldModel(
          title: t('Full name', 'الاسم الكامل'),
          alignment: left,
          isRequired: true,
          hint: t('Enter your full name', 'أدخل اسمك الكامل'),
          textAnswer: a ? answerFor.name(ar) : null,
        );
    EmailFieldModel email() => EmailFieldModel(
          title: t('Work email', 'البريد الإلكتروني للعمل'),
          isRequired: true,
          alignment: left,
          hint: 'name@company.com',
          emailAnswer: a ? answerFor.email : null,
        );
    DropDownFieldModel department() => DropDownFieldModel(
          title: t('Department', 'الإدارة'),
          alignment: left,
          isRequired: true,
          hints: departments,
          currentValue: a ? pick(departments, 1) : null,
        );
    DescriptionFieldModel description(String title, String hint, Bi sample) =>
        DescriptionFieldModel(
          title: title,
          hint: hint,
          alignment: left,
          isRequired: false,
          limitation: '500',
          descriptionAnswer: a ? sample.of(ar) : null,
        );
    DateFieldModel date(String title) => DateFieldModel(
          title: title,
          alignment: left,
          isRequired: true,
          hint: t('Select a date', 'اختر تاريخا'),
          answerDate: a
              ? DateTime(f.createdAt.year, f.createdAt.month,
                  f.createdAt.day + 5 + salt % 20)
              : null,
        );
    TermsAndConditionsFieldModel terms(Bi en) => TermsAndConditionsFieldModel(
          title: t('Declaration', 'الإقرار'),
          termsAr: en.ar,
          termsEn: en.en,
          alignment: left,
          isAccepted: a ? true : null,
        );
    RadioFieldModel radio(String title, List<String> hints,
            {bool wide = false}) =>
        RadioFieldModel(
          title: title,
          alignment: left,
          isRequired: true,
          hints: hints,
          arrangement: wide ? horizontal : vertical,
          selectedRadio: a ? pick(hints, title.length) : null,
        );
    CheckBoxFieldModel checks(String title) => CheckBoxFieldModel(
          title: title,
          isRequired: false,
          options: options,
          maximumSelection: 3,
          alignment: left,
          arrangement: vertical,
          answers: a
              ? <String>{
                  pick(options, 0),
                  if (options.length > 2) pick(options, 2),
                }.toList()
              : null,
        );
    PhoneFieldModel phone() => PhoneFieldModel(
          title: t('Mobile number', 'رقم الجوال'),
          alignment: left,
          isRequired: false,
          phoneAnswer: a ? pick(_phones, 0) : null,
          phoneCodeAnswer: a ? 'SA' : null,
        );
    TimeSelectorFieldModel time(String title) => TimeSelectorFieldModel(
          title: title,
          isRequired: false,
          time: a ? '${(8 + salt % 4).toString().padLeft(2, '0')}:30' : null,
          amOrPm: a ? 'AM' : null,
        );
    LinkFieldModel link() => LinkFieldModel(
          title: t('Evidence link', 'رابط الدليل'),
          isRequired: false,
          hint: 'https://',
          alignment: left,
          linkAnswer: a
              ? 'https://intranet.bayanatz.com/evidence/${1000 + salt}'
              : null,
        );
    List<RowEntity> rows(List<List<FieldModel>> r) =>
        <RowEntity>[for (final List<FieldModel> x in r) RowEntity(fields: x)];

    final List<List<FieldModel>> first;
    final List<List<FieldModel>> second;
    switch (f.spec.kind) {
      case _Kind.request:
        first = <List<FieldModel>>[
          <FieldModel>[heading()],
          <FieldModel>[name(), email()],
          <FieldModel>[
            department(),
            radio(t('Priority', 'الأولوية'),
                <String>[t('Normal', 'عادية'), t('Urgent', 'عاجلة')],
                wide: true),
          ],
          <FieldModel>[checks(t('Applies to', 'ينطبق على'))],
          <FieldModel>[
            description(
                t('Details of the request', 'تفاصيل الطلب'),
                t('Explain the business reason', 'اشرح سبب العمل'),
                pick(_requestDetails, 0)),
          ],
          <FieldModel>[date(t('Required by', 'مطلوب قبل'))],
        ];
        second = <List<FieldModel>>[
          <FieldModel>[
            terms(const Bi(
                'I confirm that the information given is accurate and that the data will be used only for the stated purpose.',
                'أؤكد أن المعلومات المقدمة صحيحة وأن البيانات ستستخدم للغرض المذكور فقط.')),
          ],
        ];
      case _Kind.survey:
        first = <List<FieldModel>>[
          <FieldModel>[heading()],
          <FieldModel>[
            radio(t('Overall rating', 'التقييم العام'), <String>[
              t('Excellent', 'ممتاز'),
              t('Good', 'جيد'),
              t('Fair', 'مقبول'),
              t('Poor', 'ضعيف'),
            ]),
          ],
          <FieldModel>[
            radio(t('Clarity', 'الوضوح'),
                <String>[t('Clear', 'واضح'), t('Unclear', 'غير واضح')],
                wide: true),
            radio(t('Usefulness', 'الفائدة'),
                <String>[t('Useful', 'مفيد'), t('Not useful', 'غير مفيد')],
                wide: true),
          ],
          <FieldModel>[checks(t('Areas to improve', 'مجالات التحسين'))],
          <FieldModel>[
            description(
                t('Comments', 'ملاحظات'),
                t('Write any suggestions here', 'اكتب مقترحاتك هنا'),
                pick(_surveyComments, 0)),
          ],
        ];
        second = const <List<FieldModel>>[];
      case _Kind.incident:
        first = <List<FieldModel>>[
          <FieldModel>[heading()],
          <FieldModel>[
            TextFieldModel(
              title: t('Reference number', 'الرقم المرجعي'),
              alignment: left,
              isRequired: false,
              hint: 'INC-2026-000',
              textAnswer: a ? 'INC-2026-${(100 + salt * 3).toString()}' : null,
            ),
            DropDownFieldModel(
              title: t('Severity', 'درجة الخطورة'),
              alignment: left,
              isRequired: true,
              hints: <String>[
                t('High', 'عالية'),
                t('Medium', 'متوسطة'),
                t('Low', 'منخفضة'),
              ],
              currentValue: a
                  ? pick(<String>[
                      t('High', 'عالية'),
                      t('Medium', 'متوسطة'),
                      t('Low', 'منخفضة'),
                    ], 2)
                  : null,
            ),
          ],
          <FieldModel>[
            date(t('Date identified', 'تاريخ الاكتشاف')),
            time(t('Time identified', 'وقت الاكتشاف')),
          ],
          <FieldModel>[
            description(t('What happened', 'ماذا حدث'),
                t('Describe the issue', 'صف المشكلة'), pick(_incidentTexts, 0)),
          ],
          <FieldModel>[link()],
          <FieldModel>[
            radio(t('Is a service affected?', 'هل تأثرت خدمة؟'),
                <String>[t('Yes', 'نعم'), t('No', 'لا')],
                wide: true),
          ],
        ];
        second = const <List<FieldModel>>[];
      case _Kind.registration:
        first = <List<FieldModel>>[
          <FieldModel>[heading()],
          <FieldModel>[name(), email()],
          <FieldModel>[phone(), department()],
          <FieldModel>[
            radio(t('Attendance', 'نوع الحضور'),
                <String>[t('In person', 'حضوري'), t('Online', 'عن بعد')],
                wide: true),
          ],
          <FieldModel>[checks(t('Sessions', 'الجلسات'))],
          <FieldModel>[time(t('Preferred arrival time', 'وقت الوصول المفضل'))],
        ];
        second = const <List<FieldModel>>[];
      case _Kind.acknowledgement:
        first = <List<FieldModel>>[
          <FieldModel>[heading()],
          <FieldModel>[name(), department()],
          <FieldModel>[date(t('Date', 'التاريخ'))],
          <FieldModel>[
            terms(const Bi(
                'I confirm that I have read and understood the document and that I will comply with it.',
                'أؤكد أنني قرأت المستند وفهمته وأنني سألتزم به.')),
          ],
          <FieldModel>[
            radio(
                t('Do you have any questions?', 'هل لديك أي استفسارات؟'),
                <String>[
                  t('No', 'لا'),
                  t('Yes — contact me', 'نعم — تواصلوا معي')
                ],
                wide: true),
          ],
        ];
        second = const <List<FieldModel>>[];
    }
    return <PageEntity>[
      PageEntity(rows: rows(first)),
      if (second.isNotEmpty) PageEntity(rows: rows(second)),
    ];
  }
}
