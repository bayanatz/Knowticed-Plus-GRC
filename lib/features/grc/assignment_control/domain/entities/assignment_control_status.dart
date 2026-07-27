/// Lifecycle status of one Assignment_Controls submission cycle. Only
/// `submitted`, `inReview`, `rejected`, and `approved` are ever persisted by
/// this feature (Pending/Overdue are always derived, never stored — see the
/// design spec) — `pending`/`overdue` exist here only so `fromString` stays
/// total and forward-compatible with the future Approvals/My Audits specs.
enum AssignmentControlStatus {
  pending,
  submitted,
  inReview,
  rejected,
  approved,
  overdue;

  String get value {
    switch (this) {
      case AssignmentControlStatus.pending:
        return 'Pending';
      case AssignmentControlStatus.submitted:
        return 'Submitted';
      case AssignmentControlStatus.inReview:
        return 'In review';
      case AssignmentControlStatus.rejected:
        return 'Rejected';
      case AssignmentControlStatus.approved:
        return 'Approved';
      case AssignmentControlStatus.overdue:
        return 'Overdue';
    }
  }

  static AssignmentControlStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'submitted':
        return AssignmentControlStatus.submitted;
      case 'in review':
        return AssignmentControlStatus.inReview;
      case 'rejected':
        return AssignmentControlStatus.rejected;
      case 'approved':
        return AssignmentControlStatus.approved;
      case 'overdue':
        return AssignmentControlStatus.overdue;
      case 'pending':
      default:
        return AssignmentControlStatus.pending;
    }
  }
}
