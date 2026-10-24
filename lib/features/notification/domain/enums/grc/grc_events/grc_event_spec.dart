/// Module: notification/enums
///
///*************************** FILE INFO ****************************///
/// File Name: grc_event_spec.dart
/// Description: `_GrcEventSpec` — split out of `grc_events.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../grc_events.dart';

// Split from grc_events.dart to keep every file under 700 lines.

/// Text and template variables of one [GrcNotificationEvent].
class _GrcEventSpec {
  const _GrcEventSpec({
    required this.key,
    required this.group,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.variables,
  });

  final String key;
  final String group;
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final Set<TemplateVariable> variables;
}
