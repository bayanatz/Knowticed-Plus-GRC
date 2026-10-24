/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_category.dart
/// Purpose: The fixed "By Type" list of the notification inboxes and the rule
///          that puts a stored notification under one or more of them.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// WHY KEYWORDS
/// ------------
/// A stored notification carries its module, its page and its text, but not
/// the event that raised it, so there is no stored category to read. Until the
/// sender writes one, the category is worked out from the module key and the
/// English title/body (always stored in English, see
/// `notification_data_model.dart`). One notification can fit several
/// categories ("Approval request — due tomorrow"); it passes the filter when
/// ANY of its categories is ticked.
library;

import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';

class NotificationCategory {
  const NotificationCategory(
    this.id,
    this.labelEn,
    this.labelAr, {
    this.words = const <String>[],
    this.modules = const <String>[],
  });

  /// Stable key kept in the filter selection.
  final String id;
  final String labelEn;
  final String labelAr;

  /// Lower-case fragments looked for in the English title + body.
  final List<String> words;

  /// Module keys (substring match) whose notifications always belong here.
  final List<String> modules;

  String label({required bool isArabic}) => isArabic ? labelAr : labelEn;

  /// The owner's list (22/10/2026), in his order.
  static const List<NotificationCategory> all = <NotificationCategory>[
    NotificationCategory('system_alerts', 'System Alerts', 'تنبيهات النظام',
        words: <String>['system alert', 'security', 'outage', 'suspended']),
    NotificationCategory(
        'approval_requests', 'Approval Requests', 'طلبات الموافقة',
        words: <String>[
          'approval request',
          'awaiting your approval',
          'pending your approval',
          'requires your approval',
          'needs your approval',
          'please approve',
          'for your approval',
        ]),
    NotificationCategory(
        'approvals_updates', 'Approvals Updates', 'تحديثات الموافقات',
        words: <String>[
          'has been approved',
          'has been rejected',
          'was approved',
          'was rejected',
          'approved your',
          'rejected your',
          'returned for',
        ]),
    NotificationCategory('assignments', 'Assignments', 'التكليفات',
        words: <String>['assigned', 'assignment', 'reassigned']),
    NotificationCategory('reminders', 'Reminders', 'التذكيرات',
        words: <String>['reminder', 'reminded']),
    NotificationCategory(
        'scheduled_reminders', 'Scheduled Reminders', 'التذكيرات المجدولة',
        words: <String>['scheduled', 'upcoming']),
    NotificationCategory(
        'messages', 'Messages / Announcements', 'الرسائل / الإعلانات',
        words: <String>['announcement', 'new message', 'sent you a message'],
        modules: <String>['messages']),
    NotificationCategory(
        'comments', 'Comments / Mentions', 'التعليقات / الإشارات',
        words: <String>['comment', 'mention', 'replied']),
    NotificationCategory('record_changes', 'Document / Record Changes',
        'تغييرات المستندات / السجلات',
        words: <String>[
          'document',
          'record',
          'policy',
          'version',
          'published',
          'revised',
          'deleted',
          'archived',
        ],
        modules: <String>[
          'knowledge_hub',
          'database'
        ]),
    NotificationCategory(
        'task_updates', 'Task / Workflow Updates', 'تحديثات المهام / سير العمل',
        words: <String>['task', 'to-do', 'workflow', 'status changed'],
        modules: <String>['todo']),
    NotificationCategory('sla_alerts', 'SLA Alerts', 'تنبيهات اتفاقية الخدمة',
        words: <String>['sla']),
    NotificationCategory('due_dates', 'Due Dates', 'تواريخ الاستحقاق',
        words: <String>['due', 'overdue', 'deadline', 'expires', 'expiring']),
    NotificationCategory(
        'compliance_alerts', 'Compliance Alerts', 'تنبيهات الامتثال',
        words: <String>['compliance', 'non-compliant', 'audit', 'control'],
        modules: <String>['grc', 'qiyas']),
    NotificationCategory('risk_warnings', 'Risk Warnings', 'تحذيرات المخاطر',
        words: <String>['risk']),
    NotificationCategory('hr_updates', 'HR Updates', 'تحديثات الموارد البشرية',
        words: <String>['leave', 'payroll', 'onboarding', 'employee record'],
        modules: <String>['hr']),
    NotificationCategory('attendance', 'Attendance Logs', 'سجلات الحضور',
        words: <String>[
          'check-in',
          'check in',
          'checked in',
          'check-out',
          'check out',
          'attendance',
          'clocked'
        ],
        modules: <String>[
          'time_tracker'
        ]),
    NotificationCategory('low_inventory', 'Low Inventory', 'مخزون منخفض',
        words: <String>[
          'low stock',
          'low inventory',
          'reorder',
          'running low'
        ]),
    NotificationCategory('stock_updates', 'Stock Updates', 'تحديثات المخزون',
        words: <String>['stock', 'goods received', 'issued'],
        modules: <String>['inventory']),
    NotificationCategory('maintenance', 'Maintenance Needed', 'صيانة مطلوبة',
        words: <String>['maintenance', 'repair']),
    NotificationCategory('form_submissions', 'Form Submissions', 'نماذج مقدمة',
        words: <String>['submission', 'submitted a form', 'new response'],
        modules: <String>['form_builder']),
    NotificationCategory('role_changes', 'Role Changes', 'تغييرات الأدوار',
        words: <String>['role'], modules: <String>['roles']),
    NotificationCategory('access', 'Access Notifications', 'إشعارات الوصول',
        words: <String>[
          'access',
          'permission',
          'granted',
          'revoked',
          'sign-in',
          'login'
        ]),
    NotificationCategory(
        'user_accounts', 'User Account Updates', 'تحديثات حساب المستخدم',
        words: <String>[
          'account',
          'profile',
          'password',
          'activated',
          'deactivated'
        ]),
    NotificationCategory('events', 'Events', 'الفعاليات',
        words: <String>['event', 'meeting', 'invitation', 'calendar']),
    NotificationCategory('service_closure', 'Service Closure', 'إغلاق الخدمة',
        words: <String>['closed', 'closure', 'resolved', 'completed']),
  ];

  /// Whether [n] belongs under this category.
  bool matches(NotificationModelSystem n) {
    final String module = n.nameOfModule.toLowerCase();
    for (final String m in modules) {
      if (module.contains(m)) return true;
    }
    final String text = '${n.title} ${n.body}'.toLowerCase();
    for (final String w in words) {
      if (text.contains(w)) return true;
    }
    return false;
  }
}
