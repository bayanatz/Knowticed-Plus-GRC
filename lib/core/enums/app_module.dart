/// ************************* FILE INFO ************************* ///
/// File Name: app_module.dart
/// Purpose: The app's functional modules — the ONE list every feature
///          agrees on. Lives in core, not inside a feature, because more
///          than one feature needs it.
///
/// Why shared rather than one enum per feature:
/// a calendar entry and the notification that accompanies it describe the
/// same event in the same module. Two parallel enums would drift, and the
/// Firestore keys would stop matching. One list, one set of keys.
///
/// It used to live in the notification feature as `NotificationModule`,
/// which forced the calendar to import a notification type — wrong
/// direction and a misleading name. `core` depends on no feature, so both
/// features can depend on this without depending on each other.
///
/// ⚠️ [key] is the exact string stored in Firestore (`Name_of_module`, and
/// the `<module>_<event>` template id prefix). Never rename a live key —
/// it orphans every template and notification pointing at it.
///
/// ⚠️ RULE: never write a module name as a raw string ('services', ...).
/// Always use this enum.

enum AppModule {
  knowledgeHub('knowledge_hub', labelEn: 'Knowledge Hub', labelAr: 'مركز المعرفة'),
  todo('todo', labelEn: 'To-Do List', labelAr: 'قائمة المهام'),
  services('services', labelEn: 'Service Management', labelAr: 'إدارة الخدمات'),
  roleManagement('role_management',labelEn: 'Role Management', labelAr: 'إدارة الأدوار'),
  userAccess('user_access', labelEn: 'User Access', labelAr: 'وصول المستخدمين'),
  userManagement('user_management', labelEn: 'User Management & Permissions', labelAr: 'إدارة المستخدمين والصلاحيات'),
  timeTracker('time_tracker',labelEn: 'Time Tracker & Attendance', labelAr: 'تتبع الوقت والحضور'),
  database('database',labelEn: 'Database Management', labelAr: 'إدارة قواعد البيانات'),
  qiyas('qiyas', labelEn: 'Qiyas', labelAr: 'قياس'),
  grc('grc', labelEn: 'GRC', labelAr: 'الحوكمة والمخاطر والامتثال'),
  settings('settings', labelEn: 'Settings', labelAr: 'الإعدادات'),
  notificationControl('notification_control', labelEn: 'Notifications Control', labelAr: 'التحكم في الإشعارات'),
  /// Kept for backwards compatibility with documents already written by
  /// older builds. The spec defines no events for it.
  inventory('inventory', labelEn: 'Inventory', labelAr: 'المخزون');

  const AppModule(
    this.key, {
    required this.labelEn,
    required this.labelAr,
  });

  /// The exact string stored in Firestore / used in template ids.
  final String key;

  /// Tab label in the Notification Control screen.
  final String labelEn;
  final String labelAr;

  String label({required bool isArabic}) => isArabic ? labelAr : labelEn;

  static AppModule? fromKey(String key) {
    for (final m in values) {
      if (m.key == key) return m;
    }
    return null;
  }
}
