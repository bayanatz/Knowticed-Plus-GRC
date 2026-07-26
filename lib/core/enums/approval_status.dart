import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';

/// by : mohamed ashraf
enum ApprovalStatus {
  all,
  approved,
  pending,
  rejected,
  canceled,
}

extension GetApprovalStatusName on ApprovalStatus {
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

  /// Single source of truth for status->color across every GRC request
  /// screen — was previously re-derived independently in 3 places.
  Color get color {
    switch (this) {
      case ApprovalStatus.approved:
        return AppColors.green;
      case ApprovalStatus.rejected:
        return AppColors.red;
      case ApprovalStatus.canceled:
        return AppColors.colorGrey;
      case ApprovalStatus.pending:
      case ApprovalStatus.all:
        return AppColors.orange;
    }
  }
}
