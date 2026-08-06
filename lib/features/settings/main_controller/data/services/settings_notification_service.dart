/// ************************* FILE INFO ************************* ///
/// File Name: settings_notification_service.dart
/// Purpose: ALL notifications sent by the Settings module, as intent-named
///          methods. UI pages and cubits must NOT call
///          AppNotificationSender directly - they call this service.
/// Pattern: One `<module>_notification_service.dart` per module.
///          Mirrors ServicesNotificationService.
///
/// Covers the five Settings areas the spec defines:
///   Personal Information, Health Insurance, Social Information,
///   Company Information, and Comments & Feedback - plus the three
///   legal / app-info broadcasts.

import 'package:grc_module/core/enums/template_variable.dart';
import 'package:grc_module/features/notification/domain/enums/settings_module/settings_events.dart';
import 'package:grc_module/features/notification/domain/enums/settings_module/settings_notification_pages.dart';
import 'package:grc_module/features/notification/services/app_notification_sender.dart';

class SettingsNotificationService {
  SettingsNotificationService._();

  // ═══════════════════════════════════════════════════════════
  // Personal Information
  // ═══════════════════════════════════════════════════════════

  /// The employee submitted a change; the approver must review it.
  /// Template: settings_personal_information_change_request_submitted_manager
  static Future<bool> notifyManagerOfPersonalInfoRequest({
    required String senderEmail,
    required String managerEmail,
    required String employeeName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: SettingsNotificationEvent
          .personalInformationChangeRequestSubmittedManager,
      pageKey: SettingsNotificationPage.previewChangesPage.key,
      senderEmail: senderEmail,
      receiverEmail: managerEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.employeeName: employeeName},
    );
  }

  /// The approver decided. `approved` picks the wording; on rejection the
  /// reason is shown to the employee.
  /// Templates: settings_personal_information_change_request_approved_employee
  ///          / settings_personal_information_change_request_rejected_employee
  static Future<bool> notifyEmployeeOfPersonalInfoDecision({
    required bool approved,
    required String senderEmail,
    required String employeeEmail,
    required bool isArabic,
    String rejectionReason = '',
  }) {
    return AppNotificationSender.sendEvent(
      event: approved
          ? SettingsNotificationEvent
              .personalInformationChangeRequestApprovedEmployee
          : SettingsNotificationEvent
              .personalInformationChangeRequestRejectedEmployee,
      pageKey: SettingsNotificationPage.personalInfoScreen.key,
      senderEmail: senderEmail,
      receiverEmail: employeeEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.rejectionReason: rejectionReason},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Health Insurance
  // ═══════════════════════════════════════════════════════════

  /// Template: settings_health_insurance_change_request_submitted_manager
  static Future<bool> notifyManagerOfHealthInsuranceRequest({
    required String senderEmail,
    required String managerEmail,
    required String employeeName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: SettingsNotificationEvent
          .healthInsuranceChangeRequestSubmittedManager,
      pageKey: SettingsNotificationPage.previewHealthInsuranceChangesPage.key,
      senderEmail: senderEmail,
      receiverEmail: managerEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.employeeName: employeeName},
    );
  }

  /// Templates: settings_health_insurance_change_request_approved_employee
  ///          / settings_health_insurance_change_request_rejected_employee
  static Future<bool> notifyEmployeeOfHealthInsuranceDecision({
    required bool approved,
    required String senderEmail,
    required String employeeEmail,
    required bool isArabic,
    String rejectionReason = '',
  }) {
    return AppNotificationSender.sendEvent(
      event: approved
          ? SettingsNotificationEvent
              .healthInsuranceChangeRequestApprovedEmployee
          : SettingsNotificationEvent
              .healthInsuranceChangeRequestRejectedEmployee,
      pageKey: SettingsNotificationPage.myRequestPage.key,
      senderEmail: senderEmail,
      receiverEmail: employeeEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.rejectionReason: rejectionReason},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Social Information
  // ═══════════════════════════════════════════════════════════

  /// A new social-information section was switched on for this employee and
  /// now needs filling in.
  /// Template: settings_social_information_permission_enabled
  static Future<bool> notifyEmployeeOfSocialSectionEnabled({
    required String senderEmail,
    required String employeeEmail,
    required String permissionName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: SettingsNotificationEvent.socialInformationPermissionEnabled,
      pageKey: SettingsNotificationPage.socialScreen.key,
      senderEmail: senderEmail,
      receiverEmail: employeeEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.permissionName: permissionName},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Company Information
  // ═══════════════════════════════════════════════════════════

  /// The platform admin applied the company manager's requested change.
  /// Template: settings_company_information_updated_by_admin_company_manager
  static Future<bool> notifyCompanyManagerOfCompanyInfoUpdate({
    required String senderEmail,
    required String companyManagerEmail,
    required String companyName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: SettingsNotificationEvent
          .companyInformationUpdatedByAdminCompanyManager,
      pageKey: SettingsNotificationPage.companyInfoScreen.key,
      senderEmail: senderEmail,
      receiverEmail: companyManagerEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.companyName: companyName},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Comments & Feedback
  // ═══════════════════════════════════════════════════════════

  /// Acknowledge to the submitter, then alert the application admins.
  /// [feedbackType] is the category shown in the text, e.g. "Comment",
  /// "Complaint", "Suggestion".
  /// Templates: settings_comments_feedback_submitted
  ///          + settings_new_comment_feedback_submitted_admin
  static Future<void> notifyOfFeedbackSubmitted({
    required String senderEmail,
    required String submitterEmail,
    required String submitterName,
    required String companyName,
    required String feedbackType,
    required Iterable<String> adminEmails,
    required bool isArabic,
  }) async {
    await AppNotificationSender.sendEvent(
      event: SettingsNotificationEvent.commentsFeedbackSubmitted,
      pageKey: SettingsNotificationPage.commentsAndFeedbackScreen.key,
      senderEmail: senderEmail,
      receiverEmail: submitterEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.feedbackType: feedbackType},
    );
    await AppNotificationSender.sendEventToAll(
      event: SettingsNotificationEvent.newCommentFeedbackSubmittedAdmin,
      pageKey: SettingsNotificationPage.commentsAndFeedbackScreen.key,
      senderEmail: senderEmail,
      receiverEmails: adminEmails,
      isArabic: isArabic,
      variables: {
        TemplateVariable.feedbackType: feedbackType,
        TemplateVariable.employeeName: submitterName,
        TemplateVariable.companyName: companyName,
      },
    );
  }

  /// The support team moved the item to a new status.
  /// Template: settings_comments_feedback_status_updated
  static Future<bool> notifySubmitterOfFeedbackStatus({
    required String senderEmail,
    required String submitterEmail,
    required String feedbackType,
    required String status,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: SettingsNotificationEvent.commentsFeedbackStatusUpdated,
      pageKey: SettingsNotificationPage.commentsAndFeedbackScreen.key,
      senderEmail: senderEmail,
      receiverEmail: submitterEmail,
      isArabic: isArabic,
      variables: {
        TemplateVariable.feedbackType: feedbackType,
        TemplateVariable.status: status,
      },
    );
  }

  /// The support team replied on the thread.
  /// Template: settings_comments_feedback_replied
  static Future<bool> notifySubmitterOfFeedbackReply({
    required String senderEmail,
    required String submitterEmail,
    required String feedbackType,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: SettingsNotificationEvent.commentsFeedbackReplied,
      pageKey: SettingsNotificationPage.commentsAndFeedbackScreen.key,
      senderEmail: senderEmail,
      receiverEmail: submitterEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.feedbackType: feedbackType},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // App info and legal documents - broadcasts
  // ═══════════════════════════════════════════════════════════

  /// One of the three read-only documents changed. Broadcast to everyone
  /// who should re-read it.
  ///
  /// [event] must be one of the three document events; the assert stops a
  /// caller from broadcasting an unrelated Settings notification.
  ///
  /// Templates: settings_about_this_app_updated
  ///          / settings_privacy_policy_updated
  ///          / settings_terms_conditions_updated
  static Future<int> broadcastDocumentUpdated({
    required SettingsNotificationEvent event,
    required String senderEmail,
    required Iterable<String> receiverEmails,
    required bool isArabic,
  }) {
    assert(
      const {
        SettingsNotificationEvent.aboutThisAppUpdated,
        SettingsNotificationEvent.privacyPolicyUpdated,
        SettingsNotificationEvent.termsConditionsUpdated,
      }.contains(event),
      '${event.key} is not an app-document update event',
    );
    return AppNotificationSender.sendEventToAll(
      event: event,
      pageKey: event == SettingsNotificationEvent.aboutThisAppUpdated
          ? SettingsNotificationPage.aboutThisAppScreen.key
          : SettingsNotificationPage.privacyStatementPage.key,
      senderEmail: senderEmail,
      receiverEmails: receiverEmails,
      isArabic: isArabic,
    );
  }
}
