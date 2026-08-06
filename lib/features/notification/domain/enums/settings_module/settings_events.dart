/// ************************* FILE INFO *************************
/// File Name: settings_events.dart
/// Module:    Settings
/// Purpose:   Every notification this module can raise, with its default
///            bilingual title/body exactly as specified in
///            "Knowticed Plus — Notification & Validation".
///
/// The enum is the DEFAULT / RESET source only. At runtime
/// AppNotificationSender reads `notification_templates/<module>_<key>`
/// from Firestore first, so any text an admin edits in Notification
/// Control still wins. Editing this file changes the fallback + the
/// "Reset to default" value.
///
/// RULE: never write an event key as a raw string. Use this enum.

import '../notification_event.dart';
import 'package:grc_module/core/enums/app_module.dart';
import 'package:grc_module/core/enums/template_variable.dart';

enum SettingsNotificationEvent implements NotificationEvent {
  personalInformationChangeRequestSubmittedManager(
    key: 'personal_information_change_request_submitted_manager',
    group: 'Personal Information',
    titleEn: 'Personal Information Change Request Pending Review',
    titleAr: 'طلب تعديل البيانات الشخصية بانتظار المراجعة',
    bodyEn: '{{employeeName}} has submitted a request to update their Personal Information. Your review and approval are required.',
    bodyAr: 'قام {{employeeName}} بتقديم طلب لتعديل البيانات الشخصية . يرجى مراجعة الطلب واتخاذ القرار المناسب.',
    variables: {TemplateVariable.employeeName},
  ),
  personalInformationChangeRequestApprovedEmployee(
    key: 'personal_information_change_request_approved_employee',
    group: 'Personal Information',
    titleEn: 'Personal Information Updated Successfully',
    titleAr: 'تم تحديث البيانات الشخصية بنجاح',
    bodyEn: 'Your request to update Personal Information has been approved. Your Personal Information has been updated successfully.',
    bodyAr: 'تمت الموافقة على طلب تعديل  البيانات الشخصية، وتم تحديث بياناتك الشخصية بنجاح.',
    variables: const {},
  ),
  personalInformationChangeRequestRejectedEmployee(
    key: 'personal_information_change_request_rejected_employee',
    group: 'Personal Information',
    titleEn: 'Personal Information Change Request Rejected',
    titleAr: 'تم رفض طلب تعديل البيانات الشخصية',
    bodyEn: 'Your request to update Personal Information has been rejected. Reason: {{rejectionReason}}. Please review the comments and submit a new request if further changes are required.',
    bodyAr: 'تم رفض طلب تعديل البيانات الشخصية. سبب الرفض: {{rejectionReason}}. يرجى مراجعة سبب الرفض وإعادة تقديم الطلب بعد إجراء التعديلات المطلوبة إذا لزم الأمر.',
    variables: {TemplateVariable.rejectionReason},
  ),
  healthInsuranceChangeRequestSubmittedManager(
    key: 'health_insurance_change_request_submitted_manager',
    group: 'Health Insurance',
    titleEn: 'Health Insurance Change Request Pending Review',
    titleAr: 'طلب تعديل بيانات التأمين الصحي بانتظار المراجعة',
    bodyEn: '{{employeeName}} has submitted a request to update their Health Insurance Information. Your review and approval are required before the requested changes can be applied.',
    bodyAr: 'قام {{employeeName}} بتقديم طلب لتعديل بيانات التأمين الصحي. يرجى مراجعة الطلب واتخاذ القرار المناسب قبل تطبيق التعديلات.',
    variables: {TemplateVariable.employeeName},
  ),
  healthInsuranceChangeRequestApprovedEmployee(
    key: 'health_insurance_change_request_approved_employee',
    group: 'Health Insurance',
    titleEn: 'Health Insurance Information Updated Successfully',
    titleAr: 'تم تحديث بيانات التأمين الصحي بنجاح',
    bodyEn: 'Your request to update your Health Insurance Information has been approved. Your changes have been applied successfully.',
    bodyAr: 'تمت الموافقة على طلب تعديل بيانات التأمين الصحي، وتم تطبيق التعديلات بنجاح.',
    variables: const {},
  ),
  healthInsuranceChangeRequestRejectedEmployee(
    key: 'health_insurance_change_request_rejected_employee',
    group: 'Health Insurance',
    titleEn: 'Health Insurance Change Request Rejected',
    titleAr: 'تم رفض طلب تعديل بيانات التأمين الصحي',
    bodyEn: 'Your request to update your Health Insurance Information has been rejected. Reason: {{rejectionReason}}. Please review the comments and submit a new request if additional changes are required.',
    bodyAr: 'تم رفض طلب تعديل بيانات التأمين الصحي. سبب الرفض: {{rejectionReason}}. يرجى مراجعة سبب الرفض وإعادة تقديم الطلب بعد إجراء التعديلات المطلوبة إذا لزم الأمر.',
    variables: {TemplateVariable.rejectionReason},
  ),
  socialInformationPermissionEnabled(
    key: 'social_information_permission_enabled',
    group: 'Social Information',
    titleEn: 'New Social Information Section Available',
    titleAr: 'تم إتاحة قسم جديد في المعلومات الاجتماعية',
    bodyEn: 'A new {{permissionName}} section has been enabled for your profile. Please go to Settings - Social Information and complete the required information.',
    bodyAr: 'تم تفعيل قسم {{permissionName}} في ملفك الشخصي. يرجى الانتقال إلى الإعدادات - المعلومات الاجتماعية وإكمال البيانات المطلوبة.',
    variables: {TemplateVariable.permissionName},
  ),
  companyInformationUpdatedByAdminCompanyManager(
    key: 'company_information_updated_by_admin_company_manager',
    group: 'Company Information',
    titleEn: 'Company Information Updated',
    titleAr: 'تم تحديث بيانات الشركة — يرجى التحقق',
    bodyEn: 'The company information for {{companyName}} has been updated based on your request. Please review the updated information and report any incorrect or missing details.',
    bodyAr: 'تم تحديث بيانات شركة {{companyName}} بناءً على طلبك. يرجى مراجعة البيانات المحدثة والإبلاغ عن أي معلومات غير صحيحة أو ناقصة.',
    variables: {TemplateVariable.companyName},
  ),
  commentsFeedbackSubmitted(
    key: 'comments_feedback_submitted',
    group: 'Comment & Feedback',
    titleEn: 'New Comment & Feedback Received',
    titleAr: 'تم استلام تعليق أو ملاحظة جديدة',
    bodyEn: 'Your {{feedbackType}} has been received successfully. Our team will review your request and keep you updated on its progress.',
    bodyAr: 'تم استلام {{feedbackType}} الخاص بك بنجاح. سيقوم فريقنا بمراجعته وإطلاعك على آخر المستجدات.',
    variables: {TemplateVariable.feedbackType},
  ),
  newCommentFeedbackSubmittedAdmin(
    key: 'new_comment_feedback_submitted_admin',
    group: 'Comment & Feedback',
    titleEn: 'New Comment & Feedback Received',
    titleAr: 'تم استلام تعليق أو ملاحظة جديدة',
    bodyEn: 'A new {{feedbackType}} has been submitted by {{employeeName}} from {{companyName}}. Please review and process the request.',
    bodyAr: 'تم استلام {{feedbackType}} جديدة من {{employeeName}} في {{companyName}}. يرجى مراجعة الطلب واتخاذ الإجراء المناسب.',
    variables: {TemplateVariable.feedbackType, TemplateVariable.employeeName, TemplateVariable.companyName},
  ),
  commentsFeedbackStatusUpdated(
    key: 'comments_feedback_status_updated',
    group: 'Comment & Feedback',
    titleEn: 'Comment & Feedback Status Updated',
    titleAr: 'تم تحديث حالة التعليق أو الملاحظة',
    bodyEn: 'The status of your {{feedbackType}} has been updated to {{status}}.',
    bodyAr: 'تم تحديث حالة {{feedbackType}} إلى {{status}}.',
    variables: {TemplateVariable.feedbackType, TemplateVariable.status},
  ),
  commentsFeedbackReplied(
    key: 'comments_feedback_replied',
    group: 'Comment & Feedback',
    titleEn: 'New Reply on Your Comment & Feedback',
    titleAr: 'تم الرد على تعليقك أو ملاحظتك',
    bodyEn: 'Your {{feedbackType}} has received a new reply from the support team. Please review the response in the Comments & Feedback section.',
    bodyAr: 'تم الرد على {{feedbackType}} الخاصة بك من قبل فريق الدعم. يرجى مراجعة الرد في قسم التعليقات والملاحظات.',
    variables: {TemplateVariable.feedbackType},
  ),
  aboutThisAppUpdated(
    key: 'about_this_app_updated',
    group: 'Comment & Feedback',
    titleEn: 'About This App Updated',
    titleAr: 'تم تحديث معلومات التطبيق',
    bodyEn: 'The About This App information has been updated. Please review the latest application information.',
    bodyAr: 'تم تحديث معلومات حول التطبيق. يرجى مراجعة أحدث المعلومات .',
    variables: const {},
  ),
  privacyPolicyUpdated(
    key: 'privacy_policy_updated',
    group: 'Comment & Feedback',
    titleEn: 'Privacy Policy Updated',
    titleAr: 'تم تحديث سياسة الخصوصية',
    bodyEn: 'The Privacy Policy has been updated. Please review the latest privacy terms.',
    bodyAr: 'تم تحديث سياسة الخصوصية. يرجى مراجعة أحدث بنود سياسة الخصوصية.',
    variables: const {},
  ),
  termsConditionsUpdated(
    key: 'terms_conditions_updated',
    group: 'Comment & Feedback',
    titleEn: 'Terms & Conditions Updated',
    titleAr: 'تم تحديث الشروط والأحكام',
    bodyEn: 'The Terms & Conditions have been updated. Please review the latest terms.',
    bodyAr: 'تم تحديث الشروط والأحكام. يرجى مراجعة أحدث البنود.',
    variables: const {},
  );

  const SettingsNotificationEvent({
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

  /// Sub-section this event belongs to inside the module (may be empty).
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
  AppModule get module => AppModule.settings;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static SettingsNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
