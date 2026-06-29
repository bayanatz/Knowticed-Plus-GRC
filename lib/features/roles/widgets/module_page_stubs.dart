// Stub pages for modules not included in demo_app.
// All module entry-point page stubs live here so there is one place to find them.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart'
    show SettingsScreen;

// // ── GRC ──────────────────────────────────────────────────────────────────────

// class GrcResponsivePage extends StatelessWidget {
//   const GrcResponsivePage({super.key});
//   @override
//   Widget build(BuildContext context) =>
//       Scaffold(body: Center(child: Text('GrcResponsivePage'.tr)));
// }

// class GrcResponsivePageRefactor extends StatelessWidget {
//   const GrcResponsivePageRefactor({super.key});
//   @override
//   Widget build(BuildContext context) =>
//       Scaffold(body: Center(child: Text('GRC'.tr)));
// }

// ── Form Builder ─────────────────────────────────────────────────────────────

class FormResponsivePage extends StatelessWidget {
  const FormResponsivePage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('FormResponsivePage'.tr)));
}

// ── Tracker ───────────────────────────────────────────────────────────────────

class TrackerPageResponsivePageRefactor extends StatelessWidget {
  const TrackerPageResponsivePageRefactor({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      body: Center(child: Text('TrackerPageResponsivePageRefactor'.tr)));
}

// ── Task Management ───────────────────────────────────────────────────────────

class TasksResponsivePage extends StatelessWidget {
  const TasksResponsivePage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('TasksResponsivePage'.tr)));
}

// ── Settings (backward-compat wrapper) ───────────────────────────────────────

class Settings extends StatelessWidget {
  const Settings({super.key});
  @override
  Widget build(BuildContext context) => SettingsScreen();
}
