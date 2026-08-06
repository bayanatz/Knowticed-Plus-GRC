import 'package:grc_module/core/custom/50_custom_side_frame_master.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/circle_progress.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:grc_module/features/notification/data/repository/notification_template_service.dart';
import 'package:grc_module/features/notification/presentation/ui/widgets/custom_tab_ar.dart';
import 'package:grc_module/generated/l10n.dart';

// REMOVED_MODULE: import 'package:grc_module/external/knowledge_hub_module/core/theming/new_theme.dart';
// REMOVED_MODULE: import 'package:grc_module/features/knowledge_hub_module/core/app_multi_select_drop_down.dart';
import 'package:grc_module/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
// REMOVED_MODULE: import 'package:grc_module/external/todo_module/core/components/other_components/flutter_switch.dart';
import 'package:grc_module/features/notification/data/models/notification_model.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/notification/domain/enums/notification_catalog.dart';
// `NotificationEvent` is imported for its `.title(isArabic:)` extension —
// extensions are only in scope in files that import their declaring library.
import 'package:grc_module/features/notification/domain/enums/notification_event.dart';
import 'package:grc_module/features/notification/presentation/ui/pages/notification_edit_page.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/enums/app_module.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

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
  settings(AppModule.settings),
  notificationControl(AppModule.notificationControl),

  // ── legacy tabs: no events defined in the spec, hidden from the UI ──
  employees(null),
  tasks(null),
  messages(null),
  inventory(null),
  requests(null),
  events(null),
  notes(null),
  formBuilder(null),
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

  TextEditingController subjectEn = TextEditingController();
  TextEditingController subjectAr = TextEditingController();
  TextEditingController bodyArController = TextEditingController();
  TextEditingController bodyEnController = TextEditingController();

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

  @override
  void initState() {
    super.initState();

    //print('');
    //print('╔══════════════════════════════════════════════════════════╗');
    //print('║           NOTIFICATION CONTROL INITIALIZATION           ║');
    //print('╚══════════════════════════════════════════════════════════╝');
    //print('📋 Total available tabs: ${NotificationTab.values.length}');
    //print('📋 Tab list: ${NotificationTab.values.map((t) => t.name).join(', ')}');
    //print('');

    // ✅ CRITICAL DEBUG: Check if controller exists BEFORE filtering
    _debugControllerState();

    // ✅ Set selected tab to first visible tab
    final visibleTabs = _getVisibleTabs();
    //print('✅ Visible tabs after permission check: ${visibleTabs.length}');
    //print('✅ Visible tab names: ${visibleTabs.map((t) => t.name).join(', ')}');
    //print('');

    if (visibleTabs.isNotEmpty) {
      selectedTab = visibleTabs.first;
      //print('🎯 Selected tab SET TO: ${selectedTab.name}');
    } else {
      //print('⚠️ WARNING: No visible tabs found!');
      // Fallback to home if no tabs are visible
     // selectedTab = NotificationTab.home;
      //print('🏠 FALLBACK: Selected tab SET TO: ${selectedTab.name}');
    }
    //print('══════════════════════════════════════════════════════════');
    //print('');

    // ✅ Load templates AFTER first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllTemplatesForTab();
    });
  }

  // ✅ NEW: Debug method to check controller state
  void _debugControllerState() {
    //print('');
    //print('╔══════════════════════════════════════════════════════════╗');
    //print('║              CONTROLLER STATE CHECK                      ║');
    //print('╚══════════════════════════════════════════════════════════╝');

    try {
      final controller = Get.find<MainCoreEmployeeController>();
      //print('✅ MainCoreEmployeeController FOUND');
      //print('   Controller type: ${controller.runtimeType}');
      //print('   Is initialized: ${controller.initialized}');

      // Try to get current employee data
      try {
        //print('   Attempting to access employee data...');
        // Add any relevant employee controller properties here
        //print('   ✅ Employee data accessible');
      } catch (e) {
        //print('   ⚠️ Cannot access employee data: $e');
      }
    } catch (e) {
      //print('❌ MainCoreEmployeeController NOT FOUND');
      //print('   Error: $e');
      //print('   Error type: ${e.runtimeType}');
    }
    //print('══════════════════════════════════════════════════════════');
    //print('');
  }

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

    //print('');
    //print('════════════════════════════════════════════════════');
    //print('🔄 Loading all templates for: $moduleName');
    //print('════════════════════════════════════════════════════');

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final template = await _templateService.getTemplate(
        module: moduleName,
        eventType: item.eventType,
      );

      if (template != null) {
        loadedTemplates[item.eventType] = template;
        //print(
           // '✅ Loaded: ${item.eventType} - Enabled: ${template.isEnabled}, Email: ${template.hasEmail}, Push: ${template.hasPush}');
      } else {
        //print('⚠️ No template in Firebase for: ${item.eventType}');
      }
    }

    //print('════════════════════════════════════════════════════');
    //print('✅ All templates loaded. Total: ${loadedTemplates.length}');
    //print('════════════════════════════════════════════════════');
    //print('');

    if (!mounted) return;

    setState(() {
      isLoadingTemplates = false;
      _cachedNotificationItems = _buildNotificationItems();
    });
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
      final saved =
          isArabic ? template.subjectArabic : template.subjectEnglish;

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

  // ✅ Get notification items (uses cache to prevent rebuilds)
  List<NotificationItem> getNotificationItems() {
    if (_cachedNotificationItems != null) {
      return _cachedNotificationItems!;
    }
    return _buildNotificationItems();
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
    //print('');
    //print('╔══════════════════════════════════════════════════════════╗');
    //print('║              CHECKING TAB VISIBILITY                    ║');
    //print('╚══════════════════════════════════════════════════════════╝');
    //print('⏱️ Starting visibility check at: ${DateTime.now()}');
    //print('');

    final visibleTabs = <NotificationTab>[];

    for (var tab in NotificationTab.values) {
      final isVisible = _isTabVisible(tab);
      if (isVisible) {
        visibleTabs.add(tab);
        //print('➕ Added ${tab.name} to visible tabs');
      } else {
        //print('➖ Excluded ${tab.name} from visible tabs');
      }
      //print('');
    }

    //print('══════════════════════════════════════════════════════════');
    //print('📊 VISIBILITY CHECK SUMMARY:');
    //print('   ├─ Total tabs checked: ${NotificationTab.values.length}');
    //print('   ├─ Visible tabs: ${visibleTabs.length}');
    //print('   ├─ Hidden tabs: ${NotificationTab.values.length - visibleTabs.length}');
    //print('   └─ Visible tab names: ${visibleTabs.map((t) => t.name).join(', ')}');
    //print('══════════════════════════════════════════════════════════');
    //print('');

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
      //print('⚠️ No notification selected');
      return;
    }

    final items = getNotificationItems();
    final selectedItem = items[selectedNotificationIndex!];
    final moduleName = getModuleName(selectedTab);

    //print('');
    //print('═══════════════════════════════════════════════════');
    //print('🔍 Loading template: $moduleName - ${selectedItem.eventType}');
    //print('═══════════════════════════════════════════════════');

    NotificationTemplateModel? template = await _templateService.getTemplate(
      module: moduleName,
      eventType: selectedItem.eventType,
    );

    if (template != null) {
      //print('✅ Template loaded from Firebase');
      //print('   - Subject (EN): ${template.subjectEnglish}');
      //print('   - Enabled: ${template.isEnabled}');
      //print('   - Selected types: ${template.selectedNotificationTypes}');
      //print('   - Has Email: ${template.hasEmail}');
      //print('   - Has Push: ${template.hasPush}');

      setState(() {
        currentTemplate = template;
        isNotificationEnabled = template.isEnabled;
        selectedNotificationTypes =
            List.from(template.selectedNotificationTypes);

        subjectEn.text = template.subjectEnglish;
        subjectAr.text = template.subjectArabic;
        bodyEnController.text = template.bodyEnglish;
        bodyArController.text = template.bodyArabic;
      });

      //print('✅ UI updated with loaded template');
    } else {
      //print('⚠️ No template found in Firebase for: ${selectedItem.eventType}');
    }
    //print('═══════════════════════════════════════════════════');
    //print('');
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

  Future<void> _saveTemplate() async {
    if (currentTemplate == null) {
      return;
    }

    if (subjectEn.text.trim().isEmpty ||
        subjectAr.text.trim().isEmpty ||
        bodyEnController.text.trim().isEmpty ||
        bodyArController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final updatedTemplate = currentTemplate!.copyWith(
      subjectEnglish: subjectEn.text.trim(),
      subjectArabic: subjectAr.text.trim(),
      bodyEnglish: bodyEnController.text.trim(),
      bodyArabic: bodyArController.text.trim(),
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
      });
    }
  }

  Future<void> _resetToDefault() async {
    if (selectedNotificationIndex == null) {
      return;
    }

    final items = getNotificationItems();
    final selectedItem = items[selectedNotificationIndex!];
    final moduleName = getModuleName(selectedTab);

    final success = await _templateService.resetToDefault(
      module: moduleName,
      eventType: selectedItem.eventType,
    );

    if (success) {
      await _loadTemplate();
      await _loadAllTemplatesForTab();
    }
  }

  void _clearFields() {
    subjectEn.clear();
    subjectAr.clear();
    bodyEnController.clear();
    bodyArController.clear();
    currentTemplate = null;
    isNotificationEnabled = true;
    selectedNotificationTypes = [];
  }

  /// Available-placeholder hint, derived from the selected event instead of
  /// a hardcoded per-module switch.
  String _getVariablesHintText(bool isRTL) {
    if (selectedNotificationIndex == null) {
      return isRTL
          ? "اختر نوع إشعار أولاً"
          : "Select a notification type first";
    }

    final module = selectedTab.module;
    final items = getNotificationItems();
    final selectedItem = items[selectedNotificationIndex!];
    final event = module == null
        ? null
        : NotificationCatalog.find(module: module, key: selectedItem.eventType);

    final tokens =
        event?.variables.map((v) => v.token).join(', ') ?? '';
    if (tokens.isEmpty) {
      return isRTL
          ? "لا توجد متغيرات لهذا الإشعار"
          : "This notification has no variables";
    }
    return isRTL ? "المتغيرات المتاحة: $tokens" : "Available variables: $tokens";
  }

  void _showPreviewDialog(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? "معاينة الإشعار" : "Notification Preview"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? "العنوان:" : "Subject:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(isArabic ? subjectAr.text : subjectEn.text),
            SizedBox(height: 16),
            Text(
              isArabic ? "النص:" : "Body:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(isArabic ? bodyArController.text : bodyEnController.text),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isArabic
                    ? "ملاحظة: سيتم استبدال المتغيرات مثل {{serviceName}} بالقيم الفعلية عند إرسال الإشعار"
                    : "Note: Variables like {{serviceName}} will be replaced with actual values when sending notifications",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? "إغلاق" : "Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // ✅ DEBUG: //print build state
    //print('🏗️ BUILD CALLED - Selected Tab: ${selectedTab.name}');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).notificationControl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Tab Bar
              Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _getVisibleTabs().map((tab) {
                        final isSelected = selectedTab == tab;
                        final tabName = getTabName(tab);

                        return Padding(
                          padding: EdgeInsets.only(
                            right: isRTL ? 0 : 24,
                            left: isRTL ? 24 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              //print('');
                              //print('🔄 TAB CHANGED: ${tab.name}');
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomTabUnderline(
                                  text: tabName,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  height: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
              ),

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
                isMobile
                    ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isEditMode)
                          customButtonWithSvg(
                            title: isMobile ? "" : S.of(context).edit,
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
                            width: isMobile ? 38 : 135.w,
                            height: 38.h,
                            color: AppColors.primary,
                            textStyle:
                            StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            radius: 8.r,
                            heightImage: isMobile ? 20 : 16.h,
                            widthImage: isMobile ? 20 : 16.w,
                            svgColor: AppColors.textButton,
                            image: isMobile
                                ? "assets/icons_assets/main_icons_assets/edit_pencil_square.svg"
                                : "assets/icons_assets/main_icons_assets/user_access_workflow.svg",
                            space: isMobile ? 0.sp : 8.sp,
                            colorBorder: Colors.transparent,
                          ),

                        Spacer(),
                        _buildToggleButtons(context),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    if (isEditMode) ...[
                      Container(
                        padding: EdgeInsets.only(
                          top: 15.h,
                          right: 15.w,
                          left: 15.w,
                          bottom: 15.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomSvgImage(
                                  assetPath: "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                                  width: 16.w,
                                  height: 16.h,
                                  fit: BoxFit.fill,
                                  color: AppColors.secondaryText,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "Notification Status",
                                  style: StyleText.fontSize18Weight500
                                      .copyWith(color: AppColors.text),
                                ),
                                SizedBox(width: 8.w),
                                FlutterSwitch(
                                  activeColor: AppColors.secondaryPrimary,
                                  height: 22.sp,
                                  width: 38.sp,
                                  padding: 3.sp,
                                  borderRadius: 20.sp,
                                  toggleSize: 16.sp,
                                  toggleColor: Colors.white,
                                  inactiveColor:
                                  Color(0xFF787880).withOpacity(0.16),
                                  value: isNotificationEnabled,
                                  onToggle: (newValue) {
                                    setState(() {
                                      isNotificationEnabled = newValue;
                                    });
                                  },
                                ),
                                Spacer(),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditMode = false;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.text,
                                    size: 20.sp,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                                SizedBox(width: 8.w),
                                customButton(
                                  title: "Reset Default Messages",
                                  function: _resetToDefault,
                                  color: AppColors.primary,
                                  radius: 4.r,
                                  width: 220.w,
                                  height: 30.h,
                                  textStyle: StyleText.fontSize14Weight500
                                      .copyWith(
                                    color: AppColors.textButton,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                        EdgeInsets.only(bottom: 8.h),
                                        child: Text(
                                          isRTL
                                              ? "نوع الإشعار"
                                              : "Notification Type",
                                          style: StyleText
                                              .fontSize12Weight400
                                              .copyWith(
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ),
                                      CustomMultiSelectDropdown<String>(
                                        values: selectedNotificationTypes
                                            .map((type) {
                                          if (isRTL) {
                                            return type == "email"
                                                ? "البريد الإلكتروني"
                                                : "إشعار الهاتف";
                                          } else {
                                            return type == "email"
                                                ? "Email"
                                                : "Push Notification";
                                          }
                                        }).toList(),
                                        items: (isRTL
                                            ? [
                                          "البريد الإلكتروني",
                                          "إشعار الهاتف"
                                        ]
                                            : [
                                          "Email",
                                          "Push Notification"
                                        ])
                                            .map((e) => MultiSelectDropdownItem<String>(value: e, label: e))
                                            .toList(),
                                        selectedTextBuilder: (_) => _getSelectedNotificationTypesText(
                                            isRTL),
                                        hint: isRTL
                                            ? "اختر نوع الإشعار"
                                            : "Select Notification Type",
                                        onChanged: (selected) {
                                          setState(() {
                                            selectedNotificationTypes
                                              ..clear()
                                              ..addAll(selected
                                                  .map((label) => _getNotificationTypeKey(label, isRTL)));
                                          });
                                        },
                                        fillColor: AppColors.background,
                                        valueStyle: StyleText
                                            .fontSize12Weight400
                                            .copyWith(
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 15.w),
                                Expanded(child: Container()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isLoadingTemplates
                              ? Center(child: CircleProgressMaster())
                              : Container(
                            height: 300.h,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: getNotificationItems().length,
                              itemBuilder: (context, index) {
                                final item =
                                getNotificationItems()[index];
                                final isSelected =
                                    selectedNotificationIndex == index;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedNotificationIndex = index;
                                    });
                                    _loadTemplate();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    padding: EdgeInsets.all(15.r),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isSelected
                                                  ? AppColors.textButton
                                                  : AppColors.text,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: item.isEnabled
                                                ? Colors.green
                                                : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (item.hasEmail)
                                          CustomSvgImage(
                                            assetPath:
                                            "assets/icons_assets/notification_assets/email_at_envelope.svg",
                                            width: 20.w,
                                            height: 20.h,
                                            color: isSelected
                                                ? AppColors.textButton
                                                : null,
                                          ),
                                        const SizedBox(width: 8),
                                        if (item.hasPush)
                                          CustomSvgImage(
                                            assetPath:
                                            "assets/icons_assets/notification_assets/phone_notifications_bell.svg",
                                            width: 20.w,
                                            height: 20.h,
                                            color: isSelected
                                                ? AppColors.textButton
                                                : null,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        customButton(
                            title: S.of(context).next,
                            function: () {
                              if (selectedNotificationIndex == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        isRTL
                                            ? "يرجى اختيار إشعار أولاً"
                                            : "Please select a notification first"
                                    ),
                                  ),
                                );
                                return;
                              }

                              final selectedItem = getNotificationItems()[selectedNotificationIndex!];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationEditPage(
                                    notificationItem: selectedItem,
                                    moduleName: getModuleName(selectedTab),
                                    currentTab: selectedTab,
                                  ),
                                ),
                              );
                            },
                            width: 150.w,
                            height: 38.h,
                            radius: 8.r,
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: AppColors.textButton
                            ),
                            color: AppColors.primary
                        ),
                      ],
                    )
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 300.w,
                      child: Text(
                        S.of(context).requestStatus,
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ),
                    SizedBox(width: 40.w),
                    if (!isEditMode)
                      customButtonWithSvg(
                        title: isMobile ? "" : S.of(context).edit,
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
                        width: isMobile ? 38.w : 135.w,
                        height: 38.h,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        radius: 8.r,
                        heightImage: 16.h,
                        widthImage: 16.w,
                        svgColor: AppColors.textButton,
                        image: "assets/icons_assets/main_icons_assets/user_access_workflow.svg",
                        space: isMobile ? 0.sp : 8.sp,
                        colorBorder: Colors.transparent,
                      ),
                    Spacer(),
                    _buildToggleButtons(context),
                  ],
                ),

              SizedBox(height: 8.h),

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
                    ? Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isLoadingTemplates
                              ? Center(child: CircleProgressMaster())
                              : Container(
                            height: 300.h,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: getNotificationItems().length,
                              itemBuilder: (context, index) {
                                final item =
                                getNotificationItems()[index];
                                final isSelected =
                                    selectedNotificationIndex == index;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedNotificationIndex = index;
                                    });
                                    _loadTemplate();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    padding: EdgeInsets.all(15.r),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isSelected
                                                  ? AppColors.textButton
                                                  : AppColors.text,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: item.isEnabled
                                                ? Colors.green
                                                : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (item.hasEmail)
                                          CustomSvgImage(
                                            assetPath:
                                            "assets/icons_assets/notification_assets/email_at_envelope.svg",
                                            width: 20.w,
                                            height: 20.h,
                                            color: isSelected
                                                ? AppColors.textButton
                                                : null,
                                          ),
                                        const SizedBox(width: 8),
                                        if (item.hasPush)
                                          CustomSvgImage(
                                            assetPath:
                                            "assets/icons_assets/notification_assets/phone_notifications_bell.svg",
                                            width: 20.w,
                                            height: 20.h,
                                            color: isSelected
                                                ? AppColors.textButton
                                                : null,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        customButton(
                            title: S.of(context).next,
                            function: () {
                              if (selectedNotificationIndex == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        isRTL
                                            ? "يرجى اختيار إشعار أولاً"
                                            : "Please select a notification first"
                                    ),
                                  ),
                                );
                                return;
                              }

                              final selectedItem = getNotificationItems()[selectedNotificationIndex!];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationEditPage(
                                    notificationItem: selectedItem,
                                    moduleName: getModuleName(selectedTab),
                                    currentTab: selectedTab,
                                  ),
                                ),
                              );
                            },
                            width: 150.w,
                            height: 38.h,
                            radius: 8.r,
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: AppColors.textButton
                            ),
                            color: AppColors.primary
                        ),
                      ],
                    )
                  ],
                )
                    : Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 320.w,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: isLoadingTemplates
                                  ? Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                                  : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount:
                                getNotificationItems().length,
                                itemBuilder: (context, index) {
                                  final item =
                                  getNotificationItems()[index];
                                  final isSelected =
                                      selectedNotificationIndex ==
                                          index;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedNotificationIndex =
                                            index;
                                      });
                                      _loadTemplate();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      padding: EdgeInsets.all(15.r),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius:
                                        BorderRadius.circular(
                                            8.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isSelected
                                                    ? AppColors
                                                    .textButton
                                                    : AppColors
                                                    .text,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration:
                                            BoxDecoration(
                                              color: item.isEnabled
                                                  ? Colors.green
                                                  : Colors.red,
                                              shape:
                                              BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (item.hasEmail)
                                            CustomSvgImage(
                                              assetPath:
                                              "assets/icons_assets/notification_assets/email_at_envelope.svg",
                                              width: 20.w,
                                              height: 20.h,
                                              color: isSelected
                                                  ? AppColors
                                                  .textButton
                                                  : null,
                                            ),
                                          const SizedBox(width: 8),
                                          if (item.hasPush)
                                            CustomSvgImage(
                                              assetPath:
                                              "assets/icons_assets/notification_assets/phone_notifications_bell.svg",
                                              width: 20.w,
                                              height: 20.h,
                                              color: isSelected
                                                  ? AppColors
                                                  .textButton
                                                  : null,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: isLoadingTemplates
                            ? Center(child: CircleProgressMaster())
                            : ScrollConfiguration(
                          behavior: const ScrollBehavior()
                              .copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            physics:
                            const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: Column(
                              children: [
                                if (isEditMode) ...[
                                  Container(
                                    padding: EdgeInsets.only(
                                      top: 15.h,
                                      right: 15.w,
                                      left: 15.w,
                                      bottom: 15.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius:
                                      BorderRadius.circular(
                                          8.r),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CustomSvgImage(
                                              assetPath:
                                              "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                                              width: 16.w,
                                              height: 16.h,
                                              fit: BoxFit.fill,
                                              color: AppColors
                                                  .secondaryText,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              "Notification Status",
                                              style: StyleText
                                                  .fontSize18Weight500
                                                  .copyWith(
                                                  color:
                                                  AppColors
                                                      .text),
                                            ),
                                            SizedBox(width: 8.w),
                                            FlutterSwitch(
                                              activeColor: AppColors
                                                  .secondaryPrimary,
                                              height: 22.sp,
                                              width: 38.sp,
                                              padding: 3.sp,
                                              borderRadius: 20.sp,
                                              toggleSize: 16.sp,
                                              toggleColor:
                                              Colors.white,
                                              inactiveColor:
                                              Color(0xFF787880)
                                                  .withOpacity(
                                                  0.16),
                                              value:
                                              isNotificationEnabled,
                                              onToggle: (newValue) {
                                                setState(() {
                                                  isNotificationEnabled =
                                                      newValue;
                                                });
                                              },
                                            ),
                                            Spacer(),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isEditMode =
                                                  false;
                                                });
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                color:
                                                AppColors.text,
                                                size: 20.sp,
                                              ),
                                              padding:
                                              EdgeInsets.zero,
                                              constraints:
                                              BoxConstraints(),
                                            ),
                                            SizedBox(width: 8.w),
                                            customButton(
                                              title:
                                              "Reset Default Messages",
                                              function:
                                              _resetToDefault,
                                              color:
                                              AppColors.primary,
                                              radius: 4.r,
                                              width: 190.w,
                                              height: 30.h,
                                              textStyle: StyleText
                                                  .fontSize14Weight500
                                                  .copyWith(
                                                color: AppColors
                                                    .textButton,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .only(
                                                        bottom:
                                                        8.h),
                                                    child: Text(
                                                      isRTL
                                                          ? "نوع الإشعار"
                                                          : "Notification Type",
                                                      style: StyleText
                                                          .fontSize12Weight400
                                                          .copyWith(
                                                        color: AppColors
                                                            .secondaryText,
                                                      ),
                                                    ),
                                                  ),
                                                  CustomMultiSelectDropdown<String>(
                                                    values: selectedNotificationTypes
                                                        .map(
                                                            (type) {
                                                          if (isRTL) {
                                                            return type ==
                                                                "email"
                                                                ? "البريد الإلكتروني"
                                                                : "إشعار الهاتف";
                                                          } else {
                                                            return type ==
                                                                "email"
                                                                ? "Email"
                                                                : "Push Notification";
                                                          }
                                                        }).toList(),
                                                    items: (isRTL
                                                        ? [
                                                      "البريد الإلكتروني",
                                                      "إشعار الهاتف"
                                                    ]
                                                        : [
                                                      "Email",
                                                      "Push Notification"
                                                    ])
                                                        .map((e) => MultiSelectDropdownItem<String>(value: e, label: e))
                                                        .toList(),
                                                    selectedTextBuilder: (_) => _getSelectedNotificationTypesText(
                                                        isRTL),
                                                    hint: isRTL
                                                        ? "اختر نوع الإشعار"
                                                        : "Select Notification Type",
                                                    onChanged: (selected) {
                                                      setState(() {
                                                        selectedNotificationTypes
                                                          ..clear()
                                                          ..addAll(selected
                                                              .map((label) => _getNotificationTypeKey(label, isRTL)));
                                                      });
                                                    },
                                                    fillColor: AppColors
                                                        .background,
                                                    valueStyle: StyleText
                                                        .fontSize12Weight400
                                                        .copyWith(
                                                      color:
                                                      AppColors
                                                          .text,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 15.w),
                                            Expanded(
                                                child: Container()),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                ],
                                Container(
                                  padding: EdgeInsets.all(15.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius:
                                    BorderRadius.circular(8.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextField(
        label: "Subject",
        hint: "Text Here",
        maxLines: 1,
        height: 36.h,
        textDirection: TextDirection.ltr,
        controller: subjectEn,
        onChanged: (_) =>
                                                  setState(() {}),
        enabled: isEditMode,
      ),
                                          ),
                                          SizedBox(width: 15.w),
                                          Expanded(
                                            child: CustomTextField(
        label: "عنوان",
        hint: "اكتب هنا",
        maxLines: 1,
        height: 36.h,
        textDirection: TextDirection.rtl,
        controller: subjectAr,
        onChanged: (_) =>
                                                  setState(() {}),
        enabled: isEditMode,
      ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15.h),
                                      Container(
                                        padding:
                                        EdgeInsets.all(8.r),
                                        decoration: BoxDecoration(
                                          color: Colors.blue
                                              .withOpacity(0.1),
                                          borderRadius:
                                          BorderRadius.circular(
                                              4.r),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size: 16.sp,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Text(
                                                _getVariablesHintText(
                                                    isRTL),
                                                style: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                    color: Colors
                                                        .blue),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15.h),
                                      CustomTextField(
        label: "Body",
        hint: "Text Here",
        maxLines: 7,
        minLines: 7,
        height: 150.h,
        maxLength: 500,
        showCharCount: true,
        textDirection: TextDirection.ltr,
        controller:
                                        bodyEnController,
        onChanged: (_) =>
                                            setState(() {}),
        enabled: isEditMode,
      ),
                                      SizedBox(height: 15.h),
                                      CustomTextField(
        label: "نص الرسالة",
        hint: "اكتب هنا",
        maxLines: 7,
        minLines: 7,
        height: 150.h,
        maxLength: 500,
        showCharCount: true,
        textDirection: TextDirection.rtl,
        controller:
                                        bodyArController,
        onChanged: (_) =>
                                            setState(() {}),
        enabled: isEditMode,
      ),
                                      SizedBox(height: 15.h),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          customButton(
                                            title: S
                                                .of(context)
                                                .preview,
                                            textStyle: StyleText
                                                .fontSize18Weight500
                                                .copyWith(
                                                color: lightMode
                                                    ? Colors
                                                    .black
                                                    : Colors
                                                    .white),
                                            function: () {
                                              _showPreviewDialog(
                                                  context);
                                            },
                                            width: 150.w,
                                            height: 38.h,
                                            color: lightMode
                                                ? Colors.grey[400]
                                                : Colors.grey[700],
                                            radius: 8.r,
                                          ),
                                          Spacer(),
                                          customButton(
                                            title:
                                            S.of(context).save,
                                            textStyle: StyleText
                                                .fontSize18Weight500
                                                .copyWith(
                                                color: AppColors
                                                    .textButton),
                                            function: () {
                                              isSaving
                                                  ? null
                                                  : _saveTemplate();
                                            },
                                            width: 150.w,
                                            height: 38.h,
                                            color:
                                            AppColors.primary,
                                            radius: 8.r,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  bool isEmailView = true;

  Widget _buildToggleButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 7.w),
            child: _buildToggleButton(
              context: context,
              label: S.of(context).email,
              isSelected: isEmailView,
              onTap: () {
                setState(() {
                  isEmailView = true;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 7.w),
            child: _buildToggleButton(
              context: context,
              label: S.of(context).notifications,
              isSelected: !isEmailView,
              onTap: () {
                setState(() {
                  isEmailView = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Center(
          child: Text(
            label,
            style: StyleText.fontSize12Weight500.copyWith(
              color:
              isSelected ? AppColors.textButton : AppColors.text,
            ),
          ),
        ),
      ),
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