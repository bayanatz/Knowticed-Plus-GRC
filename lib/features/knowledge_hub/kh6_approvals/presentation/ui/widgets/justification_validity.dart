/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: justification_validity.dart
/// Description: When the Approve / Reject justification may be submitted.
/// Author: Amr Mesbah
/// Created at: 14/10/2026
///
/// Submit is enabled once the box has text. The reason may be written in
/// is no language rule here or on the text field.
library;

import 'dart:ui' as ui;

bool isJustificationValid(String text, ui.TextDirection direction) =>
    text.trim().isNotEmpty;
