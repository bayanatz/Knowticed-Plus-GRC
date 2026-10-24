/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: services_calendar_events.dart
/// Module:    Service Management
/// Purpose: Every calendar entry the services module can place on the calendar.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
///
/// Written to complete CR-SKEL-CAL-N03: `calendar_data_service.dart` was
/// already migrated onto `CalendarEventModel.fromType` and referenced this
/// enum at nine call sites, but the file itself was never added — the calendar
/// side had the `CalendarEventType` interface and none of the per-module
/// files the interface's own header calls for.
///
/// Wording is aligned with `notification/domain/enums/services_module/
/// services_events.dart` so a calendar card and the notification that
/// accompanies it read the same. Where the calendar splits one notification
/// by audience (requester / provider / management), the shared phrasing is
/// kept and only the addressee changes.
///
/// ⚠️ NO `{{serviceName}}` PLACEHOLDER. The notification bodies interpolate
/// the service name, but on the calendar it is already the card's `taskName`
/// (every call site passes `taskName: taskName`), so repeating it in the body
/// would print it twice. Only entries whose call site actually passes a
/// variable declare one — `variables` is asserted against the call site in
/// [CalendarEventModel.fromType], so declaring an unused placeholder here
/// would throw at runtime.
///
/// ─── UPDATED 1/9/2026 ────────────────────────────────────────────────────
///
/// The revised §2 of "Knowticed Plus — Notification & Validation" expands the
/// Service block from two rows to six, and adds an audience note that the
/// builder was not honouring: completion is seen by "Manager, Service
/// Provider, and Requester", and the in-progress entry "records the actual
/// start date".
///
/// Three entries were added for the two sides that had no card:
/// [inProgressForProvider], [doneForProvider] and [doneForManagement]. The
/// approval-cycle rows of the spec ("Service Request Pending Decision") were
/// already covered by [pendingApproval] / [approvalApproved] /
/// [approvalRejected], and "New Service Assignment" by [assignedToProvider].
library;

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/calendar_event_type.dart';

enum ServicesCalendarEvent implements CalendarEventType {
  // ── Approval cycle ────────────────────────────────────────────────────────

  pendingApproval(
    key: 'pending_approval',
    scope: 'Approvals',
    trigger: 'Request Reaches Your Step in the Approval Cycle',
    titleEn: 'Approval Pending',
    titleAr: 'الاعتماد قيد الانتظار',
    descriptionEn:
        'This service request is waiting for an approval decision. Open it to see its status.',
    descriptionAr: 'طلب الخدمة هذا بانتظار قرار الاعتماد. افتحه لمعرفة حالته.',
    statusCode: 'Pending Approval',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the timestamp of the step that made it the signed-in user\'s turn. Shown only while `myState` is pending.',
  ),

  approvalApproved(
    key: 'approval_approved',
    scope: 'Approvals',
    trigger: 'You Approved the Request',
    titleEn: 'Request Approved',
    titleAr: 'تم اعتماد الطلب',
    descriptionEn:
        'This service request was approved. Open it to follow its progress.',
    descriptionAr: 'تم اعتماد طلب الخدمة هذا. افتحه لمتابعة تقدمه.',
    statusCode: 'Milestone',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the approver\'s own timestamp when the cycle recorded one, otherwise on the first timestamp. Kept visible after approval so the cycle stays auditable.',
  ),

  approvalRejected(
    key: 'approval_rejected',
    scope: 'Approvals',
    trigger: 'You Rejected the Request',
    titleEn: 'Request Rejected',
    titleAr: 'تم رفض الطلب',
    descriptionEn:
        'This service request was rejected. Open it to read the remarks.',
    descriptionAr: 'تم رفض طلب الخدمة هذا. افتحه لقراءة الملاحظات.',
    statusCode: 'Milestone',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Same date rule as [approvalApproved]. Kept visible after rejection.',
  ),

  // ── Provider side ─────────────────────────────────────────────────────────

  assignedToProvider(
    key: 'assigned_to_provider',
    scope: 'Provider',
    trigger: 'Request Assigned to You for Fulfilment',
    titleEn: 'New Request Assigned',
    titleAr: 'طلب جديد مسند إليك',
    descriptionEn:
        'This service request was assigned to you. Open it to review the details.',
    descriptionAr: 'تم إسناد طلب الخدمة هذا إليك. افتحه لمراجعة التفاصيل.',
    statusCode: 'Assigned',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Raised for the signed-in user when they are the assigned provider. Placed on the assignment timestamp.',
  ),

  dueForProvider(
    key: 'due_for_provider',
    scope: 'Provider',
    trigger: 'SLA Deadline for a Request Assigned to You',
    titleEn: 'Request Due',
    titleAr: 'موعد تنفيذ الطلب',
    descriptionEn:
        'The SLA deadline for this request is {{dueDate}}. Complete it by then.',
    descriptionAr:
        'موعد إنجاز هذا الطلب حسب المدة المتفق عليها هو {{dueDate}}. أنجزه قبل ذلك.',
    statusCode: 'Due',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.dueDate},
    schedulingNote:
        'Placed on the SLA deadline computed from the assignment date and the service\'s SLA, not on a stored field.',
  ),

  /// ADDED 1/9/2026 — §2 "Service Status Changed to In Progress".
  ///
  /// The spec row says the entry "records the actual start date", and the
  /// provider — the person who performed the status change — had no card on
  /// that date. [dueForProvider] sits on the DEADLINE, so a provider looking
  /// at their calendar could see when a job was due and when it was assigned,
  /// but never when work on it actually started. The requester had that card
  /// ([inProgressForRequester]) and the provider did not.
  inProgressForProvider(
    key: 'in_progress_for_provider',
    scope: 'Provider',
    trigger: 'You Moved the Request to In Progress',
    titleEn: 'Request In Progress',
    titleAr: 'الطلب قيد التنفيذ',
    descriptionEn:
        'You started work on this request. Its SLA deadline is {{dueDate}}.',
    descriptionAr:
        'بدأت العمل على هذا الطلب. موعد إنجازه المتفق عليه {{dueDate}}.',
    // See [inProgressForRequester] — 'InProgress' with no space, because
    // calendar_screen.dart compares `status.toLowerCase() == 'inprogress'`.
    statusCode: 'InProgress',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.dueDate},
    schedulingNote:
        'Placed on the timestamp paired with the first `InProgress` entry in the status history — the real start, not the assignment date and not the deadline.',
  ),

  /// ADDED 1/9/2026 — §2 "Service Completion Date Reached": "all relevant
  /// parties are notified simultaneously".
  ///
  /// Completion was a REQUESTER-ONLY card. The provider who did the work saw
  /// their request vanish from the calendar the moment they closed it —
  /// nothing marked the day it was delivered.
  doneForProvider(
    key: 'done_for_provider',
    scope: 'Provider',
    trigger: 'You Completed the Request',
    titleEn: 'Request Completed',
    titleAr: 'اكتمل الطلب',
    descriptionEn: 'You completed this request. No further action is needed.',
    descriptionAr: 'أنجزت هذا الطلب. لا يلزم أي إجراء آخر.',
    // See [doneForRequester] — matched lowercased by the Duration chip.
    statusCode: 'Done',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the completion timestamp, the same date as [doneForRequester]; the two are the same moment seen from the two sides.',
  ),

  slaBreachedProvider(
    key: 'sla_breached_provider',
    scope: 'Provider',
    trigger: 'SLA Deadline Passed — Request Still Open',
    titleEn: 'SLA Breached',
    titleAr: 'تجاوز مدة الخدمة',
    descriptionEn:
        'This request missed its SLA deadline. If it is still open, complete it and inform the requester.',
    descriptionAr:
        'تجاوز هذا الطلب مدة الخدمة المتفق عليها. إن كان مفتوحاً فأنجزه وأبلغ مقدم الطلب.',
    statusCode: 'SLA',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the breached deadline itself, so the card sits on the date the commitment was missed rather than today.',
  ),

  // ── Requester side ────────────────────────────────────────────────────────

  inProgressForRequester(
    key: 'in_progress_for_requester',
    scope: 'Requester',
    trigger: 'Your Request Moved to In Progress',
    titleEn: 'Request In Progress',
    titleAr: 'طلبك قيد التنفيذ',
    descriptionEn:
        'Work started on your request. The expected completion is {{dueDate}}.',
    descriptionAr: 'بدأ العمل على طلبك. موعد الإنجاز المتوقع {{dueDate}}.',
    // ⚠️ 'InProgress', not 'In Progress'. calendar_screen.dart buckets
    // `status.toLowerCase() == 'inprogress'` under the Duration chip; a space
    // would fail that comparison and drop the card out of every filter.
    statusCode: 'InProgress',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.dueDate},
    schedulingNote:
        'Spans from the in-progress timestamp to the SLA deadline; the card is placed on the start and the deadline is carried in the body.',
  ),

  doneForRequester(
    key: 'done_for_requester',
    scope: 'Requester',
    trigger: 'Your Request Completed Within SLA',
    titleEn: 'Request Completed',
    titleAr: 'اكتمل طلبك',
    descriptionEn:
        'Your request was completed on time. Review the result and contact the team if you need more.',
    descriptionAr:
        'تم إنجاز طلبك في الوقت المحدد. راجع النتيجة وتواصل مع الفريق إن احتجت المزيد.',
    // See [inProgressForRequester] — 'Done' is matched lowercased and also
    // buckets under the Duration chip.
    statusCode: 'Done',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Chosen over [doneAfterSlaForRequester] when the completion timestamp is on or before the computed SLA deadline.',
  ),

  doneAfterSlaForRequester(
    key: 'done_after_sla_for_requester',
    scope: 'Requester',
    trigger: 'Your Request Completed After the SLA Deadline',
    titleEn: 'Completed Late',
    titleAr: 'اكتمل بعد الموعد',
    descriptionEn:
        'Your request was completed after the agreed time. Review the result and contact the team if needed.',
    descriptionAr:
        'تم إنجاز طلبك بعد الموعد المتفق عليه. راجع النتيجة وتواصل مع الفريق عند الحاجة.',
    statusCode: 'Done',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Same placement as [doneForRequester]; only the wording differs, chosen when the completion timestamp is after the SLA deadline.',
  ),

  slaBreachedRequester(
    key: 'sla_breached_requester',
    scope: 'Requester',
    trigger: 'SLA Deadline Passed on Your Request',
    titleEn: 'Request Delayed',
    titleAr: 'تأخر طلبك',
    descriptionEn:
        'Your request passed its expected time and is still open. Contact the service team for an update.',
    descriptionAr:
        'تجاوز طلبك الموعد المتوقع وما زال مفتوحاً. تواصل مع فريق الخدمة لمعرفة المستجدات.',
    statusCode: 'SLA',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Same breached deadline as [slaBreachedProvider]; raised for the requester instead of the assignee.',
  ),

  // ── Management escalation ─────────────────────────────────────────────────

  slaBreachedManagement(
    key: 'sla_breached_management',
    scope: 'Management',
    trigger: 'SLA Breached on a Request in Your Department',
    titleEn: 'SLA Breached',
    titleAr: 'تجاوز مدة الخدمة',
    descriptionEn:
        'A request in {{departmentName}} passed its SLA deadline. Follow up with the service provider.',
    descriptionAr:
        'تجاوز طلب في {{departmentName}} المدة المتفق عليها. تابع الأمر مع مقدم الخدمة.',
    statusCode: 'SLA',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.departmentName},
    schedulingNote:
        'The escalation copy of [slaBreachedProvider], raised for department management. Carries the department so a manager over several can tell the cards apart.',
  ),

  /// ADDED 1/9/2026 — the management half of §2 "Service Completion Date
  /// Reached", whose note reads "all relevant parties are notified
  /// simultaneously".
  ///
  /// Middle management previously appeared in the Services builder for
  /// exactly one thing: an SLA breach. A manager therefore saw only the
  /// failures in their department and never a completion, which makes the
  /// calendar read as a list of problems rather than a record of work.
  doneForManagement(
    key: 'done_for_management',
    scope: 'Management',
    trigger: 'A Request in Your Department Was Completed',
    titleEn: 'Request Completed',
    titleAr: 'اكتمل طلب',
    descriptionEn: 'A request in {{departmentName}} was completed and closed.',
    descriptionAr: 'تم إنجاز طلب في {{departmentName}} وإغلاقه.',
    statusCode: 'Done',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.departmentName},
    schedulingNote:
        'Same completion timestamp as [doneForRequester] and [doneForProvider]. Raised only when the manager is neither the provider nor the requester, so nobody gets two cards for one completion.',
  );

  const ServicesCalendarEvent({
    required this.key,
    required this.scope,
    required this.trigger,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.statusCode,
    required this.colorValue,
    required this.reminderOffsetDays,
    required this.schedulingNote,
    this.variables = const <TemplateVariable>{},
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

  @override
  AppModule get module => AppModule.services;

  @override
  String get id => '${module.key}_$key';

  static ServicesCalendarEvent? fromKey(String key) {
    for (final ServicesCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
