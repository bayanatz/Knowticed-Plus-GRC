/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: module_page_stubs.dart
/// Purpose: Declares `GrcResponsivePage`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// Stub services_management_module for modules not included in knowticed.
// All module entry-point page stubs live here so there is one place to find them.
import 'package:flutter/material.dart';
import 'package:grc_module/features/settings/presentation/ui/pages/settings_screen.dart'
    show SettingsScreen;
import 'package:grc_module/core/custom/feedback/removed_module_placeholder.dart';
import 'package:grc_module/generated/l10n.dart';

// ── GRC ──────────────────────────────────────────────────────────────────────

class GrcResponsivePage extends StatelessWidget {
  const GrcResponsivePage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(S.current.grcresponsivepage)));
}

// ── Form Builder ─────────────────────────────────────────────────────────────

class FormResponsivePage extends StatelessWidget {
  const FormResponsivePage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(S.current.formresponsivepage)));
}

// ── Tracker ───────────────────────────────────────────────────────────────────

class TrackerPageResponsivePageRefactor extends StatelessWidget {
  const TrackerPageResponsivePageRefactor({super.key});
  @override
  Widget build(BuildContext context) =>
      // CHANGED 16/10/2026: same as Tasks, the old Tracking page (replaced by
      // Time Tracker) showed its class name.
      RemovedModulePage(moduleName: S.current.tracking);
}

// ── Task Management ───────────────────────────────────────────────────────────

class TasksResponsivePage extends StatelessWidget {
  const TasksResponsivePage({super.key});
  @override
  Widget build(BuildContext context) =>
      // CHANGED 16/10/2026 (merge check): showed the developer class name
      // "TasksResponsivePage". The Tasks module is not in this project yet.
      RemovedModulePage(moduleName: S.current.tasks);
}

// ── Settings (backward-compat wrapper) ───────────────────────────────────────

class Settings extends StatelessWidget {
  const Settings({super.key});
  @override
  Widget build(BuildContext context) => SettingsScreen();
}
