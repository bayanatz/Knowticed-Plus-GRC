/// Module: roles / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: role_demo_data_buttons.dart
/// Description: Debug-only Load / Remove Demo Data buttons for Role
///              Management (checklist 12, K-17). Shown only in debug builds
///              and only to the company admin.
/// Author: Moataz Handousa
/// Created at: 21/10/2026
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/data/services/role_management_demo_service.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Whether the signed-in employee is the company admin (debug builds only).
bool get showRoleDemoButtons {
  if (!kDebugMode) return false;
  final String me =
      (AppControllers.employee.employeeEntity?.email ?? '').toLowerCase();
  final String admin =
      (AppControllers.company.state.company?.email?.emails?.last ?? '')
          .toLowerCase();
  return me.isNotEmpty && me == admin;
}

class RoleDemoDataButtons extends StatefulWidget {
  /// Called after a load or remove so the page re-reads its lists.
  final VoidCallback onChanged;

  const RoleDemoDataButtons({super.key, required this.onChanged});

  @override
  State<RoleDemoDataButtons> createState() => _RoleDemoDataButtonsState();
}

class _RoleDemoDataButtonsState extends State<RoleDemoDataButtons> {
  final RoleManagementDemoService _service = RoleManagementDemoService();
  bool _busy = false;

  Future<void> _run(Future<String> Function() job) async {
    if (_busy) return;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final String message = await job();
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onChanged();
    messenger.showSnackBar(SnackBar(
      duration: const Duration(seconds: 8),
      content: Text(message),
    ));
  }

  Future<String> _load() async {
    final S s = S.of(context);
    final RoleDemoResult r = await _service.load();
    final String counts =
        '${r.roles} Roles · ${r.accessLines} Access · ${r.accounts} Accounts · ${r.logs} Logs';
    return r.problems.isEmpty
        ? '${s.roleDemoDone}: $counts'
        : '${s.roleDemoDone}: $counts\n${r.problems.join('\n')}';
  }

  Future<String> _remove() async {
    final S s = S.of(context);
    final int n = await _service.remove();
    return '${s.roleDemoRemoved}: $n';
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final TextStyle style = StyleText.fontSize14Weight500
        .copyWith(color: AppColors.textButton, letterSpacing: .1);
    return Opacity(
      opacity: _busy ? 0.6 : 1,
      child: AbsorbPointer(
        absorbing: _busy,
        child: Row(
          spacing: 10.sp,
          children: [
            customButton(
              title: _busy ? s.roleDemoWorking : s.roleDemoLoad,
              function: () => _run(_load),
              width: 180.w,
              height: 38.h,
              textStyle: style,
            ),
            customButton(
              title: s.roleDemoRemove,
              function: () => _run(_remove),
              width: 180.w,
              height: 38.h,
              textStyle: style,
            ),
          ],
        ),
      ),
    );
  }
}
