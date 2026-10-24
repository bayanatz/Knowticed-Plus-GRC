/// Module: notification/enums
///
///*************************** FILE INFO ****************************///
/// File Name: grc_event_specs_control_risk.dart
/// Description: `_grcControlWeightIssueResolved` constant, `_grcControlOwnerAssigned` constant, `_grcControlRejected` constant and 38 more — split out of `grc_events.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../grc_events.dart';

// Split from grc_events.dart to keep every file under 700 lines.

const _grcControlWeightIssueResolved = _GrcEventSpec(
  key: 'control_weight_issue_resolved',
  group: 'Policy & Control',
  titleEn: 'Control Weight Issue Resolved',
  titleAr: 'تم حل مشكلة وزن الضابط',
  bodyEn: 'The weight issue affecting {{controlName}} has been resolved.',
  bodyAr: 'تم حل مشكلة وزن الضابط {{controlName}}.',
  variables: {TemplateVariable.controlName},
);

const _grcControlOwnerAssigned = _GrcEventSpec(
  key: 'control_owner_assigned',
  group: 'Policy & Control',
  titleEn: 'Control Ownership Assigned',
  titleAr: 'تم تعيينك مالكًا للضابط',
  bodyEn:
      'You have been assigned as the Control Owner for {{controlName}} under the policy {{policyName}}. You are now responsible for managing, maintaining, and monitoring this control.',
  bodyAr:
      'تم تعيينك مالكًا للضابط {{controlName}} ضمن السياسة {{policyName}}. أصبحت الآن مسؤولًا عن إدارة هذا الضابط وصيانته ومتابعته.',
  variables: {TemplateVariable.controlName, TemplateVariable.policyName},
);

const _grcControlRejected = _GrcEventSpec(
  key: 'control_rejected',
  group: 'Policy & Control',
  titleEn: 'Control Rejected',
  titleAr: 'تم رفض الضابط',
  bodyEn:
      'The control {{controlName}} under the policy {{policyName}} has been rejected . Please review the rejection comments, update the control as required, and resubmit it for approval.',
  bodyAr:
      'تم رفض الضابط {{controlName}} ضمن السياسة {{policyName}} . يرجى مراجعة ملاحظات الرفض، وإجراء التعديلات المطلوبة، ثم إعادة إرساله للموافقة.',
  variables: {TemplateVariable.controlName, TemplateVariable.policyName},
);

const _grcControlChampionAdded = _GrcEventSpec(
  key: 'control_champion_added',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'New Control Champion Assigned',
  titleAr: 'تم تعيين بطل تحكم جديد',
  bodyEn:
      'A new Control Champions  bulk upload has been completed by {{uploadedByUserName}}.',
  bodyAr:
      // Owner 22/10/2026: was a copy of an assignee message ("you were
      // assigned…"); this one is the module owners' bulk-upload summary.
      'تم إكمال استيراد جماعي جديد لأبطال الضوابط بواسطة {{uploadedByUserName}}.',
  variables: {
    TemplateVariable.uploadedByUserName,
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.moduleName
  },
);

const _grcControlChampionAddedBulkUpload = _GrcEventSpec(
  key: 'control_champion_added_bulk_upload',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'New Control Champions Assigned',
  titleAr: 'تم تعيين أبطال ضوابط جدد',
  bodyEn:
      'New Control Champion assignments have been added through a bulk upload by {{userName}} for module {{moduleName}}.',
  bodyAr:
      'تمت إضافة تعيينات جديدة لأبطال الضوابط من خلال استيراد جماعي بواسطة {{userName}} للوحدة {{moduleName}}.',
  variables: {TemplateVariable.userName, TemplateVariable.moduleName},
);

const _grcControlChampionAssignmentStartDateReached = _GrcEventSpec(
  key: 'control_champion_assignment_start_date_reached',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Champion Assignment Started',
  titleAr: 'بدأت مهمة بطل الضبط',
  bodyEn:
      'Your assignment as Control Champion for control {{controlName}} under policy {{policyName}} in module {{moduleName}} starts today.',
  bodyAr:
      'بدأت اليوم مهمتك كبطل ضبط للضبط {{controlName}} ضمن السياسة {{policyName}} في الوحدة {{moduleName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.moduleName
  },
);

const _grcControlChampionSubmissionDueIn14Days = _GrcEventSpec(
  key: 'control_champion_submission_due_in_14_days',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Submission Due Reminder',
  titleAr: 'تذكير بموعد التسليم',
  bodyEn:
      'The submission due date for control {{controlName}} under policy {{policyName}} is on {{dueDate}}. Please complete your submission before the deadline.',
  bodyAr:
      'موعد تسليم الضبط {{controlName}} ضمن السياسة {{policyName}} هو {{dueDate}}. يرجى إكمال التسليم قبل الموعد المحدد.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.dueDate
  },
);

const _grcControlChampionSubmissionDueToday = _GrcEventSpec(
  key: 'control_champion_submission_due_today',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Submission Due Today',
  titleAr: 'موعد التسليم اليوم',
  bodyEn:
      'The submission for control {{controlName}} under policy {{policyName}} is due today ({{dueDate}}).',
  bodyAr:
      'موعد تسليم الضبط {{controlName}} ضمن السياسة {{policyName}} هو اليوم ({{dueDate}}).',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.dueDate
  },
);

const _grcControlChampionSubmissionOverdue = _GrcEventSpec(
  key: 'control_champion_submission_overdue',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Submission Overdue',
  titleAr: 'تجاوز موعد التسليم',
  bodyEn:
      'The submission deadline for control {{controlName}} under policy {{policyName}} has passed on {{dueDate}}.',
  bodyAr:
      'انتهى موعد تسليم الضبط {{controlName}} ضمن السياسة {{policyName}} بتاريخ {{dueDate}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.dueDate
  },
);

const _grcControlChampionRemoved = _GrcEventSpec(
  key: 'control_champion_removed',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Champion Assignment Removed',
  titleAr: 'تم إلغاء تعيين بطل التحكم',
  bodyEn:
      'You are no longer assigned as the Control Champion for {{controlName}}.',
  bodyAr: 'لم تعد معينًا كبطل تحكم لعنصر التحكم {{controlName}}.',
  variables: {TemplateVariable.controlName},
);

const _grcReassignmentRequested = _GrcEventSpec(
  key: 'reassignment_requested',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Champion Reassignment Requested',
  titleAr: 'تم إرسال طلب إعادة تعيين',
  bodyEn:
      'A request has been submitted to reassign the Control Champion for {{controlName}} from {{currentChampionName}} to {{newChampionName}}.',
  bodyAr:
      'تم إرسال طلب لإعادة تعيين بطل التحكم لعنصر التحكم {{controlName}} من {{currentChampionName}} إلى {{newChampionName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.currentChampionName,
    TemplateVariable.newChampionName
  },
);

const _grcControlChampionReassignmentRequestSubmitted = _GrcEventSpec(
  key: 'control_champion_reassignment_request_submitted',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Champion Reassignment Approval Required',
  titleAr: 'طلب إعادة تعيين بطل الضبط بانتظار الموافقة',
  bodyEn:
      '{{requesterName}} has submitted a request to reassign Control Champion responsibilities for module {{moduleName}}. Please review the request.',
  bodyAr:
      'قام {{requesterName}} بإرسال طلب لإعادة تعيين بطل الضبط في الوحدة {{moduleName}}. يرجى مراجعة الطلب واتخاذ الإجراء المناسب.',
  variables: {TemplateVariable.requesterName, TemplateVariable.moduleName},
);

const _grcControlChampionReassignmentRequestUpdated = _GrcEventSpec(
  key: 'control_champion_reassignment_request_updated',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Champion Reassignment Request Updated',
  titleAr: 'تم تحديث طلب إعادة التعيين',
  bodyEn:
      'The reassignment request submitted by {{requesterName}} for module {{moduleName}} has been updated. Please review the latest changes.',
  bodyAr:
      'تم تحديث طلب إعادة تعيين بطل الضبط المقدم من {{requesterName}} في الوحدة {{moduleName}}. يرجى مراجعة آخر التحديثات.',
  variables: {TemplateVariable.requesterName, TemplateVariable.moduleName},
);

const _grcControlChampionReassignmentApproved = _GrcEventSpec(
  key: 'control_champion_reassignment_approved',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Champion Reassignment Approved',
  titleAr: 'تمت الموافقة على إعادة التعيين',
  bodyEn:
      'The reassignment request for module {{moduleName}} has been approved. {{newChampionName}} has been assigned as the new Control Champion.',
  bodyAr:
      'تمت الموافقة على طلب إعادة تعيين بطل الضبط في الوحدة {{moduleName}}. وتم تعيين {{newChampionName}} كبطل الضبط الجديد.',
  variables: {TemplateVariable.moduleName, TemplateVariable.newChampionName},
);

const _grcControlChampionReassignmentRejected = _GrcEventSpec(
  key: 'control_champion_reassignment_rejected',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Champion Reassignment Rejected',
  titleAr: 'تم رفض طلب إعادة التعيين',
  bodyEn:
      'The reassignment request for module {{moduleName}} has been rejected by {{approverName}}. Reason: {{rejectionReason}}.',
  bodyAr:
      'تم رفض طلب إعادة تعيين بطل الضبط في الوحدة {{moduleName}} بواسطة {{approverName}}. سبب الرفض: {{rejectionReason}}.',
  variables: {
    TemplateVariable.moduleName,
    TemplateVariable.approverName,
    TemplateVariable.rejectionReason
  },
);

const _grcControlChampionReassignmentApprovedOldChampion = _GrcEventSpec(
  key: 'control_champion_reassignment_approved_old_champion',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Champion Assignment Removed',
  titleAr: 'تم إنهاء تعيينك كبطل ضبط',
  bodyEn:
      'Your Control Champion assignment for control {{controlName}} under policy {{policyName}} in module {{moduleName}} has ended. Responsibility has been reassigned to {{newChampionName}}.',
  bodyAr:
      'تم إنهاء تعيينك كبطل ضبط للضبط {{controlName}} ضمن السياسة {{policyName}} في الوحدة {{moduleName}}. وتمت إعادة تعيين المسؤولية إلى {{newChampionName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.moduleName,
    TemplateVariable.newChampionName
  },
);

const _grcPolicyAssignmentChangedControlChampion = _GrcEventSpec(
  key: 'policy_assignment_changed_control_champion',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Champion Policy Assignment Updated',
  titleAr: 'تم تحديث تعيين السياسة',
  bodyEn:
      'Your policy assignment has been updated. You are now assigned to {{policyName}} for {{controlName}} in {{moduleName}}.',
  bodyAr:
      'تم تحديث تعيين السياسة الخاصة بك. أصبحت معينًا على السياسة {{policyName}} لعنصر التحكم {{controlName}} ضمن الوحدة {{moduleName}}.',
  variables: {
    TemplateVariable.policyName,
    TemplateVariable.controlName,
    TemplateVariable.moduleName
  },
);

const _grcControlAssignmentChangedControlChampion = _GrcEventSpec(
  key: 'control_assignment_changed_control_champion',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Champion Control Assignment Updated',
  titleAr: 'تم تحديث تعيين عنصر التحكم',
  bodyEn:
      'Your Control Champion assignment has been changed from {{oldControlName}} to {{newControlName}} under {{policyName}}.',
  bodyAr:
      'تم تحديث تعيينك كبطل تحكم من {{oldControlName}} إلى {{newControlName}} ضمن السياسة {{policyName}}.',
  variables: {
    TemplateVariable.oldControlName,
    TemplateVariable.newControlName,
    TemplateVariable.policyName
  },
);

const _grcApprovalRequired = _GrcEventSpec(
  key: 'approval_required',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control champion Reassignment Approval Required',
  titleAr: 'طلب موافقة جديد',
  bodyEn:
      'A request to reassign {{controlName}} has been submitted by {{requesterName}} and requires your approval.',
  bodyAr:
      'تم إرسال طلب من {{requesterName}} لإعادة تعيين عنصر التحكم {{controlName}} ويحتاج إلى موافقتك.',
  variables: {TemplateVariable.controlName, TemplateVariable.requesterName},
);

const _grcRequestApproved = _GrcEventSpec(
  key: 'request_approved',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control champion Reassignment Approved',
  titleAr: 'تمت الموافقة على الطلب',
  bodyEn: 'Your reassignment request for {{controlName}} has been approved.',
  bodyAr: 'تمت الموافقة على طلب إعادة تعيين عنصر التحكم {{controlName}}.',
  variables: {TemplateVariable.controlName},
);

const _grcRequestRejected = _GrcEventSpec(
  key: 'request_rejected',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control champion Reassignment Rejected',
  titleAr: 'تم رفض الطلب',
  bodyEn: 'Your reassignment request for {{controlName}} has been rejected.',
  bodyAr: 'تم رفض طلب إعادة تعيين عنصر التحكم {{controlName}}.',
  variables: {TemplateVariable.controlName},
);

const _grcControlOwnerAssigned2 = _GrcEventSpec(
  key: 'control_owner_assigned_2',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'New Control Owner Assigned',
  titleAr: 'تم تعيين مالك تحكم جديد',
  bodyEn:
      'You have been assigned as the Control Owner for {{controlName}} under {{policyName}} in {{moduleName}}.',
  bodyAr:
      'تم تعيينك كمالك لعنصر التحكم {{controlName}} ضمن السياسة {{policyName}} في الوحدة {{moduleName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.moduleName
  },
);

const _grcControlOwnerAddedBulkUpload = _GrcEventSpec(
  key: 'control_owner_added_bulk_upload',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'New Control Owners Assigned',
  titleAr: 'تم تعيين ملاك ضوابط جدد',
  bodyEn:
      'New Control Owner assignments have been added through a bulk upload by {{userName}} for module {{moduleName}}.',
  bodyAr:
      'تمت إضافة تعيينات جديدة لملاك الضوابط من خلال استيراد جماعي بواسطة {{userName}} للوحدة {{moduleName}}.',
  variables: {TemplateVariable.userName, TemplateVariable.moduleName},
);

const _grcControlOwnerReassignmentRequestSubmitted = _GrcEventSpec(
  key: 'control_owner_reassignment_request_submitted',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Owner Reassignment Approval Required',
  titleAr: 'طلب إعادة تعيين مالك الضبط بانتظار الموافقة',
  bodyEn:
      '{{requesterName}} has submitted a request to reassign Control Owner responsibilities for module {{moduleName}}. Please review the request.',
  bodyAr:
      'قام {{requesterName}} بإرسال طلب لإعادة تعيين مالك الضبط في الوحدة {{moduleName}}. يرجى مراجعة الطلب واتخاذ الإجراء المناسب.',
  variables: {TemplateVariable.requesterName, TemplateVariable.moduleName},
);

const _grcControlOwnerReassignmentRequestUpdated = _GrcEventSpec(
  key: 'control_owner_reassignment_request_updated',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Owner Reassignment Request Updated',
  titleAr: 'تم تحديث طلب إعادة تعيين مالك الضبط',
  bodyEn:
      'The reassignment request submitted by {{requesterName}} for module {{moduleName}} has been updated. Please review the latest changes.',
  bodyAr:
      'تم تحديث طلب إعادة تعيين مالك الضبط المقدم من {{requesterName}} في الوحدة {{moduleName}}. يرجى مراجعة آخر التحديثات.',
  variables: {TemplateVariable.requesterName, TemplateVariable.moduleName},
);

const _grcControlOwnerReassignmentApproved = _GrcEventSpec(
  key: 'control_owner_reassignment_approved',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Owner Reassignment Approved',
  titleAr: 'تمت الموافقة على إعادة تعيين مالك الضبط',
  bodyEn:
      'Your request to reassign the Control Owner for module {{moduleName}} has been approved. {{newOwnerName}} has been assigned as the new Control Owner.',
  bodyAr:
      'تمت الموافقة على طلب إعادة تعيين مالك الضبط في الوحدة {{moduleName}}. وتم تعيين {{newOwnerName}} كمالك الضبط الجديد.',
  variables: {TemplateVariable.moduleName, TemplateVariable.newOwnerName},
);

const _grcControlOwnerReassignmentRejected = _GrcEventSpec(
  key: 'control_owner_reassignment_rejected',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Owner Reassignment Rejected',
  titleAr: 'تم رفض طلب إعادة تعيين مالك الضبط',
  bodyEn:
      'Your request to reassign the Control Owner for module {{moduleName}} has been rejected by {{approverName}}. Reason: {{rejectionReason}}.',
  bodyAr:
      'تم رفض طلب إعادة تعيين مالك الضبط في الوحدة {{moduleName}} بواسطة {{approverName}}. سبب الرفض: {{rejectionReason}}.',
  variables: {
    TemplateVariable.moduleName,
    TemplateVariable.approverName,
    TemplateVariable.rejectionReason
  },
);

const _grcControlOwnerReassignmentApprovedNewOwner = _GrcEventSpec(
  key: 'control_owner_reassignment_approved_new_owner',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'New Control Owner Assigned',
  titleAr: 'تم تعيينك كمالك ضبط جديد',
  bodyEn:
      'You have been assigned as the Control Owner for control {{controlName}} under policy {{policyName}} in module {{moduleName}}.',
  bodyAr:
      'تم تعيينك كمالك للضبط {{controlName}} ضمن السياسة {{policyName}} في الوحدة {{moduleName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.moduleName
  },
);

const _grcControlOwnerReassignmentApprovedOldOwner = _GrcEventSpec(
  key: 'control_owner_reassignment_approved_old_owner',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Owner Assignment Removed',
  titleAr: 'تم إنهاء تعيينك كمالك ضبط',
  bodyEn:
      'Your Control Owner assignment for control {{controlName}} under policy {{policyName}} in module {{moduleName}} has ended. Responsibility has been reassigned to {{newOwnerName}}.',
  bodyAr:
      'تم إنهاء تعيينك كمالك للضبط {{controlName}} ضمن السياسة {{policyName}} في الوحدة {{moduleName}}. وتمت إعادة تعيين المسؤولية إلى {{newOwnerName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.moduleName,
    TemplateVariable.newOwnerName
  },
);

const _grcPolicyAssignmentChangedControlOwner = _GrcEventSpec(
  key: 'policy_assignment_changed_control_owner',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Owner Policy Assignment Updated',
  titleAr: 'تم تحديث تعيين السياسة',
  bodyEn:
      'Your policy assignment has been updated. You are now assigned to {{policyName}} for {{controlName}} in {{moduleName}}.',
  bodyAr:
      'تم تحديث تعيين السياسة الخاصة بك. أصبحت معينًا على السياسة {{policyName}} لعنصر التحكم {{controlName}} ضمن الوحدة {{moduleName}}.',
  variables: {
    TemplateVariable.policyName,
    TemplateVariable.controlName,
    TemplateVariable.moduleName
  },
);

const _grcControlAssignmentChangedControlOwner = _GrcEventSpec(
  key: 'control_assignment_changed_control_owner',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Owner Control Assignment Updated',
  titleAr: 'تم تحديث تعيين عنصر التحكم',
  bodyEn:
      'Your Control Owner assignment has been changed from {{oldControlName}} to {{newControlName}} under {{policyName}}.',
  bodyAr:
      'تم تحديث تعيينك كمالك تحكم من {{oldControlName}} إلى {{newControlName}} ضمن السياسة {{policyName}}.',
  variables: {
    TemplateVariable.oldControlName,
    TemplateVariable.newControlName,
    TemplateVariable.policyName
  },
);

const _grcControlOwnerRemoved = _GrcEventSpec(
  key: 'control_owner_removed',
  group: 'Add Champion Officers & Assign Controls To Their Compliance Officers',
  titleEn: 'Control Owner Assignment Removed',
  titleAr: 'تم إلغاء تعيين مالك التحكم',
  bodyEn:
      'You are no longer assigned as the Control Owner for {{controlName}}.',
  bodyAr: 'لم تعد معينًا كمالك لعنصر التحكم {{controlName}}.',
  variables: {TemplateVariable.controlName},
);

const _grcEvidenceSubmitted = _GrcEventSpec(
  key: 'evidence_submitted',
  group: 'Assignment Controls & Approvals & Audit',
  titleEn: 'Evidence Submitted Successfully',
  titleAr: 'تم إرسال الدليل بنجاح',
  bodyEn:
      'Your evidence for control {{controlName}} has been submitted successfully and is awaiting Department Manager approval.',
  bodyAr:
      'تم إرسال الدليل الخاص بالضبط {{controlName}} بنجاح، وهو الآن بانتظار موافقة مدير الإدارة.',
  variables: {TemplateVariable.controlName},
);

const _grcDepartmentManagerApproved = _GrcEventSpec(
  key: 'department_manager_approved',
  group: 'Assignment Controls & Approvals & Audit',
  titleEn: 'Department Manager Approved',
  titleAr: 'تمت موافقة مدير الإدارة',
  bodyEn:
      'Your evidence for control {{controlName}} has been approved by {{departmentManagerName}} and has been forwarded to {{controlOwnerName}} for final review.',
  bodyAr:
      'تمت الموافقة على الدليل الخاص بالضبط {{controlName}} بواسطة {{departmentManagerName}} وتم إرساله إلى {{controlOwnerName}} للمراجعة النهائية.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.departmentManagerName,
    TemplateVariable.controlOwnerName
  },
);

const _grcDepartmentManagerRejected = _GrcEventSpec(
  key: 'department_manager_rejected',
  group: 'Assignment Controls & Approvals & Audit',
  titleEn: 'Department Manager Rejected',
  titleAr: 'تم رفض الدليل بواسطة مدير الإدارة',
  bodyEn:
      'Your evidence for control {{controlName}} has been rejected by {{departmentManagerName}}. Please review the comments and resubmit.',
  bodyAr:
      'تم رفض الدليل الخاص بالضبط {{controlName}} بواسطة {{departmentManagerName}}. يرجى مراجعة الملاحظات وإعادة الإرسال.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.departmentManagerName
  },
);

const _grcControlOwnerApproved = _GrcEventSpec(
  key: 'control_owner_approved',
  group: 'Assignment Controls & Approvals & Audit',
  titleEn: 'Control Approved',
  titleAr: 'تمت الموافقة على الضبط',
  bodyEn:
      'Your evidence for control {{controlName}} has been approved by {{controlOwnerName}}.',
  bodyAr:
      'تمت الموافقة على الدليل الخاص بالضبط {{controlName}} بواسطة {{controlOwnerName}}.',
  variables: {TemplateVariable.controlName, TemplateVariable.controlOwnerName},
);

const _grcControlOwnerRejected = _GrcEventSpec(
  key: 'control_owner_rejected',
  group: 'Assignment Controls & Approvals & Audit',
  titleEn: 'Control Owner Rejected',
  titleAr: 'تم رفض الدليل بواسطة مالك الضبط',
  bodyEn:
      'Your evidence for control {{controlName}} has been rejected by {{controlOwnerName}}. Please review the comments and resubmit.',
  bodyAr:
      'تم رفض الدليل الخاص بالضبط {{controlName}} بواسطة {{controlOwnerName}}. يرجى مراجعة الملاحظات وإعادة الإرسال.',
  variables: {TemplateVariable.controlName, TemplateVariable.controlOwnerName},
);

const _grcEvidenceWaitingForReview = _GrcEventSpec(
  key: 'evidence_waiting_for_review',
  group: 'Assignment Controls & Approvals & Audit',
  titleEn: 'Evidence Pending Your Approval',
  titleAr: 'دليل بانتظار موافقتك',
  bodyEn:
      '{{controlChampionName}} has submitted evidence for control {{controlName}}. Please review and approve or reject it.',
  bodyAr:
      'قام {{controlChampionName}} بإرسال دليل للضبط {{controlName}}. يرجى مراجعته واتخاذ قرار بالموافقة أو الرفض.',
  variables: {
    TemplateVariable.controlChampionName,
    TemplateVariable.controlName
  },
);

const _grcEvidenceWaitingForFinalApproval = _GrcEventSpec(
  key: 'evidence_waiting_for_final_approval',
  group: 'Assignment Controls & Approvals & Audit',
  titleEn: 'Evidence Pending Final Approval',
  titleAr: 'دليل بانتظار الموافقة النهائية',
  bodyEn:
      'The evidence for control {{controlName}}, submitted by {{controlChampionName}} and approved by {{departmentManagerName}}, is awaiting your final review.',
  bodyAr:
      'الدليل الخاص بالضبط {{controlName}} والمقدم من {{controlChampionName}} بعد موافقة {{departmentManagerName}} بانتظار مراجعتك النهائية.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.controlChampionName,
    TemplateVariable.departmentManagerName
  },
);

const _grcScoreHasBeenAdded = _GrcEventSpec(
  key: 'score_has_been_added',
  group: 'Assignment Controls & Approvals & Audit',
  titleEn: 'Control Score Added',
  titleAr: 'تمت إضافة درجة للضبط',
  bodyEn:
      'A compliance score of {{controlScore}} has been assigned to {{controlName}} by {{controlOwnerName}}.',
  bodyAr:
      'تم إضافة درجة امتثال قدرها {{controlScore}} للضبط {{controlName}} بواسطة {{controlOwnerName}}.',
  variables: {
    TemplateVariable.controlScore,
    TemplateVariable.controlName,
    TemplateVariable.controlOwnerName
  },
);

const _grcScoreHasBeenEdited = _GrcEventSpec(
  key: 'score_has_been_edited',
  group: 'Assignment Controls & Approvals & Audit',
  titleEn: 'Control Score Updated',
  titleAr: 'تم تحديث درجة الضبط',
  bodyEn:
      'The compliance score for {{controlName}} has been updated from {{oldControlScore}} to {{newControlScore}} by {{controlOwnerName}}.',
  bodyAr:
      'تم تحديث درجة امتثال الضبط {{controlName}} من {{oldControlScore}} إلى {{newControlScore}} بواسطة {{controlOwnerName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.oldControlScore,
    TemplateVariable.newControlScore,
    TemplateVariable.controlOwnerName
  },
);
