/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_routing.dart
/// Purpose: Shared helpers for opening a stored notification — resolving which
///          drawer module it belongs to, reaching the drawer cubit safely, and
///          formatting its timestamp.
/// Author: Knowticed Plus team
/// Created at: 22/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// `notification_page.dart`, `clear_page_notification.dart` and
/// `pin_notification.dart` each carried their own byte-identical copy of
/// `_getModuleFromString` and their own `context.read<AppDrawerCubit>()`. Both
/// were wrong, and being wrong in triplicate is why every one of the three
/// inbox screens showed "Error occurred" on tap. One copy now.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:grc_module/core/constants/app_constants.dart';
import 'package:grc_module/core/enums/app_module.dart';
import 'package:grc_module/features/notification/domain/enums/settings_module/settings_notification_pages.dart';
import 'package:grc_module/core/helper/message_module/main_helper/messaging_interface_implementation.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
// ADDED 12/9/2026 — the deep-link router. These four are the module roots that
// hold a "pending section" hint; see [openNotification].
import 'package:grc_module/features/notification/data/models/notification_data_model.dart';
import 'package:grc_module/features/notification/domain/routing/notification_deep_link.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/pages/role_screen.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';

abstract class NotificationRouting {
  /// Function Name: [moduleForStoredKey]
  ///
  /// Purpose: Map the `Name_of_module` string stored on a notification onto the
  /// drawer's [Modules] entry, so tapping the notification can open it.
  ///
  /// FIXED 22/8/2026 — this is the "Error occurred" bug.
  ///
  /// Notifications are written by `AppNotificationSender`, which stores
  /// `nameOfModule: module.key` where `module` is an [AppModule]. Its keys are
  /// `user_access`, `role_management`, `user_management`, `knowledge_hub`,
  /// `time_tracker`, `notification_control`, … — snake_case, and a finer
  /// breakdown than the drawer's.
  ///
  /// The switch this replaces was written against a completely different
  /// vocabulary: the drawer's own `Modules` names (`employees`, `knowledgehub`
  /// with no underscore, `roles`, `tracking`, `formbuilder`). Only six keys
  /// happened to overlap. Everything the User Access, Role Management, User
  /// Management, Knowledge Hub, Time Tracker and Settings modules ever sent
  /// fell through to `default: return null`, and the caller turned that into
  /// the "Error occurred" toast. Since account-status notifications are all
  /// `user_access`, *every* card in the screenshots failed.
  ///
  /// Both vocabularies are accepted here: the [AppModule] keys that live
  /// documents actually carry, and the legacy [Modules] names that older
  /// documents may still hold.
  ///
  /// Parameters:
  /// - [storedModuleKey]: the raw `Name_of_module` value.
  ///
  /// Returns: [Modules] to open, or `null` when the value matches nothing —
  /// which now genuinely means "unknown module", not "known module, wrong
  /// spelling".
  static Modules? moduleForStoredKey(String storedModuleKey) {
    final String key = storedModuleKey.trim().toLowerCase();
    if (key.isEmpty) return null;

    // 1 — the keys notifications are actually written with today.
    final AppModule? appModule = AppModule.fromKey(key);
    if (appModule != null) {
      switch (appModule) {
        // The three role-area modules are all tabs of one drawer entry.
        case AppModule.roleManagement:
        case AppModule.userAccess:
        case AppModule.userManagement:
          return Modules.roles;
        case AppModule.knowledgeHub:
          return Modules.knowledgeHub;
        case AppModule.todo:
          return Modules.todo;
        case AppModule.services:
          return Modules.services;
        case AppModule.timeTracker:
          return Modules.tracking;
        case AppModule.database:
          return Modules.database;
        case AppModule.qiyas:
          return Modules.qiyas;
        case AppModule.grc:
          return Modules.grc;
        case AppModule.settings:
          return Modules.settings;
        case AppModule.notificationControl:
          return Modules.notification;
        case AppModule.inventory:
          return Modules.inventory;
        case AppModule.messages:
          return Modules.messages;
          throw UnimplementedError();
      }
    }

    // 2 — legacy documents written before AppModule existed, which stored the
    //     drawer's own enum names.
    switch (key) {
      case 'tasks':
        return Modules.tasks;
      case 'employees':
        return Modules.employees;
      case 'messages':
        return Modules.messages;
      case 'knowledgehub':
        return Modules.knowledgeHub;
      case 'formbuilder':
      case 'services_app':
        return Modules.formBuilder;
      case 'tracking':
        return Modules.tracking;
      case 'roles':
        return Modules.roles;
      case 'requests':
        return Modules.requests;
      case 'events':
        return Modules.events;
      case 'notes':
        return Modules.notes;
      case 'hr':
        return Modules.hr;
      case 'crm':
        return Modules.crm;
      case 'notification':
        return Modules.notification;
      default:
        return null;
    }
  }

  /// Function Name: [rolesTabForStoredKey]
  ///
  /// Purpose: Which tab of the Roles module a notification belongs to.
  ///
  /// Added 22/8/2026. `Modules.roles` is a single drawer entry hosting five
  /// tabs, so resolving a notification to `Modules.roles` alone still left an
  /// "account locked" alert opening on Role Management. Indices match
  /// `Constants.tabletRolePageTabs`: 0 Role Management, 1 User Management,
  /// 2 User Access, 3 Active Directory, 4 System Logs.
  ///
  /// Returns: [int] tab index, or `null` when the notification is not from a
  /// roles-area module.
  ///
  /// CHANGED 12/9/2026: delegates to [NotificationDeepLink.rolesTabFor] rather
  /// than keeping a second copy of the switch. The router needed the same
  /// mapping, and two copies of a mapping is how this file's own "Error
  /// occurred" bug happened in the first place.
  static int? rolesTabForStoredKey(String storedModuleKey) =>
      NotificationDeepLink.rolesTabFor(storedModuleKey);

  /// Function Name: [drawerCubit]
  ///
  /// Purpose: Reach the app drawer's cubit.
  ///
  /// FIXED 22/8/2026 — the three inbox pages resolved this with
  /// `context.read<AppDrawerCubit>()`, but `AppDrawerCubit` is never placed in
  /// the widget tree. `main.dart`'s MultiBlocProvider provides
  /// ThemeAndLocalizationsCubit, CompanyCubit, AppHomeCubit and
  /// MainCoreDepartmentCubit; every AppDrawerCubit registration in the app goes
  /// through `Get.put` (custom_drawer.dart, home_responsive_page.dart,
  /// main_responsive.dart). So `context.read` threw ProviderNotFoundException,
  /// and because the throw happened inside a tap callback the button simply
  /// appeared to do nothing — the "Cleared / Pin don't work" report.
  ///
  /// Resolved from the registry that actually owns it, registering it if the
  /// current layout has torn it down (the mobile branch deletes it).
  static AppDrawerCubit drawerCubit() => Get.isRegistered<AppDrawerCubit>()
      ? Get.find<AppDrawerCubit>()
      : Get.put(AppDrawerCubit());

  // ── Opening the three notification screens ──────────────────────────────
  //
  // The desktop / tablet shell (custom_drawer.dart) does NOT wrap its content
  // area in a nested Navigator, so `Navigator.push` from inside a module puts
  // the new route over the whole window — the 90.sp sidebar and CustomAppBar
  // included. That is the "frame of page is lost" report.
  //
  // The shell already renders all three notification screens itself, keyed off
  // sentinel indices that sit OUTSIDE allowedDrawerModules:
  //
  //     if (controller.selectedIndex == 19) NotificationLandPage()
  //     if (controller.selectedIndex == 20) CleanedNotificationLandPage()
  //     if (controller.selectedIndex == 21) PinNotificationLandPage()
  //
  // (19 is what the app bar's bell already sets — 70-custom_appbar.dart.) So on
  // the shell the right move is to select that index, not to push; the earlier
  // fix was right that `context.read<AppDrawerCubit>()` threw, but replacing it
  // with a root push is what costs the frame. Mobile (NavScreen) has no such
  // branch, so it still pushes.
  //
  // The literals live here, named, instead of being scattered across the three
  // pages and the app bar.

  /// Shell index for the inbox — mirrors `custom_drawer.dart`.
  static const int inboxShellIndex = 19;

  /// Shell index for the cleared list.
  static const int clearedShellIndex = 20;

  /// Shell index for the pinned list.
  static const int pinnedShellIndex = 21;

  /// The desktop / tablet shell is what renders the sidebar; below this the
  /// app runs NavScreen, which does not. Same breakpoint as main_responsive.
  static bool _hasShell(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  /// Function Name: [openInShell]
  ///
  /// Purpose: Show one of the notification screens without losing the frame.
  ///
  /// On the shell this selects [shellIndex] so the page renders inside the
  /// content area, beside the sidebar and under the app bar. Everywhere else —
  /// mobile, or a layout where the drawer cubit is absent — it falls back to
  /// pushing [pageBuilder], which is the only option there.
  static void openInShell(
    BuildContext context, {
    required int shellIndex,
    required Widget Function() pageBuilder,
  }) {
    if (_hasShell(context) && Get.isRegistered<AppDrawerCubit>()) {
      drawerCubit().updateSelectedIndex(shellIndex);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => pageBuilder()),
    );
  }

  /// Function Name: [backToInbox]
  ///
  /// Purpose: The breadcrumb's "Notifications" crumb on the pinned / cleared
  /// pages.
  ///
  /// Pops when the page was pushed (mobile, or a deep link), and otherwise
  /// selects the inbox's own shell index. It used to fall back to
  /// `allowedDrawerModules.indexOf(Modules.notification)`, which is the
  /// Notification CONTROL page (modules_enum maps Modules.notification to
  /// NotificationControlPage) — a different screen entirely.
  static void backToInbox(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    if (Get.isRegistered<AppDrawerCubit>()) {
      drawerCubit().updateSelectedIndex(inboxShellIndex);
    }
  }

  /// Function Name: [openNotification]
  ///
  /// Purpose: What the View button does. Opens the module a notification came
  /// from and, where the stored `name_of_page` says so, the SECTION of it the
  /// notification is actually about.
  ///
  /// ADDED 12/9/2026. This replaces `_handleViewNotification`, which existed
  /// as three byte-identical private copies — `notification_page.dart`,
  /// `clear_page_notification.dart`, `pin_notification.dart`. All three read
  /// `nameOfModule` and threw `nameOfPage` away, which is the gap four of the
  /// page enums document in their own headers: the keys were stored correctly
  /// and nothing ever acted on them. So an "approved" alert and a "needs your
  /// review" alert both landed on the module's front door.
  ///
  /// HOW A SECTION IS DELIVERED. Not by pushing the target screen: the desktop
  /// / tablet shell does not wrap its content area in a nested Navigator, so a
  /// push from here covers the sidebar and the app bar — the "frame of page is
  /// lost" report that the notes above this method exist because of. The
  /// module is selected in the drawer as before, and the section is left on
  /// the module's own root widget as a static, which that widget consumes and
  /// clears on its first build. `RoleScreenHost.pendingInitialTab` has worked
  /// this way since 22/8/2026; the other three follow it.
  ///
  /// WHAT IT CANNOT DO. Land on a RECORD — a specific database, document,
  /// conversation or request. A stored notification carries no target id, so
  /// a page key naming a detail screen resolves to the list that screen opens
  /// from. See the header of `notification_deep_link.dart`.
  ///
  /// Parameters:
  /// - [context]: the inbox page's context, used only to pop it afterwards.
  /// - [notification]: the tapped notification.
  ///
  /// Returns: nothing. A notification whose module resolves to nothing, or to
  /// a module this user's drawer does not carry, is a silent no-op — the
  /// pre-existing behaviour, snackbars deliberately removed.
  static void openNotification(
    BuildContext context,
    NotificationModelSystem notification,
  ) {
    // 21/9/2026 — change-request notifications are FILED under User
    // Management but still point at a Settings page (their name_of_page is a
    // SettingsNotificationPage key); the page decides where View lands.
    final Modules? targetModule =
        SettingsNotificationPage.fromKey(notification.nameOfPage) != null
            ? Modules.settings
            : moduleForStoredKey(notification.nameOfModule);
    if (targetModule == null) return;

    final NotificationDeepLink link = NotificationDeepLink.resolve(
      module: targetModule,
      moduleKey: notification.nameOfModule,
      pageKey: notification.nameOfPage,
    );

    if (_hasShell(context)) {
      _openInDrawer(context, targetModule, link);
    } else {
      _openOnMobile(context, targetModule, link);
    }
  }

  /// Function Name: [_openInDrawer]
  ///
  /// Purpose: The desktop / tablet half of [openNotification] — select the
  /// module in the shell's sidebar.
  static void _openInDrawer(
    BuildContext context,
    Modules targetModule,
    NotificationDeepLink link,
  ) {
    final AppDrawerCubit appDrawerController = drawerCubit();
    final int moduleIndex =
        appDrawerController.allowedDrawerModules.indexOf(targetModule);
    // Not in this user's drawer: no role or no licence for it. Silent no-op,
    // the pre-existing behaviour — snackbars deliberately removed.
    if (moduleIndex == -1) return;

    // Armed BEFORE the drawer switches: updateSelectedIndex is what causes the
    // module to be built, and the module reads its hint during that build.
    _armSection(link);
    appDrawerController.updateSelectedIndex(moduleIndex);

    // Guarded, unlike the three copies this replaces, which called
    // `Navigator.of(context).pop()` unconditionally. On the shell the inbox is
    // not a pushed route at all — it is rendered at sentinel index 19 — so
    // there was nothing of ours to pop and the call reached whatever route sat
    // below.
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }

  /// Function Name: [_openOnMobile]
  ///
  /// Purpose: The phone half of [openNotification] — PUSH the module.
  ///
  /// FIXED 12/9/2026 — "View goes to the home page on mobile".
  ///
  /// Below 600px the app is not the drawer shell, it is `NavScreen`: a bottom
  /// bar driven by `NavBarCubit.navBarModules`, which has nothing to do with
  /// `AppDrawerCubit.allowedDrawerModules`. The old handler — and the first
  /// cut of this method — did the shell dance on mobile too: set a drawer
  /// index nothing was listening to, then pop. The inbox is pushed there (from
  /// the bell in `71-custom_appbar_mobile.dart`, which sits on the Home tab),
  /// so the pop was the ONLY thing that had any effect, and it landed the user
  /// back on Home. The module was never opened; it only looked like a
  /// navigation because something moved.
  ///
  /// A phone opens a module by pushing `module.widget` — that is what
  /// `MorePage.moduleWidget` does, and `.widget` is what supplies each
  /// module's own providers and nested Navigator. So this pushes the same
  /// thing, REPLACING the inbox route so Back returns to Home rather than to a
  /// notification list the user is done with.
  static void _openOnMobile(
    BuildContext context,
    Modules targetModule,
    NotificationDeepLink link,
  ) {
    // Role ∩ licence, as the phone computes it: `navBarModules` is the bottom
    // bar and `moreListModules` is everything else the user may open (see
    // `_getMoreListModules`). Skipped entirely when the cubit is absent or
    // still loading its lists — refusing to open on an empty list would block
    // every notification, which is the failure this method exists to fix.
    if (Get.isRegistered<NavBarCubit>()) {
      final NavBarCubit navBar = Get.find<NavBarCubit>();
      final bool listsReady =
          navBar.navBarModules.isNotEmpty || navBar.moreListModules.isNotEmpty;
      final bool allowed = navBar.navBarModules.contains(targetModule) ||
          navBar.moreListModules.contains(targetModule);
      if (listsReady && !allowed) return;
    }

    _armSection(link);

    final NavigatorState navigator = Navigator.of(context);
    final MaterialPageRoute<void> route =
        MaterialPageRoute<void>(builder: (_) => targetModule.widget);

    // canPop tells us whether the inbox is a route of ours to replace. It
    // always is on this path today; the push is the safe fallback.
    if (navigator.canPop()) {
      navigator.pushReplacement(route);
    } else {
      navigator.push(route);
    }
  }

  /// Function Name: [_armSection]
  ///
  /// Purpose: Hand the resolved section to the module that will read it.
  ///
  /// One static per module root. Each is cleared by its owner on the first
  /// build, used or not, so a hint can never survive into an unrelated visit.
  static void _armSection(NotificationDeepLink link) {
    if (link.rolesTab != null) {
      RoleScreenHost.pendingInitialTab = link.rolesTab;
    }
    if (link.settingsSection != null) {
      SettingsScreen.pendingInitialIndex = link.settingsSection!.containerIndex;
    }
    // Knowledge Hub / Services sections: those modules are not in this app.
  }

  /// Function Name: [formatTimestamp]
  ///
  /// Purpose: When a notification arrived, phrased the way the design asks for.
  ///
  /// UPDATED 22/8/2026 (second pass): every card stamps the plain absolute
  /// date on all three inbox pages, per the request to show the date itself
  /// rather than how long ago it was.
  ///
  /// UPDATED 26/8/2026: the clock time is stamped with it — `23 Aug 2026,
  /// 08:32 PM`. The date alone could not separate two notifications that
  /// arrived on the same day, which is most of an active inbox.
  ///
  /// The first pass followed Figma (node 4717:10740 and its tablet/mobile
  /// twins) with relative wording — `Today At 10:00 AM`, `Yesterday At 10:00
  /// AM`, `Week Ago At 10:00 AM`, then `From 18 Jul 2025`. Kept below as
  /// [formatTimestampRelative] in case the design wins that argument later.
  ///
  /// Parameters:
  /// - [context]: used for the active locale.
  /// - [millisecondsSinceEpoch]: the notification's `timestamp` field.
  ///
  /// Returns: [String], or `''` when there is no usable timestamp.
  static String formatTimestamp(
    BuildContext context,
    int millisecondsSinceEpoch,
  ) {
    if (millisecondsSinceEpoch <= 0) return '';

    final bool isArabic = Localizations.localeOf(context).languageCode ==
        AppConstants.arabicLanguageCode;
    final String localeTag = isArabic ? 'ar' : 'en_US';

    // Arabic-Indic digits, Arabic month names and a localized AM/PM marker all
    // come free: intl's DateFormat follows the locale tag. main() preloads
    // both locales via AppBarDate.ensureDateFormattingInitialized().
    return DateFormat('dd MMM yyyy, hh:mm a', localeTag)
        .format(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch));
  }

  /// Function Name: [formatTimestampRelative]
  ///
  /// Purpose: The relative phrasing the Figma card specifies — `Today At 10:00
  /// AM`, `Yesterday At 10:00 AM`, `Week Ago At 10:00 AM`, then `From 18 Jul
  /// 2025`. No longer wired to the cards; kept so the design's wording can be
  /// restored without rewriting it.
  ///
  /// Parameters:
  /// - [context]: used for the active locale.
  /// - [millisecondsSinceEpoch]: the notification's `timestamp` field.
  ///
  /// Returns: [String], or `''` when there is no usable timestamp.
  static String formatTimestampRelative(
    BuildContext context,
    int millisecondsSinceEpoch,
  ) {
    if (millisecondsSinceEpoch <= 0) return '';

    final bool isArabic = Localizations.localeOf(context).languageCode ==
        AppConstants.arabicLanguageCode;
    final String localeTag = isArabic ? 'ar' : 'en_US';

    final DateTime moment =
        DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    final DateTime now = DateTime.now();

    // Calendar days apart, not elapsed hours: something sent at 23:50 is
    // "Yesterday" at 00:10, not "Today".
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);
    final DateTime startOfThatDay =
        DateTime(moment.year, moment.month, moment.day);
    final int daysAgo = startOfToday.difference(startOfThatDay).inDays;

    // Arabic-Indic digits come free: intl's DateFormat pads with the locale's
    // own zero digit. main() preloads both locales via
    // AppBarDate.ensureDateFormattingInitialized().
    final String time = DateFormat('hh:mm a', localeTag).format(moment);

    if (daysAgo <= 0) {
      return isArabic ? 'اليوم في $time' : 'Today At $time';
    }
    if (daysAgo == 1) {
      return isArabic ? 'أمس في $time' : 'Yesterday At $time';
    }
    if (daysAgo < 7) {
      final String dayName = DateFormat('EEEE', localeTag).format(moment);
      return isArabic ? '$dayName في $time' : '$dayName At $time';
    }
    if (daysAgo < 14) {
      return isArabic ? 'قبل أسبوع في $time' : 'Week Ago At $time';
    }

    final String date = DateFormat('dd MMM yyyy', localeTag).format(moment);
    return isArabic ? 'بتاريخ $date' : 'From $date';
  }

  /// Function Name: [messageSender]
  ///
  /// Purpose: The notification card's Message button — open the chat with
  /// whoever sent [notification].
  ///
  /// ADDED 21/9/2026. The button was a deliberate no-op on all three pages
  /// (inbox, pinned, cleared).
  ///
  /// On the desktop / tablet shell the chat opens INSIDE the Messages module
  /// (tablet_body.dart renders the selected connection inline): the
  /// connection is selected first, then the drawer switches to Messages, so
  /// the frame and sidebar stay. On a phone, or when Messages is not in this
  /// user's drawer, the chat is pushed full screen instead. A failure says
  /// why, localized, and closes itself after 3 seconds.
  static Future<void> messageSender(
    BuildContext context,
    NotificationModelSystem notification,
  ) async {
    final String email = notification.senderEmail.trim();
    final MessagingInterfaceImplementation messaging =
        MessagingInterfaceImplementation();

    final int messagesIndex = _hasShell(context)
        ? drawerCubit().allowedDrawerModules.indexOf(Modules.messages)
        : -1;

    final OpenChatResult result;
    if (messagesIndex != -1) {
      result = await messaging.selectChatWithUser(userEmail: email);
      if (result == OpenChatResult.opened) {
        drawerCubit().updateSelectedIndex(messagesIndex);
        return;
      }
    } else {
      if (!context.mounted) return;
      result = await messaging.tryOpenChatWithUser(
          context: context, userEmail: email);
    }
    if (context.mounted) await showOpenChatFailure(context, result);
  }
}
