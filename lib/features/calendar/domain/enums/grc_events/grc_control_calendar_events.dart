/// Module: calendar / c1_calendar / domain / enums / grc_module
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_control_calendar_events.dart
/// Purpose: The GRC **Control / Control Champion / Control Owner** calendar
///          entries — the date-driven half of those spec sections. Sibling of
///          [GrcModuleCalendarEvent] and [GrcPolicyCalendarEvent], same shape.
/// Author: Knowticed Plus team
/// Created At: 16/9/2026
///
/// SOURCE DATES
/// ------------
/// * Assignment start date  = the control's Start Date (a champion / owner
///   covers a control from the day the control starts).
/// * Submission due date    = the control's End Date — the same date
///   computeAssignmentControlTab uses to decide "Overdue".
/// * Reassignment requests  = the request's own Start / End Date.
///
/// Every entry is DERIVED on read in calendar_data_service
/// (getGrcControlCalendarEvents), so "created immediately" and "existing entry
/// is updated automatically" hold by construction.
///
/// ONE COLOUR FOR GRC: `CalendarModulePalette.grc` (0xFFB5AF3D) on every entry.
///
/// ⚠️ `statusCode` is ENGLISH ONLY — see CalendarEventType.statusCode.
library;

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/calendar_event_type.dart';

enum GrcControlCalendarEvent implements CalendarEventType {
  controlStartDateReached(
    key: 'control_start_date_reached',
    scope: 'GRC Module - Control',
    trigger: 'Control Start Date Reached',
    titleEn: 'Control Active',
    titleAr: 'الضابط مفعّل',
    descriptionEn:
        '{{controlName}} is active from today. Review its details and requirements.',
    descriptionAr:
        'أصبح {{controlName}} مفعّلاً اعتباراً من اليوم. راجع تفاصيله ومتطلباته.',
    statusCode: 'Active',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote:
        'Highlighted on the activation day only — the copy says "today". Audience: the module owners.',
  ),

  championAssignmentStartDateReached(
    key: 'champion_assignment_start_date_reached',
    scope: 'GRC Module – Control Champion',
    trigger: 'Control Assignment Start Date Reached',
    titleEn: 'Assignment Starts',
    titleAr: 'بداية التكليف',
    descriptionEn:
        'You are assigned to {{controlName}} from today. Review the control and its evidence needs.',
    descriptionAr:
        'تم تكليفك بـ{{controlName}} اعتباراً من اليوم. راجع الضابط والأدلة المطلوبة.',
    statusCode: 'Active',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote:
        'Highlighted on the assignment start date (the control start date) for each assigned champion, on that day only.',
  ),

  ownerAssignmentStartDateReached(
    key: 'owner_assignment_start_date_reached',
    scope: 'GRC Module – Control Owner',
    trigger: 'Control Assignment Start Date Reached',
    titleEn: 'Ownership Starts',
    titleAr: 'بداية الملكية',
    descriptionEn:
        'You own {{controlName}} from today. Review the control and its champions.',
    descriptionAr:
        'أصبحت مالك {{controlName}} اعتباراً من اليوم. راجع الضابط وأبطاله.',
    statusCode: 'Active',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote:
        'Highlighted on the assignment start date for each assigned owner, on that day only.',
  ),

  championStartDateDefined(
    key: 'champion_start_date_defined',
    scope: 'GRC Module – Control Champion',
    trigger: 'Control Champion Start Date Defined',
    titleEn: 'Champion Assignment Set',
    titleAr: 'تحديد تكليف البطل',
    descriptionEn:
        'Your assignment to {{controlName}} starts on {{startDate}}. Plan the evidence you will submit.',
    descriptionAr:
        'يبدأ تكليفك بـ{{controlName}} في {{startDate}}. خطّط للأدلة التي ستسلّمها.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.startDate},
    schedulingNote:
        'Created as soon as the champion is assigned; placed on the start date while it is still today or ahead.',
  ),

  championStartDateReached(
    key: 'champion_start_date_reached',
    scope: 'GRC Module – Control Champion',
    trigger: 'Control Champion Start Date Reached',
    titleEn: 'Champion Starts Today',
    titleAr: 'بدء مهام البطل اليوم',
    descriptionEn:
        'You start as Champion of {{controlName}} today. Submit evidence by its due date.',
    descriptionAr:
        'تبدأ اليوم مهامك كبطل لـ{{controlName}}. سلّم الأدلة قبل موعدها.',
    statusCode: 'Active',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote:
        'Highlighted on the start date. Emitted for approved reassignment requests (the regular path uses championAssignmentStartDateReached, which is the same moment).',
  ),

  submissionDueDateDefined(
    key: 'submission_due_date_defined',
    scope: 'GRC Module – Control Champion',
    trigger: 'Submission Due Date Defined',
    titleEn: 'Evidence Due Date Set',
    titleAr: 'تحديد موعد الأدلة',
    descriptionEn:
        'Evidence for {{controlName}} is due on {{dueDate}}. Submit it by that date.',
    descriptionAr:
        'موعد تسليم أدلة {{controlName}} هو {{dueDate}}. سلّمها قبل هذا التاريخ.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.dueDate},
    schedulingNote:
        'Placed on the submission due date (the control end date) as soon as it exists; hidden once evidence is submitted.',
  ),

  submissionDueIn14Days(
    key: 'submission_due_in_14_days',
    scope: 'GRC Module – Control Champion',
    trigger: 'Submission Due in 14 Days',
    titleEn: 'Evidence Due Soon',
    titleAr: 'اقتراب موعد الأدلة',
    descriptionEn:
        'Evidence for {{controlName}} is due in 14 days, on {{dueDate}}. Start preparing it now.',
    descriptionAr:
        'موعد تسليم أدلة {{controlName}} بعد 14 يوماً، في {{dueDate}}. ابدأ بتجهيزها الآن.',
    statusCode: 'Reminder',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: -14,
    variables: {TemplateVariable.controlName, TemplateVariable.dueDate},
    schedulingNote:
        'Placed 14 days before the due date; skipped when that day has passed or evidence is already submitted.',
  ),

  submissionDueToday(
    key: 'submission_due_today',
    scope: 'GRC Module – Control Champion',
    trigger: 'Submission Due Date Reached',
    titleEn: 'Evidence Due Today',
    titleAr: 'موعد الأدلة اليوم',
    descriptionEn:
        'Evidence for {{controlName}} is due today. Submit it today to avoid a delay.',
    descriptionAr:
        'موعد تسليم أدلة {{controlName}} اليوم. سلّمها اليوم لتجنب التأخير.',
    statusCode: 'Due Today',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.dueDate},
    schedulingNote:
        'Highlighted on the due date itself, only on that day and only while nothing is submitted.',
  ),

  submissionOverdue(
    key: 'submission_overdue',
    scope: 'GRC Module – Control Champion',
    trigger: 'Submission Due Date Passed',
    titleEn: 'Evidence Overdue',
    titleAr: 'تأخر تسليم الأدلة',
    descriptionEn:
        'Evidence for {{controlName}} was due on {{dueDate}}. Submit it as soon as possible.',
    descriptionAr:
        'كان موعد تسليم أدلة {{controlName}} في {{dueDate}}. سلّمها في أقرب وقت.',
    statusCode: 'Overdue',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 1,
    variables: {TemplateVariable.controlName, TemplateVariable.dueDate},
    schedulingNote:
        'Placed on the first day after the due date when no submitted status was recorded.',
  ),

  championStartDateUpdated(
    key: 'champion_start_date_updated',
    scope: 'GRC Module – Control Champion',
    trigger: 'Control Champion Start Date Updated',
    titleEn: 'Start Date Changed',
    titleAr: 'تغيير تاريخ البدء',
    descriptionEn:
        'The start of your assignment to {{controlName}} moved to {{newStartDate}} (was {{oldStartDate}}).',
    descriptionAr:
        'تغيّر بدء تكليفك بـ{{controlName}} إلى {{newStartDate}} بدلاً من {{oldStartDate}}.',
    statusCode: 'Updated',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {
      TemplateVariable.controlName,
      TemplateVariable.oldStartDate,
      TemplateVariable.newStartDate
    },
    schedulingNote:
        'Placed on the NEW start date; the old date stops producing cards by construction (derived on read).',
  ),

  submissionDueDateUpdated(
    key: 'submission_due_date_updated',
    scope: 'GRC Module – Control Champion',
    trigger: 'Submission Due Date Updated',
    titleEn: 'Due Date Changed',
    titleAr: 'تغيير موعد التسليم',
    descriptionEn:
        'The evidence due date of {{controlName}} moved to {{newEndDate}} (was {{oldEndDate}}).',
    descriptionAr:
        'تغيّر موعد تسليم أدلة {{controlName}} إلى {{newEndDate}} بدلاً من {{oldEndDate}}.',
    statusCode: 'Updated',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {
      TemplateVariable.controlName,
      TemplateVariable.oldEndDate,
      TemplateVariable.newEndDate
    },
    schedulingNote:
        'Placed on the NEW due date; derived on read like every GRC entry.',
  ),

  championReassignmentPending(
    key: 'champion_reassignment_pending',
    scope: 'GRC Module – Control Champion Request',
    trigger: 'Reassignment Request Submitted',
    titleEn: 'Champion Reassignment Pending',
    titleAr: 'إعادة تكليف البطل قيد الاعتماد',
    descriptionEn:
        '{{requesterName}} asked to reassign {{controlName}} from {{startDate}}. Approve or reject the request.',
    descriptionAr:
        'طلب {{requesterName}} إعادة تكليف {{controlName}} اعتباراً من {{startDate}}. اعتمد الطلب أو ارفضه.',
    statusCode: 'Pending',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {
      TemplateVariable.requesterName,
      TemplateVariable.controlName,
      TemplateVariable.startDate
    },
    schedulingNote:
        'For the approvers (module owners) while the request is pending, placed on the requested start date — the day the decision is needed by.',
  ),

  championReassignmentApproved(
    key: 'champion_reassignment_approved',
    scope: 'GRC Module – Control Champion Request',
    trigger: 'Reassignment Request Approved',
    titleEn: 'Reassignment Approved',
    titleAr: 'اعتماد إعادة التكليف',
    descriptionEn:
        'Your reassignment was approved. You become Champion of {{controlName}} on {{startDate}}.',
    descriptionAr:
        'تم اعتماد إعادة التكليف. تصبح بطل {{controlName}} في {{startDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.startDate},
    schedulingNote:
        'For the newly assigned champion, on the approved start date while it is today or ahead.',
  ),

  championAssignmentEndsToday(
    key: 'champion_assignment_ends_today',
    scope: 'GRC Module – Control Champion Request',
    trigger: 'Control Champion Assignment Ends Today',
    titleEn: 'Assignment Ends Today',
    titleAr: 'انتهاء التكليف اليوم',
    descriptionEn:
        'Your assignment to {{controlName}} ends today. Hand over any open work.',
    descriptionAr:
        'ينتهي اليوم تكليفك بـ{{controlName}}. سلّم أي أعمال مفتوحة.',
    statusCode: 'Expiring',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote: 'For the assigned champion, on the approved end date only.',
  ),

  ownerStartDateDefined(
    key: 'owner_start_date_defined',
    scope: 'GRC Module – Control Owner',
    trigger: 'Control Owner Start Date Defined',
    titleEn: 'Ownership Set',
    titleAr: 'تحديد الملكية',
    descriptionEn:
        'You become owner of {{controlName}} on {{startDate}}. Review the control and its champions.',
    descriptionAr:
        'تصبح مالك {{controlName}} في {{startDate}}. راجع الضابط وأبطاله.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.startDate},
    schedulingNote:
        'Created as soon as the owner is assigned; placed on the start date while it is today or ahead.',
  ),

  ownerStartDateReached(
    key: 'owner_start_date_reached',
    scope: 'GRC Module – Control Owner',
    trigger: 'Control Owner Start Date Reached',
    titleEn: 'Ownership Starts Today',
    titleAr: 'بدء الملكية اليوم',
    descriptionEn:
        'You are owner of {{controlName}} from today. Review the control and its champions.',
    descriptionAr:
        'أنت مالك {{controlName}} اعتباراً من اليوم. راجع الضابط وأبطاله.',
    statusCode: 'Active',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote:
        'Highlighted on the start date. Emitted for approved reassignment requests (the regular path uses ownerAssignmentStartDateReached).',
  ),

  ownerStartDateUpdated(
    key: 'owner_start_date_updated',
    scope: 'GRC Module – Control Owner',
    trigger: 'Control Owner Start Date Updated',
    titleEn: 'Start Date Changed',
    titleAr: 'تغيير تاريخ البدء',
    descriptionEn:
        'The start of your ownership of {{controlName}} moved to {{newStartDate}} (was {{oldStartDate}}).',
    descriptionAr:
        'تغيّر بدء ملكيتك لـ{{controlName}} إلى {{newStartDate}} بدلاً من {{oldStartDate}}.',
    statusCode: 'Updated',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {
      TemplateVariable.controlName,
      TemplateVariable.oldStartDate,
      TemplateVariable.newStartDate
    },
    schedulingNote: 'Placed on the NEW start date.',
  ),

  ownerReassignmentPending(
    key: 'owner_reassignment_pending',
    scope: 'GRC Module – Control Owner Request',
    trigger: 'Reassignment Request Submitted',
    titleEn: 'Owner Reassignment Pending',
    titleAr: 'إعادة تكليف المالك قيد الاعتماد',
    descriptionEn:
        '{{requesterName}} asked to reassign {{controlName}} from {{startDate}}. Approve or reject the request.',
    descriptionAr:
        'طلب {{requesterName}} إعادة تكليف {{controlName}} اعتباراً من {{startDate}}. اعتمد الطلب أو ارفضه.',
    statusCode: 'Pending',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {
      TemplateVariable.requesterName,
      TemplateVariable.controlName,
      TemplateVariable.startDate
    },
    schedulingNote:
        'For the approvers while pending, on the requested start date.',
  ),

  ownerReassignmentApproved(
    key: 'owner_reassignment_approved',
    scope: 'GRC Module – Control Owner Request',
    trigger: 'Reassignment Request Approved',
    titleEn: 'Reassignment Approved',
    titleAr: 'اعتماد إعادة التكليف',
    descriptionEn:
        'Your reassignment was approved. You become owner of {{controlName}} on {{startDate}}.',
    descriptionAr:
        'تم اعتماد إعادة التكليف. تصبح مالك {{controlName}} في {{startDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.startDate},
    schedulingNote:
        'For the newly assigned owner, on the approved start date while it is today or ahead.',
  ),

  ownerAssignmentEndsToday(
    key: 'owner_assignment_ends_today',
    scope: 'GRC Module – Control Owner Request',
    trigger: 'Control Owner Assignment Ends Today',
    titleEn: 'Ownership Ends Today',
    titleAr: 'انتهاء الملكية اليوم',
    descriptionEn:
        'Your ownership of {{controlName}} ends today. Hand over any open work.',
    descriptionAr:
        'تنتهي اليوم ملكيتك لـ{{controlName}}. سلّم أي أعمال مفتوحة.',
    statusCode: 'Expiring',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote:
        'For the assigned owner, on the approved end date only. (The spec lists this row for champions; owners get the same card for symmetry.)',
  );

  const GrcControlCalendarEvent({
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
    required this.variables,
    required this.schedulingNote,
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
  final Set<TemplateVariable> variables;
  @override
  final String schedulingNote;

  @override
  AppModule get module => AppModule.grc;

  @override
  String get id => '${module.key}_$key';

  static GrcControlCalendarEvent? fromKey(String key) {
    for (final GrcControlCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
