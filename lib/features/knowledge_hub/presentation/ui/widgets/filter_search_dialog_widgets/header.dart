/// Module: knowledge_hub/presentation/ui/widgets/filter_search_dialog_widgets
///
///*************************** FILE INFO ****************************///
/// File Name: header.dart
/// Description: `buildHeader()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

Widget buildHeader(BuildContext context, bool lightMode) {
  // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 15./16./16. row.
  return CustomDialogHeader(
    title: S.of(context).filter,
    icon: 'assets/icons_assets/main_icons_assets/ic_action_filter.svg',
  );
}
