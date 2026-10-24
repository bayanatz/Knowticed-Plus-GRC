/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_todo.dart
/// Purpose: Showcase to-dos for the signed-in user: 30 office tasks created
///          across the year, at least 5 in every list tab (To Do, Done,
///          Overdue, Scheduled, Deleted).
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Written with `TodoModel.toCreateMap` (the module's own create map) and a
/// back-dated write time, so the creation date sits in the past month it
/// belongs to.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/todo/data/models/todo_model.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';
import 'package:knowticed_plus/features/todo/helpers/constants/todo_firestore_paths.dart';

enum _Kind { open, done, overdue, scheduled, deleted }

class _T {
  const _T(this.name, this.description, this.kind, {this.items = const <Bi>[]});

  final Bi name;
  final Bi description;
  final _Kind kind;
  final List<Bi> items;
}

abstract final class ShowcaseTodo {
  static const List<_T> _todos = <_T>[
    // ── Done (7) ──
    _T(
        Bi('Publish the 2026 data governance policy',
            'نشر سياسة حوكمة البيانات لعام 2026'),
        Bi('Final review of the policy with Legal and publish it on the Knowledge Hub.',
            'المراجعة النهائية للسياسة مع الشؤون القانونية ونشرها في مركز المعرفة.'),
        _Kind.done,
        items: <Bi>[
          Bi('Legal review', 'المراجعة القانونية'),
          Bi('Director sign-off', 'اعتماد المدير'),
          Bi('Publish on Knowledge Hub', 'النشر في مركز المعرفة'),
        ]),
    _T(
        Bi('Close Q1 data quality findings',
            'إغلاق ملاحظات جودة البيانات للربع الأول'),
        Bi('Confirm every Q1 finding has an owner, a fix and evidence attached.',
            'التأكد من أن لكل ملاحظة مالكاً ومعالجة وأدلة مرفقة.'),
        _Kind.done),
    _T(
        Bi('Onboard the new Business Analyst', 'تهيئة محللة الأعمال الجديدة'),
        Bi('Accounts, role access and an introduction to the service catalogue.',
            'إنشاء الحسابات وصلاحيات الأدوار والتعريف بدليل الخدمات.'),
        _Kind.done,
        items: <Bi>[
          Bi('Create account', 'إنشاء الحساب'),
          Bi('Assign role', 'إسناد الدور'),
          Bi('Walk-through session', 'جلسة تعريفية'),
        ]),
    _T(
        Bi('Submit the annual NDMO compliance self-assessment',
            'رفع التقييم الذاتي السنوي لامتثال مكتب إدارة البيانات الوطني'),
        Bi('Collect evidence from every department and submit before the national deadline.',
            'جمع الأدلة من جميع الإدارات ورفعها قبل الموعد الوطني.'),
        _Kind.done),
    _T(
        Bi('Archive the 2025 service requests',
            'أرشفة طلبات الخدمات لعام 2025'),
        Bi('Move closed 2025 requests to the archive and keep the audit trail.',
            'نقل طلبات 2025 المغلقة إلى الأرشيف مع الاحتفاظ بسجل التدقيق.'),
        _Kind.done),
    _T(
        Bi('Renew the master data platform licence',
            'تجديد ترخيص منصة البيانات الرئيسية'),
        Bi('Obtain the quotation, approval and purchase order for the renewal.',
            'الحصول على عرض السعر والموافقة وأمر الشراء للتجديد.'),
        _Kind.done),
    _T(
        Bi('Run the mid-year access review',
            'تنفيذ مراجعة الصلاحيات نصف السنوية'),
        Bi('Review every role and remove access that is no longer needed.',
            'مراجعة كل دور وإزالة الصلاحيات غير المطلوبة.'),
        _Kind.done),
    // ── Overdue (6) ──
    _T(
        Bi('Update the critical data elements register',
            'تحديث سجل عناصر البيانات الحرجة'),
        Bi('Add the new finance and HR elements with their owners and stewards.',
            'إضافة عناصر المالية والموارد البشرية الجديدة مع ملاكها وأمنائها.'),
        _Kind.overdue),
    _T(
        Bi('Reply to the Internal Audit memo',
            'الرد على مذكرة التدقيق الداخلي'),
        Bi('Answer the three observations on record retention.',
            'الرد على الملاحظات الثلاث الخاصة بالاحتفاظ بالسجلات.'),
        _Kind.overdue),
    _T(
        Bi('Fix duplicate supplier records', 'معالجة سجلات الموردين المكررة'),
        Bi('Merge the 214 duplicates found in the last data quality scan.',
            'دمج 214 سجلاً مكرراً ظهرت في آخر فحص لجودة البيانات.'),
        _Kind.overdue),
    _T(
        Bi('Approve the data sharing agreement with the Statistics Authority',
            'اعتماد اتفاقية مشاركة البيانات مع هيئة الإحصاء'),
        Bi('Check the classification of every shared field before signing.',
            'التحقق من تصنيف كل حقل مشترك قبل التوقيع.'),
        _Kind.overdue),
    _T(
        Bi('Complete the business continuity drill report',
            'استكمال تقرير تمرين استمرارية الأعمال'),
        Bi('Record the recovery times and lessons learned from the September drill.',
            'تسجيل أزمنة الاستعادة والدروس المستفادة من تمرين سبتمبر.'),
        _Kind.overdue),
    _T(
        Bi('Review the risk treatment plans', 'مراجعة خطط معالجة المخاطر'),
        Bi('Five high risks are waiting for an updated treatment plan.',
            'خمس مخاطر عالية بانتظار تحديث خطط المعالجة.'),
        _Kind.overdue),
    // ── Scheduled (6) ──
    _T(
        Bi('Data Governance Council meeting', 'اجتماع مجلس حوكمة البيانات'),
        Bi('Quarterly council: data quality KPIs, open risks and policy updates.',
            'الاجتماع الربعي: مؤشرات جودة البيانات والمخاطر المفتوحة وتحديثات السياسات.'),
        _Kind.scheduled),
    _T(
        Bi('Present the Q4 data quality dashboard',
            'عرض لوحة جودة البيانات للربع الرابع'),
        Bi('Present completeness, accuracy and timeliness scores to the leadership.',
            'عرض نتائج الاكتمال والدقة والحداثة على القيادة.'),
        _Kind.scheduled),
    _T(
        Bi('Workshop: metadata standards for media assets',
            'ورشة عمل: معايير البيانات الوصفية للأصول الإعلامية'),
        Bi('Agree the metadata fields for photos, videos and press releases.',
            'الاتفاق على حقول البيانات الوصفية للصور والفيديو والبيانات الصحفية.'),
        _Kind.scheduled),
    _T(
        Bi('External audit kick-off', 'بدء التدقيق الخارجي'),
        Bi('Kick-off meeting with the external auditors and evidence plan.',
            'اجتماع البدء مع المدققين الخارجيين وخطة الأدلة.'),
        _Kind.scheduled),
    _T(
        Bi('Year-end records retention review',
            'مراجعة الاحتفاظ بالسجلات لنهاية العام'),
        Bi('Confirm which records are archived and which are destroyed.',
            'تحديد السجلات التي تؤرشف والتي تتلف.'),
        _Kind.scheduled),
    _T(
        Bi('Training: Knowticed Plus for new employees',
            'تدريب: Knowticed Plus للموظفين الجدد'),
        Bi('Two-hour session on requests, services and the Knowledge Hub.',
            'جلسة لمدة ساعتين عن الطلبات والخدمات ومركز المعرفة.'),
        _Kind.scheduled),
    // ── To Do (6) ──
    _T(
        Bi('Draft the 2027 data strategy',
            'إعداد مسودة استراتيجية البيانات 2027'),
        Bi('First draft of goals, initiatives and KPIs for the 2027 strategy.',
            'المسودة الأولى للأهداف والمبادرات والمؤشرات لاستراتيجية 2027.'),
        _Kind.open,
        items: <Bi>[
          Bi('Goals', 'الأهداف'),
          Bi('Initiatives', 'المبادرات'),
          Bi('KPIs', 'المؤشرات'),
          Bi('Budget estimate', 'تقدير الميزانية'),
        ]),
    _T(
        Bi('Map the customer data flows', 'رسم تدفقات بيانات العملاء'),
        Bi('Document where customer data is collected, stored and shared.',
            'توثيق أماكن جمع بيانات العملاء وتخزينها ومشاركتها.'),
        _Kind.open),
    _T(
        Bi('Prepare the data classification training',
            'إعداد تدريب تصنيف البيانات'),
        Bi('Slides and a short quiz on the four classification levels.',
            'عرض تقديمي واختبار قصير عن مستويات التصنيف الأربعة.'),
        _Kind.open),
    _T(
        Bi('Review the new service request forms',
            'مراجعة نماذج طلبات الخدمات الجديدة'),
        Bi('Check the five new forms built in the Form Builder before publishing.',
            'مراجعة النماذج الخمسة الجديدة في منشئ النماذج قبل نشرها.'),
        _Kind.open),
    _T(
        Bi('Collect Qiyas evidence for the digital transformation standard',
            'جمع أدلة قياس لمعيار التحول الرقمي'),
        Bi('Gather screenshots and reports for the eight remaining controls.',
            'جمع لقطات الشاشة والتقارير للضوابط الثمانية المتبقية.'),
        _Kind.open),
    _T(
        Bi('Clean up the shared drive folders', 'تنظيم مجلدات القرص المشترك'),
        Bi('Move the department files into the Knowledge Hub structure.',
            'نقل ملفات الإدارة إلى هيكل مركز المعرفة.'),
        _Kind.open),
    // ── Deleted (5) ──
    _T(
        Bi('Book the venue for the media day', 'حجز مكان اليوم الإعلامي'),
        Bi('Cancelled — the event moved online.',
            'ألغيت — تحول الحدث إلى الإنترنت.'),
        _Kind.deleted),
    _T(
        Bi('Order printed copies of the annual report',
            'طلب نسخ مطبوعة من التقرير السنوي'),
        Bi('Not needed — the report is published digitally.',
            'غير مطلوب — يُنشر التقرير رقمياً.'),
        _Kind.deleted),
    _T(
        Bi('Test the old reporting tool', 'اختبار أداة التقارير القديمة'),
        Bi('Replaced by the Knowticed Plus dashboards.',
            'استبدلت بلوحات Knowticed Plus.'),
        _Kind.deleted),
    _T(
        Bi('Draft the paper leave form', 'إعداد نموذج الإجازة الورقي'),
        Bi('Replaced by the leave request in the app.',
            'استبدل بطلب الإجازة في التطبيق.'),
        _Kind.deleted),
    _T(
        Bi('Duplicate: council meeting minutes', 'مكرر: محضر اجتماع المجلس'),
        Bi('Duplicate of another to-do.', 'نسخة مكررة من مهمة أخرى.'),
        _Kind.deleted),
  ];

  /// Function Name: [seed]
  ///
  /// Purpose: Writes the showcase to-dos for [ownerEmail]; returns how many.
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required String ownerEmail,
    required bool isArabic,
    required DateTime now,
  }) async {
    final CollectionReference<Map<String, dynamic>> col = firestore
        .collection(getBaseUrl(TodoFirestorePaths.todosOf(ownerEmail)));
    final WriteBatch batch = firestore.batch();
    final List<TodoPriority> priorities = <TodoPriority>[
      TodoPriority.high,
      TodoPriority.medium,
      TodoPriority.low,
    ];
    for (int i = 0; i < _todos.length; i++) {
      final _T t = _todos[i];
      final String id = ShowcaseCommon.id('todo', i + 1);
      // Created across the year; future items created in the last weeks.
      final DateTime created = t.kind == _Kind.scheduled || t.kind == _Kind.open
          ? now.subtract(Duration(days: 3 + i % 20, hours: i))
          : ShowcaseCommon.spread(i, _todos.length, now,
              endGap: const Duration(days: 10));
      DateTime? start;
      DateTime? end;
      switch (t.kind) {
        case _Kind.done:
        case _Kind.deleted:
          start = created.add(const Duration(days: 2));
          end = created.add(const Duration(days: 7));
        case _Kind.overdue:
          start = now.subtract(Duration(days: 12 + i));
          end = now.subtract(Duration(days: 2 + i % 5));
        case _Kind.scheduled:
          final DateTime day = now.add(Duration(days: 3 + i * 4));
          start = DateTime(day.year, day.month, day.day, 10);
          end = start.add(const Duration(hours: 2));
        case _Kind.open:
          break;
      }
      final TodoEntity todo = TodoEntity(
        id: id,
        ownerEmail: ownerEmail,
        name: t.name.of(isArabic),
        description: t.description.of(isArabic),
        priority: priorities[i % 3],
        isDone: t.kind == _Kind.done,
        completedAt: t.kind == _Kind.done ? end : null,
        isDeleted: t.kind == _Kind.deleted,
        deletedAt: t.kind == _Kind.deleted
            ? created.add(const Duration(days: 4))
            : null,
        isScheduled: start != null,
        startAt: start,
        endAt: end,
        reminders: start == null
            ? const <TodoReminder>[]
            : const <TodoReminder>[
                TodoReminder(value: 1, unit: TodoReminderUnit.day)
              ],
        items: <TodoItem>[
          for (int k = 0; k < t.items.length; k++)
            TodoItem(
              id: '${id}_item_$k',
              title: t.items[k].of(isArabic),
              isDone: t.kind == _Kind.done || k == 0,
            ),
        ],
      );
      batch.set(
        col.doc(id),
        TodoModel.toCreateMap(todo, id: id, now: created),
      );
    }
    await batch.commit();
    return _todos.length;
  }
}
