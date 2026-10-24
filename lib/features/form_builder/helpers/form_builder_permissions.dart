/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_permissions.dart
/// Description: Every Form Builder permission question, answered in one place.
/// Author: Amr Mesbah
/// Created at: 12/10/2026
///
/// ─── WHY THIS SHAPE ──────────────────────────────────────────────────
/// The same shape as `messaging/main_controller/helper/messages_permissions.dart`
/// and the Knowledge Hub helper, for the same reason: the form module asked
/// `isHasPermission` directly in a dozen places, so each switch was enforced
/// on some screens and ignored on others (Restore was even gated by the
/// Convert-to-PDF switch). A role switch obeyed in one place out of three
/// looks exactly like a broken switch. Every screen now asks THIS class.
///
/// The switches are the ones Role Management draws for Form Builder
/// (`roles/r1_role_management/domain/enums/form/`):
///
///   Form Permissions (section)     → FormPermissions.*
///   Results Permissions (section)  → ResultsPermissions.*
///   Create Group Permissions       → a section with no children: the
///                                    section switch IS the permission.
///
/// ─── THE MASTER TOGGLES ──────────────────────────────────────────────
/// Each column in Role Management has a master toggle above it (a
/// section-level permission). Every getter is therefore TWO checks: the
/// section must be on AND the switch must be on. As in MessagesAccess, a
/// section blocks only when the role EXPLICITLY stores it as `false` — roles
/// saved before the section keys existed have no key at all and must not
/// lose every ability because of that.
///
/// ─── CHILD SWITCHES ──────────────────────────────────────────────────
/// Some Results switches are drawn nested under a parent
/// (`ResultsPermissions.isChild`): Pending / View Submissions / Export
/// Submission Data / Download Submissions sit under Users, and Export
/// Analytics Data under Analytics. A child counts only when its parent is on
/// too — the same rule the Role Management screen shows visually.
///
/// ─── FAIL-CLOSED ─────────────────────────────────────────────────────
/// `isHasPermission` returns false when the module is not accessible, the key
/// is missing, or the role could not be loaded. Every getter inherits that,
/// and the `Get.find` is guarded so a call before the controller is
/// registered denies rather than throws.
library;

import 'dart:developer';

import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form_builder/form_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form_builder/form_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form_builder/results_permissions.dart';

/// Static-only; holds no state.
abstract final class FormBuilderAccess {
  const FormBuilderAccess._();

  static const Modules _module = Modules.formBuilder;

  static MainCoreEmployeeController? get _c =>
      Get.isRegistered<MainCoreEmployeeController>()
          ? Get.find<MainCoreEmployeeController>()
          : null;

  /// The Form Builder permission map this session holds — for denial logs.
  static Map<String, bool> get storedForDebug =>
      _c?.getModulePermissions(_module) ?? const <String, bool>{};

  /// Master toggle: blocks only when stored explicitly as false.
  static bool _sectionOn(FormPermissionsSections section) {
    final MainCoreEmployeeController? c = _c;
    if (c == null || !c.hasModuleAccess(_module)) return false;
    final bool? value =
        c.getModulePermissions(_module)[section.getDataBaseName];
    if (value == null) {
      log('[FormBuilderPermissions] section ${section.getDataBaseName} not '
          'stored on this role — treated as on');
      return true;
    }
    return value;
  }

  // ── Section master toggles ────────────────────────────────────────────────

  static bool get canUseFormPermissions =>
      _sectionOn(FormPermissionsSections.formPermissions);

  static bool get canUseResultsPermissions =>
      _sectionOn(FormPermissionsSections.resultsPermissions);

  // ── Form Permissions ──────────────────────────────────────────────────────

  /// Section AND switch. Use the named getters below, never this directly.
  static bool form(FormPermissions permission) {
    final MainCoreEmployeeController? c = _c;
    if (c == null || !canUseFormPermissions) return false;
    return c.isHasPermission(
      module: _module,
      section: FormPermissionsSections.formPermissions,
      permission: permission,
    );
  }

  static bool get canCreateForm => form(FormPermissions.createNewForm);
  static bool get canEditForm => form(FormPermissions.editForm);
  static bool get canDeleteForm => form(FormPermissions.deleteForm);
  static bool get canRestoreForm => form(FormPermissions.restoreForm);
  static bool get canDuplicateForm => form(FormPermissions.duplicateForm);
  static bool get canConvertToPdf => form(FormPermissions.convertToPdf);
  static bool get canFillOutForm => form(FormPermissions.fillOutForm);
  static bool get canShare => form(FormPermissions.share);

  /// May turn on "Edit Permission" (recipients can edit their submitted
  /// response) when publishing or sharing a form.
  static bool get canGrantEditPermission =>
      form(FormPermissions.editPermission);

  // ── Results Permissions ───────────────────────────────────────────────────

  /// The non-child switch a child is drawn under: the nearest preceding
  /// non-child in declaration order (the order Role Management lists them).
  static ResultsPermissions? _parentOf(ResultsPermissions permission) {
    if (!permission.isChild) return null;
    for (int i = permission.index - 1; i >= 0; i--) {
      final ResultsPermissions candidate = ResultsPermissions.values[i];
      if (!candidate.isChild) return candidate;
    }
    return null;
  }

  /// Section AND switch AND (for a child) its parent switch.
  static bool results(ResultsPermissions permission) {
    final MainCoreEmployeeController? c = _c;
    if (c == null || !canUseResultsPermissions) return false;
    bool on(ResultsPermissions p) => c.isHasPermission(
          module: _module,
          section: FormPermissionsSections.resultsPermissions,
          permission: p,
        );
    final ResultsPermissions? parent = _parentOf(permission);
    if (parent != null && !on(parent)) return false;
    return on(permission);
  }

  static bool get canSeeUsers => results(ResultsPermissions.users);
  static bool get canSeePendingSubmissions =>
      results(ResultsPermissions.pendingSubmissions);
  static bool get canViewSubmissions =>
      results(ResultsPermissions.viewSubmissions);
  static bool get canExportSubmissionData =>
      results(ResultsPermissions.exportSubmissionData);
  static bool get canDownloadSubmissions =>
      results(ResultsPermissions.downloadSubmissions);

  /// Files respondents uploaded (the "Uploaded Documents" page).
  static bool get canDownloadFormDigitalAssets =>
      results(ResultsPermissions.downloadFormDigitalAssets);
  static bool get canSeeAnalytics => results(ResultsPermissions.analytics);
  static bool get canExportAnalyticsData =>
      results(ResultsPermissions.exportAnalyticsData);

  /// The Users view of Results has something to show: Users is on AND at
  /// least one of its two tabs (Pending / View Submissions) is on.
  ///
  /// Large-screen bug report p.4 / p.12: with both tabs switched off the
  /// Users chip and the Pending / Submissions tabs were still drawn over a
  /// "You don't have permission" message. They now disappear with it.
  static bool get canSeeUsersView =>
      canSeePendingSubmissions || canViewSubmissions;

  /// Results is a hub; offer it when ANY of its views is allowed.
  ///
  /// Large-screen bug report p.12: the Users switch alone no longer counts —
  /// with Pending, View Submissions and Analytics all off there is nothing to
  /// open, so the Result button is hidden.
  static bool get canOpenResults => canSeeUsersView || canSeeAnalytics;

  // ── Create Group Permissions ──────────────────────────────────────────────

  /// The section switch IS the permission (it has no children).
  ///
  /// Roles saved before the section key existed have no value for it; those
  /// keep the old behaviour (allowed when Share is allowed) instead of losing
  /// group creation outright.
  static bool get canCreateGroup {
    final MainCoreEmployeeController? c = _c;
    if (c == null || !c.hasModuleAccess(_module)) return false;
    final bool? value = c.getModulePermissions(_module)[
        FormPermissionsSections.createGroupPermissions.getDataBaseName];
    return value ?? canShare;
  }
}
