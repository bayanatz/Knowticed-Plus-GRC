/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_page.dart
/// Description: The notification inbox.
/// Author: Amr Mesbah
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-NOTIF-N05/N06/N11/N14: the two UI `try` blocks are gone; the drawer
///          cubit is read from the tree; `Get.snackbar` replaced with a themed,
///          localized toast; the unsafe `as int` / `as String` casts are guarded;
///          raw colours route through AppColors.
///
/// REMAINING (CR-SKEL-NOTIF-N02): still ~1,000 LOC.
library;

import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_pop_up.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/knowledge_hub_module/core/theming/new_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/todo_new_module/external/tasks_module/core/custom_widgets/SideFrameMasterServices.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/pin_notification.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';

import 'package:knowticed_plus/generated/l10n.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/inventory_module/core/drop_down.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/services_mangment_module/Category/presentation/ui/service_department_manager/mobile/dashBoard_master_mobile/widget/dialog.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/services_mangment_module/core/custom_pop_up.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_card.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_filter_row.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/clear_page_notification.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

part '../widgets/notification_page/notification_land_page_state.dart';
part '../widgets/notification_page/notification_type_list.dart';
part '../widgets/notification_page/notification_content_logic.dart';
part '../widgets/notification_page/notification_content_builders.dart';

final List<Map<String, String>> notificationByeType = [
  {'key': 'system', 'value': 'System'},
  {'key': 'employee', 'value': 'Employee'},
  {'key': 'manager', 'value': 'Manager'},
];

final List<Map<String, String>> timeFilterList = [
  {'key': 'day', 'value': 'Day'},
  {'key': 'week', 'value': 'Week'},
  {'key': 'month', 'value': 'Month'},
  {'key': 'year', 'value': 'Year'},
  {'key': 'custom', 'value': 'Custom'},
];

final List<Map<String, String>> notificationByeTypeArabic = [
  {'key': 'system', 'value': 'النظام'},
  {'key': 'employee', 'value': 'الموظفين'},
  {'key': 'manager', 'value': 'المدير'},
];

final List<Map<String, String>> timeFilterListArabic = [
  {'key': 'day', 'value': 'يوم'},
  {'key': 'week', 'value': 'أسبوع'},
  {'key': 'month', 'value': 'شهر'},
  {'key': 'year', 'value': 'سنة'},
  {'key': 'custom', 'value': 'مخصص'},
];

// `getNotificationTypeList()`, `getNotificationByeType()` and
// `getTimeFilterList()` were deleted: three top-level helpers with no callers
// anywhere in lib/, each selecting an Arabic or English list with
// `Get.locale` (CR-SKEL-NOTIF-N06). The lists themselves are still used
// directly by the page.

// ============================================
// MAIN PAGE
// ============================================

class NotificationLandPage extends StatefulWidget {
  const NotificationLandPage({super.key});

  @override
  State<NotificationLandPage> createState() => _NotificationLandPageState();
}

class _NotificationContentState extends State<_NotificationContent> {
  String selectStatus = "All";
  String? selectedNotificationType;
  String? selectedNotificationByeType;
  String? selectedNotificationTime;
  String? selectedNotificationDepartment;
  TextEditingController searchController = TextEditingController();
  String sortOrder = "newest";

  /// False until the user picks a sort: the Sort button stays grey and the
  /// list is newest first. Picking turns the button yellow; picking the chosen
  /// row again clears it.
  bool sortChosen = false;

  // ── Toolbar state (added 22/8/2026, Figma 4717:10740) ─────────────────
  //
  // The design carries a second filter row under the search field — Sender
  // Type and By Type on the leading side, Department and Time on the
  // trailing side — and a "Collapse Tools" link above the buttons. None of it
  // existed in the code.
  //
  // FIXED 25/8/2026 — all four filters opened the page on `null`, which is not
  // one of the options. Nothing was highlighted when the menu dropped open and
  // the trigger drew in the placeholder style, so the row read as "unset"
  // rather than "showing everything". They now start on
  // [NotificationFilters.all] — the sentinel behind the "All" entry, a real
  // value present in every option list — so "All" is the selection from the
  // first frame.
  // SUPERSEDED 22/10/2026 — Owner: multi-select. There is no "All" entry any
  // more; nothing ticked is "all", and the field shows its own name.
  //
  // CHANGED 26/8/2026: the "All" sentinel, the test for whether a value
  // narrows anything, the four option builders and the row itself all live in
  // notification_filter_row.dart, which the Pinned and Cleared pages already
  // used. This page kept a private copy of every one of them, so a fix to
  // either half only ever reached one of the three lists.

  /// Sender Type / By Type / Department / Time (+ the Custom range).
  ///
  /// CHANGED 22/10/2026 — Owner: all four are multi-select; one value object
  /// replaces the four single values. By Type is the module a notification
  /// came from — the only "type" the stored notification carries (it has no
  /// type field), see NotificationFilters.apply.
  NotificationFilterSelection filters =
      const NotificationFilterSelection.cleared();

  /// Whether the chips, search and filter rows are hidden to give the card
  /// list the full height ("Collapse Tools" / "Expand Tools" in the design).
  bool toolsCollapsed = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ✅ FIXED: Better module name matching
  String _getModuleKeyFromName(String displayName) {
    for (Modules module in widget.allowedModules) {
      // _chipLabel first — that is what the chip rendered and therefore what
      // selectStatus holds. getModuleName stays as a fallback so a value
      // captured before the 26/8/2026 rename still resolves.
      if (_chipLabel(module) == displayName ||
          module.getModuleName == displayName) {
        String key = _moduleEnumToKey(module);
        return key;
      }
    }

    return displayName.toLowerCase();
  }

  /// Function Name: [_moduleKeyOf]
  ///
  /// Purpose: The chip key a stored notification belongs under.
  ///
  /// Notifications store the fine-grained AppModule key (`user_access`,
  /// `user_management`, `role_management`, `knowledge_hub`, `time_tracker`…),
  /// while the chips are the drawer's coarser [Modules]. NotificationRouting
  /// owns that mapping — the three role-area keys all collapse onto
  /// [Modules.roles] — so counting and filtering both go through it instead of
  /// string-matching the raw value.
  ///
  /// Returns: the chip key, or `null` for a module this inbox has no chip for.
  String? _moduleKeyOf(String storedModuleKey) {
    final Modules? module = NotificationRouting.moduleForStoredKey(
      storedModuleKey,
    );
    return module == null ? null : _moduleEnumToKey(module);
  }

  Future<void> _handleCleanAll() async {
    final s = S.of(context);
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/notification_lottie_assets/lot_action_clear_all.json',
      confirmTitle: s.cleaningNotifications,
      confirmSubtitle: s.areYouSureYouWantToCleanAll,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () async {
        // 22/10/2026 — Owner: "I filtered by this module, so I want to
        // remove the notifications from this module." Clean All clears what
        // is ON SCREEN (module chip + filters + search); on "All" with
        // nothing filtered that is everything. Returns false on failure.
        final List<String> ids = <String>[
          for (final NotificationModelSystem n in _getFilteredNotifications())
            if (n.id != null) n.id!,
        ];
        return widget.notificationService.markCleaned(ids);
      },
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: s.allNotificationsCleared,
      successSubtitle: s.youSuccessfullyCleanedAllNotification,
    );
  }

  Future<void> _handlePinToggle(NotificationModelSystem notification) async {
    bool newPinStatus = !notification.isPinned;
    await widget.notificationService.updatePinStatus(
      notification.id!,
      newPinStatus,
    );
  }

  /// Opens what a notification points at.
  ///
  /// CHANGED 12/9/2026: this was ~25 lines here, and the same ~25 lines in
  /// `clear_page_notification.dart` and `pin_notification.dart`. All three
  /// resolved the module and stopped, ignoring the `name_of_page` every
  /// notification stores. The shared version reads it, so a notification can
  /// land on the section it is about, and the three copies cannot drift again.
  void _handleViewNotification(NotificationModelSystem notification) =>
      NotificationRouting.openNotification(context, notification);

  // WIRED 21/9/2026 — was a no-op. See NotificationRouting.messageSender.
  void _handleMessageSender(NotificationModelSystem notification) =>
      NotificationRouting.messageSender(context, notification);

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.sizeOf(context).width >= 900;
    var isMobile = ContextExtension(context).isPhone;
    final s = S.of(context);

    List<NotificationModelSystem> filteredNotifications =
        _getFilteredNotifications();
    Map<String, int> moduleCounts = _getNotificationCountsByModule();

    // Owner 21/10/2026 14:53 (pinned rows): everything above the cards —
    // title link, Cleared / Pin, counters, Search / Sort / Clean All and the
    // filters — stays put; ONLY the cards scroll.
    // On the phone the frame scrolls its child, so SideFrameBoundedBody gives
    // this Column the screen height and the Expanded card list scrolls inside.
    return SideFrameBoundedBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── "Collapse Tools" ──────────────────────────────────────
          // ADDED 22/8/2026 (Figma 4717:10740): a text link, trailing-aligned,
          // that hides the chips / search / filter rows so the card list gets
          // the full height. Reads "Expand Tools" once collapsed.
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              onTap: withHaptic(
                  () => setState(() => toolsCollapsed = !toolsCollapsed),
                  HapticLevel.low),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.sp),
                // CHANGED 26/8/2026: was TextDecoration.underline, which sits
                // tight against the baseline and gives no control over the
                // gap. This draws the rule as its own 1.h line 3.h below the
                // text instead. IntrinsicWidth sizes the column to the text,
                // and CrossAxisAlignment.stretch hands that same width to the
                // line — so it tracks the label and stays exactly as wide,
                // including when it flips to "Expand Tools" or to Arabic.
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        toolsCollapsed ? s.expandTools : s.collapseTools,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.blue,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Container(height: 1.h, color: AppColors.blue),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.sp),

          // ── What "Collapse Tools" hides ───────────────────────────────
          // CHANGED 26/8/2026. Collapsed now leaves exactly the search row
          // and the cards on screen, so this guard opens here — above the
          // Cleared / Pin buttons — rather than below them. It closes just
          // before the search row and reopens just after it, because that one
          // row is the only thing between here and the grid that survives.
          if (!toolsCollapsed) ...[
            // Top buttons
            Row(
              children: [
                customButtonWithSvg(
                  title: s.cleared,
                  // The root push this replaces covered the sidebar and app bar
                  // ("frame of page is lost"): the shell's content area is not
                  // wrapped in a nested Navigator. openInShell selects the index
                  // the shell already renders this page at, and only pushes on
                  // mobile, where there is no shell. See NotificationRouting.
                  function: () => NotificationRouting.openInShell(
                    context,
                    shellIndex: NotificationRouting.clearedShellIndex,
                    pageBuilder: () => const CleanedNotificationLandPage(),
                  ),
                  width: 135.w,
                  height: 38.h,
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                  space: 8.sp,
                  radius: 8.r,
                  svgColor: AppColors.textButton,
                  image:
                      "assets/icons_assets/notification_assets/ic_action_clear.svg",
                  widthImage: 22.sp,
                  heightImage: 22.sp,
                  colorBorder: AppColors.transparent,
                ),
                Spacer(),
                customButtonWithSvg(
                  title: s.pin,
                  // Same as Cleared above — select, don't push.
                  function: () => NotificationRouting.openInShell(
                    context,
                    shellIndex: NotificationRouting.pinnedShellIndex,
                    pageBuilder: () => const PinNotificationLandPage(),
                  ),
                  width: 135.w,
                  height: 38.h,
                  color: AppColors.primary,
                  svgColor: AppColors.textButton,
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                  space: 8.sp,
                  radius: 8.r,
                  image:
                      "assets/icons_assets/notification_assets/ic_action_pin_round.svg",
                  widthImage: 22.sp,
                  heightImage: 22.sp,
                  colorBorder: AppColors.transparent,
                ),
              ],
            ),
            SizedBox(height: 15.sp),

            // Filter chips
            //
            // CHANGED 13/9/2026 — was a local `_statusChip` plus a hand-rolled
            // horizontal Row, a near-copy of the shared component. Now
            // `StatusChipFilter` (core/custom/8-custom_filter_app.dart), which
            // already does the scroll row, the count box, the selected/
            // unselected colours and — the reason this page wanted it —
            // localises the count digits, so an Arabic screen no longer shows
            // ASCII "14" beside Arabic-Indic dates.
            //
            // The chip KEY stays the displayed name, not a module id, because
            // `selectStatus` is what `_getFilteredNotifications` feeds to
            // `_getModuleKeyFromName`. Changing the key would mean changing that
            // lookup too, and this change is meant to be visual only.
            StatusChipFilter(
              selectedKey: selectStatus,
              onSelected: (String key) => setState(() => selectStatus = key),
              innerSpacing: 16.sp,
              items: <StatusChipItem>[
                StatusChipItem(
                  key: s.all,
                  label: s.all,
                  count: moduleCounts['all'] ?? 0,
                ),
                ...() {
                  final List<Map<String, dynamic>> moduleData =
                      widget.allowedModules.map((module) {
                    final String moduleKey = _moduleEnumToKey(module);
                    return <String, dynamic>{
                      'count': moduleCounts[moduleKey] ?? 0,
                      // Not getModuleName — see [_chipLabel] for why this inbox
                      // renames Roles / Services locally.
                      'displayName': _chipLabel(module),
                    };
                  }).toList();

                  // Busiest module first. Was `(b['count'] as int)` — a missing
                  // or wrongly-typed field threw during build
                  // (CR-SKEL-NOTIF-N11).
                  moduleData.sort(
                    (a, b) => ((b['count'] as num?)?.toInt() ?? 0).compareTo(
                      (a['count'] as num?)?.toInt() ?? 0,
                    ),
                  );

                  return moduleData.map<StatusChipItem>((data) {
                    final String name = data['displayName']?.toString() ?? '';
                    return StatusChipItem(
                      key: name,
                      label: name,
                      count: (data['count'] as num?)?.toInt() ?? 0,
                    );
                  }).toList();
                }(),
              ],
            ),
            SizedBox(height: 15.sp),
          ],

          // Search and buttons. OUTSIDE the collapse guard on purpose — the
          // collapsed view is "search row + cards", so this row and the Sort /
          // Clean All buttons on it stay put either way.
          Row(
            children: [
              AppSearchTextField(
                controller: searchController,
                onChanged: (val) => setState(() {}),
              ),
              SizedBox(width: ButtonSizing.toolbarGap(context)),
              // CHANGED 13/9/2026 (Figma MESBAH — mobile Notification screen).
              // At 375px the four filter dropdowns took a third of the screen
              // before a single card showed, so on mobile they move into a
              // dialog and this slot carries the Filter button that opens it.
              // Sort keeps the slot on tablet and desktop, where the dropdown
              // row still fits beside the cards.
              if (NotificationFilters.inDialog(context, isMobile: isMobile))
                CustomFilterIcon(
                  iconOnly: true,
                  active: filters.isFiltering,
                  onTap: () async {
                    final NotificationFilterSelection? picked =
                        await showNotificationFilterDialog(
                      context: context,
                      notifications: widget.allNotifications
                          .where((n) => !n.isPinned && !n.isClean)
                          .toList(),
                      employeeController: widget.employeeController,
                      current: filters,
                    );

                    // null = dismissed. Leave the page's filters alone.
                    if (picked == null || !mounted) return;
                    setState(() => filters = picked);
                  },
                ),
              // iPad portrait (Moataz 23/10/2026): Filter AND Sort side by side.
              // The phone keeps Filter alone on this page, as before.
              if (NotificationFilters.inDialog(context, isMobile: isMobile) &&
                  !isMobile)
                SizedBox(width: ButtonSizing.toolbarGap(context)),
              if (!isMobile)
                CustomPopupMenuButton(
                  // 22/10/2026 — Owner: icon only (the core square) on a phone and
                  // on a tablet in portrait, where the toolbar is too narrow.
                  title: isMobile ||
                          MediaQuery.orientationOf(context) ==
                              Orientation.portrait
                      ? ""
                      : s.sort,
                  iconPath:
                      "assets/icons_assets/main_icons_assets/ic_action_sort.svg",
                  backgroundColor: AppColors.card,
                  iconColor: AppColors.secondaryText,
                  // Owner 21/10/2026 14:54: the house height (38.sp) like Search and Clean All.
                  width: 100.w,
                  // Raw 38: CustomPopupMenuButton scales it itself (.r).
                  height: 38,
                  options: [
                    // Was a hand-rolled locale ternary; the strings live in
                    // the ARB bundle now like every other label on the page.
                    PopupOption(value: "newest", label: s.newestFirst),
                    PopupOption(value: "oldest", label: s.oldestFirst),
                  ],
                  selectedValue: sortChosen ? sortOrder : '',
                  onCleared: () => setState(() {
                    sortChosen = false;
                    sortOrder = "newest";
                  }),
                  onSelected: (value) {
                    setState(() {
                      sortOrder = value;
                      sortChosen = true;
                    });
                  },
                ),
              SizedBox(width: ButtonSizing.toolbarGap(context)),
              // Owner 21/10/2026 14:39 ("same height as Search and Sort — are
              // they our customs?"): Clean All is the house button
              // (customButtonWithSvg, ButtonSizing.height = 38.sp like the
              // search field), not a hand-made 38.h container.
              isMobile
                  ? GestureDetector(
                      onTap: withHaptic(_handleCleanAll, HapticLevel.low),
                      child: Container(
                        width: ButtonSizing.height,
                        height: ButtonSizing.height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColors.primary,
                        ),
                        child: Center(
                          child: CustomSvgImage(
                            assetPath:
                                "assets/icons_assets/notification_assets/ic_action_clear_all.svg",
                            width: 20.r,
                            height: 20.r,
                            fit: BoxFit.scaleDown,
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                    )
                  : customButtonWithSvg(
                      title: s.cleanAll,
                      function: _handleCleanAll,
                      width: 120.w,
                      height: ButtonSizing.height,
                      color: AppColors.primary,
                      svgColor: AppColors.textButton,
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.textButton),
                      image:
                          "assets/icons_assets/notification_assets/ic_action_clear_all.svg",
                      widthImage: 20.r,
                      heightImage: 20.r,
                      colorBorder: AppColors.transparent,
                    ),
            ],
          ),

          // Guard reopens: the filter dropdowns collapse with the rest.
          if (!toolsCollapsed) ...[
            SizedBox(height: 15.sp),

            // ── Filter row ────────────────────────────────────────────────
            // ADDED 22/8/2026 (Figma 4717:10740 + the 768 / 375 twins). Sender
            // Type and By Type lead, Department and Time trail. On mobile the
            // four stack into two rows of two rather than being cut off — the
            // design collapses them behind a filter icon there, but four
            // reachable dropdowns beat one icon that needs another sheet built
            // behind it.
            //
            // Shared with the Pinned and Cleared pages since 26/8/2026 — the
            // page keeps the four selected values and nothing else. The list
            // handed over is the one this page actually shows (unpinned and
            // uncleaned), because the By Type and Department menus are built
            // from it and must not offer an option that matches nothing.
            // Mobile reaches these through the Filter button above instead.
            if (!NotificationFilters.inDialog(context, isMobile: isMobile))
              NotificationFilterRow(
                notifications: widget.allNotifications
                    .where((n) => !n.isPinned && !n.isClean)
                    .toList(),
                employeeController: widget.employeeController,
                isMobile: isMobile,
                selection: filters,
                onChanged: (v) => setState(() => filters = v),
              ),
          ],

          isMobile
              ? (toolsCollapsed ? SizedBox(height: 15.sp) : SizedBox())
              : SizedBox(height: 15.sp),

          // Grid
          // CHANGED 22/10/2026 — Owner (lag): the list and grid were
          // shrink-wrapped inside a SingleChildScrollView, which builds EVERY
          // card of the inbox on every rebuild (each search keystroke, filter
          // tick or Pin tap). They scroll themselves now and build only the
          // cards on screen; the empty state keeps its scroll view.
          Expanded(
            child: filteredNotifications.isEmpty
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.sp),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 50.h),
                              CustomEmptyState(
                                lottiePath:
                                    'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
                                size: 250,
                                verticalPadding: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : isMobile
                    // Owner 21/10/2026 14:53: on the phone every card is its
                    // CONTENT height (no fixed cell, no empty band, no "…").
                    ? ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredNotifications.length,
                        separatorBuilder: (_, __) => SizedBox(height: 15.sp),
                        itemBuilder: (context, index) {
                          final notification = filteredNotifications[index];
                          return _buildNotificationCard(
                              notification, isMobile, s);
                        },
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          // Owner 21/10/2026 14:45: one card per row on iPad portrait.
                          // Owner 23/10/2026 (Mac: "why only two cards, the
                          // window is huge"): the column count grows with the
                          // width — iPad landscape (about 1370) keeps 2, a
                          // normal Mac window gets 3, a very wide one 4.
                          crossAxisCount: (isDesktop &&
                                  MediaQuery.of(context).orientation ==
                                      Orientation.landscape)
                              ? (MediaQuery.sizeOf(context).width >= 2200
                                  ? 4
                                  : MediaQuery.sizeOf(context).width >= 1500
                                      ? 3
                                      : 2)
                              : 1,
                          // 160.sp left the card ~37px short of its own content once the
                          // sender chip and the two button rows were laid out.
                          // CHANGED 13/9/2026 — one tile height per form factor.
                          //
                          // A single 195.sp left a band of empty card under the buttons on
                          // a phone: mobile shrinks the buttons to 75% (see
                          // notification_card.dart), the avatar to 30.sp and the label
                          // sizes with it, so the card needs roughly 25.sp less than a
                          // desktop one. The body is Flexible now, so that surplus does
                          // not stretch the text box — it just sits at the bottom of the
                          // card, which is exactly the gap this removes.
                          // +1 body line (owner round 4, 7/10/2026): bodies show
                          // up to 3 lines — see NotificationCard.bodyMaxLines.
                          // Owner 21/10/2026 14:32 (Figma 1611-47512, 133 with a one-line body):
                          // our bodies run two lines, so the cell is 152 (170 on the phone).
                          mainAxisExtent: isMobile ? 170.sp : 152.sp,
                          crossAxisSpacing: 15.sp,
                          mainAxisSpacing: 15.sp,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final notification = filteredNotifications[index];
                          return _buildNotificationCard(
                              notification, isMobile, s);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
