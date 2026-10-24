/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: debug_view_tests_button.dart
/// Purpose: DEBUG-ONLY app-bar chip "🧪 View tests" — sends the signed-in
///          user one notification of every kind, each pointing at a real
///          record, so View can be checked module by module.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Owner, 22/10/2026: every notification's View opens the record. Real
/// notifications go to OTHER people (the approver, the owner), so they never
/// reach the tester's inbox; each module's `send…ViewTests` sends its kinds
/// through its real sender path to [receiverEmail] instead. Shown only with
/// the debug test-employee switch (absent from release builds), like the
/// Customs chip beside it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/database/helpers/debug/database_view_tests.dart'; // [module:database]
import 'package:knowticed_plus/features/form_builder/helpers/debug/form_builder_view_tests.dart'; // [module:form_builder]
import 'package:knowticed_plus/features/grc/helpers/debug/grc_view_tests.dart'; // [module:grc]
import 'package:knowticed_plus/features/knowledge_hub/helpers/debug/knowledge_hub_view_tests.dart'; // [module:knowledge_hub]
import 'package:knowticed_plus/features/messaging/helpers/debug/messages_view_tests.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart';
import 'package:knowticed_plus/features/roles/helpers/debug/roles_view_tests.dart';
import 'package:knowticed_plus/features/services/helpers/debug/services_view_tests.dart'; // [module:services]
import 'package:knowticed_plus/features/settings/helpers/debug/settings_view_tests.dart';

typedef _ViewTestSender = Future<int> Function(
    {required String receiverEmail, required bool isArabic});

final Map<String, _ViewTestSender> _senders = <String, _ViewTestSender>{
  'Services': sendServicesViewTests, // [module:services]
  'Settings': sendSettingsViewTests,
  'Knowledge Hub': sendKnowledgeHubViewTests, // [module:knowledge_hub]
  'Form Builder': sendFormBuilderViewTests, // [module:form_builder]
  'Roles': sendRolesViewTests,
  'GRC': sendGrcViewTests, // [module:grc]
  'Database': sendDatabaseViewTests, // [module:database]
  'Messages': sendMessagesViewTests,
};

class DebugViewTestsButton extends StatefulWidget {
  const DebugViewTestsButton({super.key});

  @override
  State<DebugViewTestsButton> createState() => _DebugViewTestsButtonState();
}

class _DebugViewTestsButtonState extends State<DebugViewTestsButton> {
  bool _running = false;

  Future<void> _run() async {
    if (_running) return;
    final String email = Get.isRegistered<MainCoreEmployeeController>()
        ? (Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? '')
        : '';
    if (email.isEmpty) return;
    HapticController.low();
    setState(() => _running = true);
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final List<String> lines = <String>[];
    for (final MapEntry<String, _ViewTestSender> e in _senders.entries) {
      int sent = 0;
      try {
        sent = await e.value(receiverEmail: email, isArabic: isArabic);
      } catch (error) {
        debugPrint('[ViewTests] ${e.key} failed: $error');
      }
      lines.add('${e.key}: $sent');
    }
    if (!mounted) return;
    setState(() => _running = false);
    CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
      title: 'View tests sent',
      subtitle: lines.join('\n'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isDebugTestEmployeeSwitchEnabled()) return const SizedBox.shrink();
    return GestureDetector(
      key: const ValueKey<String>('debugViewTestsButton'),
      behavior: HitTestBehavior.opaque,
      onTap: _run,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          _running ? '🧪 Sending…' : '🧪 View tests',
          maxLines: 1,
          style: StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
        ),
      ),
    );
  }
}
