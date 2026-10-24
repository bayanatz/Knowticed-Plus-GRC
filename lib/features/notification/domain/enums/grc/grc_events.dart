/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: grc_events.dart
/// Description: GRC notification events.
/// Author: Amr Mesbah
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).
///
/// REMAINING (CR-SKEL-NOTIF-N04): 801 LOC, one over the hard 800 cap.
library;

/// ************************* FILE INFO *************************
/// File Name: grc_events.dart
/// Module:    GRC
/// Description:   Every notification this module can raise, with its default
///            bilingual title/body exactly as specified in
///            "Knowticed Plus — Notification & Validation".
///
/// The enum is the DEFAULT / RESET source only. At runtime
/// AppNotificationSender reads `Modules/notification_templates/<module>/<key>`
/// from Firestore first, so any text an admin edits in Notification
/// Control still wins. Editing this file changes the fallback + the
/// "Reset to default" value.
///
/// RULE: never write an event key as a raw string. Use this enum.

import 'package:knowticed_plus/features/notification/domain/enums/notification_event.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

part 'grc_events/grc_event_spec.dart';
part 'grc_events/grc_event_specs_module_policy.dart';
part 'grc_events/grc_event_specs_control_risk.dart';

enum GrcNotificationEvent implements NotificationEvent {
  moduleCreated(_grcModuleCreated),
  moduleOwnerAssigned(_grcModuleOwnerAssigned),
  moduleOwnerChanged(_grcModuleOwnerChanged),
  activationDateUpdated(_grcActivationDateUpdated),
  activationDateToday(_grcActivationDateToday),
  moduleUpdatedEdited(_grcModuleUpdatedEdited),
  moduleStatusChangedActivated(_grcModuleStatusChangedActivated),
  moduleStatusChangedDeactivated(_grcModuleStatusChangedDeactivated),
  moduleDeleted(_grcModuleDeleted),
  moduleRestored(_grcModuleRestored),
  moduleRemovedFromDepartment(_grcModuleRemovedFromDepartment),
  policyCreated(_grcPolicyCreated),
  newPoliciesAddedBulkUpload(_grcNewPoliciesAddedBulkUpload),
  policyUpdatedEdited(_grcPolicyUpdatedEdited),
  policyScheduledForActivation(_grcPolicyScheduledForActivation),
  policyActivationDateUpdated(_grcPolicyActivationDateUpdated),
  e14DaysBeforePolicyStartDate(_grcE14DaysBeforePolicyStartDate),
  policyActivationDateToday(_grcPolicyActivationDateToday),
  e14DaysBeforePolicyExpirationDate(_grcE14DaysBeforePolicyExpirationDate),
  policyEndDateUpdated(_grcPolicyEndDateUpdated),
  policyExpired(_grcPolicyExpired),
  policyWeightUpdated(_grcPolicyWeightUpdated),
  policyDeleted(_grcPolicyDeleted),
  policyActivated(_grcPolicyActivated),
  policyDeactivated(_grcPolicyDeactivated),
  policyWeightIssueDetected(_grcPolicyWeightIssueDetected),
  policyWeightIssueResolved(_grcPolicyWeightIssueResolved),
  controlAddedToPolicy(_grcControlAddedToPolicy),
  controlAddedToPolicyBulkUpload(_grcControlAddedToPolicyBulkUpload),
  departmentAssignedToControl(_grcDepartmentAssignedToControl),
  controlUpdated(_grcControlUpdated),
  controlDeleted(_grcControlDeleted),
  controlWeightUpdated(_grcControlWeightUpdated),
  controlAssignedToChampion(_grcControlAssignedToChampion),
  controlChampionChangedNewChampion(_grcControlChampionChangedNewChampion),
  controlChampionChangedPreviousChampion(
      _grcControlChampionChangedPreviousChampion),
  controlOwnerChangedNewOwner(_grcControlOwnerChangedNewOwner),
  controlOwnerChangedPreviousOwner(_grcControlOwnerChangedPreviousOwner),
  controlDeactivated(_grcControlDeactivated),
  controlActivated(_grcControlActivated),
  controlWeightIssueDetected(_grcControlWeightIssueDetected),
  controlWeightIssueResolved(_grcControlWeightIssueResolved),
  controlOwnerAssigned(_grcControlOwnerAssigned),
  controlRejected(_grcControlRejected),
  controlChampionAdded(_grcControlChampionAdded),
  controlChampionAddedBulkUpload(_grcControlChampionAddedBulkUpload),
  controlChampionAssignmentStartDateReached(
      _grcControlChampionAssignmentStartDateReached),
  controlChampionSubmissionDueIn14Days(
      _grcControlChampionSubmissionDueIn14Days),
  controlChampionSubmissionDueToday(_grcControlChampionSubmissionDueToday),
  controlChampionSubmissionOverdue(_grcControlChampionSubmissionOverdue),
  controlChampionRemoved(_grcControlChampionRemoved),
  reassignmentRequested(_grcReassignmentRequested),
  controlChampionReassignmentRequestSubmitted(
      _grcControlChampionReassignmentRequestSubmitted),
  controlChampionReassignmentRequestUpdated(
      _grcControlChampionReassignmentRequestUpdated),
  controlChampionReassignmentApproved(_grcControlChampionReassignmentApproved),
  controlChampionReassignmentRejected(_grcControlChampionReassignmentRejected),
  controlChampionReassignmentApprovedOldChampion(
      _grcControlChampionReassignmentApprovedOldChampion),
  policyAssignmentChangedControlChampion(
      _grcPolicyAssignmentChangedControlChampion),
  controlAssignmentChangedControlChampion(
      _grcControlAssignmentChangedControlChampion),
  approvalRequired(_grcApprovalRequired),
  requestApproved(_grcRequestApproved),
  requestRejected(_grcRequestRejected),
  controlOwnerAssigned2(_grcControlOwnerAssigned2),
  controlOwnerAddedBulkUpload(_grcControlOwnerAddedBulkUpload),
  controlOwnerReassignmentRequestSubmitted(
      _grcControlOwnerReassignmentRequestSubmitted),
  controlOwnerReassignmentRequestUpdated(
      _grcControlOwnerReassignmentRequestUpdated),
  controlOwnerReassignmentApproved(_grcControlOwnerReassignmentApproved),
  controlOwnerReassignmentRejected(_grcControlOwnerReassignmentRejected),
  controlOwnerReassignmentApprovedNewOwner(
      _grcControlOwnerReassignmentApprovedNewOwner),
  controlOwnerReassignmentApprovedOldOwner(
      _grcControlOwnerReassignmentApprovedOldOwner),
  policyAssignmentChangedControlOwner(_grcPolicyAssignmentChangedControlOwner),
  controlAssignmentChangedControlOwner(
      _grcControlAssignmentChangedControlOwner),
  controlOwnerRemoved(_grcControlOwnerRemoved),
  evidenceSubmitted(_grcEvidenceSubmitted),
  departmentManagerApproved(_grcDepartmentManagerApproved),
  departmentManagerRejected(_grcDepartmentManagerRejected),
  controlOwnerApproved(_grcControlOwnerApproved),
  controlOwnerRejected(_grcControlOwnerRejected),
  evidenceWaitingForReview(_grcEvidenceWaitingForReview),
  evidenceWaitingForFinalApproval(_grcEvidenceWaitingForFinalApproval),
  scoreHasBeenAdded(_grcScoreHasBeenAdded),
  scoreHasBeenEdited(_grcScoreHasBeenEdited);

  const GrcNotificationEvent(this._spec);

  final _GrcEventSpec _spec;

  @override
  String get key => _spec.key;

  /// Sub-section this event belongs to inside the module (may be empty).
  @override
  String get group => _spec.group;

  @override
  String get titleEn => _spec.titleEn;
  @override
  String get titleAr => _spec.titleAr;
  @override
  String get bodyEn => _spec.bodyEn;
  @override
  String get bodyAr => _spec.bodyAr;
  @override
  Set<TemplateVariable> get variables => _spec.variables;

  @override
  AppModule get module => AppModule.grc;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static GrcNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
