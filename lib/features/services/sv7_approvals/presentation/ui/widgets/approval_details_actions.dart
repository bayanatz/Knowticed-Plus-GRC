/// Module: services / sv7_approvals / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approval_details_actions.dart
/// Purpose: The Approve / Reject buttons of the approval details page with
///          their confirm-and-reason dialogs. The decision is made by
///          ApprovalRequestDetailsCubit; afterwards the module lists are
///          refreshed and the user goes back to the approvals list.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_approve_reject_buttons.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/helper/current_user_context.dart';
import 'package:knowticed_plus/features/services/helpers/services_feedback.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/controller/approval_request_details_cubit.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/pages/approval_request_toggle.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ApprovalDetailsActions extends StatefulWidget {
  const ApprovalDetailsActions({
    required this.myState,
    required this.documentState,
    required this.serviceNameEnglish,
    required this.serviceNameArabic,
    super.key,
  });

  /// This approver's own step ('pending', 'waiting', 'approved', ...).
  final String? myState;

  /// The request's saved status.
  final String? documentState;
  final String serviceNameEnglish;
  final String serviceNameArabic;

  @override
  State<ApprovalDetailsActions> createState() => _ApprovalDetailsActionsState();
}

class _ApprovalDetailsActionsState extends State<ApprovalDetailsActions> {
  final TextEditingController _approveController = TextEditingController();
  final TextEditingController _rejectController = TextEditingController();

  @override
  void dispose() {
    _approveController.dispose();
    _rejectController.dispose();
    super.dispose();
  }

  /// Saves the decision; on success refreshes the module lists.
  Future<bool> _submit({required bool approve}) async {
    final email = CurrentUserContext.email ?? '';
    if (email.isEmpty) return false;
    final cubit = context.read<ApprovalRequestDetailsCubit>();
    final manager = ServicesManagerCubit.get(context);
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);
    final ok = approve
        ? await cubit.approve(
            approverEmail: email,
            comment: _approveController.text,
            displayServiceName: widget.serviceNameEnglish,
            displayServiceNameArabic: widget.serviceNameArabic,
          )
        : await cubit.reject(
            approverEmail: email,
            comment: _rejectController.text,
            displayServiceName: widget.serviceNameEnglish,
            displayServiceNameArabic: widget.serviceNameArabic,
          );
    if (!ok) {
      // SVC-REQ-10: say why the decision was refused.
      ServicesFeedback.showWarning(
        messenger,
        ServicesFeedback.refusalText(s, cubit.lastRefusal),
      );
      return false;
    }
    // SVC-REQ-08: the decision is saved, but tell the approver when the
    // next person could not be notified.
    if (cubit.lastNotificationFailed) {
      ServicesFeedback.showWarning(messenger, s.svcDecisionSavedNotifyFailed);
    }
    manager.getAllServices();
    manager.getMyRequestServices();
    manager.loadProviderPerDocument();
    await manager.getMyApprovalServices(email);
    return true;
  }

  void _backToList() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) navigateTo(context, ApprovalToggle());
    });
  }

  void _openDialog({required bool approve}) {
    final s = S.of(context);
    CustomDialogManager.showDialogFlow(
      confirmWidth: 411,
      context: context,
      customReasonTitle: approve ? s.reasonOfApproval : s.reasonOfRejection,
      confirmLottie:
          approve ? ServicesLottie.approved : ServicesLottie.rejected,
      confirmTitle: approve ? s.ApproveRequest : s.RejectRequest,
      confirmSubtitle: approve
          ? s.AreYouSureYouWantToApproveThisRequest
          : s.AreYouSureYouWantToRejectThisRequest,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () async => true,
      comment: true,
      // A reason is required for both decisions.
      commentRequired: true,
      commentController: approve ? _approveController : _rejectController,
      commentSubmitText: s.submit,
      commentDiscardText: s.discard,
      onCommentSubmit: () => _submit(approve: approve),
      successLottie:
          approve ? ServicesLottie.approved : ServicesLottie.rejected,
      successTitle: approve ? s.Successful : s.RejectRequest,
      successSubtitle: approve
          ? s.YouSuccessfullyApprovedThisRequest
          : s.YouSuccessfullyRejectedThisRequest,
      onSuccessDismissed: _backToList,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Without "Approve And Reject" the page stays readable but offers no
    // action.
    if (!ServicesModuleAccess.canApproveAndReject) return const SizedBox();
    return CustomApproveRejectButtons(
      myState: widget.myState,
      documentState: widget.documentState,
      onApprove: () => _openDialog(approve: true),
      onReject: () => _openDialog(approve: false),
    );
  }
}
