/// Module: services / sv7_approvals / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: approval_request_state.dart
/// Purpose: State for ApprovalRequestCubit — the per-state request counts
///          shown as status chips on the approvals list.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:equatable/equatable.dart';

class ApprovalRequestCounts extends Equatable {
  final int total;
  final int pending;
  final int approved;
  final int cancel;
  final int done;
  final int rejected;
  final int inProgress;
  final int branchSla;

  const ApprovalRequestCounts({
    this.total = 0,
    this.pending = 0,
    this.approved = 0,
    this.cancel = 0,
    this.done = 0,
    this.rejected = 0,
    this.inProgress = 0,
    this.branchSla = 0,
  });

  @override
  List<Object?> get props => [
        total,
        pending,
        approved,
        cancel,
        done,
        rejected,
        inProgress,
        branchSla,
      ];
}

typedef ApprovalRequestState = ApprovalRequestCounts;
