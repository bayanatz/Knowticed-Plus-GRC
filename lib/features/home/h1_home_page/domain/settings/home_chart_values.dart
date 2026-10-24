/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_chart_values.dart
/// Purpose: Declares `HomeChartCatalog` — for every module, the sets of
///          numbers ("values") a Chart & Graph card can show. The chart's gear
///          offers Module, then the Values of that module (Figma H11 / H12
///          "Chart Settings").
/// Author: Knowticed Plus team
/// Created at: 23/10/2026
///
/// WHAT IS REAL AND WHAT IS NOT (To-Do is wired: HomeChartLive, 24/10/2026)
/// ----------------------------
/// The catalog is the real list of counters each module's Home cards already
/// show. The NUMBERS in [HomeChartSeries.sample] are sample figures: the
/// Chart & Graph cards have always drawn sample data, and the live counts of
/// each module are not wired to them yet. Wiring is a per-module step that
/// replaces [HomeChartSeries.sample] and nothing else here.
library;

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_chart_live.dart';

/// "In progress" → "In Progress": every English word starts with a capital
/// (Moataz 24/10/2026).
String titleCase(String s) => s
    .split(' ')
    .map((String w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

/// One bar / slice / row of a chart.
class HomeChartSeries {
  const HomeChartSeries(this.en, this.ar, this.sample);

  final String en;
  final String ar;

  /// Sample figure (see the file header).
  final double sample;

  String label(bool isArabic) => isArabic ? ar : titleCase(en);
}

/// One selectable set of numbers of a module, e.g. "Requests by status".
class HomeChartValue {
  const HomeChartValue(this.key, this.en, this.ar, this.series,
      {this.trend = false});

  /// True for a value measured over time (the last six months, oldest first):
  /// its [series] are the six months' figures and their labels are not used.
  /// False = a snapshot split into parts (statuses, levels…).
  final bool trend;

  /// Stable machine name, stored in the placed chart's settings.
  final String key;
  final String en;
  final String ar;
  final List<HomeChartSeries> series;

  String title(bool isArabic) => isArabic ? ar : titleCase(en);
}

class HomeChartCatalog {
  const HomeChartCatalog._();

  /// Modules that offer chart values, in the order the dropdown lists them.
  static List<Modules> get modules => _byModule.keys.toList();

  /// The values [module] offers (empty for an unknown module key).
  static List<HomeChartValue> valuesOf(String? moduleKey) {
    for (final MapEntry<Modules, List<HomeChartValue>> e in _byModule.entries) {
      if (e.key.name == moduleKey) {
        return <HomeChartValue>[
          for (final HomeChartValue v in e.value) _withLive(moduleKey!, v),
        ];
      }
    }
    return const <HomeChartValue>[];
  }

  /// [v] with the module's real figures in place of the sample ones, when the
  /// module has published them and their count matches the series.
  static HomeChartValue _withLive(String moduleKey, HomeChartValue v) {
    final List<HomeChartLiveSeries>? parts =
        HomeChartLive.instance.labelled(moduleKey, v.key);
    if (parts != null) {
      return HomeChartValue(
        v.key,
        v.en,
        v.ar,
        <HomeChartSeries>[
          for (final HomeChartLiveSeries p in parts)
            HomeChartSeries(p.en, p.ar, p.value),
        ],
        trend: v.trend,
      );
    }
    final List<double>? live = HomeChartLive.instance.figures(moduleKey, v.key);
    if (live == null || live.length != v.series.length) return v;
    return HomeChartValue(
      v.key,
      v.en,
      v.ar,
      <HomeChartSeries>[
        for (int i = 0; i < v.series.length; i++)
          HomeChartSeries(v.series[i].en, v.series[i].ar, live[i]),
      ],
      trend: v.trend,
    );
  }

  /// What a chart can draw: a LINE chart needs a value over time; the
  /// pie / donut / radial / stacked / grouped / table / horizontal charts need a
  /// snapshot split into parts; the bar, base line and trend-bar charts take
  /// either (Moataz 24/10/2026: offer only values that make sense).
  static List<HomeChartValue> valuesFor(
      String? moduleKey, HomeComponents component) {
    final List<HomeChartValue> all = valuesOf(moduleKey);
    switch (component) {
      case HomeComponents.lineChart:
        return all.where((HomeChartValue v) => v.trend).toList();
      case HomeComponents.barChart:
      case HomeComponents.barTrendChart:
      case HomeComponents.baseLineChart:
        return all;
      default:
        return all.where((HomeChartValue v) => !v.trend).toList();
    }
  }

  /// Modules that have at least one value this [component] can draw.
  static List<Modules> modulesFor(HomeComponents component) => <Modules>[
        for (final Modules m in modules)
          if (valuesFor(m.name, component).isNotEmpty) m,
      ];

  static HomeChartValue _tr(
          String key, String en, String ar, List<double> months) =>
      HomeChartValue(
        key,
        en,
        ar,
        <HomeChartSeries>[
          for (final double v in months) HomeChartSeries('', '', v)
        ],
        trend: true,
      );

  /// The chosen value, or null when [moduleKey] / [valueKey] is not in the
  /// catalog (nothing chosen = the card keeps its own sample).
  static HomeChartValue? find(String? moduleKey, String? valueKey) {
    for (final HomeChartValue v in valuesOf(moduleKey)) {
      if (v.key == valueKey) return v;
    }
    return null;
  }

  static final Map<Modules, List<HomeChartValue>> _byModule =
      <Modules, List<HomeChartValue>>{
    Modules.services: <HomeChartValue>[
      _tr('requests_per_month', 'Requests per month', 'الطلبات شهريًا',
          <double>[62.0, 71.0, 68.0, 84.0, 79.0, 96.0]),
      HomeChartValue('requests_by_status', 'Requests by status',
          'الطلبات حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Pending', 'قيد الانتظار', 14),
        HomeChartSeries('In progress', 'قيد التنفيذ', 9),
        HomeChartSeries('Approved', 'موافق عليه', 22),
        HomeChartSeries('Rejected', 'مرفوض', 5),
        HomeChartSeries('Done', 'منجز', 31),
      ]),
      HomeChartValue('sla', 'Service level agreement',
          'اتفاقية مستوى الخدمة', <HomeChartSeries>[
        HomeChartSeries('Within SLA', 'ضمن الاتفاقية', 40),
        HomeChartSeries('Near breach', 'قريب من التجاوز', 7),
        HomeChartSeries('Breached', 'متجاوز', 3),
      ]),
      HomeChartValue('requests_by_department', 'Requests by department',
          'الطلبات حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 34),
        HomeChartSeries('IT', 'تقنية المعلومات', 27),
        HomeChartSeries('Finance', 'المالية', 18),
        HomeChartSeries('Operations', 'العمليات', 12),
        HomeChartSeries('Sales', 'المبيعات', 5),
      ]),
      HomeChartValue('requests_by_service', 'Top requested services',
          'الخدمات الأكثر طلبًا', <HomeChartSeries>[
        HomeChartSeries('Annual leave', 'إجازة سنوية', 26),
        HomeChartSeries('Laptop request', 'طلب جهاز', 19),
        HomeChartSeries('Access card', 'بطاقة دخول', 14),
        HomeChartSeries('Salary letter', 'خطاب راتب', 11),
      ]),
      HomeChartValue('requests_by_priority', 'Requests by priority',
          'الطلبات حسب الأولوية', <HomeChartSeries>[
        HomeChartSeries('High', 'عالي', 12),
        HomeChartSeries('Medium', 'متوسط', 38),
        HomeChartSeries('Low', 'منخفض', 31),
      ]),
    ],
    Modules.todo: <HomeChartValue>[
      _tr(
          'tasks_done_per_month',
          'Tasks done per month',
          'المهام المنجزة شهريًا',
          <double>[34.0, 41.0, 38.0, 52.0, 47.0, 58.0]),
      HomeChartValue('tasks_by_status', 'Tasks by status',
          'المهام حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Done', 'منجز', 20),
        HomeChartSeries('To do', 'قيد التنفيذ', 12),
        HomeChartSeries('Overdue', 'متأخر', 4),
        HomeChartSeries('Scheduled', 'مجدول', 6),
      ]),
      HomeChartValue('tasks_by_priority', 'Tasks by priority',
          'المهام حسب الأولوية', <HomeChartSeries>[
        HomeChartSeries('High', 'عالي', 15),
        HomeChartSeries('Medium', 'متوسط', 13),
        HomeChartSeries('Low', 'منخفض', 10),
      ]),
      HomeChartValue('tasks_by_department', 'Tasks by department',
          'المهام حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 9),
        HomeChartSeries('IT', 'تقنية المعلومات', 14),
        HomeChartSeries('Finance', 'المالية', 7),
        HomeChartSeries('Operations', 'العمليات', 12),
        HomeChartSeries('Sales', 'المبيعات', 6),
      ]),
      HomeChartValue('tasks_by_assignee', 'Tasks by owner',
          'المهام حسب المسؤول', <HomeChartSeries>[
        HomeChartSeries('Me', 'أنا', 11),
        HomeChartSeries('My team', 'فريقي', 19),
        HomeChartSeries('Others', 'آخرون', 8),
      ]),
    ],
    Modules.timeTracker: <HomeChartValue>[
      _tr('attendance_rate', 'Attendance rate', 'نسبة الحضور',
          <double>[91.0, 93.0, 90.0, 94.0, 92.0, 95.0]),
      HomeChartValue('attendance', 'Attendance by status',
          'الحضور حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Present', 'حاضر', 13),
        HomeChartSeries('Absent', 'غياب', 1),
        HomeChartSeries('Late', 'متأخر', 2),
      ]),
      HomeChartValue('requests', 'Requests by status',
          'الطلبات حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Approved', 'مقبول', 19),
        HomeChartSeries('Pending', 'قيد الانتظار', 12),
        HomeChartSeries('Rejected', 'مرفوض', 6),
      ]),
      HomeChartValue('attendance_by_department', 'Attendance by department',
          'الحضور حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 12),
        HomeChartSeries('IT', 'تقنية المعلومات', 19),
        HomeChartSeries('Finance', 'المالية', 13),
        HomeChartSeries('Operations', 'العمليات', 30),
        HomeChartSeries('Sales', 'المبيعات', 16),
      ]),
      HomeChartValue('requests_by_type', 'Requests by type',
          'الطلبات حسب النوع', <HomeChartSeries>[
        HomeChartSeries('Leave', 'إجازة', 17),
        HomeChartSeries('Permission', 'إذن', 11),
        HomeChartSeries('Overtime', 'وقت إضافي', 9),
      ]),
    ],
    Modules.inventory: <HomeChartValue>[
      _tr('stock_movement', 'Stock movement per month', 'حركة المخزون شهريًا',
          <double>[120.0, 148.0, 131.0, 160.0, 154.0, 172.0]),
      HomeChartValue('stock', 'Stock by condition',
          'المخزون حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Products', 'المنتجات', 120),
        HomeChartSeries('Damaged', 'التالف', 10),
        HomeChartSeries('Missing', 'المفقود', 6),
        HomeChartSeries('Salon', 'الصالون', 40),
      ]),
      HomeChartValue('stock_by_category', 'Stock by category',
          'المخزون حسب الفئة', <HomeChartSeries>[
        HomeChartSeries('Hair', 'الشعر', 48),
        HomeChartSeries('Skin', 'البشرة', 36),
        HomeChartSeries('Nails', 'الأظافر', 22),
        HomeChartSeries('Tools', 'الأدوات', 14),
      ]),
      HomeChartValue('orders_by_status', 'Orders by status',
          'الطلبات حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Delivered', 'تم التسليم', 26),
        HomeChartSeries('Pending', 'قيد الانتظار', 9),
        HomeChartSeries('Canceled', 'ملغي', 3),
      ]),
    ],
    Modules.knowledgeHub: <HomeChartValue>[
      _tr('documents_per_month', 'Documents per month', 'المستندات شهريًا',
          <double>[8.0, 11.0, 9.0, 14.0, 12.0, 17.0]),
      HomeChartValue('documents', 'Documents by status',
          'المستندات حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Published', 'تم النشر', 9),
        HomeChartSeries('Approved', 'موافق عليه', 5),
        HomeChartSeries('Pending', 'قيد الانتظار', 6),
        HomeChartSeries('Rejected', 'مرفوض', 6),
      ]),
      HomeChartValue('documents_by_department', 'Documents by department',
          'المستندات حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 14),
        HomeChartSeries('IT', 'تقنية المعلومات', 9),
        HomeChartSeries('Finance', 'المالية', 11),
        HomeChartSeries('Operations', 'العمليات', 6),
        HomeChartSeries('Sales', 'المبيعات', 4),
      ]),
      HomeChartValue('documents_by_type', 'Documents by type',
          'المستندات حسب النوع', <HomeChartSeries>[
        HomeChartSeries('Policy', 'سياسة', 12),
        HomeChartSeries('Guide', 'دليل', 15),
        HomeChartSeries('Form', 'نموذج', 9),
      ]),
    ],
    Modules.formBuilder: <HomeChartValue>[
      _tr('submissions_per_month', 'Submissions per month', 'الإرسالات شهريًا',
          <double>[18.0, 25.0, 22.0, 31.0, 28.0, 36.0]),
      HomeChartValue('submissions', 'Submissions by status',
          'الإرسالات حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Submitted', 'تم الإرسال', 18),
        HomeChartSeries('Pending', 'قيد الانتظار', 7),
        HomeChartSeries('Rejected', 'مرفوض', 3),
      ]),
      HomeChartValue('submissions_by_department', 'Submissions by department',
          'الإرسالات حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 8),
        HomeChartSeries('IT', 'تقنية المعلومات', 5),
        HomeChartSeries('Finance', 'المالية', 6),
        HomeChartSeries('Operations', 'العمليات', 4),
        HomeChartSeries('Sales', 'المبيعات', 2),
      ]),
      HomeChartValue('submissions_by_form', 'Submissions by form',
          'الإرسالات حسب النموذج', <HomeChartSeries>[
        HomeChartSeries('Leave form', 'نموذج إجازة', 11),
        HomeChartSeries('Feedback', 'ملاحظات', 8),
        HomeChartSeries('Onboarding', 'التهيئة', 6),
      ]),
    ],
    Modules.employees: <HomeChartValue>[
      _tr('headcount', 'Headcount', 'عدد الموظفين',
          <double>[88.0, 90.0, 92.0, 93.0, 95.0, 98.0]),
      HomeChartValue('employees_status', 'Employees by status',
          'الموظفون حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Active', 'نشط', 84),
        HomeChartSeries('On leave', 'في إجازة', 9),
        HomeChartSeries('Inactive', 'معطل', 5),
      ]),
      HomeChartValue('employees_department', 'Employees by department',
          'الموظفون حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 12),
        HomeChartSeries('IT', 'تقنية المعلومات', 21),
        HomeChartSeries('Finance', 'المالية', 14),
        HomeChartSeries('Operations', 'العمليات', 33),
        HomeChartSeries('Sales', 'المبيعات', 18),
      ]),
      HomeChartValue('employees_by_type', 'Employees by contract',
          'الموظفون حسب العقد', <HomeChartSeries>[
        HomeChartSeries('Full-time', 'دوام كامل', 74),
        HomeChartSeries('Part-time', 'دوام جزئي', 12),
        HomeChartSeries('Contract', 'متعاقد', 12),
      ]),
    ],
    Modules.messages: <HomeChartValue>[
      _tr('messages_per_month', 'Messages per month', 'الرسائل شهريًا',
          <double>[240.0, 265.0, 252.0, 298.0, 281.0, 310.0]),
      HomeChartValue('messages', 'Messages by status',
          'الرسائل حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Sent', 'مرسلة', 120),
        HomeChartSeries('Received', 'مستلمة', 164),
        HomeChartSeries('Unread', 'غير مقروءة', 18),
      ]),
      HomeChartValue('messages_by_channel', 'Messages by channel',
          'الرسائل حسب القناة', <HomeChartSeries>[
        HomeChartSeries('Direct', 'مباشرة', 172),
        HomeChartSeries('Groups', 'مجموعات', 98),
        HomeChartSeries('Broadcast', 'بث', 32),
      ]),
      HomeChartValue('messages_by_department', 'Messages by department',
          'الرسائل حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 61),
        HomeChartSeries('IT', 'تقنية المعلومات', 88),
        HomeChartSeries('Finance', 'المالية', 47),
        HomeChartSeries('Operations', 'العمليات', 74),
        HomeChartSeries('Sales', 'المبيعات', 32),
      ]),
    ],
    Modules.tasks: <HomeChartValue>[
      _tr('tasks_created', 'Tasks created per month', 'المهام المنشأة شهريًا',
          <double>[28.0, 35.0, 31.0, 44.0, 40.0, 49.0]),
      HomeChartValue('tasks_status', 'Tasks by status',
          'المهام حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('To do', 'للتنفيذ', 16),
        HomeChartSeries('In progress', 'قيد التنفيذ', 11),
        HomeChartSeries('Done', 'منجز', 27),
      ]),
      HomeChartValue('tasks_by_priority2', 'Tasks by priority',
          'المهام حسب الأولوية', <HomeChartSeries>[
        HomeChartSeries('High', 'عالي', 12),
        HomeChartSeries('Medium', 'متوسط', 24),
        HomeChartSeries('Low', 'منخفض', 18),
      ]),
      HomeChartValue('tasks_by_department2', 'Tasks by department',
          'المهام حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 10),
        HomeChartSeries('IT', 'تقنية المعلومات', 17),
        HomeChartSeries('Finance', 'المالية', 8),
        HomeChartSeries('Operations', 'العمليات', 13),
        HomeChartSeries('Sales', 'المبيعات', 6),
      ]),
    ],
    Modules.grc: <HomeChartValue>[
      _tr('risks_logged', 'Risks logged per month', 'المخاطر المسجلة شهريًا',
          <double>[4.0, 6.0, 5.0, 8.0, 7.0, 9.0]),
      HomeChartValue(
          'risks', 'Risks by level', 'المخاطر حسب المستوى', <HomeChartSeries>[
        HomeChartSeries('High', 'عالية', 7),
        HomeChartSeries('Medium', 'متوسطة', 15),
        HomeChartSeries('Low', 'منخفضة', 22),
      ]),
      HomeChartValue('risks_by_department', 'Risks by department',
          'المخاطر حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 6),
        HomeChartSeries('IT', 'تقنية المعلومات', 11),
        HomeChartSeries('Finance', 'المالية', 13),
        HomeChartSeries('Operations', 'العمليات', 9),
        HomeChartSeries('Sales', 'المبيعات', 5),
      ]),
      HomeChartValue('risks_by_status', 'Risks by status',
          'المخاطر حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Open', 'مفتوحة', 19),
        HomeChartSeries('Mitigated', 'تم الحد منها', 17),
        HomeChartSeries('Closed', 'مغلقة', 8),
      ]),
    ],
    Modules.events: <HomeChartValue>[
      _tr('events_per_month', 'Events per month', 'الأحداث شهريًا',
          <double>[7.0, 9.0, 8.0, 12.0, 10.0, 14.0]),
      HomeChartValue(
          'events', 'Events by status', 'الأحداث حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Upcoming', 'قادمة', 12),
        HomeChartSeries('Past', 'سابقة', 31),
        HomeChartSeries('Canceled', 'ملغاة', 3),
      ]),
      HomeChartValue('events_by_type', 'Events by type',
          'الأحداث حسب النوع', <HomeChartSeries>[
        HomeChartSeries('Meeting', 'اجتماع', 24),
        HomeChartSeries('Training', 'تدريب', 11),
        HomeChartSeries('Workshop', 'ورشة عمل', 8),
      ]),
      HomeChartValue('events_by_department', 'Events by department',
          'الأحداث حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 9),
        HomeChartSeries('IT', 'تقنية المعلومات', 12),
        HomeChartSeries('Finance', 'المالية', 8),
        HomeChartSeries('Operations', 'العمليات', 10),
        HomeChartSeries('Sales', 'المبيعات', 5),
      ]),
    ],
    Modules.notes: <HomeChartValue>[
      _tr('notes_per_month', 'Notes per month', 'الملاحظات شهريًا',
          <double>[15.0, 19.0, 17.0, 24.0, 21.0, 27.0]),
      HomeChartValue(
          'notes', 'Notes by status', 'الملاحظات حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Pinned', 'مثبتة', 6),
        HomeChartSeries('Recent', 'حديثة', 19),
        HomeChartSeries('Archived', 'مؤرشفة', 24),
      ]),
      HomeChartValue('notes_by_department', 'Notes by department',
          'الملاحظات حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 8),
        HomeChartSeries('IT', 'تقنية المعلومات', 13),
        HomeChartSeries('Finance', 'المالية', 9),
        HomeChartSeries('Operations', 'العمليات', 11),
        HomeChartSeries('Sales', 'المبيعات', 8),
      ]),
      HomeChartValue('notes_by_type', 'Notes by type',
          'الملاحظات حسب النوع', <HomeChartSeries>[
        HomeChartSeries('Text', 'نصية', 27),
        HomeChartSeries('Checklist', 'قائمة مهام', 14),
        HomeChartSeries('Quote', 'اقتباس', 8),
      ]),
    ],
    Modules.qiyas: <HomeChartValue>[
      _tr('assignments_per_month', 'Assignments per month', 'التعيينات شهريًا',
          <double>[10.0, 13.0, 12.0, 17.0, 15.0, 20.0]),
      HomeChartValue('qiyas', 'Assignments by coverage',
          'التعيينات حسب التغطية', <HomeChartSeries>[
        HomeChartSeries('Assigned', 'معين', 21),
        HomeChartSeries('Partially assigned', 'تعيين جزئي', 8),
        HomeChartSeries('Unassigned', 'غير مخصص', 5),
      ]),
      HomeChartValue('assignments_by_department', 'Assignments by department',
          'التعيينات حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 7),
        HomeChartSeries('IT', 'تقنية المعلومات', 12),
        HomeChartSeries('Finance', 'المالية', 9),
        HomeChartSeries('Operations', 'العمليات', 10),
        HomeChartSeries('Sales', 'المبيعات', 7),
      ]),
      HomeChartValue('assignments_by_status', 'Assignments by status',
          'التعيينات حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Completed', 'مكتمل', 18),
        HomeChartSeries('In progress', 'قيد التنفيذ', 11),
        HomeChartSeries('Overdue', 'متأخر', 5),
      ]),
    ],
    Modules.hr: <HomeChartValue>[
      _tr(
          'hr_requests_trend',
          'HR requests per month',
          'طلبات الموارد البشرية شهريًا',
          <double>[20.0, 24.0, 22.0, 30.0, 27.0, 33.0]),
      HomeChartValue('hr_requests', 'HR requests by type',
          'طلبات الموارد البشرية حسب النوع', <HomeChartSeries>[
        HomeChartSeries('Leave', 'إجازات', 22),
        HomeChartSeries('Contracts', 'عقود', 9),
        HomeChartSeries('Payroll', 'رواتب', 13),
      ]),
      HomeChartValue('hr_by_department', 'HR requests by department',
          'طلبات الموارد البشرية حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 11),
        HomeChartSeries('IT', 'تقنية المعلومات', 13),
        HomeChartSeries('Finance', 'المالية', 9),
        HomeChartSeries('Operations', 'العمليات', 8),
        HomeChartSeries('Sales', 'المبيعات', 3),
      ]),
      HomeChartValue('hr_status', 'HR requests by status',
          'طلبات الموارد البشرية حسب الحالة', <HomeChartSeries>[
        HomeChartSeries('Approved', 'موافق عليه', 25),
        HomeChartSeries('Pending', 'قيد الانتظار', 13),
        HomeChartSeries('Rejected', 'مرفوض', 6),
      ]),
    ],
    Modules.crm: <HomeChartValue>[
      _tr(
          'leads_per_month',
          'New leads per month',
          'العملاء المحتملون الجدد شهريًا',
          <double>[22.0, 27.0, 25.0, 34.0, 31.0, 38.0]),
      HomeChartValue('leads', 'Leads by stage',
          'العملاء المحتملون حسب المرحلة', <HomeChartSeries>[
        HomeChartSeries('New', 'جديد', 30),
        HomeChartSeries('Qualified', 'مؤهل', 18),
        HomeChartSeries('Won', 'مكسوب', 9),
      ]),
      HomeChartValue('leads_by_source', 'Leads by source',
          'العملاء المحتملون حسب المصدر', <HomeChartSeries>[
        HomeChartSeries('Website', 'الموقع', 24),
        HomeChartSeries('Referral', 'ترشيح', 19),
        HomeChartSeries('Campaign', 'حملة', 14),
      ]),
      HomeChartValue('leads_by_owner', 'Leads by owner',
          'العملاء المحتملون حسب المسؤول', <HomeChartSeries>[
        HomeChartSeries('Ahmed', 'أحمد', 21),
        HomeChartSeries('Sara', 'سارة', 18),
        HomeChartSeries('Khaled', 'خالد', 15),
      ]),
    ],
    Modules.database: <HomeChartValue>[
      _tr(
          'records_per_month',
          'Records added per month',
          'السجلات المضافة شهريًا',
          <double>[90.0, 110.0, 102.0, 131.0, 124.0, 150.0]),
      HomeChartValue('records', 'Records by action',
          'السجلات حسب الإجراء', <HomeChartSeries>[
        HomeChartSeries('Created', 'منشأة', 140),
        HomeChartSeries('Updated', 'محدثة', 96),
        HomeChartSeries('Deleted', 'محذوفة', 12),
      ]),
      HomeChartValue('records_by_table', 'Records by table',
          'السجلات حسب الجدول', <HomeChartSeries>[
        HomeChartSeries('Clients', 'العملاء', 96),
        HomeChartSeries('Products', 'المنتجات', 74),
        HomeChartSeries('Orders', 'الطلبات', 63),
      ]),
      HomeChartValue('records_by_department', 'Records by department',
          'السجلات حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 40),
        HomeChartSeries('IT', 'تقنية المعلومات', 66),
        HomeChartSeries('Finance', 'المالية', 52),
        HomeChartSeries('Operations', 'العمليات', 71),
        HomeChartSeries('Sales', 'المبيعات', 38),
      ]),
    ],
    Modules.roles: <HomeChartValue>[
      _tr(
          'access_changes',
          'Access changes per month',
          'تغييرات الصلاحيات شهريًا',
          <double>[6.0, 9.0, 7.0, 12.0, 10.0, 13.0]),
      HomeChartValue('users', 'Users by access',
          'المستخدمون حسب الصلاحية', <HomeChartSeries>[
        HomeChartSeries('Active', 'نشط', 31),
        HomeChartSeries('Inactive', 'معطل', 7),
        HomeChartSeries('Locked', 'محظور', 8),
      ]),
      HomeChartValue('users_by_role', 'Users by role',
          'المستخدمون حسب الدور', <HomeChartSeries>[
        HomeChartSeries('Admin', 'مدير النظام', 4),
        HomeChartSeries('Manager', 'مدير', 12),
        HomeChartSeries('Employee', 'موظف', 30),
      ]),
      HomeChartValue('users_by_department', 'Users by department',
          'المستخدمون حسب القسم', <HomeChartSeries>[
        HomeChartSeries('HR', 'الموارد البشرية', 9),
        HomeChartSeries('IT', 'تقنية المعلومات', 14),
        HomeChartSeries('Finance', 'المالية', 8),
        HomeChartSeries('Operations', 'العمليات', 10),
        HomeChartSeries('Sales', 'المبيعات', 5),
      ]),
    ],
  };
}
