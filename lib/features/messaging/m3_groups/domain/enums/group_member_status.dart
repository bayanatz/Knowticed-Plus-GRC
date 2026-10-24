/// Module: messaging / groups / domain/enum/group_member_status.dart
/// ************************* FILE INFO *************************** ///
/// File Name: group_member_status.dart
/// Purpose: Group member status — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

import 'package:flutter/widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// A group member's role in the chat. CHANGED 17/10/2026: lowerCamelCase
/// values (only kept in memory — Firestore stores member ids + isAdmin) and a
/// translated [label]; the dropdown used to show the raw English `.name` in
/// Arabic too.
enum GroupMemberStatus {
  member,
  admin;

  String label(BuildContext context) => this == GroupMemberStatus.admin
      ? S.of(context).groupAdmin
      : S.of(context).member;
}
