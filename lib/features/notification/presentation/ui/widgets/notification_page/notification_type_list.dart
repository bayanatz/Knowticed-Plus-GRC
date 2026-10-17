/// Module: notification/notification_page
///
///*************************** FILE INFO ****************************///
/// File Name: notification_type_list.dart
/// Description: `notificationTypeList` constant, `notificationTypeListArabic` constant, `_NotificationContent` widget — split out of `notification_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/notification_page.dart';

// Split from notification_page.dart to keep every file under 700 lines.

final List<Map<String, String>> notificationTypeList = [
  {'key': 'approval_requests', 'value': 'Approval Requests'},
  {'key': 'approvals_updates', 'value': 'Approvals Updates'},
  {'key': 'assignments', 'value': 'Assignments'},
  {'key': 'reminders', 'value': 'Reminders'},
  {'key': 'scheduled_reminders', 'value': 'Scheduled Reminders'},
  {'key': 'messages_announcements', 'value': 'Messages / Announcements'},
  {'key': 'comments_mentions', 'value': 'Comments / Mentions'},
  {'key': 'document_record_changes', 'value': 'Document / Record Changes'},
  {'key': 'task_workflow_updates', 'value': 'Task / Workflow Updates'},
  {'key': 'sla_alerts', 'value': 'SLA Alerts'},
  {'key': 'due_dates', 'value': 'Due Dates'},
  {'key': 'compliance_alerts', 'value': 'Compliance Alerts'},
  {'key': 'risk_warnings', 'value': 'Risk Warnings'},
  {'key': 'hr_updates', 'value': 'HR Updates'},
  {'key': 'attendance_logs', 'value': 'Attendance Logs'},
  {'key': 'low_inventory', 'value': 'Low Inventory'},
  {'key': 'stock_updates', 'value': 'Stock Updates'},
  {'key': 'maintenance_needed', 'value': 'Maintenance Needed'},
  {'key': 'form_submissions', 'value': 'Form Submissions'},
  {'key': 'role_changes', 'value': 'Role Changes'},
  {'key': 'access_notifications', 'value': 'Access Notifications'},
  {'key': 'user_account_updates', 'value': 'User Account Updates'},
  {'key': 'events', 'value': 'Events'},
  {'key': 'service_closure', 'value': 'Service Closure'},
];

final List<Map<String, String>> notificationTypeListArabic = [
  {'key': 'approval_requests', 'value': 'طلبات الموافقة'},
  {'key': 'approvals_updates', 'value': 'تحديثات الموافقات'},
  {'key': 'assignments', 'value': 'التعيينات'},
  {'key': 'reminders', 'value': 'التذكيرات'},
  {'key': 'scheduled_reminders', 'value': 'التذكيرات المجدولة'},
  {'key': 'messages_announcements', 'value': 'الرسائل / الإعلانات'},
  {'key': 'comments_mentions', 'value': 'التعليقات / الإشارات'},
  {'key': 'document_record_changes', 'value': 'تغييرات المستندات / السجلات'},
  {'key': 'task_workflow_updates', 'value': 'تحديثات المهام / سير العمل'},
  {'key': 'sla_alerts', 'value': 'تنبيهات اتفاقية مستوى الخدمة'},
  {'key': 'due_dates', 'value': 'تواريخ الاستحقاق'},
  {'key': 'compliance_alerts', 'value': 'تنبيهات الامتثال'},
  {'key': 'risk_warnings', 'value': 'تحذيرات المخاطر'},
  {'key': 'hr_updates', 'value': 'تحديثات الموارد البشرية'},
  {'key': 'attendance_logs', 'value': 'سجلات الحضور'},
  {'key': 'low_inventory', 'value': 'انخفاض المخزون'},
  {'key': 'stock_updates', 'value': 'تحديثات المخزون'},
  {'key': 'maintenance_needed', 'value': 'الصيانة المطلوبة'},
  {'key': 'form_submissions', 'value': 'تقديم النماذج'},
  {'key': 'role_changes', 'value': 'تغييرات الأدوار'},
  {'key': 'access_notifications', 'value': 'إشعارات الوصول'},
  {'key': 'user_account_updates', 'value': 'تحديثات حساب المستخدم'},
  {'key': 'events', 'value': 'الأحداث'},
  {'key': 'service_closure', 'value': 'إغلاق الخدمة'},
];

// ✅ SEPARATE STATEFUL WIDGET FOR CONTENT
class _NotificationContent extends StatefulWidget {
  final List<NotificationModelSystem> allNotifications;
  final List<Modules> allowedModules;
  final String currentUserEmail;
  final FirestoreNotificationService notificationService;
  final MainCoreEmployeeController employeeController;

  const _NotificationContent({
    required this.allNotifications,
    required this.allowedModules,
    required this.currentUserEmail,
    required this.notificationService,
    required this.employeeController,
  });

  @override
  State<_NotificationContent> createState() => _NotificationContentState();
}
