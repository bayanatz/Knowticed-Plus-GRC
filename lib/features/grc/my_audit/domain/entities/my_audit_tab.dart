import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';

/// The 6 tabs shown on the Owner's My Audits list. Unlike [MyAuditStatus],
/// `overdue` here is a real, always re-derived UI state — see
/// `computeMyAuditTab` and `buildMyAuditItems` in my_audit_resolver.dart.
enum MyAuditTab {
  pending,
  outstanding,
  scored,
  rejected,
  overdue;

  String get label {
    switch (this) {
      case MyAuditTab.pending:
        return 'Pending';
      case MyAuditTab.outstanding:
        return 'Outstanding';
      case MyAuditTab.scored:
        return 'Scored';
      case MyAuditTab.rejected:
        return 'Rejected';
      case MyAuditTab.overdue:
        return 'Overdue';
    }
  }
}

/// Visual identity (color + icon) for one [MyAuditTab], shared by the
/// status pill on the card, tab bar, and details page — same convention as
/// `AssignmentControlTabStyle`/`ApprovalStatusStyle`.
class MyAuditTabStyle {
  final Color color;
  final IconData icon;

  const MyAuditTabStyle({required this.color, required this.icon});

  static MyAuditTabStyle of(MyAuditTab tab) {
    switch (tab) {
      case MyAuditTab.pending:
        return MyAuditTabStyle(color: AppColors.warning, icon: Icons.schedule);
      case MyAuditTab.outstanding:
        return MyAuditTabStyle(color: AppColors.warning, icon: Icons.hourglass_bottom);
      case MyAuditTab.scored:
        return const MyAuditTabStyle(color: Colors.green, icon: Icons.check_circle);
      case MyAuditTab.rejected:
        return const MyAuditTabStyle(color: Colors.red, icon: Icons.block);
      case MyAuditTab.overdue:
        return const MyAuditTabStyle(color: Colors.red, icon: Icons.alarm);
    }
  }
}
