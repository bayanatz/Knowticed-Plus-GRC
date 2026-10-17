/// Module: notification/clear_page_notification
///
///*************************** FILE INFO ****************************///
/// File Name: cleaned_notification_land_page_state.dart
/// Description: State and UI of the `CleanedNotificationLandPage` widget — split out of `clear_page_notification.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/clear_page_notification.dart';

// Split from clear_page_notification.dart to keep every file under 700 lines.

class _CleanedNotificationLandPageState
    extends State<CleanedNotificationLandPage> {
  final FirestoreNotificationService _notificationService =
      FirestoreNotificationService();

  /// Resolved lazily rather than in a field initializer, so the page can be
  /// built before the GetX bindings have registered it (CR-SKEL-NOTIF-N06).
  MainCoreEmployeeController get _employeeController => Get.find<
      MainCoreEmployeeController>(); // TODO(knowticed, 12/8/2026): inject

  String? _currentUserEmail;
  List<Modules> _allowedModules = [];

  @override
  void initState() {
    super.initState();
    _currentUserEmail = _employeeController.employeeEntity?.email;
    _loadAllowedModules();
  }

  void _loadAllowedModules() {
    List<Modules> allModules = [
      Modules.services,
      Modules.tasks,
      Modules.employees,
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
        // FIXED 22/8/2026: was `updateSelectedIndex(19)` — a raw index into
        // the drawer's permission-filtered module list, which points at a
        // different entry on every tenant. This page is pushed on top of the
        // inbox now, so popping is both correct and layout-independent; the
        // drawer selection is only touched when there is nothing to pop back
        // to (deep link straight into this page).
        // Pops when this page was pushed (mobile), otherwise selects the
        // inbox's shell index. The old fallback resolved
        // Modules.notification, which is the Notification CONTROL page.
        onFirstTap: () => NotificationRouting.backToInbox(context),
        secondTitle: s.cleared,
        child: StreamBuilder<List<NotificationModelSystem>>(
          stream: _notificationService.streamNotificationsForUser(
            _currentUserEmail!,
          ),
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
