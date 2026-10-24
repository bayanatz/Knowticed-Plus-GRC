/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: header_icon_item.dart
/// Purpose: Model describing a single pinned app-bar header icon.
/// Author: Amr Mesbah
/// Created at: 11/8/2026
///
/// Moved out of `presentation/ui/widgets/icon_selector_dialog_widget.dart`:
/// the cubit and the state both consume this model, so declaring it inside a
/// UI widget file was a layer inversion. The catalog of selectable icons — the
/// part that needs page imports — stays in the widget layer.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';

class HeaderIconItem {
  const HeaderIconItem({
    required this.svgPath,
    required this.getTitle,
    required this.navigateTo,
    this.onTap,
  });

  /// Asset path of the icon; this is the value persisted to Firebase.
  final String svgPath;

  /// Resolves the localized label at render time.
  final String Function(BuildContext) getTitle;

  /// Builds the destination page for this icon.
  final Widget Function(BuildContext) navigateTo;

  /// Runs INSTEAD of opening [navigateTo], when this icon is an action rather
  /// than a destination.
  ///
  /// ADDED 23/8/2026. Four pinnable icons — English, AR, Light mode, Dark mode
  /// — are switches, not pages. The model could only describe a page, so each
  /// was left as `const Placeholder()` and tapping one did nothing but show its
  /// tooltip. A non-null [onTap] takes precedence over [navigateTo].
  final void Function(BuildContext)? onTap;

  /// Every [svgPath] the app is willing to restore from storage.
  ///
  /// UPDATED 23/8/2026: the icon picker was rebuilt against Figma node
  /// 7464:8017 and now offers the `picker_*` glyphs exported from that node.
  /// Those paths had to be added here or [fromSvgPath] would return null for
  /// every freshly pinned icon and the app bar would come back empty on the
  /// next launch. The pre-existing paths stay listed so icons pinned BEFORE
  /// that change still restore — this list is checked against whatever is
  /// already in Firebase, so dropping an entry silently drops a user's pin.
  static const List<String> supportedSvgPaths = <String>[
    // Current — exported from the Figma icon-picker design.
    'assets/icons_assets/home_assets/ic_module_user_management.svg',
    'assets/icons_assets/home_assets/ic_module_language_en.svg',
    'assets/icons_assets/main_icons_assets/ic_module_service_approvals.svg',
    'assets/icons_assets/home_assets/ic_module_user_access.svg',
    'assets/icons_assets/home_assets/ic_module_dark_mode.svg',
    'assets/icons_assets/home_assets/ic_module_light_mode.svg',
    'assets/icons_assets/home_assets/ic_module_language_ar.svg',
    'assets/icons_assets/main_icons_assets/ic_comms_customer_service.svg',
    'assets/icons_assets/home_assets/ic_module_requested_services.svg',
    'assets/icons_assets/main_icons_assets/ic_module_service_approvals.svg',
    'assets/icons_assets/home_assets/ic_module_inventory_dashboard.svg',
    'assets/icons_assets/home_assets/ic_module_grc_qiyas.svg',
    'assets/icons_assets/home_assets/ic_module_hub_approvals.svg',
    'assets/icons_assets/main_icons_assets/ic_module_create_todo.svg',
    'assets/icons_assets/home_assets/ic_module_create_task.svg',
    'assets/icons_assets/main_icons_assets/ic_hr_check_in_out.svg',
    'assets/icons_assets/home_assets/ic_module_check_in_out.svg',
    // Legacy — no longer offered by the picker, still restorable.
    'assets/icons_assets/main_icons_assets/ic_module_roles.svg',
    'assets/icons_assets/home_assets/ic_module_user_access.svg',
    'assets/icons_assets/main_icons_assets/ic_security_access_workflow.svg',
    'assets/icons_assets/home_assets/ic_module_language_en.svg',
    'assets/icons_assets/main_icons_assets/ic_module_dark_mode_toggle.svg',
    'assets/icons_assets/main_icons_assets/ic_module_services.svg',
    'assets/icons_assets/main_icons_assets/ic_module_inventory.svg',
    'assets/icons_assets/main_icons_assets/ic_data_analytics.svg',
    'assets/icons_assets/home_assets/ic_data_todo_total.svg',
    'assets/icons_assets/main_icons_assets/ic_hr_check_in_out.svg',
  ];

  /// Legacy asset path → the current picker glyph that replaced it.
  ///
  /// ADDED 23/8/2026 with [canonicalSvgPath]. An icon pinned before the picker
  /// was rebuilt is still stored under its old path, and the icon CATALOG —
  /// which is what knows each icon's destination — is keyed on the new paths
  /// only. Without this table those icons restore and draw, but no destination
  /// can be looked up for them, so tapping one does nothing.
  static const Map<String, String> _legacySvgPathAliases = <String, String>{
    'assets/icons_assets/main_icons_assets/ic_module_roles.svg':
        'assets/icons_assets/main_icons_assets/ic_module_service_approvals.svg',
    'assets/icons_assets/home_assets/ic_module_user_access.svg':
        'assets/icons_assets/home_assets/ic_module_user_access.svg',
    'assets/icons_assets/main_icons_assets/ic_security_access_workflow.svg':
        'assets/icons_assets/home_assets/ic_module_user_management.svg',
    // One language button: an icon pinned as "AR" resolves to the same entry.
    'assets/icons_assets/home_assets/ic_module_language_ar.svg':
        'assets/icons_assets/home_assets/ic_module_language_en.svg',
    'assets/icons_assets/main_icons_assets/ic_module_dark_mode_toggle.svg':
        'assets/icons_assets/home_assets/ic_module_dark_mode.svg',
    'assets/icons_assets/main_icons_assets/ic_module_services.svg':
        'assets/icons_assets/main_icons_assets/ic_comms_customer_service.svg',
    'assets/icons_assets/main_icons_assets/ic_module_inventory.svg':
        'assets/icons_assets/home_assets/ic_module_inventory_dashboard.svg',
    'assets/icons_assets/main_icons_assets/ic_data_analytics.svg':
        'assets/icons_assets/home_assets/ic_module_grc_qiyas.svg',
    'assets/icons_assets/home_assets/ic_data_todo_total.svg':
        'assets/icons_assets/main_icons_assets/ic_module_create_todo.svg',
    'assets/icons_assets/main_icons_assets/ic_hr_check_in_out.svg':
        'assets/icons_assets/main_icons_assets/ic_hr_check_in_out.svg',
    'assets/icons_assets/home_assets/ic_module_check_in_out.svg':
        'assets/icons_assets/main_icons_assets/ic_hr_check_in_out.svg',
    'assets/icons_assets/home_assets/ic_module_light_mode.svg':
        'assets/icons_assets/home_assets/ic_module_dark_mode.svg',
  };

  /// Function Name: [canonicalSvgPath]
  ///
  /// Purpose: The current picker path for [svgPath], so a stored icon can be
  ///          matched against the catalog whichever generation it was pinned
  ///          in. Returns [svgPath] unchanged when it is already current.
  ///
  /// The ICON DRAWN stays the stored one — only the lookup key is normalised,
  /// so a legacy pin keeps its old glyph and gains its destination.
  static String canonicalSvgPath(String svgPath) =>
      _legacySvgPathAliases[svgPath] ?? svgPath;

  static const String _languageEnSvg =
      'assets/icons_assets/home_assets/ic_module_language_en.svg';
  static const String _languageArSvg =
      'assets/icons_assets/home_assets/ic_module_language_ar.svg';

  /// Function Name: [displaySvgPath]
  ///
  /// Purpose: The glyph to DRAW. The language button is one button that flips:
  ///          it shows the language a tap switches TO (AR while the app is in
  ///          English, EN while it is in Arabic). Every other icon draws as
  ///          stored.
  static String displaySvgPath(String svgPath) {
    if (canonicalSvgPath(svgPath) != _languageEnSvg) return svgPath;
    return (Get.locale?.languageCode ?? 'en') == 'ar'
        ? _languageEnSvg
        : _languageArSvg;
  }

  /// Function Name: [title]
  ///
  /// Purpose: Localized label for this icon.
  ///
  /// Parameters:
  /// - [context]: Build context used to resolve localizations.
  ///
  /// Returns: [String] the localized title.
  String title(BuildContext context) => getTitle(context);

  /// Function Name: [fromSvgPath]
  ///
  /// Purpose: Rebuild an item from the persisted asset path. Used by the cubit,
  ///          which has no [BuildContext] — the title stays a callback so it is
  ///          localized at render time.
  ///
  /// Parameters:
  /// - [svgPath]: Asset path previously stored in Firebase.
  ///
  /// Returns: [HeaderIconItem] or `null` when the path is not recognised.
  static HeaderIconItem? fromSvgPath(String svgPath) {
    if (!supportedSvgPaths.contains(svgPath)) {
      return null;
    }

    return HeaderIconItem(
      svgPath: svgPath,
      getTitle: (BuildContext ctx) {
        final S l = S.of(ctx);
        switch (svgPath) {
          // Current — the Figma icon-picker set. A path missing from this
          // switch still restores (supportedSvgPaths gates that), but falls
          // through to `default` and shows the raw asset path as its label.
          case 'assets/icons_assets/home_assets/ic_module_user_management.svg':
            return l.userManagement;
          case 'assets/icons_assets/home_assets/ic_module_language_en.svg':
          case 'assets/icons_assets/home_assets/ic_module_language_ar.svg':
            return l.language;
          case 'assets/icons_assets/main_icons_assets/ic_module_service_approvals.svg':
            return l.roles;
          case 'assets/icons_assets/home_assets/ic_module_user_access.svg':
            return l.userAccess;
          case 'assets/icons_assets/home_assets/ic_module_dark_mode.svg':
          case 'assets/icons_assets/home_assets/ic_module_light_mode.svg':
            return l.lightDarkMode;
          case 'assets/icons_assets/main_icons_assets/ic_comms_customer_service.svg':
            return l.serviceDashboard;
          case 'assets/icons_assets/home_assets/ic_module_requested_services.svg':
            return l.requestedServices;
          case 'assets/icons_assets/home_assets/ic_module_inventory_dashboard.svg':
            return l.inventoryDashboard;
          case 'assets/icons_assets/home_assets/ic_module_grc_qiyas.svg':
            return l.qiyasDashboard;
          case 'assets/icons_assets/home_assets/ic_module_hub_approvals.svg':
            // No `hubApproval` key in intl_en.arb — literal until one is added.
            return Get.locale?.languageCode == 'ar'
                ? 'موافقات مركز المعرفة'
                : 'Knowledge Hub Approval';
          case 'assets/icons_assets/main_icons_assets/ic_module_create_todo.svg':
            return l.createToDo;
          case 'assets/icons_assets/home_assets/ic_module_create_task.svg':
            return l.createTask;
          case 'assets/icons_assets/main_icons_assets/ic_hr_check_in_out.svg':
          case 'assets/icons_assets/home_assets/ic_module_check_in_out.svg':
            return l.checkInOut;
          // Legacy — pinned before the picker was rebuilt.
          case 'assets/icons_assets/main_icons_assets/ic_module_roles.svg':
            return l.roles;
          case 'assets/icons_assets/main_icons_assets/ic_security_access_workflow.svg':
            return l.userManagement;
          case 'assets/icons_assets/main_icons_assets/ic_module_dark_mode_toggle.svg':
            return l.lightDarkMode;
          case 'assets/icons_assets/main_icons_assets/ic_module_services.svg':
            return l.serviceDashboard;
          case 'assets/icons_assets/main_icons_assets/ic_module_inventory.svg':
            return l.inventoryDashboard;
          case 'assets/icons_assets/main_icons_assets/ic_data_analytics.svg':
            return l.qiyasDashboard;
          case 'assets/icons_assets/home_assets/ic_data_todo_total.svg':
            return l.createToDo;
          default:
            return svgPath;
        }
      },
      // A restored item cannot carry its own destination: pages live in the
      // presentation layer and this model is consumed by the cubit, so
      // importing them here would invert the layering. The app bar resolves
      // the destination from the icon catalog by [canonicalSvgPath] instead
      // — see `headerIconForSvgPath` in icon_selector_dialog_widget.dart.
      //
      // This placeholder is therefore never pushed; it exists because the
      // field is required.
      navigateTo: (BuildContext ctx) => const Placeholder(),
    );
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Return a copy of this item with selected fields replaced.
  HeaderIconItem copyWith({
    String? svgPath,
    String Function(BuildContext)? getTitle,
    Widget Function(BuildContext)? navigateTo,
    void Function(BuildContext)? onTap,
  }) {
    return HeaderIconItem(
      svgPath: svgPath ?? this.svgPath,
      getTitle: getTitle ?? this.getTitle,
      navigateTo: navigateTo ?? this.navigateTo,
      onTap: onTap ?? this.onTap,
    );
  }
}
