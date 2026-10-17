/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_events.dart
/// Module:    Form Builder
/// Description: Every notification the Form Builder module can raise, with its
///          default bilingual title/body exactly as specified in section 2.3
///          of "Knowticed Plus — Notification & Validation".
/// Author: Amr Mesbah
/// Created at: 12/10/2026
///
/// The enum is the DEFAULT / RESET source only. At runtime
/// AppNotificationSender reads `notification_templates/<module>_<key>` from
/// Firestore first, so any text an admin edits in Notification Control still
/// wins. Editing this file changes the fallback + the "Reset to default" value.
///
/// ─── WHO RECEIVES WHAT ───────────────────────────────────────────────
///   Recipient of the form : formAssigned, accessEndsIn14Days, accessEnded,
///                           endDateUpdated, editPermissionEnabled,
///                           formContentUpdated, formShared, reminderSent
///   Form owner            : submissionReceived, responseResubmitted,
///                           allSubmissionsCompleted
///   Group member          : addedToGroup, removedFromGroup, groupNameUpdated
///
/// Senders live in `data/repository/form_builder_notification_service.dart`.
/// The two time-driven events (accessEndsIn14Days, accessEnded) are raised by
/// `form_builder_notification_scheduler.dart`, because the app has no cron.
///
/// RULE: never write an event key as a raw string. Use this enum.
library;

import 'package:grc_module/features/notification/domain/enums/notification_event.dart';
import 'package:grc_module/core/enums/app_module.dart';
import 'package:grc_module/core/enums/template_variable.dart';

enum FormBuilderNotificationEvent implements NotificationEvent {
  // ── Form access ───────────────────────────────────────────────────────────
  formAssigned(
    key: 'form_assigned',
    group: 'Form Access',
    titleEn: 'New Form Assigned',
    titleAr: 'تم تعيين نموذج جديد لك',
    bodyEn:
        '{{employeeName}} has assigned you the form "{{formName}}". The form will be available until {{accessEndDate}}. Please complete and submit it.',
    bodyAr:
        'قام {{employeeName}} بتعيين النموذج «{{formName}}» لك. سيكون النموذج متاحًا حتى {{accessEndDate}}. يرجى استكماله وإرساله.',
    variables: {
      TemplateVariable.employeeName,
      TemplateVariable.formName,
      TemplateVariable.accessEndDate,
    },
  ),
  accessEndsIn14Days(
    key: 'access_ends_in_14_days',
    group: 'Form Access',
    titleEn: 'Form Access Ends in 14 Days',
    titleAr: 'يتبقى 14 يومًا على انتهاء الوصول',
    bodyEn:
        'Your access to the form "{{formName}}" will end on {{accessEndDate}}. You have 14 days remaining to complete and submit the form.',
    bodyAr:
        'ستنتهي صلاحية وصولك إلى النموذج «{{formName}}» بتاريخ {{accessEndDate}}. يتبقى لديك 14 يومًا لاستكمال النموذج وإرساله.',
    variables: {TemplateVariable.formName, TemplateVariable.accessEndDate},
  ),
  accessEnded(
    key: 'access_ended',
    group: 'Form Access',
    titleEn: 'Form Access Has Ended',
    titleAr: 'انتهت صلاحية الوصول إلى النموذج',
    bodyEn:
        'Your access to the form "{{formName}}" has ended, the form is no longer available for completion or submission.',
    bodyAr:
        'انتهت صلاحية وصولك إلى النموذج «{{formName}}»، ولم يعد النموذج متاحًا للاستكمال أو الإرسال.',
    variables: {TemplateVariable.formName},
  ),
  endDateUpdated(
    key: 'end_date_updated',
    group: 'Form Access',
    titleEn: 'Form Deadline Updated',
    titleAr: 'تم تعديل الموعد النهائي للنموذج',
    bodyEn:
        'The access end date for the form "{{formName}}" has been changed from {{previousAccessEndDate}} to {{newAccessEndDate}}.',
    bodyAr:
        'تم تغيير تاريخ انتهاء الوصول إلى النموذج «{{formName}}» من {{previousAccessEndDate}} إلى {{newAccessEndDate}}.',
    variables: {
      TemplateVariable.formName,
      TemplateVariable.previousAccessEndDate,
      TemplateVariable.newAccessEndDate,
    },
  ),

  // ── Responses ─────────────────────────────────────────────────────────────
  submissionReceived(
    key: 'submission_received',
    group: 'Responses',
    titleEn: 'New Form Submission Received',
    titleAr: 'تم استلام إجابة جديدة',
    bodyEn:
        '{{employeeName}} has submitted a response to the form "{{formName}}" on {{submissionDate}}.',
    bodyAr:
        'قام {{employeeName}} بإرسال إجابته على النموذج «{{formName}}» بتاريخ {{submissionDate}}.',
    variables: {
      TemplateVariable.employeeName,
      TemplateVariable.formName,
      TemplateVariable.submissionDate,
    },
  ),
  editPermissionEnabled(
    key: 'edit_permission_enabled',
    group: 'Responses',
    titleEn: 'Form Response Editing Enabled',
    titleAr: 'تم تفعيل إمكانية تعديل الإجابة',
    bodyEn:
        'The owner has updated the form "{{formName}}" and enabled response editing. You can now review the latest changes and update your submitted response until {{accessEndDate}}.',
    bodyAr:
        'قام مالك النموذج بتحديث النموذج «{{formName}}» وتفعيل إمكانية تعديل الإجابة. يمكنك الآن مراجعة أحدث التعديلات وتحديث إجابتك المرسلة حتى {{accessEndDate}}.',
    variables: {TemplateVariable.formName, TemplateVariable.accessEndDate},
  ),
  responseResubmitted(
    key: 'response_resubmitted',
    group: 'Responses',
    titleEn: 'Response Resubmitted',
    titleAr: 'تمت إعادة إرسال الإجابة',
    bodyEn:
        '{{employeeName}} has resubmitted their response for the form "{{formName}}".',
    bodyAr:
        'قام {{employeeName}} بإعادة إرسال إجابته على النموذج «{{formName}}».',
    variables: {TemplateVariable.employeeName, TemplateVariable.formName},
  ),

  // ── Form updates & sharing ────────────────────────────────────────────────
  formContentUpdated(
    key: 'form_content_updated',
    group: 'Form Updates',
    titleEn: 'Form Updated',
    titleAr: 'تم تحديث النموذج',
    bodyEn:
        'The form "{{formName}}" has been updated by {{ownerName}}. Please review the latest changes.',
    bodyAr:
        'تم تحديث النموذج «{{formName}}» بواسطة {{ownerName}}. يرجى مراجعة أحدث التعديلات.',
    variables: {TemplateVariable.formName, TemplateVariable.ownerName},
  ),
  formShared(
    key: 'form_shared',
    group: 'Form Updates',
    titleEn: 'Form Shared With You',
    titleAr: 'تمت مشاركة نموذج معك',
    bodyEn:
        '{{ownerName}} has shared the form "{{formName}}" with you. You can now access and complete the form before {{accessEndDate}}.',
    bodyAr:
        'قام {{ownerName}} بمشاركة النموذج «{{formName}}» معك. يمكنك الآن الوصول إلى النموذج واستكماله قبل {{accessEndDate}}.',
    variables: {
      TemplateVariable.ownerName,
      TemplateVariable.formName,
      TemplateVariable.accessEndDate,
    },
  ),
  reminderSent(
    key: 'reminder_sent',
    group: 'Form Updates',
    titleEn: 'Form Submission Reminder',
    titleAr: 'تذكير بإرسال النموذج',
    bodyEn:
        'This is a reminder to complete and submit the form "{{formName}}" before {{accessEndDate}}. Please submit your response if you have not already done so.',
    bodyAr:
        'هذا تذكير باستكمال وإرسال النموذج «{{formName}}» قبل {{accessEndDate}}. يرجى إرسال إجابتك إذا لم تكن قد أرسلتها بالفعل.',
    variables: {TemplateVariable.formName, TemplateVariable.accessEndDate},
  ),

  // ── Groups ────────────────────────────────────────────────────────────────
  addedToGroup(
    key: 'added_to_group',
    group: 'Groups',
    titleEn: 'Added to Group',
    titleAr: 'تمت إضافتك إلى مجموعة',
    bodyEn:
        'You have been added to the "{{groupName}}" group by {{ownerName}}. You now have access to any forms and resources shared with this group according to your assigned permissions.',
    bodyAr:
        'تمت إضافتك إلى مجموعة «{{groupName}}» بواسطة {{ownerName}}. أصبح بإمكانك الوصول إلى النماذج والموارد التي تتم مشاركتها مع هذه المجموعة وفقًا للصلاحيات الممنوحة لك.',
    variables: {TemplateVariable.groupName, TemplateVariable.ownerName},
  ),
  removedFromGroup(
    key: 'removed_from_group',
    group: 'Groups',
    titleEn: 'Removed from Group',
    titleAr: 'تمت إزالتك من المجموعة',
    bodyEn:
        'You have been removed from the "{{groupName}}" group by {{ownerName}}. You no longer have access to the forms and resources shared through this group.',
    bodyAr:
        'تمت إزالتك من مجموعة «{{groupName}}» بواسطة {{ownerName}}. لم يعد بإمكانك الوصول إلى النماذج والموارد التي تتم مشاركتها من خلال هذه المجموعة.',
    variables: {TemplateVariable.groupName, TemplateVariable.ownerName},
  ),
  groupNameUpdated(
    key: 'group_name_updated',
    group: 'Groups',
    titleEn: 'Group Name Updated',
    titleAr: 'تم تحديث اسم المجموعة',
    bodyEn:
        'The group "{{oldGroupName}}" has been renamed to "{{newGroupName}}" by {{ownerName}}. Your group membership and access permissions remain unchanged.',
    bodyAr:
        'تم تغيير اسم المجموعة «{{oldGroupName}}» إلى «{{newGroupName}}» بواسطة {{ownerName}}. تظل عضويتك وصلاحيات الوصول الخاصة بك كما هي دون أي تغيير.',
    variables: {
      TemplateVariable.oldGroupName,
      TemplateVariable.newGroupName,
      TemplateVariable.ownerName,
    },
  ),

  // ── Completion ────────────────────────────────────────────────────────────
  allSubmissionsCompleted(
    key: 'all_submissions_completed',
    group: 'Responses',
    titleEn: 'All Responses Received',
    titleAr: 'تم استلام جميع الإجابات',
    bodyEn:
        'All assigned recipients have submitted their responses for the form "{{formName}}". The form is now complete and ready for your review.',
    bodyAr:
        'قام جميع المستلمين المعيّنين بإرسال إجاباتهم على النموذج «{{formName}}». أصبح النموذج الآن مكتملًا وجاهزًا للمراجعة.',
    variables: {TemplateVariable.formName},
  );

  const FormBuilderNotificationEvent({
    required this.key,
    required this.group,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.variables,
  });

  @override
  final String key;

  /// Sub-section this event belongs to inside the module.
  @override
  final String group;

  @override
  final String titleEn;
  @override
  final String titleAr;
  @override
  final String bodyEn;
  @override
  final String bodyAr;
  @override
  final Set<TemplateVariable> variables;

  @override
  AppModule get module => AppModule.formBuilder;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static FormBuilderNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
