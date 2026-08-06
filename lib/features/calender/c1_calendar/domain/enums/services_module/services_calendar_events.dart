/// ************************* FILE INFO *************************
/// File Name: services_calendar_events.dart
/// Module:    Service Management
/// Purpose:   Every calendar entry the Services module puts on the shared
///            calendar.
///
/// Two sources, both captured here so the calendar has ONE list:
///
///   • SPEC — "Knowticed Plus — Notification & Validation", Section 2
///     (Calendar Event Triggers). Marked `spec: true`.
///   • EXISTING BEHAVIOUR — entries `calendar_data_service.dart` has always
///     drawn (the approval-cycle cards, and the assignment / due /
///     progress / SLA / done cards). They are not in the spec's calendar
///     table, but users see them today, so dropping them would be a
///     regression. Marked `spec: false`.
///
/// ⚠️ `statusCode` is ENGLISH ONLY and must not be translated — the filter
/// chips in calendar_screen.dart compare it as a raw string
/// (`event.status == englishStatus`). The Arabic label comes from
/// `_getLocalizedStatusName`. The old code localised the three approval
/// statuses, which silently broke filtering in Arabic; the codes below fix
/// that.
///
/// RULE: never write a calendar title, description, status or colour as a
/// raw string in calendar_data_service. Add it here.

import '../calendar_event_type.dart';
import 'package:grc_module/core/enums/app_module.dart';
import 'package:grc_module/core/enums/template_variable.dart';

/// The colour every Services card already uses.
const int _kServicesBlue = 0xFF0095FF;

enum ServicesCalendarEvent implements CalendarEventType {
  // ── SPEC: Section 2, "Service" rows ─────────────────────────────────
  slaBreached(
    key: 'sla_breached',
    trigger: 'SLA Breached',
    titleEn: 'Service Level Agreement Breached',
    titleAr: 'تم تجاوز اتفاقية مستوى الخدمة (SLA)',
    descriptionEn:
        'Service has reached SLA threshold. Immediate action required.',
    descriptionAr: 'الخدمة وصلت حد اتفاقية مستوى الخدمة. مطلوب إجراء فوري.',
    statusCode: 'SLA',
    spec: true,
    schedulingNote:
        'Visible to Manager, Service Provider, and Requester. Escalation action recommended.',
  ),
  serviceCompletionDateReached(
    key: 'service_completion_date_reached',
    trigger: 'Service Completion Date Reached',
    titleEn: 'Service Request Completed',
    titleAr: 'اكتمل طلب الخدمة',
    descriptionEn: 'Your request — Done.',
    descriptionAr: 'طلبك — منتهي.',
    statusCode: 'Done',
    spec: true,
    schedulingNote:
        'Completion date reached; all relevant parties are notified simultaneously.',
  ),

  // ── EXISTING: approval-cycle cards (getApprovalCalendarEvents) ──────
  pendingApproval(
    key: 'pending_approval',
    trigger: 'Request awaiting the approver decision',
    titleEn: 'Pending Approval',
    titleAr: 'بانتظار الموافقة',
    descriptionEn:
        'A request has been submitted and requires your decision to proceed.',
    descriptionAr: 'تم تقديم طلب ويتطلب قرارك للمتابعة.',
    statusCode: 'Pending Approval',
    schedulingNote:
        'Shown to the approver whose turn it is, on the submission timestamp.',
  ),
  approvalApproved(
    key: 'approval_approved',
    trigger: 'Approver approved the request',
    titleEn: 'Approved',
    titleAr: 'تمت الموافقة',
    descriptionEn: 'You have approved this request.',
    descriptionAr: 'لقد وافقت على هذا الطلب.',
    statusCode: 'Approved',
    schedulingNote:
        'Stays on the approver calendar after the decision, on the approval timestamp.',
  ),
  approvalRejected(
    key: 'approval_rejected',
    trigger: 'Approver rejected the request',
    titleEn: 'Rejected',
    titleAr: 'مرفوض',
    descriptionEn: 'You have rejected this request.',
    descriptionAr: 'لقد رفضت هذا الطلب.',
    statusCode: 'Rejected',
    schedulingNote:
        'Stays on the approver calendar after the decision, on the rejection timestamp.',
  ),

  // ── EXISTING: fulfilment cards (getServicesCalendarEvents) ──────────
  assignedToProvider(
    key: 'assigned_to_provider',
    trigger: 'Service assigned to the provider',
    titleEn: 'Assigned',
    titleAr: 'معين',
    descriptionEn: 'A service is assigned to you. Review and change status.',
    descriptionAr: 'خدمة معينة لك. راجع وغير الحالة.',
    statusCode: 'Assigned',
    schedulingNote: 'Created for the assigned provider on the approval date.',
  ),
  dueForProvider(
    key: 'due_for_provider',
    trigger: 'SLA deadline for the assigned provider',
    titleEn: 'Due',
    titleAr: 'مستحق',
    descriptionEn:
        'The deadline for the assigned service is {{dueDate}}. Kindly prioritize accordingly.',
    descriptionAr:
        'الموعد النهائي للخدمة المخصصة هو {{dueDate}}. يرجى تحديد الأولويات وفقاً لذلك.',
    statusCode: 'Due',
    variables: {TemplateVariable.dueDate},
    schedulingNote: 'Placed on the SLA deadline while the service is running.',
  ),
  inProgressForRequester(
    key: 'in_progress_for_requester',
    trigger: 'Service moved to in progress',
    titleEn: 'In Progress',
    titleAr: 'قيد التنفيذ',
    descriptionEn:
        'Your service is in progress and is expected to be completed by {{dueDate}}.',
    descriptionAr: 'خدمتك قيد التنفيذ ومن المتوقع إكمالها بحلول {{dueDate}}.',
    statusCode: 'In Progress',
    variables: {TemplateVariable.dueDate},
    schedulingNote:
        'Placed on the in-progress start time, for the requester only.',
  ),
  slaBreachedProvider(
    key: 'sla_breached_provider',
    trigger: 'SLA breached — service provider view',
    titleEn: 'SLA Breached',
    titleAr: 'تم تجاوز اتفاقية مستوى الخدمة',
    descriptionEn:
        'Service has reached SLA threshold. Immediate action required.',
    descriptionAr: 'الخدمة وصلت حد اتفاقية مستوى الخدمة. مطلوب إجراء فوري.',
    statusCode: 'SLA',
    schedulingNote:
        'Placed on the deadline once it passes, while the service is still in progress.',
  ),
  slaBreachedRequester(
    key: 'sla_breached_requester',
    trigger: 'SLA breached — requester view',
    titleEn: 'SLA Breached',
    titleAr: 'تم تجاوز اتفاقية مستوى الخدمة',
    descriptionEn:
        'Your service request exceeded the SLA timeframe and is overdue.',
    descriptionAr:
        'طلب الخدمة تجاوز الإطار الزمني لاتفاقية مستوى الخدمة وهو متأخر.',
    statusCode: 'SLA',
    schedulingNote: 'Same deadline, worded for the requester.',
  ),
  slaBreachedManagement(
    key: 'sla_breached_management',
    trigger: 'SLA breached — middle management view',
    titleEn: 'SLA Breached',
    titleAr: 'تم تجاوز اتفاقية مستوى الخدمة',
    descriptionEn:
        'Service under your supervision ({{departmentName}}) breached SLA. Immediate attention required.',
    descriptionAr:
        'خدمة تحت إشرافك ({{departmentName}}) تجاوزت اتفاقية مستوى الخدمة. مطلوب اهتمام فوري.',
    statusCode: 'SLA',
    variables: {TemplateVariable.departmentName},
    schedulingNote:
        'Only for the supervising manager, when they are neither provider nor requester.',
  ),
  doneForRequester(
    key: 'done_for_requester',
    trigger: 'Service completed',
    titleEn: 'Done',
    titleAr: 'منتهي',
    descriptionEn: 'Your request - Done',
    descriptionAr: 'طلبك - منتهي',
    statusCode: 'Done',
    schedulingNote:
        'Placed on the completion timestamp. Use doneAfterSlaForRequester when the deadline had already passed.',
  ),
  doneAfterSlaForRequester(
    key: 'done_after_sla_for_requester',
    trigger: 'Service completed after the SLA deadline',
    titleEn: 'Done',
    titleAr: 'منتهي',
    descriptionEn:
        'The service exceeded the approved SLA duration and is now closed as Done',
    descriptionAr:
        'تجاوزت الخدمة مدة اتفاقية مستوى الخدمة المعتمدة وتم إغلاقها الآن كمنتهية',
    statusCode: 'Done',
    schedulingNote:
        'Same slot as doneForRequester, used when completion happened past the deadline.',
  );

  const ServicesCalendarEvent({
    required this.key,
    required this.trigger,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.statusCode,
    required this.schedulingNote,
    this.scope = '',
    this.colorValue = _kServicesBlue,
    this.reminderOffsetDays = 0,
    this.variables = const {},
    this.spec = false,
  });

  @override
  final String key;
  @override
  final String scope;
  @override
  final String trigger;
  @override
  final String titleEn;
  @override
  final String titleAr;
  @override
  final String descriptionEn;
  @override
  final String descriptionAr;
  @override
  final String statusCode;
  @override
  final int colorValue;
  @override
  final int reminderOffsetDays;
  @override
  final String schedulingNote;
  @override
  final Set<TemplateVariable> variables;

  /// True when the entry comes from the spec's calendar table, false when
  /// it is behaviour the app already shipped.
  final bool spec;

  @override
  AppModule get module => AppModule.services;

  @override
  String get id => '${module.key}_$key';

  static ServicesCalendarEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
