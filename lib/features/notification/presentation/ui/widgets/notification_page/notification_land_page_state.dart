/// Module: notification/notification_page
///
///*************************** FILE INFO ****************************///
/// File Name: notification_land_page_state.dart
/// Description: State and UI of the `NotificationLandPage` widget — split out of `notification_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/notification_page.dart';

// Split from notification_page.dart to keep every file under 700 lines.

class _NotificationLandPageState extends State<NotificationLandPage> {
  final FirestoreNotificationService _notificationService =
      FirestoreNotificationService();
  final MainCoreEmployeeController _employeeController = Get.find<
      MainCoreEmployeeController>(); // TODO(knowticed, 12/8/2026): inject

  String? _currentUserEmail;
  bool _hasMarkedAllAsRead = false;

  /// The inbox stream, opened ONCE. 22/10/2026 — Owner (View lag): it was
  /// created inside build(), so every rebuild of this page dropped the
  /// Firestore listener, opened a new one and flashed the loading spinner.
  Stream<List<NotificationModelSystem>>? _stream;
  List<Modules> _allowedModules = [];

  @override
  void initState() {
    super.initState();
    _currentUserEmail = _employeeController.employeeEntity?.email;
    _loadAllowedModules();
    final String? email = _currentUserEmail;
    if (email != null && email.isNotEmpty) {
      _stream = _notificationService.streamNotificationsForUser(email);
    }

    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      _markAllNotificationsAsRead();
    }
  }

  void _loadAllowedModules() {
    List<Modules> allModules = [
      Modules.services,
      Modules.tasks,
      // REMOVED 26/8/2026: Modules.employees — the "Org Chart" filter chip.
      // This list is what the chip row, the per-chip counts and the chip →
      // module-key lookup all read, so dropping it here removes the chip and
      // its count together. Org Chart notifications still arrive and still
      // show under "All"; they just no longer get a filter of their own.
      Modules.inventory,
      Modules.messages,
      Modules.knowledgeHub,
      Modules.qiyas,
      Modules.formBuilder,
      // CHANGED 9/10/2026 (Time Tracker phase 4): the real module, not the
      // legacy stub — NotificationRouting now resolves `time_tracker` here.
      Modules.timeTracker,
      Modules.todo,
      Modules.grc,
      Modules.database,
      Modules.roles,
      // ADDED 24/8/2026: settings notifications (change request submitted /
      // approved / rejected) store `Name_of_module: 'settings'`. The module was
      // missing from this list, so they landed in "All" with no tab of their
      // own and no way to filter to them. `Modules.settings` is always present
      // in the drawer (AppDrawerCubit adds it unconditionally), so tapping one
      // opens Settings rather than reporting access denied.
      Modules.settings,
    ];

    _allowedModules = allModules.where((module) {
      return _employeeController.hasModuleAccess(module);
    }).toList();
  }

  Future<void> _markAllNotificationsAsRead() async {
    if (_hasMarkedAllAsRead || _currentUserEmail == null) return;
    await _notificationService.markAllAsRead(_currentUserEmail!);
    _hasMarkedAllAsRead = true;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (_currentUserEmail == null || _currentUserEmail!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            S.of(context).userEmailNotFound,
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: s.notifications,
        child: StreamBuilder<List<NotificationModelSystem>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircleProgressMaster.inline(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  // The raw Firestore error is not something a user can
                  // act on; it stays in the console, not on screen.
                  s.errorLoadingNotifications,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.text,
                  ),
                ),
              );
            }

            return _NotificationContent(
              allNotifications: snapshot.data ?? [],
              allowedModules: _allowedModules,
              currentUserEmail: _currentUserEmail!,
              notificationService: _notificationService,
              employeeController: _employeeController,
            );
          },
        ),
      ),
    );
  }
}
