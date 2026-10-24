/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_control.dart
/// Purpose: The notification-settings screen: per-module templates and toggles.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-NOTIF-N05/N14: the dead `_debugControllerState` — whose body was
///          commented-out prints in two empty `try/catch` blocks — is deleted;
///          raw colours route through AppColors.
///
/// Updated: 2/9/2026 - "Reset all in this module" is gated on
///          NotificationPermissions.editNotification. The other four
///          Notification Control permissions are enforced on
///          `NotificationEditPage`, which is where a single template is
///          actually changed.
///
/// Updated: 9/10/2026 - Time Tracker QA KP-TT-018 (shared module → Amr's
///          handover): the edit panel's Preview · Discard · Save row is a
///          sticky footer that always fits (`NotificationEditActions` —
///          was three fixed 150.w buttons, "RIGHT OVERFLOWED BY 191 PIXELS"
///          on iPad portrait with Save off-screen), and "Notification
///          Status" + "Reset Default Messages" wrap instead of overflowing
///          (`NotificationStatusHeader`), on tablet and phone.
///
/// REMAINING (CR-SKEL-NOTIF-N02): still ~1,800 LOC, over the 1,500 gate.
library;

import 'package:knowticed_plus/core/custom/dialogs/custom_confirm_dialog.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/inputs/field_sizing.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/default_switch_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_segmented_toggle.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/custom_tab_ar.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_template_editor.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_edit_layout.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_sections_list.dart';
import 'package:knowticed_plus/generated/l10n.dart';

// REMOVED_MODULE: import 'package:knowticed_plus/external/knowledge_hub_module/core/theming/new_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/knowledge_hub_module/core/app_multi_select_drop_down.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/layout/app_scroll_behavior.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/todo_module/core/components/other_components/flutter_switch.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_model.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_catalog.dart';
// `NotificationEvent` is imported for its `.title(isArabic:)` extension —
// extensions are only in scope in files that import their declaring library.
import 'package:knowticed_plus/features/notification/domain/enums/notification_event.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_edit_page.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_preview_page.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
// ADDED 2/9/2026 — the Notification Control role permissions.
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/notification/notification_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/notification/notification_sections_enum.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Tabs of the Notification Control screen.
///
/// Each tab is just a view onto a [AppModule]. Tabs whose [module]
/// is null are legacy placeholders kept so older navigation code still
/// compiles — they are filtered out of the UI by `_isTabVisible`.
enum NotificationTab {
  knowledgeHub(AppModule.knowledgeHub),
  todo(AppModule.todo),
  services(AppModule.services),
  roles(AppModule.roleManagement),
  userAccess(AppModule.userAccess),
  userManagement(AppModule.userManagement),
  tracking(AppModule.timeTracker),
  database(AppModule.database),
  qiyas(AppModule.qiyas),
  grc(AppModule.grc),
  // Owner 22/10/2026: every module that sends notifications has a tab.
  messages(AppModule.messages),
  formBuilder(AppModule.formBuilder),
  settings(AppModule.settings),
  notificationControl(AppModule.notificationControl),

  // ── legacy tabs: no events defined in the spec, hidden from the UI ──
  employees(null),
  tasks(null),
  inventory(null),
  requests(null),
  events(null),
  notes(null),
  hr(null);

  const NotificationTab(this.module);

  /// The module this tab edits, or null for a legacy placeholder tab.
  final AppModule? module;

  static NotificationTab? forModule(AppModule module) {
    for (final t in values) {
      if (t.module == module) return t;
    }
    return null;
  }
}

class NotificationControlPage extends StatefulWidget {
  const NotificationControlPage({super.key});

  @override
  State<NotificationControlPage> createState() =>
      _NotificationControlPageState();
}

class _NotificationControlPageState extends State<NotificationControlPage> {
  NotificationTab selectedTab = NotificationTab.services;

  // Edit mode state
  bool isEditMode = false;
  bool isSaving = false;

  // ✅ Add loading state
  bool isLoadingTemplates = true;

  // Selected notification types
  List<String> selectedNotificationTypes = [];

  /// Email (Subject + Body) and Push (Title + Description), EN and AR.
  final NotificationTemplateControllers templateText =
      NotificationTemplateControllers();

  // Add selected notification item index
  int? selectedNotificationIndex;

  // ✅ Current template being edited
  NotificationTemplateModel? currentTemplate;

  // ✅ Notification template service
  final NotificationTemplateService _templateService =
      NotificationTemplateService();

  // ✅ Toggle state for notification status
  bool isNotificationEnabled = true;

  // ✅ Store loaded templates from Firebase for each event
  Map<String, NotificationTemplateModel> loadedTemplates = {};

  // ✅ Cache the notification items list to prevent rebuilding
  List<NotificationItem>? _cachedNotificationItems;

  /// True while [_confirmResetModuleToDefaults] is writing. Disables the
  /// module reset action so a double-tap cannot start two bulk writes.
  // Owner 21/10/2026: kept for the removed "Reset all in this module" button (UI only removed).
  // ignore: unused_field
  bool _isResettingModule = false;

  /// ADDED 2/9/2026 — NotificationPermissions.editNotification.
  ///
  /// Only ONE control on this screen writes anything: "Reset all in this
  /// module", which rewrites every template in the selected tab in one bulk
  /// pass. Everything else here is a list, and the per-template rights are
  /// enforced on `NotificationEditPage` where the edits actually happen — so
  /// this screen needs exactly one permission, not five.
  ///
  /// Read once in [initState]: a role cannot change while the screen is open.
  // Owner 21/10/2026: kept for the removed "Reset all in this module" button (UI only removed).
  // ignore: unused_field
  bool _canEditNotification = false;

  @override
  void initState() {
    super.initState();

    _canEditNotification =
        Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.notification,
      section: NotificationPermissionsSections.notificationControl,
      permission: NotificationPermissions.editNotification,
    );

    // ✅ CRITICAL DEBUG: Check if controller exists BEFORE filtering

    // ✅ Set selected tab to first visible tab
    final visibleTabs = _getVisibleTabs();

    if (visibleTabs.isNotEmpty) {
      selectedTab = visibleTabs.first;
    } else {
      // Fallback to home if no tabs are visible
      // selectedTab = NotificationTab.home;
    }

    // ✅ Load templates AFTER first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllTemplatesForTab();
    });
  }

  @override
  void dispose() {
    templateText.dispose();
    super.dispose();
  }

  // `_debugControllerState()` was deleted: a debug probe whose entire body was
  // commented-out prints wrapped in two empty `try/catch` blocks — try is
  // forbidden in presentation/ui/ (§11.2, CR-SKEL-NOTIF-N05).

  // ✅ Load all templates for current tab from Firebase
  Future<void> _loadAllTemplatesForTab() async {
    if (!mounted) return;

    setState(() {
      isLoadingTemplates = true;
      _cachedNotificationItems = null;
    });

    final items = _getDefaultNotificationItems();
    final moduleName = getModuleName(selectedTab);

    loadedTemplates.clear();

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final template = await _templateService.getTemplate(
        module: moduleName,
        eventType: item.eventType,
      );

      if (template != null) {
        loadedTemplates[item.eventType] = template;
        // '✅ Loaded: ${item.eventType} - Enabled: ${template.isEnabled}, Email: ${template.hasEmail}, Push: ${template.hasPush}');
      } else {}
    }

    if (!mounted) return;

    setState(() {
      isLoadingTemplates = false;
      _cachedNotificationItems = _buildNotificationItems();
      _cachedItemsLocale = Localizations.localeOf(context);
    });

    // Owner 22/10/2026 (Figma): the tablet opens with the first notification
    // selected, never an empty "Text Here" message.
    if (!ContextExtension(context).isPhone &&
        selectedNotificationIndex == null &&
        (_cachedNotificationItems?.isNotEmpty ?? false)) {
      setState(() => selectedNotificationIndex = 0);
      await _loadTemplate();
    }
  }

  // ✅ Build notification items with Firebase data
  List<NotificationItem> _buildNotificationItems() {
    final items = _getDefaultNotificationItems();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return items.map((item) {
      final template = loadedTemplates[item.eventType];
      if (template == null) return item;

      // Show the ADMIN-EDITED subject, not the enum default. The enum text is
      // only a fallback — once someone renames a notification in this screen
      // the row must show the new name, otherwise the list and the message
      // that actually goes out disagree.
      final saved = isArabic ? template.subjectArabic : template.subjectEnglish;

      return NotificationItem(
        title: saved.trim().isEmpty ? item.title : saved,
        eventType: item.eventType,
        group: item.group,
        isEnabled: template.isEnabled,
        hasEmail: template.hasEmail,
        hasPush: template.hasPush,
      );
    }).toList();
  }

  /// Locale the cached rows were built for.
  ///
  /// FIXED 22/8/2026 — this is the "localization" arrow on the Request Status
  /// list. Both `_getDefaultNotificationItems` and `_buildNotificationItems`
  /// resolve their text from `Localizations.localeOf(context)`, so each row's
  /// title IS translated — but only at the moment it is built. The result was
  /// cached in `_cachedNotificationItems` and only ever rebuilt by
  /// `_loadAllTemplatesForTab`, i.e. on a tab change. Switching the app to
  /// Arabic left every row sitting in the language it was first rendered in,
  /// which is why an otherwise fully-Arabic screen listed
  /// "Account Successfully Activated" in English.
  Locale? _cachedItemsLocale;

  // ✅ Get notification items (uses cache to prevent rebuilds)
  List<NotificationItem> getNotificationItems() {
    final Locale locale = Localizations.localeOf(context);

    // The cache is keyed on the locale now: a language switch invalidates it,
    // anything else still hits it.
    if (_cachedNotificationItems != null && _cachedItemsLocale == locale) {
      return _cachedNotificationItems!;
    }

    final List<NotificationItem> items = _buildNotificationItems();
    _cachedNotificationItems = items;
    _cachedItemsLocale = locale;
    return items;
  }

  // ✅ ENHANCED: Add detailed debugging for tab visibility checking
  // Notification tabs are no longer permission-gated: the per-module
  // NotificationPermissions enums were removed, so there is nothing left to
  // grant or deny against. Every tab is visible.
  /// A tab is shown when its module actually has events in the catalog.
  /// Legacy placeholder tabs (module == null) are hidden.
  bool _isTabVisible(NotificationTab tab) {
    final module = tab.module;
    return module != null && NotificationCatalog.eventsOf(module).isNotEmpty;
  }

  List<NotificationTab> _getVisibleTabs() {
    final visibleTabs = <NotificationTab>[];

    for (var tab in NotificationTab.values) {
      final isVisible = _isTabVisible(tab);
      if (isVisible) {
        visibleTabs.add(tab);
      } else {}
    }

    return visibleTabs;
  }

  // ✅ ENHANCED: Add permission enum to database name mapping debug

  // ✅ Notification rows come straight from the module event catalog.
  //
  // This used to be a ~530-line hardcoded switch that duplicated the default
  // templates in notification_template_service.dart. Both now read the same
  // per-module enums in domain/enums/<module>_module/.
  List<NotificationItem> _getDefaultNotificationItems() {
    final module = selectedTab.module;
    if (module == null) return const [];

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return NotificationCatalog.eventsOf(module)
        .map((event) => NotificationItem(
              title: event.title(isArabic: isArabic),
              eventType: event.key,
              group: event.group,
              isEnabled: true,
              hasEmail: true,
              hasPush: true,
            ))
        .toList();
  }

  String getTabName(NotificationTab tab) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return tab.module?.label(isArabic: isArabic) ?? tab.name;
  }

  /// Firestore module key for a tab — never a raw string.
  String getModuleName(NotificationTab tab) => tab.module?.key ?? tab.name;
  // ✅ Load template when notification item is selected
  Future<void> _loadTemplate() async {
    if (selectedNotificationIndex == null) {
      return;
    }

    final items = getNotificationItems();
    final selectedItem = items[selectedNotificationIndex!];
    final moduleName = getModuleName(selectedTab);

    NotificationTemplateModel? template = await _templateService.getTemplate(
      module: moduleName,
      eventType: selectedItem.eventType,
    );

    if (template != null) {
      setState(() {
        _submitted = false;
        currentTemplate = template;
        isNotificationEnabled = template.isEnabled;
        selectedNotificationTypes =
            List.from(template.selectedNotificationTypes);

        templateText.subjectEn.text = template.subjectEnglish;
        templateText.subjectAr.text = template.subjectArabic;
        templateText.bodyEn.text = template.bodyEnglish;
        templateText.bodyAr.text = template.bodyArabic;
        templateText.pushTitleEn.text = template.pushTitleEn;
        templateText.pushTitleAr.text = template.pushTitleAr;
        templateText.pushBodyEn.text = template.pushBodyEn;
        templateText.pushBodyAr.text = template.pushBodyAr;
      });
    } else {}
  }

  String _getSelectedNotificationTypesText(bool isRTL) {
    if (selectedNotificationTypes.isEmpty) {
      return isRTL ? "اختر نوع الإشعار" : "Select Notification Type";
    }

    List<String> displayNames = selectedNotificationTypes.map((type) {
      if (isRTL) {
        return type == "email" ? "البريد الإلكتروني" : "إشعار الهاتف";
      } else {
        return type == "email" ? "Email" : "Push Notification";
      }
    }).toList();

    return displayNames.join(", ");
  }

  String _getNotificationTypeKey(String displayName, bool isRTL) {
    if (isRTL) {
      return displayName == "البريد الإلكتروني" ? "email" : "push";
    } else {
      return displayName == "Email" ? "email" : "push";
    }
  }

  Future<bool> _saveTemplate() async {
    if (currentTemplate == null) {
      return false;
    }

    // Every one of the eight texts is needed (Email and Push, EN and AR).
    if (templateText.invalidChannel() != null) {
      return false;
    }

    setState(() {
      isSaving = true;
    });

    final updatedTemplate = currentTemplate!.copyWith(
      subjectEnglish: templateText.subjectEn.text.trim(),
      subjectArabic: templateText.subjectAr.text.trim(),
      bodyEnglish: templateText.bodyEn.text.trim(),
      bodyArabic: templateText.bodyAr.text.trim(),
      pushTitleEnglish: templateText.pushTitleEn.text.trim(),
      pushTitleArabic: templateText.pushTitleAr.text.trim(),
      pushBodyEnglish: templateText.pushBodyEn.text.trim(),
      pushBodyArabic: templateText.pushBodyAr.text.trim(),
      isEnabled: isNotificationEnabled,
      selectedNotificationTypes: selectedNotificationTypes,
      updatedAt: DateTime.now(),
    );

    final success = await _templateService.saveTemplate(updatedTemplate);

    setState(() {
      isSaving = false;
    });

    if (success) {
      setState(() {
        currentTemplate = updatedTemplate;
        loadedTemplates[updatedTemplate.eventType] = updatedTemplate;
        _cachedNotificationItems = null;
        _submitted = false;
      });
    }
    return success;
  }

  /// Owner 22/10/2026: true once Save was pressed — the fields then show
  /// their errors (R-6). Reset whenever a template is loaded.
  bool _submitted = false;

  /// Save is offered only when something differs from the stored template.
  bool get _hasChanges {
    final NotificationTemplateModel? t = currentTemplate;
    if (t == null) return false;
    return templateText.differsFrom(t) ||
        isNotificationEnabled != t.isEnabled ||
        selectedNotificationTypes
            .toSet()
            .difference(t.selectedNotificationTypes.toSet())
            .isNotEmpty ||
        t.selectedNotificationTypes
            .toSet()
            .difference(selectedNotificationTypes.toSet())
            .isNotEmpty;
  }

  /// Save: show the errors (and the channel that has them) if anything is
  /// missing; otherwise confirm → save → success, the app's standard flow.
  Future<void> _onSavePressed() async {
    if (!_hasChanges || isSaving) return;
    setState(() => _submitted = true);
    final String? bad = templateText.invalidChannel();
    if (bad != null) {
      setState(() => isEmailView = bad == 'email');
      return;
    }
    final bool isAr = Directionality.of(context) == TextDirection.rtl;
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json',
      confirmTitle: S.of(context).saveChanges,
      confirmSubtitle: isAr
          ? 'هل تريد حفظ التغييرات على هذا الإشعار؟'
          : 'Do you want to save the changes to this notification?',
      confirmYesText: S.of(context).confirm,
      confirmNoText: S.of(context).cancel,
      onConfirm: _saveTemplate,
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: S.of(context).Successful,
      successSubtitle:
          isAr ? 'تم حفظ الإشعار بنجاح' : 'The notification was saved.',
    );
  }

  // 23/10/2026 (Moataz): Reset overwrites the template, so it asks first
  // ("Are you sure?") like Save does, then resets and says it worked.
  Future<void> _resetToDefault() async {
    if (selectedNotificationIndex == null) {
      return;
    }

    final items = getNotificationItems();
    final selectedItem = items[selectedNotificationIndex!];
    final moduleName = getModuleName(selectedTab);
    final bool isAr = Directionality.of(context) == TextDirection.rtl;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_action_restore.json',
      confirmTitle: isAr ? 'استعادة الرسائل الافتراضية' : 'Reset to default',
      confirmSubtitle: isAr
          ? 'هل أنت متأكد أنك تريد استعادة الرسائل الافتراضية لهذا الإشعار؟ ستُستبدل رسائلك الحالية.'
          : 'Are you sure you want to reset this notification to its default messages? Your current messages will be replaced.',
      confirmYesText: S.of(context).confirm,
      confirmNoText: S.of(context).cancel,
      confirmWidth: 411,
      successWidth: 411,
      onConfirm: () async {
        final success = await _templateService.resetToDefault(
          module: moduleName,
          eventType: selectedItem.eventType,
        );
        if (success) {
          await _loadTemplate();
          await _loadAllTemplatesForTab();
        }
        return success;
      },
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: S.of(context).Successful,
      successSubtitle: isAr
          ? 'تمت استعادة الرسائل الافتراضية.'
          : 'The default messages were restored.',
    );
  }

  /// ══════════════════════════════════════════════════════════════════
  ///  RESET A WHOLE MODULE                            ADDED 30/8/2026
  ///
  ///  [_resetToDefault] above fixes ONE event. It exists because the enum
  ///  catalog is the spec's text and Firestore's saved template overrides it:
  ///  `NotificationTemplateService.getTemplate` returns the stored document
  ///  whenever one exists and only falls back to the catalog when it does not.
  ///  So when the spec wording changes, every module whose templates were
  ///  already seeded keeps serving the OLD text — correct in code, wrong in
  ///  the app — and the only cure was opening each event in turn and tapping
  ///  "Reset Default" (fourteen times for Service Management alone).
  ///
  ///  This is that, for the whole tab, in one action.
  /// ══════════════════════════════════════════════════════════════════

  /// Function Name: [_confirmResetModuleToDefaults]
  ///
  /// Purpose: Ask, then rewrite every template in the selected tab's module
  /// back to its catalog default.
  ///
  /// Parameters:
  /// - [isRTL]: the active direction, for the dialog's wording.
  ///
  /// Returns: [Future<void>]. Confirmation is required because this discards
  /// admin edits — that is the point of the action, but it is not undoable.
  // Owner 21/10/2026: kept for the removed "Reset all in this module" button (UI only removed).
  // ignore: unused_element
  Future<void> _confirmResetModuleToDefaults(bool isRTL) async {
    final AppModule? module = selectedTab.module;
    if (module == null) return;

    final String moduleLabel = module.label(isArabic: isRTL);

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: S.of(context).resetModuleNotifications,
      subtitle: S.of(context).resetModuleNotificationsBody(moduleLabel),
      cancelLabel: S.of(context).cancel,
      confirmLabel: S.of(context).reset,
      lottieAsset:
          'assets/lottie_assets/main_lottie_assets/lot_action_restore.json',
      onConfirm: () => confirmed = true,
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() {
      _isResettingModule = true;
      isEditMode = false;
      selectedNotificationIndex = null;
      _clearFields();
    });

    await _templateService.resetModuleToDefaults(module);

    if (!mounted) return;
    setState(() => _isResettingModule = false);

    // No snackbar, for the reason [_resetToDefault] gives: the reloaded rows
    // repainting with the default text IS the confirmation.
    await _loadAllTemplatesForTab();
  }

  void _clearFields() {
    templateText.clear();
    currentTemplate = null;
    isNotificationEnabled = true;
    selectedNotificationTypes = [];
  }

  // _getVariablesHintText was replaced 22/10/2026 by the variable chips in
  // NotificationTemplateEditor.

  /// Function Name: [_editActions]
  ///
  /// Purpose: ADDED 9/10/2026 (Time Tracker QA KP-TT-018) — the edit panel's
  /// Preview · Discard · Save footer (same colours and actions as the old
  /// fixed row), laid out to fit any panel width.
  ///
  /// Returns: [Widget]
  Widget _editActions(BuildContext context, bool isRTL, bool lightMode) {
    // Owner 22/10/2026 (Figma edit mode): Preview on the start side with
    // Discard under it, Save on the end side.
    Widget button(String key, String title, VoidCallback onTap, Color color,
            Color textColor) =>
        KeyedSubtree(
          key: ValueKey<String>(key),
          child: customButton(
            title: title,
            function: onTap,
            width: 150.w,
            height: 38.h,
            radius: 8.r,
            color: color,
            textStyle: StyleText.fontSize18Weight500.copyWith(color: textColor),
          ),
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            button(
                'notificationEditPreview',
                S.of(context).preview,
                () => _showPreviewDialog(context),
                // 23/10/2026 (Moataz): Preview is yellow everywhere (it was
                // grey on iPad / Mac and yellow on the phone).
                AppColors.primary,
                AppColors.textButton),
            SizedBox(height: 12.sp),
            // ADDED 22/8/2026: Discard reloads the stored template and drops
            // back out of edit mode without writing anything.
            button('notificationEditDiscard', S.of(context).discard,
                _discardChanges, AppColors.darkGrey, AppColors.text),
          ],
        ),
        const Spacer(),
        // R-3: grey, 50%, not tappable until something changed.
        Opacity(
          opacity: _hasChanges ? 1 : 0.5,
          child: AbsorbPointer(
            absorbing: !_hasChanges,
            child: button(
                'notificationEditSave',
                S.of(context).save,
                _onSavePressed,
                _hasChanges ? AppColors.primary : AppColors.grey,
                AppColors.textButton),
          ),
        ),
      ],
    );
  }

  /// Function Name: [_discardChanges]
  ///
  /// Purpose: Throw away unsaved edits to the selected template.
  ///
  /// Added 22/8/2026. The action row offered Preview and Save and nothing
  /// else, so a message typed by mistake could only be undone by retyping the
  /// original — and the ✕ that used to sit up beside "Reset Default Messages"
  /// left edit mode without restoring the fields, which is worse than nothing.
  ///
  /// Re-reads the stored template (or the catalog default when Firestore has
  /// none) and leaves edit mode. Nothing is written.
  Future<void> _discardChanges() async {
    if (selectedNotificationIndex == null) {
      setState(() => isEditMode = false);
      return;
    }

    await _loadTemplate();

    if (!mounted) return;
    setState(() => isEditMode = false);
  }

  /// Owner 22/10/2026: Preview is its own page (Figma › Preview
  /// Notification) — the message beside a phone showing how it arrives.
  void _showPreviewDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => NotificationPreviewPage(
          controllers: templateText,
          module: selectedTab.module,
          isEmail: isEmailView,
          onSave: _hasChanges ? _onSavePressed : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // ✅ DEBUG: //print build state

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).notificationControl,
          pinnedTop: Container(
              padding:
                  // Owner 22/10/2026: tabs start on the page title's line.
                  const EdgeInsets.symmetric(vertical: 8),
              // FIXED 22/8/2026 — "make this scrollable right and left".
              //
              // The row was already inside a horizontal
              // SingleChildScrollView, so on a touch device it scrolled
              // fine. On desktop it did not: Flutter's default
              // ScrollBehavior does not list `PointerDeviceKind.mouse` in
              // `dragDevices`, and a vertical wheel does not drive a
              // horizontal scrollable — so with the last tab clipped at the
              // edge ("Databa…") there was no way to reach it at all.
              //
              // AppScrollBehavior (core/custom/90-app_scroll_behavior.dart)
              // adds mouse and trackpad to the drag devices, which is
              // exactly what this needs.
              child: ScrollConfiguration(
                behavior: const AppScrollBehavior(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _getVisibleTabs().map((tab) {
                      final isSelected = selectedTab == tab;
                      final tabName = getTabName(tab);

                      // Owner 22/10/2026: same tab row as Role Management
                      // (role_screen.dart) — 20 Medium, 32 apart, 1.5 underline.
                      return Padding(
                        padding: EdgeInsetsDirectional.only(end: 32.sp),
                        child: GestureDetector(
                          onTap: () async {
                            HapticController
                                .low(); // list row: on the tap (X-117)
                            setState(() {
                              selectedTab = tab;
                              isEditMode = false;
                              selectedNotificationIndex = null;
                              currentTemplate = null;
                              _clearFields();
                            });
                            await _loadAllTemplatesForTab();
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tabName,
                                style: StyleText.fontSize20Weight500.copyWith(
                                  height: 1.3,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.secondaryBlack,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              CustomTabUnderline(
                                text: tabName,
                                textStyle: StyleText.fontSize20Weight500
                                    .copyWith(height: 1.3),
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.transparent,
                                height: 1.5.sp,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Tab Bar
              // Owner 22/10/2026: the module tabs are pinned (pinnedTop) — only
              // the sections scroll under them.

              // Owner 21/10/2026: "Reset all in this module" button removed from the page (UI only; _confirmResetModuleToDefaults is kept).
              SizedBox(height: 20.h),
              if (_getVisibleTabs().isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 64.sp,
                          color: AppColors.secondaryText,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          isRTL
                              ? "لا توجد صلاحيات لعرض الإشعارات"
                              : "No notification permissions available",
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Owner 22/10/2026 (Figma iPhone): no Edit, Next or switch on
                // the phone list — a row opens that notification's own page.
                // Tablet: the Edit · switch row is in the right column.
                const SizedBox.shrink(),

              if (isMobile) SizedBox(height: 8.h),

              // ✅ Show loading indicator while fetching data
              if (isLoadingTemplates)
                isMobile
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: CircleProgressMaster()),
                        ],
                      )
                    : Expanded(
                        child: Center(child: CircleProgressMaster()),
                      )
              else
                // Content Area
                isMobile
                    // 23/10/2026 (Moataz, phone): the last section ended flush
                    // against the bottom nav; 24 of air under it.
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 24.sp),
                        child: NotificationSectionsList(
                          // The phone page body already scrolls (SideFrameMasterServices).
                          shrinkWrap: true,
                          items: getNotificationItems(),
                          selectedIndex: null,
                          onSelect: (int index) => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => NotificationEditPage(
                                notificationItem: getNotificationItems()[index],
                                moduleName: getModuleName(selectedTab),
                                currentTab: selectedTab,
                              ),
                            ),
                          ).then((_) => _loadAllTemplatesForTab()),
                        ))
                    : Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Owner 22/10/2026: each section draws its own card.
                            SizedBox(
                              width: 320.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: isLoadingTemplates
                                        ? Center(
                                            child: CircleProgressMaster.inline(
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : NotificationSectionsList(
                                            // Bottom of the first title on the
                                            // Edit row → both first cards start
                                            // on one line (owner 22/10/2026).
                                            firstTitleHeight:
                                                ButtonSizing.height,
                                            showStatus: !isEditMode,
                                            items: getNotificationItems(),
                                            selectedIndex:
                                                selectedNotificationIndex,
                                            onSelect: (int index) {
                                              setState(() =>
                                                  selectedNotificationIndex =
                                                      index);
                                              _loadTemplate();
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.sp), // R-1 / R-4: 16 apart
                            Expanded(
                              child: isLoadingTemplates
                                  ? Center(child: CircleProgressMaster())
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _desktopHeader(context),
                                        SizedBox(height: 8.sp),
                                        Expanded(
                                          // Scrolls only when it does not fit, and
                                          // never bounces (owner 22/10/2026: the
                                          // card slid under its own top edge).
                                          child: SingleChildScrollView(
                                            physics:
                                                const ClampingScrollPhysics(),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                if (isEditMode) ...[
                                                  // Figma edit mode: status card,
                                                  // then the Push | Email switch,
                                                  // then the message.
                                                  Container(
                                                    padding:
                                                        EdgeInsets.all(15.sp),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.card,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.r),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ..._statusCardChildren(
                                                            context, isRTL),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10.sp),
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .centerEnd,
                                                    child: _buildToggleButtons(
                                                        context),
                                                  ),
                                                  SizedBox(height: 10.sp),
                                                ],
                                                NotificationTemplateEditor(
                                                  controllers: templateText,
                                                  isEmail: isEmailView,
                                                  enabled: isEditMode,
                                                  submitted: _submitted,
                                                  module: selectedTab.module,
                                                  onChanged: () =>
                                                      setState(() {}),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Owner 22/10/2026: Preview · Discard · Save
                                        // exist only while editing.
                                        if (isEditMode) ...[
                                          SizedBox(height: 12.sp),
                                          _editActions(
                                              context, isRTL, lightMode),
                                        ],
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }

  /// The status card's content on the tablet / desktop editor.
  ///
  /// 23/10/2026 (Moataz): iPad PORTRAIT is laid out like the phone with the
  /// Reset button first — Reset Default Messages, then the status and its
  /// switch, then the channel at full width. LANDSCAPE (iPad and Mac) keeps
  /// the original: the status with Reset at the end of its row, and the
  /// channel in the left half.
  List<Widget> _statusCardChildren(BuildContext context, bool isRTL) {
    final bool portrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;

    final Widget statusIcon = CustomSvgImage(
      assetPath: "assets/icons_assets/main_icons_assets/ic_status.svg",
      width: 16.w,
      height: 16.h,
      fit: BoxFit.fill,
      color: AppColors.secondaryText,
    );
    final Widget statusTitle = Text(
      isRTL ? "حالة الإشعار" : "Notification Status",
      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
    );
    // Owner 21/10/2026: core DefaultSwitchButton.
    final Widget statusSwitch = DefaultSwitchButton(
      value: isNotificationEnabled,
      onChanged: (newValue) => setState(() => isNotificationEnabled = newValue),
    );
    Widget resetButton({double? width}) => customButton(
          title:
              isRTL ? "استعادة الرسائل الافتراضية" : "Reset Default Messages",
          function: _resetToDefault,
          color: AppColors.darkGrey,
          radius: 4.r,
          width: width,
          height: 30.h,
          textStyle:
              StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        );
    final Widget channelLabel = Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        isRTL ? "قناة الإشعار" : "Notification Channel",
        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      ),
    );
    final Widget channelField = CustomMultiSelectFilter<String>(
      values: selectedNotificationTypes.map((type) {
        if (isRTL) {
          return type == "email" ? "البريد الإلكتروني" : "إشعار الهاتف";
        }
        return type == "email" ? "Email" : "Push Notification";
      }).toList(),
      items: (isRTL
              ? ["البريد الإلكتروني", "إشعار الهاتف"]
              : ["Email", "Push Notification"])
          .map((e) => MultiSelectDropdownItem<String>(value: e, label: e))
          .toList(),
      selectedTextBuilder: (_) => _getSelectedNotificationTypesText(isRTL),
      hint: isRTL ? "اختر نوع الإشعار" : "Select Notification Type",
      onChanged: (selected) {
        setState(() {
          selectedNotificationTypes
            ..clear()
            ..addAll(
                selected.map((label) => _getNotificationTypeKey(label, isRTL)));
        });
      },
      fillColor: AppColors.background,
      // Owner 22/10/2026: as tall as the 36 text fields.
      height: FieldSizing.height,
      heightSizesWholeTrigger: true,
      valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
    );

    if (portrait) {
      return <Widget>[
        SizedBox(width: double.infinity, child: resetButton()),
        SizedBox(height: 15.h),
        Row(
          children: <Widget>[
            statusIcon,
            SizedBox(width: 8.w),
            statusTitle,
            const Spacer(),
            statusSwitch,
          ],
        ),
        SizedBox(height: 15.h),
        channelLabel,
        channelField,
      ];
    }

    return <Widget>[
      // QA KP-TT-018 (9/10/2026): the action moves to its own line when it
      // does not fit beside the title.
      SizedBox(
        width: double.infinity,
        child: NotificationStatusHeader(
          icon: statusIcon,
          title: statusTitle,
          toggle: statusSwitch,
          trailing: resetButton(width: 190.w),
        ),
      ),
      SizedBox(height: 15.h),
      Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[channelLabel, channelField],
            ),
          ),
          SizedBox(width: 16.sp),
          Expanded(child: Container()),
        ],
      ),
    ];
  }

  bool isEmailView = true;

  /// Tablet: Edit on the start side, the Email | Notifications switch on the
  /// end side, in a row as tall as the Edit button. While editing both leave
  /// (Figma: the switch moves under the status card) but the row keeps its
  /// height, so nothing jumps.
  Widget _desktopHeader(BuildContext context) {
    return SizedBox(
      height: ButtonSizing.height,
      child: Row(
        children: [
          if (!isEditMode)
            // 23/10/2026 (Moataz): on an iPad held in PORTRAIT the Edit button
            // is just the icon (a house-height square); landscape keeps the
            // labelled button.
            if (MediaQuery.orientationOf(context) == Orientation.portrait)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isEditMode = true;
                    if (selectedNotificationIndex == null &&
                        getNotificationItems().isNotEmpty) {
                      selectedNotificationIndex = 0;
                    }
                  });
                  if (selectedNotificationIndex != null) {
                    _loadTemplate();
                  }
                },
                child: Container(
                  width: ButtonSizing.height,
                  height: ButtonSizing.height,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: CustomSvgImage(
                      assetPath:
                          "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
                      width: 20.sp,
                      height: 20.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              )
            else
              customButtonWithSvg(
                title: S.of(context).edit,
                function: () {
                  setState(() {
                    isEditMode = true;
                    if (selectedNotificationIndex == null &&
                        getNotificationItems().isNotEmpty) {
                      selectedNotificationIndex = 0;
                    }
                  });
                  if (selectedNotificationIndex != null) {
                    _loadTemplate();
                  }
                },
                width: 135.w,
                height: 38.h,
                color: AppColors.primary,
                textStyle: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.textButton,
                ),
                radius: 8.r,
                heightImage: 16.h,
                widthImage: 16.w,
                svgColor: AppColors.textButton,
                // Owner 22/10/2026: our edit icon (was the workflow icon).
                image:
                    "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
                space: 8.sp,
                colorBorder: AppColors.transparent,
              ),
          const Spacer(),
          if (!isEditMode) _buildToggleButtons(context),
        ],
      ),
    );
  }

  // Owner 21/10/2026: the Email | Notifications switch is the core CustomSegmentedToggle (compact: card box, yellow pill, 12 Medium), not a hand-built pair; same isEmailView logic.
  Widget _buildToggleButtons(BuildContext context) {
    return CustomSegmentedToggle(
      compact: true,
      // Owner 22/10/2026: as tall as the Edit button beside it
      // (buttons are always ButtonSizing.height).
      height: ButtonSizing.height,
      tabs: [S.of(context).email, S.of(context).notifications],
      selectedIndex: isEmailView ? 0 : 1,
      onChanged: (int index) {
        setState(() {
          isEmailView = index == 0;
        });
      },
    );
  }
}

class NotificationItem {
  final String title;
  final String eventType;

  /// Sub-section this row belongs to inside the module (may be empty).
  final String group;
  final bool isEnabled;
  final bool hasEmail;
  final bool hasPush;

  NotificationItem({
    required this.title,
    required this.eventType,
    this.group = '',
    required this.isEnabled,
    required this.hasEmail,
    required this.hasPush,
  });
}
