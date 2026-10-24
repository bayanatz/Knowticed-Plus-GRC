/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_settings.dart
/// Purpose: Showcase Settings data: profile change requests in every status
///          (pending, approved, rejected, cancelled — at least 5 each for
///          the signed-in user, more from colleagues for the reviewers),
///          each with a comment thread, plus Comments & Feedback reports in
///          every status (open, fixed, closed).
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Same document shape as `SettingsDemoSeeder` (ChangeRequestMapper keys,
/// the feedback map) and the request comments go to
/// `RequestCollectionPaths.requestCommentsCollection` keyed by `Request_Id`,
/// exactly as `DetailsRequest` reads them.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/models/change_request_mapper.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/data/utils/feedback_collection_paths.dart';

class _Req {
  const _Req(this.section, this.note, this.changes);

  final String section;
  final Bi note;
  final List<FieldChange> changes;
}

class _Fb {
  const _Fb(this.type, this.priority, this.body);

  final String type;
  final String priority;
  final Bi body;
}

abstract final class ShowcaseSettings {
  static const String _personal = 'Personal Information';
  static const String _health = 'Health Insurance';
  static const String _company = 'Company Information';

  static const List<_Req> _requests = <_Req>[
    _Req(
        _personal,
        Bi('My mobile number changed after moving to the new office.',
            'تغير رقم جوالي بعد الانتقال إلى المكتب الجديد.'),
        <FieldChange>[
          FieldChange(
              fieldName: 'phone',
              oldValue: '0551234567',
              newValue: '0559876543')
        ]),
    _Req(
        _personal,
        Bi('I moved to a new home in Riyadh.',
            'انتقلت إلى سكن جديد في الرياض.'),
        <FieldChange>[
          FieldChange(
              fieldName: 'city', oldValue: 'Jeddah', newValue: 'Riyadh'),
          FieldChange(
              fieldName: 'street',
              oldValue: 'Prince Sultan Rd. 14',
              newValue: 'King Fahd Rd. 220'),
        ]),
    _Req(
        _health,
        Bi('Please update the policy number after the annual renewal.',
            'يرجى تحديث رقم الوثيقة بعد التجديد السنوي.'),
        <FieldChange>[
          FieldChange(
              fieldName: 'insurancePolicyNumber',
              oldValue: 'TW-2025-4471',
              newValue: 'TW-2026-4471')
        ]),
    _Req(
        _company,
        Bi('The tax number on file is missing the last digit.',
            'الرقم الضريبي المسجل ينقصه الرقم الأخير.'),
        <FieldChange>[
          FieldChange(
              fieldName: 'taxNumber',
              oldValue: '30012345670000',
              newValue: '300123456700003')
        ]),
    _Req(
        _personal,
        Bi('Marital status update after marriage.',
            'تحديث الحالة الاجتماعية بعد الزواج.'),
        <FieldChange>[
          FieldChange(
              fieldName: 'marital_status',
              oldValue: 'Single',
              newValue: 'Married')
        ]),
    _Req(
        _personal,
        Bi('My postal code was corrected by Saudi Post.',
            'صحح البريد السعودي الرمز البريدي الخاص بي.'),
        <FieldChange>[
          FieldChange(
              fieldName: 'postalCode', oldValue: '12241', newValue: '12244')
        ]),
    _Req(
        _health,
        Bi('Adding my newborn daughter to the medical policy.',
            'إضافة ابنتي المولودة إلى الوثيقة الطبية.'),
        <FieldChange>[
          FieldChange(
              fieldName: 'insurancePolicyNumber',
              oldValue: 'TW-2026-4471',
              newValue: 'TW-2026-4471-D2')
        ]),
    _Req(
        _personal,
        Bi('New office extension after the floor move.',
            'تحويلة مكتب جديدة بعد الانتقال إلى الطابق الجديد.'),
        <FieldChange>[
          FieldChange(
              fieldName: 'extension', oldValue: '2140', newValue: '3315')
        ]),
  ];

  /// Comment threads, picked by request status.
  static const Map<String, List<Bi>> _threads = <String, List<Bi>>{
    'pending': <Bi>[
      Bi('I attached the supporting document to my profile.',
          'أرفقت المستند الداعم في ملفي الشخصي.'),
      Bi('Thank you, the request is with HR for verification.',
          'شكراً، الطلب لدى الموارد البشرية للتحقق.'),
      Bi('Expected decision within two working days.',
          'القرار المتوقع خلال يومي عمل.'),
    ],
    'approved': <Bi>[
      Bi('Checked against the official record — the change is correct.',
          'تمت المطابقة مع السجل الرسمي — التغيير صحيح.'),
      Bi('Approved. Your profile is now updated.',
          'تم الاعتماد. تم تحديث ملفك الشخصي.'),
      Bi('Thank you for the quick review.', 'شكراً على سرعة المراجعة.'),
    ],
    'rejected': <Bi>[
      Bi('The new value does not match the attached certificate.',
          'القيمة الجديدة لا تطابق الشهادة المرفقة.'),
      Bi('Could you tell me which document you need?',
          'هل يمكن توضيح المستند المطلوب؟'),
      Bi('Please submit again with the updated official certificate.',
          'يرجى إعادة التقديم مع الشهادة الرسمية المحدثة.'),
    ],
    'cancelled': <Bi>[
      Bi('I submitted this by mistake, cancelling it.',
          'قدمت هذا الطلب بالخطأ وسألغيه.'),
      Bi('Noted, no action needed from HR.',
          'تم العلم، لا يلزم أي إجراء من الموارد البشرية.'),
    ],
  };

  static const Map<String, Bi> _decisionReasons = <String, Bi>{
    'rejected': Bi(
        'The new value does not match the official certificate. Please attach the updated certificate.',
        'القيمة الجديدة لا تطابق الشهادة الرسمية. يرجى إرفاق الشهادة المحدثة.'),
    'cancelled': Bi('Submitted by mistake.', 'قُدم بالخطأ.'),
  };

  static const List<_Fb> _feedback = <_Fb>[
    _Fb(
        'bug',
        'high',
        Bi('On the iPad in portrait, the long department names are cut in the Requests list.',
            'على الآيباد بالوضع الرأسي تُقص أسماء الإدارات الطويلة في قائمة الطلبات.')),
    _Fb(
        'feature_request',
        'medium',
        Bi('Please add an export to Excel on the Time Tracker dashboard.',
            'يرجى إضافة تصدير إلى إكسل في لوحة متتبع الوقت.')),
    _Fb(
        'comment',
        'low',
        Bi('The new Knowledge Hub search is much faster, thank you.',
            'البحث الجديد في مركز المعرفة أسرع بكثير، شكراً.')),
    _Fb(
        'bug',
        'critical',
        Bi('Bulk upload of services stops when a row has an empty category.',
            'يتوقف الرفع الجماعي للخدمات عندما يكون التصنيف فارغاً في أحد الصفوف.')),
    _Fb(
        'feature_request',
        'high',
        Bi('Allow delegating approvals while on leave.',
            'السماح بتفويض الموافقات أثناء الإجازة.')),
    _Fb(
        'comment',
        'medium',
        Bi('The GRC dashboard colours make the risk levels very clear.',
            'ألوان لوحة الحوكمة والمخاطر توضح مستويات المخاطر بشكل ممتاز.')),
    _Fb(
        'bug',
        'medium',
        Bi('The calendar shows the event one hour late after the time change.',
            'يظهر التقويم الحدث متأخراً ساعة بعد تغيير التوقيت.')),
    _Fb(
        'feature_request',
        'low',
        Bi('Add Hijri dates next to the Gregorian dates.',
            'إضافة التاريخ الهجري بجانب التاريخ الميلادي.')),
    _Fb(
        'bug',
        'high',
        Bi('Form Builder preview does not show the Arabic labels in RTL.',
            'معاينة منشئ النماذج لا تعرض العناوين العربية من اليمين لليسار.')),
    _Fb(
        'comment',
        'low',
        Bi('Messages loads instantly now, great improvement.',
            'تحميل الرسائل أصبح فورياً، تحسن رائع.')),
    _Fb(
        'feature_request',
        'medium',
        Bi('Show the SLA countdown on every service request card.',
            'عرض العد التنازلي لاتفاقية مستوى الخدمة على كل بطاقة طلب.')),
    _Fb(
        'bug',
        'low',
        Bi('The org chart zoom resets after opening a profile.',
            'يعود تكبير الهيكل التنظيمي للوضع الأصلي بعد فتح ملف موظف.')),
    _Fb(
        'comment',
        'medium',
        Bi('The database quality score helped us find 200 duplicates.',
            'ساعدنا مؤشر جودة قاعدة البيانات في اكتشاف 200 سجل مكرر.')),
    _Fb(
        'feature_request',
        'high',
        Bi('Notify the requester by email when a request is approved.',
            'إشعار مقدم الطلب بالبريد الإلكتروني عند اعتماد الطلب.')),
    _Fb(
        'bug',
        'medium',
        Bi('The To-Do reminder arrived twice for a recurring task.',
            'وصل تذكير المهمة مرتين لمهمة متكررة.')),
  ];

  /// Function Name: [seed]
  ///
  /// Purpose: Writes the showcase requests (with comments) and feedback;
  /// returns how many documents were written.
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required bool isArabic,
    required DateTime now,
  }) async {
    final WriteBatch batch = firestore.batch();
    int count = 0;
    final CollectionReference<Map<String, dynamic>> requests = firestore
        .doc(RequestCollectionPaths.rolesDoc)
        .collection(RequestCollectionPaths.requestsCollection);
    final CollectionReference<Map<String, dynamic>> feedback = firestore
        .doc(FeedbackCollectionPaths.settingsDoc)
        .collection(FeedbackCollectionPaths.feedbackCollection);

    const List<String> statuses = <String>[
      'approved',
      'pending',
      'rejected',
      'cancelled',
    ];
    // 20 requests by the signed-in user (5 per status) + 16 by colleagues
    // (mostly pending, so the reviewer's queue is full).
    const int mine = 20;
    const int total = 36;
    for (int i = 0; i < total; i++) {
      final bool isMine = i < mine;
      final String status = isMine
          ? statuses[i % 4]
          : (i % 3 == 0 ? 'approved' : (i % 5 == 0 ? 'rejected' : 'pending'));
      final ShowcasePerson who = isMine ? me : ShowcaseCommon.person(i);
      final _Req r = _requests[i % _requests.length];
      final DateTime at = status == 'pending'
          ? now.subtract(Duration(days: 1 + i % 12, hours: i % 7))
          : ShowcaseCommon.spread(i, total, now,
              endGap: const Duration(days: 14));
      final String id = ShowcaseCommon.id('request', i + 1);
      final String stamp =
          '${at.year}-${_two(at.month)}-${_two(at.day)} ${_two(at.hour)}:${_two(at.minute)}:00';
      final DateTime decided = at.add(Duration(days: 1 + i % 3, hours: 2));
      batch.set(requests.doc(id), <String, dynamic>{
        ChangeRequestMapper.keyChanges:
            r.changes.map((FieldChange c) => c.toMap()).toList(),
        ChangeRequestMapper.keySection: r.section,
        ChangeRequestMapper.keyRequestDate: Timestamp.fromDate(at),
        ChangeRequestMapper.keyRequestDateFormatted: stamp,
        ChangeRequestMapper.keyRequestNote: r.note.of(isArabic),
        ChangeRequestMapper.keyStatus: status,
        ChangeRequestMapper.keyDecisionReason:
            _decisionReasons[status]?.of(isArabic) ?? '',
        ChangeRequestMapper.keyEmployeeId: who.id,
        ChangeRequestMapper.keyEmployeeEmail: who.email,
        ChangeRequestMapper.keyEmployeeName: who.name(isArabic),
        ChangeRequestMapper.keyCreatedAt: Timestamp.fromDate(at),
        ChangeRequestMapper.keyUpdatedAt:
            Timestamp.fromDate(status == 'pending' ? at : decided),
        ChangeRequestMapper.keyNumberOfChanges: r.changes.length,
      });
      count++;
      ShowcaseCommon.addThread(
        batch: batch,
        firestore: firestore,
        collectionPath: RequestCollectionPaths.requestCommentsCollection,
        filterFields: <String, dynamic>{
          RequestCollectionPaths.commentRequestIdField: id,
        },
        threadKey: 'request_${i + 1}',
        lines: _threads[status]!,
        // Requester, then a reviewer, alternating.
        speakers: <int>[
          ShowcaseCommon.people.indexOf(who).clamp(0, 99),
          (i + 3) % ShowcaseCommon.people.length,
        ],
        start: at,
        isArabic: isArabic,
      );
      count += _threads[status]!.length;
    }

    const List<String> fbStatuses = <String>['open', 'fixed', 'closed'];
    for (int i = 0; i < _feedback.length; i++) {
      final _Fb f = _feedback[i];
      final ShowcasePerson who = i % 3 == 0 ? me : ShowcaseCommon.person(i + 1);
      final DateTime at = ShowcaseCommon.spread(i, _feedback.length, now);
      batch.set(
          feedback.doc(ShowcaseCommon.id('feedback', i + 1)), <String, dynamic>{
        'type': f.type,
        'body': f.body.of(isArabic),
        'employeeId': who.id,
        'employeeName': who.name(isArabic),
        'employeeEmail': who.email,
        'status': fbStatuses[i % 3],
        'priority': f.priority,
        'createdAt': Timestamp.fromDate(at),
        'attachments': const <Map<String, dynamic>>[],
        'attachment': null,
        'details': null,
      });
      count++;
    }

    await batch.commit();
    return count;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
