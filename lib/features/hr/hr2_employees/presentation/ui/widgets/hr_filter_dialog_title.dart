// ***************************** FILE INFO ***************************** //
// File Name: hr_filter_dialog_title.dart
// Purpose: Displays the shared title row for HR employee filter dialogs.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'package:flutter/material.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

/// Renders the localized icon-and-title heading shared by filter dialogs.
class HrFilterDialogTitle extends StatelessWidget {
  const HrFilterDialogTitle({super.key});

  @override
  Widget build(BuildContext context) {
    // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 20./20./12. row.
    return CustomDialogHeader(
        title: S.of(context).filter,
        icon: 'assets/icons_assets/main_icons_assets/ic_action_filter.svg');
  }
}
