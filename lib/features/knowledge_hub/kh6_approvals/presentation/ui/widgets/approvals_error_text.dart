/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_error_text.dart
/// Description: Turns an `ApprovalsErrorKey` from the cubit into translated
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_states.dart';

extension ApprovalsErrorText on ApprovalsErrorKey {
  /// The message to show for this error. For [ApprovalsErrorKey.unknown] the
  /// technical [detail] is shown when there is one, else a generic error.
  String text(BuildContext context, {String detail = ''}) {
    final s = S.of(context);
    switch (this) {
      case ApprovalsErrorKey.accountNotLoaded:
        return s.accountDataLoadError;
      case ApprovalsErrorKey.loadFailed:
        return s.errorLoadingApprovals;
      case ApprovalsErrorKey.sessionExpired:
        return s.approvalsSessionExpired;
      case ApprovalsErrorKey.statusUpdateFailed:
        return s.approvalsStatusUpdateFailed;
      case ApprovalsErrorKey.noApprovePermission:
        return s.approvalsNoApprovePermission;
      case ApprovalsErrorKey.noRejectPermission:
        return s.approvalsNoRejectPermission;
      case ApprovalsErrorKey.notPendingInQueue:
        return s.approvalsNotPendingInQueue;
      case ApprovalsErrorKey.approveFailed:
        return s.approvalsApproveFailed;
      case ApprovalsErrorKey.rejectFailed:
        return s.approvalsRejectFailed;
      case ApprovalsErrorKey.addCommentFailed:
        return s.approvalsAddCommentFailed;
      case ApprovalsErrorKey.recordActionFailed:
        return s.approvalsRecordActionFailed;
      case ApprovalsErrorKey.unknown:
        return detail.isNotEmpty ? detail : s.error;
    }
  }
}
