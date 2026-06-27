// ============================================================================
// RemovedModulePage
// ----------------------------------------------------------------------------
// A neutral placeholder screen shown when a module has been removed from this
// (demo) copy of the app. Buttons that used to open a removed module's pages
// now open this page instead, so the app still compiles WITHOUT copying the
// real module code from the master (demo_app_plus) app.
//
// To "restore" a module later, just import its real page again and swap the
// navigation target back.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RemovedModulePage extends StatelessWidget {
  /// Optional name of the module, shown in the message (e.g. "Services").
  final String? moduleName;

  const RemovedModulePage({super.key, this.moduleName});

  @override
  Widget build(BuildContext context) {
    final title = moduleName == null
        ? 'This module is not available'.tr
        : '${moduleName!} ${'is not available'.tr}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
