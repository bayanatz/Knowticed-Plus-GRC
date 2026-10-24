/// Module: settings/main_controller
///
///************************ FILE INFO ****************************///
/// File Name: settings_screen.dart
/// Purpose: Entry point for the settings screen, mobile and tablet.
/// Author: Amr Mesbah
/// Created at: 10/11/2023
/// Updated: 11/8/2026 - The employee/employeeDirectory globals now delegate to
///          SettingsController; GetBuilder -> BlocBuilder; the try/catch that
///          silently fell back to Get.put removed.
/// Updated: 22/10/2026 - A change-request notification's View opens that
///          request on top of Requests (see [SettingsScreenState._openRecord]).
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/routes/app_routes.dart';
import 'package:knowticed_plus/core/routes/get_pages.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

import 'package:knowticed_plus/features/settings/data/models/employee_directory_model.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/pages/settings_layout.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/settings_notification_record.dart';

/// Resolves the single [SettingsController], registering it on first use.
///
/// FIXED 18/8/2026: this was `_settingsOrNull`, which returned `null` whenever
/// the controller was not yet registered with GetX. That made the `employee`
/// SETTER below a silent no-op: `LoginController.initData` assigns
/// `employee = ...` twice (after `getEmployee`, and on the login-success
/// branch) and both writes were dropped, because `SettingsController` is not
/// created until something calls `Get.put` on it — the run log shows it being
/// created only AFTER `AppDrawerCubit`, i.e. after login had already written.
///
/// The reads then returned `null` for the rest of the session, which is where
/// two crashes came from:
///   * `login_controller.dart` — `employee!.lastLogin = ...`
///     ("Null check operator used on a null value", uncaught async).
///   * `70-custom_appbar.dart` — `employee!.title` while building the
///     AppBar's BlocBuilder.
///
/// Registering lazily makes the store exist before the first write, so the
/// value written at login is the value read afterwards. `SettingsController()`
/// takes no required arguments and does no I/O in its constructor (`init()` is
/// a separate, explicitly-called step), so constructing it here is cheap and
/// has no side effects.
SettingsController get _settings => Get.isRegistered<SettingsController>()
    ? Get.find<SettingsController>()
    : Get.put(SettingsController(), permanent: true);

/// The signed-in employee.
///
/// This used to be a top-level mutable global that 23 files imported and read
/// directly. The value now lives on [SettingsController]; these accessors
/// remain so those call sites keep compiling while they migrate to reading the
/// cubit. Prefer `Get.find<SettingsController>().employee` in new code.
@Deprecated('Read Get.find<SettingsController>().employee instead.')
NewEmployeeModelHistory? get employee => _settings.employee;

@Deprecated('Set SettingsController.employee instead.')
set employee(NewEmployeeModelHistory? value) {
  _settings.employee = value;
}

/// The signed-in employee's directory entry. Same story as [employee].
@Deprecated('Read Get.find<SettingsController>().employeeDirectory instead.')
EmployeeDirectoryModel? get employeeDirectory => _settings.employeeDirectory;

@Deprecated('Set SettingsController.employeeDirectory instead.')
set employeeDirectory(EmployeeDirectoryModel? value) {
  _settings.employeeDirectory = value;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({this.index, this.hasBack = true, super.key});

  /// The section to open on, for a caller that cannot pass [index].
  ///
  /// ADDED 12/9/2026 with the notification deep-link router. The drawer builds
  /// this screen through `Modules.settings.widget`, which is a plain
  /// `SettingsScreen()` with no arguments — so a notification that knows it
  /// belongs on Requests or Personal Information has nowhere to say so. It
  /// leaves the `SettingsController.selectedContainerIndex` here instead, and
  /// [_initializeSettings] consumes and clears it on the next build.
  ///
  /// Same shape as `RoleScreenHost.pendingInitialTab`, which the inbox has
  /// used for the roles tabs since 22/8/2026. [index] still wins when a caller
  /// passes one — this is the fallback, not an override.
  ///
  /// ⚠️ Cleared on read, whether or not it was used. A hint left armed would
  /// hijack the next unrelated visit to Settings.
  static int? pendingInitialIndex;

  final int? index;

  /// Was a mutable public field; widget fields must be final.
  final bool hasBack;

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  /// Navigator key for the tablet-side nested navigator below. One per screen:
  /// it was a single top-level key, so a second Settings screen alive at the
  /// same time (side menu + header gear) logged "Multiple widgets used the
  /// same GlobalKey" (24/10/2026).
  final GlobalKey settingsKey = GlobalKey();

  SettingsController? _settingsController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    // 22/10/2026 — taken before the first await so it is spent on this visit
    // whatever happens next (see pending_notification_record.dart).
    final PendingNotificationRecord? record =
        PendingNotificationRecord.take(Modules.settings);

    // Was `try { Get.find() } catch { Get.put() }` — a try/catch used as
    // control flow, which also hid genuine construction errors.
    final SettingsController controller = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());
    _settingsController = controller;

    // Cubit has no onInit(), so start-up is driven explicitly.
    await controller.init();

    // Read-and-clear, before the ?? chain, so the hint is spent even when
    // `widget.index` outranks it — see [SettingsScreen.pendingInitialIndex].
    final int? pending = SettingsScreen.pendingInitialIndex;
    SettingsScreen.pendingInitialIndex = null;

    controller.selectedContainerIndex =
        widget.index ?? (record != null ? _requestsIndex : pending) ?? 0;

    if (mounted) setState(() => isLoading = false);

    // 22/10/2026 — Owner (calendar check): on a phone the menu only
    // highlighted the requested row; the tablet shows its pane beside the
    // menu. Open that page, as tapping the row does, so Back returns here.
    // A record always opens over Requests (13), even if the stored page key
    // resolved no section of its own.
    final String? route =
        _phoneRouteFor[record != null ? _requestsIndex : pending];
    if (route != null && mounted && kpIsPhoneLayout(context)) {
      Navigator.of(context).push(AppPages.route(route));
    }

    if (record != null && mounted) _openRecord(record);
  }

  /// `selectedContainerIndex` of the Requests section.
  static const int _requestsIndex = 13;

  /// Function Name: [_openRecord]
  ///
  /// Purpose: Open the change request a notification is about, on top of
  /// Requests, so Back lands on the Requests list (owner, 22/10/2026).
  ///
  /// Phone: pushed over the Requests page [_initializeSettings] just opened.
  /// iPad: Requests is the right-hand pane, inside the nested [settingsKey]
  /// Navigator — the record is pushed there, exactly as tapping its card in
  /// that pane does. The navigator exists only after the first frame with
  /// `isLoading` false, hence the post-frame callback.
  void _openRecord(PendingNotificationRecord record) {
    final Widget page = SettingsNotificationRecord.pageFor(
      requestId: record.recordId,
      pageKey: record.pageKey,
    );

    if (kpIsPhoneLayout(context)) {
      navigateTo(context, page);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final NavigatorState? pane = settingsKey.currentState is NavigatorState
          ? settingsKey.currentState! as NavigatorState
          : null;
      pane?.push(appSlideRoute<void>(page));
    });
  }

  /// Settings section (`selectedContainerIndex`) → its phone page.
  static const Map<int, String> _phoneRouteFor = <int, String>{
    0: Routes.settingsPersonalInfo,
    4: Routes.settingsCommentsAndFeedback,
    5: Routes.settingsAboutThisApp,
    8: Routes.settingsCompanyInfo,
    12: Routes.settingsSocial,
    13: Routes.settingsRequests,
    16: Routes.settingsPrivacyStatement,
  };

  void setSelectedContainerIndex(int index) {
    if (!mounted) return;
    setState(() {
      if (index != 11) {
        _settingsController?.selectedContainerIndex = index;
      }
      if (index == 10) {
        _settingsController?.healthInsuranceController.getData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final SettingsController? controller = _settingsController;
    // In a Scaffold so the first-open wait shows the page background, not the
    // bare black route behind it.
    if (isLoading || controller == null) {
      return const Scaffold(body: CircleProgressMaster());
    }

    final bool isTablet = !kpIsPhoneLayout(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<SettingsController, SettingsState>(
        bloc: controller,
        builder: (BuildContext context, SettingsState state) {
          return Row(
            children: [
              Expanded(
                child: isTablet
                    // A nested Navigator so pages pushed from settings render
                    // inside the content area. Names are resolved against the
                    // shared route table (§14); anything unknown — including
                    // the initial '/' — falls back to the menu itself.
                    ? Navigator(
                        key: settingsKey,
                        onGenerateRoute: (RouteSettings routeSettings) =>
                            AppPages.maybeRoute(routeSettings) ??
                            MaterialPageRoute<void>(
                              settings: routeSettings,
                              builder: (_) => const SettingsLayout(),
                            ),
                      )
                    : const SettingsLayout(),
              ),
            ],
          );
        },
      ),
    );
  }
}
