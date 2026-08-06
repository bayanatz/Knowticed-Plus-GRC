import 'package:flutter/material.dart';

import 'package:grc_module/core/theme/app_colors.dart';

/// by : mohamed ashraf
enum ApprovalStatus {
  all,
  approved,
  pending,
  rejected,
  canceled,
}

extension GetApprovalStatusName on ApprovalStatus {
  /// Status colour used by pills, banners and filter chips.
  ///
  /// Mirrors the palette in `grc/approval/domain/entities/approval_resolver.dart`
  /// (`ApprovalStatusStyle`) so the GRC request screens and the Approvals
  /// screens stay visually consistent.
  Color get color {
    switch (this) {
      case ApprovalStatus.approved:
        return Colors.green;
      case ApprovalStatus.pending:
        return AppColors.warning;
      case ApprovalStatus.rejected:
        return Colors.red;
      case ApprovalStatus.canceled:
        return AppColors.delete;
      case ApprovalStatus.all:
        return AppColors.text;
    }
  }

  String get getName {
    switch (this) {
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.rejected:
        return 'Rejected';
      case ApprovalStatus.canceled:
        return 'Canceled';
      case ApprovalStatus.all:
        return 'All';
    }
  }

  String get getOrderName {
    switch (this) {
      case ApprovalStatus.approved:
        return 'Approve';
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.rejected:
        return 'Reject';
      case ApprovalStatus.canceled:
        return 'Cancel';
      case ApprovalStatus.all:
        return 'All';
    }
  }
}
