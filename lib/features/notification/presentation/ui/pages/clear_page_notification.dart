/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: clear_page_notification.dart
/// Description: Cleared notifications, with restore and permanent delete.
/// Author: Amr Mesbah
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-NOTIF-N05/N06/N11/N14: the three UI `try` blocks are gone; the
///          drawer cubit is read from the tree; toasts are themed and localized;
///          the unsafe casts are guarded.
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_pop_up.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// new_theme imported from main_core above
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';

import 'package:knowticed_plus/generated/l10n.dart';
// using package:knowticed_plus/core/custom/32-custom_svg.dart (already imported)

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
// shared_action_widgets.dart already imported above
// shared_action_widgets.dart already imported above
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_filter_row.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_card.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

part '../widgets/clear_page_notification/cleaned_notification_land_page_state.dart';

// ✅ CLEANED NOTIFICATIONS PAGE - Shows only isClean == true
class CleanedNotificationLandPage extends StatefulWidget {
  const CleanedNotificationLandPage({super.key});

  @override
  State<CleanedNotificationLandPage> createState() =>
      _CleanedNotificationLandPageState();
}

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

class _NotificationContentState extends State<_NotificationContent> {
  String selectStatus = "All";
  TextEditingController searchController = TextEditingController();
  String sortOrder = "newest";

  /// False until the user picks a sort: the Sort button stays grey and the
  /// list is newest first. Picking turns the button yellow; picking the chosen
  /// row again clears it.
  bool sortChosen = false;

  /// Toolbar filters — the same four the inbox carries.
  /// CHANGED 22/10/2026 — Owner: multi-select; nothing ticked = all.
  NotificationFilterSelection filters =
      const NotificationFilterSelection.cleared();

  /// The cleaned notifications this page shows, before the toolbar
  /// narrows them. Feeds the By Type / Department option lists so neither menu
  /// offers a value that matches nothing here.
  List<NotificationModelSystem> _scopedNotifications() =>
      widget.allNotifications.where((n) => n.isClean).toList();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ✅ ONLY show CLEANED notifications (isClean == true) - EXACT MATCH TO MAIN PAGE
  List<NotificationModelSystem> _getFilteredNotifications() {
    List<NotificationModelSystem> filtered = widget.allNotifications;

    // ✅ DEBUG: Print all notifications before filtering

    // ✅ ONLY show CLEANED notifications (isClean == true)
    filtered = filtered.where((n) => n.isClean == true).toList();

    // ✅ FIXED: Module filter with better debugging (EXACT MATCH TO MAIN PAGE)
    // Resolved through NotificationRouting so role-area notifications file
    // under the Roles chip; the "All" test accepts the localized label too.
    if (selectStatus != "All" && selectStatus != S.of(context).all) {
      final String moduleFilter = _getModuleKeyFromName(selectStatus);

      filtered = filtered
          .where((n) => _moduleKeyOf(n.nameOfModule) == moduleFilter)
          .toList();
    }

    // Search filter
    if (searchController.text.isNotEmpty) {
      String query = searchController.text.toLowerCase();
      filtered = filtered.where((n) {
        // displayBody, not body — search matches what the card shows. See the
        // model: the "Reason: …" clause is stripped from every card.
        // Both languages: a notification is stored in English AND Arabic
        // (30/8/2026), so searching only the English half would miss a card
        // the user is currently looking at in Arabic. See the model.
        return n.searchText.contains(query);
      }).toList();
    }

    // Toolbar filters — sender type / module / department / time window.
    filtered = NotificationFilters.apply(
      source: filtered,
      employeeController: widget.employeeController,
      selection: filters,
    );

    // Sort by timestamp
    filtered.sort((a, b) {
      if (sortOrder == "newest") {
        return (b.timestamp).compareTo(a.timestamp);
      } else {
        return (a.timestamp).compareTo(b.timestamp);
      }
    });

    return filtered;
  }

  // ✅ FIXED: Better module name matching (EXACT MATCH TO MAIN PAGE)
  String _getModuleKeyFromName(String displayName) {
    for (Modules module in widget.allowedModules) {
      if (module.getModuleName == displayName) {
        String key = _moduleEnumToKey(module);
        return key;
      }
    }

    return displayName.toLowerCase();
  }

  // ✅ FIXED: Ensure exact match with Firebase naming (EXACT MATCH TO MAIN PAGE)
  String _moduleEnumToKey(Modules module) {
    switch (module) {
      case Modules.services:
        return 'services';
      case Modules.roles:
        return 'roles';
      case Modules.tasks:
        return 'tasks';
      case Modules.employees:
        return 'employees';
      case Modules.inventory:
        return 'inventory';
      case Modules.messages:
        return 'messages';
      case Modules.knowledgeHub:
        return 'knowledgeHub'; // ✅ Matches Firebase exactly
      case Modules.qiyas:
        return 'qiyas';
      case Modules.formBuilder:
        return 'formBuilder'; // ✅ Changed from 'services_app'
      case Modules.timeTracker: // CHANGED 9/10/2026 (was Modules.tracking)
        return 'tracking';
      case Modules.todo:
        return 'todo';
      case Modules.grc:
        return 'grc';
      case Modules.database:
        return 'database';
      default:
        return module.name.toLowerCase();
    }
  }

  // ✅ Count ONLY cleaned notifications (EXACT MATCH TO MAIN PAGE)
  /// The chip key a stored notification belongs under. Notifications carry the
  /// fine-grained AppModule key (`user_access`, `user_management`,
  /// `role_management`…) while the chips are the drawer's coarser [Modules];
  /// NotificationRouting owns that mapping and collapses the three role-area
  /// keys onto [Modules.roles]. Same helper as notification_page.
  String? _moduleKeyOf(String storedModuleKey) {
    final Modules? module = NotificationRouting.moduleForStoredKey(
      storedModuleKey,
    );
    return module == null ? null : _moduleEnumToKey(module);
  }

  Map<String, int> _getNotificationCountsByModule() {
    Map<String, int> counts = {'all': 0};

    for (Modules module in widget.allowedModules) {
      String key = _moduleEnumToKey(module);
      counts[key] = 0;
    }

    for (var notification in widget.allNotifications) {
      // ✅ ONLY count CLEANED notifications
      if (!notification.isClean) continue;

      counts['all'] = (counts['all'] ?? 0) + 1;

      // Resolved, not string-matched — see [_moduleKeyOf].
      final String? key = _moduleKeyOf(notification.nameOfModule);
      if (key != null && counts.containsKey(key)) {
        counts[key] = counts[key]! + 1;
      }
    }

    return counts;
  }

  // ✅ RESTORE notification - set isClean to false
  /// Restores a cleared notification.
  ///
  /// `updateCleanStatus` already returns `false` on failure and catches at the
  /// repository boundary, so the page-level `try/catch` here was redundant —
  /// and try is forbidden in presentation/ui/ anyway (§11.2,
  /// CR-SKEL-NOTIF-N05).
  // Kept, unused, since the cards switched to the inbox's Message / Pin /
  // View on 26/8/2026 — one line in _buildNotificationCard puts it back.
  // ignore: unused_element
  Future<void> _handleRestore(NotificationModelSystem notification) async {
    // Snackbars removed: the list repaints from the updated clean status, so
    // a restore is visible without a toast, and a failure is silent. The
    // returned flag is no longer read — updateCleanStatus catches at the
    // repository boundary.
    await widget.notificationService.updateCleanStatus(notification.id!, false);
  }

  // ✅ DELETE permanently
  // Kept, unused — see the note on _handleRestore.
  // ignore: unused_element
  Future<void> _handleDelete(NotificationModelSystem notification) async {
    final s = S.of(context);
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_action_delete.json',
      confirmTitle: '${s.delete} ${s.notification}',
      confirmSubtitle: s.areYouSureToProceed,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () async {
        // `deleteNotification` returns false on failure and catches at the
        // repository boundary (CR-SKEL-NOTIF-N05).
        final bool deleted = await widget.notificationService
            .deleteNotification(notification.id!);
        // Snackbar removed: showDialogFlow already skips its success step
        // when this returns false.
        return deleted;
      },
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: s.deleted,
      successSubtitle: '',
    );
  }

  /// Function Name: [_handleDeleteAll]
  ///
  /// Purpose: Permanently delete every cleared notification.
  ///
  /// Confirm -> delete -> success, through CustomDialogManager.showDialogFlow,
  /// the same flow the single-row Delete uses. `deleteAllCleaned` returns
  /// false on failure and catches at the repository boundary, so a failed
  /// batch never shows the success step.
  Future<void> _handleDeleteAll() async {
    final s = S.of(context);
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_action_delete.json',
      confirmTitle: s.deleteAllNotifications,
      confirmSubtitle: s.areYouSureDeleteAllCleared,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      // 22/10/2026 — Owner: like Clean All, Delete All acts on what is ON
      // SCREEN (module chip + filters + search); on "All" that is every
      // cleared notification.
      onConfirm: () async => widget.notificationService.deleteNotifications(
        <String>[
          for (final NotificationModelSystem n in _getFilteredNotifications())
            if (n.id != null) n.id!,
        ],
      ),
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: s.allNotificationsDeleted,
      successSubtitle: s.youSuccessfullyDeletedAllNotifications,
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

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.sizeOf(context).width >= 900;
    var isMobile = ContextExtension(context).isPhone;
    final s = S.of(context);

    List<NotificationModelSystem> filteredNotifications =
        _getFilteredNotifications();
    Map<String, int> moduleCounts = _getNotificationCountsByModule();

    // Owner 21/10/2026 14:53 (pinned rows, same as the main page): the rows
    // above the cards stay put and only the cards scroll. SideFrameBoundedBody
    // bounds the Column on the phone, where the frame scrolls its child.
    return SideFrameBoundedBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statusChip(
                  moduleCounts['all'].toString(),
                  s.all,
                  isSelected: selectStatus == s.all,
                  onTap: () => setState(() => selectStatus = s.all),
                  labelColor: selectStatus == s.all
                      ? AppColors.text
                      : AppColors.secondaryText,
                ),
                ...() {
                  List<Map<String, dynamic>> moduleData =
                      widget.allowedModules.map((module) {
                    String moduleKey = _moduleEnumToKey(module);
                    int count = moduleCounts[moduleKey] ?? 0;
                    return {
                      'module': module,
                      'moduleKey': moduleKey,
                      'count': count,
                      'displayName': module.getModuleName,
                    };
                  }).toList();

                  // Was `(b['count'] as int)` — a missing or wrongly-typed field threw
                  // during build (CR-SKEL-NOTIF-N11).
                  moduleData.sort(
                    (a, b) => ((b['count'] as num?)?.toInt() ?? 0).compareTo(
                      (a['count'] as num?)?.toInt() ?? 0,
                    ),
                  );

                  return moduleData.map<Widget>((data) {
                    return _statusChip(
                      data['count'].toString(),
                      data['displayName'] as String,
                      isSelected: selectStatus == data['displayName'],
                      onTap: () => setState(
                        () => selectStatus =
                            data['displayName']?.toString() ?? '',
                      ),
                      labelColor: selectStatus == data['displayName']
                          ? AppColors.text
                          : AppColors.secondaryText,
                    );
                  }).toList();
                }(),
              ],
            ),
          ),
          SizedBox(height: 15.sp),

          // Search and Sort
          Row(
            children: [
              AppSearchTextField(
                controller: searchController,
                onChanged: (val) => setState(() {}),
              ),
              SizedBox(width: ButtonSizing.toolbarGap(context)),
              // Owner 21/10/2026 14:53: on the phone the four filter
              // dropdowns go into the dialog (same as the main page) and
              // this Filter icon sits between Search and Sort.
              if (NotificationFilters.inDialog(context,
                  isMobile: isMobile)) ...[
                CustomFilterIcon(
                  iconOnly: true,
                  active: filters.isFiltering,
                  onTap: () async {
                    final NotificationFilterSelection? picked =
                        await showNotificationFilterDialog(
                      context: context,
                      notifications: _scopedNotifications(),
                      employeeController: widget.employeeController,
                      current: filters,
                    );
                    if (picked == null || !mounted) return;
                    setState(() => filters = picked);
                  },
                ),
                SizedBox(width: ButtonSizing.toolbarGap(context)),
              ],
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
              // Delete All — the Cleared page's counterpart to the inbox's
              // CleanAll. Only drawn when there is something to delete, so it
              // never opens a dialog over an empty list.
              if (_scopedNotifications().isNotEmpty) ...[
                SizedBox(width: ButtonSizing.toolbarGap(context)),
                GestureDetector(
                  onTapDown: hapticDown(_handleDeleteAll, HapticLevel.high),
                  onTap: _handleDeleteAll,
                  // 22/10/2026 (Moataz: "the height is not consistent with
                  // the Sort and the Search bar"): was 38.h — a share of the
                  // SCREEN height, ~58 on a tall iPad — next to Search and
                  // Sort at the house height. Now ButtonSizing.height, like
                  // the inbox's Clean All; square on the phone.
                  child: Container(
                    width: isMobile ? ButtonSizing.height : 130.w,
                    height: ButtonSizing.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: AppColors.red,
                    ),
                    child: isMobile
                        ? Center(
                            child: CustomSvgImage(
                              assetPath:
                                  "assets/icons_assets/notification_assets/ic_action_clear_all.svg",
                              width: 20.r,
                              height: 20.r,
                              fit: BoxFit.scaleDown,
                              color: AppColors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomSvgImage(
                                assetPath:
                                    "assets/icons_assets/notification_assets/ic_action_clear_all.svg",
                                width: 20.r,
                                height: 20.r,
                                fit: BoxFit.scaleDown,
                                color: AppColors.white,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                s.deleteAll,
                                style: StyleText.fontSize16Weight500.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 15.sp),

          // Sender Type / By Type / Department / Time — same row as the inbox.
          if (!NotificationFilters.inDialog(context, isMobile: isMobile))
            NotificationFilterRow(
              notifications: _scopedNotifications(),
              employeeController: widget.employeeController,
              isMobile: isMobile,
              selection: filters,
              // 22/10/2026 — Time = Custom now opens the range calendar here
              // too (the Pinned and Cleared rows never passed the range).
              onChanged: (v) => setState(() => filters = v),
            ),

          SizedBox(height: 15.sp),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: // Grid or Empty
                  filteredNotifications.isEmpty
                      ? Center(
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
                        )
                      : isMobile
                          // Owner 21/10/2026 14:53: on the phone every card is its
                          // CONTENT height (no fixed cell, no empty band, no "…").
                          ? ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredNotifications.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 15.sp),
                              itemBuilder: (context, index) {
                                final notification =
                                    filteredNotifications[index];
                                return _buildNotificationCard(
                                    notification, isMobile, s);
                              },
                            )
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                // Owner 21/10/2026 14:45: one card per row on iPad portrait.
                                crossAxisCount: (isDesktop &&
                                        MediaQuery.of(context).orientation ==
                                            Orientation.landscape)
                                    ? 2
                                    : 1,
                                // 185.sp, matching the inbox — the card is shared now, so
                                // the tile it sits in has to be too. 180.sp left it 5px short.
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
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredNotifications.length,
                              itemBuilder: (context, index) {
                                final notification =
                                    filteredNotifications[index];
                                return _buildNotificationCard(
                                    notification, isMobile, s);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  /// One card — the inbox's, buttons included.
  ///
  /// CHANGED 26/8/2026: this is now a copy of `notification_page.dart`'s
  /// `_buildNotificationCard`, line for line. Message on top for a card from a
  /// person, Pin and View beneath, exactly as the inbox draws it. It previously
  /// passed this page's own Restore / Delete / View, which is what made the
  /// cards here look unlike the inbox's even after both moved onto the shared
  /// [NotificationCard].
  ///
  /// ⚠️ Restore and Delete are therefore no longer on the cards. The page's
  /// Delete All button still clears the list, but per-notification restore and
  /// delete have no entry point left. [_handleRestore] and [_handleDelete] are
  /// kept below, unused, so putting either back is a one-line change here.
  Widget _buildNotificationCard(
    NotificationModelSystem notification,
    bool isMobile,
    S s,
  ) {
    // No Message button on a system notification (nobody to message) nor on
    // a To-Do one (personal — owner, 7/10/2026). Same rule the card uses.
    final bool hasHumanSender = NotificationCard.hasSenderSection(
      notification,
      widget.employeeController,
    );

    return NotificationCard(
      notification: notification,
      employeeController: widget.employeeController,
      isMobile: isMobile,
      onTap: () => _handleViewNotification(notification),
      primaryAction: hasHumanSender
          ? NotificationCardAction(
              title: s.message,
              iconPath:
                  "assets/icons_assets/main_icons_assets/ic_comms_chat_double.svg",
              onTap: () => _handleMessageSender(notification),
            )
          : null,
      leadingAction: NotificationCardAction(
        // Same button pins and unpins; yellow either way (owner 22/10/2026),
        // so the LABEL says which one it is.
        title: notification.isPinned ? s.unpin : s.pin,
        iconPath: "assets/icons_assets/main_icons_assets/ic_action_pin.svg",
        onTap: () => _handlePinToggle(notification),
      ),
      trailingAction: NotificationCardAction(
        title: s.view,
        iconPath:
            "assets/icons_assets/notification_assets/ic_action_view_document.svg",
        onTap: () => _handleViewNotification(notification),
      ),
    );
  }

  /// Messaging the sender is not implemented anywhere in the app — the inbox's
  /// handler is a no-op too. Copied here so the Message button behaves
  /// identically on both pages rather than being wired to something this page
  /// invented.
  // WIRED 21/9/2026 — was a no-op. See NotificationRouting.messageSender.
  void _handleMessageSender(NotificationModelSystem notification) =>
      NotificationRouting.messageSender(context, notification);

  /// Pin / unpin, same as the inbox's.
  Future<void> _handlePinToggle(NotificationModelSystem notification) async {
    final bool newPinStatus = !notification.isPinned;
    await widget.notificationService.updatePinStatus(
      notification.id!,
      newPinStatus,
    );
  }

  Widget _statusChip(
    String count,
    String label, {
    required bool isSelected,
    required Color labelColor,
    required VoidCallback onTap,
  }) {
    var light = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return GestureDetector(
      onTap: withHaptic(onTap, HapticLevel.low),
      child: Row(
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: light
                  ? (isSelected ? AppColors.primary : AppColors.card)
                  : (isSelected ? AppColors.primary : AppColors.card),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: isMobile
                    ? StyleText.fontSize14Weight400.copyWith(
                        color: light
                            ? (AppColors.secondaryText)
                            : (isSelected
                                ? AppColors.textButton
                                : AppColors.text),
                      )
                    : StyleText.fontSize20Weight500.copyWith(
                        color: light
                            ? (isSelected
                                ? AppColors.textButton
                                : AppColors.secondaryText)
                            : (isSelected
                                ? AppColors.textButton
                                : AppColors.text),
                      ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            label,
            style: isMobile
                ? StyleText.fontSize14Weight600.copyWith(color: labelColor)
                : StyleText.fontSize16Weight600.copyWith(color: labelColor),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}
