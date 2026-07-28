// lib/features/grc/approval/domain/entities/approval_status.dart
/// Lifecycle status of one Approval document (one per control+champion
/// pair — see the design spec's "Approval doc lifecycle" section).
enum ApprovalStatus {
  pending,
  approved,
  rejected;

  String get value {
    switch (this) {
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  static ApprovalStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      case 'pending':
      default:
        return ApprovalStatus.pending;
    }
  }
}
