/// Module: form_builder_module/presentation
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_no_permission.dart
/// Description: Shown in place of a Form Builder view the signed-in role is
///          not allowed to see (see FormBuilderAccess).
/// Author: Amr Mesbah
/// Created at: 12/10/2026
///
/// Used where a view cannot simply be removed — e.g. a Results tab, whose
/// TabController length is fixed (user_screen.dart explains why gating the
/// tab itself crashes). The tab stays; its content says why it is empty.
library;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class FormBuilderNoPermission extends StatelessWidget {
  const FormBuilderNoPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text(
          S.of(context).fbNoPermissionSection,
          textAlign: TextAlign.center,
          style: StyleText.fontSize14Weight400.copyWith(color: AppColors.icon),
        ),
      ),
    );
  }
}
