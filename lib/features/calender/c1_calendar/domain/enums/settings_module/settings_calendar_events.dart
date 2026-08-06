/// ************************* FILE INFO *************************
/// File Name: settings_calendar_events.dart
/// Module:    Settings
/// Purpose:   Every calendar entry this module can put on the shared
///            calendar, exactly as specified in "Knowticed Plus —
///            Notification & Validation", Section 2 (Calendar Event
///            Triggers).
///
/// Each value carries its bilingual title, the reminder offset (0 = the
/// event day itself, -14 = the two-week-ahead reminder) and the spec's
/// scheduling note, so calendar_data_service never hardcodes a label,
/// a colour or an offset again.
///
/// RULE: never write a calendar event key or title as a raw string.

import '../calendar_event_type.dart';
import 'package:grc_module/core/enums/app_module.dart';
import 'package:grc_module/core/enums/template_variable.dart';

enum SettingsCalendarEvent implements CalendarEventType {
  personalInformationProfileChangeRequestSubmitted(
    key: 'personal_information_profile_change_request_submitted',
    scope: 'Personal Information',
    trigger: 'Profile Change Request Submitted',
    titleEn: 'Profile Change Request Pending Approval',
    titleAr: 'طلب تعديل البيانات الشخصية بانتظار الموافقة',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar entry is created immediately for the approver when the employee submits the request.',
    variables: const {},
  ),
  personalInformationProfileChangeRequestApproved(
    key: 'personal_information_profile_change_request_approved',
    scope: 'Personal Information',
    trigger: 'Profile Change Request Approved',
    titleEn: 'Profile Change Request Approved',
    titleAr: 'تمت الموافقة على طلب تعديل البيانات',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar event is marked as completed for both the requester and the approver after approval.',
    variables: const {},
  ),
  personalInformationProfileChangeRequestRejected(
    key: 'personal_information_profile_change_request_rejected',
    scope: 'Personal Information',
    trigger: 'Profile Change Request Rejected',
    titleEn: 'Profile Change Request Rejected',
    titleAr: 'تم رفض طلب تعديل البيانات',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar event is marked as completed for both the requester and the approver after rejection.',
    variables: const {},
  ),
  healthInsuranceHealthInsuranceChangeRequestSubmitted(
    key: 'health_insurance_health_insurance_change_request_submitted',
    scope: 'Health Insurance',
    trigger: 'Health Insurance Change Request Submitted',
    titleEn: 'Health Insurance Change Request Pending Approval',
    titleAr: 'طلب تعديل بيانات التأمين الصحي بانتظار الموافقة',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar entry is created immediately for the approver when the employee submits the request.',
    variables: const {},
  ),
  healthInsuranceHealthInsuranceChangeRequestApproved(
    key: 'health_insurance_health_insurance_change_request_approved',
    scope: 'Health Insurance',
    trigger: 'Health Insurance Change Request Approved',
    titleEn: 'Health Insurance Change Request Approved',
    titleAr: 'تمت الموافقة على طلب تعديل بيانات التأمين الصحي',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar event is created for the employee on the approval date and marked as completed.',
    variables: const {},
  ),
  healthInsuranceHealthInsuranceChangeRequestRejected(
    key: 'health_insurance_health_insurance_change_request_rejected',
    scope: 'Health Insurance',
    trigger: 'Health Insurance Change Request Rejected',
    titleEn: 'Health Insurance Change Request Rejected',
    titleAr: 'تم رفض طلب تعديل بيانات التأمين الصحي',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar event is created for the employee on the rejection date and marked as completed.',
    variables: const {},
  ),
  commentsFeedbackCommentFeedbackSubmitted(
    key: 'comments_feedback_comment_feedback_submitted',
    scope: 'Comments & Feedback',
    trigger: 'Comment & Feedback Submitted',
    titleEn: 'New {{feedbackType}} Submitted',
    titleAr: 'تم استلام {{feedbackType}} جديدة',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'A calendar entry is created immediately for the application administrator when a new {FeedbackType} is submitted. The event is tagged with the corresponding feedback category and linked to the submitted item for review.',
    variables: {TemplateVariable.feedbackType},
  ),
  commentsFeedbackReplyAddedToCommentFeedback(
    key: 'comments_feedback_reply_added_to_comment_feedback',
    scope: 'Comments & Feedback',
    trigger: 'Reply Added to Comment & Feedback',
    titleEn: 'New Reply on Your {{feedbackType}}',
    titleAr: 'تم الرد على {{feedbackType}} الخاصة بك',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'A calendar entry is created immediately for the employee whenever the support or administration team posts a new reply on the submitted {FeedbackType}. The event links directly to the conversation.',
    variables: {TemplateVariable.feedbackType},
  ),
  commentsFeedbackCommentFeedbackStatusUpdated(
    key: 'comments_feedback_comment_feedback_status_updated',
    scope: 'Comments & Feedback',
    trigger: 'Comment & Feedback Status Updated',
    titleEn: '{{feedbackType}} Marked as {{status}}',
    titleAr: 'تم تحديث حالة {{feedbackType}} إلى {{status}}',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'A calendar entry is created immediately for the employee when the status of the submitted {FeedbackType} changes. The event is linked to the original feedback and displays the latest status.',
    variables: {TemplateVariable.feedbackType, TemplateVariable.status},
  );

  const SettingsCalendarEvent({
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
    required this.variables,
  });

  @override
  final String key;

  /// Sub-area inside the module (e.g. 'Policy', 'Control Champion').
  /// Empty when the module has no sub-areas.
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
  AppModule get module => AppModule.settings;

  @override
  String get id => '${module.key}_$key';

  static SettingsCalendarEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
