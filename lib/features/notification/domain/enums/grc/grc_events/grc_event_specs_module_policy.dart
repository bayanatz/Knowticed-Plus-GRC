/// Module: notification/enums
///
///*************************** FILE INFO ****************************///
/// File Name: grc_event_specs_module_policy.dart
/// Description: `_grcModuleCreated` constant, `_grcModuleOwnerAssigned` constant, `_grcModuleOwnerChanged` constant and 38 more — split out of `grc_events.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../grc_events.dart';

// Split from grc_events.dart to keep every file under 700 lines.

const _grcModuleCreated = _GrcEventSpec(
  key: 'module_created',
  group: '',
  titleEn: 'New GRC Module Created',
  titleAr: 'تم إنشاء وحدة جديدة',
  bodyEn:
      'The GRC module {{moduleName}} has been successfully created and is now available in the Governance, Risk, and Compliance repository.',
  bodyAr:
      'تم إنشاء وحدة الحوكمة والمخاطر والامتثال {{moduleName}} بنجاح، وهي متاحة الآن ضمن وحدات النظام.',
  variables: {TemplateVariable.moduleName},
);

const _grcModuleOwnerAssigned = _GrcEventSpec(
  key: 'module_owner_assigned',
  group: '',
  titleEn: 'Module Ownership Assigned',
  titleAr: 'تم تعيين مالك للوحدة',
  bodyEn:
      'You have been assigned as the Module Owner for {{moduleName}}. Please review the module information.',
  bodyAr:
      'تم تعيينك كمالك لوحدة {{moduleName}}، وأصبحت مسؤولاً عن إدارتها وصيانتها.',
  variables: {TemplateVariable.moduleName},
);

const _grcModuleOwnerChanged = _GrcEventSpec(
  key: 'module_owner_changed',
  group: '',
  titleEn: 'Module Ownership Updated',
  titleAr: 'تم تغيير مالك الوحدة',
  bodyEn:
      'Module ownership for {{moduleName}} has been reassigned to {{newOwnerName}}. Previous ownership records have been updated accordingly.',
  bodyAr:
      'تم إعادة تعيين ملكية وحدة {{moduleName}} إلى {{newOwnerName}}، وتم تحديث سجلات الملكية وفقًا لذلك.',
  variables: {TemplateVariable.moduleName, TemplateVariable.newOwnerName},
);

const _grcActivationDateUpdated = _GrcEventSpec(
  key: 'activation_date_updated',
  group: '',
  titleEn: 'Module Activation Date Updated',
  titleAr: 'تم تحديث تاريخ التفعيل',
  bodyEn:
      'The activation date for {{moduleName}} has been updated from {{oldDate}} to {{newDate}}. Please review your planned activities accordingly.',
  bodyAr:
      'تم تحديث تاريخ تفعيل وحدة {{moduleName}} من {{oldDate}} إلى {{newDate}}. يرجى مراجعة خطط العمل وفقًا للتاريخ الجديد.',
  variables: {
    TemplateVariable.moduleName,
    TemplateVariable.oldDate,
    TemplateVariable.newDate
  },
);

const _grcActivationDateToday = _GrcEventSpec(
  key: 'activation_date_today',
  group: '',
  titleEn: 'Module Activation Due Today',
  titleAr: 'موعد التفعيل اليوم',
  bodyEn: 'Today is the scheduled activation date for {{moduleName}}.',
  bodyAr: 'اليوم هو تاريخ التفعيل المجدول للوحدة {{moduleName}}.',
  variables: {TemplateVariable.moduleName},
);

const _grcModuleUpdatedEdited = _GrcEventSpec(
  key: 'module_updated_edited',
  group: '',
  titleEn: 'GRC Module Updated',
  titleAr: 'تم تحديث الوحدة',
  bodyEn: 'The information for {{moduleName}} has been updated.',
  bodyAr:
      'تم تحديث بيانات وحدة {{moduleName}} بنجاح، وأصبحت أحدث المعلومات متاحة للمستخدمين المخولين.',
  variables: {TemplateVariable.moduleName},
);

const _grcModuleStatusChangedActivated = _GrcEventSpec(
  key: 'module_status_changed_activated',
  group: '',
  titleEn: 'GRC Module Activated',
  titleAr: 'تم تفعيل الوحدة',
  bodyEn:
      'The status of {{moduleName}} has been changed to Active. The activation has been completed successfully.',
  bodyAr:
      'تم تغيير حالة الوحدة {{moduleName}} إلى نشطة، وتم إكمال عملية التفعيل بنجاح.',
  variables: {TemplateVariable.moduleName},
);

const _grcModuleStatusChangedDeactivated = _GrcEventSpec(
  key: 'module_status_changed_deactivated',
  group: '',
  titleEn: 'GRC Module Deactivated',
  titleAr: 'تم إيقاف الوحدة',
  bodyEn:
      'The status of {{moduleName}} has been changed to Inactive. Users can no longer perform activities within this module until it is reactivated.',
  bodyAr:
      'تم تغيير حالة وحدة {{moduleName}} إلى غير نشطة، ولن يتمكن المستخدمون من استخدامها حتى يتم إعادة تفعيلها.',
  variables: {TemplateVariable.moduleName},
);

const _grcModuleDeleted = _GrcEventSpec(
  key: 'module_deleted',
  group: '',
  titleEn: 'GRC Module Removed',
  titleAr: 'تم حذف الوحدة',
  bodyEn:
      'The GRC module {{moduleName}} has been moved to the Removed Modules section. It can be restored if required.',
  bodyAr:
      'تم نقل وحدة {{moduleName}} إلى قسم الوحدات المحذوفة، ويمكن استعادتها عند الحاجة.',
  variables: {TemplateVariable.moduleName},
);

const _grcModuleRestored = _GrcEventSpec(
  key: 'module_restored',
  group: '',
  titleEn: 'GRC Module Restored',
  titleAr: 'تم استعادة الوحدة',
  bodyEn:
      'The GRC module {{moduleName}} has been successfully restored and is now available again in the system.',
  bodyAr:
      'تم استعادة وحدة {{moduleName}} بنجاح، وأصبحت متاحة مرة أخرى داخل النظام.',
  variables: {TemplateVariable.moduleName},
);

const _grcModuleRemovedFromDepartment = _GrcEventSpec(
  key: 'module_removed_from_department',
  group: '',
  titleEn: 'Module Removed from Your Department',
  titleAr: 'تم نقل الوحدة من إدارتك',
  bodyEn:
      'The GRC module {{moduleName}} has been removed from {{departmentName}} . It is no longer under your department\'s responsibility',
  bodyAr:
      'تم حذف وحدة الحوكمة والمخاطر والامتثال {{moduleName}} من إدارة {{departmentName}}. لم تعد هذه الوحدة ضمن مسؤولية إدارتك.',
  variables: {TemplateVariable.moduleName, TemplateVariable.departmentName},
);

const _grcPolicyCreated = _GrcEventSpec(
  key: 'policy_created',
  group: 'Policy & Control',
  titleEn: 'New Policy Created Successfully',
  titleAr: 'تم إنشاء سياسة جديدة',
  bodyEn:
      'The policy {{policyName}} has been successfully created under the GRC module {{moduleName}}.',
  bodyAr:
      'تم إنشاء السياسة {{policyName}} بنجاح ضمن وحدة الحوكمة {{moduleName}}، وأصبحت متاحة الآن للإدارة والتعيين.',
  variables: {TemplateVariable.policyName, TemplateVariable.moduleName},
);

const _grcNewPoliciesAddedBulkUpload = _GrcEventSpec(
  key: 'new_policies_added_bulk_upload',
  group: 'Policy & Control',
  titleEn: 'New Policies Added (Bulk Upload)',
  titleAr: 'تمت إضافة سياسات جديدة',
  bodyEn:
      'New policies have been added through a bulk upload by {{uploadedByUserName}} under module {{moduleName}}.',
  bodyAr:
      'تمت إضافة سياسات جديدة من خلال استيراد جماعي بواسطة {{uploadedByUserName}} ضمن الوحدة {{moduleName}}.',
  variables: {TemplateVariable.uploadedByUserName, TemplateVariable.moduleName},
);

const _grcPolicyUpdatedEdited = _GrcEventSpec(
  key: 'policy_updated_edited',
  group: 'Policy & Control',
  titleEn: 'Policy Updated',
  titleAr: 'تم تحديث السياسة',
  bodyEn:
      'The policy {{policyName}} has been updated under module {{moduleName}}.',
  bodyAr: 'تم تحديث السياسة {{policyName}} ضمن الوحدة {{moduleName}}.',
  variables: {TemplateVariable.policyName, TemplateVariable.moduleName},
);

const _grcPolicyScheduledForActivation = _GrcEventSpec(
  key: 'policy_scheduled_for_activation',
  group: 'Policy & Control',
  titleEn: 'Policy Activation Scheduled',
  titleAr: 'تم جدولة تفعيل السياسة',
  bodyEn:
      'The policy {{policyName}} has been scheduled to become active on {{startDate}}.',
  bodyAr: 'تم جدولة تفعيل السياسة {{policyName}} بتاريخ {{startDate}}.',
  variables: {TemplateVariable.policyName, TemplateVariable.startDate},
);

const _grcPolicyActivationDateUpdated = _GrcEventSpec(
  key: 'policy_activation_date_updated',
  group: 'Policy & Control',
  titleEn: 'Policy Activation Date Updated',
  titleAr: 'تم تحديث تاريخ التفعيل',
  bodyEn:
      'The activation date of {{policyName}} has been changed from {{oldStartDate}} to {{newStartDate}}.',
  bodyAr:
      'تم تحديث تاريخ تفعيل السياسة {{policyName}} من {{oldStartDate}} إلى {{newStartDate}}.',
  variables: {
    TemplateVariable.policyName,
    TemplateVariable.oldStartDate,
    TemplateVariable.newStartDate
  },
);

const _grcE14DaysBeforePolicyStartDate = _GrcEventSpec(
  key: '14_days_before_policy_start_date',
  group: 'Policy & Control',
  titleEn: 'Upcoming Policy Activation Reminder',
  titleAr: 'تذكير باقتراب تفعيل السياسة',
  bodyEn:
      'The policy {{policyName}} is scheduled to become active in 14 days on {{startDate}}. Please review the policy details and ensure everything is ready before the activation date.',
  bodyAr:
      'سيتم تفعيل السياسة {{policyName}} بعد 14 يومًا بتاريخ {{startDate}}. يرجى مراجعة تفاصيل السياسة ، والتأكد من جاهزية جميع المتطلبات قبل موعد التفعيل.',
  variables: {TemplateVariable.policyName, TemplateVariable.startDate},
);

const _grcPolicyActivationDateToday = _GrcEventSpec(
  key: 'policy_activation_date_today',
  group: 'Policy & Control',
  titleEn: 'Policy Activation Due Today',
  titleAr: 'موعد تفعيل السياسة اليوم',
  bodyEn: 'Today is the scheduled activation date for {{policyName}}.',
  bodyAr: 'اليوم هو موعد تفعيل السياسة {{policyName}}.',
  variables: {TemplateVariable.policyName},
);

const _grcE14DaysBeforePolicyExpirationDate = _GrcEventSpec(
  key: '14_days_before_policy_expiration_date',
  group: 'Policy & Control',
  titleEn: 'Policy Expiration Reminder',
  titleAr: 'تذكير باقتراب انتهاء صلاحية السياسة',
  bodyEn: 'The policy {{policyName}} will expire in 14 days on {{endDate}}.',
  bodyAr:
      'ستنتهي صلاحية السياسة {{policyName}} بعد 14 يومًا بتاريخ {{endDate}}.',
  variables: {TemplateVariable.policyName, TemplateVariable.endDate},
);

const _grcPolicyEndDateUpdated = _GrcEventSpec(
  key: 'policy_end_date_updated',
  group: 'Policy & Control',
  titleEn: 'Policy Expiration Date Updated',
  titleAr: 'تم تحديث تاريخ انتهاء السياسة',
  bodyEn:
      'The expiration date for {{policyName}} has been updated from {{oldEndDate}} to {{newEndDate}}.',
  bodyAr:
      'تم تحديث تاريخ انتهاء صلاحية السياسة {{policyName}} من {{oldEndDate}} إلى {{newEndDate}}.',
  variables: {
    TemplateVariable.policyName,
    TemplateVariable.oldEndDate,
    TemplateVariable.newEndDate
  },
);

const _grcPolicyExpired = _GrcEventSpec(
  key: 'policy_expired',
  group: 'Policy & Control',
  titleEn: 'Policy Expired',
  titleAr: 'انتهت صلاحية السياسة',
  bodyEn:
      'The policy {{policyName}} has reached its expiration date and is now marked as expired. Please review and renew it if required.',
  bodyAr:
      'انتهت صلاحية السياسة {{policyName}}، وتم تصنيفها كمنتهية الصلاحية. يرجى مراجعتها وتجديدها أو استبدالها عند الحاجة.',
  variables: {TemplateVariable.policyName},
);

const _grcPolicyWeightUpdated = _GrcEventSpec(
  key: 'policy_weight_updated',
  group: 'Policy & Control',
  titleEn: 'Policy Weight Updated',
  titleAr: 'تم تحديث وزن السياسة',
  bodyEn: 'The weight of {{policyName}} has been updated.',
  bodyAr: 'تم تحديث وزن السياسة {{policyName}}.',
  variables: {TemplateVariable.policyName},
);

const _grcPolicyDeleted = _GrcEventSpec(
  key: 'policy_deleted',
  group: 'Policy & Control',
  titleEn: 'Policy Removed',
  titleAr: 'تم حذف السياسة',
  bodyEn:
      'The policy {{policyName}} has been removed and moved to the removed policies section.',
  bodyAr: 'تم نقل السياسة {{policyName}} إلى قسم السياسات المحذوفة.',
  variables: {TemplateVariable.policyName},
);

const _grcPolicyActivated = _GrcEventSpec(
  key: 'policy_activated',
  group: 'Policy & Control',
  titleEn: 'Policy Activated',
  titleAr: 'تم تفعيل السياسة',
  bodyEn:
      'The policy {{policyName}} has been activated and is now effective within the organization.',
  bodyAr: 'تم تفعيل السياسة {{policyName}}، وأصبحت سارية داخل المؤسسة.',
  variables: {TemplateVariable.policyName},
);

const _grcPolicyDeactivated = _GrcEventSpec(
  key: 'policy_deactivated',
  group: 'Policy & Control',
  titleEn: 'Policy Deactivated',
  titleAr: 'تم إيقاف السياسة',
  bodyEn:
      'The policy {{policyName}} has been deactivated. It will no longer be available for operational use until it is activated again.',
  bodyAr:
      'تم إيقاف السياسة {{policyName}}، ولن تكون متاحة للاستخدام حتى يتم إعادة تفعيلها.',
  variables: {TemplateVariable.policyName},
);

const _grcPolicyWeightIssueDetected = _GrcEventSpec(
  key: 'policy_weight_issue_detected',
  group: 'Policy & Control',
  titleEn: 'Policy Weight Issue Detected',
  titleAr: 'تم اكتشاف مشكلة في وزن السياسة',
  bodyEn:
      'A weight issue has been identified for {{policyName}}. Please review the policy weight configuration.',
  bodyAr:
      'تم اكتشاف مشكلة في وزن السياسة {{policyName}}. يرجى مراجعة إعدادات الوزن.',
  variables: {TemplateVariable.policyName},
);

const _grcPolicyWeightIssueResolved = _GrcEventSpec(
  key: 'policy_weight_issue_resolved',
  group: 'Policy & Control',
  titleEn: 'Policy Weight Issue Resolved',
  titleAr: 'تم حل مشكلة وزن السياسة',
  bodyEn: 'The weight issue affecting {{policyName}} has been resolved.',
  bodyAr: 'تم حل مشكلة وزن السياسة {{policyName}}.',
  variables: {TemplateVariable.policyName},
);

const _grcControlAddedToPolicy = _GrcEventSpec(
  key: 'control_added_to_policy',
  group: 'Policy & Control',
  titleEn: 'New Control Added',
  titleAr: 'تمت إضافة ضابط جديد',
  bodyEn:
      'A new control {{controlName}} has been added to the policy {{policyName}}. Please review the updated policy configuration if required.',
  bodyAr:
      'تمت إضافة الضابط {{controlName}} إلى السياسة {{policyName}}. يرجى مراجعة السياسة المحدثة عند الحاجة.',
  variables: {TemplateVariable.controlName, TemplateVariable.policyName},
);

const _grcControlAddedToPolicyBulkUpload = _GrcEventSpec(
  key: 'control_added_to_policy_bulk_upload',
  group: 'Policy & Control',
  titleEn: 'Control Added to Policy (bulk upload)',
  titleAr: 'تمت إضافة ضوابط جديدة',
  bodyEn:
      'New controls have been added to the policy {{policyName}} through a bulk upload by {{userName}}. Please review the newly added controls.',
  bodyAr:
      'تمت إضافة ضوابط جديدة  إلى السياسة {{policyName}} من خلال استيراد جماعي بواسطة {{userName}}. يرجى مراجعة الضوابط المضافة حديثًا.',
  variables: {TemplateVariable.policyName, TemplateVariable.userName},
);

const _grcDepartmentAssignedToControl = _GrcEventSpec(
  key: 'department_assigned_to_control',
  group: 'Policy & Control',
  titleEn: 'Department Assigned',
  titleAr: 'تم تعيين قسم للضبط',
  bodyEn:
      'The department {{departmentName}} has been assigned to control {{controlName}} under policy {{policyName}} in module {{moduleName}}.',
  bodyAr:
      'تم تعيين القسم {{departmentName}} للضبط {{controlName}} ضمن السياسة {{policyName}} في الوحدة {{moduleName}}.',
  variables: {
    TemplateVariable.departmentName,
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.moduleName
  },
);

const _grcControlUpdated = _GrcEventSpec(
  key: 'control_updated',
  group: 'Policy & Control',
  titleEn: 'Policy Control Updated',
  titleAr: 'تم تحديث الضابط',
  bodyEn:
      'The control {{controlName}} within {{policyName}} has been updated successfully. The latest configuration is now available.',
  bodyAr:
      'تم تحديث الضابط {{controlName}} ضمن السياسة {{policyName}} بنجاح، وأصبحت أحدث البيانات متاحة.',
  variables: {TemplateVariable.controlName, TemplateVariable.policyName},
);

const _grcControlDeleted = _GrcEventSpec(
  key: 'control_deleted',
  group: 'Policy & Control',
  titleEn: 'Policy Control Removed',
  titleAr: 'تم حذف الضابط',
  bodyEn:
      'The control {{controlName}} has been removed from the policy {{policyName}}. Please ensure this change does not affect compliance requirements.',
  bodyAr:
      'تم حذف الضابط {{controlName}} من السياسة {{policyName}}. يرجى التأكد من أن هذا التغيير لا يؤثر على متطلبات الامتثال.',
  variables: {TemplateVariable.controlName, TemplateVariable.policyName},
);

const _grcControlWeightUpdated = _GrcEventSpec(
  key: 'control_weight_updated',
  group: 'Policy & Control',
  titleEn: 'Control Weight Changed',
  titleAr: 'تم تحديث وزن الضابط',
  bodyEn:
      'The weight of {{controlName}} has been updated from {{oldWeight}} to {{newWeight}} in {{policyName}}.',
  bodyAr:
      'تم تحديث وزن الضابط {{controlName}} من {{oldWeight}} إلى {{newWeight}} ضمن السياسة {{policyName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.oldWeight,
    TemplateVariable.newWeight,
    TemplateVariable.policyName
  },
);

const _grcControlAssignedToChampion = _GrcEventSpec(
  key: 'control_assigned_to_champion',
  group: 'Policy & Control',
  titleEn: 'Control Assigned',
  titleAr: 'تم تعيين ضابط إليك',
  bodyEn:
      'You have been assigned responsibility for the control {{controlName}} within {{policyName}}.',
  bodyAr:
      'تم تعيين مسؤولية الضابط {{controlName}} ضمن السياسة {{policyName}} إليك.',
  variables: {TemplateVariable.controlName, TemplateVariable.policyName},
);

const _grcControlChampionChangedNewChampion = _GrcEventSpec(
  key: 'control_champion_changed_new_champion',
  group: 'Policy & Control',
  titleEn: 'New Control Champion Assigned',
  titleAr: 'تم تعيين بطل ضبط جديد',
  bodyEn:
      'You have been assigned as the Control Champion for {{controlName}} under policy {{policyName}} in module {{moduleName}}.',
  bodyAr:
      'تم تعيينك كبطل الضبط {{controlName}} ضمن السياسة {{policyName}} في الوحدة {{moduleName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.moduleName
  },
);

const _grcControlChampionChangedPreviousChampion = _GrcEventSpec(
  key: 'control_champion_changed_previous_champion',
  group: 'Policy & Control',
  titleEn: 'Control Champion Assignment Removed',
  titleAr: 'تم إلغاء تعيينك كبطل للضبط',
  bodyEn:
      'You are no longer assigned as the Control Champion for {{controlName}} under policy {{policyName}} in module {{moduleName}}.',
  bodyAr:
      'لم تعد معينًا كبطل للضبط {{controlName}} ضمن السياسة {{policyName}} في الوحدة {{moduleName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.moduleName
  },
);

const _grcControlOwnerChangedNewOwner = _GrcEventSpec(
  key: 'control_owner_changed_new_owner',
  group: 'Policy & Control',
  titleEn: 'New Control Owner Assigned',
  titleAr: 'تم تعيين مالك جديد للضبط',
  bodyEn:
      'You have been assigned as the Control Owner for {{controlName}} under policy {{policyName}} in module {{moduleName}}.',
  bodyAr:
      'تم تعيينك كمالك للضبط {{controlName}} ضمن السياسة {{policyName}} في الوحدة {{moduleName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.moduleName
  },
);

const _grcControlOwnerChangedPreviousOwner = _GrcEventSpec(
  key: 'control_owner_changed_previous_owner',
  group: 'Policy & Control',
  titleEn: 'Control Owner Assignment Removed',
  titleAr: 'تم إلغاء تعيينك كمالك للضبط',
  bodyEn:
      'You are no longer assigned as the Control Owner for {{controlName}} under policy {{policyName}} in module {{moduleName}}.',
  bodyAr:
      'لم تعد معينًا كمالك للضبط {{controlName}} ضمن السياسة {{policyName}} في الوحدة {{moduleName}}.',
  variables: {
    TemplateVariable.controlName,
    TemplateVariable.policyName,
    TemplateVariable.moduleName
  },
);

const _grcControlDeactivated = _GrcEventSpec(
  key: 'control_deactivated',
  group: 'Policy & Control',
  titleEn: 'Control Deactivated',
  titleAr: 'تم إيقاف الضابط',
  bodyEn:
      'The control {{controlName}} under the policy {{policyName}} has been deactivated. It will no longer be available for operational use until it is reactivated.',
  bodyAr:
      'تم إيقاف الضابط {{controlName}} ضمن السياسة {{policyName}}، ولن يكون متاحًا للاستخدام حتى يتم إعادة تفعيله.',
  variables: {TemplateVariable.controlName, TemplateVariable.policyName},
);

const _grcControlActivated = _GrcEventSpec(
  key: 'control_activated',
  group: 'Policy & Control',
  titleEn: 'Control Activated Successfully',
  titleAr: 'تم تفعيل الضابط',
  bodyEn:
      'The control {{controlName}} under the policy {{policyName}} has been activated.',
  bodyAr:
      'تم تفعيل الضابط {{controlName}} ضمن السياسة {{policyName}} بنجاح، وأصبح متاحًا للاستخدام في أنشطة الامتثال والحوكمة.',
  variables: {TemplateVariable.controlName, TemplateVariable.policyName},
);

const _grcControlWeightIssueDetected = _GrcEventSpec(
  key: 'control_weight_issue_detected',
  group: 'Policy & Control',
  titleEn: 'Control Weight Issue Detected',
  titleAr: 'تم اكتشاف مشكلة في وزن الضابط',
  bodyEn:
      'A weight issue has been identified for {{controlName}}. Please review the control weight configuration.',
  bodyAr:
      'تم اكتشاف مشكلة في وزن الضابط {{controlName}}. يرجى مراجعة إعدادات الوزن.',
  variables: {TemplateVariable.controlName},
);
